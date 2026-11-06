;;;; This is "unicode/src/utf-8/conditions.lisp".

(in-package #:unicode.utf-8)

(defgeneric utf-8-error-octets (condition)
  (:documentation "Syntax:
\(utf-8-error-octets condition\) → octets

Arguments and Values:
condition—a condition of type utf-8-error.
octets—an octet vector.

Description:
Return the octets that triggered this condition."))

(defgeneric utf-8-error-message (condition)
  (:documentation "Syntax:
\(utf-8-error-message condition\) → string

Arguments and Values:
condition—a condition of type utf-8-error.
string—a format string.

Description:
Return the format string used to print error messages."))

(define-condition utf-8-error (error)
  ((octets :reader utf-8-error-octets
           :initform nil
           :initarg :octets
           :type (or null octet octets code-point)
           :documentation "The octets being encoded or decoded.")
   (message :reader utf-8-error-message
            :initform "The octet sequence~%  ~S~%has an encoding error."
            :initarg :message
            :type string
            :documentation "A format string used to report this condition."))
  (:report (lambda (c stream)
             (format stream
                     (utf-8-error-message c)
                     (utf-8-error-octets c)))))
                     
             
