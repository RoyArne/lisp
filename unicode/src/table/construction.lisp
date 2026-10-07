;;;; This is "src/table/construction.lisp".
;;;;
;;;;   Here we define the interface for constructing tables:
;;;;
;;;; · (construct-property-table (property) &body body) → property-table
;;;;     (add-entry code-point/range) → (values)
;;;;
;;;; · (construct-code-point-map () &body body) → code-point-map
;;;;     (add-entry code-point/range code-point) → (values)
;;;;
;;;; · (construct-property-map (&key test) &body body) → property-map
;;;;     (add-entry code-point/range property) → (values)
;;;;
;;;; · (construct-string-map (() &body body) → string-map
;;;;     (add-entry code-point/range octets) → (values)
;;;;
;;;;   The add-entry function is locally available inside the body expression
;;;;   of each macro.

(in-package #:unicode.table)


;;; ============================================================================
;;; Selecting buckets from encoding length
;;; ============================================================================

(declaim (inline from-octets to-octets to-properties to-strings)

         (ftype (function (buckets utf-8:encoding-length)
                          utf-8:octets)
                from-octets to-octets)
         
         (ftype (function (buckets utf-8:encoding-length)
                          vector)
                to-properties)
         
         (ftype (function (buckets utf-8:encoding-length)
                          (vector utf-8:octets))
                to-strings))

(defun from-octets (buckets encoding-length)
  (declare (optimize (speed 3) (safety 0)))
  (aref buckets (1- encoding-length)))

(defun to-octets (buckets encoding-length)
  (declare (optimize (speed 3) (safety 0)))
  (aref buckets (1- encoding-length)))

(defun to-properties (buckets encoding-length)
  (declare (optimize (speed 3) (safety 0)))
  (aref buckets (1- encoding-length)))

(defun to-strings (buckets encoding-length)
  (declare (optimize (speed 3) (safety 0)))
  (aref buckets (1- encoding-length)))


;;; ============================================================================
;;; Investigating and Editing the FROM-OCTETS and TO-OCTETS Bucket
;;; ============================================================================

(declaim (ftype (function (utf-8:octets utf-8:encoding-length)
                          (or null code-point:code-point))
                decode-last-code-point)

         (ftype (function (code-point:code-point utf-8:octets &optional utf-8:encoding-length)
                          (values))
                push-code-point)

         (ftype (function (entry utf-8:octets)
                          (values))
                push-entry)

         (ftype (function (entry utf-8:octets utf-8:encoding-length)
                          (values))
                extend-last-entry))

(defun decode-last-code-point (bucket encoding-length)
  (when (plusp (length bucket))
    (utf-8:decode-code-point bucket (- (length bucket) encoding-length))))

(defun push-code-point (code-point bucket &optional (min-size 1))
  ;; The min-size is used to make every code point in the to-octets buckets
  ;; take up exactly 4 octets. This lets us look up values using an index
  ;; (times four), instead of searching from the start to find the nth code
  ;; point.
  (loop with start = (length bucket)
        with end = (utf-8:push-code-point code-point bucket)
        repeat (- min-size (- end start))
        do (vector-push-extend 0 bucket))
  (values))

(defun push-entry (entry bucket)
  (push-code-point (code-point:start entry) bucket)
  (push-code-point (code-point:end entry) bucket)
  (values))

(defun extend-last-entry (entry bucket encoding-length)
  (utf-8:encode-code-point (code-point:end entry) bucket (- (length bucket) encoding-length))
  (values))


;;; ============================================================================
;;; Adding to the TO-PROPERTY and TO-STRING Buckets
;;; ============================================================================

(declaim (inline push-property push-string)

         (ftype (function (t vector)
                          (values))
                push-property)

         (ftype (function (utf-8:octets (vector utf-8:octets))
                          (values))
                push-string))

(defun push-property (property bucket)
  (vector-push-extend property bucket)
  (values))

(defun push-string (string bucket)
  (vector-push-extend string bucket)
  (values))


;;; ============================================================================
;;; Comparing and Manipulating Entries
;;; ============================================================================

(declaim (inline entry-length)
         
         (ftype (function (entry)
                          (values utf-8:encoding-length utf-8:encoding-length))
                entry-length)
         
         (ftype (function (entry)
                          (values entry (or entry null)))
                split-entry)
         
         (ftype (function (entry (or entry null))
                          boolean)
                contiguous-entries?))

(defun entry-length (entry)
  (values (utf-8:encoded-length (code-point:start entry))
          (utf-8:encoded-length (code-point:end entry))))

(defun split-entry (entry)
  "Splits an entry if it spans across UTF-8 encoded byte length boundaries."
  (multiple-value-bind (n1 n2)
      (entry-length entry)
    (if (/= n1 n2)
        (values (code-point:make-range (code-point:start entry)
                                       (utf-8:octet-range-end n1))
                (code-point:make-range (utf-8:octet-range-start (1+ n1))
                                       (code-point:end entry)))
        (values entry nil))))

(defun contiguous-entries? (current-entry last-entry)
  (and last-entry (= (1+ (code-point:end last-entry))
                     (code-point:start current-entry))))


;;; ============================================================================
;;; Adding Entries to Table Filters and Buckets
;;; ============================================================================

(declaim (ftype (function (entry filter)
                          (values))
                add-to-filter!))

(defun add-to-filter! (entry filter)
  (loop for code-point from (code-point:start entry) upto (code-point:end entry)
        do (setf (sbit filter (utf-8:initial-octet code-point)) 1))
  (values))


(declaim (ftype (function (entry filter (vector utf-8:octets))
                          (values))
                add-entry-to-property-table!)

         (ftype (function (entry code-point:code-point filter (vector utf-8:octets) (vector utf-8:octets)) (values))
                add-entry-to-code-point-map!)

         (ftype (function (entry t (or function symbol) filter (vector utf-8:octets) (vector vector))
                          (values))
                add-entry-to-property-map!)

         (ftype (function (entry utf-8:octets filter (vector utf-8:octets) (vector (vector utf-8:octets)))
                          (values))
                add-entry-to-string-map!))

(defun add-entry-to-property-table! (entry filter from-buckets)
  (add-to-filter! entry filter)
  (loop with current = entry
        while current do
           (multiple-value-bind (head tail)
               (split-entry current)
             (let* ((length (entry-length head))
                    (from (from-octets from-buckets length)))
               (cond
                 ((contiguous-entries? head (decode-last-code-point from length))
                  (extend-last-entry head from length))
                 (t
                  (push-entry head from))))
             (setf current tail))))

(defun add-entry-to-code-point-map! (entry code-point filter from-buckets to-buckets)
  (add-to-filter! entry filter)
  (loop with current = entry
        while current do
           (multiple-value-bind (head tail)
               (split-entry current)
             (let* ((length (entry-length head))
                    (from (from-octets from-buckets length))
                    (to (to-octets to-buckets length)))
               ;; We use 4 octets for every code point in the to bucket for
               ;; easy lookup later. If we used variable space we would have
               ;; to traverse the bucket to find the octet at some index i.
                 (cond
                 ((and (contiguous-entries? head (decode-last-code-point from length))
                       (= code-point (decode-last-code-point to 4)))
                  (extend-last-entry head from length))
                 (t
                  (push-entry head from)
                  (push-code-point code-point to 4))))
             (setf current tail))))

(defun add-entry-to-property-map! (entry property test filter from-buckets to-buckets)
  (add-to-filter! entry filter)
  (loop with current = entry
        while current do
           (multiple-value-bind (head tail)
               (split-entry current)
             (let* ((length (entry-length head))
                    (from (from-octets from-buckets length))
                    (to (to-properties to-buckets length)))
               (cond
                 ((and (contiguous-entries? head (decode-last-code-point from length))
                       (funcall test property (aref to (1- (length to)))))
                  (extend-last-entry head from length))
                 (t
                  (push-entry head from)
                  (push-property property to))))
             (setf current tail))))

(defun add-entry-to-string-map! (entry string filter from-buckets to-buckets)
  (add-to-filter! entry filter)
  (loop with current = entry
        while current do
           (multiple-value-bind (head tail)
               (split-entry current)
             (let* ((length (entry-length head))
                    (from (from-octets from-buckets length))
                    (to (to-strings to-buckets length)))
               (cond
                 ((and (contiguous-entries? head (decode-last-code-point from length))
                       (utf-8:octets= string (aref to (1- (length to)))))
                  (extend-last-entry head from length))
                 (t
                  (push-entry head from)
                  (push-string string to))))
             (setf current tail))))


;;; ============================================================================
;;; Finalizing Tables
;;;
;;; FIXME: The following functions are meant to optimize the arrays in table
;;;        structures such that (declare (optimize (speed 3) (safety 0))
;;;        yields better results.
;;;
;;;        For example, a fixed length array of a specified element type can
;;;        be accessed faster than an adjustable one with a fill poniter.
;;;
;;; ============================================================================

(declaim (ftype (function (property-table)
                          property-table)
                finalize-property-table)
         
         (ftype (function (code-point-map)
                          code-point-map)
                finalize-code-point-map)

         (ftype (function (property-map)
                          property-map)
                finalize-property-map)
         
         (ftype (function (string-map)
                          string-map)
                finalize-string-map))

(defun finalize-property-table (table)
  table)

(defun finalize-code-point-map (table)
  table)

(defun finalize-property-map (table)
  table)

(defun finalize-string-map (table)
  table)


;;; ============================================================================
;;; Macros For Cnstructing Tables
;;; ============================================================================

(defmacro construct-property-table ((property) &body body)
  "
Note that entries MUST be added in ascending order. Otherwise; the lookup
functions will not work, and entries may be merged in unexpected ways."
  (let ((table (gensym "PROPERTY-TABLE")))
    `(let ((,table (make-property-table)))
       (flet ((add-entry (entry)
                (add-entry-to-property-table! entry
                                              (property-table-filter ,table)
                                              (property-table-from ,table))
                (values)))
         ,@body)
       (finalize-property-table ,table))))

(defmacro construct-code-point-map (() &body body)
  "Return a CODE-POINT-MAP constructed by means of the local function ADD-ENTRY:

  \(add-entry from-entry to-code-point\)

where from-entry is either a range or a code-point. For example,

\(construct-code-point-map \(\)
  \(loop for code-point in \(sort \(map 'list #'char-code \"ABCDEFÆØÅ-.,—–·…\"\) #'<\)
        for mapping = \(char-code #\\A\)
        do \(add-entry code-point mapping\)\)\)

constructs a table mapping every character to 'A'.

Note that entries MUST be added in ascending order. Otherwise; the lookup
functions will not work, and entries may be merged in unexpected ways."
  (let ((table (gensym "CODE-POINT-MAP")))
    `(let ((,table (make-code-point-map)))
       (flet ((add-entry (entry code-point)
                (add-entry-to-code-point-map! entry code-point
                                              (code-point-map-filter ,table)
                                              (code-point-map-from ,table) 
                                              (code-point-map-to ,table))
                (values)))
         ,@body)
       (finalize-code-point-map ,table))))

(defmacro construct-property-map ((&key (test 'eql)) &body body)
  "Return a PROPERTY-MAP constructed by means of the local function ADD-ENTRY:

  \(add-entry entry property\)

where entry is either a range or a code-point. The TEST argument must be a
function that accepts two properties and returns T if they are equal \(NIL
otherwise\). For example,

\(construct-property-map \(:test #'=\)
  \(loop for code-point in \(sort (map 'list #'char-code \"ABCDEFÆØÅ-.,—–·…\"\) #'<\)
        for property = \(random 3\)
        do \(add-entry code-point property\)\)\)

constructs a table mapping characters to a random number chosen at
construction time.

Note that entries MUST be added in ascending order. Otherwise; the lookup
functions will not work, and entries may be merged in unexpected ways."
  (let ((table (gensym "PROPERTY-MAP")))
    `(let ((,table (make-property-map)))
       (flet ((add-entry (from property)
                (add-entry-to-property-map! from property
                                            ,test
                                            (property-map-filter ,table)
                                            (property-map-from ,table)
                                            (property-map-to ,table))
                (values)))
         ,@body)
       (finalize-property-map ,table))))

(defmacro construct-string-map (() &body body)
  "
Note that entries must be added in ascending order. Otherwise; the lookup
functions will not work, and entries may be merged in unexpected ways."
  (let ((table (gensym "STRING-MAP")))
    `(let ((,table (make-string-map)))
       (flet ((add-entry (from string)
                (add-entry-to-string-map! from string
                                          (string-map-filter ,table)
                                          (string-map-from ,table)
                                          (string-map-to ,table))
                (values)))
         ,@body)
       (finalize-string-map ,table))))
