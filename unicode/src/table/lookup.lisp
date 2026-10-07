;;;; This is "src/table/lookup.lisp".
;;;;
;;;;   Here we define the interface for looking up code points in tables:
;;;;
;;;; · (has-property? octets start property-table) → boolean
;;;;
;;;; · (code-point-mapping-of octets start code-point-map) → (or null code-point)
;;;;
;;;; · (property-mapping-of octets start property-map) → (or null property)
;;;;
;;;; · (string-mapping-of octets start string-map) → (or null octets)

(in-package #:unicode.table)


;;; ============================================================================
;;; Internal Lookup and Search Functions
;;; ============================================================================

(declaim (ftype (function (filter utf-8:octets vector:index)
                          boolean)
                in-filter?)

         (ftype (function (utf-8:octets vector:index (vector utf-8:octets))
                          (or null vector:index))
                binary-search))

(defun in-filter? (filter octets index)
  (declare (optimize (speed 3) (safety 0)))
  (plusp (sbit filter (aref octets index))))

(defun binary-search (octets start buckets)
  (let* ((encoding-length (utf-8:encoding-length octets start))
         ;; vector1, start1 and end1 point to the code-point we're looking
         ;; for, and are constant arguments for our compare function.
         (vector1 octets)
         (start1 start)
         (end1 (+ start encoding-length))
         ;; vector2 contains pairs of utf-8 encoded code points denoting
         ;; ranges.
         (vector2 (from-octets buckets encoding-length))
         (range-length (* 2 encoding-length))
         ;; left and right are range indices, not octet indices
         (left 0)
         (right (floor (length vector2) range-length)))
    (loop while (< left right)
          do (let* ((middle (floor (+ left right) 2))
                    ;; range index * length gives octet index
                    (start2 (* middle range-length))
                    (end2 (+ start2 encoding-length)))
               (cond
                 ((minusp (utf-8:compare vector1 start1 end1 vector2 start2 end2))
                  (setf right middle))
                 ((plusp (utf-8:compare vector1 start1 end1 vector2 end2 (+ end2 encoding-length)))
                  (setf left (1+ middle)))
                 (t
                  (return middle)))))))


;;; ============================================================================
;;; Public Interface
;;; ============================================================================

(declaim (ftype (function (utf-8:octets vector:index property-table)
                          (or null t))
                has-property?)
         
         (ftype (function (utf-8:octets vector:index code-point-map)
                          (or null code-point:code-point))
                code-point-mapping-of)
         
         (ftype (function (utf-8:octets vector:index property-map)
                          (or null t))
                property-mapping-of)
         
         (ftype (function (utf-8:octets vector:index string-map)
                          (or null utf-8:octets))
                string-mapping-of))

(defun has-property? (octets start table)
  (when (in-filter? (property-table-filter table) octets start)
    (when (binary-search octets start (property-table-from table))
      (property-table-property table))))

(defun code-point-mapping-of (octets start table)
  (when (in-filter? (code-point-map-filter table) octets start)
    (let ((index (binary-search octets start (code-point-map-from table))))
      (when index
        (utf-8:decode-code-point (to-octets (code-point-map-to table) (utf-8:encoding-length octets start)) (* index 4))))))

(defun property-mapping-of (octets start table)
  (when (in-filter? (property-map-filter table) octets start)
    (let ((index (binary-search octets start (property-map-from table))))
      (when index
        (aref (to-properties (property-map-to table) (utf-8:encoding-length octets start)) index)))))

(defun string-mapping-of (octets start table)
  (when (in-filter? (string-map-filter table) octets start)
    (let ((index (binary-search octets start (string-map-from table))))
      (when index
        (aref (to-properties (string-map-to table) (utf-8:encoding-length octets start)) index)))))
      
