;;;; This is "namespace/src/interface/symbol-package.lisp".

(in-package #:namespace)

(defgeneric symbol-package (symbol)
  (:documentation
   "Syntax:
\(symbol-package symbol\) → location-designator

Arguments and Values:
symbol—a symbol object.
location-designator—a package object, or nil.

Description:
Returns the home package of symbol, or nil if symbol is not interned in any
package.")
  (:method ((symbol symbol))
    (package symbol)))
