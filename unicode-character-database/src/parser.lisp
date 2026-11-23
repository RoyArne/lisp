
(defpackage #:unicode-character-database.parser
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:files #:unicode-character-database.files)
                    (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

  (:export #:parse-code-point
           #:parse-range
           #:parse-sequence
           #:parse-code-point-field
           #:code-point-field-to-octets)

  (:export #:parse-symbol-name
           #:parse-keyword
           #:equals-symbol?)

  (:export #:with-nth-field
           #:when-nth-field
           #:with-nth-fields)

  (:export #:filter-lines
           #:distinct-field-values
           #:read-database-stream
           #:load-database-file
           #:defloader
           #:remove-loaded-file))

(in-package #:unicode-character-database.parser)

;;; Code Points
;;; ===========
;;;
;;; · code points are written as four to six hexadecimal digits.
;;;
;;;   examples: "0032", "F0164", and "10FFFD".
;;;
;;; · ranges are written as two code points separated by "..".
;;;
;;;   example: "0032..A0332".
;;;
;;; · sequences are written as two or more code points separated by " ".
;;;
;;;;  example: "0032 00F5 01A9 1166 BD022".

(defun parse-code-point (field &optional (start 0) end)
  "Parse FIELD between START and END as a hecadecimal number."
  (coerce (parse-integer field :start start :end end :radix 16) 'code-point:code-point))

(defun parse-range (field)
  "Parse FIELD as a range of code points in the format
<hexadecimal number>..<hecadecimal number>."
  (let ((end (loop for i from 0 below (length field)
	           while (digit-char-p (char field i) 16)
	           finally (return i))))
    (code-point:make-range (parse-code-point field 0 end)
		           (parse-code-point field (+ end 2)))))

(defun parse-sequence (field)
  "Parse FIELD as a list of space separated hexadecimal numbers."
  (map 'list
       #'parse-code-point
       (split-sequence:split-sequence #\Space field :test #'char= :remove-empty-subseqs t)))

(defun parse-code-point-field (field)
  "Returns either a single code-point, a range, or a list of code-points."
  (cond
    ((search ".." field :test #'string=)
     (parse-range field))
    ((find #\Space field :test #'char=)
     (parse-sequence field))
    (t
     (parse-code-point field))))

(defun code-point-field-to-octets (field)
  "Returns an octet vector corresponding to the code point(s) in field."
  (flet ((encode (code-point)
           (let ((octets (utf-8:make-octets (utf-8:encoded-length code-point))))
             (utf-8:encode-code-point code-point octets 0)
             octets)))
    (etypecase field
      (code-point:code-point (encode field))
      (code-point:range (apply 'concatenate
                               'utf-8:octets
                               (loop for code-point from (code-point:range-start field) upto (code-point:range-end field)
                                     collect (encode code-point))))
       (list (apply 'concatenate 'utf-8:octets (mapcar #'encode field))))))

;;; Keywords and Symbols
;;; ====================

(defun parse-symbol-name (field)
  "Return field as a symbol name: any underscores ('_') are replaced by
hyphens ('-'), converting the result to upper case."
  (string-upcase (substitute #\- #\_ (copy-seq field) :test 'char=)))

(defun parse-keyword (field)
  "Parse field as a keyword."
  (intern (string-upcase field) "KEYWORD"))

(defun equals-symbol? (symbol field)
  "True if the symbol name of symbol equals field as returned by
parse-symbol-name."
  (string= (symbol-name symbol) (parse-symbol-name field)))

;;; Database Lines
;;; ==============
;;;
;;; · each database line deals with one code point.
;;;
;;; · each line has a number of fields, optionally followed by a comment.
;;;
;;; · fields are separated by ";" (which does not appear inside fields).
;;;
;;; · comments begin with "#" (which does not appear inside fields).
;;;
;;; · the first field is usually a code point (or range/sequence of code
;;;   points).

(defun trim-spaces (field)
  (string-trim '(#\Space) field))

(defun strip-comment (line)
  (first (split-sequence:split-sequence #\# line :test #'char=)))

(defun fieldsp (fields)
  "Returns true if the fields list is an actual list of fields.

Returns nil if there is zero fields in the list, or only one field that begins
with the '@' character."
  (or (> (length fields) 1)
      (and (plusp (length (first fields)))
           (char/= #\@ (char (first fields) 0)))))

(defun fields (line)
  "Return a list of fields."
  (map 'list #'trim-spaces (split-sequence:split-sequence #\; (strip-comment line) :test #'char=)))

(defun @linep (line)
  (when (< 0 (length line))
    (char= #\@ (char line 0))))
    
(defun read-database-line (stream &optional (eof-error-p t) eof-value)
  "Read one line from stream and return a list of fields. The first field is
always a code point field. Note that the code point field is parsed by means
of parse-code-point-field."
  (loop for line = (read-line stream eof-error-p :eof)
        when (eql line :eof)
        do (return eof-value)
        when (@linep line)
        do (return (trim-spaces (strip-comment line)))
        do (let ((fields (fields line)))
             (when (fieldsp fields)
               (return (cons (parse-code-point-field (first fields)) (rest fields)))))))

(defmacro with-nth-field ((field n line) &body body)
  `(let ((,field (nth ,n ,line)))
     ,@body))

(defmacro when-nth-field ((field n line) &body body)
  "Return BODY when the Nth FIELD of LINE is longer than zero."
  `(with-nth-field (,field ,n ,line)
     (when (plusp (length ,field))
       ,@body)))

(defmacro with-nth-fields (list (&rest fields) &body body)
  "Given a list and zero or more fields in the form \(name n\), bind the nth
element to the name variable."
  `(let (,@(loop for (name n) in fields
                 collect `(,name (nth ,n ,list))))
     ,@body))

;;; Parsing Database Files
;;; ======================
;;;
;;; TODO: We need a way to sort lines by code point field.

(declaim (ftype (function (integer list &key (:predicate (or function symbol)) (:key (or function symbol)))
                          list)
                filter-lines)
         
         (ftype (function ((or integer symbol function) list &key (:test (or symbol function)) (:key (or symbol function)))
                          list)
                distinct-field-values))

(defun filter-lines (n lines &key (predicate 'string=) (key 'identity))
  "Return a list of those lines where predicate is true for the nth field. If key
is given then it is applied to the nth field before it is passed to the
predicate function."
  (loop for line in lines
        when (funcall predicate (funcall key (nth n line)))
        collect line))

(defun distinct-field-values (field lines &key (test 'eql) (key 'identity))
  "Returns a list of distinct values for the given field. The field may be designated by:
  · an integer n: the nth field is used.
  · a symbol or a function: the function is applied to a list of field and its
    return value is used."
  (loop with distinct-values = '()
        for line in lines
        do (pushnew (etypecase field
                      (symbol (funcall field line))
                      (function (funcall field line))
                      (integer (nth field line)))
                    distinct-values
                    :test test
                    :key key)
        finally (return distinct-values)))
                     
(declaim (ftype (function (stream)
                          list)
                read-database-stream)
         
         (ftype (function (string) list)
                load-database-file))

(defun read-database-stream (stream)
  "Return a list of lines where each line is a list of fields. The first field is
a code point field parsed by means of parse-code-point-field. The remaining
fields are strings."
  (loop for line = (read-database-line stream nil)
        while line
        collect line))

(defun load-database-file (filespec)
  "Read the FILESPEC file and return a list of database lines. Each line is a list
of fields, beginning with a code point field. Note that the code point field
is parsed by means of parse-code-point-field."
  (with-open-file (stream
                   (files:input-pathname filespec)
                   :direction :input
                   :element-type 'character
                   :external-format :utf-8)
    (read-database-stream stream)))

(defparameter *files* (make-hash-table :test 'equal))

(defmacro defloader (result-function-name filespec &optional (parser-function nil parser-function-supplied?))
  "Defines a function named result-function-name that stores and returns the
filespec database. The parser-function, if supplied, is applied to the database before
it is returned."
  `(defun ,result-function-name ()
     (or (gethash ,filespec *files*)
         (setf (gethash ,filespec *files*)
               (if ,parser-function-supplied?
                   (funcall ,parser-function (load-database-file ,filespec))
                   (load-database-file ,filespec))))))

(defun remove-loaded-file (filespec)
  "Remove filespec from *files*."
  (remhash filespec *files*))
