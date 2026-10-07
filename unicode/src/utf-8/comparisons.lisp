
(in-package #:unicode.utf-8)

;;; Comparing Octet Vectors
;;;
;;; We define octets=, octets/=, octets<, octets>, octets<=, and octets>=. They
;;; are all build around the compare function, and equivalent to string=,
;;; string/=, and so on.
;;;
;;; Comparing Code Point Encodings
;;;
;;; We define code-point=, code-point/=, code-point<, code-point>,
;;; code-point<=, and code-point>=. They are equivalent to char=, char/=, and
;;; so on.

(declaim (ftype (function (octets vector:index vector:index octets vector:index vector:index)
                          (values integer vector:index))
                compare)
         
         (ftype (function (octets octets &key (:start1 vector:index) (:end1 vector:end-index)
                                              (:start2 vector:index) (:end2 vector:end-index))
                          boolean)
                octets=)
         
         (ftype (function (octets octets &key (:start1 vector:index) (:end1 vector:end-index)
                                              (:start2 vector:index) (:end2 vector:end-index))
                          (or null vector:index))
                octets/= octets< octets> octets<= octets>=))

(defun compare (vector1 start1 end1 vector2 start2 end2)
  "Return two values, the integer result of the comparison and a mismatch
offset.

The result is a negative number if vector1 is less than vector2, a positive
number if it is greater, and zero if they are equal.

The mismatch offset is the number of equal octets."
  (let ((i1 start1)
        (i2 start2))
    (loop while (and (< i1 end1) (< i2 end2))
          for v1 = (aref vector1 i1)
          for v2 = (aref vector2 i2)
          do (cond
               ((/= v1 v2)
                (return (values (- v1 v2) (- i1 start1))))
               (t (incf i1)
                  (incf i2)))
          finally
             (cond ((< i1 end1)
                    ;; vector2 ended first, so vector1 is longer (greater)
                    (return (values 1 (- i1 start1))))
                   ((< i2 end2)
                    ;; vector1 ended first, so vector1 is shorter (less)
                    (return (values -1 (- i1 start1))))
                   (t
                    ;; both ended at the same time and matched entirely
                    (return (values 0 (- i1 start1))))))))

(defun octets= (vector1 vector2 &key (start1 0) end1 (start2 0) end2)
  "Return true if VECTOR1 and VECTOR2 are of the same length and contain the same
octets \(compared by =\)."
  (let ((end1 (vector:end vector1 end1))
        (end2 (vector:end vector2 end2)))
    (when (= (- end1 start1) (- end2 start2))
      (zerop (compare vector1 start1 end1 vector2 start2 end2)))))
      
(defun octets/= (vector1 vector2 &key (start1 0) end1 (start2 0) end2)
  "Return the offset from START1 and START2 to the first octet that differs from
VECTOR1 to VECTOR2. Return NIL if there is no such octet."
  (let ((end1 (vector:end vector1 end1))
        (end2 (vector:end vector2 end2)))
    (multiple-value-bind (difference mismatch)
        (compare vector1 start1 end1 vector2 start2 end2)
      (unless (and (zerop difference)
                   (= (- end1 start1) (- end2 start2)))
        mismatch))))

(defun octets< (vector1 vector2 &key (start1 0) end1 (start2 0) end2)
  "Return the offset from START1 and START2 to the first octet in VECTOR1 that is
less than the corresponding octet in VECTOR2. Return NIL if there is no such
octet."
  (let ((end1 (vector:end vector1 end1))
        (end2 (vector:end vector2 end2)))
    (multiple-value-bind (difference mismatch)
        (compare vector1 start1 end1 vector2 start2 end2)
      (when (or (minusp difference)
                (and (zerop difference)
                     (< (- end1 start1) (- end2 start2))))
        mismatch))))

(defun octets> (vector1 vector2 &key (start1 0) end1 (start2 0) end2)
  "Return the offset from START1 and START2 to the first octet in VECTOR1 that is
greater than the corresponding octet in VECTOR2. Return NIL if there is no
such octet."
  (let ((end1 (vector:end vector1 end1))
        (end2 (vector:end vector2 end2)))
    (multiple-value-bind (difference mismatch)
        (compare vector1 start1 end1 vector2 start2 end2)
      (when (or (plusp difference)
                (and (zerop difference)
                     (> (- end1 start1) (- end2 start2))))
        mismatch))))

(defun octets<= (vector1 vector2 &key (start1 0) end1 (start2 0) end2)
  (let ((end1 (vector:end vector1 end1))
        (end2 (vector:end vector2 end2)))
    (multiple-value-bind (difference mismatch)
        (compare vector1 start1 end1 vector2 start2 end2)
      (when (and (not (plusp difference))
                 (<= (- end1 start1) (- end2 start2)))
        mismatch))))

(defun octets>= (vector1 vector2 &key (start1 0) end1 (start2 0) end2)
  (let ((end1 (vector:end vector1 end1))
        (end2 (vector:end vector2 end2)))
    (multiple-value-bind (difference mismatch)
        (compare vector1 start1 end1 vector2 start2 end2)
      (when (and (not (minusp difference))
                 (>= (- end1 start1) (- end2 start2)))
        mismatch))))


;;; Comparing Code Points
;;;

(declaim (ftype (function (octets vector:index octets vector:index)
                          boolean)
                code-point= code-point/= code-point< code-point> code-point<= code-point>=))

(defmacro octetn (n vector start)
  `(aref ,vector (+ ,n ,start)))

(defmacro octet1= (vector1 start1 vector2 start2)
  `(= (octet1 ,vector1 ,start1) (octet1 ,vector2 ,start2)))

(defmacro octetn= (n vector1 start1 vector2 start2)
  `(= (octetn ,n ,vector1 ,start1) (octetn ,n ,vector2 ,start2)))

(defun code-point= (vector1 start1 vector2 start2)
  "True if the code point encoded at START1 in VECTOR1 is the
same as the one at START2 in VECTOR2; otherwise, false."
  (when (octet1= vector1 start1 vector2 start2)
    (let ((length (encoding-length vector1 start1)))
      (and (= length (encoding-length vector2 start2))
           (case length
             (1 t)
             (2 (octetn= 1 vector1 start1 vector2 start2))
             (3 (and (octetn= 1 vector1 start1 vector2 start2)
                     (octetn= 2 vector1 start1 vector2 start2)))
             (4 (and (octetn= 1 vector1 start1 vector2 start2)
                     (octetn= 2 vector1 start1 vector2 start2)
                     (octetn= 3 vector1 start1 vector2 start2))))))))


(defmacro octet1/= (vector1 start1 vector2 start2)
  `(/= (octet1 ,vector1 ,start1) (octet1 ,vector2 ,start2)))

(defmacro octetn/= (n vector1 start1 vector2 start2)
  `(/= (octetn ,n ,vector1 ,start1) (octetn ,n ,vector2 ,start2)))

(defun code-point/= (vector1 start1 vector2 start2)
  "True if the code point encoded at START1 in VECTOR1 is
different from the one at START2 in VECTOR2; otherwise, false."
  (or (octet1/= vector1 start1 vector2 start2)
      (let ((length1 (encoding-length vector1 start1))
            (length2 (encoding-length vector2 start2)))
        (or (/= length1 length2)
            (case length1
              (1 nil)
              (2 (octetn/= 1 vector1 start1 vector2 start2))
              (3 (or (octetn/= 1 vector1 start1 vector2 start2)
                     (octetn/= 2 vector1 start1 vector2 start2)))
              (4 (or (octetn/= 1 vector1 start1 vector2 start2)
                     (octetn/= 2 vector1 start1 vector2 start2)
                     (octetn/= 3 vector1 start1 vector2 start2))))))))


(defmacro octet1< (vector1 start1 vector2 start2)
  `(< (octet1 ,vector1 ,start1) (octet1 ,vector2 ,start2)))

(defmacro octetn< (n vector1 start1 vector2 start2)
  `(< (octetn ,n ,vector1 ,start1) (octetn ,n ,vector2 ,start2)))

(defun code-point< (vector1 start1 vector2 start2)
  "True if the code point encoded at START1 in VECTOR1 is less
than the one at START2 in VECTOR2; otherwise, false."
  (or (octet1< vector1 start1 vector2 start2)
      (let ((length1 (encoding-length vector1 start1))
            (length2 (encoding-length vector2 start2)))
        (or (< length1 length2)
            (and (octet1= vector1 start1 vector2 start2)
                 (= length1 length2)
                 (loop for i from 1 below length1
                       when (octetn< i vector1 start1 vector2 start2) do (return t)
                       unless (octetn= i  vector1 start1 vector2 start2) do (return nil)))))))


(defmacro octet1> (vector1 start1 vector2 start2)
  `(> (octet1 ,vector1 ,start1) (octet1 ,vector2 ,start2)))

(defmacro octetn> (n vector1 start1 vector2 start2)
  `(> (octetn ,n ,vector1 ,start1) (octetn ,n ,vector2 ,start2)))

(defun code-point> (vector1 start1 vector2 start2)
  "True if the code point encoded at START1 in VECTOR1 is greater
than the one at START2 in VECTOR2; otherwise, false."
  (or (octet1> vector1 start1 vector2 start2)
      (let ((length1 (encoding-length vector1 start1))
            (length2 (encoding-length vector2 start2)))
        (or (> length1 length2)
            (and (octet1= vector1 start1 vector2 start2)
                 (= length1 length2)
                 (loop for i from 1 below length1
                       when (octetn> i vector1 start1 vector2 start2) do (return t)
                       unless (octetn= i  vector1 start1 vector2 start2) do (return nil)))))))


(defun code-point<= (vector1 start1 vector2 start2)
  "True if the code point encoded at START1 in VECTOR1 is less
than or equal to the one at START2 in VECTOR2; otherwise, false."
  (or (octet1< vector1 start1 vector2 start2)
      (let ((length1 (encoding-length vector1 start1))
            (length2 (encoding-length vector2 start2)))
        (or (< length1 length2)
            (and (= length1 length2)
                 (loop for i from 1 below length1
                       when (octetn< i vector1 start1 vector2 start2) do (return t)
                       unless (octetn= i vector1 start1 vector2 start2) do (return nil)
                       finally (return (octetn= (1- length1) vector1 start1 vector2 start2))))))))


(defun code-point>= (vector1 start1 vector2 start2)
  "True if the code point encoded at START1 in VECTOR1 is greater
than or equal to the one at START2 in VECTOR2; otherwise, false."
  (or (octet1> vector1 start1 vector2 start2)
      (let ((length1 (encoding-length vector1 start1))
            (length2 (encoding-length vector2 start2)))
        (or (> length1 length2)
            (and (= length1 length2)
                 (loop for i from 1 below length1
                       when (octetn> i vector1 start1 vector2 start2) do (return t)
                       unless (octetn= i vector1 start1 vector2 start2) do (return nil)
                       finally (return (octetn= (1- length1) vector1 start1 vector2 start2))))))))
