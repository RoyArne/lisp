
(in-package #:unicode.rope)

;;; Weight Calculations

(declaim (inline weight)
         
         (ftype (function (rope) weight)
                weight compute-subtree-weight))

(defun weight (node)
  "Return the number of octets in NODEs left subtree."
  (declare (optimize (speed 3) (safety 0)))
  (etypecase node
    (utf-8:octets (length node))
    (node (node-weight node))))

(defun compute-subtree-weight (root)
  "Return the number of octets in the ROOT subtree."
  (etypecase root
    (utf-8:octets (length root))
    (node (+ (node-weight root) (compute-subtree-weight (suffix root))))))

;;; Normalizing Leaf Nodes

(declaim (inline empty-leaf? zero-length-leaf? normalize-leaf)
         
         (ftype (function (rope)
                          boolean)
                empty-leaf? zero-length-leaf?)
         
         (ftype (function (utf-8:octets)
                          utf-8:octets)
                normalize-leaf))

(defun empty-leaf? (node)
  "True if NODE is the empty leaf node, i.e. *EMPTY*."
  (declare (optimize (speed 3) (safety 0)))
  (eq node utf-8:*empty*))

(defun zero-length-leaf? (leaf)
  "True if LEAF is a zero length octet vector."
  (declare (optimize (speed 3) (safety 0)))
  (zerop (length leaf)))

(defun normalize-leaf (leaf)
  "Return a leaf node that EMPTY-LEAF? returns true for if LEAF is a zero length
octet vector. Otherwise; return LEAF."
  (declare (optimize (speed 3) (safety 0)))
  (if (zero-length-leaf? leaf)
      utf-8:*empty*
      leaf))


;;; Constructing Ropes

(declaim (ftype (function (rope)
                          rope)
                copy minimize)
         
         (ftype (function (&optional rope rope)
                          rope)
                join)
         
         (ftype (function (rope vector:index)
                          (values rope rope))
                split))

(defun copy (node)
  "Return a copy of NODE created by recursively calling COPY on the prefix and
suffix branches. Leaf nodes are copied by means of COPY-SEQ, and empty leaf
nodes are normalized."
  (etypecase node
    (utf-8:octets (if (zero-length-leaf? node)
                      utf-8:*empty*
		      (copy-seq node)))
    (node (make-node :node-weight (node-weight node)
                     :prefix (copy (prefix node))
                     :suffix (copy (suffix node))))))

(defun minimize (node)
  "Attempts to reduce node by removing empty leaf nodes."
  (etypecase node
    (utf-8:octets (normalize-leaf node))
    (node (cond
	    ((empty-leaf? (prefix node))
	     (minimize (suffix node)))
	    ((empty-leaf? (suffix node))
	     (minimize (prefix node)))
	    (t
	     node)))))

(defun join (&optional (prefix utf-8:*empty*) (suffix utf-8:*empty*))
  (let ((minimized-prefix (minimize prefix))
        (minimized-suffix (minimize suffix)))
    (cond
      ((empty-leaf? minimized-prefix)
       minimized-suffix)
      ((empty-leaf? minimized-suffix)
       minimized-prefix)
      (t
       (make-node :node-weight (compute-subtree-weight minimized-prefix)
                  :prefix minimized-prefix
                  :suffix minimized-suffix)))))

(defun split (node index)
  (etypecase node
    ;; FIXME: ensure we do not split a code point encoded by multiple octets.
    ;; (octets (if (utf-8:continuation? (aref node index))
    ;; 		      (error "Cannot split ~A at ~A." node index)
    ;; 		      (values (normalize-leaf (subseq node 0 index))
    ;; 			      (normalize-leaf (subseq node index)))))
    (utf-8:octets (values (normalize-leaf (subseq node 0 index))
		          (normalize-leaf (subseq node index))))
    (node (cond
	    ((> (node-weight node) index)
	     (multiple-value-bind (prefix suffix)
		 (split (prefix node) index)
	       (values prefix (join suffix (suffix node)))))
	    ((< (node-weight node) index)
	     (multiple-value-bind (prefix suffix)
		 (split (suffix node) index)
	       (values (join (prefix node) prefix) suffix)))
	    (t
	     (values (prefix node) (suffix node)))))))


;;; Gemini balance
;;;
;;; Generated 28. September 2026. Gemini (pro) was given the source code
;;; written so far and asked to produce a balance function. It generated the
;;; three functions collect-leaves, rebuild-balanced, and balance. It also
;;; produced the ftype declarations.

(declaim (ftype (function (rope &optional list)
                          list)
                collect-leaves)
         
         (ftype (function (simple-vector fixnum fixnum)
                          rope)
                rebuild-balanced)
         
         (ftype (function (rope)
                          rope)
                balance))

(defun collect-leaves (node &optional acc)
  "Traverse the rope and collect all non-empty leaf nodes into a list.
   By passing the accumulator to the right subtree first, we naturally 
   build the list in the correct left-to-right order."
  (etypecase node
    (utf-8:octets 
     (if (zero-length-leaf? node)
         acc
         (cons node acc)))
    (node
     (collect-leaves (prefix node)
                     (collect-leaves (suffix node) acc)))))

(defun rebuild-balanced (leaves-vec start end)
  "Recursively bisect a vector of leaves to build a perfectly balanced rope."
  (declare (type simple-vector leaves-vec)
           (type fixnum start end)
           (optimize (speed 3) (safety 1)))
  (let ((count (- end start)))
    (declare (type fixnum count))
    (cond
      ((<= count 0) utf-8:*empty*)
      ((= count 1) (svref leaves-vec start))
      ((= count 2) (join (svref leaves-vec start)
                         (svref leaves-vec (1+ start))))
      (t
       (let ((mid (+ start (floor count 2))))
         (declare (type fixnum mid))
         (join (rebuild-balanced leaves-vec start mid)
               (rebuild-balanced leaves-vec mid end)))))))

(defun balance (rope)
  "Returns a perfectly balanced version of ROPE, discarding any empty nodes."
  (let* ((leaves (collect-leaves rope))
         (leaf-vec (coerce leaves 'simple-vector)))
    (if (zerop (length leaf-vec))
        utf-8:*empty*
        (rebuild-balanced leaf-vec 0 (length leaf-vec)))))
