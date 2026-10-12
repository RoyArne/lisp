;;;; This is "namespace/src/package-interface/package-internal-list.lisp".

(in-package #:namespace)

(defgeneric package-internal-list (package)

  (:documentation "Syntax:
\(package-internal-list package\) → packages

Arguments and Values:
package—a package designator.
packages—a list of package objects.

Description:
Returns a list of packages that has package as their home package.")

  (:method (package)
    (package-internal-list (resolve-package-designator package *package*)))

  (:method ((package package))
    (copy-list (internal-list package))))
