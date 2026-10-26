;;;; This is "namespace/src/package-interface/find-all-symbols.lisp".

(in-package #:namespace)

(defgeneric find-all-symbols (name)

  (:documentation
   "Syntax:
\(find-all-symbols name\) → symbols

Arguments and Values:
name—a string designator.
symbols—a list of symbols.

Description:
Returns a list of all symbols that have a name that is the same \(using
string=)\ as name.")

  (:method (name)
    (find-all-symbols (resolve-string-designator name)))
  
  (:method ((name string))
    (loop for package in (visible-list *package*)
          collect (find-internal-symbol name package)
          collect (find-external-symbol name package))))
