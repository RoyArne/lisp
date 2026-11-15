;;;; This is "src/table/proplist.lisp
;;;;
;;;; "proplist.lisp" defines tables and lookup functions for data in
;;;; "UCD/PropList.txt" in the Unicode Character Database.
;;;;
;;;; All tables in this file are property-table structures.

(in-package #:unicode.table)

;;; ============================================================================
;;; Property Tables and Lookup Functions
;;; ============================================================================

(declaim (type property-table
               *ascii-hex-digit* *bidi-control* *dash* *deprecated* *diacritic* *extender* *hex-digit* *hyphen*
               *ideographic* *id-compat-math-start* *id-compat-math-continue* *ids-unary-operator* *ids-binary-operator*
               *ids-trinary-operator* *join-control* *logical-order-exception* *modifier-combining-mark*
               *noncharacter-code-point* *other-alphabetic* *other-default-ignorable-code-point* *other-grapheme-extend*
               *other-id-continue* *other-id-start* *other-lowercase* *other-math* *other-uppercase* *pattern-syntax*
               *pattern-white-space* *prepended-concatenation-mark* *quotation-mark* *radical* *regional-indicator*
               *sentence-terminal* *soft-dotted* *terminal-punctuation* *unified-ideograph* *variation-selector*
               *white-space*))

(defparameter *ascii-hex-digit* (load-table "UCD/PropList/ascii-hex-digit.lisp" *empty-property-table*))
(defparameter *bidi-control* (load-table "UCD/PropList/bidi-control.lisp" *empty-property-table*))
(defparameter *dash* (load-table "UCD/PropList/dash.lisp" *empty-property-table*))
(defparameter *deprecated* (load-table "UCD/PropList/deprecated.lisp" *empty-property-table*))
(defparameter *diacritic* (load-table "UCD/PropList/diacritic.lisp" *empty-property-table*))
(defparameter *extender* (load-table "UCD/PropList/extender.lisp" *empty-property-table*))
(defparameter *hex-digit* (load-table "UCD/PropList/hex-digit.lisp" *empty-property-table*))
(defparameter *hyphen* (load-table "UCD/PropList/hyphen.lisp" *empty-property-table*))
(defparameter *ideographic* (load-table "UCD/PropList/ideographic.lisp" *empty-property-table*))
(defparameter *id-compat-math-start* (load-table "UCD/PropList/id-compat-math-start.lisp" *empty-property-table*))
(defparameter *id-compat-math-continue* (load-table "UCD/PropList/id-compat-math-continue.lisp" *empty-property-table*))
(defparameter *ids-unary-operator* (load-table "UCD/PropList/ids-unary-operator.lisp" *empty-property-table*))
(defparameter *ids-binary-operator* (load-table "UCD/PropList/ids-binary-operator.lisp" *empty-property-table*))
(defparameter *ids-trinary-operator* (load-table "UCD/PropList/ids-trinary-operator.lisp" *empty-property-table*))
(defparameter *join-control* (load-table "UCD/PropList/join-control.lisp" *empty-property-table*))
(defparameter *logical-order-exception* (load-table "UCD/PropList/logical-order-exception.lisp" *empty-property-table*))
(defparameter *modifier-combining-mark* (load-table "UCD/PropList/modifier-combining-mark.lisp" *empty-property-table*))
(defparameter *noncharacter-code-point* (load-table "UCD/PropList/noncharacter-code-point.lisp" *empty-property-table*))
(defparameter *other-alphabetic* (load-table "UCD/PropList/other-alphabetic.lisp" *empty-property-table*))
(defparameter *other-default-ignorable-code-point* (load-table "UCD/PropList/other-default-ignorable-code-point.lisp"
                                                               *empty-property-table*))
(defparameter *other-grapheme-extend* (load-table "UCD/PropList/other-grapheme-extend.lisp" *empty-property-table*))
(defparameter *other-id-continue* (load-table "UCD/PropList/other-id-continue.lisp" *empty-property-table*))
(defparameter *other-id-start* (load-table "UCD/PropList/other-id-start.lisp" *empty-property-table*))
(defparameter *other-lowercase* (load-table "UCD/PropList/other-lowercase.lisp" *empty-property-table*))
(defparameter *other-math* (load-table "UCD/PropList/other-math.lisp" *empty-property-table*))
(defparameter *other-uppercase* (load-table "UCD/PropList/other-uppercase.lisp" *empty-property-table*))
(defparameter *pattern-syntax* (load-table "UCD/PropList/pattern-syntax.lisp" *empty-property-table*))
(defparameter *pattern-white-space* (load-table "UCD/PropList/pattern-white-space.lisp" *empty-property-table*))
(defparameter *prepended-concatenation-mark* (load-table "UCD/PropList/prepended-concatenation-mark.lisp" *empty-property-table*))
(defparameter *quotation-mark* (load-table "UCD/PropList/quotation-mark.lisp" *empty-property-table*))
(defparameter *radical* (load-table "UCD/PropList/radical.lisp" *empty-property-table*))
(defparameter *regional-indicator* (load-table "UCD/PropList/regional-indicator.lisp" *empty-property-table*))
(defparameter *sentence-terminal* (load-table "UCD/PropList/sentence-terminal.lisp" *empty-property-table*))
(defparameter *soft-dotted* (load-table "UCD/PropList/soft-dotted.lisp" *empty-property-table*))
(defparameter *terminal-punctuation* (load-table "UCD/PropList/terminal-punctuation.lisp" *empty-property-table*))
(defparameter *unified-ideograph* (load-table "UCD/PropList/unified-ideograph.lisp" *empty-property-table*))
(defparameter *variation-selector* (load-table "UCD/PropList/variation-selector.lisp" *empty-property-table*))
(defparameter *white-space* (load-table "UCD/PropList/white-space.lisp" *empty-property-table*))

(declaim (ftype (function (utf-8:octets vector:index)
                          (or null symbol))
                ascii-hex-digit? bidi-control? dash? deprecated? diacritic? extender? hex-digit? hyphen? ideographic?
                id-compat-math-start? id-compat-math-continue? ids-unary-operator? ids-binary-operator? ids-trinary-operator?
                join-control? logical-order-exception? modifier-combining-mark? noncharacter-code-point? other-alphabetic?
                other-default-ignorable-code-point? other-grapheme-extend? other-id-continue? other-id-start? other-lowercase?
                other-math? other-uppercase? pattern-syntax? pattern-white-space? prepended-concatenation-mark?
                quotation-mark? radical? regional-indicator? sentence-terminal? soft-dotted? terminal-punctuation?
                unified-ideograph? variation-selector? white-space?))

(defun ascii-hex-digit? (octets start)
  (has-property? octets start *ascii-hex-digit*))

(defun bidi-control? (octets start)
  (has-property? octets start *bidi-control*))

(defun dash? (octets start)
  (has-property? octets start *dash*))

(defun deprecated? (octets start)
  (has-property? octets start *deprecated*))

(defun diacritic? (octets start)
  (has-property? octets start *diacritic*))

(defun extender? (octets start)
  (has-property? octets start *extender*))

(defun hex-digit? (octets start)
  (has-property? octets start *hex-digit*))

(defun hyphen? (octets start)
  (has-property? octets start *hyphen*))

(defun ideographic? (octets start)
  (has-property? octets start *ideographic*))

(defun id-compat-math-start? (octets start)
  (has-property? octets start *id-compat-math-start*))

(defun id-compat-math-continue? (octets start)
  (has-property? octets start *id-compat-math-continue*))

(defun ids-unary-operator? (octets start)
  (has-property? octets start *ids-unary-operator*))

(defun ids-binary-operator? (octets start)
  (has-property? octets start *ids-binary-operator*))

(defun ids-trinary-operator? (octets start)
  (has-property? octets start *ids-trinary-operator*))

(defun join-control? (octets start)
  (has-property? octets start *join-control*))

(defun logical-order-exception? (octets start)
  (has-property? octets start *logical-order-exception*))

(defun modifier-combining-mark? (octets start)
  (has-property? octets start *modifier-combining-mark*))

(defun noncharacter-code-point? (octets start)
  (has-property? octets start *noncharacter-code-point*))

(defun other-alphabetic? (octets start)
  (has-property? octets start *other-alphabetic*))

(defun other-default-ignorable-code-point? (octets start)
  (has-property? octets start *other-default-ignorable-code-point*))

(defun other-grapheme-extend? (octets start)
  (has-property? octets start *other-grapheme-extend*))

(defun other-id-continue? (octets start)
  (has-property? octets start *other-id-continue*))

(defun other-id-start? (octets start)
  (has-property? octets start *other-id-start*))

(defun other-lowercase? (octets start)
  (has-property? octets start *other-lowercase*))

(defun other-math? (octets start)
  (has-property? octets start *other-math*))

(defun other-uppercase? (octets start)
  (has-property? octets start *other-uppercase*))

(defun pattern-syntax? (octets start)
  (has-property? octets start *pattern-syntax*))

(defun pattern-white-space? (octets start)
  (has-property? octets start *pattern-white-space*))

(defun prepended-concatenation-mark? (octets start)
  (has-property? octets start *prepended-concatenation-mark*))

(defun quotation-mark? (octets start)
  (has-property? octets start *quotation-mark*))

(defun radical? (octets start)
  (has-property? octets start *radical*))

(defun regional-indicator? (octets start)
  (has-property? octets start *regional-indicator*))

(defun sentence-terminal? (octets start)
  (has-property? octets start *sentence-terminal*))

(defun soft-dotted? (octets start)
  (has-property? octets start *soft-dotted*))

(defun terminal-punctuation? (octets start)
  (has-property? octets start *terminal-punctuation*))

(defun unified-ideograph? (octets start)
  (has-property? octets start *unified-ideograph*))

(defun variation-selector? (octets start)
  (has-property? octets start *variation-selector*))

(defun white-space? (octets start)
  (has-property? octets start *white-space*))
