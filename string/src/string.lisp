
(defpackage #:string
  (:use #:common-lisp)

  ;; 16.2 The Strings Dictionary
  ;;   (https://www.lispworks.com/documentation/HyperSpec/Body/c_string.htm)
  ;;
  (:shadow #:string
           ;; do we do simple-string and simple-base-string?
           #:base-string
           #:simple-string
           #:simple-base-string
           
           ;; our predicates end with ?: simple-string?
           #:simple-string-p
           
           ;; schar is pointless without simple-string
           #:char
           #:schar

           ;; we can do upcase, downcase and capitalize
           ;; nstring-<x> doesn't make sense when we do immutable strings
           #:string-upcase #:string-downcase #:string-capitalize
           #:nstring-upcase #:nstring-downcase #:nstring-capitalize

           ;; tring, left-trim and right-trim. Could be for sequences generally.
           #:string-trim #:string-left-trim #:string-right-trim

           ;; We want to use special characters like ≠. They should be easily composable.
           #:string= #:string/= ; string≠ 
           #:string< #:string>
           #:string<= #:string>= ; string≤ string≥
           
           ;; again, predicates end with ?
           #:string-equal #:string-not-equal
           #:string-lessp #:string-greaterp ; string-less? string-not-less?
           #:string-not-greaterp #:string-not-lessp ; do we want these?
           #:stringp ; string?
           #:make-string)

  (:export #:string

           #:char

           #:upcase #:downcase #:capitalize

           #:string= #:string≠
           #:string< #:string>
           #:string≤ #:string≥

           #:string-equal #:string-not-equal
           #:string-less? #:string-greater?

           #:string?
           #:make-string))
