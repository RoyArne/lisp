;;;; This is "namespace/src/package-interface/make-package.lisp".

(in-package #:namespace)

(defgeneric package-package (package)
  (:documentation "Syntax:
\(package-package package\) → home

Arguments and Values:
package—a package designator.
home—a home designator.

Description:
Returns the home package of package, or nil if package is a top-level
package.")

  (:method (package)
    (package-package (resolve-package-designator package *package*)))

  (:method ((package package))
    (home-package package)))
