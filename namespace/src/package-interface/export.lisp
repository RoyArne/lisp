;;;; This is "namespace/src/package-interface/export.lisp".

(in-package #:namespace)

(defgeneric export (symbols &optional package)
  (:documentation
   "Syntax:
\(export symbols &optional package\) → t

Arguments and Values:
symbols—a designator for a list of symbols.
package—a package designator. The default is the current package.

Description:
Export makes one or more symbols be external symbols of package.

Each symbol must be accessible in package. Any inherited symbols are
imported first, and all packages that use package are checked for name
conflicts.

Exceptional Situations:

symbol-is-not-accessible

  A correctable error of type package-error.

  Signaled if a symbol being exported is not accessible in package and
  offers an option to 'import' the symbol.

conflicting-symbol-names

  A correctable error of type package-error.

  Signaled if there are any name conflicts. The 'unintern' option
  resolves the conflict in favor of the symbol being exported. The
  'shadow' option resolves it in favor of the other one.")

  (:method ((symbols list) &optional (package *package*))
    (declare (type package-designator package))
    (loop with package =  (resolve-package-designator package *package*)
	  for symbol in symbols
	  do (export symbol package)
          finally (return t)))

  (:method ((symbol symbol) &optional (package *package*))
    (declare (type package-designator package))
    (let* ((package (resolve-package-designator package *package*)))
      (multiple-value-bind (found-symbol status)
          (find-symbol (name symbol) package)
      
        ;; Error if not accessible. Correctable by importing.
        (when (or (null status)
                  (not (eql symbol found-symbol)))
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
      
        ;; Look for name conflicts in packages that uses
        ;; package. Correctable by uninterning or shadowing the
        ;; conflicting symbol.
        (loop
	  for used-by in (used-by-list package)
	  do (multiple-value-bind (conflicting-symbol status)
	         (find-present-symbol (name symbol) used-by)
	       (unless (null status)
	         (restart-case
		     (error 'conflicting-symbol-names
			    :package package
			    :context *package*
			    :symbol symbol
			    :conflicting-symbol conflicting-symbol)
		   (unintern ()
		     :report (lambda (stream)
			       (format stream "Unintern ~S." conflicting-symbol))
		     :test (lambda (condition)
			     (typep condition 'conflicting-symbol-names))
		     (unintern conflicting-symbol (symbol-package conflicting-symbol)))
		   (shadow ()
		     :report (lambda (stream)
			       (format stream "Shadow ~S." conflicting-symbol))
		     :test (lambda (condition)
			     (typep condition 'conflicting-symbol-names))
		     (shadow conflicting-symbol (symbol-package conflicting-symbol)))))))
      
        ;; Do the export.
        (unless (eql status :external)
	  (add-external-symbol symbol package)
	  (when (eql status :internal)
	    (remove-internal-symbol symbol package)))))
    t))
