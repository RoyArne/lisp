;;;; This is "unicode/src/table/hangulsyllabletype.lisp
;;;;
;;;; "hangulsyllabletype.lisp" defines the hangul syllable type property map
;;;; for data in "UCD/HangulSyllableTYpe.txt" in the Unicode Character
;;;; Database.

(in-package #:unicode.table)

;;; ============================================================================
;;; Property Maps and Lookup Functions
;;; ============================================================================

(declaim (type property-map *hangul-syllable-type*)

         (ftype (function (utf-8:octets vector:index)
                          (or null keyword))
                hangul-syllable-type-of))

(defparameter *hangul-syllable-type* (load-table "UCD/HangulSyllableType/hangul-syllable-type.lisp" *empty-property-map*))

(defun hangul-syllable-type-of (octets start)
  (property-mapping-of octets start *hangul-syllable-type*))
