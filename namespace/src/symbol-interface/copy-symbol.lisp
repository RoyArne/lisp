;;;; This is "namespace/src/interface/copy-symbol.lisp".

(in-package #:namespace)

(defgeneric copy-symbol (symbol &optional copy-properties?)

  (:documentation
   "Syntax:
\(copy-symbol symbol &optional copy-properties?\) → new-symbol

Arguments and Values:
symbol, new-symbol—a symbol.
copy-properties?—a generalized boolean.

Description:
Creates and returns a fresh, uninterned symbol whose name is the same name as
that of symbol. The new-symbol is neither bound nor fbound and has a null
property list.

Exceptional Situations:
The copy properties functionality is not implemented yet, and copy-symbol
signals an error if copy-symbol? is true.")
  
  (:method ((s symbol) &optional copy-properties?)
    (declare (type boolean copy-properties?))
    (if copy-properties?
        (error "Cannot copy the properties of~%  ~S~%~
                because that functionality is not implemented yet."
               s)
        (make-instance 'symbol :name (slot-value s 'name)))))
