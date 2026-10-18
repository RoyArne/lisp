;;;; This is "namespace/src/package-interface/defpackage.lisp".

(in-package #:namespace)

(declaim (ftype (function (common-lisp:symbol list)
                          boolean)
                option-present?))

(defun option-present? (name options)
  (and (find name options :key 'first) t))

(declaim (inline option-name option-values)

         (type list *defpackage-option-names*)

         (ftype (function (list)
                          common-lisp:symbol)
                option-name)

         (ftype (function (common-lisp:symbol list)
                          boolean)
                named-option?)

         (ftype (function (list)
                          list)
                option-values)

         (ftype (function (t)
                          (values))
                check-defpackage-option))

(defparameter *defpackage-option-names*
  '(:local-nicknames :home :use :intern :shadow :export :import-from :shadowing-import-from :size))

(defun option-name (option)
  (first option))

(defun named-option? (name option)
  (eql name (option-name option)))

(defun option-values (option)
  (rest option))

(defun check-defpackage-option (option)
  (unless (and (listp option)
               ;; we don't use option-name because the result might not be a symbol.
               (member (first option) *defpackage-option-names*))
    (error 'type-error
           :datum option
           :expected-type 'defpackage-option
           :context "while parsing defpackage options."))
  (values))


(declaim (ftype (function (common-lisp:symbol list)
                          list)
                mapcan-option))

(defun mapcan-option (name options)
  ;; Extract and concatenate all values of the name option.
  ;; For example
  ;;
  ;;   (… (:shadow #:a #:b #:c) … (:shadow #:e #:f) …)
  ;;
  ;; becomes
  ;;   (:shadow #:a #:b #:c #:e #:f)
  (mapcan #'(lambda (option)
              (when (named-option? name option)
                (option-values option)))
          options))


(declaim (ftype (function (common-lisp:symbol list)
                          (values t boolean))
                at-most-one-of)

         (ftype (function (list)
                          (values (or null string) boolean))
                home-option)

         (ftype (function (list)
                          (values (or null integer) boolean))
                size-option))

(defun at-most-one-of (name options)
  ;; Signals an error unless there is exactly one or zero name option
  ;; values.
  ;; Returns two values: the first is the option value (or nil if not
  ;; present), the second is t if a value was present, and nil if not.
  (let ((option (mapcan-option name options)))
    (if (not (cdr option))
        (values (option-name option) (not (null option)))
        (error 'type-error
	       :datum (cons name option)
	       :expected-type (list name 'defpackage-option)
	       :context (ecase name
                          (:home "which allows exactly one string-designator value.")
                          (:size "which allows exactly one integer value."))))))

(defun home-option (options)
  ;; (:home string-designator), at most one
  (multiple-value-bind (home present?)
      (at-most-one-of :home options)
    (values (when home (resolve-string-designator home))
            present?)))

(defun size-option (options)
  ;; (:size integer), at most one
  (multiple-value-bind (size present?)
      (at-most-one-of :size options)
    (when present?
      (unless (integerp size)
        (error 'type-error
               :datum (list :size size)
               :expected-type (list :size 'defpackage-option)
               :context "which allows exactly one integer value.")))
    (values size present?)))


(declaim (ftype (function (list)
                          list)
                use-option intern-option shadow-option export-option))

;;; The :use, :intern, :shadow, and, :export options are all lists of string
;;; designators. More than one of each can appear. Separate occurences of each
;;; can be concatenated into one list.

(defun use-option (options)
  ;; (:use string-designator…), zero or more
  (map 'list 'resolve-string-designator (mapcan-option :use options)))

(defun intern-option (options)
  ;; (:intern string-designator…), zero or more
  (map 'list 'resolve-string-designator (mapcan-option :intern options)))

(defun shadow-option (options)
  ;; (:shadow string-designator…), zero or more
  (map 'list 'resolve-string-designator (mapcan-option :shadow options)))

(defun export-option (options)
  ;; (:export string-designator…), zero or more
  (map 'list 'resolve-string-designator (mapcan-option :export options)))


(declaim  (ftype (function (common-lisp:symbol list)
                           list)
                 any-import-from-option)
          
          (ftype (function (list)
                           list)
                 import-from-options shadowing-import-from-options))

;;; The :import-from and :shadowing-import-from options are both lists of
;;; string designators. The first designator names the package we are
;;; importing from, remaining strings names the symbols. Separate occurences
;;; of each are never concatenated (even if they name the same package).

(defun any-import-from-option (name options)
  (loop for option in options
        when (eql name (first option))
        collect (map 'list 'resolve-string-designator (rest option))))

(defun import-from-options (options)
  ;; (:import-from string-designator string-designator…), zero or more
  (any-import-from-option :import-from options))

(defun shadowing-import-from-options (options)
  ;; (:shadowing-import-from string-designator string-designator…), zero or more
  (any-import-from-option :shadowing-import-from options))

(declaim (ftype (function (list)
                          list)
                local-nicknames-options))

(defun local-nicknames-options (options)
  ;; (:local-nicknames (string-designator string-designator)), zero or more
  (loop for nicknames in (mapcan-option :local-nicknames options)
        collect (if (= 2 (length nicknames))
                    (list (resolve-string-designator (first nicknames))
                          (resolve-string-designator (second nicknames)))
                    (error 'type-error
                           :datum nicknames
                           :expected-type (list :local-nicknames 'defpackage-option)
                           :context "which must be a list of two string designators."))))


(defun expand-defpackage-form (name options)
  (let ((package (common-lisp:gensym "PACKAGE"))
	(resolved-name (common-lisp:gensym "NEW-NAME"))
	(home-supplied? (common-lisp:gensym "HOME-SUPPLIED?"))
        (home-option (common-lisp:gensym "HOME-OPTION"))
	(home-package (common-lisp:gensym "HOME"))
        (nicknames (common-lisp:gensym "NICKNAMES"))
	(string (common-lisp:gensym "STRING"))
	(strings (common-lisp:gensym "STRINGS")))
    `(eval-when (:compile-toplevel :load-toplevel :execute)

       ;; Re. Home Resolution: omitted means make a peer package of the
       ;;                      current package,
       ;;                      given package means use it as the home package,
       ;;                      given nil means make a top level package.
       (let* ((,resolved-name ,(resolve-string-designator name))
              (,home-package (multiple-value-bind (,home-option ,home-supplied?)
                                 ,(home-option options)
                               (if ,home-supplied?
                                   (resolve-home-designator ,home-option)
                                   (home-package *package*))))
              (,package (or (find-conflicting-package ,resolved-name ,home-package)
                            (make-instance 'package))))

         ;; We need to set the packages name, and place it in the hierarchy,
         ;; in THAT order.
         (cond
           ((name ,package)
            ;; We're working with a pre-existing package.
            ;;
            ;; CONSIDER: Should we ensure that it is the first package in it's
            ;;           location? New packages are placed there, one might
            ;;           expect defpackage to do the same even with a
            ;;           pre-existing package.
            (unless (eql ,home-package (home-package ,package))
              ;; We assume the intent is to move the package because a new
              ;; home was specified.
              (remove-package ,package (home-package ,package))
              (add-package ,package ,home-package)))
           (t
            ;; All is well, we're working with a new package. Assign it a name
            ;; and a place in the hierarchy. The package is empty, and we know
            ;; the name doesn't conflict with anything.
            (setf (slot-value ,package 'name) ,resolved-name)
            (add-package ,package ,home-package)))

         ;; Next we resolve the local nicknames.
         (loop for ,nicknames in ,(local-nicknames-options options)
               do (add-package-local-nickname (first ,nicknames)
                                              (resolve-package-designator (second ,nicknames))
                                              ,package))
	 
	 ;; The order in which the remaining options appear in a defpackage
	 ;; form is irrelevant. The order in which they are executed is as
	 ;; follows:

	 ;; 1. :shadow and :shadowing-import-from.
         (shadow ',(shadow-option options) ,package)
         (loop for ,strings in ',(shadowing-import-from-options options)
               do (shadowing-import (rest ,strings) (first ,strings)))
	 
	 ;; 2. :use.
         (use-package ',(use-option options) ,package)

	 ;; 3. :import-from and :intern.
         (loop for ,strings in ',(import-from-options options)
               do (import (rest ,strings) (first ,strings)))
         (loop for ,string in ',(intern-option options)
               do (intern ,string ,package))
         
	 ;; 4. :export.
         (export (loop for ,string in ',(export-option options)
                       collect (or (find-symbol ,string ,package)
                                   (intern ,string ,package)))
                 ,package)

	 ;; We ignore :size and :documentation for now.
	   
	 ,package))))

(defmacro defpackage (name &rest options)
  (mapc 'check-defpackage-option options)
  (expand-defpackage-form name options))
