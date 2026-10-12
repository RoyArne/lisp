;;;; This is "namespace/src/package-interface/package-name.lisp".

(in-package #:namespace)

(defgeneric package-name (package)
  (:documentation "Syntax:
\(package-name package\) → name

Arguments and Values:
package—a package designator.
name—a string, or nil.

Description:
Returns the string that names package. Returns nil if package has been
deleted.")

  (:method (package)
    (package-name (resolve-package-designator package *package*)))

  (:method ((package package))
    (name package)))
