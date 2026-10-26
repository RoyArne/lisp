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
If the package designator is a name that does not currently name a package, a
correctable error of type package-error is signaled. If correction is
attempted, no deletion action is attempted; instead, delete-package
immediately returns nil.

If package, or a package that is internal to package, is used by other
packages that are not internal to package, a correctable error of type
package-error is signaled. If correction is attempted, unuse-package is called
to remove any dependencies. delete-package then deletes package. The effects
of unusing a package is not undone if the process is aborted before all
packages have been processed.

If package, or a package that is internal to package, is the current package,
a correctable error of type package-error is signaled. If correction is
attempted, no deletion action is attempted; instead, delete-package
immediately returns nil.

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
         ;; instead. We assume *lisp* and *keyword* can never be an internal
         ;; package.
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
      ;;
      ;; FIXME: we need to go through all the internal packages and make sure
      ;;        they are not used by external packages.
      ;; (loop for used-by = (first (used-by-list package))
      ;;       until (null used-by)
      ;;       do (restart-case
      ;;   	 (error'package-is-in-use
      ;;   	  :package package
      ;;   	  :context *package*
      ;;   	  :message (format nil
      ;;   			   "Cannot delete ~~S because it is used by ~S in the context ~~S."
      ;;   			   used-by))
      ;;            (unuse-package ()
      ;;   	   :report (lambda (stream)
      ;;   		     (format stream "Call (unuse-package ~S ~S)." package used-by))
      ;;   	   :test (lambda (condition)
      ;;   		   (typep condition 'package-is-in-use))
      ;;   	   (unuse-package package used-by)))))
    
    ;; Remove the package from its home.
    (remove-package package (home-package package))
    
    ;; Remove references to package from its symbols.
    ;; (unintern-internal-symbols! package)
    ;; (unintern-external-symbols! package)
    ;; (unintern-shadowing-symbols! package)
    ;; (clear-shadowing-symbols! package)
    
    ;; Remove package from the used-by-list of packages it is using.
    (clear-use-list! package)
    ;; Set the package name to NIL
    (setf (slot-value package 'name) nil)
    t))
