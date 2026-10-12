;;;; This is "namespace/src/internal-structure/resolve-package-designator.lisp".

(in-package #:namespace)

(defgeneric resolve-package-designator (designator &optional context)
  
  (:documentation "Syntax:
\(resolve-package-designator designator &optional context\) → package

Arguments and Values:
designator—a package designator.
context—a package object. Defaults to the current package.
package—a package object.

Description:
If designator is a package object then that package is returned
regardless of context.

If designator is a string designator then package and context is
passed to resolve-string-designator, and a matching package object is
returned.

Exceptional Situations:
Signals an error of type type-error if designator is not a
package-designator.
Signals an error of type package-does-not-exist if package is a string
designator that cannot be found in the given context.")

  (:method (object &optional (context *package*))
    (declare (type package context))
    (let ((name (handler-case
		    (resolve-string-designator object)
		  (type-error () (error 'type-error
					:datum object
					:expected-type 'package-designator
					:context "and cannot be coerced into a package object.")))))
      ;;(find-visible-package/error-if-not-found name context)))
      (or (find-visible-package name context)
	  (error 'package-does-not-exist :package name :context context))))

  ;; This method is here because common-lisp:symbol (in addition to symbol) is
  ;; allowed as a string designator. We don't want NIL to pass as a package
  ;; designator though.
  ;;
  ;; FIXME: We do not have our own null defined yet, so a symbol named nil
  ;; will pass as a string designator.
  (:method ((package common-lisp:null) &optional (context *package*))
    (declare (ignore context))
    (error 'type-error
	   :datum package
	   :expected-type 'package-designator
	   :context "and cannot be coerced into a package object."))
  
  (:method ((package package) &optional (context *package*))
    (declare (ignore context))
    package))
	       
