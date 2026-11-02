;;;; This is "namespace/src/package-interface/defpackage.lisp".

(in-package #:namespace)

(declaim (type list *defpackage-options*)

         (ftype (function (list)
                          boolean)
                defpackage.options?))

;;; defpackage-options?
;;; ===================
;;;
;;; Checks that every element of our options is a list, and that the first
;;; element of each is one of the keywords in *defpackage-options*.
;;;
;;; We want to signal a correctable program-error for options we do not
;;; understand. Named continue or ignore?

(defparameter *defpackage-options*
  '(:home
    :local-nicknames
    :extend :shadow :shadowing-import-from :use :import-from :intern :export
    :publish
    :documentation
    :size))

(defun defpackage-options? (options) ; returns t
  (loop for option in options
        if (listp option)
        do (unless (find (first option) *defpackage-options*)
             ;; FIXME: add restarts
             (error 'program-error :message (format nil
                                                    "Unkown defpackage option~%  ~S."
                                                    option)))
        else
        do (error 'program-error :message (format nil
                                                  "The defpackage option~%  ~S~%~
                                                   is not in the form~%  (:name value*)."
                                                  option))
        finally (return t)))


;;; Collecting Option Arguments fo Parsing
;;; ======================================
;;;
;;; Signals an error of type program-error if any option is not a list
;;; (defpackage-options? checks for this, but we keep the checks in case we call
;;; these independently).
;;;
;;; Any option without arguments is treated as not being supplied at all.

(declaim (ftype (function (common-lisp:symbol list)
                          list)
                concatenate-option-arguments
                list-option-arguments))

(defun concatenate-option-arguments (name options)
  ;; Concatenate the arguments of all name instances into a single list.
  ;;
  ;; ((:shadowing-import-from "FROM" "S1" "S2" "S3")
  ;;  (:shadowing-import-from "FROM" "S1" "S2" "S3"))
  ;;
  ;; becomes
  ;;
  ;; ("FROM" "S1" "S2" "S3" "FROM" "S1" "S2" "S3")
  (handler-case
      (mapcan #'(lambda (option)
                  (when (eql name (first option))
                    (rest option)))
              options)
    (type-error ()
      (error 'program-error :message (format nil
                                             "Cannot parse the~%  ~S option~%~
                                              because the options~%  ~S~%~
                                              are malformed."
                                             name options)))))

(defun list-option-arguments (name options)
  ;; List the arguments of all name instances.
  ;;
  ;; ((:shadowing-import-from "FROM" "S1" "S2" "S3")
  ;;  (:shadowing-import-from "FROM" "S1" "S2" "S3"))
  ;;
  ;; becomes
  ;;
  ;; (("FROM" "S1" "S2" "S3")
  ;;  ("FROM" "S1" "S2" "S3"))
  (handler-case
      (mapcan #'(lambda (option)
                  (when (eql name (first option))
                    (list (rest option))))
              options)
    (type-error ()
      (error 'program-error :message (format nil
                                             "Cannot parse the~%  ~S option~%~
                                              because the options~%  ~S~%~
                                              are malformed."
                                             name options)))))



