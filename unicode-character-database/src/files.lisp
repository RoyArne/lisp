;;;; This is "src/files.lisp".

(defpackage #:unicode-character-database.files
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:output-files #:unicode.files)
                    (#:table #:unicode.table))

  (:export #:data-directory-pathname
           #:input-pathname
           #:output-pathname
           #:with-table-output-stream
           #:write-tables))

(in-package #:unicode-character-database.files)

(defparameter *data-directory-path* "../data/")

(defun data-directory-pathname ()
  (asdf:system-relative-pathname (asdf:find-system "unicode-character-database") *data-directory-path*))

(defun input-pathname (filespec)
  (merge-pathnames filespec (data-directory-pathname)))

(defun path-from-data-directory (pathname)
  (let ((result ""))
    (loop for directory in (subseq (pathname-directory pathname) (length (pathname-directory (data-directory-pathname))))
          do (setf result (concatenate 'string result directory "/")))
    result))

(defun output-directory/filename (pathname table-name)
  "(output-filename \"…/UCD/PropList.txt\" 'table-name)
→
\"PropList/table-name.lisp\""
  
  (concatenate 'string (path-from-data-directory pathname) (pathname-name pathname) "/" (string-downcase table-name) ".lisp"))

(defun output-pathname (pathname table-name)
  "Return the pathname for TABLE-NAME given PATHNAME.

PATHNAME is the pathname returned by (INPUT-PATHNAME filespec).
TABLE-NAME is a symbol naming the table."
  (output-files:table-pathname (output-directory/filename pathname table-name)))

(defmacro with-table-output-stream ((stream input-pathname table-name) &body body)
  `(with-open-file (,stream
                    (output-pathname ,input-pathname ,table-name)
                    :direction :output
                    :if-exists :supersede
                    :if-does-not-exist :create
                    :external-format :utf-8)
     ,@body))

(defun write-tables (input-pathname names tables)
  (loop for name in names
        for table in tables
        do (with-table-output-stream (stream input-pathname name)
             (table:write-table table stream)))
  t)
