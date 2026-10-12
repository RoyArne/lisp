;;;; This is "namespace/src/package-interface/list-peer-packages.lisp".

(in-package #:namespace)

(defgeneric list-peer-packages ()
  (:documentation "Syntax:
\(list-peer-packages\) → packages

Arguments and Values:
packages—a list of package objects.

Description:
Returns a list of packages with the same home package the current
package, or the list of top-level packages if the current package is a
top-level package.")
 
  (:method ()
    (copy-list (peer-list *package*))))
