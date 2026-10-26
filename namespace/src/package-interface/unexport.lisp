;;;; This is "namespace/src/package-interface/unexport.lisp".

(in-package #:namespace)

(defgeneric unexport (symbols &optional package)
  (:documentation "Syntax:
\(unexport symbols &optional package\) → t

Arguments and Values:
symbols—a designator for a list of symbols.
package—a package designator. The default is the current package.

Description:
Unexport undoes the effect of export by reverting external symbols to
internal. It has no effect on symbols who are already internal to
package.

Exceptional Situations:

symbol-is-not-accessible

  A correctable error of type package-error.

  Signaled if a symbol being unexported is not accessible in package and
  offers an option to 'import' the symbol.")

  (:method (symbols &optional (package *package*))
    (declare (type package-designator package))
    (unexport (list symbols) package))

  (:method ((symbols list) &optional (package *package*))
    (declare (type package-designator package))
    (loop with package = (resolve-package-designator package *package*)
	  for symbol in symbols
          if (typep symbol 'symbol)
	  do (unexport symbol package)
          else
          do (error 'type-error
                    :datum symbol
                    :expected-type 'symbol
                    :datum "during unexport")
          finally (return t)))
  
  (:method ((symbol symbol) &optional (package *package*))
    (declare (type package-designator package))
    (let* ((package (resolve-package-designator package *package*))
	   (status (nth-value 1 (find-symbol (symbol-name symbol) package))))
      ;; Error if not accessible. Correctable by importing.
      (when (null status)
	(restart-case
	    (error 'symbol-is-not-accessible
		   :package package
		   :context *package*
		   :symbol symbol)
	  (import ()
	    :report (lambda (stream)
		      (format stream "Import ~S." symbol))
	    :test (lambda (condition)
		    (typep condition 'symbol-is-not-accessible))
	    (import symbol package)
	    (setf status :internal))))
      (when (eql status :external)
	(remove-external-symbol symbol package)
	(add-internal-symbol symbol package))
      t)))


