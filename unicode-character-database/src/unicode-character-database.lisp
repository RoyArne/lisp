
(defpackage #:unicode-character-database
  (:use #:common-lisp)

  ;; "src/files.lisp"
  (:export #:data-directory-pathname
           #:input-pathname
           #:output-pathname
           #:with-table-output-stream)

  ;; "src/parser.lisp"
  (:export #:read-database-stream
           #:load-database-file)

  ;; "src/unicodedata.lisp"
  (:export #:write-unicodedata-tables)

  ;; "src/proplist.lisp"
  (:export #:proplist!
           #:write-proplist-tables)

  ;; src/common-lisp-standard-characters.lisp
  (:export #:write-common-lisp-tables))
