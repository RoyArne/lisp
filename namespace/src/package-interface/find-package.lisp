;;;; This is "namespace/src/package-interface/find-package.lisp".

(in-package #:namespace)

(defgeneric find-package (name)
  
  (:documentation "Syntax:
\(find-package name\) → package

Arguments and Values:
name—a package designator.
package—a package object or nil.

Description:
If name is a package object, that package object is returned.

If name is a string-designator, find-package locates a package with a local
nickname or name matching name. Local nicknames takes precedence over names.")

  (:method (name)
    (find-package (resolve-string-designator name)))
  
  (:method ((name string))
    (find-visible-package name *package*))
  
  (:method ((package package))
    package))
