
(in-package #:unicode.rope)

(declaim (ftype (function (rope rope)
                          boolean)
                rope=))

(defun rope= (rope1 rope2)
  "Syntax:
\(rope= rope1 rope2\) → boolean

Arguments and Values:
rope1, rope2—a rope.
boolean—a generalized boolean.

Description:
Returns true if rope1 and rope2 contains the same number of octets, and in the
same order. Otherwise, returns false."
  (or (eq rope1 rope2)
      (if (and (typep rope1 'utf-8:octets) (typep rope2 'utf-8:octets))
          (zerop (utf-8:compare rope1 0 (length rope1) rope2 0 (length rope2)))
          (let ((flat1 (collect-leaves rope1))
                (flat2 (collect-leaves rope2)))
            (when (and flat1
                       flat2
                       (= (reduce #'+ flat1 :key #'length :initial-value 0)
                          (reduce #'+ flat2 :key #'length :initial-value 0)))
              ;; At this point flat1 and 2 are non-nil, and of equal length.
              (loop with v1 = (pop flat1)
                    with v2 = (pop flat2)

                    for i1 = 0 then (1+ i1) ; indices into v1 and v2
                    for i2 = 0 then (1+ i2)

                    until (and (null flat1) ; end condition.
                               (null flat2)
                               (= i1 (length v1))
                               (= i2 (length v2)))

                    when (= i1 (length v1)) ; reset i1 and get a new v1
                    do (setf v1 (pop flat1)
                             i1 0)
                    
                    when (= i2 (length v2)) ; reset i2 and get a new v2
                    do (setf v2 (pop flat2)
                             i2 0)

                    ;; This is never out of bounds because we will never pop a
                    ;; zero length octets vector, and so an index of zero is
                    ;; always valid.
                    ;; We can never pop a nil because both flat1 and flat2
                    ;; contain the same number of octets. That means that i1
                    ;; and i2 will advance in lockstep, popping new vectors as
                    ;; needed, and hit the end condition above before we can
                    ;; pop a nil here.
                    when (/= (aref v1 i1) (aref v2 i2)) ; early return for false
                    do (return nil)
                    
                    finally (return t))))))) ; return true if we reach the end condition

;; (sb-ext:define-hash-table-test rope= rope-fnv-1a/64-hash)

(declaim (ftype (function (&optional (or string rope) (or string rope))
                          rope)
                string-join))

(defun string-join (&optional (prefix "") (suffix ""))
  (join (etypecase prefix
          (string (utf-8:string-to-octets prefix))
          (rope prefix))
        (etypecase suffix
          (string (utf-8:string-to-octets suffix))
          (rope suffix))))
