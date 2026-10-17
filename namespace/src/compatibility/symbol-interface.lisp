;;;; This is "namespace/src/compatibility/symbol-interface.lisp".

(in-package #:namespace)

(defmethod copy-symbol ((symbol common-lisp:symbol) &optional copy-properties?)
  (declare (type boolean copy-properties?))
  (if copy-properties?
      (error "Cannot copy the properties of~%  ~S~%~
              because that functionality is not implemented yet."
             symbol)
      (make-instance 'symbol :name (string (common-lisp:symbol-name symbol)))))

(defmethod make-symbol ((name common-lisp:string))
  (make-symbol (string name)))

;; We extend the STRING function from the "STRING" system with a method
;; specialized on our own symbols.

(defmethod string ((object symbol))
  (name object))

(defmethod symbol-name ((symbol common-lisp:symbol))
  (string (common-lisp:symbol-name symbol)))

(defmethod symbol-package ((symbol common-lisp:symbol))
  (let ((name (common-lisp:symbol-package symbol)))
    ;; FIXME: Eventually we will need our own NIL.
    (if (null name)
        name
        (string name))))

(defmethod symbol? ((object common-lisp:symbol))
  t)
