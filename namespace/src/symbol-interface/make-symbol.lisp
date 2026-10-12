;;;; This is "namespace/src/interface/make-symbol.lisp".

(in-package #:namespace)

(defgeneric make-symbol (name)

  (:documentation
   "Syntax:
\(make-symbol name) → new-symbol

Arguments and Values:
name—a string.
new-symbol—a fresh, uninterned symbol.

Description:
Creates and returns a fresh, uninterned symbol whose name is the given
name. The new-symbol is neither bound nor fbound and has a null property list.")
  
  (:method ((name string))
    (make-instance 'symbol :name name)))
