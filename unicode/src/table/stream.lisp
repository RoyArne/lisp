;;;; This is "src/table/stream.lisp".
;;;;
;;;;   This file defines the interface for writing/reading tables from/to
;;;;   streams.
;;;;
;;;; · (read-table &key stream table-type) → table
;;;; · (write-table (table &optional stream) → table
;;;;
;;;; · (write-property-table table &optional stream) → property-table
;;;; · (read-property-table &optional stream) → property-table
;;;;
;;;; · (write-property-map table &optional stream) → property-map
;;;; · (read-property-map &optional stream) → property-map
;;;;
;;;; · (write-code-point-map table &optional stream) → code-point-map
;;;; · (read-code-point-map &optional stream) → code-point-map
;;;;
;;;; · (write-string-map table &optional stream) → string-map
;;;; · (read-string-map &optional stream) → string-map

(in-package #:unicode.table)

(defparameter *unicode.table-package* (find-package "UNICODE.TABLE"))

;; (defun make-test-to-octets (string)
;;   (loop with buckets = (make-adjustable-to-octets)
;;         with octets = (utf-8:string-to-octets string)
;;         for i = 0 then (utf-8:next octets i) while (< i (length octets))
;;         for bucket = (to-octets buckets (utf-8:encoding-length octets i))
;;         do (push-code-point (utf-8:decode-code-point octets i) bucket 4)
;;         finally (return buckets)))

;; (defun make-test-to-strings (&rest strings)
;;   (loop with buckets = (make-adjustable-to-strings)
;;         for string in (map 'list #'utf-8:string-to-octets strings)
;;         do (push-string string (aref buckets (random 4)))
;;         finally (return buckets)))


;;; ============================================================================
;;; Reading Delimiters
;;; ============================================================================

(declaim (ftype (function (stream)
                          character)
                read-table-start read-table-end))

(defun read-table-start (stream)
  (if (char= #\( (peek-char t stream))
      (read-char stream)
      (error "Cannot read a table start character from stream.")))

(defun read-table-end (stream)
  (if (char= #\) (peek-char t stream))
      (read-char stream)
      (error "Cannot read a table end character from stream.")))


;;; ============================================================================
;;; Reading and Writing Common Table Data
;;; ============================================================================

(declaim (ftype (function (stream &optional symbol)
                          symbol)
                read-table-type)

         (ftype (function (filter stream)
                          filter)
                write-filter)

         (ftype (function (stream)
                          filter)
                read-filter)

         (ftype (function (buckets stream)
                          buckets)
                write-from-octets)

         (ftype (function (stream)
                          buckets)
                read-from-octets))

(defun read-table-type (stream &optional table-type)
  (let ((type (read stream)))
    (if (eql type (or table-type type))
        type
        (error "The table type~%  ~S~%~
                read from~%  ~S~%~
                does not match the expected type~%  ~S."
               type stream table-type))))

(defun write-filter (filter stream)
  (pprint-logical-block (stream nil)
    (format stream "~S" filter))
  filter)

(defun read-filter (stream)
  (coerce (read stream) 'filter))

(defun write-from-octets (buckets stream)
  (pprint-logical-block (stream (map 'list #'utf-8:octets-to-string buckets) :prefix "(" :suffix ")")
    (pprint-indent :block 0)
    (loop do (format stream "~S" (pprint-pop))
          do (pprint-exit-if-list-exhausted)
          do (pprint-newline :mandatory stream)))
  buckets)

(defun read-from-octets (stream)
  (make-from-octets (map 'list #'utf-8:string-to-octets (read stream))))


;;; ============================================================================
;;; Reading and Writing Property Table Data
;;; ============================================================================

(declaim (ftype (function (stream)
                          property-table)
                %read-property-table))

(defun %read-property-table (stream)
  (make-property-table :filter (read-filter stream)
                       :from (read-from-octets stream)
                       :property (read stream)))


;;; ============================================================================
;;; Reading and Writing Property Map Data
;;; ============================================================================

(declaim (ftype (function (buckets stream)
                          buckets)
                write-to-properties)

         (ftype (function (stream)
                          buckets)
                read-to-properties)

         (ftype (function (stream)
                          property-map)
                %read-property-map))

(defun write-to-properties (buckets stream)
  (pprint-logical-block (stream (map 'list #'identity buckets) :prefix "(" :suffix ")")
    (pprint-indent :block 0)
    (loop do (format stream "~S" (pprint-pop))
          do (pprint-exit-if-list-exhausted)
          do (pprint-newline :mandatory stream)))
  buckets)

(defun read-to-properties (stream)
  (make-to-properties (read stream)))

(defun %read-property-map (stream)
  (make-property-map :filter (read-filter stream)
                     :from (read-from-octets stream)
                     :to (read-to-properties stream)))


;;; ============================================================================
;;; Reading and Writing Code Point Map Data
;;; ============================================================================

(declaim (ftype (function (buckets stream)
                          buckets)
                write-to-octets)

         (ftype (function (stream)
                          buckets)
                read-to-octets)
         
         (ftype (function (stream)
                          code-point-map)
                %read-code-point-map))

(defun write-to-octets (buckets stream)
  (flet ((to-string (bucket)
           (coerce (loop for i from 0 below (length bucket) by 4
                         collect (code-char (utf-8:decode-code-point bucket i)))
                   'string)))
    (pprint-logical-block (stream (map 'list #'to-string buckets) :prefix "(" :suffix ")")
      (pprint-indent :block 0)
      (loop do (format stream "~S" (pprint-pop))
            do (pprint-exit-if-list-exhausted)
            do (pprint-newline :mandatory stream))))
  buckets)

(defun read-to-octets (stream)
  (flet ((to-octets (string)
           (loop with octets = (utf-8:make-octets (* (length string) 4))
                 for char across string
                 for index = 0 then (+ index 4)
                 do (utf-8:encode-code-point (char-code char) octets index)
                 finally (return octets))))
    (make-to-octets (map 'list #'to-octets (read stream)))))

(defun %read-code-point-map (stream)
  (make-code-point-map :filter (read-filter stream)
                       :from (read-from-octets stream)
                       :to (read-to-octets stream)))


;;; ============================================================================
;;; Reading and Writing String Map Data
;;; ============================================================================

(declaim (ftype (function (buckets stream)
                          buckets)
                write-to-strings)

         (ftype (function (stream)
                          buckets)
                read-to-strings)

         (ftype (function (stream)
                          string-map)
                %read-to-strings))

(defun write-to-strings (buckets stream)
  (pprint-logical-block (stream (map 'list #'identity buckets) :prefix "(" :suffix ")")
    (pprint-indent :block 0)
    (loop do (pprint-logical-block (stream (map 'list #'utf-8:octets-to-string (pprint-pop)) :prefix "(" :suffix ")")
               (loop initially (pprint-exit-if-list-exhausted)
                     do (format stream "~S" (pprint-pop))
                     do (pprint-exit-if-list-exhausted)
                     do (write-char #\Space stream)
                     do (pprint-newline :fill stream)))
          do (pprint-exit-if-list-exhausted)
          do (pprint-newline :mandatory stream)))
  buckets)

(defun read-to-strings (stream)
  (make-to-strings (loop with list = (read stream)
                         for strings in list
                         collect (map '(vector utf-8:octets) #'utf-8:string-to-octets strings))))

(defun %read-string-map (stream)
  (make-string-map :filter (read-filter stream)
                   :from (read-from-octets stream)
                   :to (read-to-strings stream)))


;;; ============================================================================
;;; Interface for Reading and Writing Tables
;;; ============================================================================

(declaim (ftype (function ((or property-table property-map code-point-map string-map) &optional stream)
                          (or property-table property-map code-point-map string-map))
                write-table)
         
         (ftype (function (&key (:stream stream) (:table-type symbol))
                          (or property-table property-map code-point-map string-map))
                read-table)

         (ftype (function (property-table &optional stream)
                          property-table)
                write-property-table)

         (ftype (function (&optional stream)
                          property-table)
                read-property-table)

         (ftype (function (property-map &optional stream)
                          property-map)
                write-property-map)

         (ftype (function (&optional stream)
                          property-map)
                read-property-map)

         (ftype (function (code-point-map &optional stream)
                          code-point-map)
                write-code-point-map)
         
         (ftype (function (&optional stream)
                          code-point-map)
                read-code-point-map)

         (ftype (function (string-map &optional stream)
                          string-map)
                write-string-map)

         (ftype (function (&optional stream)
                          string-map)
                read-string-map))

(defun read-table (&key (stream *standard-input*) table-type)
  (let ((*package* *unicode.table-package*))
    (read-table-start stream)
    (let ((table (ecase (read-table-type stream table-type)
                   (property-table (%read-property-table stream))
                   (property-map (%read-property-map stream))
                   (code-point-map (%read-code-point-map stream))
                   (string-map (%read-string-map stream)))))
      (read-table-end stream)
      table)))

(defun write-property-table (table &optional (stream *standard-output*))
  (let ((*package* *unicode.table-package*))
    (pprint-logical-block (stream nil :prefix "(" :suffix ")")
    (format stream "~S " 'property-table )
    (pprint-indent :current 0 stream)
    (write-filter (property-table-filter table) stream)
    (pprint-newline :mandatory stream)
    (write-from-octets (property-table-from table) stream)
    (pprint-newline :mandatory stream)
    (format stream "~S" (property-table-property table))))
  table)

(defun read-property-table (&optional (stream *standard-input*))
  (let ((*package* *unicode.table-package*))
    (read-table stream 'property-table)))

(defun write-property-map (table &optional (stream *standard-output*))
  (let ((*package* *unicode.table-package*))
    (pprint-logical-block (stream nil :prefix "(" :suffix ")")
      (format stream "~S " 'property-map )
      (pprint-indent :current 0 stream)
      (write-filter (property-map-filter table) stream)
      (pprint-newline :mandatory stream)
      (write-from-octets (property-map-from table) stream)
      (pprint-newline :mandatory stream)
      (write-to-properties (property-map-to table) stream)))
  table)

(defun read-property-map (&optional (stream *standard-input*))
  (let ((*package* *unicode.table-package*))
    (read-table stream 'property-map)))

(defun write-code-point-map (table &optional (stream *standard-output*))
  (let ((*package* *unicode.table-package*))
    (pprint-logical-block (stream nil :prefix "(" :suffix ")")
      (format stream "~S " 'code-point-map )
      (pprint-indent :current 0 stream)
      (write-filter (code-point-map-filter table) stream)
      (pprint-newline :mandatory stream)
      (write-from-octets (code-point-map-from table) stream)
      (pprint-newline :mandatory stream)
      (write-to-octets (code-point-map-to table) stream)))
  table)

(defun read-code-point-map (&optional (stream *standard-input*))
  (let ((*package* *unicode.table-package*))
    (read-table stream 'code-point-map)))

(defun write-string-map (table &optional (stream *standard-output*))
  (let ((*package* *unicode.table-package*))
    (pprint-logical-block (stream nil :prefix "(" :suffix ")")
      (format stream "~S " 'string-map)
      (pprint-indent :current 0 stream)
      (write-filter (string-map-filter table) stream)
      (pprint-newline :mandatory stream)
      (write-from-octets (string-map-from table) stream)
      (pprint-newline :mandatory stream)
      (write-to-strings (string-map-to table) stream)))
  table)

(defun read-string-map (&optional (stream *standard-input*))
  (read-table stream 'string-map))

(defun write-table (table &optional (stream *standard-input*))
  (etypecase table
    (property-table (write-property-table table stream))
    (property-map (write-property-map table stream))
    (code-point-map (write-code-point-map table stream))
    (string-map (write-string-map table stream))))
