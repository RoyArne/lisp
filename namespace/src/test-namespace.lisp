
(defpackage #:test-namespace
  (:use #:common-lisp)
  (:local-nicknames (#:ns #:namespace))
  (:import-from #:fiveam
                #:def-suite
                #:in-suite
                #:test
                #:is
                #:is-true
                #:is-false
                #:signals
                #:run!))

(in-package #:test-namespace)



(defun new-package (name)
  (let ((package (make-instance 'ns:package)))
    (setf (slot-value package 'ns::name)
          (string:string (etypecase name
                           (string:string name)
                           (ns:symbol name)
                           (cl:string name)
                           (cl:symbol (string-downcase (symbol-name name))))))
    package))

(defmacro with-packages ((&rest packages) &body body)
  "Evaluate BODY with PACKAGES created and bound."
  (labels ((walk (spec parent-var)
             (if (symbolp spec)
                 ;; Case 1: Leaf package (symbol)
                 (if parent-var
                     (values `((,spec (let ((obj (new-package ',spec)))
                                        (ns::add-internal-package obj ,parent-var)
                                        obj)))
                             nil)
                     (values `((,spec (new-package ',spec)))
                             spec))
                 ;; Case 2: Package with internal packages (list: home . subs)
                 (let* ((home (first spec))
                        (subs (rest spec))
                        (home-binding
                         (if parent-var
                             `((,home (let ((obj (new-package ',home)))
                                        (ns::add-internal-package obj ,parent-var)
                                        obj)))
                             `((,home (new-package ',home)))))
                        (top-level-ref (if parent-var nil home)))
                   (multiple-value-bind (sub-bindings sub-top-refs)
                       (loop for sub in subs
                             append (multiple-value-bind (b refs)
                                        (walk sub home)
                                      b))
                     (values (nconc home-binding sub-bindings)
                             top-level-ref))))))
    (let ((bindings '())
          (top-level-refs '()))
      (dolist (pkg packages)
        (multiple-value-bind (b ref) (walk pkg nil)
          (setf bindings (nconc bindings b))
          (when ref
            (push ref top-level-refs))))
      (setf top-level-refs (nreverse top-level-refs))
      `(let* (,@bindings
              (ns::*packages* (list ,@top-level-refs))
              (ns::*package* (first ns::*packages*)))
         ,@body))))
        
  
(def-suite namespace)
(in-suite namespace)

