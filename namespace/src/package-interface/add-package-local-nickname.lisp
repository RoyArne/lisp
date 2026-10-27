;;;; This is "namespace/src/package-interface/add-package-local-nickname.lisp".

(in-package #:namespace)

(declaim (ftype (function (string package package)
                          string)
                ensure-valid-local-nickname))

(defun ensure-valid-local-nickname (nickname actual-package package)
  (restart-case
      (cond
        ((string= nickname (name package))
         ;; It is an error to use nicknames that are the same as the name of
         ;; the package that is adding the nicknamed package.
         (error 'conflicting-package-names
		:package package
		:context package
		:name nickname
		:message "~S names ~S when adding a local nickname to ~S."))
        ((find-local-nickname nickname package)
         ;; It is an error to give two different packages the same nickname.
         ;; CONSIDER: what if the older nicknamed package is the same that
         ;;           we're giving a nickname now? i.e
         ;;           (eql actual-package (find-local-nickname …).
         ;;           should we allow this? if so we need to take care to not
         ;;           add an extra entry for the same package.
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

Note:
Local nicknames takes precedence over package names.

Exceptional Situations:

conflicting-package-names

  An error of type package-error.

  Signaled if local-nickname is the same as the designated packages name \(by
  string=\).

conflicting-package-names

  A correctable error of type package-error.

  Signaled if local-nickname is the same as the nickname given to another
  package \(by string=\).

  A 'use-value' option corrects the error by inquiring for a new nickname to
  be entered.")

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
    
