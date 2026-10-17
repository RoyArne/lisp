;;;; This is "namespace/src/package-interface/in-package.lisp".

(in-package #:namespace)

(defmacro in-package (name)
  "Syntax:
\(in-package name\) → package

Arguments and Values:
name—a string designator.
package—a package object.

Description:
Sets the current package to the package named by name.

Side Effects:
The variable *package* is assigned.

Exceptional Situations:
Signals an error of type package-does-not-exist if the specified
package does not exist.

See Also:
*package* \(variable\)."
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf *package* (or (find-visible-package (resolve-string-designator ',name) *package*)
                         (error 'package-does-not-exist
	                        :package ',name
	                        :context *package*)))))
