;;;; This is "namespace/src/compatibility.lisp".

(in-package #:namespace)

(defmethod print-object ((p package) stream)
  (print-unreadable-object (p stream :type t)
    (with-slots (name) p
      (when name
        (format stream "~A" name)))))

(defmethod print-object ((s symbol) stream)
  (print-unreadable-object (s stream :type t)
    (format stream "~A" (symbol-name s))))
