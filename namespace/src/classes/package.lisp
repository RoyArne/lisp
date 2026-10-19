;;;; This is "namespace/src/classes-and-conditions/packages.lisp".
;;;;
;;;; TODO: We may change
;;;;
;;;;       · internal-list → internal-packages
;;;;       · internal-to-list → internal-to-packages
;;;;
;;;;       and add
;;;;
;;;;       · external-packages, and
;;;;       · unresolved-external-packages
;;;;
;;;;       The additions will be needed if we want to export any internal functions:
;;;;
;;;;       · (export-package packages &optional package) → t
;;;;
;;;;       which makes all PACKAGES available from outside PACKAGE by means of
;;;;       "dotted" string designators:
;;;;
;;;;       · #:this-is.a.test → three packages: #:this-is,
;;;;                                            #:a (internal to #:this-is), and
;;;;                                            #:test (internal to #:a).
;;;;
;;;;
;;;;       Alternatively, we may keep internal-list and internal-to-list, and add
;;;;
;;;;       · external-list
;;;;       · unresolved-external-list
;;;;
;;;;       The first is consistent with the naming of internal-symbols and
;;;;       external-symbols. The second matches use-list and used-by-list.
;;;;
;;;;       The first thing to do is find all uses of internal-list and
;;;;       internal-to-list.

(in-package #:namespace)

(defclass package ()
  ((name :reader name
         :initform nil
         :type (or null string)
         :documentation "A string used to identify the package. Set to NIL when the package is deleted.")
   (local-nicknames :reader local-nicknames
                    :initform '()
                    :type list
                    :documentation
                    "A \(name . package\) alist specifying alternative package names for use in this package.")

   (internal-list :reader internal-list
                  :initform '()
                  :type list
                  :documentation "A list of packages that are internal to this package.")
   (internal-to-list :reader internal-to-list
                     :initform '()
                     :type list
                     :documentation "A list of packages that this package is internal to. The first package is the home package.")
   
   (use-list :reader use-list
             :initform '()
             :type list
             :documentation "This package inherits external symbol from packages in this list.")
   (used-by-list :reader used-by-list
                 :initform '()
                 :type list
                 :documentation "A list of packages that inherit external symbols from this package.")

   (internal-symbols :reader internal-symbols
                     :initform (make-hash-table :test 'string:case-sensitive-string-test)
                     :type hash-table
                     :documentation "A hash table of symbols that are internal to this package.")
   (external-symbols :reader external-symbols
                     :initform (make-hash-table :test 'string:case-sensitive-string-test)
                     :type hash-table
                     :documentation "A hash table of symbols that are external to this package.")
   (shadowing-symbols :reader shadowing-symbols
                      :initform '()
                      :type list
                      :documentation "A list of symbols that take precedence over inherited symbols.")))