;;; Getting Specific Options and Executing Them
;;; ===========================================
;;;
;;; We use a pair of functions, parse-<name>-option and execute-<name>-option,
;;; to retreive the arguments to each option and apply them to the package
;;; being defined.
;;;
;;; The order in which the options appear in a defpackage form is irrelevant. The
;;; order in which they are executed is as follows:
;;;
;;; 1. :home.
;;;
;;;    Establish which packages can be referenced by later options. Executing
;;;    the home option places the package in the system.
;;;
;;; 2. :local-nicknames
;;;
;;;    Make local nicknames available for the options below.
;;;
;;; 3a. A package being extended executes its side of the
;;;     :extend option.
;;;
;;;    This is not implemented yet, but will probably be done by calling
;;;
;;;    (extend symbol-list package-being-extended &optional extending-package)
;;;
;;;    We need a function to retreive the symbol list from the
;;;    extending-package (i.e. the home package).
;;;
;;;    Make any symbols it is extended by available for :shadow, :intern, and
;;;    :export.
;;;
;;; 3b. A package being published executes its side of the :publish option.
;;;
;;;     This is not implemented yet, but will probably be done by calling
;;;
;;;     (publish published-package &optional publishing-package)
;;;
;;; Before executing the options :shadow, :shadowing-import-from,
;;; :import-from, and :intern we check that their symbol-name arguments are
;;; disjoin.
;;;
;;; 4. :shadow and :shadowing-import-from
;;;
;;;    We shadow symbols to prevent name conflicts arising from the :use
;;;    option.
;;;
;;; 5. :use
;;;
;;;    We execute the :use option to make inherited symbols available for the
;;;    :intern option.
;;;
;;; Before executing the :intern and :export options we check that their
;;; symbol-name arguments are disjoint.
;;;
;;; 6. :import-from and :intern
;;;
;;;    The :import-from and :intern options finalize the set of symbols
;;;    available for the :export and :extend options.
;;;
;;; Before we execute the :export and :extend options we check that their
;;; symbol-name arguments are disjoint.
;;;
;;; 7. :export
;;;
;;;    The symbols being exported are also interned in the package.
;;; 
;;; 8. :extend
;;;
;;;    The :extend option is not implemented yet. This will probably be done by
;;;
;;;    8a. interning the provided list of symbol-names, and
;;;    8b. calling a function from internal-structure to add package name and
;;;        symbols to unresolved extensions.
;;;
;;; 9. :publish
;;;
;;;    The :publish option is not implemented yet. This will probably be done
;;;    by calling an function from internal-structure that adds the named
;;;    packages to unresolved publications.
;;;
;;; 10. :size
;;; 11. :documentation
;;;

(declaim (ftype (function (list)
                          (or list home-designator))
                parse-home-option)

         (ftype (function (home-designator package string)
                          (values))
                execute-home-option))

(defun parse-home-option (options)
  ;; Returns nil, a string or the list '(home-package *package*).
  ;; The value is evaluated and passed to resolve-home-designator.
  (let ((arguments (concatenate-option-arguments :home options)))
    (cond
      ((cdr arguments)
       ;; Zero or one home argument can be supplied.
       (error 'program-error :message (format nil
                                              "The :home option arguments~%  ~S~%~
                                               exceeds the maximum of one (1) allowed."
                                              arguments)))
      ((null arguments)
       ;; Any (:home) with no argument supplied goes here.
       '(home-package *package*))
      (t
       ;; We have a :home option with exactly one argument supplied.
       (when (first arguments)
         (resolve-string-designator (first arguments)))))))

(defun execute-home-option (home-package package name)
  (cond
    ((name package)
     ;; name is non-nil for a pre-existing package.
     ;;
     ;; At this point the home-package may be the same or a new one: in
     ;; either case we remove the package from its old home, and add it
     ;; to the new one.
     ;;
     ;; This has the effect of placing it first in the interal-list of
     ;; its home, which is where newly added packages are placed.
     ;;
     ;; Users may expect this even if home is unchanged.
     (remove-package package (home-package package))
     (add-package package home-package))
    (t
     ;; We're making a new package.
     (setf (name package) name)
     (add-package package home-package)))
  (values))

(declaim (ftype (function (list)
                          list)
                parse-local-nicknames-option)

         (ftype (function (list package)
                          (values))
                execute-local-nicknames-option))

(defun parse-local-nicknames-option (options)
  ;; Returns a list of (string string) lists.
  (let ((option (concatenate-option-arguments :local-nicknames options)))
    (handler-case
        (mapcar #'(lambda (elt)
                    (list (resolve-string-designator (first elt))
                          (resolve-string-designator (second elt))))
                option)
      (type-error ()
        (error 'program-error :message (format nil
                                               "The :local-nicknames option arguments~%  ~S~%~
                                                are not a list of~%  (string-designator string-designator)~%~
                                               values."
                                               option))))))

(defun execute-local-nicknames-option (local-nicknames package)
  (loop for local-nickname in local-nicknames
        do (add-package-local-nickname (first local-nickname) (second local-nickname) package))
  (values))


