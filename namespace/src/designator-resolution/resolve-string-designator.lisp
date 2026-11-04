;;;; This is "namespace/src/designator-resolution/resolve-string-designator.lisp".

(in-package #:namespace)

(defgeneric resolve-string-designator (object)
  (:documentation "Syntax:
\(resolve-string-designator object\) → name

Arguments and Values:
object—a string designator.
name—a string.

Description:
Returns a string.

If object is a symbol, then the string that is its name is returned.

If object is a string, then that string itself is returned.

Exceptional Situations:
Signals an error of type type-error if object is not a string
designator.")
  (:method (object)
    (error 'type-error
	   :datum object
	   :expected-type 'string-designator
	   :context "and cannot be coerced into a package name."))
  (:method ((designator string))
    designator)
  (:method ((designator symbol))
    (name designator)))
