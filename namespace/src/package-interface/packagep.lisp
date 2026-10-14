;;;; This is "namespace/src/package-interface/packagep.lisp".

(in-package #:namespace)

(defgeneric package? (object)
  (:documentation
   "Syntax:
\(package? object\) → generalized boolean

Arguments and Values:
object—an object.
generalized boolean—t, or nil.

Description:
Returns t if object is a package object; otherwise, returns nil.")

  (:method (object)
    nil)

  (:method ((object package))
    t))
