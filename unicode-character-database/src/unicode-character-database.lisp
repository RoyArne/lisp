
(defpackage #:unicode-character-database
  (:use #:common-lisp)

  (:import-from #:unicode.configuration
                #:data-pathname)

  ;; From the #:unicode.configuration package in the unicode system
  (:export #:data-pathname)

  ;; "src/configuration.lisp"
  (:export #:make-unicode-character-database-pathname)

  ;; "src/parser.lisp"
  (:export #:parse-code-point
           #:parse-range
           #:parse-sequence
           #:parse-code-point-field)

  ;; "src/parser.lisp"
  (:export #:with-nth-field
           #:when-nth-field
           #:with-nth-fields)

  ;; "src/parser.lisp"
  (:export #:load-database-file)

  (:export #:unicodedata!
           #:character-names
           #:general-category
           #:canonical-combining-classes
           #:bidirectional-category
           #:decimal-digit-value
           #:digit-value
           #:numeric-value
           #:mirrored
           #:uppercase-mapping
           #:lowercase-mapping
           #:titlecase-mapping
           #:write-unicodedata-tables))
