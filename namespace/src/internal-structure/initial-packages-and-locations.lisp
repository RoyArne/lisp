;;;; This is "namespace/src/internal-structure/initial-packages-and-locations.lisp".
;;;;
;;;; We make initial definitions of the system packages "lisp" and "keyword",
;;;; as well as the "user" package.
;;;;
;;;; The current package, *package* is set to the user package.
;;;;
;;;; The list of top-level packages is intialized to (user lisp keyword).
;;;;

(in-package #:namespace)

(declaim (type package *lisp* *keyword* *user* *package*)
         (type list *packages*))

(defparameter *lisp* (let ((p (make-instance 'package)))
                       (setf (slot-value p 'name) (string "lisp"))
                       p))

(defparameter *keyword* (let ((p (make-instance 'package)))
                          (setf (slot-value p 'name) (string "keyword"))
                          p))

(defparameter *user* (let ((p (make-instance 'package)))
                       (setf (slot-value p 'name) (string "user"))
                       p))



(defparameter *package* *user*
  "Variable:
*package*

Description:
A package object that acts as the current package: it is the default value for
operations that manipulate and locate packages in the package hierarchy.

See Also:
in-package \(macro\).")


(defparameter *packages* (list  *user* *lisp* *keyword*)
  "Variable:
*packages*

Description:
Stores a list of package objects and acts as the top-level of the package
hierarchy.

See Also:
list-all-packages \(function\).")
