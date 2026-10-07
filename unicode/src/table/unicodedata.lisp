;;;; This is "src/table/unicodedata.lisp".
;;;;
;;;; "unicodedata.lisp" defines tables and lookup functions for data in
;;;; UnicodeData.txt from the Unicode Character Database.
;;;;
;;;; We store the data in on file per table at the pathname returned by
;;;; (unicode.configuration:data-pathname filename). The filenames are:
;;;;
;;;; · "character-names.lisp"
;;;; · "general-category.lisp"
;;;; · "canonical-combining-classes.lisp"
;;;; · "bidirectional-category.lisp"
;;;; · "canonical-decomposition-mapping.lisp"
;;;; · "compatibility-decomposition-mapping.lisp"
;;;; · "decimal-digit-value.lisp"
;;;; · "digit-value.lisp"
;;;; · "numeric-value.lisp"
;;;; · "mirrored.lisp"
;;;; · "uppercase-mapping.lisp"
;;;; · "lowercase-mapping.lisp"
;;;; · "titlecase-mapping.lisp"

(in-package #:unicode.table)


;;; ============================================================================
;;; Reading Data Files
;;; ============================================================================

(declaim (ftype (function (string (or property-table property-map code-point-map string-map))
                          (or property-table property-map code-point-map string-map))
                read-unicodedata))

(defun read-unicodedata (filename default)
  (with-open-file (stream (unicode.configuration:data-pathname filename) :if-does-not-exist nil :external-format :utf-8)
    (if stream
        (read-table :stream stream :table-type (type-of default))
        default)))


;;; ============================================================================
;;; Property Tables and Lookup Functions
;;; ============================================================================

(declaim (type property-table
               *mirrored*)

         (ftype (function (utf-8:octets vector:index)
                          boolean)
                mirrored?))

(defparameter *mirrored* (read-unicodedata "mirrored.lisp" *empty-property-table*))

(defun mirrored? (octets start)
  (has-property? octets start *mirrored*))


;;; ============================================================================
;;; Property Maps and Lookup Functions
;;; ============================================================================

(declaim (type property-map
               *general-category* *canonical-combining-classes* *decimal-digit-value* *digit-value* *numeric-value*)

         (ftype (function (utf-8:octets vector:index)
                          t)
                general-category-of canonical-combining-class-of decimal-digit-value-of digit-value-of numeric-value-of))

(defparameter *general-category* (read-unicodedata "general-category.lisp" *empty-property-map*))
(defparameter *decimal-digit-value* (read-unicodedata "decimal-digit-value.lisp" *empty-property-map*))
(defparameter *digit-value* (read-unicodedata "digit-value.lisp" *empty-property-map*))
(defparameter *numeric-value* (read-unicodedata "numeric-value.lisp" *empty-property-map*))
(defparameter *canonical-combining-classes* (read-unicodedata "canonical-combining-classes.lisp" *empty-property-map*))

(defun general-category-of (octets start)
  (property-mapping-of octets start *general-category*))

(defun decimal-digit-value-of (octets start)
  (property-mapping-of octets start *decimal-digit-value*))

(defun digit-value-of (octets start)
  (property-mapping-of octets start *digit-value*))

(defun numeric-value-of (octets start)
  (property-mapping-of octets start *numeric-value*))

(defun canonical-combining-class-of (octets start)
  (property-mapping-of octets start *canonical-combining-classes*))


;;; ============================================================================
;;; Code Point Maps and Lookup Functions
;;; ============================================================================

(declaim (type code-point-map
               *uppercase-mapping* *lowercase-mapping* *titlecase-mapping*)

         (ftype (function (utf-8:octets vector:index)
                          code-point:code-point)
                upppercase-of lowercase-of titlecase-of))

(defparameter *uppercase-mapping* (read-unicodedata "uppercase-mapping.lisp" *empty-code-point-map*))
(defparameter *lowercase-mapping* (read-unicodedata "lowercase-mapping.lisp" *empty-code-point-map*))
(defparameter *titlecase-mapping* (read-unicodedata "titlecase-mapping.lisp" *empty-code-point-map*))

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
                          utf-8:octets)
                character-name-of bidirectional-category-of canonical-decomposition-of
                compatibility-decomposition-of))

(defparameter *character-names* (read-unicodedata "character-names.lisp" *empty-string-map*))
(defparameter *bidirectional-category* (read-unicodedata "bidirectional-category.lisp" *empty-string-map*))
(defparameter *canonical-decomposition-mapping* (read-unicodedata "canonical-decomposition-mapping.lisp" *empty-string-map*))
(defparameter *compatibility-decomposition-mapping* (read-unicodedata "compatibility-decomposition-mapping.lisp" *empty-string-map*))

(defun character-name-of (octets start)
  (string-mapping-of octets start *character-names*))

(defun bidirectional-category-of (octets start)
  (string-mapping-of octets start *bidirectional-category*))

(defun canonical-decomposition-of (octets start)
  (string-mapping-of octets start *canonical-decomposition-mapping*))

(defun compatibility-decomposition-of (octets start)
  (string-mapping-of octets start *compatibility-decomposition-mapping*))
