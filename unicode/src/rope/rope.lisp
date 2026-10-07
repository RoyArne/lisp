
(defpackage #:unicode.rope
  (:documentation
   "Implements a rope data structure composed of nodes and leaf nodes.

Nodes are a branches composed of a prefix and suffix. They also have a weight,
which is the total length of all leaf nodes in its prefix branch.

Leaf nodes are utf-8 octet vectors.")
  (:use #:common-lisp #:unicode)

  (:local-nicknames (#:utf-8 #:unicode.utf-8)
                    (#:vector #:system.sequence.vector))

  ;; FIXME: We may want to export a length function. It is the same as
  ;;        compute-subtree-weight, but with a better name.
  ;; FIXME: Do we want to expose node internals, like prefix and suffix?
  ;;        Or do we not want to export weight?
  
  ;; rope/type-definitions.lisp
  (:export #:rope? #:rope #:node #:weight)

  ;; rope/operations.lisp
  (:export #:copy #:join #:split #:balance)

  ;; rope/fnv-1a.lisp
  (:export #:rope-fnv-1a/64-hash
           #:rope-fnv-1a/32-hash)

  ;; rope/compatibility.lisp
  (:export #:rope=
           #:string-join))
