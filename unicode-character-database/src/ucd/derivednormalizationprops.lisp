(defpackage #:unicode-character-database.derivednormalizationprops
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:parser #:unicode-character-database.parser))

  (:export #:derivednormalizationprops!
           #:full-composition-exclusions)

  (:documentation
   "The #:unicode-character-database.derivednormalizationprops is only used to
provide a list of code points that have the Full_Composition_Exclusion
property. It is returned by the full-composition-exclusion function.

The derivednormalizationprops! function returns a list of all the lines in
UCD/DerivedNormalizationProps.txt.

See (Table 9. Property Table,
DerivedNormalizationProps.txt)[https://www.unicode.org/reports/tr44/#DerivedNormalizationProps.txt]
for a description of the named properties.."))

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
