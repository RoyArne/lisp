
(defpackage #:unicode

  ;; UCD/UnicodeData.txt
  ;; ===================
  ;;
  ;; TODO: We want to export the general category names from here. We will
  ;;       have to update the generator to make symbols in the unicode
  ;;       package, currently it makes keywords.
  (:export #:mirrored?
           #:general-category-of
           #:decimal-digit-value-of
           #:digit-value-of
           #:numeric-value-of
           #:uppercase-of
           #:lowercase-of
           #:titlecase-of
           #:character-name-of
           #:combining-class-of
           #:bidirectional-category-of
           #:canonical-decomposition-of
           #:compatibility-decomposition-of)

  ;; UCD/PropList.txt
  ;; ================
  ;;
  ;; The following property names appear in "PropList.txt" in the Unicode
  ;; Character Database.
  ;;
  ;; The names have been lower-cased and underscores replaced by hyphen ('-')
  ;; characters.
  ;;
  ;; See [UAX #44](https://www.unicode.org/reports/tr44/#PropList.txt) for a
  ;; description of the properties.
  (:export #:ascii-hex-digit #:ascii-hex-digit?
           #:bidi-control #:bidi-control?
           #:dash #:dash?
           #:deprecated #:deprecated?
           #:diacritic #:diacritic?
           #:extender #:extender?
           #:hex-digit #:hex-digit?
           #:hyphen #:hyphen?
           #:ideographic #:ideographic?
           #:id-compat-math-start #:id-compat-math-start?
           #:id-compat-math-continue #:id-compat-math-continue?
           #:ids-unary-operator #:ids-unary-operator?
           #:ids-binary-operator #:ids-binary-operator?
           #:ids-trinary-operator #:ids-trinary-operator?
           #:join-control #:join-control?
           #:logical-order-exception #:logical-order-exception?
           #:modifier-combining-mark #:modifier-combining-mark?
           #:noncharacter-code-point #:noncharacter-code-point?
           #:other-alphabetic #:other-alphabetic?
           #:other-default-ignorable-code-point #:other-default-ignorable-code-point?
           #:other-grapheme-extend #:other-grapheme-extend?
           #:other-id-continue #:other-id-continue?
           #:other-id-start #:other-id-start?
           #:other-lowercase #:other-lowercase?
           #:other-math #:other-math?
           #:other-uppercase #:other-uppercase?
           #:pattern-syntax #:pattern-syntax?
           #:pattern-white-space #:pattern-white-space?
           #:prepended-concatenation-mark #:prepended-concatenation-mark?
           #:quotation-mark #:quotation-mark?
           #:radical #:radical?
           #:regional-indicator #:regional-indicator?
           #:sentence-terminal #:sentence-terminal?
           #:soft-dotted #:soft-dotted?
           #:terminal-punctuation #:terminal-punctuation?
           #:unified-ideograph #:unified-ideograph?
           #:variation-selector #:variation-selector?
           #:white-space #:white-space?))
