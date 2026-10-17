;;;; This is "namespace/src/internal-structure/package-manipulation.lisp".
;;;;
;;;;   Here we define functions to:
;;;;
;;;; · search the hierarchy for named packages,
;;;; · place packages at the top-level,
;;;; · remove packages from the top-level,
;;;; · place internal packages, and
;;;; · remove internal package.
;;;;
;;;;   Functions that search for symbols in packages, and place and remove
;;;;   them from packages are found in "symbol-manipulation.lisp".

(in-package #:namespace)

;;; Local Package Nicknames

(declaim (ftype (function (string package)
                          (or null cons))
                find-local-nickname)

         (ftype (function (string package package)
                          (values))
                add-local-nickname!)
         
         (ftype (function (string package)
                          (values))
                remove-local-nickname!))

(defun find-local-nickname (nickname package)
  (assoc nickname (local-nicknames package) :test 'string=))

(defun add-local-nickname! (nickname actual-package package)
  (with-slots (local-nicknames) package
    (setf local-nicknames (acons nickname actual-package local-nicknames)))
  (values))

(defun remove-local-nickname! (old-nickname package)
  (with-slots (local-nicknames) package
    (let ((nickname (find-local-nickname old-nickname package)))
      (when nickname
        (setf local-nicknames (remove nickname local-nicknames)))))
  (values))


;;; Getting the Home Package

(declaim (ftype (function (context-designator)
                          context-designator)
                home-package))

(defun home-package (context-designator)
  "Returns the home package of PACKAGE. Returns NIL for top-level packages."
  (etypecase context-designator
    (null nil)
    (package (first (internal-to-list context-designator)))))


;;; Searching for Packages

(declaim (ftype (function (context-designator)
                          list)
                visible-list)

         (ftype (function (string package)
                          (or null package))
                find-visible-package))

(defun visible-list (context-designator)
  (etypecase context-designator
    (null *packages*)
    (package (append (internal-list context-designator)
                     (visible-list (home-package context-designator))))))

(defun find-visible-package (name package)
  (or (rest (find-local-nickname name package))
      (find name (visible-list package) :test 'string= :key 'name)))


;;; Checking for Package Name Conflicts

(declaim (ftype (function (package)
                          list)
                peer-list)

         (ftype (function (context-designator)
                          list)
                conflict-list)

         (ftype (function (string context-designator)
                          (or null package))
                find-conflicting-package))

(defun peer-list (package)
  "Returns a list of packages that has the same home package as PACKAGE."
  (let ((home (home-package package)))
    (etypecase home
      (null *packages*)
      (package (internal-list home)))))

(defun conflict-list (context-designator)
  "Returns a list of packages that must be checked for name conflicts when naming
a package whos home package is CONTEXT-DESIGNATOR."
  (etypecase context-designator
    (null *packages*)
    (package (append (peer-list context-designator)
                     (internal-to-list context-designator)))))

(defun find-conflicting-package (name context-designator)
  "Return a package that would cause a name conflict if a new package named NAME
was created with PACKAGE as its home package. Returns NIL if there is no such
package."
  ;; CONSIDER: Since we always check for name conflicts when creating,
  ;;           renaming, and, moving packages, there should never be more than
  ;;           one conflict, right?
  (find name (conflict-list (home-package context-designator)) :test 'string= :key 'name))


;;; Adding and Removing top-level packages.

(declaim (ftype (function (package)
                          package)
                remove-top-level-package
                add-top-level-package))

(defun remove-top-level-package (package)
  (setf *packages* (remove package *packages*))
  package)

(defun add-top-level-package (package)
  (push package *packages*)
  (setf (slot-value package 'internal-to-list) '())
  package)


;;; Adding and Removing Internal Packages

(declaim (ftype (function (package)
                          (values))
                update-internal-to-lists!)
                          
         (ftype (function (package package)
                          package)
                remove-internal-package
                add-internal-package))

(defun update-internal-to-lists! (package)
  (loop for internal-package in (internal-list package)
        do (setf (slot-value internal-package 'internal-to-list) (cons package (slot-value package 'internal-to-list)))
        do (update-internal-to-lists! internal-package))
  (values))

(defun remove-internal-package (package home)
  (setf (slot-value home 'internal-list) (remove package (slot-value home 'internal-list))
        (slot-value package 'internal-to-list) '())
  (update-internal-to-lists! package)
  package)
  
(defun add-internal-package (package home)
  (push package (slot-value home 'internal-list))
  (setf (slot-value package 'internal-to-list) (cons home (internal-to-list home)))
  (update-internal-to-lists! package)
  package)


;;; Adding and Removing Packages

(declaim (ftype (function (package context-designator)
                          package)
                remove-package
                add-package))

(defun remove-package (package home)
  (etypecase home
    (null (remove-top-level-package package))
    (package (remove-internal-package package home)))) 

(defun add-package (package home)
  (etypecase home
    (null (add-top-level-package package))
    (package (add-internal-package package home)))) 


;;; Updating the Used By List

(declaim (ftype (function (package package)
                          (values))
                remove-from-used-by-list!
                add-to-use-list!)

         (ftype (function (package)
                          (values))
                clear-use-list!))


(defun remove-from-used-by-list! (using-package used-package)
  (with-slots (use-list) using-package
    (with-slots (used-by-list) used-package
      (setf used-by-list (remove using-package used-by-list)
            use-list (remove used-package use-list))))
  (values))

(defun clear-use-list! (package)
  (loop for used-package in (use-list package)
        do (with-slots (used-by-list) used-package
             (setf used-by-list (remove package used-by-list))))
  (setf (slot-value package 'use-list) '())
  (values))

(defun add-to-use-list! (using-package used-package)
  (push using-package (slot-value used-package 'used-by-list))
  (push used-package (slot-value using-package 'use-list))
  (values))
