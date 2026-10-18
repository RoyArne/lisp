;;;; This is "namespace/src/compatibility/package-interface.lisp".

(in-package #:namespace)

(defmethod find-symbol ((name common-lisp:string) &optional (package *package*))
  (find-symbol (string name) package))

(defmethod intern ((name common-lisp:string) &optional (package *package*))
  (intern (string name) package))
