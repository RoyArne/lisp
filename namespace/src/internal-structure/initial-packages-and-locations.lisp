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
  "The current package. Functions that accept optional 'package'
\(and 'contex'\) parameters, act on *package* by default.

Internal symbols of this package are available without the use of a
namespace prefix.

The value of *package* is set by the in-package macro.")


(defparameter *packages* (list  *user* *lisp* *keyword*)
  "The list of top-level packages.")
