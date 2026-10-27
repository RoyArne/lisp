;;;; This is "namespace/src/package-interface/import.lisp".

(in-package #:namespace)

(defgeneric import (symbols &optional package)

  (:documentation
   "Syntax:
\(import symbols &optional package\) → t

Arguments and Values:
symbols—a designator for a list of symbols.
package—a package designator. The default is the current package.
symbol—a symbol.

Descritpion:
Import adds symbol or symbols to the internals of package, checking
for name conflicts with existing symbols either present in package or
accessible to it.

Once the symbols have been imported, they may be referenced in the
importing package without the use of a package prefix when using the
Lisp reader.

A name conflict in import between the symbol being imported and a
symbol inherited from some other package can be resolved in favor of
the symbol being imported by making it a shadowing symbol, or in favor
of the symbol already accessible by not doing the import.

A name conflict in import with a symbol already present in the package
may be resolved by uninterning that symbol, or by not doing the
import.

The imported symbol is not automatically exported from the current
package, but if it is already present and external, then the fact that
it is external is not changed.

If any symbol to be imported has no home package \(i.e.,
\(symbol-package symbol\) → nil\), import sets the home package of the
symbol to package.

If the symbol is already present in the importing package, import has
no effect.

Side Effects:
The package system is modified.

Exceptional Situations:

conflicting-symbol-names

  A correctable error of type package-error.

  Signaled if any of the symbols being imported has the same name \(by
  string=\) as another symbol already accessible in package, even if the
  symbol is a shadowing symbol in package.

  A 'shadow' option resolves the conflict by making the symbol being imported
  a shadowing symbol.

  An 'unintern' option resolves the conflict by uninterning the symbol already
  present in package.

  An 'abort' option resolves the conflict by not importing the symbol.

Import signals a correctable error of type package-error if any of the
symbols to be imported has the same name \(under string=\) as some
distinct symbol \(under eql\) already accessible in the package, even if
the conflict is with a shadowing symbol of the package.")

  (:method ((symbols list) &optional (package *package*))
    (declare (type package-designator package))
    (loop with package = (resolve-package-designator package *package*)
	  for new-symbol in symbols
          if (typep new-symbol 'symbol)
	  do (import new-symbol package)
          else
          do (error 'type-error
                    :datum new-symbol
                    :expected-type 'symbol
                    :datum "during import")
          finally (return t)))

  (:method ((new-symbol symbol) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (multiple-value-bind (conflicting-symbol status)
	  (find-symbol (symbol-name new-symbol) package)
	(cond
	  
	  ;; New symbols are added to the internal list.
	  ((null status)
	   (add-internal-symbol new-symbol package)
           (unless (package new-symbol)
	     (setf (package new-symbol) package)))
	  
	  ;; Old symbols are added to the internal list if they are
	  ;; :inherited.
	  ((eql new-symbol conflicting-symbol)
	   (when (eql status :inherited)
	     (add-internal-symbol new-symbol package)))
	  
	  ;; A conflict with an :inherited symbol.
	  ((eql status :inherited)
	   (restart-case
	       (error 'conflicting-symbol-names
		      :package package
		      :context *package*
		      :symbol new-symbol
		      :conflicting-symbol conflicting-symbol)
	     (abort ()
	       :report (lambda (stream)
			 (format stream "Do not import ~S." new-symbol))
	       :test (lambda (condition)
		       (typep condition 'conflicting-symbol-names))
	       t)
	     (shadow ()
	       :report (lambda (stream)
			 (format stream "Import ~S as a shadowing symbol." new-symbol))
	       :test (lambda (condition)
		       (typep condition 'conflicting-symbol-names))
	       (shadowing-import new-symbol package))))
	  
	  ;; A conflict with an :internal or :external symbol.
	  ((or (eql status :internal) (eql status :external))
	   (restart-case 
	       (error 'conflicting-symbol-names
		      :package package
		      :context *package*
		      :symbol new-symbol
		      :conflicting-symbol conflicting-symbol)
	     ;; If the conflicting symbol is :internal or
	     ;; :external we can unintern the conflicting symbol
	     ;; and import the new one, or not do the import.
	     (abort ()
	       :report (lambda (stream)
			 (format stream "Do not import ~S." new-symbol))
	       :test (lambda (condition)
		       (typep condition 'conflicting-symbol-names))
	       t)
	     (unintern ()
	       :report (lambda (stream)
			 (format stream "Import ~S after uninterning ~S."
				 new-symbol conflicting-symbol))
	       :test (lambda (condition)
		       (typep condition 'conflicting-symbol-names))
	       (unintern conflicting-symbol package)
	       (add-internal-symbol new-symbol package)
               (unless (package new-symbol)
                 (setf (package new-symbol) package)))))
	  
	  ;; Unexpected.
	  (t
	   (error "Internal error while importing the symbol ~S into ~S.~@
                   The conflicting symbol is ~S, and its status is ~S."
		  new-symbol package conflicting-symbol status)))))
    t))
		   
