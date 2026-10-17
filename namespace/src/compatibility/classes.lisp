;;;; This is "namespace/src/compatibility/classes.lisp".

(in-package #:namespace)

(defmethod print-object ((package package) stream)
  (print-unreadable-object (package stream :type t)
    (with-slots (name) package
      (when name
        (format stream "~A" name)))))

(defmethod print-object ((symbol symbol) stream)
  (print-unreadable-object (symbol stream :type t)
    (format stream "~A" (name symbol))))
