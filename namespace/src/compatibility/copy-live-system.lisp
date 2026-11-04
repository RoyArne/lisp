;;;; This is "namespace/src/compatibility/copy-live-system.lisp".
;;;;
;;;; Initial version of "making a copy of (common-lisp:list-all-packages).
;;;;
;;;;    We copy the system by
;;;;
;;;; 1. make an empty copy of every package.
;;;; 2. for each package intern all the symbols that are at home in that package.
;;;; 3. go through the shadowing list and shadow/shadowing-import everything there.
;;;; 4. do the exports, importing as needed.
;;;; 5. apply use package according to the original package-use-list.

(in-package #:namespace)


(defun live-symbol-package-name (live-symbol)
  (cl:package-name (cl:symbol-package live-symbol)))

(defun live-symbol-home? (live-symbol live-package)
  (eql (cl:symbol-package live-symbol) live-package))


;;; Lookup the copy of a live package or symbol

(defun nonlive-package (live-package)
  (find-package (cl:package-name live-package)))

(defun nonlive-symbol (live-symbol)
  (find-symbol (cl:symbol-name live-symbol) (live-symbol-package-name live-symbol)))

(defun copy-live-packages ()
  ;; Create an empty version of all the packages in the live system.
  (let ((*packages* '()))
    (mapcar 'make-package (mapcar 'cl:package-name (cl:list-all-packages)))
    *packages*))

(defun intern-live-symbols! (live-package)
  ;; Intern all the symbols that are at home in live-package in its copy.
  (cl:do-symbols (live-symbol live-package)
    (when (live-symbol-home? live-symbol live-package)
      (intern (cl:symbol-name live-symbol) (cl:package-name live-package)))))

(defun shadow-live-symbols! (live-package)
  (loop for live-symbol in (cl:package-shadowing-symbols live-package)
        do (if (live-symbol-home? live-symbol live-package)
               (shadow (cl:symbol-name live-symbol) (cl:package-name live-package))
               (shadowing-import (nonlive-symbol live-symbol) (cl:package-name live-package)))))

(defun export-live-symbols! (live-package)
  (cl:do-external-symbols (live-symbol live-package)
    (unless (live-symbol-home? live-symbol live-package)
      (import (nonlive-symbol live-symbol) (cl:package-name live-package)))
    (export (nonlive-symbol live-symbol) (cl:package-name live-package))))

(defun use-live-packages! (live-package)
  (use-package (mapcar 'nonlive-package (cl:package-use-list live-package)) (cl:package-name live-package)))

(defun copy-live-system ()
  (let ((*packages* (copy-live-packages)))
    (mapc 'intern-live-symbols! (cl:list-all-packages))
    (mapc 'shadow-live-symbols! (cl:list-all-packages))
    (mapc 'export-live-symbols! (cl:list-all-packages))
    (mapc 'use-live-packages! (cl:list-all-packages))
    *packages*))

(defmacro with-live-system (&body body)
  `(let ((*packages* (copy-live-system)))
     ,@body))
