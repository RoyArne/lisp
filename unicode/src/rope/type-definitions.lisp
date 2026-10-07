
(in-package #:unicode.rope)

(deftype weight ()
  "The size of the left-hand branch of a rope."
  `fixnum)

(defstruct (node (:conc-name nil)
                 (:copier nil))
  "A non-leaf node in a rope data structure. Leaf nodes are OCTETS."
  (node-weight 0 :type weight)
  (prefix utf-8:*empty* :type (or utf-8:octets node))
  (suffix utf-8:*empty* :type (or utf-8:octets node)))

(deftype rope ()
  "Either a node or an utf-8:octets vector."
  `(or utf-8:octets node))

(defun rope? (node)
  (typecase node
    (utf-8:octets t)
    (node t)))
