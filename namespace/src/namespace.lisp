
(defpackage #:namespace
  (:use #:common-lisp)

  (:documentation
   "The #:namespace package implements \(parts of\) chapter 10 \(Symbols\) and
11 \(Packages\) from the Common Lisp Hyperspec.")

  
  ;;   We shadow string types and symbols from Common Lisp, in favor of our
  ;;   own definitions from the "string" system.
  
  (:shadowing-import-from #:string
                          #:string
                          #:string=)

  
  ;;   We shadow symbols listed in chapter "10.2 The Symbols Dictionary" in
  ;;   the Common Lisp Hyperspec.
  ;;
  ;; · https://www.lispworks.com/documentation/HyperSpec/Body/10_.htm
  ;;
  ;;   Generally, funcitons and macros below are implemented in the
  ;;   src/symbol-interface/ directory, one definition per file.
  ;;
  ;;   Classes are defined in the src/classes/ directory.

  (:shadow #:symbol            ; System Class   (implemented)
           #:keyword           ; Type
           #:symbolp           ; Function       (implemented as symbol?)
           #:keywordp          ; Function
           #:make-symbol       ; Function       (implemented)
           #:copy-symbol       ; Function       (implemented)
           #:gensym            ; Function
           #:*gensym-counter*  ; Variable
           #:gentemp           ; Function
           #:symbol-function   ; Accessor
           #:symbol-name       ; Function       (implemented)
           #:symbol-package    ; Function       (implemented)
           #:symbol-plist      ; Accessor
           #:symbol-value      ; Accessor
           #:get               ; Accessor
           #:remprop           ; Function
           #:boundp            ; Function
           #:makunbound        ; Function
           #:set               ; Function
           #:unbound-variable) ; Condition Type 
  
  (:export #:symbol            ; System Class   (implemented)
           ;; #:keyword           ; Type
           ;; #:symbolp           ; Function       (implemented as symbol?)
           #:symbol?
           ;;#:keywordp          ; Function
           #:make-symbol       ; Function       (implemented)
           #:copy-symbol       ; Function       (implemented)
           ;; #:gensym           ; Function
           ;; #:*gensym-counter* ; Variable
           ;; #:gentemp          ; Function
           ;; #:symbol-function  ; Accessor
           #:symbol-name       ; Function       (implemented)
           #:symbol-package    ; Function       (implemented)
           ;; #:symbol-plist      ; Accessor
           ;; #:symbol-value      ; Accessor
           ;; #:get               ; Accessor
           ;; #:remprop           ; Function
           ;; #:boundp            ; Function
           ;; #:makunbound        ; Function
           ;; #:set               ; Function
           );; #:unbound-variable  ; Condition Type 

  
  ;;   We shadow symbols listed in chapter "11.2 The Packages Dictionary" in
  ;;   the Common Lisp HyperSpec.
  ;;
  ;; · https://www.lispworks.com/documentation/HyperSpec/Body/11_.htm
  ;;
  ;;   Generally, functions and macros listed below are implemented in the
  ;;   src/package-interface/ directory, one definition per file.
  ;;
  ;;   Conditions are implemented in the src/conditions/ directory. Reader
  ;;   functions for condition slots are also implemented here.
  ;;
  ;;   Classes are defined in the src/classes/ directory.
  ;;
  ;;   Variables are found in
  ;;   src/internal-structure/initial-packages-and-locations.lisp.

  (:shadow #:package                   ; System Class         (implemented)
           #:export                    ; Function             (implemented)
           #:find-symbol               ; Function             (implemented)
           #:find-package              ; Function             (implemented)
           #:find-all-symbols          ; Function             (implemented)
           #:import                    ; Function             (implemented)
           #:list-all-packages         ; Function             (implemented)
           #:rename-package            ; Function             (implemented)
           #:shadow                    ; Function             (implemented)
           #:shadowing-import          ; Function             (implemented)
           #:delete-package            ; Function             (implemented)
           #:make-package              ; Function             (implemented)
           #:with-package-iterator     ; Macro
           #:unexport                  ; Function             (implemented)
           #:unintern                  ; Function             (implemented)
           #:in-package                ; Macro                (implemented)
           #:unuse-package             ; Function             (implemented)
           #:use-package               ; Function             (implemented)
           #:defpackage                ; Macro                (partial implementation)
           #:do-symbols                ; Macro                (implemented)
           #:do-external-symbols       ; Macro                (implemented)
           #:do-all-symbols            ; Macro                (implemented)
           #:intern                    ; Function             (implemented)
           #:package-name              ; Function             (implemented)
           #:package-nicknames         ; Function             (will NOT implement)
           #:package-shadowing-symbols ; Function             (implemented)
           #:package-use-list          ; Function             (implemented)
           #:package-used-by-list      ; Function             (implemented)
           #:packagep                  ; Function             (implemented as package?)
           #:*package*                 ; Variable             (implemented)
           #:package-error             ; Condition Type       (implemented)
           #:package-error-package)    ; Function             (implemented)

  (:export #:package                   ; System Class         (implemented)
           #:export                    ; Function             (implemented)
           #:find-symbol               ; Function             (implemented)
           #:find-package              ; Function             (implemented)
           #:find-all-symbols          ; Function             (implemented)
           #:import                    ; Function             (implemented)
           #:list-all-packages         ; Function             (implemented)
           #:rename-package            ; Function             (implemented)
           #:shadow                    ; Function             (implemented)
           #:shadowing-import          ; Function             (implemented)
           #:delete-package            ; Function             (implemented)
           #:make-package              ; Function             (implemented)
           ;; #:with-package-iterator     ; Macro
           #:unexport                  ; Function             (implemented)
           #:unintern                  ; Function             (implemented)
           #:in-package                ; Macro                (implemented)
           #:unuse-package             ; Function             (implemented)
           #:use-package               ; Function             (implemented)
           #:defpackage                ; Macro                (partial implementation)
           #:do-symbols                ; Macro                (implemented)
           #:do-external-symbols       ; Macro                (implemented)
           #:do-all-symbols            ; Macro                (implemented)
           #:intern                    ; Function             (implemented)
           #:package-name              ; Function             (implemented)
           ;; #:package-nicknames         ; Function             (will NOT implement)
           #:package-shadowing-symbols ; Function             (implemented)
           #:package-use-list          ; Function             (implemented)
           #:package-used-by-list      ; Function             (implemented)
           ;; #:packagep                  ; Function             (implemented as package?)
           #:package?                  ; Function             (implemented)
           #:*package*                 ; Variable             (implemented)
           #:package-error             ; Condition Type       (implemented)
           #:package-error-package)    ; Function             (implemented)

  
  ;;   We shadow symbols listed in chapter "7.2 Package-Local Nicknames" in
  ;;   the SBCL Manual.
  ;;
  ;; · https://www.sbcl.org/manual/#package-local-nicknames

  (:shadow #:package-local-nicknames           ; Function     (implemented)
           #:package-locally-nicknamed-by-list ; Function
           #:add-package-local-nickname        ; Function     (implemented)
           #:remove-package-local-nickname)    ; Function     (implemented)

  (:export #:package-local-nicknames           ; Function     (implemented)
           ;;#:package-locally-nicknamed-by-list ; Function
           #:add-package-local-nickname        ; Function     (implemented)
           #:remove-package-local-nickname)    ; Function     (implemented)

  
  ;;   Additional functionality
  ;;
  ;;   The additional condition types (like conflicting-package-names and
  ;;   package-is-in-use) are subtypes of package-error.
  ;;
  ;;   They are (mostly?) signalled in situations where Common Lisp would also
  ;;   signal a package-error. However, they are useful when we want to define
  ;;   handlers for different situations.
  ;;
  ;; · *packages* gives access to the top-level list of packages. By default
  ;;    it lists the system defined packages *lisp*, *keyword*, and *user*.
  ;;
  ;; · package-package returns a packages home package.
  ;;
  ;; · list-peer-packages gives a list of packages at the same level as the
  ;;   current (or a specified) package (i.e. packages with the same home
  ;;   package).
  ;;
  ;; · package-internal-list gives a list of packages who has the given
  ;;   package as their home package.
  ;;
  ;; · package-internal-to-list gives a list of packages who are directly
  ;;   above the given package in the hierarchy (the first package in the list
  ;;   is the given packages home package, followed by that packages home
  ;;   package, and so on).
  
  (:export #:conflicting-package-names        ; Condition Type (implemented)
           #:conflicting-symbol-names         ; Condition Type (implemented)
           #:list-peer-packages               ; Function (implemented)
           #:package-does-not-exist           ; Condition Type (implemented)
           #:package-error-conflicting-name   ; Function (implemented)
           #:package-error-conflicting-symbol ; Function (implemented)
           #:package-error-context            ; Function (implemented)
           #:package-error-message            ; Function (implemented)
           #:package-error-symbol             ; Function (implemented)
           #:package-is-a-system-package      ; Condition Type (implemented)
           #:package-is-in-use                ; Condition Type (implemented)
           #:package-is-the-current-package   ; Condition Type (implemented)
           #:package-internal-list            ; Function (implemented)
           #:package-internal-to-list         ; Function (implemented)
           #:package-package                  ; Function (implemented)
           #:package-symbol-error             ; Condition Type (implemented)
           #:symbol-is-not-accessible         ; Condition Type (implemented)
           #:*keyword*                        ; Variable (implemented)
           #:*lisp*                           ; Variable (implemented)
           #:*packages*                       ; Variable (implemented)
           #:*user*)                          ; Variable (implemented)

  ;; Restarts
  ;;
  ;; Some names are also exported as functions/macros above.

  (:export #:abort                            ; offered by import.
           #:continue                         ; offered by delete-package.
           #:delete-package                   ; offered by rename-package and make-package.
           #:import                           ; offered by export and unexport.
           #:keep-old                         ; offered by use-package.
           #:shadow                           ; offered by export and import.
           #:take-new                         ; offered by use-package.
           #:unintern                         ; offered by export and import.
           #:unuse-package                    ; offered by delete-package.
           #:use-value))                      ; offered by add-package-local-nickname.
