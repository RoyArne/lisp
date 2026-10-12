;;;; This is "namespace/src/package-interface/package-use-list.lisp".

(in-package #:namespace)

(defgeneric package-use-list (package)
  (:documentation "Syntax:
\(package-use-list package\) → packages

Arguments and Values:
package—a package designator.
packages—a list of package objects.

Description:
Returns a list of other packages used by package.")

  (:method (package)
    (package-use-list (resolve-package-designator package *package*)))

  (:method ((package package))
    (copy-list (use-list package))))
