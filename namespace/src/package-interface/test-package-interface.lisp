;;;; This is "namespace/src/package-interface/test-package-interface.lisp".

(in-package #:test-namespace)

(def-suite test-package-interface :in namespace)
(in-suite test-package-interface)

;; (test make-package
;;   (with-packages (p1 (p2 (p3 p4)))
;;     (is-true (typep (ns::make-package "p5") 'ns::package))
;;     (signals ns::conflicting-package-names (ns::make-package "p5"))
;;     (is-true (typep (ns::make-package "p5" :home p4) 'ns::package))))


;;; IN-PACKAGE
;;; ==========
;;;
;;; the tests make use of *package*

(test in-package-in-the-top-level
  (with-packages (p1 p2)
    (is (eql ns:*package* p1))
    (is (eql p2 (ns:in-package "p2")))
    (is (eql ns:*package* p2))))

(test in-package-switch-to-same-package
  (with-packages (p1 p2)
    (is (eql p1 (ns:in-package "p1")))
    (is (eql ns:*package* p1))))

(test in-package-using-internal-packages
  (with-packages ((p1 p2) (p3))
    (is (eql p2 (ns:in-package "p2")))
    (is (eql ns:*package* p2))
    (is (eql p3 (ns:in-package "p3")))
    (is (eql ns:*package* p3))))

(test in-package-signals-package-does-not-exist
  (with-packages (p1)
    (signals ns:package-does-not-exist (ns:in-package "p4")))
  (with-packages (p1 (p2 p3))
    (signals ns:package-does-not-exist (ns:in-package "p3"))))

;;; LIST-ALL-PACKAGES and LIST-PEER-PACKAGES
;;; ========================================

(test list-all-packages-at-top-level
  (with-packages (p1 p2 p3 p4)
    (is-true (every 'eql ns:*packages* (ns:list-all-packages))))
  (with-packages ((p1 p2) (p3 p4))
    (is-true (every 'eql (cons p2 ns:*packages*) (ns:list-all-packages)))))

(test list-all-packages-at-internal-levels
  (with-packages ((p1 (p2 p3)
                      (p4 p5))
                  p6)
    (setf ns:*package* p4)
    (is-true (every 'eql (append (list p5) (list p4 p2) ns:*packages*) (ns:list-all-packages)))))

(test list-peer-packages-at-top-level
  (with-packages ((p1 p2) (p3 p4))
    (is-true (every 'eql ns:*packages* (ns:list-peer-packages)))))

(test list-peer-packages-at-internal-levels
  (with-packages ((p1 (p2 p3)
                      (p4 p5))
                  p6)
    (setf ns:*package* p4)
    (is-true (every 'eql (list p4 p2) (ns:list-peer-packages)))))

;;; INTERN, EXPORT and SYMBOL-PACKAGE
;;; =================================
;;;
;;; intern returns two values,
;;;   the symbol that was found or created, and its status:
;;;   :internal—the symbol was found and present as an internal symbol,
;;;   :external—the symbol was found and present as an external symbol,
;;;   :inherited—the symbol was found and is inherited by use of use-package, or,
;;;   nil—a new symbol was created.
;;;
;;; the tests make use of export, use-package, and, symbol-package, package-shadowing-symbols
;;;

(test intern-in-p1-then-intern-again
  (with-packages (p1)
    (multiple-value-bind (s1 s1-status)
        (ns:intern "s1")
      (is-true (typep s1 'ns:symbol))
      (is-false s1-status)
      (is (string:string= (string:string "s1") (ns:symbol-name s1)))
      (is (eql p1 (ns:symbol-package s1)))
      (multiple-value-bind (f1 f1-status)
          (ns:intern "s1")
        (is (eql s1 f1))
        (is (eql :internal f1-status))))))

(test intern-in-p1-and-export/p2-uses-p1/intern-in-p2
  (with-packages (p1 p2)
    (let ((s1 (ns:intern "s1")))
      (is-true (ns:export s1))
      (multiple-value-bind (f1 f1-status)
          (ns:intern "s1")
        (is (eql s1 f1))
        (is (eql :external f1-status)))
      (is-true (ns:use-package p1 p2))
      (multiple-value-bind (f1 f1-status)
          (ns:intern "s1" p2)
        (is (eql s1 f1))
        (is (eql :inherited f1-status))))))

(test export-signals-symbol-is-not-accessible
  (with-packages (p1 p2)
    (let ((s1 (ns:intern "s1")))
      (signals ns:symbol-is-not-accessible (ns:export s1 "p2"))
      (ns:intern "s1" p2)
      (signals ns:symbol-is-not-accessible (ns:export s1 "p2")))))

(test export-correcting-symbol-is-not-accessible-by-import
  ;; Simple case of correcting by import when there are no conflicts.
  (with-packages (p1 p2)
    (let ((s1 (ns:intern "s1")))
      (is-true (handler-bind ((ns:symbol-is-not-accessible
                                #'(lambda (condition)
                                    (invoke-restart (find-restart 'ns:import condition)))))
                 (ns:export s1 "p2")))
      (multiple-value-bind (s1-2 status)
          (ns:find-symbol "s1" p2)
        (is (eql s1 s1-2))
        (is (eql :external status))))))

(test export-signals-conflicting-symbol-names-during-import
  ;; Verify that correcting by import signals conflicting-symbol-names.
  (with-packages (p1 p2)
    (let ((s1 (ns:intern "s1" p1))
          (s2 (ns:intern "s1" p2)))
      (signals ns:conflicting-symbol-names (handler-bind ((ns:symbol-is-not-accessible
                                                            #'(lambda (condition)
                                                                (invoke-restart (find-restart 'ns:import condition)))))
                                             (ns:export s1 "p2")))
      (multiple-value-bind (s1-2 status)
          (ns:find-symbol "s1" p2)
        (is (eql s2 s1-2))
        (is (eql :internal status))))))

(test export-correct-conflicting-symbol-names-by-unintern
  ;; When using the import correction during symbol-is-not-accessible, we may
  ;; have a conflicting-symbol-names condition with an :internal or :external
  ;; symbol present in the exporting package. We can correct it by uninterning
  ;; the conflicting symbol, then importing.
  (with-packages (p1 p2)
    (let ((s1 (ns:intern "s1" p1))
          (s2 (ns:intern "s1" p2)))
      (is-true (handler-bind ((ns:symbol-is-not-accessible
                                #'(lambda (condition)
                                    (invoke-restart (find-restart 'ns:import condition))))
                              (ns:conflicting-symbol-names
                                #'(lambda (condition)
                                    (invoke-restart (find-restart 'ns:unintern condition)))))
                 (ns:export s1 "p2")))
      (multiple-value-bind (s1-exported status)
          (ns:find-symbol "s1" p2)
        (is (eql s1 s1-exported))
        (is (eql :external status)))
      (is-false (ns:symbol-package s2)))))

(test export-correct-conflicting-symbol-names-by-shadow
  ;; When using the import correction during symbol-is-not-accessible, we may
  ;; have a conflicting-symbol-names condition with an :inherited symbol
  ;; present in the exporting package. We can correct it by shdowing-importing the
  ;; new symbol.
  (with-packages (p1 p2 p3)
    (let ((s1 (ns:intern "s1" p1))
          (s3 (ns:intern "s1" p3)))
      (is-true (ns:export s3 p3))
      (is-true (ns:use-package p3 p2))
      (is-true (handler-bind ((ns:symbol-is-not-accessible
                                #'(lambda (condition)
                                    (invoke-restart (find-restart 'ns:import condition))))
                              (ns:conflicting-symbol-names
                                #'(lambda (condition)
                                    (invoke-restart (find-restart 'ns:shadow condition)))))
                 (ns:export s1 p2)))
      (multiple-value-bind (s1-exported status)
          (ns:find-symbol "s1" p2)
        (is (eql s1 s1-exported))
        (is (eql :external status)))
      (is-true (find s1 (ns:package-shadowing-symbols p2))))))
  

;;; USE-PACKAGE
;;; ===========
;;;
;;; use-package accepts a DESIGNATOR for a LIST of PACKAGE DESIGNATORs
;;;
;;; it signals conflicting-symbol-names with options to keep-old and take-new
;;;
;;; the tests make use of package-use-list, package-used-by-list, export,
;;; intern, find-symbol, and, symbol-package
;;;
;;; we can consider package-use-list and package-used-by-list tested.

(test use-package-with-string-designators
  (with-packages (p1 p2 p3 p4)
    (is-true (ns:use-package "p2"))
    (is (eql p2 (find p2 (ns:package-use-list p1))))
    (is (eql p1 (find p1 (ns:package-used-by-list p2))))
    (is-true (ns:use-package (list "p1" "p2" "p3") p4))
    (is (eql p1 (find p1 (ns:package-use-list p4))))
    (is (eql p2 (find p2 (ns:package-use-list p4))))
    (is (eql p3 (find p3 (ns:package-use-list p4))))
    (is (eql p4 (find p4 (ns:package-used-by-list p1))))
    (is (eql p4 (find p4 (ns:package-used-by-list p2))))
    (is (eql p4 (find p4 (ns:package-used-by-list p3))))))

(test use-package-with-package-objects
  (with-packages (p1 p2 p3 p4)
    (is-true (ns:use-package p2))
    (eql p2 (find p2 (ns:package-use-list p1)))
    (eql p1 (find p1 (ns:package-used-by-list p2)))
    (is-true (ns:use-package (list p1 p2 p3) p4))
    (is (eql p1 (find p1 (ns:package-use-list p4))))
    (is (eql p2 (find p2 (ns:package-use-list p4))))
    (is (eql p3 (find p3 (ns:package-use-list p4))))
    (is (eql p4 (find p4 (ns:package-used-by-list p1))))
    (is (eql p4 (find p4 (ns:package-used-by-list p2))))
    (is (eql p4 (find p4 (ns:package-used-by-list p3))))))

(test use-package-with-package-designators
  (with-packages (p1 p2 p3 p4)
    (is-true (ns:use-package (list p1 "p2" p3) p4))
    (is (eql p1 (find p1 (ns:package-use-list p4))))
    (is (eql p2 (find p2 (ns:package-use-list p4))))
    (is (eql p3 (find p3 (ns:package-use-list p4))))
    (is (eql p4 (find p4 (ns:package-used-by-list p1))))
    (is (eql p4 (find p4 (ns:package-used-by-list p2))))
    (is (eql p4 (find p4 (ns:package-used-by-list p3))))))

(test use-package-signals-conflicting-symbol-names
  (with-packages (p1 p2)
    (ns:export (ns:intern "s1" p1) p1)
    (ns:intern "s1" p2)
    (signals ns:conflicting-symbol-names (ns:use-package p1 p2))))

(test use-package-resolve-name-conflict-by-keeping-old
  ;; p2 is using p1, the old symbol is the one in p2
  (with-packages (p1 p2)
    (ns:export (ns:intern "s1" p1) p1)
    (ns:intern "s1" p2)
    (is-true (handler-bind ((ns:conflicting-symbol-names
                              #'(lambda (condition)
                                  (invoke-restart (find-restart 'ns:keep-old condition)))))
               (ns:use-package p1 p2)))
    (is (eql p2 (ns:symbol-package (ns:find-symbol "s1" p2))))))

(test use-package-resolve-name-conflict-by-taking-new
  ;; p2 is using p1, the new symbol is the one in p1
  (with-packages (p1 p2)
    (ns:export (ns:intern "s1" p1) p1)
    (ns:intern "s1" p2)
    (is-true (handler-bind ((ns:conflicting-symbol-names
                              #'(lambda (condition)
                                  (invoke-restart (find-restart 'ns:take-new condition)))))
               (ns:use-package p1 p2)))
    (is (eql p1 (ns:symbol-package (ns:find-symbol "s1" p2))))))

(test use-package-signals-package-does-not-exist
  (with-packages (p1)
    (signals ns:package-does-not-exist (ns:use-package "p2"))))

(test use-package-signals-package-does-not-exist-on-non-visible-internal-package
  (with-packages (p1 (p2 p3))
    (signals ns:package-does-not-exist (ns:use-package "p3"))))

(test use-package-top-level-using-internal-package
  (with-packages ((p1 p2))
    (is-true (ns:use-package "p2"))
    (is (eql p2 (find p2 (ns:package-use-list p1))))
    (is (eql p1 (find p1 (ns:package-used-by-list p2))))))

(test use-package-internal-using-lower-level-packages
  (with-packages ((p1 (p2 p3 p4)))
    (setf ns:*package* p2)
    (is-true (ns:use-package (list p3 p4)))
    (is (eql p3 (find p3 (ns:package-use-list p2))))
    (is (eql p2 (find p2 (ns:package-used-by-list p3))))
    (is (eql p4 (find p4 (ns:package-use-list p2))))
    (is (eql p2 (find p2 (ns:package-used-by-list p4))))))

(test use-package-internal-using-higher-level-packages
  (with-packages ( p1
                  (p2 (p3  p4)
                       p5)
                   p6)
    (setf ns:*package* p4) ; visible = (p4 p5 p3 p1 p2 p6), all are higher level
    (is-true (ns:use-package (list p1 p3 p5 "p6" "p2")))
    (is (eql p1 (find p1 (ns:package-use-list p4))))
    (is (eql p2 (find p2 (ns:package-use-list p4))))
    (is (eql p3 (find p3 (ns:package-use-list p4))))
    (is (eql p5 (find p5 (ns:package-use-list p4))))
    (is (eql p6 (find p6 (ns:package-use-list p4))))
    (is (eql p4 (find p4 (ns:package-used-by-list p1))))
    (is (eql p4 (find p4 (ns:package-used-by-list p2))))
    (is (eql p4 (find p4 (ns:package-used-by-list p3))))
    (is (eql p4 (find p4 (ns:package-used-by-list p5))))
    (is (eql p4 (find p4 (ns:package-used-by-list p6))))))


;;; UNUSE-PACKAGE
;;; =============
;;;
;;; unuse-package accepts a DESIGNATOR for a LIST of PACKAGE DESIGNATORs
;;;
;;; the tests make use of use-package abnd find-symbol.

(test unuse-package-with-string-designators
    (with-packages (p1 p2 p3 p4)
      (ns:use-package "p2")
      (is-true (ns:unuse-package "p2"))
      (is-false (find p2 (ns:package-use-list p1)))
      (is-false (find p1 (ns:package-used-by-list p2)))
      (ns:use-package (list "p1" "p2" "p3") p4)
      (is-true (ns:unuse-package (list "p1" "p2" "p3") p4))
      (is-false (find p1 (ns:package-use-list p4)))
      (is-false (find p2 (ns:package-use-list p4)))
      (is-false (find p3 (ns:package-use-list p4)))
      (is-false (find p4 (ns:package-used-by-list p1)))
      (is-false (find p4 (ns:package-used-by-list p2)))
      (is-false (find p4 (ns:package-used-by-list p3)))))

(test unuse-package-imported-symbols-still-accessible
  (with-packages (p1 p2)
    (ns:export (ns:intern "s1"))
    (ns:import (ns:find-symbol "s1" p1) p2)
    (ns:use-package "p1" p2)
    (ns:unuse-package "p1" p2)
    (is (eql (ns:find-symbol "s1" p1) (ns:find-symbol "s1" p2)))))


;;; FIND-SYMBOL
;;; ===========
;;;
;;; the tests make use of intern, export, import, use-package.

(test find-symbol-no-matches
  (with-packages (p1 p2)
    (multiple-value-bind (s1 status)
        (ns:find-symbol "s1")
      (is-false s1)
      (is-false status))
    (multiple-value-bind (s1 status)
        (ns:find-symbol "s1" p2)
      (is-false s1)
      (is-false status))
    (ns:intern "s1" p2)
    (multiple-value-bind (s1 status)
        (ns:find-symbol "s1")
      (is-false s1)
      (is-false status))))

(test find-symbol-matches
  (with-packages (p1 p2 p3)
    (let ((s1 (ns:intern "s1")))
      (multiple-value-bind (s1-2 status)
          (ns:find-symbol "s1")
        (is (eql s1 s1-2))
        (is (eql :internal status)))
      (is-true (ns:export s1))
      (multiple-value-bind (s1-2 status)
          (ns:find-symbol "s1")
        (is (eql s1 s1-2))
        (is (eql :external status)))
      (is-true (ns:import s1 p2))
      (multiple-value-bind (s1-2 status)
          (ns:find-symbol "s1" p2)
        (is (eql s1 s1-2))
        (is (eql :internal status)))
      (is-true (ns:use-package p1 p3))
      (multiple-value-bind (s1-2 status)
          (ns:find-symbol "s1" p3)
        (is (eql s1 s1-2))
        (is (eql :inherited status))))))


;;; ADD-PACKAGE-LOCAL-NICKNAME, REMOVE-PACKAGE-LOCAL-NICKNAME, PACKAGE-LOCAL-NICKNAMES
;;; ==================================================================================

(test add-package-local-nickname
  (with-packages (p1 p2)
    (let ((nickname (string:string "nickname")))
      (is-false (ns:find-package nickname))
      (is (eql p1 (ns:add-package-local-nickname nickname p2 p1)))
      (is (eql p2 (rest (find nickname (ns:package-local-nicknames p1) :test 'string:string= :key 'first))))
      (is (eql p2 (ns:find-package nickname))))))

(test add-package-local-nickname-signals-package-does-not-exist
  (with-packages (p1)
    (let ((nickname (string:string "nickname")))
      (is-false (ns:find-package nickname))
      (signals ns:package-does-not-exist (ns:add-package-local-nickname nickname "test")))))

(test add-package-local-nickname-signals-conflicting-package-names
  (with-packages (p1 p2 p3)
    (let ((nickname (string:string "nickname")))
      (is (eql p1 (ns:add-package-local-nickname nickname p2 p1)))
      (signals ns:conflicting-package-names (ns:add-package-local-nickname nickname p3 p1)))))

(test remove-package-local-nickname
  (with-packages (p1 p2)
    (let ((nickname (string:string "nickname")))
      (is (eql p1 (ns:add-package-local-nickname nickname p2 p1)))
      (is (eql p2 (ns:find-package nickname)))
      (is-true (ns:remove-package-local-nickname nickname))
      (is-false (ns:find-package nickname))
      (is-false (ns:remove-package-local-nickname nickname)))))

(test local-nicknames-take-precedence-over-package-names
  (with-packages (p1 p2 p3)
    (is (eql p3 (ns:add-package-local-nickname "p2" "p1" p3)))
    (is (eql p2 (ns:find-package "p2")))
    (setf ns:*package* p3)
    (is (eql p1 (ns:find-package "p2")))))

;;; FIND-PACKAGE
;;; ============
;;;
;;; TODO: test find-package with local nicknames.

(test find-package-no-matches
  (with-packages (p1 (p2 p3))
    (is-false (ns:find-package "p4"))
    (is-false (ns:find-package "p5"))
    (is-false (ns:find-package "p3")))) ; p3 exists but is internal and not visible

(test find-package-matches
  (with-packages (p1 (p2 p3))
    (is (eql p1 (ns:find-package "p1")))
    (is (eql p2 (ns:find-package "p2")))
    (is (eql p2 (ns:in-package "p2")))
    (is (eql p3 (ns:find-package "p3")))))

;;; DEFPACKAGE
;;; ==========

(test defpackage-no-options
  (with-packages (p1)
    (let ((p2 (ns:defpackage "p2")))
      (is-true (typep p2 'ns:package))
      (is (eql p2 (ns:find-package "p2")))
      (is (eql p2 (find p2 ns:*packages*)))
      (is-true (null (ns:package-package p2))))))

(test defpackagage-works-on-existing-package
  (with-packages (p1)
    (let ((p1-2 (ns:defpackage "p1")))
      (is (eql p1 p1-2))
      (is (eql p1 (find p1-2 ns:*packages*))))))

(test defpackage-placed-in-home-package-of-current-package
  ;; technically, defpackage-no-options test for this, but we'll make sure it
  ;; works when current package is an internal one.
  (with-packages ((p1 p2))
    (setf ns:*package* p2)
    (let ((p3 (ns:defpackage "p3")))
      (is (eql p1 (ns:package-package p3)))
      (is (eql p3 (find p3 (ns:package-internal-list p1))))
      (is (eql p1 (find p1 (ns:package-internal-to-list p3)))))))

(test defpackage-placed-in-specified-home-package
  (with-packages ((p1 p2))
    (let ((p3 (ns:defpackage "p3"
                (:home "p2"))))
      (is (eql p2 (ns:package-package p3)))
      (is (eql p3 (find p3 (ns:package-internal-list p2))))
      (is (eql p2 (find p2 (ns:package-internal-to-list p3)))))))

(test defpackage-placed-in-specified-top-level
  (with-packages ((p1 p2))
    (let ((p3 (ns:defpackage "p3"
                (:home nil))))
      (is-true (null (ns:package-package p3)))
      (is (eql p3 (find p3 ns:*packages*)))
      (is-true (null (ns:package-internal-to-list p3))))))

;; This gives a compile error (which it should). FIXME: Not sure how it should be tested.
;; (test defpackage-wont-accept-multiple-home-options
;;   (with-packages ((p1 p2))
;;     (signals type-error (ns:defpackage "p3"
;;                           (:home "p1")
;;                           (:home "p2")))))

(test defpackage-uses-package
  ;; The :use option operates by calling use-package, which is tested above.
  (with-packages (p1)
    (let ((p2 (ns:defpackage "p2"
                (:use "p1"))))
      (is (eql p1 (find p1 (ns:package-use-list p2))))
      (is (eql p2 (find p2 (ns:package-used-by-list p1))))
      (let ((p3 (ns:defpackage "p3"
                  (:use "p1" "p2"))))
        (is (eql p1 (find p1 (ns:package-use-list p3))))
        (is (eql p3 (find p3 (ns:package-used-by-list p1))))
        (is (eql p2 (find p2 (ns:package-use-list p3))))
        (is (eql p3 (find p3 (ns:package-used-by-list p2))))))
    ;; Finally make sure :use with no parameters is ok.
    (is-true (typep (ns:defpackage "p4"
                      (:use))
                    'ns:package))))
      
(test defpackage-use-signals-package-does-not-exist
  (with-packages (p1)
    (signals ns:package-does-not-exist (ns:defpackage "p2"
                                         (:use "p3")))))

(test defpackage-assigns-local-nicknames
  (with-packages (p1 p2)
    (let ((p3 (ns:defpackage "p3"
                (:local-nicknames ("pkg1" "p1")
                                  ("pkg2" "p2")))))
      (setf ns:*package* p3)
      (is (eql p1 (ns:find-package "pkg1")))
      (is (eql p2 (ns:find-package "pkg2"))))))

(test defpackage-allows-empty-shadow-option
  (with-packages (p1)
    (is-true (typep (ns:defpackage "p2"
                      (:shadow))
                    'ns:package))))

(test defpackage-adds-shadowing-symbols
  (with-packages (p1)
    (let ((p2 (ns:defpackage "p2"
                (:shadow "test" "abc" "def"))))
      (setf ns:*package* p2)
      (eql :internal (nth-value 1 (ns:find-symbol "test")))
      (eql :internal (nth-value 1 (ns:find-symbol "abc")))
      (eql :internal (nth-value 1 (ns:find-symbol "def")))
      (is (eql (ns:find-symbol "abc")
               (find (ns:find-symbol "abc") (ns:package-shadowing-symbols p2)))))))

(test defpackage-allows-shadowing-import-from-option-with-package-and-no-symbols
  (with-packages (p1)
    (is-true (typep (ns:defpackage "p2"
                      (:shadowing-import-from "p1"))
                    'ns:package))))

(test defpackage-shadowing-imports-symbols
  (with-packages (p1)
    (let ((a (ns:intern "a" p1))
          (b (ns:intern "b" p1))
          (c (ns:intern "c" p1)))
      (is-true (ns:export (list a b c) p1))
      (let ((p2 (ns:defpackage "p2"
                  (:shadowing-import-from "p1" "a" "b" "c"))))
        (setf ns:*package* p2)
        (is (eql a (ns:find-symbol "a")))
        (is (eql b (ns:find-symbol "b")))
        (is (eql c (ns:find-symbol "c")))
        (is (eql a (find a (ns:package-shadowing-symbols p2))))
        (is (eql b (find b (ns:package-shadowing-symbols p2))))
        (is (eql c (find c (ns:package-shadowing-symbols p2))))))))

(test defpackage-shadowing-import-signals-symbol-is-not-accessible 
  (with-packages (p1)
    (signals ns:symbol-is-not-accessible (ns:defpackage "p2"
                                           (:shadowing-import-from "p1" "a")))))

(test defpackage-allows-import-from-option-with-package-and-no-symbols
  (with-packages (p1)
    (is-true (typep (ns:defpackage "p2"
                      (:import-from "p1"))
                    'ns:package))))

(test defpackage-imports-symbols
  (with-packages (p1)
    (let ((a (ns:intern "a" p1))
          (b (ns:intern "b" p1))
          (c (ns:intern "c" p1)))
      (is-true (ns:export (list a b c) p1))
      (let ((p2 (ns:defpackage "p2"
                  (:import-from "p1" "a" "b" "c"))))
        (setf ns:*package* p2)
        (is (eql a (ns:find-symbol "a")))
        (is (eql b (ns:find-symbol "b")))
        (is (eql c (ns:find-symbol "c")))))))

(test defpackage-import-signals-symbol-is-not-accessible 
  (with-packages (p1)
    (signals ns:symbol-is-not-accessible (ns:defpackage "p2"
                                           (:import-from "p1" "a")))))

(test defpackage-allows-empty-intern-option
  (with-packages (p1)
    (is-true (typep (ns:defpackage "p2"
                      (:intern))
                    'ns:package))))

(test defpackage-interns-symbols
  (with-packages (p1)
    (let ((p2 (ns:defpackage "p2"
                (:intern "a" "b" "c"))))
      (setf ns:*package* p2)
      (multiple-value-bind (symbol status)
          (ns:find-symbol "a")
        (is (eql p2 (ns:symbol-package symbol)))
        (is (eql :internal status))))))

(test defpackage-allows-empty-export-option
  (with-packages (p1)
    (is-true (typep (ns:defpackage "p2"
                      (:export))
                    'ns:package))))

(test defpackage-exports-symbols
  (with-packages (p1)
    (let ((p2 (ns:defpackage "p2"
                (:export "a" "b" "c"))))
      (setf ns:*package* p2)
      (multiple-value-bind (symbol status)
          (ns:find-symbol "a")
        (is (eql p2 (ns:symbol-package symbol)))
        (is (eql :external status))))))