;;; Ensuring symbol-name Arguments are Disjoint
;;; ===========================================
;;;
;;; The collection of symbol-name arguments given to the options :shadow,
;;; :intern, :import-from, and :shadowing-import-from must all be disjoint;
;;;
;;; additionally, the symbol-name arguments given to :export and :intern must
;;; be disjoint.
;;;
;;; Disjoint in this context is defined as no two of the symbol-names being
;;; string= with each other.
;;;
;;; If either condition is violated, an error of type program-error should be
;;; signaled.
;;;
;;; We should be more specific in out error report, list the exact symbols
;;; that are duplicates, with the options they occure in:
;;;
;;; The symbol-name arguments
;;;   (:shadow "abc" "def")
;;;   (:import-from "abc" "def")
;;; are not disjoint.
;;;
;;; But this is also lacking: our shadowing-import-from and import-from
;;; options take an additional package argument, and there is one option for
;;; each package.
;;;
;;; Do we want to include that information? Perhaps only the symbol names are
;;; enough.
;;;
;;; There are duplicate symbol-name arguments for
;;;   "abc" "def"
;;; in
;;;   :shadow and :import-from options.
;;;
;;; We will compare symbol-names using string=,
;;; resolve-option-string-designator-arguments takes a list of designators and
;;; returns a list of strings.

(declaim (ftype (function (&rest list)
                          boolean)
                disjoint-lists-of-symbols?)

         (ftype (function (list list list list)
                          boolean)
                disjoint-shadow/shadowing-import-from/import-from/intern-options?)

         (ftype (function (list list)
                          boolean)
                disjoint-intern/export-options?))

