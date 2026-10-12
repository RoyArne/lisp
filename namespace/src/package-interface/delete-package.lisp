;;;; This is "namespace/src/package-interface/delete-package.lisp".

(in-package #:namespace)

(defgeneric delete-package (package)
    (:documentation "Syntax:
\(delete-package package\) → generalized boolean

Arguments and Values:
package—a package designator.
generalized boolean—t, or nil.

Description:
delete-package deletes package from all package system data
structures. If the operation is successful, delete-package returns
true, otherwise nil. The effect of delete-package is that the name and
nicknames of package cease to be recognized package names. The package
object is still a package (i.e., packagep is true of it) but
package-name returns nil. The consequences of deleting the COMMON-LISP
package or the KEYWORD package are undefined. The consequences of
invoking any other package operation on package once it has been
deleted are unspecified. In particular, the consequences of invoking
find-symbol, intern and other functions that look for a symbol name in
a package are unspecified if they are called with *package* bound to
the deleted package or with the deleted package as an argument.

If package is a package object that has already been deleted,
delete-package immediately returns nil.

After this operation completes, the home package of any symbol whose
home package had previously been package is
implementation-dependent. Except for this, symbols accessible in
package are not modified in any other way; symbols whose home package
is not package remain unchanged.

Exceptional Situations:
If the package designator is a name that does not currently name a
package, a correctable error of type package-error is signaled. If
correction is attempted, no deletion action is attempted; instead,
delete-package immediately returns nil.

If package is used by other packages, a correctable error of type
package-error is signaled. If correction is attempted, unuse-package
is effectively called to remove any dependencies, causing package's
external symbols to cease being accessible to those packages that use
package. delete-package then deletes package just as it would have had
there been no packages that used it.

If package is the current package, a correctable error of type
package-error is signaled. If correction is attempted, no deletion
action is attempted; instead, delete-package immediately returns
nil.

If package is a system package, a correctable error of type
package-error is signaled. If correction is attempted, no deletion
action is attempted; instead, delete-package immediately returns
nil.")

    (:method (package)
      (restart-case 
	  (delete-package (resolve-package-designator package *package*))
	(continue ()
	  :report "Return NIL."
	  :test (lambda (condition)
		  (typep condition 'package-does-not-exist))
	  (return-from delete-package nil))))

    (:method ((package package))
      ;; The current package cannot be deleted. Offer a choice to return NIL instead.
      (when (eql package *package*)
	(restart-case
	    (error 'package-is-the-current-package
		   :package package
		   :context *package*
		   :message "Cannot delete ~S because it is the current package in context ~S.")
	  (continue ()
	    :report (lambda (stream)
		      (format stream "Return NIL without deleting ~S."  package))
	    :test (lambda (condition)
		    (typep condition 'package-is-the-current-package))
	    (return-from delete-package nil))))
      ;; A package cannot be deleted whle it is used by some other
      ;; package. Offer to call unuse-package for each package using
      ;; package.
      ;; We do not restore the used-by relationship if the process of
      ;; unusing packages is aborted before it is completed.
      (loop
	 for used-by = (first (used-by-list package))
	 until (null used-by)
	 do (restart-case
		(error'package-is-in-use
		 :package package
		 :context *package*
		 :message (format nil
				  "Cannot delete ~~S because it is used by ~S in the context ~~S."
				  used-by))
	      (unuse-package ()
		:report (lambda (stream)
			  (format stream "Call (unuse-package ~S ~S)." package used-by))
		:test (lambda (condition)
			(typep condition 'package-is-in-use))
		(unuse-package package used-by))))
      ;; Remove the package from its home.
      (remove-package package (home-package package))
      ;; Remove references to package from its symbols.
      (unintern-internal-symbols! package)
      (unintern-external-symbols! package)
      (unintern-shadowing-symbols! package)
      (clear-shadowing-symbols! package)
      ;; Remove package from the used-by-list of packages it is using.
      (clear-use-list! package)
      ;; Set the package name to NIL
      (setf (slot-value package 'name) nil)
      package)

    (:method ((package (eql *lisp*)))
      (restart-case
	  (error 'package-is-a-system-package
		 :package package
		 :context *package*
		 :message "Cannot delete ~S because it is a system package.")
	(continue ()
	  :report (lambda (stream)
		    (format stream "Return NIL without deleting ~S." package))
	  :test (lambda (condition)
		  (typep condition 'package-is-a-system-package))
	  (return-from delete-package nil))))

    (:method ((package (eql *keyword*)))
      (restart-case
	  (error 'package-is-a-system-package
		 :package package
		 :context *package*
		 :message "Cannot delete ~S because it is a system package.")
	(continue ()
	  :report (lambda (stream)
		    (format stream "Return NIL without deleting ~S." package))
	  :test (lambda (condition)
		  (typep condition 'package-is-a-system-package))
	  (return-from delete-package nil)))))
