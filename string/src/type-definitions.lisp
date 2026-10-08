;;;; This is "string/src/type-definitions.lisp".

(in-package #:string)

(defclass string ()
  ((rope :initarg :rope
         :initform utf-8:*empty*
         :type rope:rope)))

;; Eventually we need an initialize-instance that does some normalization and
;; things like that.

(defgeneric string? (object)
  (:documentation
   "Syntax
\(string? object\) → generalized-boolean

Arguments and Values:
object—an object.
generalized-boolean—a generalized boolean.

Description:
Returns true if object is a string; otherwise, returns false.")
  (:method (object)
    nil)
  (:method ((object string))
    t))

;; Maybe string should have keyword arguments? for example :normalize normalization-method.

(defgeneric string (object)
  (:documentation
   "Syntax:
\(string object\) → string

Arguments and Values:
object—an object.
string—a string.

Description:
Returns a string described by object."))
