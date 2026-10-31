;;;; This is "namespace/src/internal-structure/name-validation.lisp".
;;;;
;;;; FIXME: validation of package and symbol names happens in this file.
;;;;        for now we only assign the values given.
;;;;
;;;; [Unicode Security Mechanisms](http://www.unicode.org/reports/tr39/),
;;;; [Unicode Identifiers and Syntax](https://www.unicode.org/reports/tr31/)

(in-package #:namespace)

(defgeneric (setf name) (name object)
  ;;; Methods for package objects.
  ;;;
  ;;; We accept strings and nil. nil is supplied if the package is deleted.
  (:method ((name null) (package package))
    (setf (slot-value package 'name) name))
  (:method ((name string) (package package))
    (setf (slot-value package 'name) name))

  ;;; Methods for symbol objects.
  ;;;
  ;;; We accept strings.
  (:method ((name string) (symbol symbol))
    (setf (slot-value symbol 'name) name)))
