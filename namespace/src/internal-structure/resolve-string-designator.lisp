;;;; This is "namespace/src/internal-structure/resolve-string-designator.lisp".

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

  ;; NOTE: At the time RESOLVE-STRING-DESIGNATOR is loaded, symbol specific
  ;;       methods are not defined.
  ;;
  ;;       This means that we cannot call (string symbol) or (symbol-name
  ;;       symbol) to convert symbol into a string. Instead, we call its slot
  ;;       accessor NAME.
  (:method ((designator string))
    designator)
  
  (:method ((designator symbol))
    (name designator))

  ;; Compatibility functions, depending on the string function having
  ;; compatibility definitions for common lisp strings and symbols.
  (:method ((designator common-lisp:string))
    (string designator))
  
  (:method ((designator common-lisp:symbol))
    (string designator)))
