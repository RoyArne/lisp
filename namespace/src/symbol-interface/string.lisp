;;;; This is "namespace/src/symbol-interface/string.lisp".
;;;;
;;;; We extend the string function (in the "string" system) with a method for
;;;; symbols.

(in-package #:namespace)

(defmethod string ((object symbol))
  (name object))
