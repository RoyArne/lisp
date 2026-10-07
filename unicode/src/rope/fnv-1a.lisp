
(in-package #:unicode.rope)

(declaim (ftype (function (rope &optional (or null (unsigned-byte 64)))
                          (unsigned-byte 64))
                compute-rope-fnv-1a/64-hash)

         (ftype (function (rope)
                          (unsigned-byte 64))
                rope-fnv-1a/64-hash)

         (ftype (function (rope &optional (or null (unsigned-byte 32)))
                          (unsigned-byte 32))
                compute-rope-fnv-1a/32-hash)

         (ftype (function (rope)
                          (unsigned-byte 32))
                rope-fnv-1a/32-hash))
         
(defun compute-rope-fnv-1a/64-hash (rope &optional hash)
  (etypecase rope
    (utf-8:octets (if (null hash)
                      (utf-8:fnv-1a/64 rope)
                      (utf-8:fnv-1a/64 rope :hash hash)))
    (node (compute-rope-fnv-1a/64-hash (suffix rope)
                                         (compute-rope-fnv-1a/64-hash (prefix rope) hash)))))

(defun rope-fnv-1a/64-hash (rope)
  (etypecase rope
    (utf-8:octets (utf-8:fnv-1a/64 rope))
    (node (compute-rope-fnv-1a/64-hash rope))))

(defun compute-rope-fnv-1a/32-hash (rope &optional hash)
  (etypecase rope
    (utf-8:octets (if (null hash)
                      (utf-8:fnv-1a/32 rope)
                      (utf-8:fnv-1a/32 rope :hash hash)))
    (node (compute-rope-fnv-1a/32-hash (suffix rope)
                                       (compute-rope-fnv-1a/32-hash (prefix rope) hash)))))

(defun rope-fnv-1a/32-hash (rope)
  (etypecase rope
    (utf-8:octets (utf-8:fnv-1a/32 rope))
    (node (compute-rope-fnv-1a/32-hash rope))))

