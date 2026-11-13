
(defpackage #:unicode.configuration
  (:use #:common-lisp)

  (:export #:data-directory-pathname
           #:data-pathname
           #:ensure-data-directory-exists))

(in-package #:unicode.configuration)

(defun data-directory-pathname ()
  "Return the pathname to the 'unicode/data/' directory."
  (asdf:system-relative-pathname (asdf:find-system "unicode") "../data/"))

(defun data-pathname (filename &key directory)
  "Return the pathname to FILENAME in the 'unicode/data/' directory. If the
directory argument is supplied then return the pathname to FILENAME in that
subdirectory of the 'unicode/data/ directory."
  (merge-pathnames filename (if directory
                                (uiop:ensure-directory-pathname (merge-pathnames directory (data-directory-pathname)))
                                (data-directory-pathname))))

(defun ensure-data-directory-exists (&optional subdirectory)
  "Ensure that the 'unicode/data/' directory exists. If the optional SUBDIRECTORY
argument is provided then we also ensure that it exists too."
  (uiop:ensure-all-directories-exist (remove-if 'null (list (data-directory-pathname)
                                                            (when subdirectory
                                                              (uiop:ensure-directory-pathname (data-pathname subdirectory)))))))
