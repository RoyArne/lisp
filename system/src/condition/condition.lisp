
(defpackage #:system.condition
  (:use #:common-lisp)
  (:shadow #:program-error)
  (:export #:program-error))

(in-package #:system.condition)

(define-condition program-error (error)
  ((message :reader program-error-message
            :initform "Syntax error."
            :initarg :message
            :documentation "A string used to report this condition."
            :type string))
  (:report (lambda (condition stream)
             (format stream string))))
   
