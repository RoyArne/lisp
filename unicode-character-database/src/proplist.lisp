
(defpackage #:unicode-character-database.proplist
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

  (:import-from #:unicode
                #:ascii-hex-digit
                #:bidi-control
                #:dash
                #:deprecated
                #:diacritic
                #:extender
                #:hex-digit
                #:hyphen
                #:ideographic
                #:id-compat-math-start
                #:id-compat-math-continue
                #:ids-unary-operator
                #:ids-binary-operator
                #:ids-trinary-operator
                #:join-control
                #:logical-order-exception
                #:modifier-combining-mark
                #:noncharacter-code-point
                #:other-alphabetic
                #:other-default-ignorable-code-point
                #:other-grapheme-extend
                #:other-id-continue
                #:other-id-start
                #:other-lowercase
                #:other-math
                #:other-uppercase
                #:pattern-syntax
                #:pattern-white-space
                #:prepended-concatenation-mark
                #:quotation-mark
                #:radical
                #:regional-indicator
                #:sentence-terminal
                #:soft-dotted
                #:terminal-punctuation
                #:unified-ideograph
                #:variation-selector
                #:white-space)
  
  (:documentation
   "The #:unicode-character-database.proplist package creates property tables from
PropList.txt in the Unicode Character Database.

https://www.unicode.org/reports/tr44/#PropList.txt"))

(in-package #:unicode-character-database.proplist)

;;; We need to pull the symbols here from some package.

(defparameter *property-names* '(("ASCII_Hex_Digit" . ascii-hex-digit)
                                 ("Bidi_Control" . bidi-control)
                                 ("Dash" . dash)
                                 ("Deprecated" . deprecated)
                                 ("Diacritic" . diacritic)
                                 ("Extender" . extender)
                                 ("Hex_Digit" . hex-digit)
                                 ("Hyphen" . hyphen)
                                 ("Ideographic" . ideographic)
                                 ("ID_Compat_Math_Start" . id-compat-math-start)
                                 ("ID_Compat_Math_Continue" . id-compat-math-continue)
                                 ("IDS_Unary_Operator" . ids-unary-operator)
                                 ("IDS_Binary_Operator" . ids-binary-operator)
                                 ("IDS_Trinary_Operator" . ids-trinary-operator)
                                 ("Join_Control" . join-control)
                                 ("Logical_Order_Exception" . logical-order-exception)
                                 ("Modifier_Combining_Mark" . modifier-combining-mark)
                                 ("Noncharacter_Code_Point" . noncharacter-code-point)
                                 ("Other_Alphabetic" . other-alphabetic)
                                 ("Other_Default_Ignorable_Code_Point" . other-default-ignorable-code-point)
                                 ("Other_Grapheme_Extend" . other-grapheme-extend)
                                 ("Other_ID_Continue" . other-id-continue)
                                 ("Other_ID_Start" . other-id-start)
                                 ("Other_Lowercase" . other-lowercase)
                                 ("Other_Math" . other-math)
                                 ("Other_Uppercase" . other-uppercase)
                                 ("Pattern_Syntax" . pattern-syntax)
                                 ("Pattern_White_Space" . pattern-white-space)
                                 ("Prepended_Concatenation_Mark" . prepended-concatenation-mark)
                                 ("Quotation_Mark" . quotation-mark)
                                 ("Radical" . radical)
                                 ("Regional_Indicator" . regional-indicator)
                                 ("Sentence_Terminal" . sentence-terminal)
                                 ("Soft_Dotted" . soft-dotted)
                                 ("Terminal_Punctuation" . terminal-punctuation)
                                 ("Unified_Ideograph" . unified-ideograph)
                                 ("Variation_Selector" . variation-selector)
                                 ("White_Space" . white-space))
  "A list of all the property names found in PropList.txt.
Sourced from https://www.unicode.org/reports/tr44/#PropList.txt")

(defparameter *proplist* nil)

(defun parse-proplist (proplist)
  (loop for line in proplist
        collect (list (first line) (or (rest (find (second line) *property-names* :key 'first :test 'string-equal))
                                       (error "There is no property named ~S." (second line))))))

(defun load-proplist! ()
  (setf *proplist* (parse-proplist (load-database-file "PropList.txt")))
  t)

(defun proplist! ()
  (unless *proplist*
    (load-proplist!))
  *proplist*)

(defun list-characters (property-name)
  (mapcar 'first (remove-if (complement #'(lambda (name)
                                            (eql property-name name)))
                            (proplist!)
                            :key 'second)))

(defun make-table (property-name)
  (table:construct-property-table (property-name)
    (loop for code-point in (list-characters property-name)
          do (table:add-entry code-point))))

(defun pattern-white-space ()
  (make-table 'pattern-white-space))

(defun white-space ()
  (make-table 'white-space))
