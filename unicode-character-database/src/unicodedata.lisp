
(defpackage #:unicode-character-database.unicodedata
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

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

(in-package #:unicode-character-database.unicodedata)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *unicodedata-fields*
    '((code-point . 0)
      (name . 1)
      (general-category . 2)
      (canonical-combining-classes . 3)
      (bidirectional-category . 4)
      (decomposition-mapping . 5)
      (decimal-digit-value . 6)
      (digit-value . 7)
      (numeric-value . 8)
      (mirrored . 9)
      (unicode-1.0-name . 10)
      (comment-field . 11)
      (uppercase-mapping . 12)
      (lowercase-mapping . 13)
      (titlecase-mapping . 14)))

  (defun unicodedata-fieldname→number (name)
    (or (rest (find name *unicodedata-fields* :key #'first))
        (error "There is no field named~% ~S~%~
                in *unicodedata-fields*."
               name))))


(defparameter *general-category-names*
  '(;; Letters
    ("LU" "LETTER-UPPERCASE" "LETTER")
    ("LL" "LETTER-LOWERCASE" "LETTER")
    ("LT" "LETTER-TITLECASE" "LETTER")
    ("LM" "LETTER-MODIFIER" "LETTER")
    ("LO" "LETTER-OTHER" "LETTER")
    ;; Marks
    ("MN" "MARK-NON-SPACING" "MARK")
    ("MC" "MARK-SPACING-COMBINING" "MARK")
    ("ME" "MARK-ENCLOSING" "MARK")
    ;; Numbers
    ("ND" "NUMBER-DECIMAL-DIGIT" "NUMBER")
    ("NL" "NUMBER-LETTER" "NUMBER")
    ("NO" "NUMBER-OTHER" "NUMBER")
    ;; Punctuation
    ("PC" "PUNCTUATION-CONNECTOR" "PUNCTUATION")
    ("PD" "PUNCTUATION-DASH" "PUNCTUATION")
    ("PS" "PUNCTUATION-OPEN" "PUNCTUATION")
    ("PE" "PUNCTUATION-CLOSE" "PUNCTUATION")
    ("PI" "PUNCTUATION-INITIAL-QUOTE" "PUNCTUATION")
    ("PF" "PUNCTUATION-FINAL-QUOTE" "PUNCTUATION")
    ("PO" "PUNCTUATION-OTHER" "PUNCTUATION")
    ;; Symbols
    ("SM" "SYMBOL-MATH" "SYMBOL")
    ("SC" "SYMBOL-CURRENCY" "SYMBOL")
    ("SK" "SYMBOL-MODIFIER" "SYMBOL")
    ("SO" "SYMBOL-OTHER" "SYMBOL")
    ;; Separators
    ("ZS" "SEPARATOR-SPACE" "SEPARATOR")
    ("ZL" "SEPARATOR-LINE" "SEPARATOR")
    ("ZP" "SEPARATOR-PARAGRAPH" "SEPARATOR")
    ;; Others
    ("CC" "OTHER-CONTROL" "OTHER")
    ("CF" "OTHER-FORMAT" "OTHER")
    ("CS" "OTHER-SURROGATE" "OTHER")
    ("CO" "OTHER-PRIVATE-USE" "OTHER")
    ("CN" "OTHER-NOT-ASSIGNED" "OTHER")))

(defun general-category-to-keyword (general-category)
  (intern (first general-category) (find-package "KEYWORD")))

