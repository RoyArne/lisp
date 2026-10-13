;;;; This is "namespace/src/package-interface/add-package-local-nickname.lisp".

(in-package #:namespace)

(declaim (ftype (function (string package package)
                          string)
                ensure-valid-local-nickname))

(defun ensure-valid-local-nickname (nickname actual-package package)
  (restart-case
      (cond
        ((string= nickname (name package))
         (error 'conflicting-package-names
		:package package
		:context package
		:name nickname
		:message "~S names ~S when adding a local nickname to ~S."))
        ((find-local-nickname nickname package)
	 (error 'conflicting-package-names
		:package (rest (find-local-nickname nickname package))
		:context package
		:name nickname
		:message "~S is already a local nickname for ~S in ~S."))
        (t
         nickname))
    (use-value (new-nickname)
      :report "Enter a local nickname"
      :interactive (lambda ()
		     (format *query-io* "Enter a local nickname:")
		     (force-output *query-io*)
		     (list (read *query-io*)))
      (ensure-valid-local-nickname new-nickname actual-package package))))

(defgeneric add-package-local-nickname (local-nickname actual-package &optional package)
  (:documentation "Syntax:
\(add-package-local-nickname local-nickname actual-package &optional package\) → designated-package

Arguments and Values:
local-nickname—a string designator.
actual-package—a package designator.
package—a package designator.
designated-package—the package where local-nickname can be used.

Description:
Makes local-nickname available as a package prefix for actual-package
from inside package.

Returns the package object where local-nickname is available.

Exceptional Situations:
Signals an error of type type-error if package is not a package
designator.
Signals an error of type package-does-not-exist if package cannot be
found in context.
Signals a correctable error of type conflicting-package-names if
local-nickname is already a local nickname for a different package.
Signals a correctable error of type conflicting-package-names if
local-nickname is the name or a nickname of the package to which the
nickname is being added.")

  (:method (nickname actual-package &optional (package *package*))
    (declare (type package-designator package))
    (add-package-local-nickname nickname
				(resolve-package-designator actual-package package)
				package))

  (:method (nickname (actual-package package) &optional (package *package*))
    (add-package-local-nickname (resolve-string-designator nickname)
				actual-package
				package))

  (:method ((nickname string) (actual-package package) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (unless (eql actual-package (rest (find-local-nickname nickname package)))
        (add-local-nickname! (ensure-valid-local-nickname nickname actual-package package)
                             actual-package
                             package))
      package)))
    
