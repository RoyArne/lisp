;;;; This is "namespace/src/package-interface/use-package.lisp".

(in-package #:namespace)

(defgeneric use-package (packages-to-use &optional package)
  (:documentation "Syntax:
\(use-package packages &optional package\) → t

Arguments and Values:
packages—a designator for a list of package designators.
package—a package designator. The default is the current package.

Description:

Causes package to inherit all the external symbols of packages. The new
symbols become accessible as internal symbols of package.

Packages are added to the use list of package if they are not there
already.

Exceptional Situations:

conflicting-symbol-names

  A correctable error of type package-error.

  Signaled if one of the newly accessible symbols has the same name as one
  already accessible. Two restarts are offered:

  'keep-old' keeps the one already accessible by making it a shadowing symbol.

  'take-new' makes the newly accessible symbol a shadowing symbol.")

  (:method (to-use &optional (package *package*))
    (declare (type package-designator package))
    (use-package (list to-use) package))

  (:method ((packages-to-use list) &optional (package *package*))
    (declare (type package-designator package))
    (loop with package = (resolve-package-designator package *package*)
          for to-use in packages-to-use
          do (use-package (resolve-package-designator to-use package) package))
    t)

  (:method ((to-use package) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (unless (find to-use (use-list package))
        (loop for new-symbol being the hash-values in (external-symbols to-use)
              do (multiple-value-bind (conflicting-symbol status)
                     (find-symbol (name new-symbol) package)
                   (unless (or (null status)
                               (shadowing-symbol? conflicting-symbol package))
		     (restart-case
		         (error 'conflicting-symbol-names
			        :package package
			        :context *package*
			        :symbol new-symbol
			        :conflicting-symbol conflicting-symbol)
		       (keep-old ()
		         :report (lambda (stream)
			           (format stream
				           "Keep ~S already accessible in ~S (shadowing others)."
				           conflicting-symbol package))
		         :test (lambda (condition)
			         (typep condition 'conflicting-symbol-names))
		         (if (eql status :inherited)
			     (shadowing-import conflicting-symbol package)
			     (shadow (name conflicting-symbol) package)))
		       (take-new ()
		         :report (lambda (stream)
			           (format stream
				           "Make ~S accessible in ~S (uninterning old ones)."
				           new-symbol (package new-symbol)))
		         :test (lambda (condition)
			         (typep condition 'conflicting-symbol-names))
		         (shadowing-import new-symbol package))))))
        (add-to-use-list! package to-use)))
    t))
