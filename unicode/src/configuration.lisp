
(defpackage #:unicode.configuration
  (:use #:common-lisp)

  (:export #:data-directory-pathname
           #:data-pathname))

(in-package #:unicode.configuration)

(defun data-directory-pathname ()
  (asdf:system-relative-pathname (asdf:find-system "unicode") "../data/"))

(defun data-pathname (filename)
  (merge-pathnames filename (data-directory-pathname)))
