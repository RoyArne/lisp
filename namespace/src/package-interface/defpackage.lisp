;;;; This is "namespace/src/package-interface/defpackage.lisp".

(in-package #:namespace)

(declaim (ftype (function (t)
                          (values))
                check-defpackage-option)

         (ftype (function (common-lisp:symbol list)
                          boolean)
                option-present?)

         (ftype (function (common-lisp:symbol list)
                          list)
                mapcan-option)

         (ftype (function (common-lisp:symbol list)
                          (values t boolean))
                at-most-one-of))

(defun check-defpackage-option (option)
  ;; We need proper syntax checks?
  ;;
  ;; (:local-nicknames (string-designator string-designator)), zero or more
  ;; (:home string-designator), at most one
  ;; (:use string-designator…), zero or more
  ;; (:intern string-designator…), zero or more
  ;; (:shadow string-designator…), zero or more
  ;; (:export string-designator…), zero or more
  ;; (:import-from string-designator string-designator…), zero or more
  ;; (:shadowing-import-from string-designator string-designator…), zero or more
  ;; (:size integer), at most one
  (unless (and (listp option)
               (member (first option)
                       (list :local-nicknames :home :use :intern :shadow :export :import-from :shadowing-import-from :size)))
    (error 'type-error
           :datum option
           :expected-type 'defpackage-option
           :context "while parsing defpackage options."))
  (values))

(defun option-present? (name options)
  (and (find name options :key 'first) t))

(defun mapcan-option (name options)
  ;; Extract and concatenate all values of the name option.
  ;; For example
  ;;
  ;;   (… (:shadow #:a #:b #:c) … (:shadow #:e #:f) …)
  ;;
  ;; becomes
  ;;   (:shadow #:a #:b #:c #:e #:f)
  (mapcan #'(lambda (option)
              (when (eql name (first option))
                (rest option)))
          options))

(defun at-most-one-of (name options)
  ;; Signals an error unless there is exactly one or zero name option
  ;; values.
  ;; Returns two values: the first is the option value (or nil if not
  ;; present), the second is t if a value was present, and nil if not.
  (let ((option (mapcan-option name options)))
    (if (not (cdr option))
        (values (first option) (not (null option)))
        (error 'type-error
	       :datum (cons name option)
	       :expected-type (list name 'defpackage-option)
	       :context "which allows only one value."))))

(declaim (ftype (function (list)
                          (values (or null string) boolean))
                home-option))

(defun home-option (options)
  (multiple-value-bind (home present?)
      (at-most-one-of :home options)
    (values (when home (resolve-string-designator home))
            present?)))



(declaim (ftype (function (list)
                          list)
                use-option intern-option shadow-option export-option))

;;; The :use, :intern, :shadow, and, :export options are all lists of string
;;; designators. More than one of each can appear. Separate occurences of each
;;; can be concatenated into one list.

(defun use-option (options)
  (map 'list 'resolve-string-designator (mapcan-option :use options)))

(defun intern-option (options)
  (map 'list 'resolve-string-designator (mapcan-option :intern options)))

(defun shadow-option (options)
  (map 'list 'resolve-string-designator (mapcan-option :shadow options)))

(defun export-option (options)
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
  (any-import-from-option :import-from options))

(defun shadowing-import-from-options (options)
  (any-import-from-option :shadowing-import-from options))

(defun expand-defpackage-form (name options)
  (let ((package (common-lisp:gensym "PACKAGE"))
	(resolved-name (common-lisp:gensym "NEW-NAME"))
	(home-supplied? (common-lisp:gensym "HOME-SUPPLIED?"))
        (home-option (common-lisp:gensym "HOME-OPTION"))
	(home-package (common-lisp:gensym "HOME"))
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
         ;; in THAT order. If we're working with an existing package, it is
         ;; possible that we have to change its location. Or is it not?
         ;;
         ;; Given NIL as home we must place the package at the top-level. If
         ;; we find a package there, it must also be a top-level package, and
         ;; we don't need to change anything. Except place it first in the
         ;; list. Like make-package, the defpackage should place what it
         ;; defines at the head position in the place it is placed.
         ;;
         ;; Given a package, we have resolved that package to be the new
         ;; packages home. If we find a package there, it may be a peer
         ;; package of home, or in its internal list. If it is in the peer
         ;; list, do we move it?

         (cond
           ((name ,package)
            ;; We're working with a pre-existing package
            (unless (eql ,home-package (home-package ,package))
              ;; Do we just give up? Or is it the users intention to move this
              ;; package? Given that a home package is explicitly specified,
              ;; maybe we should assume an intention to move.
              (remove-package ,package (home-package ,package))
              (add-package ,package ,home-package)))
           (t
            ;; All is well, we're working with a new package. Assign it a name
            ;; and a place in the hierarchy. The package is empty, and we know
            ;; the name doesn't conflict with anything.
            (setf (slot-value ,package 'name) ,resolved-name)
            (add-package ,package ,home-package)))
	 
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
         ;; local nicknames are still missing.
	   
	 ,package))))

(defmacro defpackage (name &rest options)
  (mapc 'check-defpackage-option options)
  (expand-defpackage-form name options))
