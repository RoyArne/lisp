;;;; This is "namespace/src/package-interface/package-internal-to-list.lisp".

(in-package #:namespace)

(defgeneric package-internal-to-list (package)

  (:documentation
   "Syntax:
\(package-internal-to-list package\) → packages

Arguments and Values:
package—a package designator.
packages—a list of package objects.

Description:
Returns a list of packages that are superior to package in the system
hierarchy. The returned packages are listed in order from packages
home package up to a top-level package.")

  (:method (package)
    (package-internal-to-list (resolve-package-designator package *package*)))

  (:method ((package package))
    (copy-list (internal-to-list package))))
