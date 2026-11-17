;;;; This is "src/table/unicodedata.lisp".
;;;;
;;;; "unicodedata.lisp" defines tables and lookup functions for data in
;;;; UnicodeData.txt from the Unicode Character Database. Our tables are
;;;; stored in the "data/UCD/UnicodeData/" directory, one file per table.

(in-package #:unicode.table)

;;; ============================================================================
;;; Property Tables and Lookup Functions
;;; ============================================================================

(declaim (type property-table
               *mirrored*)

         (ftype (function (utf-8:octets vector:index)
                          boolean)
                mirrored?))

(defparameter *mirrored* (load-table "UCD/UnicodeData/mirrored.lisp" *empty-property-table*))

(defun mirrored? (octets start)
  (has-property? octets start *mirrored*))


;;; ============================================================================
;;; Property Maps and Lookup Functions
;;; ============================================================================

(declaim (type property-map
               *general-category* *decimal-digit-value* *digit-value* *numeric-value*)

         (ftype (function (utf-8:octets vector:index)
                          t)
                general-category-of decimal-digit-value-of digit-value-of numeric-value-of))

(defparameter *general-category* (load-table "UCD/UnicodeData/general-category.lisp" *empty-property-map*))
(defparameter *decimal-digit-value* (load-table "UCD/UnicodeData/decimal-digit-value.lisp" *empty-property-map*))
(defparameter *digit-value* (load-table "UCD/UnicodeData/digit-value.lisp" *empty-property-map*))
(defparameter *numeric-value* (load-table "UCD/UnicodeData/numeric-value.lisp" *empty-property-map*))

(defun general-category-of (octets start)
  (property-mapping-of octets start *general-category*))

(defun decimal-digit-value-of (octets start)
  (property-mapping-of octets start *decimal-digit-value*))

(defun digit-value-of (octets start)
  (property-mapping-of octets start *digit-value*))

(defun numeric-value-of (octets start)
  (property-mapping-of octets start *numeric-value*))

(declaim (type property-map  *canonical-combining-classes*)

         (ftype (function (utf-8:octets vector:index)
                          (unsigned-byte 8))
                canonical-combining-class-of))

(defparameter *canonical-combining-classes* (load-table "UCD/UnicodeData/canonical-combining-classes.lisp" *empty-property-map*))

;; Description of ccc values: https://www.unicode.org/reports/tr44/#CCC_Values_Table
;; The default value is zero.
(defun canonical-combining-class-of (octets start)
  (or (property-mapping-of octets start *canonical-combining-classes*)
      0))


;;; ============================================================================
;;; Code Point Maps and Lookup Functions
;;; ============================================================================

(declaim (type code-point-map
               *uppercase-mapping* *lowercase-mapping* *titlecase-mapping*)

         (ftype (function (utf-8:octets vector:index)
                          code-point:code-point)
                upppercase-of lowercase-of titlecase-of))

(defparameter *uppercase-mapping* (load-table "UCD/UnicodeData/uppercase-mapping.lisp" *empty-code-point-map*))
(defparameter *lowercase-mapping* (load-table "UCD/UnicodeData/lowercase-mapping.lisp" *empty-code-point-map*))
(defparameter *titlecase-mapping* (load-table "UCD/UnicodeData/titlecase-mapping.lisp" *empty-code-point-map*))

(defun uppercase-of (octets start)
  (code-point-mapping-of octets start *uppercase-mapping*))

(defun lowercase-of (octets start)
  (code-point-mapping-of octets start *lowercase-mapping*))

(defun titlecase-of (octets start)
  (code-point-mapping-of octets start *titlecase-mapping*))


;;; ============================================================================
;;; String Maps and Lookup Functions
;;; ============================================================================

(declaim (type string-map
               *character-names* *bidirectional-category* *canonical-decomposition-mapping* *compatibility-decomposition-mapping*)

         (ftype (function (utf-8:octets vector:index)
                          (or null utf-8:octets))
                character-name-of bidirectional-category-of canonical-decomposition-of
                compatibility-decomposition-of))

(defparameter *character-names* (load-table "UCD/UnicodeData/character-names.lisp" *empty-string-map*))
(defparameter *bidirectional-category* (load-table "UCD/UnicodeData/bidirectional-category.lisp" *empty-string-map*))
(defparameter *canonical-decomposition-mapping* (load-table "UCD/UnicodeData/canonical-decomposition-mapping.lisp" *empty-string-map*))
(defparameter *compatibility-decomposition-mapping* (load-table "UCD/UnicodeData/compatibility-decomposition-mapping.lisp" *empty-string-map*))

(defun character-name-of (octets start)
  (string-mapping-of octets start *character-names*))

(defun bidirectional-category-of (octets start)
  (string-mapping-of octets start *bidirectional-category*))

(defun canonical-decomposition-of (octets start)
  (string-mapping-of octets start *canonical-decomposition-mapping*))

(defun compatibility-decomposition-of (octets start)
  (string-mapping-of octets start *compatibility-decomposition-mapping*))
