(defpackage #:unicode-character-database.derivednormalizationprops
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:files #:unicode-character-database.files)
                    (#:parser #:unicode-character-database.parser)
                    (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

  (:export #:derivednormalizationprops!
           #:full-composition-exclusions))

(in-package #:unicode-character-database.derivednormalizationprops)

(defparameter *derivednormalizationprops* nil)

(defun load-derivednormalizationprops ()
  (setf *derivednormalizationprops* (parser:load-database-file "UCD/DerivedNormalizationProps.txt"))
  t)

(defun derivednormalizationprops! ()
  (unless *derivednormalizationprops*
    (load-derivednormalizationprops))
  *derivednormalizationprops*)

(defun full-composition-exclusions ()
  (loop for line in (derivednormalizationprops!)
        when (string-equal "Full_Composition_Exclusion" (second line))
        collect (first line)))
