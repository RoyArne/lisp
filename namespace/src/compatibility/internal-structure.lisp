;;;; This is "namespace/src/compatibility/internal-structure.lisp".

(in-package #:namespace)

(defmethod resolve-string-designator ((designator common-lisp:string))
  (string designator))

(defmethod resolve-string-designator ((designator common-lisp:symbol))
  (string designator))
