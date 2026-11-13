
(defpackage #:unicode
  
  ;; Names used in PropList.txt
  ;; ==========================
  ;;
  ;; The following property names appear in "PropList.txt" in the Unicode
  ;; Character Database.
  ;;
  ;; The names have been lower-cased and underscores replaced by hyphen ('-')
  ;; characters.
  ;;
  ;; See [UAX #44](https://www.unicode.org/reports/tr44/#PropList.txt) for a
  ;; description of the properties.
  (:export #:ascii-hex-digit
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
           #:white-space))
