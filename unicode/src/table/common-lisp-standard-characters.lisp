
(in-package #:unicode.table)

;;; ============================================================================
;;; Property Maps and Lookup Functions
;;; ============================================================================

(declaim (type property-map
               *common-lisp-syntax-types*
               *common-lisp-traits*)

         (ftype (function (utf-8:octets vector:index)
                          t)
                common-lisp-syntax-type-of
                common-lisp-trait-of))

(defparameter *common-lisp-syntax-types* (read-unicodedata "common-lisp-syntax-types.lisp" *empty-property-map*))
(defparameter *common-lisp-traits* (read-unicodedata "common-lisp-traits.lisp" *empty-property-map*))

(defun common-lisp-syntax-type-of (octets start)
  (property-mapping-of octets start *common-lisp-syntax-types*))

(defun common-lisp-trait-of (octets start)
  (property-mapping-of octets start *common-lisp-traits*))

