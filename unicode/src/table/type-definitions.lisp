;;;; This is "src/table/type-definitions.lisp".
;;;;
;;;;   Here we define the base structure, table, the public table structures
;;;;   property-table, property-map, code-point-map, and string-map, as well
;;;;   as their constituent types.
;;;;
;;;;   We also define constructor functions for every type, excepting the
;;;;   entry type (a code point or a range, defined in #:unciode.code-point).

(in-package #:unicode.table)

;;; ============================================================================
;;; Filters
;;; ============================================================================

(deftype filter ()
  "256 bits used for rapid preliminary checking based on the initial UTF-8 octet."
  `(simple-bit-vector 256))


(declaim (ftype (function ()
                          filter)
                make-filter))

(defun make-filter ()
  (make-array 256 :element-type 'bit :initial-element 0))

;;; ============================================================================
;;; Buckets
;;;
;;; Note that the to-octets buckets use four octets for every code point. This
;;; means that we can lookup using index * 4 later. If we used a variable
;;; number of octets for each code point we would have to traverse the bucket
;;; to find index n.
;;; ============================================================================

(deftype buckets ()
  "One bucket for each UTF-8 encoding length."
  `(simple-vector 4))


(declaim (ftype (function (sequence)
                          buckets)
                make-from-octets make-to-octets make-to-properties make-to-strings)

         (ftype (function ()
                          buckets)
                make-adjustable-from-octets make-adjustable-to-octets make-adjustable-to-properties make-adjustable-to-strings))

(defun make-from-octets (buckets)
  (make-array 4 :element-type 'utf-8:octets :initial-contents buckets))

(defun make-adjustable-from-octets ()
  (make-from-octets (loop repeat 4 collect (utf-8:make-adjustable-octets 128))))

(defun make-to-octets (buckets)
  (make-from-octets buckets))

(defun make-adjustable-to-octets ()
  (make-adjustable-from-octets))

(defun make-to-properties (buckets)
  (make-array 4 :element-type 'vector :initial-contents buckets))

(defun make-adjustable-to-properties ()
  (make-to-properties (loop repeat 4 collect (make-array 128 :element-type 'vector :adjustable t :fill-pointer 0))))

(defun make-to-strings (buckets)
  (make-array 4 :element-type '(vector utf-8:octets) :initial-contents buckets))

(defun make-adjustable-to-strings ()
  (make-to-properties (loop repeat 4 collect (make-array 128 :element-type 'utf-8:octets :adjustable t :fill-pointer 0))))


;;; ============================================================================
;;; Tables
;;;
;;; The table structures are initialized with fresh, adjustable bucket
;;; vectors.
;;;
;;; Finished table are intended to contain static vectors where access can be
;;; better optimized. The construction interface in
;;; "src/table/construction.lisp" is responsible for this.
;;;
;;; ============================================================================

(defstruct table
  (filter (make-filter) :type filter)
  (from (make-adjustable-from-octets) :type buckets))

(defstruct (property-table (:include table))
  (property t :type t))

(defstruct (code-point-map (:include table))
  (to (make-adjustable-to-octets) :type buckets))

(defstruct (property-map (:include table))
  (to (make-adjustable-to-properties) :type buckets))

(defstruct (string-map (:include table))
  (to (make-adjustable-to-strings) :type buckets))

;;; ============================================================================
;;; Default Table Values
;;;
;;; We define a group of empty tables (with empty initialization
;;; values). These are used in place of missing data, for example when
;;; generated unicode data files are not found.
;;;
;;; ============================================================================

(declaim (type filter *empty-filter*)
         (type buckets *empty-from-octets* *empty-to-octets* *empty-to-properties* *empty-to-strings*))

(defparameter *empty-filter* (make-filter))
(defparameter *empty-from-octets* (make-from-octets (list utf-8:*empty* utf-8:*empty* utf-8:*empty* utf-8:*empty*)))
(defparameter *empty-to-octets* (make-to-octets (list utf-8:*empty* utf-8:*empty* utf-8:*empty* utf-8:*empty*)))
(defparameter *empty-to-properties* (make-to-properties (list #() #() #() #())))
(defparameter *empty-to-strings* (make-to-strings (list #() #() #() #())))

(declaim (type property-table *empty-property-table*)
         (type property-map *empty-property-map*)
         (type code-point-map *empty-code-point-map*)
         (type string-map *empty-string-map*))

(defparameter *empty-property-table* (make-property-table :filter *empty-filter* :from *empty-from-octets*))
(defparameter *empty-property-map* (make-property-map :filter *empty-filter* :from *empty-from-octets* :to *empty-to-properties*))
(defparameter *empty-code-point-map* (make-code-point-map :filter *empty-filter* :from *empty-from-octets* :to *empty-to-octets*))
(defparameter *empty-string-map* (make-string-map :filter *empty-filter* :from *empty-from-octets* :to *empty-to-strings*))


;;; ============================================================================
;;; Entries
;;;
;;; These are code points or ranges being entered into one of the from-octets
;;; buckets.
;;; ============================================================================

(deftype entry ()
  "A code-point or a range."
  `(or code-point:code-point code-point:range))
