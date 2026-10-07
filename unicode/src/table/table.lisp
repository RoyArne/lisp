
(defpackage #:unicode.table
  (:use #:common-lisp #:unicode)

  (:local-nicknames (#:code-point #:unicode.code-point)
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

  ;; "src/table/unicodedata.lisp"
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
           #:compatibility-decomposition-of))
