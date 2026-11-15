
(defpackage #:unicode.table
  (:use #:common-lisp #:unicode)

  (:local-nicknames (#:files #:unicode.files)
                    (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:vector #:system.sequence.vector))

  ;; "src/table/type-definitions.lisp"
  (:export #:property-table
           #:property-map
           #:code-point-map
           #:string-map)

  ;; "src/table/construction.lisp"
  (:export #:add-entry
           #:construct-property-table
           #:construct-property-map
           #:construct-code-point-map
           #:construct-string-map)
  
  ;; "src/table/lookup.lisp"
  (:export #:has-property?
           #:property-mapping-of
           #:code-point-mapping-of
           #:string-mapping-of)

  ;; "src/table/stream.lisp"
  (:export #:write-table #:read-table
           #:write-property-table #:read-property-table
           #:write-property-map #:read-property-map
           #:write-code-point-map #:read-code-point-map
           #:write-string-map #:read-string-map)

  ;; "src/table/unicodedata.lisp"; the symbols are external in the #:unicode package
  (:import-from #:unicode
                #:mirrored?
                #:general-category-of
                #:decimal-digit-value-of
                #:digit-value-of
                #:numeric-value-of
                #:uppercase-of
                #:lowercase-of
                #:titlecase-of
                #:character-name-of
                #:canonical-combining-class-of
                #:bidirectional-category-of
                #:canonical-decomposition-of
                #:compatibility-decomposition-of)

  ;; "src/table/common-lisp-standard-characters.lisp"
  (:export #:common-lisp-syntax-type-of
           #:common-lisp-trait-of)

  ;; "src/table/proplist.lisp"; the symbols are external in the #:unicode package
  (:import-from #:unicode
                #:ascii-hex-digit #:ascii-hex-digit?
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
