;;;; This is "namespace/src/interface/package-error.lisp".
;;;;
;;;; 1. Base Package Errors
;;;;
;;;;    package-error
;;;;      package-error-package
;;;;      package-error-location
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
;;;      package-error-location
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
Return a package designator for the offending package."))

(defgeneric package-error-location (condition)
  (:documentation "Syntax:
\(package-error-location condition\) → location

Arguments and Values:
condition—a condition of type package-error.
location—a location designator.

Description:
Return the location designator for the offending package."))

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

  \"Error operating on ~S located at ~S.\"
  package and location.

\(package-error-message conflicting-package-names\) → string

  \"The name ~S conflicts with ~S located at ~S.\"
  name, package and location.

\(package-error-message package-symbol-error\) → string

  \"Error operating on ~S in the package ~S located at ~S.\"
  symbol, package and location.

\(package-error-message conflicting-symbol-names\) → string

  \"The symbol name ~S conflicts with ~S in ~S located at ~S.\"
  conflicting-symbol, symbol, package and location."))

(define-condition package-error (error)
  ((package :reader package-error-package
	    :initform "PACKAGE-DESIGNATOR"
	    :initarg :package
	    :type package-designator
	    :documentation "The package designator for the offending package.")
   (location :reader package-error-location
	     :initform nil
	     :initarg :location
	     :type location-designator
	     :documentation "The location designator for the offending package.")
   (message :reader package-error-message
	    :initform "Error operating on ~S located at ~S."
	    :initarg :message
	    :type string
	    :documentation "A format string used to report this condition."))
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-package c)
		     (package-error-location c))))
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
current package, *package*."))

(define-condition package-is-in-use (package-error)
  ()
  (:documentation
   "Signaled by delete-package when the package being deleted is used
by another package \(used by means of use-package\)."))


;;; ============================================================================
;;; 3. Packages that Do Not Exist
;;;
;;;    package-does-not-exist
;;;
;;; ============================================================================

(define-condition package-does-not-exist (package-error)
  ()
  (:default-initargs
   :message "The name ~S does not designate any package located at ~S.")
  (:documentation
   "Signaled when a string designator cannot be resolved into a
package object by resolve-package-designator."))


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
   :message  "The name ~S conflicts with ~S located at ~S.")
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-conflicting-name c)
		     (package-error-package c)
		     (package-error-location c))))
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
   :message "Error operating on ~S in the package ~S located at ~S.")
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-symbol c)
		     (package-error-package c)
		     (package-error-location c))))
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
   :message "The symbol ~S is not accessible from ~S located at ~S.")
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
   :message "The symbol name ~S conflicts with ~S in ~S located at ~S.")
  (:report (lambda (c stream)
	     (format stream
		     (package-error-message c)
		     (package-error-symbol c)
		     (package-error-conflicting-symbol c)
		     (package-error-package c)
		     (package-error-location c))))
  (:documentation
   "Signaled when a package operation would result in two accessible
symbols with the same name."))
