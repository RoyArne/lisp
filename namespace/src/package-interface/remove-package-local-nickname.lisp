;;;; This is "namespace/src/package-interface/remove-package-local-nickname.lisp".

(in-package #:namespace)

(defgeneric remove-package-local-nickname (old-nickname &optional package)
  (:documentation "Syntax:
\(remove-package-local-nickname old-nickname &optional package\) → boolean

Arguments and Values:
old-nickname—a string designator.
package—a package designator. The default is the current package.
boolean—a generalized boolean.

Description:
Removes old-nickname as a local nickname from package.

Returns t if old-nickname was a local nickname in package. Otherwise,
returns NIL.")

  (:method (old-nickname &optional (package *package*))
    (declare (type package-designator package))
    (remove-package-local-nickname (resolve-string-designator old-nickname)
				   package))

  (:method ((old-nickname string) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (remove-local-nickname! old-nickname package)
      t)))
    
