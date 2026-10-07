
(defpackage #:unicode.utf-8

  (:documentation
   "Implements the UTF-8 encoding of Unicode code points.")
  
  (:use #:common-lisp #:unicode)

  (:local-nicknames (#:code-point #:unicode.code-point)
                    (#:vector #:system.sequence.vector))

  ;; utf-8/type-definitions.lisp
  (:export #:octet #:octets)

  ;; utf-8/encoding-and-decoding.lisp
  (:export #:initial-octet
           #:encoding-length #:encoded-length
           #:octet-range-start #:octet-range-end
           #:encode-code-point #:decode-code-point
           #:push-code-point
           #:in-1-octet-range?
           #:+1-octet-range-start+ #:+1-octet-range-end+
           #:in-2-octet-range?
           #:+2-octet-range-start+ #:+2-octet-range-end+
           #:in-3-octet-range? #:in-low-3-octet-range? #:in-high-3-octet-range?
           #:+3-octet-range-start+ #:+3-octet-range-low-end+ #:+1-octet-range-high-start+ #:+3-octet-range-end+
           #:in-4-octet-range?
           #:+4-octet-range-start+ #:+4-octet-range-end+)

  ;; utf-8/vectors.lisp
  (:export #:make-octets #:make-adjustable-octets
           #:empty? #:*empty*
           #:next #:previous)

  ;; utf-8/comparisons.lisp
  (:export #:compare
           #:octets= #:octets/= #:octets< #:octets> #:octets<= #:octets>=
           #:code-point= #:code-point/= #:code-point< #:code-point> #:code-point<= #:code-point>=)

  ;; utf-8/fnv-1a.lisp
  (:export #:fnv-1a/64
           #:fnv-1a/32)

  ;; utf-8/compatibility.lisp
  (:export #:string-to-octets #:octets-to-string))
