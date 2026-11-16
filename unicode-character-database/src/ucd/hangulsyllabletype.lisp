;;;; This is "unicode-character-database/src/ucd/hangulsyllabletype.lisp".
;;;;
;;;; It builds the hangul-syllable-type table.

(defpackage #:unicode-character-database.hangul-syllable-type
  (:use #:common-lisp
        #:unicode-character-database)
  
  (:local-nicknames (#:files #:unicode-character-database.files)
                    (#:parser #:unicode-character-database.parser)
                    (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

  (:import-from #:unicode
                #:hangul-syllable-type))

(in-package #:unicode-character-database.hangul-syllable-type)

(defun hangul-syllable-type ()
  (table:construct-property-map (:test 'eql)
    (loop for line in (parser:load-database-file "UCD/HangulSyllableType.txt")
          do (table:add-entry (first line) (parser:parse-keyword (second line))))))

(defun write-hangul-syllable-type ()
  (files:with-table-output-stream (stream (files:input-pathname "UCD/HangulSyllableType.txt") 'hangul-syllable-type)
    (table:write-table (hangul-syllable-type) stream))
  t)