(defparameter *unicodedata* '()
  "A list. Every element is a list of fields from UnicodeData.txt:

 0 code point or range
 1 character name. A string.
 2 general category. A list of strings, for example:
   \(\"SM\" \"SYMBOL-MATH\" \"SYMBOL\"\).
 3 canonical combining classes. An integer in the range 0…255.
 4 bidirectional category
 5 character decomposition mapping
 6 decimal digit value
 7 digit value
 8 numeric value
 9 mirrored
10 Unicode 1.0 name
11 10646 comment field
12 uppercase mapping
13 lowercase mapping
14 titlecase mapping

Unicode, Inc. (1999) UnicodeData File Format
  http://www.unicode.org/L2/L1999/UnicodeData.html")

(defun parse-unicodedata (lines)
  ;; This function expects preprocessing from load-unicodedata. Specifically,
  ;; it can't deal with ranges of code points where start and end are defined
  ;; on different lines.
  (labels ((code-point (line)                                        ; 0. A code-point.
             (nth 0 line))
           (name (line)                                              ; 1. A string.
             (with-nth-field (name 1 line)
               (if (string-equal "<control>" name)
                   (case (nth 0 line)
                     (128 "PADDING CHARACTER")
                     (129 "HIGH OCTET PRESET")
                     (132 "INDEX")
                     (153 "SINGLE GRAPHIC CHARACTER INTRODUCER")
                     (otherwise (or (unicode-1.0-name line)
                                    name)))
                   name)))
           
           (general-category (line)                                  ; 2. A list of names (strings).
             (with-nth-field (gc 2 line)
               (or (find gc *general-category-names* :key #'first :test #'string-equal)
                   (error "The general category~%  ~A~%is undefined." gc))))
           
           (canonical-combining-classes (line)                       ; 3. An integer in the range 0-255.
             (parse-integer (nth 3 line)))
           
           (bidirectional-category (line)                            ; 4. A string.
             (nth 4 line))
           
           (decomposition-mapping (line)                             ; 5. A list: a keyword followed by code points.
             (when-nth-field (mapping 5 line)                        ;    Nil if there is no mapping.
               ;; Compatibility mappings are preceded by '<compat>'.
               (if (char= #\< (char mapping 0))
                   (cons :compatibility
                         (parse-sequence (subseq mapping (1+ (position #\> mapping :test #'char=)))))
                   (cons :canonical
                         (parse-sequence mapping)))))
           
           (decimal-digit-value (line)                               ; 6. An integer or nil.
             (when-nth-field (decimal-digit-value 6 line)
               (parse-integer decimal-digit-value)))
           
           (digit-value (line)                                       ; 7. An integer or nil.
             (when-nth-field (digit-value 7 line)
               (parse-integer digit-value)))
           
           (numeric-value (line)                                     ; 8. A number or nil.
             (when-nth-field (numeric-value 8 line)
               (let ((split (position #\/ numeric-value :test #'char=)))
                 (if split
                     (/ (parse-integer numeric-value :start 0 :end split)
                        (parse-integer numeric-value :start (1+ split)))
                     (parse-integer numeric-value)))))
           
           (mirrored (line)                                          ; 9. A boolean.
             (with-nth-field (mirrored 9 line)
               (cond
                 ((char-equal #\Y (char mirrored 0)) t)
                 ((char-equal #\N (char mirrored 0)) nil)
                 (t (error "The value for mirrored~%  ~A~%is not 'Y' or 'N'." mirrored)))))
           
           (unicode-1.0-name (line)                                  ; 10. A string or nil.
             (when-nth-field (name 10 line)
               name))
           
           (comment-field (line)                                     ; 11. A string or nil.
             (when-nth-field (comment 11 line)                       
               comment))
           
           (uppercase-mapping (line)                                 ; 12. A code point or nil.
             (when-nth-field (uppercase-mapping 12 line)
               (parse-integer uppercase-mapping :radix 16)))
           
           (lowercase-mapping (line)                                 ; 13. A code point or nil.
             (when-nth-field (lowercase-mapping 13 line)
               (parse-integer lowercase-mapping :radix 16)))
           
           (titlecase-mapping (line)                                 ; 14. A code point or nil.
             (when-nth-field (titlecase-mapping 14 line)
               (parse-integer titlecase-mapping :radix 16))))
    
    (loop for line in lines
          collect (list (code-point line)
                        (name line)
                        (general-category line)
                        (canonical-combining-classes line)
                        (bidirectional-category line)
                        (decomposition-mapping line)
                        (decimal-digit-value line)
                        (digit-value line)
                        (numeric-value line)
                        (mirrored line)
                        (unicode-1.0-name line)
                        (comment-field line)
                        (uppercase-mapping line)
                        (lowercase-mapping line)
                        (titlecase-mapping line)))))

(defun preprocess-unicodedata (lines)
  ;; The preprocessing merges two lines defining ranges of code points into
  ;; one line.
  ;;
  ;; Some lines are named <XXX, First> and paired with a following <XXX, Last>
  ;; line. These line denote ranges of code points and are replaced with a
  ;; single line defining that code-point: The code point field is replaced with a
  ;; range, the name field is from the first line, but with the ',First' part
  ;; removed. Other fields are kept from the first line.
  (labels ((range-start-p (field)
             (search ", First>" field :test #'string-equal))
           (range-end-p (field)
             (search ", Last" field :test #'string-equal))
           (make-name (field)
             (concatenate 'string (subseq field 0 (search "," field :test #'string=)) ">"))
           (make-line (start-line end-line)
             (cons (code-point:make-range (first start-line)
                                          (first end-line))
                   (cons (make-name (second start-line))
                         (rest (rest start-line))))))
    ;; We remove code points that are in the surrogate range.
    (remove-if #'code-point:in-surrogate-range?
               (loop with start-line = '()
                     for line in lines
                     for name = (nth 1 line)
                     when (range-start-p name) do (setf start-line line)
                     unless start-line collect line
                     when (range-end-p name) collect (make-line start-line line)
                     when (range-end-p name) do (setf start-line '()))
               :key #'first)))

(defun load-unicodedata! ()
  (setf *unicodedata* (parse-unicodedata (preprocess-unicodedata (load-database-file "UnicodeData.txt"))))
  t)

(defun unicodedata! ()
  (unless *unicodedata*
    (load-unicodedata!))
  *unicodedata*)

(defmacro do-unicodedata ((&rest fields) &body body)
  (let ((line (gensym)))
    `(loop for ,line in (unicodedata!)
           do (let (,@(loop for name in fields
                            collect `(,name (nth ,(unicodedata-fieldname→number name) ,line))))
                ,@body))))

(defun character-names ()
  (table:construct-string-map ()
    (do-unicodedata (code-point name)
      (table:add-entry code-point (utf-8:string-to-octets name)))))

(defun general-category ()
  (table:construct-property-map (:test 'eql)
    (do-unicodedata (code-point general-category)
      (table:add-entry code-point (general-category-to-keyword general-category)))))

(defun canonical-combining-classes ()
  (table:construct-property-map (:test 'eql)
    (do-unicodedata (code-point canonical-combining-classes)
      (table:add-entry code-point canonical-combining-classes))))

(defun bidirectional-category ()
  (table:construct-string-map ()
    (do-unicodedata (code-point bidirectional-category)
      (table:add-entry code-point (utf-8:string-to-octets bidirectional-category)))))


;; (defun canonical-decomposition-p (decomposition-mapping)
;;   (eql (first decomposition-mapping) :canonical))

;; (defun compatibility-decomposition-p (decomposition-mapping)
;;   (or (canonical-decomposition-p decomposition-mapping)
;;       (eql (first decomposition-mapping) :compatibility)))

;; (defun full-decomposition-of (vector map)
;;   (reduce #'nconc
;;           (loop for part in (table:property-of vector 0 map)
;;                 collect (or (full-decomposition-of (utf-8:encode-code-points (list part)) map) (list part)))))
  
;; (defun full-decomposition-map (property-map)
;;   (table:construct-interval→octets ()
;;     (table:do-interval→property (code-point decomposition property-map)
;;       (table:add-entry code-point
;;                        (utf-8:encode-code-points (full-decomposition-of (utf-8:encode-code-points (list code-point))
;;                                                                         property-map))))))

;; (defun initial-canonical-decomposition-map ()
;;   (table:construct-interval→property ()
;;     (do-unicodedata (code-point decomposition-mapping)
;;       (when (canonical-decomposition-p decomposition-mapping)
;;         (table:add-entry code-point (rest decomposition-mapping))))))

;; (defun canonical-decomposition-mapping ()
;;   (full-decomposition-map (initial-canonical-decomposition-map)))

;; (defun initial-compatibility-decomposition-map ()
;;   (table:construct-interval→property ()
;;     (do-unicodedata (code-point decomposition-mapping)
;;       (when (compatibility-decomposition-p decomposition-mapping)
;;         (table:add-entry code-point (rest decomposition-mapping))))))

;; (defun compatibility-decomposition-mapping ()
;;   (full-decomposition-map (initial-compatibility-decomposition-map)))


(defun decimal-digit-value ()
  (table:construct-property-map (:test 'eql)
    (do-unicodedata (code-point decimal-digit-value)
      (when decimal-digit-value
        (table:add-entry code-point decimal-digit-value)))))

(defun digit-value ()
  (table:construct-property-map (:test 'eql)
    (do-unicodedata (code-point digit-value)
      (when digit-value
        (table:add-entry code-point digit-value)))))

(defun numeric-value ()
  (table:construct-property-map (:test 'eql)
    (do-unicodedata (code-point numeric-value)
      (when numeric-value
        (table:add-entry code-point numeric-value)))))

(defun mirrored ()
  (table:construct-property-table (:mirrored)
    (do-unicodedata (code-point mirrored)
      (when mirrored
        (table:add-entry code-point)))))

(defun uppercase-mapping ()
  (table:construct-code-point-map ()
    (do-unicodedata (code-point uppercase-mapping)
      (when uppercase-mapping
        (table:add-entry code-point uppercase-mapping)))))

(defun lowercase-mapping ()
  (table:construct-code-point-map ()
    (do-unicodedata (code-point lowercase-mapping)
      (when lowercase-mapping
        (table:add-entry code-point lowercase-mapping)))))

(defun titlecase-mapping ()
  (table:construct-code-point-map ()
    (do-unicodedata (code-point titlecase-mapping)
      (when titlecase-mapping
        (table:add-entry code-point titlecase-mapping)))))

(defun write-unicodedata-tables ()
  (flet ((list-filename/table (name)
           (list (concatenate 'string (string-downcase name) ".lisp")
                 (funcall name))))
    (loop for (name table) in (map 'list #'list-filename/table '(character-names
                                                                 general-category
                                                                 canonical-combining-classes
                                                                 bidirectional-category
                                                                 ;; canonical-decomposition-mapping
                                                                 ;; compatibility-decomposition-mapping
                                                                 decimal-digit-value
                                                                 digit-value
                                                                 numeric-value
                                                                 mirrored
                                                                 uppercase-mapping
                                                                 lowercase-mapping
                                                                 titlecase-mapping))
          do (with-open-file (stream
                              (data-pathname name)
                              :direction :output
                              :if-exists :supersede
                              :if-does-not-exist :create
                              :external-format :utf-8)
               (table:write-table table stream)))
    t))
                          
  
