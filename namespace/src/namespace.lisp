
(defpackage #:namespace
  (:use #:common-lisp)

  (:documentation
   "The #:namespace package implements \(parts of\) chapter 10 \(Symbols\) and
11 \(Packages\) from the Common Lisp Hyperspec.")

  ;; We shadow string types and symbols from Common Lisp, in favor of our own
  ;; definitions from the "string" system.
  (:shadowing-import-from #:string
                          #:string
                          #:string=)

  ;; We shadow the symbols dictionary from Common Lisp. These are from
  ;; chapter 10 of the Common Lisp HyperSpec.
  (:shadow #:symbol
           #:keyword
           #:unbound-variable
           #:*gensym-counter*
           #:symbolp
           #:keywordp
           #:make-symbol
           #:copy-symbol
           #:gensym
           #:gentemp
           #:symbol-function
           #:symbol-name
           #:symbol-package
           #:symbol-plist
           #:symbol-value
           #:get
           #:remprop
           #:boundp
           #:makunbound
           #:set)

  ;; We export the symbol interface that is defined so far.
  (:export #:copy-symbol
           #:make-symbol
           #:symbol
           #:symbol-name
           #:symbol-package
           #:symbol?)

  ;; We shadow the packages dictionary from Common Lisp. These are from
  ;; chapter 11 of the Common Lisp HyperSpec.
  (:shadow #:package
   
           #:package-error
           #:package-does-not-exist
           #:package-is-a-system-package
           #:package-is-the-current-package
           #:package-is-in-use
           #:conflicting-package-names
           #:package-symbol-error
           #:symbol-is-not-accessible
           #:conflicting-symbol-names

           #:package-error-package
           #:package-error-context
           #:package-error-conflicting-name
           #:package-error-symbol
           #:package-error-conflicting-symbol
   
           #:*package*
           #:*packages*

           #:with-package-iterator
           #:in-package
           #:defpackage
           #:do-all-symbols
           #:do-external-symbols
           #:do-symbols
   
           #:export
           #:find-symbol
           #:find-package
           #:find-all-symbols
           #:import
           #:list-all-packages
           #:list-shadowing-packages
           #:list-peer-packages
           #:rename-package
           #:shadow
           #:shadowing-import
           #:delete-package
           #:make-package
           #:unexport
           #:unintern
           #:unuse-package
           #:use-package
           #:intern
           #:package-locally-nicknamed-by-list
           #:add-package-local-nickname
           #:remove-package-local-nickname
           #:package-name
           #:package-nicknames
           #:package-shadowing-symbols
           #:package-use-list
           #:package-used-by-list
           #:package-package
           #:package-internal-list
           #:package-internal-to-list
           #:package-local-nicknames
           #:packagep)

  ;; Export the package interface that is implemented so far
  (:export #:add-package-local-nickname
           #:delete-package
           #:do-all-symbols
           #:do-symbols
           #:do-external-symbols
           #:export
           #:find-package
           #:find-symbol
           #:import
           #:in-package
           #:intern
           #:list-all-packages
           #:list-peer-packages
           #:make-package
           #:package
           #:package-internal-list
           #:package-internal-to-list
           #:package-local-nicknames
           #:package-name
           #:package-package
           #:package-shadowing-list
           #:package-use-list
           #:package-used-by-list
           #:package?
           #:remove-package-local-nickname
           #:rename-package
           #:shadow
           #:shadowing-import
           #:unexport
           #:unintern
           #:use-package))
