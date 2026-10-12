;;;; This is "namespace/src/package-interface/unuse-package.lisp".

(in-package #:namespace)

(defgeneric unuse-package (packages &optional package)

  (:documentation "Syntax:
\(unuse-package packages &optional package\) → t

Arguments and Values:
packages—a designator for a list of package designators.
package—a package designator. The default is the current package.

Description:
unuse-package causes package to cease inheriting all the external
symbols of packages-to-unuse; unuse-package undoes the effects of
use-package. The packages are removed from the use list of package.

Any symbols that have been imported into package continue to be
present in package.")

  (:method (package-to-unuse &optional (package *package*))
    (declare (type package-designator package))
    (unuse-package (list package-to-unuse) package))

  (:method ((packages-to-unuse list) &optional (package *package*))
    (declare (type package-designator package))
    (loop with package = (resolve-package-designator package *package*)
          for package-to-unuse in packages-to-unuse
          do (unuse-package (resolve-package-designator package-to-unuse package) package))
    t)

  (:method ((package-to-unuse package) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (remove-from-used-by-list! package package-to-unuse))
    t))
