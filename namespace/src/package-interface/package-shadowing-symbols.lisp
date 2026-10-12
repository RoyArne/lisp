;;;; This is "namespace/src/package-interface/package-shadowing-symbols.lisp".

(in-package #:namespace)

(defgeneric package-shadowing-symbols (package)

  (:documentation "Syntax:
\(package-shadowing-symbols package\) → symbols

Arguments and Values:
package—a package designator.
symbols—a list of symbols.

Description:
Returns a list of symbols that have been declared as shadowing symbols
in package by shadow or shadowing-import (or the equivalent defpackage
options). All symbols on this list are present in package.

Exceptional Situations:
Signals an error of type type-error if package is not a package
designator.
Signals an error of type package-does-not-exist if package cannot be
found in context.")

  (:method (package)
    (package-shadowing-symbols (resolve-package-designator package *package*)))

  (:method ((package package))
    (copy-seq (shadowing-symbols package))))
