;;;; This is "namespace/src/package-interface/shadowing-import.lisp".

(in-package #:namespace)

(defgeneric shadowing-import (symbols &optional package)

  (:documentation
   "Syntax:
\(shadowing-import symbols &optional package\) → t

Arguments and Values:
symbols—A designator for a list of symbols.
package—A package designator. The default is the current package.

Description:
shadowing-import is like import, but it does not signal an error even
if the importation of a symbol would shadow some symbol already
accessible in package.

shadowing-import inserts each of symbols into package as an internal
symbol, regardless of whether another symbol of the same name is
shadowed by this action. If a different symbol of the same name is
already present in package, that symbol is first uninterned from
package. The new symbol is added to package's shadowing-symbols list.

shadowing-import does name-conflict checking to the extent that it
checks whether a distinct existing symbol with the same name is
accessible; if so, it is shadowed by the new symbol, which implies
that it must be uninterned if it was present in package.")

  (:method (object &optional (package *package*))
    (declare (type package-designator package))
    (shadowing-import (list object) package))
  
  (:method ((symbols list) &optional (package *package*))
    (declare (type package-designator package))
    (loop with package = (resolve-package-designator package *package*)
	  for new-symbol in symbols
          if (typep new-symbol 'symbol)
	  do (shadowing-import new-symbol package)
          else
          do (error 'type-error
                    :datum new-symbol
                    :expected-type 'symbol
                    :datum "during shadowing-import")
          finally (return t)))

  (:method ((new-symbol symbol) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (multiple-value-bind (conflicting-symbol status)
	  (find-symbol (name new-symbol) package)
	(unless (eql conflicting-symbol new-symbol)
	  (if (null status)
	      (setf status :internal)
	      (unintern conflicting-symbol package))
	  (case status
	    ((:internal :inherited) (add-internal-symbol new-symbol package))
	    (:external (add-external-symbol new-symbol package)))))
      (add-shadowing-symbol new-symbol package))
    t))
