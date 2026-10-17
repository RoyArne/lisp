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
    (apply #'append
           (loop for package in (visible-list *package*)
                 collect (loop for symbol being each hash-value of (external-symbols package)
                               when (string:string= name (name symbol))
                               collect symbol)
                 collect (loop for symbol being each hash-value of (internal-symbols package)
                               when (string:string= name (name symbol))
                               collect symbol)))))
