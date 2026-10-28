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
                          boolean)
                home-option?
                size-option?)

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
        (values (first option) (not (null option)))
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

(defun home-option? (options)
  (nth-value 1 (home-option options)))

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

(defun size-option? (options)
  (nth-value 1 (size-option options)))


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

(defmacro execute-import-option (function import-options importing-package)
  (let ((from-package (common-lisp:gensym "IMPORT-FROM"))
        (string (common-lisp:gensym "STRING"))
        (strings (common-lisp:gensym "STRINGS"))
        (symbol (common-lisp:gensym "SYMBOL"))
        (status (common-lisp:gensym "STATUS")))
    `(loop for ,strings in ,import-options
           do (let ((,from-package (resolve-package-designator (first ,strings))))
                (,function (loop for ,string in (rest ,strings)
                                 collect (multiple-value-bind (,symbol ,status)
                                             (find-symbol ,string ,from-package)
                                           (if (null ,status)
                                               (error 'symbol-is-not-accessible
                                                      :symbol ,string
                                                      :package ,from-package
                                                      :context ,importing-package)
                                               ,symbol)))
                           ,importing-package)))))

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
	(home-package (common-lisp:gensym "HOME-PACKAGE"))
        (nicknames (common-lisp:gensym "NICKNAMES"))
	(string (common-lisp:gensym "STRING")))
    `(eval-when (:compile-toplevel :load-toplevel :execute)

       (let* ((,resolved-name ,(resolve-string-designator name))
              (,home-package (resolve-home-designator ,(if (home-option? options)
                                                           (home-option options)        ; supplied, use the supplied value
                                                           '(home-package *package*)))) ; not supplied, home of *package*
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

         ;; Next we resolve the local nicknames. We want the nicknames
         ;; available for shadowing-import, use and import-from below.
         (loop for ,nicknames in ',(local-nicknames-options options)
               do (add-package-local-nickname (first ,nicknames)
                                              (resolve-package-designator (second ,nicknames))
                                              ,package))
	 
	 ;; The remaining options must be executed in the following order:

	 ;; 1. :shadow and :shadowing-import-from.
         (shadow ',(shadow-option options) ,package)
         (execute-import-option shadowing-import ',(shadowing-import-from-options options) ,package)
	 
	 ;; 2. :use.
         (use-package ',(use-option options) ,package)

	 ;; 3. :import-from and :intern.
         (execute-import-option import ',(import-from-options options) ,package)
         (loop for ,string in ',(intern-option options)
               do (intern ,string ,package))
         
	 ;; 4. :export.
         (export (loop for ,string in ',(export-option options)
                       collect (or (find-symbol ,string ,package)
                                   (intern ,string ,package)))
                 ,package)

	 ;; We ignore :size and :documentation for now.
	   
	 ,package))))
    

;; defpackage defined-package-name [[option]] => package

;; option::= (:nicknames nickname*)* |  
;;           (:documentation string) |  
;;           (:use package-name*)* |  
;;           (:shadow {symbol-name}*)* |  
;;           (:shadowing-import-from package-name {symbol-name}*)* |  
;;           (:import-from package-name {symbol-name}*)* |  
;;           (:export {symbol-name}*)* |  
;;           (:intern {symbol-name}*)* |  
;;           (:size integer) 

(defmacro defpackage (name &rest options)
  "Syntax:
\(defpackage name &rest options\) → package

Arguments and Values:
name—a string designator.
package—a package object named package-name.

Description:
Creates a package named name and returns it. If name refers to an existing
package, that package is returned. If the new definition differs from the
current state of that package, the existing package is modified to reflect the
new definition.

Option Arguments:
string—a string.
package-name—a string designator.
symbol-name—a string designator.

\(:documentation string\)

    At most one :documentation option can appear. Its argument is a string
    that is attached as the packages documentation string.

\(:use package-name*\)

    Zero or more :use options can appear, each naming zero or more
    packages. The new package will inherit symbols from each named package as
    if by use-package.

\(:shadow symbol-name*\)

    Zero or more :shadow options can appear, each naming zero or more
    symbols. Each named symbol is created and added to the packages list of
    shadowing symbols as if by shadow.

\(:shadowing-import-from package-name symbol-name*\)

    Zero or more :shadowing-import-from options can appear. If the option
    names anything, it must be a package followed by zero or more symbols. The
    named symbols are imported from the named package as if by
    shadowing-import.

\(:import-from package-name symbol-name*\)

    Zero or more :import-from options can appear. If the option names
    anything, it must be a package followed by zero or more symbols. The named
    symbols are imported from the named package as if by import.

\(:export symbol-name*\)

    Zero or more :export options can appear, each naming zero or more
    symbols. Each named symbol is added to the packages list of external
    symbols.

    The :export option can interact with the :shadowing-import-from and
    :import-from options such that imported symbols are used rather than new
    symbols being created. If a named symbol is inherited (through the
    :use-package option), the named symbol is imported and then exported from
    the package being defined.

    The exported symbols are added to the new packages external symbols.

\(:intern symbol-name*\)

    Zero or more :import options can appear, each naming zero or more
    symbols. The named symbols are found or created in the new package. The
    :intern option interacts with the :use option such that inherited symbols
    can be used rather than new ones created.

The order in which the options appear in a defpackage form is irrelevant. The
order in which they are executed is as follows:

1. :home.
2. :local-nicknames
3. :shadow and :shadowing-import-from.
4. :use.
5. :import-from and :intern.
6. :export.

The new package is placed in its home first, because that establishes which
packages are accessible to the :local-nicknames option. Local nicknames are
next since they may be referenced by the :shadowing-import-from, :import-from,
and :use options.

We execute :shadow and :shadowing-import-from next because they might be
necessary to block name conflicts from the :use option. Following shadows we
execute the :use option, so that :intern and :export can refer to inherited
symbols. We then execute the :intern option and lastly the :export option so
that it can refer to symbols made accessible by the other options.

If a defpackage form appears as a top level form, all of the actions normally
performed by this macro at load time must also be performed at compile time.

Exceptional Situations:

An error of type program-error should be signaled if :size or :documentation
appears more than once.

Since implementations might allow extended options an error of type
program-error should be signaled if an option is present that is not actually
supported in the host implementation.

The collection of symbol-name arguments given to the options :shadow, :intern,
:import-from, and :shadowing-import-from must all be disjoint; additionally,
the symbol-name arguments given to :export and :intern must be
disjoint. Disjoint in this context is defined as no two of the symbol-names
being string= with each other. If either condition is violated, an error of
type program-error should be signaled.

For the :shadowing-import-from and :import-from options, a correctable error
of type package-error is signaled if no symbol is accessible in the package
named by package-name for one of the argument symbol-names.

Name conflict errors are handled by the underlying calls to make-package,
use-package, import, and export. See Section 11.1 (Package Concepts).

See Also:

documentation, Section 11.1 (Package Concepts), Section 3.2 (Compilation)

Notes:

The :intern option is useful if an :import-from or a :shadowing-import-from
option in a subsequent call to defpackage (for some other package) expects to
find these symbols accessible but not necessarily external.

It is recommended that the entire package definition is put in a single place,
and that all the package definitions of a program are in a single file. This
file can be loaded before loading or compiling anything else that depends on
those packages. Such a file can be read in the COMMON-LISP-USER package,
avoiding any initial state issues.

defpackage cannot be used to create two ``mutually recursive'' packages, such
as:

 (defpackage my-package
   (:use common-lisp your-package)    ;requires your-package to exist first
   (:export \"MY-FUN\"))                
 (defpackage your-package
   (:use common-lisp)
   (:import-from my-package \"MY-FUN\") ;requires my-package to exist first
   (:export \"MY-FUN\"))

However, nothing prevents the user from using the package-affecting functions
such as use-package, import, and export to establish such links after a more
standard use of defpackage.

The macroexpansion of defpackage could usefully canonicalize the names into
strings, so that even if a source file has random symbols in the defpackage
form, the compiled file would only contain strings.

Frequently additional implementation-dependent options take the form of a
keyword standing by itself as an abbreviation for a list (keyword T); this
syntax should be properly reported as an unrecognized option in
implementations that do not support it."
  (mapc 'check-defpackage-option options)
  (expand-defpackage-form name options))
