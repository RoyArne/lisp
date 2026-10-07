;;;; This is "src/compatibility.lisp".
;;;;
;;;; We define some methods for compatibility with sbcl.

(in-package #:string)

(defmethod print-object ((object string) stream)
  (print-unreadable-object (object stream :type t)
    (write-string (rope:rope-to-string (slot-value object 'rope)) stream)))

;; Convert Common Lisps string, character and symbol types to our strings.

(defmethod string ((object common-lisp:string))
  (make-instance 'string :rope (utf-8:string-to-octets object)))

(defmethod string ((object common-lisp:character))
  (string (common-lisp:string object)))

(defmethod string ((object common-lisp:symbol))
  (string (common-lisp:string object)))

;; Make custom hash-table tests for our string class.

(defun case-sensitive-string-test (string1 string2)
  (rope:rope= (slot-value string1 'rope) (slot-value string2 'rope)))

(defun string-fnv1a/32-hash (string)
  (rope:rope-fnv-1a/32-hash (slot-value string 'rope)))

(sb-ext:define-hash-table-test case-sensitive-string-test string-fnv1a/32-hash)
