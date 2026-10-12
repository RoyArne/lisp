;;;; This is "namespace/src/interface/symbol?.lisp".

(in-package #:namespace)

(defgeneric symbol? (object)

  (:documentation
   "Syntax:
\(symbol? object\) → generalized-boolean.

Arguments and Values:
object—an object.
generalized-boolean—a generalized boolean.

Description:
Returns true if object is of type symbol; otherwise, returns false.")

  (:method (object)
    nil)
  
  (:method ((object symbol))
    t))
