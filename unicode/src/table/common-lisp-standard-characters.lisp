
(in-package #:unicode.table)

;;; ============================================================================
;;; Property Maps and Lookup Functions
;;; ============================================================================

(declaim (type property-map
               *common-lisp-syntax-types*)

         (ftype (function (utf-8:octets vector:index)
                          t)
                common-lisp-syntax-type-of))

(defparameter *common-lisp-syntax-types* (read-unicodedata "common-lisp-syntax-types.lisp" *empty-property-map*))

(defun common-lisp-syntax-type-of (octets start)
  (property-mapping-of octets start *common-lisp-syntax-types*))
