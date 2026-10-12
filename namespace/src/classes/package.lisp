;;;; This is "namespace/src/classes-and-conditions/packages.lisp".

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

