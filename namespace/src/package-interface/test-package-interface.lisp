;;;; This is "namespace/src/package-interface/test-package-interface.lisp".

(in-package #:test-namespace)

(def-suite test-package-interface :in namespace)
(in-suite test-package-interface)

(test make-package
  (with-packages (p1 (p2 (p3 p4)))
    (is-true (typep (ns::make-package "p5") 'ns::package))
    (signals ns::conflicting-package-names (ns::make-package "p5"))
    (is-true (typep (ns::make-package "p5" :home p4) 'ns::package))))


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
;;; the tests make use of export, use-package, and, symbol-package
;;; we can consider export and symbol-package tested

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

;;; USE-PACKAGE
;;; ===========
;;;
;;; use-package accepts a DESIGNATOR for a LIST of PACKAGE DESIGNATORs
;;;
;;; it signals conflicting-symbol-names with options to keep-old and take-new
;;;
;;; the tests make use of export, intern, and, symbol-package

(test use-package-with-string-designators
  (with-packages (p1 p2 p3 p4)
    (is-true (ns:use-package "p2"))
    (is-true (ns:use-package (list "p1" "p2" "p3") p4))))

(test use-package-with-package-objects
  (with-packages (p1 p2 p3 p4)
    (is-true (ns:use-package p2))
    (is-true (ns:use-package (list p1 p2 p3) p4))))

(test use-package-with-package-designators
  (with-packages (p1 p2 p3 p4)
    (is-true (ns:use-package (list p1 "p2" p3) p4))))

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

