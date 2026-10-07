
(defpackage #:unicode-character-database.parser
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

  (:export #:parse-code-point
           #:parse-range
           #:parse-sequence
           #:parse-code-point-field)

  (:export #:with-nth-field
           #:when-nth-field
           #:with-nth-fields)

  (:export #:load-database-file))

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

(defun read-database-line (stream &optional (eof-error-p t) eof-value)
  "Read one line from stream and return a list of fields. The first field is
always a code point field. Note that the code point field is parsed by means
of parse-code-point-field."
  (loop for line = (read-line stream eof-error-p :eof)
        when (eql line :eof)
        do (return eof-value)
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

(declaim (ftype (function (string) list)
                load-database-file))

(defun load-database-file (filename)
  "Read the NAME file and return a list of database lines. Each line is a list
of fields, beginning with a code point field. Note that the code point field
is parsed by means of parse-code-point-field."
  (with-open-file (stream
                   (make-unicode-character-database-pathname filename)
                   :direction :input
                   :element-type 'character
                   :external-format :utf-8)
    (loop for line = (read-database-line stream nil)
          while line
          collect line)))
