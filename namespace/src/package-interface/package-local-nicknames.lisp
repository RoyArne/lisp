;;;; This is "namespace/src/package-interface/package-local-nicknames.lisp".

(in-package #:namespace)

(defgeneric package-local-nicknames (package)
  (:documentation "Syntax:
\(package-local-nicknames package\) → local-nicknames

Arguments and Values:
package—a package designator.
local-nicknames—an alist of \(string . package object\).

Description:
Returns an alist of \(local-nickname . actual-package\) for package.

See Also:
add-package-local-nickname, package-locally-nicknamed-by-list,
remove-package-local-nickname.")

  (:method (object)
    (package-local-nicknames (resolve-package-designator object *package*)))

  (:method ((package package))
    (copy-alist (local-nicknames package))))
