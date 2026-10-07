
(defpackage #:unicode.code-point
  (:use #:common-lisp #:unicode)

  (:export #:code-point
           #:code-point?)
  
  (:export #:range
           #:range-start
           #:range-end
           #:make-range
           #:range-p)

  (:export #:start
           #:end)
  
  (:export #:in-range?
           #:less-than-range?
           #:greater-than-range?
           #:overlapping-ranges?
           #:adjacent-ranges?)
  
  (:export #:in-unicode-range?
           #:+unicode-range-start+ #:+unicode-range-end+)
  
  (:export #:in-surrogate-range?
           #:+surrogate-range-start+ #:+surrogate-range-end+))

(in-package #:unicode.code-point)

;;; Code Point and Range Definitions

(deftype code-point ()
  "A 21-bit integer. 

This definition includes numbers that are invalid code points. Use the
CODE-POINT? function to check if a code point is really a code point."
  `(unsigned-byte 21))

(declaim (type code-point
               +unicode-range-start+ +unicode-range-end+
               +surrogate-range-start+ +surrogate-range-end+))

(defconstant +unicode-range-start+ #x0000)
(defconstant +surrogate-range-start+ #xD800)
(defconstant +surrogate-range-end+ #xDFFF)
(defconstant +unicode-range-end+ #x10FFFF)


(defstruct (range
            (:constructor make-range (start end))
            (:print-object (lambda (range stream)
                             (print-unreadable-object (range stream)
                               (format stream "U+~4,'0X…U+~4,'0X" (range-start range) (range-end range))))))
  (start +unicode-range-start+ :type code-point)
  (end +unicode-range-end+ :type code-point))


(declaim (inline start end)

         (ftype (function ((or code-point range))
                          code-point)
                start end))

(defun start (span)
  (declare (optimize (speed 3) (safety 0)))
  (etypecase span
    (code-point span)
    (range (range-start span))))

(defun end (span)
  (declare (optimize (speed 3) (safety 0)))
  (etypecase span
    (code-point span)
    (range (range-end span))))

(declaim (type range
               *unicode-range* *surrogate-range*))

(defparameter *unicode-range* (make-range +unicode-range-start+ +unicode-range-end+))
(defparameter *surrogate-range* (make-range +surrogate-range-start+ +surrogate-range-end+))


(declaim (inline in-range? less-than-range? greater-than-range? overlapping-ranges? adjacent-ranges?)
         
         (ftype (function ((or code-point range) (or code-point range))
                          boolean)
                in-range? less-than-range? greater-than-range? overlapping-ranges? adjacent-ranges?))

(defun in-range? (span1 span2)
  (declare (optimize (speed 3) (safety 0)))
  (etypecase span1
    (code-point (etypecase span2
                  (code-point (= span1 span2))
                  (range (<= (range-start span2) span1 (range-end span2)))))
    (range (etypecase span2
                  (code-point (= (range-start span1) span2 (range-end span1)))
                  (range (<= (range-start span1) (range-end span2) (range-start span2) (range-end span1)))))))

(defun less-than-range? (span1 span2)
  (declare (optimize (speed 3) (safety 0)))
  (etypecase span1
    (code-point (etypecase span2
                  (code-point (< span1 span2))
                  (range (< span1 (range-start span2)))))
    (range (etypecase span2
                  (code-point (< (range-end span1) span2))
                  (range (< (range-end span1) (range-start span2)))))))

(defun greater-than-range? (span1 span2)
  (declare (optimize (speed 3) (safety 0)))
  (etypecase span1
    (code-point (etypecase span2
                  (code-point (> span1 span2))
                  (range (> span1 (range-end span2)))))
    (range (etypecase span2
                  (code-point (> (range-start span1) span2))
                  (range (> (range-start span1) (range-end span2)))))))

(defun overlapping-ranges? (span1 span2)
  (declare (optimize (speed 3) (safety 0)))
  (etypecase span1
    (code-point (etypecase span2
                  (code-point (= span1 span2))
                  (range (<= (range-start span2) span1 (range-end span2)))))
    (range (etypecase span2
             (code-point (<= (range-start span1) span2 (range-end span1)))
             (range (and (>= (range-end span1) (range-start span2))
                         (<= (range-start span1) (range-end span2))))))))

(defun adjacent-ranges? (span1 span2)
  (declare (optimize (speed 3) (safety 0)))
  (etypecase span1
    (code-point (etypecase span2
                  (code-point (or (= (1+ span1) span2)
                                  (= (1- span1) span2)))
                  (range (or (= (1+ span1) (range-start span2))
                             (= (1- span1) (range-end span2))))))
    (range (etypecase span2
             (code-point (or (= (1+ (range-end span1)) span2)
                             (= (1- (range-start span1)) span2)))
             (range (or (= (1+ (range-end span1)) (range-start span2))
                        (= (1- (range-start span1)) (range-end span2))))))))


(declaim (inline in-surrogate-range? in-unicode-range? code-point?)
         
         (ftype (function ((or code-point range))
                          boolean)
                in-surrogate-range? in-unicode-range?)
         
         (ftype (function (t)
                          boolean)
                code-point?))

(defun in-surrogate-range? (span)
  (declare (optimize (speed 3) (safety 0)))
  (overlapping-ranges? span *surrogate-range*))

(defun in-unicode-range? (span)
  (declare (optimize (speed 3) (safety 0)))
  (and (in-range? span *unicode-range*)
       (not (in-surrogate-range? span))))'

(defun code-point? (object)
  "True if OBJECT is of type code-point and in the range
*UNICODE-RANGE-START* to *UNICODE-RANGE-END*, but outside the range
*SURROGATE-RANGE-START* to *SURROGATE-RANGE-END*."
  (declare (optimize (speed 3) (safety 0)))
  (and (typep object 'code-point)
       (in-unicode-range? object)))
