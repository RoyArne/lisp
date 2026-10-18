
(in-package #:asdf-user)

(defsystem namespace
  :name "namespace"
  :author "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :maintainer "Roy Arne Gangstad <roy.gangstad@gmail.com>"
  :license "GNU Affero General Public License, version 3."
  :depends-on ("unicode" "string")
  :serial t
  :components ((:file "namespace")
               (:file "utilities")
               
               (:module classes
                :serial t
                :depends-on ("namespace")
                :components ((:file "package")
                             (:file "symbol")))

               (:module conditions
                :serial t
                :depends-on ("namespace")
                :components ((:file "package-error")))
               
               (:module internal-structure
                :serial t
                :depends-on ("namespace" classes conditions)
                :components ((:file "designator-types")
                             (:file "initial-packages-and-locations")
                             (:file "package-manipulation") ; :depends-on ("designator-types")
                             (:file "resolve-string-designator")  ; :depends-on ("designator-types")
                             (:file "resolve-package-designator")  ; :depends-on ("designator-types")
                             (:file "resolve-context-designator") ; :depends-on ("designator-types")
                             (:file "resolve-home-designator") ; :depends-on ("designator-types")
                             (:file "symbol-manipulation")))

               (:module symbol-interface
                :serial t
                :depends-on ("namespace" classes)
                :components ((:file "copy-symbol")
                             (:file "make-symbol")
                             (:file "symbolp")
                             (:file "symbol-name")
                             (:file "symbol-package")))

               (:module package-interface
                :depends-on ("namespace" "utilities" classes conditions internal-structure symbol-interface)
                :components ((:file "add-package-local-nickname")
                             (:file "do-all-symbols")
                             (:file "do-symbols")
                             (:file "do-external-symbols")
                             (:file "unuse-package")
                             (:file "delete-package" :depends-on ("unuse-package"))
                             (:file "find-all-symbols")
                             (:file "find-package")
                             (:file "find-symbol")
                             (:file "in-package")
                             (:file "intern" :depends-on ("find-symbol"))
                             (:file "list-all-packages")
                             (:file "list-peer-packages")
                             (:file "package-internal-list")
                             (:file "package-internal-to-list")
                             (:file "package-local-nicknames")
                             (:file "package-name")
                             (:file "package-package")
                             (:file "package-shadowing-symbols")
                             (:file "package-use-list")
                             (:file "package-used-by-list")
                             (:file "packagep")
                             (:file "remove-package-local-nickname")
                             (:file "rename-package" :depends-on ("delete-package"))
                             (:file "shadow")
                             (:file "unintern" :depends-on ("find-symbol"))
                             (:file "shadowing-import":depends-on ("unintern"))
                             (:file "import" :depends-on ("shadowing-import" "unintern"))
                             (:file "unexport" :depends-on ("import"))
                             (:file "export" :depends-on ("import" "shadow" "unintern"))
                             (:file "use-package" :depends-on ("find-symbol" "shadow" "shadowing-import"))
                             (:file "make-package" :depends-on ("use-package" "delete-package"))
                             (:file "defpackage" :depends-on ("add-package-local-nickname"
                                                              "intern" "shadow"
                                                              "shadowing-import" "import"
                                                              "export"
                                                              "use-package"))))

               ;;   Methods and functions to make everything work with
               ;;   SBCL/Common Lisp. For example, methods that allows regular
               ;;   strings and symbols to work as string designators.
               ;;
               (:module compatibility
                :depends-on ("namespace" classes internal-structure symbol-interface package-interface)
                :serial t
                :components ((:file "classes")
                             (:file "internal-structure")
                             (:file "symbol-interface")
                             (:file "package-interface")))))
