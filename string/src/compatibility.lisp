;;;; This is "src/compatibility.lisp".
;;;;
;;;; We define some methods for compatibility with sbcl.

(in-package #:string)

(defmethod string ((object common-lisp:string))
  (make-instance 'string :rope (utf-8:string-to-octets object)))

(defmethod string ((object common-lisp:character))
  (string (common-lisp:string object)))

(defmethod string ((object common-lisp:symbol))
  (string (common-lisp:string object)))
