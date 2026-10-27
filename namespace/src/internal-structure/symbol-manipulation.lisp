;;;; This is "namespace/src/internal-structure/symbol-manipulation.lisp".
;;;;
;;;;   Here we define functions to:
;;;;
;;;; · search for symbols in a packages internal and external tables,
;;;; · search for symbols in a packages list of shadowing symbols, and
;;;; · add and remove symbols from the above places.
;;;;
;;;;    Functions that manipulate the package objects are found in
;;;;    "package-manipulation.lisp".

(in-package #:namespace)

;;; Finding Symbols

(declaim (inline find-symbol-in-table)

         (ftype (function (string hash-table)
                          (values (or null symbol) boolean))
                find-symbol-in-table)
                
         (ftype (function (string package)
                          (values (or null symbol) boolean))
                find-internal-symbol
                find-external-symbol
                find-shadowing-symbol)

         (ftype (function (string package)
                          (values (or null symbol) (or null common-lisp:keyword)))
                find-present-symbol))

(defun find-symbol-in-table (name table)
  (gethash name table))

(defun find-internal-symbol (name package)
  (find-symbol-in-table name (internal-symbols package)))

(defun find-external-symbol (name package)
  (find-symbol-in-table name (external-symbols package)))

(defun find-shadowing-symbol (name package)
  (let ((symbol (find name (shadowing-symbols package) :test 'string= :key 'name)))
    (values symbol (and symbol t))))

(defun find-present-symbol (name package)
  (multiple-value-bind (symbol internal?)
      (find-internal-symbol name package)
    (if internal?
        (values symbol :internal)
        (multiple-value-bind (symbol external?)
            (find-external-symbol name package)
          (if external?
              (values symbol :external)
              (values nil nil))))))

;;; Iterating Across Symbols
;;;
;;; We name them process-x to distinguish them from do-x-symbols.

(defmacro process-internal-symbols ((symbol package) &body body)
  `(loop for ,symbol being each hash-value of (internal-symbols ,package)
         do (progn ,@body)))

(defmacro process-external-symbols ((symbol package) &body body)
  `(loop for ,symbol being each hash-value of (external-symbols ,package)
         do (progn ,@body)))

(defmacro process-shadowing-symbols ((symbol package) &body body)
  `(loop for ,symbol in (shadowing-symbols ,package)
         do (progn ,@body)))
  
         

(declaim (ftype (function (symbol package)
                          boolean)
                shadowing-symbol?))

(defun shadowing-symbol? (symbol package)
  (and (find symbol (shadowing-symbols package)) t))
    
;;; Adding Symbols

(declaim (inline add-symbol-to-table)
         
         (ftype (function (symbol hash-table)
                          symbol)
                add-symbol-to-table)
         
         (ftype (function ((or string symbol) package)
                          symbol)
                symbol-to-add
                add-internal-symbol
                add-external-symbol
                add-shadowing-symbol))

(defun symbol-to-add (name package)
  (etypecase name
    (string (make-instance 'symbol :name name :package package))
    (symbol name)))

(defun add-symbol-to-table (symbol table)
  (setf (gethash (name symbol) table) symbol))

(defun add-internal-symbol (name package)
  (add-symbol-to-table (symbol-to-add name package) (internal-symbols package)))

(defun add-external-symbol (name package)
  (add-symbol-to-table (symbol-to-add name package) (external-symbols package)))

(defun add-shadowing-symbol (name package)
  (let ((symbol (symbol-to-add name package)))
    (pushnew symbol (slot-value package 'shadowing-symbols))
    symbol))


;;; Removing Symbols

(declaim (inline remove-symbol-from-table)

         (ftype (function (string hash-table)
                          boolean)
                remove-symbol-from-table)
         
         (ftype (function ((or string symbol))
                          string)
                name-to-remove)

         (ftype (function ((or string symbol) package)
                          boolean)
                remove-internal-symbol
                remove-external-symbol
                remove-shadowing-symbol))

(defun remove-symbol-from-table (name table)
  ;; why?
  ;; (when (eql name (find-symbol-in-table name table))
  (remhash name table))

(defun name-to-remove (name)
  (etypecase name
    (string name)
    (symbol (name name))))

(defun remove-internal-symbol (name package)
  (remove-symbol-from-table (name-to-remove name) (internal-symbols package)))

(defun remove-external-symbol (name package)
  (remove-symbol-from-table (name-to-remove name) (external-symbols package)))

(defun remove-shadowing-symbol (name package)
  (setf (slot-value package 'shadowing-symbols)
        (remove (name-to-remove name) (shadowing-symbols package) :test 'string= :key 'name))
  t)


;;; Clearing the Shadowing Symbols slot

(declaim (ftype (function (package)
                          (values))
                clear-shadowing-symbols!))

(defun clear-shadowing-symbols! (package)
  (setf (slot-value package 'shadowing-symbols) '())
  (values))


;;; Uninterning Symbols

(declaim (ftype (function (package hash-table)
                          (values))
                unintern-symbols-from-table!)

         (ftype (function (package)
                          (values))
                unintern-internal-symbols!
                unintern-external-symbols!
                unintern-shadowing-symbols!))
         
(defun unintern-symbols-from-table! (package table)
  (loop for symbol being the hash-values in table
        when (eql package (slot-value symbol 'package))
        do (setf (slot-value symbol 'package) nil))
  (values))

(defun unintern-internal-symbols! (package)
  (unintern-symbols-from-table! package (internal-symbols package)))

(defun unintern-external-symbols! (package)
  (unintern-symbols-from-table! package (external-symbols package)))

(defun unintern-shadowing-symbols! (package)
  (loop for symbol in (shadowing-symbols package)
        when (eql package (slot-value symbol 'package))
        do (setf (slot-value symbol 'package) nil))
  (values))

