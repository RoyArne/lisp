;;;; This is "namespace/src/package-interface/shadow.lisp".

(in-package #:namespace)

(defgeneric shadow (symbol-names &optional package)

  (:documentation
   "Syntax:
\(shadow symbol-names &optional package\) → t

Arguments and Values:
symbol-names—a designator for a list of string designators.
package—a package designator. The default is the current package.

Description:
Shadow assures that symbols with names given by symbol-names are
present in the package.

Specifically, package is searched for symbols with the names supplied
by symbol-names. For each such name, if a corresponding symbol is not
present in package \(directly, not by inheritance\), then a
corresponding symbol is created with that name, and inserted into
package as an internal symbol. The corresponding symbol, whether
pre-existing or newly created, is then added, if not already present,
to the shadowing symbols list of package. Returns result.")

  (:method (object &optional (package *package*))
    (declare (type package-designator package))
    (shadow (list object) package))

  (:method ((symbol-names list) &optional (package *package*))
    (declare (type package-designator package))
    (loop with package = (resolve-package-designator package *package*)
          for name in symbol-names
	  do (shadow (resolve-string-designator name) package)
          finally (return t)))

  (:method ((name string) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package)))
      (multiple-value-bind (symbol status)
	  (find-symbol name package)
	(let ((shadowing-symbol (if (or (null status)
					(eql status :inherited))
                                    (make-instance 'symbol :name name :package package)
				    symbol)))
	  (unless (or (eql status :external)
		      (eql status :internal))
	    (add-internal-symbol shadowing-symbol package))
	  (add-shadowing-symbol shadowing-symbol package))))
    t))
