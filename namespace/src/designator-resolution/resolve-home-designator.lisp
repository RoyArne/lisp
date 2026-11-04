;;;; This is "namespace/src/internal-structure/resolve-home-designator.lisp".

(in-package #:namespace)

(defgeneric resolve-home-designator (designator &optional location)
  (:documentation "Syntax:
\(resolve-home-designator designator &optional location\) → home

Arguments and Values:
designator—a home designator.
location—a location designator.
home—a package object, or nil.

Description:
If designator is nil then nil is returned regardless of location.

If designator is a package object then that package is returned
regardless of location.

If designator is a string designator then package and location is
passed to resolve-string-designator, and a matching package object is
returned.

Exceptional Situations:
Signals an error of type type-error if designator is not a
home-designator.
Signals an error of type package-does-not-exist if package is a string
designator that cannot be found at the given location.")

  (:method (object &optional (location *package*))
    (declare (type location-designator location))
    (handler-case
	(resolve-package-designator object location)
      (type-error () (error 'type-error
			    :datum object
			    :expected-type 'home-designator
			    :context "and cannot be coerced into a package object."))))
  
  (:method ((object null) &optional (location *package*))
    (declare (type location-designator location)
             (ignore location))
    object))
