;;;; This is "namespace/src/utilities.lisp".

(in-package #:namespace)


;;;   separate-declarations-and-body is used by
;;;
;;; · do-symbols,
;;; · do-external-symbols, and
;;; · do-all-symbols.
;;;

(declaim (ftype (function (list)
                          (values list list))
                separate-declarations-and-body))

(defun separate-declarations-and-body (body)
  ;; find the position of the first non-declare element of body
  (let ((i (position-if (complement #'(lambda (elt)
                                        (and (consp elt)
                                             (eq 'declare (car elt)))))
                        body)))
    ;; Return two values, a list of declare forms and the remaining body forms
    (if (null i)
        (values body '())
        (values (subseq body 0 i) (subseq body i)))))
