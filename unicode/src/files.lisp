
(defpackage #:unicode.files
  (:use #:common-lisp)

  (:export #:data-directory-pathname
           #:table-pathname))

(in-package #:unicode.files)

(defparameter *data-directory-path* "../data/")

(defun data-directory-pathname ()
  "Return the pathname to the 'unicode/data/' directory."
  (asdf:system-relative-pathname (asdf:find-system "unicode") *data-directory-path*))

(defun table-pathname (filespec)
  "Return the pathname for FILESPEC in the data directory."
  (merge-pathnames filespec (data-directory-pathname)))
