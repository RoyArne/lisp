;;;; This is "namespace/src/package-interface/make-package.lisp".

(in-package #:namespace)
  
(defgeneric list-all-packages ()
  (:documentation "Syntax:
\(list-all-packages\) → packages

Arguments and Values:
packages—a list of package objects.

Description:
list-all-packages returns a list of all packages that are visible from
the current package.")

  (:method ()
    (copy-list (visible-list *package*)))) 
