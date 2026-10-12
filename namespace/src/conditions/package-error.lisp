;;;; This is "namespace/src/interface/package-error.lisp".
;;;;
;;;; 1. Base Package Errors
;;;;
;;;;    package-error
;;;;      package-error-package
;;;;      package-error-context
;;;;      package-error-message
;;;;
;;;; 2. Packages that are Used For Something
;;;;
;;;;    package-is-a-system-package
;;;;    package-is-the-current-package
;;;;    package-is-in-use
;;;;
;;;; 3. Packages that Do Not Exist
;;;;
;;;;    package-does-not-exist
;;;;
;;;; 4. Conflicting Package Names
;;;;
;;;;    conflicting-package-names
;;;;      package-error-conflicting-name
;;;;
;;;; 5. Base Symbol Errors
;;;;
;;;;    package-symbol-error
;;;;      package-error-symbol
;;;;
;;;; 6. Inaccessible Symbols
;;;;
;;;;    symbol-is-not-accessible
;;;;
;;;; 7. Symbol Name Conflicts
;;;;
;;;;    conflicting-symbol-names
;;;;      package-error-conflicting-symbol
;;;;

(in-package #:namespace)

;;; ============================================================================
;;; 1. Base Package Errors
;;;
;;;    package-error
;;;      package-error-package
;;;      package-error-context
;;;      package-error-message
;;;
;;; ============================================================================

(defgeneric package-error-package (condition)
  (:documentation "Syntax:
\(package-error-package condition\) → package

Arguments and Values:
condition—a condition of type package-error.
package—a package designator.

Description:
Returns a package designator for the offending package."))

(defgeneric package-error-context (condition)
  (:documentation "Syntax:
\(package-error-context condition\) → context

Arguments and Values:
condition—a condition of type package-error.
context—a context designator.

Description:
Returns the context designator of the offending package."))

(defgeneric package-error-message (condition)
  (:documentation "Syntax:
\(package-error-message condition\) → string

Arguments and Values:
condition—a condition of type package-error.
string—a format string.

Description:
Return the format string used to print error messages. Default format
strings and parameters are listed below.

Methods:
\(package-error-message package-error\) → string

  \"Error operating on ~S in the context ~S.\"
  package and context.

\(package-error-message conflicting-package-names\) → string

  \"The name ~S conflicts with ~S in the context ~S.\"
  name, package and context.

\(package-error-message package-symbol-error\) → string

  \"Error operating on ~S in the package ~S in the context ~S.\"
  symbol, package and context.

\(package-error-message conflicting-symbol-names\) → string

  \"The symbol name ~S conflicts with ~S in ~S in the context of ~S.\"
  conflicting-symbol, symbol, package and context."))

(define-condition package-error (error)
  ((package :reader package-error-package
	    :initform "DEFAULT VALUE"
	    :initarg :package
	    :type package-designator
	    :documentation "The package designator of the offending package.")
   (context :reader package-error-context
	    :initform nil
	    :initarg :context
	    :type context-designator
	    :documentation "The context designator of the offending package.")
   (message :reader package-error-message
	    :initform "Error operating on ~S in the context ~S."
	    :initarg :message
	    :type string
	    :documentation "A format string used to report this condition."))
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-package c)
		     (package-error-context c))))
  (:documentation
   "Signaled when a package operation cannot be performed."))


;;; ============================================================================
;;; 2. Packages that are Used For Something
;;;
;;;    package-is-a-system-package
;;;    package-is-the-current-package
;;;    package-is-in-use
;;;
;;; ============================================================================

(define-condition package-is-a-system-package (package-error)
  ()
  (:documentation
   "Signaled by delete-package when the package being deleted is a
system package."))

(define-condition package-is-the-current-package (package-error)
  ()
  (:documentation
   "Signaled by delete-package when the package being deleted is the
current package."))

(define-condition package-is-in-use (package-error)
  ()
  (:documentation
   "Signaled by delete-package when the package being deleted is used
by another package."))


;;; ============================================================================
;;; 3. Packages that Do Not Exist
;;;
;;;    package-does-not-exist
;;;
;;; ============================================================================

(define-condition package-does-not-exist (package-error)
  ()
  (:default-initargs
   :message "The name ~S does not designate any package in the context ~S.")
  (:documentation
   "Signaled when a string designator cannot be resolved into a
package object by resolve-package-designator.

Every function that accepts a package designator (and context
designator) argument calls resolve-package-designator, and may signal
a package-does-not-exist error. The functions are:

  add-package-local-nickname, delete-package, in-package,
  package-internal-list, package-locally-nicknamed-by-list,
  package-local-nicknames, package-name, package-nicknames,
  package-package, package-shadowing-symbols, package-used-by-list,
  remove-package-local-nickname, rename-package, and
  resolve-home-designator."))


;;; ============================================================================
;;; 4. Conflicting Package Names
;;;
;;;    conflicting-package-names
;;;      package-error-conflicting-name
;;;
;;; ============================================================================

(defgeneric package-error-conflicting-name (condition)
  (:documentation "Syntax:
\(package-error-conflicting-name condition\) → string

Arguments and Values:
condition—a condition of type package-error.
string—a string.

Description:
Returns the conflicting name."))

(define-condition conflicting-package-names (package-error)
  ((name :reader package-error-conflicting-name
	 :initform "(default value)"
	 :initarg :name
	 :documentation "A string."))
  (:default-initargs
   :message  "The name ~S conflicts with ~S in the context ~S.")
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-conflicting-name c)
		     (package-error-package c)
		     (package-error-context c))))
  (:documentation
   "Signaled when the given name \(or nickname\) of a package conflicts
with the name \(or nickname\) of another package."))


;;; ============================================================================
;;; 5. Base Symbol Errors
;;;
;;;    package-symbol-error
;;;      package-error-symbol
;;;
;;; ============================================================================

(defgeneric package-error-symbol (condition)
  (:documentation "Syntax:
\(package-error-symbol condition\) → symbol

Arguments and Values:
condition—a condition of type package-error.
symbol—a symbol.

Description:
Returns the offending symbol."))

(define-condition package-symbol-error (package-error)
  ((symbol :reader package-error-symbol
	   :initform "(default value)"
	   :initarg :symbol
	   :documentation "A symbol."))
  (:default-initargs
   :message "Error operating on ~S in the package ~S in the context ~S.")
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-symbol c)
		     (package-error-package c)
		     (package-error-context c))))
  (:documentation
   "Signaled when a package operation involving a symbol cannot be
performed."))


;;; ============================================================================
;;; 6. Inaccessible Symbols
;;;
;;;    symbol-is-not-accessible
;;;
;;; ============================================================================

(define-condition symbol-is-not-accessible (package-symbol-error)
  ()
  (:default-initargs
   :message "The symbol ~S is not accessible from ~S in the context ~S.")
  (:documentation
   "Signaled when a package operation is attempted on a symbol that is
not accessible."))


;;; ============================================================================
;;; 7. Symbol Name Conflicts
;;;
;;;    conflicting-symbol-names
;;;      package-error-conflicting-symbol
;;;
;;; ============================================================================

(defgeneric package-error-conflicting-symbol (condition)
  (:documentation "Syntax:
\(package-error-conflicting-symbol condition\) → symbol

Arguments and Values:
condition—a condition of type package-error.
symbol—a symbol.

Description:
Returns the symbol that conflicts with the offending symbol."))

(define-condition conflicting-symbol-names (package-symbol-error)
  ((conflicting-symbol :reader package-error-conflicting-symbol
		       :initform "(default value)"
		       :initarg :conflicting-symbol
		       :documentation "A symbol"))
  (:default-initargs
   :message "The symbol name ~S conflicts with ~S in ~S in the context of ~S.")
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-symbol c)
		     (package-error-conflicting-symbol c)
		     (package-error-package c)
		     (package-error-context c))))
  (:documentation
   "Signaled when a package operation would result in two accessible
symbols with the same name."))
