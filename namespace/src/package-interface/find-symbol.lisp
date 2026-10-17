;;;; This is "namespace/src/package-interface/find-symbol.lisp".

(in-package #:namespace)

(defgeneric find-symbol (string &optional package)
  
  (:documentation
   "Syntax:
\(find-symbol string &optional package\) → symbol, status

Arguments and Values:
string—a string.
package—a package designator. The default is the current package.
symbol—a symbol or nil.
status—one of :inherited, :external, :internal, or nil.

Description:
Locates a symbol named string in package.

If a symbol with that name is accessible in package, it is returned as
the first value; the second value is:

  :internal if the symbol is present as an internal symbol.
  :external if the symbol is present as an external symbol.
  :inherited if the symbol is inherited through use-package.

Both values are nil if no such symbol is accessible.")

  (:method ((name string) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (multiple-value-bind (symbol status)
	  (find-present-symbol name package)
	(if (null status)
	    (loop for used-package in (use-list package)
	          do (multiple-value-bind (symbol present?)
		         (find-external-symbol name used-package)
		       (when present?
		         (return-from find-symbol
			   (values symbol :inherited)))))
	    (values symbol status))))))
