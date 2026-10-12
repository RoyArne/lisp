;;;; This is "namespace/src/package-interface/package-use-list.lisp".

(in-package #:namespace)

(defgeneric package-used-by-list (package)
  (:documentation "Syntax:
\(package-used-by-list package\) → packages

Arguments and Values:
package—a package designator.
packages—a list of package objects.

Description:
Returns a list of packages that uses package.")

  (:method (package)
    (package-used-by-list (resolve-package-designator package *package*)))
  
  (:method ((package package))
    (copy-list (used-by-list package))))
