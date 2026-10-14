;;;; This is "namespace/src/package-interface/rename-package.lisp".

(in-package #:namespace)


(defgeneric rename-package (package new-name)
  (:documentation "Syntax:
\(rename-package package new-name\) → package-object

Arguments and Values:
package—a package designator.
new-name—a string designator.
package-object—a package object.

Description:
Set the string that names package to new-name.

Exceptional Situations:

conflicting-package-names

  A correctable error of type package-error.

  Signaled if the new name is equal to any package name visible from
  package. Offers an 'delete-package' option that deletes the conflicting
  package.")

  (:method (package new-name)
    (rename-package (resolve-package-designator package)
                    (resolve-string-designator new-name)))
  
  (:method ((package package) (new-name string))
    (unless (string= new-name (name package))
      (let ((conflict (find-conflicting-package new-name package)))
        (setf (slot-value package 'name) (if conflict
                                             (restart-case
                                                 (error 'conflicting-package-names
		                                        :package conflict
		                                        :context package
		                                        :name new-name)
	                                       (delete-package ()
	                                         :report (lambda (stream)
		                                           (format stream "Delete ~S." conflict))
	                                         :test (lambda (condition)
		                                         (typep condition 'conflicting-package-names))
	                                         (delete-package conflict)
	                                         new-name))
                                             new-name))))
    package))
