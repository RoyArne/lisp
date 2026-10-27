;;;; This is "namespace/src/package-interface/make-package.lisp".

(in-package #:namespace)

(defgeneric make-package (name &key use home)
  
  (:documentation "Syntax:
\(make-package name &key use home\) → new-package

Arguments and Values:
name—a string designator.
use—a list of package designators. The default is an empty list.
home—a context designator. The default is nil.
new-package—a package object.

Description:
Creates a new package named name.

Use is a list of package-designators specifying packages that are used
by the new package, per use-package.

Home specifies where the new package is located:

  Not supplied:      This is the default.

                     The new package becomes a peer of the current
                     package.

                     Its home package is the home package of the
                     current package.

                     It is located as the first element in the
                     package-internal-list of the current packages
                     home package.

  NIL:               The new package becomes a top-level package.

                     It does not have a home package.

                     It is located as the first element of *packages*.

  A package object:  The new package becomes an internal package of
                     the supplied home package.

                     Its home package is the supplied home package.

                     It is located as the first element of the
                     supplied home packages package-internal-list.

Exceptional Situations:

conflicting-package-names

  A correctable error of type package-error.

  Signaled if a package with the same name already exists, and offers
  a 'delete-package' option to delete the existing package.")

  (:method (object &key (use '()) (home nil home-supplied?))
    (declare (type list use)
	     (type home-designator home)
             (type boolean home-supplied?))
    (make-package (resolve-string-designator object)
                  :use use
                  :home (resolve-home-designator (if home-supplied? home (home-package *package*)))))

  (:method ((name string) &key (use '()) (home nil home-supplied?))
    (declare (type list use)
	     (type home-designator home)
             (type boolean home-supplied?))
    (let ((new (make-instance 'package))
          (home (resolve-home-designator (if home-supplied? home (home-package *package*)))))
      (let ((conflict (find-conflicting-package name home)))
        (setf (slot-value new 'name) (if conflict
                                         (restart-case
                                             (error 'conflicting-package-names
		                                    :package conflict
		                                    :context home
		                                    :name name)
	                                   (delete-package ()
	                                     :report (lambda (stream)
		                                       (format stream "Delete ~S." conflict))
	                                     :test (lambda (condition)
		                                     (typep condition 'conflicting-package-names))
	                                     (delete-package conflict)
	                                     name))
                                         name)))
      (add-package new home)
      (use-package use new)
      new)))