(defun disjoint-lists-of-symbols? (&rest lists)
  ;; False if any list shares elements (by cl:string=).
  (let ((union '())
        (sum 0))
    (loop for list in lists
          do (incf sum (length list))
          do (setf union (union union list :test 'string=)))
    (>= (length union) sum)))

(defun disjoint-shadow/shadowing-import-from/import-from/intern-options? (shadow shadowing-import-from import-from intern)
  ;; Returns t or signals a program-error.
  (or (disjoint-lists-of-symbols? shadow
                                  (mapcan 'rest shadowing-import-from)
                                  (mapcan 'rest import-from)
                                  intern)
      (error 'program-error :message (format nil
                                             "The symbol-name arguments of ~%  :shadow ~S,~%  :shadowing-import-from ~S,~%  :import-from ~S,~%~
                                              and~%  :intern ~S,~%~
                                              are not disjoint."
                                             shadow shadowing-import-from import-from intern))))
             
(defun disjoint-intern/export-options? (intern export)
  ;; Returns t or signals a program-error.
  (or (disjoint-lists-of-symbols? intern export)
      (error 'program-error :message (format nil
                                             "The symbol-name arguments of~%  :intern ~S,~%~
                                              and~%  :export ~S,~%~
                                              are not disjoint."
                                             intern export))))


(declaim (ftype (function (list)
                          list)
                parse-shadow-option))

(defun parse-shadow-option (options)
  ;; Returns a list of strings
  (mapcar 'resolve-string-designator (concatenate-option-arguments :shadow options)))

;;; There is no "execute-shadow-option", we call shadow from
;;; expand-defpackage-form.

(declaim (ftype (function (list)
                          list)
                parse-shadowing-import-from-option))

(defun parse-shadowing-import-from-option (options)
  ;; Returns a list of lists of strings
  (loop for option in (list-option-arguments :shadowing-import-from options)
        collect (mapcar 'resolve-string-designator option)))

;; :shadowing-import-from is executed by "execute-import-from".

(declaim (ftype (function (list)
                          list)
                parse-use-option))

(defun parse-use-option (options)
  (mapcar 'resolve-string-designator (concatenate-option-arguments :use options)))

;;; There is no "execute-use-option", we call use from expand-defpackage-form.

(declaim (ftype (function (list)
                          list)
                parse-import-from-option)

         (ftype (function ((or function common-lisp:symbol) list package)
                          (values))
                execute-import-option))

(defun parse-import-from-option (options)
  ;; Returns a list of lists of strings
  (loop for option in (list-option-arguments :import-from options)
        collect (mapcar 'resolve-string-designator option)))

(defun execute-import-option (import-function list-of-arguments package)
  ;; Executes both :shadowing-import-from and :import-from
  (loop for arguments in list-of-arguments
        do (funcall import-function
                    (loop with from-package = (resolve-package-designator (first arguments))
                          for symbol-name in (rest arguments)
                          collect (multiple-value-bind (symbol status)
                                      (find-symbol symbol-name from-package)
                                    (if (null status)
                                        (error 'symbol-is-not-accessible
                                               :symbol symbol-name
                                               :package from-package
                                               :context package)
                                        symbol)))
                    package))
  (values))
            
(declaim (ftype (function (list)
                          list)
                parse-intern-option)

         (ftype (function (list package)
                          (values))
                execute-intern-option))

(defun parse-intern-option (options)
  (mapcar 'resolve-string-designator (concatenate-option-arguments :intern options)))

(defun execute-intern-option (symbol-names package)
  (loop for symbol-name in symbol-names
        do (intern symbol-name package))
  (values))
            
(declaim (ftype (function (list)
                          list)
                parse-export-option)

         (ftype (function (list package)
                          (values))
                execute-export-option))

(defun parse-export-option (options)
  (mapcar 'resolve-string-designator (concatenate-option-arguments :export options)))

(defun execute-export-option (symbol-names package)
  (export (loop for symbol-name in symbol-names
                collect (or (find-symbol symbol-name package)
                            (intern symbol-name package)))
          package)
  (values))

(defun parse-extend-option (options)
  (declare (ignore options))
  (error 'program-error :message "The option~% :extend~% is not implemented yet."))

(defun parse-publish-option (options)
  (declare (ignore options))
  (error 'program-error :message "The option~% :publish~% is not implemented yet."))

(defun parse-size-option (options)
  (declare (ignore options))
  (error 'program-error :message "The option~% :size~% is not implemented yet."))

(defun parse-documentation-option (options)
  (declare (ignore options))
  (error 'program-error :message "The option~% :documentation~% is not implemented yet."))
        

(defun expand-defpackage-form (name options)
  (let ((resolved-name (common-lisp:gensym "NAME"))
        (package (common-lisp:gensym "PACKAGE"))
	(home-package (common-lisp:gensym "HOME-PACKAGE"))
        ;;(local-nickname (common-lisp:gensym "LOCAL-NICKNAME"))
        (shadow-args (common-lisp:gensym "SHADOW"))
        (shadowing-import-from-args (common-lisp:gensym "SHADOWING-IMPORT-FROM"))
        (import-from-args (common-lisp:gensym "IMPORT-FROM"))
        (intern-args (common-lisp:gensym "INTERN"))
        (export-args (common-lisp:gensym "EXPORT")))
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       ;; We work out the location of the package being defined, and obtain a
       ;; package object to work with.
       ;;
       ;; The package object may be an existing package or a new one.
       ;;
       ;; The process may terminate with an error if home cannot be
       ;; resolved. This leaves the package hierarchy unchanged.
       (let* ((,home-package (resolve-home-designator ,(parse-home-option options)))
              (,resolved-name ,(resolve-string-designator name))
              (,package (or (find-conflicting-package ,resolved-name ,home-package)
                            (make-instance 'package))))

         ;; We place the package in its location.
         ;;
         ;; If we're working with a new package, and the name is invalid, then
         ;; the process will terminate before any changes are made.
         ;;
         ;; Otherwise the package hierarchy is altered, with package placed.
         (execute-home-option ,home-package ,package ,resolved-name)

         ;; We add local nicknames so they are available for use when
         ;; processing further options.
         ;;
         ;; The process may terminate here depending on name conflicts. This
         ;; may leave the package with some nicknames working.
         (execute-local-nicknames-option ',(parse-local-nicknames-option options) ,package)

         ;; At this point the package being extended will execute its side of
         ;; the :extend option

         ;; At this point the package being published will execute its side of
         ;; the :publish option.

         ;; The symbol-name lists are used twice below, for executing the
         ;; options and checking that the lists are disjoint.
         (let ((,shadow-args ',(parse-shadow-option options))
               (,shadowing-import-from-args ',(parse-shadowing-import-from-option options))
               (,import-from-args ',(parse-import-from-option options))
               (,intern-args ',(parse-intern-option options))
               (,export-args ',(parse-export-option options)))

           ;; The symbol-name arguments given to :shadow, :intern,
           ;; :import-from, and :shadowing-import-from must all be
           ;; disjoint. We signal a program-error if they are not.
           (disjoint-shadow/shadowing-import-from/import-from/intern-options? ,shadow-args
                                                                              ,shadowing-import-from-args
                                                                              ,import-from-args
                                                                              ,intern-args)

           (shadow ,shadow-args ,package) 
           (execute-import-option 'shadowing-import ,shadowing-import-from-args ,package)
           (use-package ',(parse-use-option options) ,package)
           (execute-import-option 'import ,import-from-args ,package)

           ;; The symbol-name arguments given to :export and :intern must be
           ;; disjoint. We signal a program-error if they are not.
           (disjoint-intern/export-options? ,intern-args ,export-args)

           (execute-intern-option ,intern-args ,package)
           (execute-export-option ,export-args ,package)

           ;; The symbol-name arguments given to :export and :extend must be
           ;; disjoint. We signal a program-error if they are not. Note that
           ;; we can have multiple :extend options, and each of them must be
           ;; disjoint with the :export option, but not with each other.
           
           ;; At this point we will execute the :extend option from the
           ;; extending package.

           ;; At this point we will execute the :publish option.

           ;; At this point we will execute the :size option.

           ;; At this point we will execute the :documentation option.
           
         ,package)))))

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

Note that options that omitt arguments, for example \(:home\), are treated as
if not supplied.

\(:home package-name\)

   At most one :home option may appear; it specifies where to locate the new
   package.

   If omitted, then the new package becomes a peer package of the current
   package; i.e. the home package of the current package becomes the home
   package of the new package.

   If supplied as nil then the new package becomes a top-level package.

   Otherwise, the named package becomes the new packages home package.

\(:shadow symbol-name*\)

    Any number of :shadow options may appear. The named symbols become
    shadowing symbols in the new package by means of shadow.

\(:shadowing-import-from package-name symbol-name*\)

    Any number of :shadowing-import-from options may appear. The named symbols
    become shadowing symbols in the new package by means of shadowing-import.

\(:use package-name*\)

    Any number of :use options may appear. The named packages are used by
    means of use-package.

\(:import-from package-name symbol-name*\)

    Any number of :import-from options may appear. The named symbols are
    imported into the new package by means of import.

\(:intern symbol-name*\)

    Any number of :intern options may appear. The named symbols become
    internal symbols in the new package by means of intern.

\(:export symbol-name*\)

    Any number of :export options may appear. The named symbols become
    external symbols in the new package by means of export. Any named symbols
    that are not already present in the new package are interned.

\(:extend package-name symbol-name*\)

    The :extend option is mot implemented yet, and ignored.

\(publish package-name*\)

    The :publish option is mot implemented yet, and ignored.

\(:size\)
    The :size option is mot implemented yet, and ignored.

\(:documentation string\)

    The :documentation option is mot implemented yet, and ignored.

The order in which the options appear in a defpackage form is irrelevant. The
order in which they are executed is as follows:

1. :home.
2. :local-nicknames.
3. :shadow and :shadowing-import-from.
4. :use.
5. :import-from.
6. :intern.
7. :export.
8. :extend.
9. :publish

1. The new package is placed in its home location to establish wich packages
   are visible when other options are executed.

2. We define local nicknames so they may be used by later options.

3. We execute :shadow and :shadowing-import to block any name conflicts that
   may appear because of later options.

4. We establish inherited symbols so they are available for :intern later.

5. We execute :import-from so that imported symbols are available for :intern.

6. We execute :intern which may intern symbols available from :use and
   :import-from.

7. :export is executed after all symbols are available.

8. :extend is not implemented. Each :extend option names a package and a list
   of symbols that package will import. The names should be disjoint from
   :export arguments.

Clarification Needed:
The Common Lisp HyperSpec entry for defpackage says:

  The collection of symbol-name arguments given to the options :shadow,
  :intern, :import-from, and :shadowing-import-from must all be disjoint;
  additionally, the symbol-name arguments given to :export and :intern must be
  disjoint. Disjoint in this context is defined as no two of the symbol-names
  being string= with each other. If either condition is violated, an error of
  type program-error should be signaled.

However, the execution order implies that it is fine if the symbol names are
not disjoint. It makes sense that

  a. :shadow and :shadowing-import-from should be disjoint.
  b. :import-from should be disjoint from :shadow and :shadowing-import.

Using :intern with any name from the options above will not change anything.

It is also mentioned that arguments to :intern and :export should be disjoint.
The :export option interns any named symbol it cannot find, so it is redundant
to add those names to :intern, but it does not cause problems.

Exceptional Situations:

  program-error

  An error of type program-error.

  Signaled if :size or :documentation appears more than once.

  Signaled if an option is present that is not actually supported in the
  implementation."
  (when (defpackage-options? options)
    (expand-defpackage-form name options)))
