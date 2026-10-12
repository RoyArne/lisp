;;;; This is "namespace/src/package-interface/use-package.lisp".

(in-package #:namespace)

(defgeneric use-package (packages-to-use &optional package)
  (:documentation "Syntax:
\(use-package packages &optional package\) → t

Arguments and Values:
packages—a designator for a list of package designators.
package—a package designator. The default is the current package.

Description:
use-package causes package to inherit all the external symbols of
packages. The inherited symbols become accessible as internal symbols
of package.

Packages are added to the use list of package if they are not there
already. All external symbols in packages become accessible in package
as internal symbols. use-package does not cause any new symbols to be
present in package but only makes them accessible by inheritance.

use-package checks for name conflicts between the newly imported
symbols and those already accessible in package. A name conflict in
use-package between two external symbols inherited by package from
packages-to-use may be resolved in favor of either symbol by importing
one of them into package and making it a shadowing symbol.")

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
