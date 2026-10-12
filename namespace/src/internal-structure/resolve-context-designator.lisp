;;;; This is "namespace/src/internal-structure/resolve-context-designator.lisp".

(in-package #:namespace)

(defgeneric resolve-context-designator (object)

  (:documentation "Syntax:
\(resolve-context-designator object\) → designator

Arguments and Values:
object—a context designator.
designator—a context designator.

Description:
Returns a context designator.

If object is nil, then nil is returned.

If object is a package object, then that package object is returned.

Exceptional Situations:
Signals an error of type type-error if object is not a context
designator.")

  (:method (object)
    (error 'type-error
	   :datum object
	   :expected-type 'context-designator
	   :context "and cannot be coerced into a context designator."))
  
  (:method ((object null))
    object)
  
  (:method ((object package))
    object))
