;;;; This is "namespace/src/package-interface/delete-package.lisp".

(in-package #:namespace)

(defgeneric delete-package (package)
    (:documentation "Syntax:
\(delete-package package\) → generalized boolean

Arguments and Values:
package—a package designator.
generalized boolean—t, or nil.

Description:
Deletes package from the package system. Returns true if the operation is
successful, otherwise nil.

The deleted package is still a package object \(i.e. package? is true for it\),
but package-name returns nil.

If package is a deleted package object, then delete-package immediately
returns nil.

After this operation completes, symbols who were accessible in package are
unchanged. If package had any internal packages, they are still internal to
package. Package itself is removed from its home package \(if any\).

Exceptional Situations:

package-does-not-exist

  A correctable error of type package-error.

  Signaled if the package-designator is a name that does not name a visible
  package.

  A 'continue' option corrects the error by aborting the deletion, and
  delete-package immediately returns nil.

package-is-the-current-package

  A correctable arror of type package-error.

  Signaled if package is the current package, *package*.

  A 'continue' option corrects the error by aborting the deletion, and
  delete-package immediately returns nil.

package-is-a-system-package

  A correctable arror of type package-error.

  Signaled if package is one of the system packages, *lisp* or *keyword*.

  A 'continue' option corrects the error by aborting the deletion, and
  delete-package immediately returns nil.

package-is-in-use

  A correctable arror of type package-error.

  Signaled if package, or a package that is internal to package, is used by
  any package not internal to package.

  A 'unuse-package' option corrects the error by calling unuse-package to
  remove dependencies on package and its internal packages. delete-package
  then deletes package and returns t.

  The effects of unusing packages are not undone if the process is aborted
  before all relevant packages have been processed.")
  
  (:method (package)
    (restart-case 
	(delete-package (resolve-package-designator package *package*))
      (continue ()
	:report "Return NIL."
	:test (lambda (condition)
		(typep condition 'package-does-not-exist))
	(return-from delete-package nil))))

  (:method ((package package))
    (let ((hierarchy (list-hierarchy package)))
      (cond
        ((null (package-name package))
         ;; If the name is nil then the package is already deleted.
         (return-from delete-package nil))

        ((find *package* hierarchy)
         ;; The current package cannot be deleted. Offer a choice to return NIL
         ;; instead.
         (restart-case
	     (error 'package-is-the-current-package
		    :package package
		    :context *package*
		    :message "Cannot delete ~S because it (or one of its internal packages) is the current package in context ~S.")
	   (continue ()
	     :report (lambda (stream)
		       (format stream "Return NIL without deleting ~S."  package))
	     :test (lambda (condition)
		     (typep condition 'package-is-the-current-package))
	     (return-from delete-package nil))))

        ((or (eql package *lisp*)
             (eql package *keyword*))
         ;; System packages cannot be deleted. Offer a choice to return NIL
         ;; instead.
         ;; 
         ;; FIXME: We assume *lisp* and *keyword* are never internal
         ;;        packages.
         ;; 
         ;;        It is perfectly possible for someone to set one of them to
         ;;        an internal package though, they just shouldnt. This needs
         ;;        an external fix, we need a way to define types for *lisp*
         ;;        and *keyword* so they can only hold top-level packages
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
    
      ;; We do not restore the used-by relationship if the process of
      ;; unusing packages is aborted before it is completed.
      (loop for package-to-unuse in hierarchy
            do (loop with used-by-list = (remove-if #'(lambda (p) (find p hierarchy)) (used-by-list package-to-unuse))
                     for used-by = (first used-by-list)
                     while used-by
                     do (restart-case
                            (error 'package-is-in-use
                                   :package package
                                   :context package-to-unuse
                                   :message (format nil "Cannot delete ~~S because ~S is using ~~S." used-by))
                          (unuse-package ()
                            :report (lambda (stream)
                                      (format stream "Call (unuse-package ~S ~S)." package-to-unuse used-by))
                            :test (lambda (condition)
                                    (typep condition 'package-is-in-use))
                            (setf used-by-list (rest used-by-list))
                            (unuse-package package-to-unuse used-by))))))
    
    ;; Remove the package from its home.
    (remove-package package (home-package package))
    
    ;; Remove package from the used-by-list of packages it is using.
    (clear-use-list! package)
    ;; Set the package name to NIL
    (setf (name package) nil)
    t))
