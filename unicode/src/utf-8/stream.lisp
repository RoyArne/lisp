;;;; This is "unicode/src/utf-8/stream.lisp".

(in-package #:unicode.utf-8)
                            

(declaim (ftype (function (stream octets vector:index)
                          (values vector:index boolean))
                read-code-point!)

         (ftype (function (stream octets vector:index vector:index)
                          (values vector:index boolean))
                fill-vector!))

(defun read-code-point! (stream vector start)
  ;; Reads one code point from stream and stores it at start in vector.
  ;;
  ;; Returns two values: the end index of the code points encoding in vector, and
  ;;                     a boolean which is true if we hit end of file.
  ;;
  ;;                     the end index is equal to start if we hit end of file.
  ;;
  ;; We assume there are at least 4 octets of free space at start in vector.
  ;;
  ;; Signals an error of type utf-8-error if the code points encoding is
  ;; incorrect.
  (handler-case
      (case (%encoding-length (setf (octet1 vector start) (read-byte stream)))
        (1
         (values (1+ start) nil))
        (2
         (unless (continuation? (setf (octet2 vector start) (read-byte stream)))
           (error 'utf-8-error
                  :message "The octet sequence~%  ~S~%~
                              is an invalid two-octet UTF-8 encoding."
                  :octets (subseq vector start (+ start 2))))
         (values (+ start 2) nil))
        (3
         (unless (and (continuation? (setf (octet2 vector start) (read-byte stream)))
                      (continuation? (setf (octet3 vector start) (read-byte stream))))
           (error 'utf-8-error
                  :message "The octet sequence~%  ~S~%~
                              is an invalid three-octet UTF-8 encoding."
                  :octets (subseq vector start (+ start 3))))
         (values (+ start 3) nil))
        (4
         (unless (and (continuation? (setf (octet2 vector start) (read-byte stream)))
                      (continuation? (setf (octet3 vector start) (read-byte stream)))
                      (continuation? (setf (octet4 vector start) (read-byte stream))))
           (error 'utf-8-error
                  :message "The octet sequence~%  ~S~%~
                              is an invalid four-octet UTF-8 encoding."
                  :octets (subseq vector start (+ start 4))))
         (values (+ start 4) nil)))
    (end-of-file ()
      (values start t))))

(defun fill-vector! (stream vector start end)
  ;; Attempts to fill vector from start up to end with code points read from
  ;; stream. The final code point may overflow by up to three octets.
  ;;
  ;; Returns two values: the end index of the encoding of the last code point
  ;;                     read from stream, and
  ;;                     a boolean which is true if we hit end of file.
  ;;
  ;; We use read-code-point! to read the code points from stream. It may
  ;; signal an utf-8-error if it any code points encoding is incorrect.
  (let ((index start))
    (loop (multiple-value-bind (next end-of-file?)
              (read-code-point! stream vector index)
            (cond
              (end-of-file?
               (return-from fill-vector! (values index end-of-file?)))
              ((< next end)
               (setf index next))
              (t
               (return-from fill-vector! (values next end-of-file?))))))))


(defstruct buffer
  (octets (coerce #() 'octets) :type octets)
  (end 0 :type vector:index))

(declaim (type fixnum +buffer-size+ +overflow-size+)

         (ftype (function ()
                          buffer)
                initialize-buffer))

;; The octet vectors in our buffers can hold +buffer-size+ octets plus an
;; additional +overflow-size+ octets.
;;
;; The overflow size allows us to read entire code points into the buffer: we
;; don't want to deal with code points that are partially loaded.
;;
;; Additionally, the buffer must be large enough to accommodate our unread
;; limit of two code points, while looking ahead to check for CRLF sequences:
;;
;;   A CRLF sequence may span from the last octet in the current-buffer to the
;;   first octet in the next-buffer. 
;;
;;   Once we fill the next-buffer with data, we MUST NOT go pack to the
;;   prev-buffer because doing so would invalidate the next-buffer.
;;
;;   Worst case scenario: we need to look ahead for a CRLF sequence, going
;;   into the next-buffer, not reading it, and then unreading two code points
;;   prior to the CRLF sequence.
;;
;;   Therefore, the current-buffer must be able to store one CR code point
;;   plus two other code-points for unread.

(defconstant +buffer-size+ 12)  ; enough for three x four-octet encoded code points
(defconstant +overflow-size+ 4) ; enough for one four-octet encoded code point

(defun initialize-buffer ()
  (make-buffer :octets (make-octets (+ +buffer-size+ +overflow-size+)) :end 0))


(defstruct (octet-stream (:conc-name nil))
  (buffer-stream nil :type (or null stream))
  (prev-buffer (initialize-buffer) :type buffer)
  (current-buffer (initialize-buffer) :type buffer)
  (buffer-index 0 :type vector:index)
  (next-buffer (initialize-buffer) :type buffer)
  ;; EoF indicates that there is no more to read from stream, we still need to
  ;; look at buffer index and the state of our buffers before signaling eof.
  (buffer-end-of-file? nil :type boolean)
  ;; Unread count goes up to 2 to accommodate CRLF newline sequences.
  (unread-count 0 :type (integer 0 2)))


(declaim (ftype (function (octet-stream)
                          octet-stream)
                fill-next-buffer!
                use-next-buffer!
                use-prev-buffer!)

         (ftype (function (octet-stream)
                          boolean)
                use-next-buffer?
                use-prev-buffer?))

(defun fill-next-buffer! (octet-stream)
  ;; Fill the octet-streams next-buffer, returning octet-stream.
  (let ((buffer (next-buffer octet-stream)))
    (cond
      ((buffer-end-of-file? octet-stream)
       (setf (buffer-end buffer) 0))
      (t
       (multiple-value-bind (end end-of-file?)
           (fill-vector! (buffer-stream octet-stream) (buffer-octets buffer) 0 +buffer-size+)
         (setf (buffer-end buffer) end
               (buffer-end-of-file? octet-stream) end-of-file?)))))
  octet-stream)

;;; Note: Take care not to switch to prev buffer if there is data in next
;;;       buffer; next-buffer will be permanently lost.
;;;
;;;       Switching to prev buffer MUST only happen when we have to unread a
;;;       code point right after switching next to current.
;;;
;;;       The unread limit of 2 code points MUST be enforced.

(defun use-next-buffer? (octet-stream)
  ;; We have to switch to the next buffer when reading code points and our
  ;; index reaches buffer end.
  (= (buffer-index octet-stream) (buffer-end (current-buffer octet-stream))))

(defun use-next-buffer! (octet-stream)
  ;; The next-buffer is moved into the current-buffer. We move the
  ;; current-buffer into the prev-buffer, and the prev-buffer is invalidated
  ;; and moved into the next-buffer.
  ;;
  ;; Any data in the prev-buffer is lost.
  (let ((invalidated-buffer (prev-buffer octet-stream)))
    ;; Cycle through buffers next ← prev ← current ← next.
    (setf (prev-buffer octet-stream) (current-buffer octet-stream)
          (current-buffer octet-stream) (next-buffer octet-stream)
          (next-buffer octet-stream) invalidated-buffer)
    ;; Update indices
    (setf (buffer-index octet-stream) 0
          (buffer-end invalidated-buffer) 0))
  octet-stream)

(defun use-prev-buffer? (octet-stream)
  ;; We have to switch to the prev buffer when unreading code points and our
  ;; index is at zero.
  (zerop (buffer-index octet-stream)))

(defun use-prev-buffer! (octet-stream)
  ;; The prev-buffer is moved into the current-buffer. We move the
  ;; current-buffer into the next-buffer, and the next-buffer is invalidated
  ;; and moved into the prev-buffer.
  ;;
  ;; Any data in the next-buffer is lost.
  (let ((invalidated-buffer (next-buffer octet-stream)))
    ;; Cycle through buffers next → prev → current → next.
    (setf (next-buffer octet-stream) (current-buffer octet-stream)
          (current-buffer octet-stream) (prev-buffer octet-stream)
          (prev-buffer octet-stream) invalidated-buffer)
    ;; Update indices
    (setf (buffer-index octet-stream) (previous (buffer-octets (current-buffer octet-stream))
                                              (buffer-end (current-buffer octet-stream)))
          (buffer-end invalidated-buffer) 0))
  octet-stream)


(declaim (ftype (function (stream)
                          octet-stream)
                initialize-octet-stream))

(defun initialize-octet-stream (stream)
  ;; We wrap the stream in an octet-stream structure and preload a buffer
  ;; worth of text. The preloaded buffer is set as the current buffer,
  ;; returning the new octet-stream.
  (use-next-buffer! (fill-next-buffer! (make-octet-stream :buffer-stream stream
                                                          :current-buffer (initialize-buffer)
                                                          :buffer-index 0
                                                          :prev-buffer (initialize-buffer)
                                                          :next-buffer (initialize-buffer)
                                                          :buffer-end-of-file? nil))))



(declaim (ftype (function (buffer)
                          boolean)
                invalid-buffer?)

         (ftype (function (octet-stream)
                          boolean)
                invalid-prev-buffer?
                invalid-current-buffer?
                invalid-next-buffer?)

         (ftype (function (octet-stream vector:index)
                          boolean)
                in-current-buffer?))

(defun invalid-buffer? (buffer)
  ;; An end index of zero means there is no data in the buffer.
  (zerop (buffer-end buffer)))

(defun invalid-prev-buffer? (octet-stream)
  (invalid-buffer? (prev-buffer octet-stream)))

(defun invalid-current-buffer? (octet-stream)
  (invalid-buffer? (current-buffer octet-stream)))

(defun invalid-next-buffer? (octet-stream)
  (invalid-buffer? (next-buffer octet-stream)))

(defun in-current-buffer? (octet-stream index)
  (< index (buffer-end (current-buffer octet-stream))))


(declaim (type octet +linefeed+ +return+ +newline+)

         (ftype (function (octet-stream)
                          (values))
                skip-cr-in-crlf-sequence!)

         (ftype (function (octet-stream octets vector:index)
                          (values vector:index boolean))
                read-code-point))

;;; We use +newline+ as our newline character.
;;;
;;; We accept single +newline+ octets and +return+ +linefeed+ octet sequences
;;; (CRLF) as our newlines. We do not convert CRLF sequences when they go into
;;; the buffer, that happens when they are read.
;;;
;;; There is no mechanism to allow multi-octet newline encodings. If one is
;;; added, both read-code-point and unread-code-point needs adjusting.

(defconstant +linefeed+ 10)
(defconstant +return+ 13)
(defconstant +newline+ 10)

(defun skip-cr-in-crlf-sequence! (octet-stream)
  ;; Returns true if the next two octets in octet-stream is a CRLF pair.
  ;;
  ;; The side effects caused by crlf-sequence!? assumes that checking for a
  ;; CRLF is part of a read action, and that the next step is to return the LF
  ;; part of the sequence.
  ;;
  ;; May fill the next-buffer with data in order to check for a LF. If the LF
  ;; is in the next-buffer, we make that buffer the current-buffer.
  ;;
  ;; Regardless of where the LF was found, our buffer index is set so that the
  ;; next code point is the LF.
  (when (= +return+ (aref (buffer-octets (current-buffer octet-stream)) (buffer-index octet-stream)))
    (cond
      ((in-current-buffer? octet-stream (1+ (buffer-index octet-stream)))
       (when (= +linefeed+ (aref (buffer-octets (current-buffer octet-stream)) (1+ (buffer-index octet-stream))))
         (incf (buffer-index octet-stream))))
      (t
       (when (invalid-next-buffer? octet-stream)
         (fill-next-buffer! octet-stream))
       (unless (invalid-next-buffer? octet-stream)
         (when (= +linefeed+ (aref (buffer-octets (next-buffer octet-stream)) 0))
           (use-next-buffer! octet-stream)))))))

(defun read-code-point (octet-stream vector start)
  ;; read one code point from octet stream and encode it beginning at start in
  ;; vector. return two values, the end index of the encoding and a boolean
  ;; which is true at end of file.

  ;; Switch to the next-buffer if needed.
  (when (use-next-buffer? octet-stream)
    (use-next-buffer! (if (invalid-next-buffer? octet-stream)
                          (fill-next-buffer! octet-stream)
                          octet-stream)))

  ;; Return early at end of file.
  (when (and (buffer-end-of-file? octet-stream)
             (invalid-next-buffer? octet-stream)
             (use-next-buffer? octet-stream))
    (return-from read-code-point (values start t)))

  ;; Decrement the unread counter.
  (when (plusp (unread-count octet-stream))
    (decf (unread-count octet-stream)))

  ;; Skips any cr in a crlf sequence (i.e. buffer-index is advanced, and we
  ;; may switch to the next-buffer).
  (skip-cr-in-crlf-sequence! octet-stream)

  (let ((encoding-length (copy-code-point (buffer-octets (current-buffer octet-stream)) (buffer-index octet-stream) vector start)))
    (incf (buffer-index octet-stream) encoding-length)
    (values (+ start encoding-length) nil)))

;; (defun unread-code-point (octet-stream vector start)
;;   ;; Unread the code point encoded at start in vector. Return true if the code
;;   ;; point was unread, otherwise nil.
;;   (when (< (unread-count octet-stream) 2)
;;     (let ((encoding-length (%encoding-length (aref vector start))))
;;       (cond
;;         ((use-prev-buffer? octet-stream)
;;          (when (invalid-prev-buffer? octet-stream)
;;            (return-from unread-code-point nil))
;;          (use-prev-buffer! octet-stream)
;;          (incf (unread-count octet-stream))
;;          t)
;;         ((>= (buffer-index octet-stream) encoding-length)
;;          (decf (buffer-index octet-stream) encoding-length)
;;          (incf (unread-count octet-stream))
;;          t)
;;         (t
;;          (when (invalid-prev-buffer? octet-stream)
;;            (return-from unread-code-point nil))
;;          (use-prev-buffer! octet-stream)
;;          (incf (unread-count octet-stream))
;;          t)))))
