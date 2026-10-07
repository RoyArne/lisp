
(defpackage #:system.sequence.vector
  (:use #:common-lisp)

  (:export #:index
           #:end-index
           #:size
           #:end
           #:empty?))

(in-package #:system.sequence.vector)

(deftype index ()
  "An index into a vector."
  `fixnum)

(deftype end-index ()
  "An index into a vector, or NIL \(indicating the end of the vector\)."
  `(or null index))

(deftype size ()
  "The length of a vector."
  `(integer 0 #.array-dimension-limit))


(declaim (inline end empty?)
         
         (ftype (function (vector end-index)
                          index)
                end)

         (ftype (function (vector)
                          boolean)
                empty?))

(defun end (vector index)
  "Return INDEX, or the length of VECTOR if INDEX is NIL."
  (declare (optimize (speed 3) (safety 0)))
  (or index (length vector)))

(defun empty? (vector)
  "True if the length of VECTOR is zero."
  (declare (optimize (speed 3) (safety 0)))
  (zerop (length vector)))
