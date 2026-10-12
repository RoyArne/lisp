;;;; This is "namespace/src/interface/symbol-name.lisp".

(in-package #:namespace)

(defgeneric symbol-name (symbol)

  (:documentation
   "Syntax:
\(symbol-name symbol\) → name

Arguments and Values:
symbol—a symbol object.
name—a string.

Description:
Returns the name of symbol.")
  
  (:method ((s symbol))
    (slot-value s 'name)))

