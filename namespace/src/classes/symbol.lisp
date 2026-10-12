;;;; This is "namespace/src/classes-and-conditions/symbols.lisp".

(in-package #:namespace)

(defclass symbol ()
  ((name :reader name
         :initarg :name
         :initform (string "")
         :type string
         :documentation "A string used to identify the symbol.")
   (package :accessor package
            :initarg :package
            :initform nil
            :type (or null package)
            :documentation "The symbols home package.")))

;; A keyword is a symbol that is at home in the keyword package. We might not
;; want a class for it.

;; (defclass keyword (symbol)
;;   ())
