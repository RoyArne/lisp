
(in-package #:test-namespace)

(def-suite test-classes :in namespace)
(in-suite test-classes)

(test package-classes
  (is-true (typep (make-instance 'ns:package) 'ns:package))
  (is-true (typep (make-instance 'ns:symbol) 'ns:symbol)))

(test package-class-slots
  (let ((p (make-instance 'ns:package)))
    (is (null (ns::name p)))
    (is (null (ns::local-nicknames p)))
    (is (null (ns::internal-list p)))
    (is (null (ns::internal-to-list p)))
    (is (null (ns::use-list p)))
    (is (null (ns::used-by-list p)))
    (is (hash-table-p (ns::internal-symbols p)))
    (is (hash-table-p (ns::external-symbols p)))
    (is (null (ns::shadowing-symbols p)))))

(test symbol-class-slots
  (let ((s (make-instance 'ns:symbol)))
    (is (string:string? (ns::name s)))
    (is (null (ns::package s)))))
