
(defpackage #:unicode-character-database.configuration
  (:use #:common-lisp
        #:unicode-character-database)

  (:export #:unicode-character-database-directory-pathname
           #:make-unicode-character-database-pathname
           #:make-table-filename)
  
  (:import-from #:unicode.configuration
                #:data-pathname
                #:ensure-data-directory-exists)

  (:export #:data-pathname
           #:ensure-data-directory-exists)

  (:documentation
   "The #:unicode-character-database.configuration exports functionality to locate
files in the Unicode Character Database:

· unicode-character-database-directory-pathname
· make-unicode-character-database-pathname
· make-table-filename

 It also exports functions to locate output files in the unicode system:

· data-pathname"))

(in-package #:unicode-character-database.configuration)

(defun unicode-character-database-directory-pathname ()
  "Return the pathname to the Unicode Character Database directory which contains
a copy of https://www.unicode.org/Public/UCD/latest/ucd/."
  (asdf:system-relative-pathname (asdf:find-system "unicode-character-database") "../data/UCD/"))

(defun make-unicode-character-database-pathname (filespec)
  "Return the pathname to FILESPEC in the Unicode Character Database"
  (merge-pathnames filespec (unicode-character-database-directory-pathname)))

(defun make-table-filename (name)
  "Return '<name>.lisp' where name has been lower-cased."
  (concatenate 'string (string-downcase name) ".lisp"))
