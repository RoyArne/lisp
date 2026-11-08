
(in-package #:unicode.utf-8)

(declaim (inline make-octets make-adjustable-octets)
         
         (ftype (function ((or vector:size list vector))
                          octets)
                make-octets)
         
         (ftype (function (vector:size)
                          octets)
                make-adjustable-octets))

(defun make-octets (octets)
  "Return an octet vector depending on OCTETS:

  If OCTETS is an integer then an octet vector of that length \(initialized to
  all zeroes\) is returned.

  If OCTETS is a vector or a list then it is coerced into an octet vector
  which is returned."
  (etypecase octets
    (vector:size (make-array octets :element-type 'octet :initial-element 0))
    (list (coerce octets 'octets))
    (vector (coerce octets 'octets))))

(defun make-adjustable-octets (length)
  "Return an adjustable octet vector of the given LENGTH \(initialized to all
zeroes\). Its fill pointer is set to zero."
  (make-array length :element-type 'octet :initial-element 0 :adjustable t :fill-pointer 0))


(declaim (type octets *empty*))

(defparameter *empty* (make-octets 0)
  "A zero length vector of octets. This is intended as THE value for places
that need a zero length octets vector.")


(declaim (ftype (function (octets vector:index)
                          vector:index)
                next previous))

(defun next (vector start)
  "Return the index of the next code point following start, i.e. at start + 1 or greater."
  (cond
    ((continuation? (octet1 vector start))
     (loop for i from (1+ start) below (length vector)
           while (continuation? (octet1 vector i))
           finally (return i)))
    (t
     (+ start (encoding-length vector start)))))

(defun previous (vector start)
  "Return the index of the first code point preceding start, i.e. at start - 1 or less."
  (loop for i from (1- start) downto 0
        while (continuation? (octet1 vector i))
        finally (return i)))

(declaim (ftype (function (octets vector:index octets vector:index)
                          encoding-length)
                copy-code-point))

(defun copy-code-point (from from-start to to-start)
  "Copy the code point encoded at from-start in from to to-start in to. Returns
the number of octets copied."
  (loop with encoding-length = (encoding-length from from-start)
        for i from 0 below encoding-length
        do (setf (aref to (+ to-start i)) (aref from (+ from-start i)))
        finally (return encoding-length)))
