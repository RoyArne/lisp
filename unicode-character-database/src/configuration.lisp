
(defpackage #:unicode-character-database.configuration
  (:use #:common-lisp
        #:unicode-character-database)
  
  (:export #:make-unicode-character-database-pathname)

  (:export #:data-pathname))

(in-package #:unicode-character-database.configuration)

(defun unicode-character-database-directory-pathname ()
  (asdf:system-relative-pathname (asdf:find-system "unicode-character-database") "../data/UCD/"))

(defun make-unicode-character-database-pathname (filename)
  (merge-pathnames filename (unicode-character-database-directory-pathname)))
