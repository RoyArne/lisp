;;;; This is "src/utf-8/fnv-1a.lisp".
;;;;
;;;; It defines the Fowler–Noll–Vo hash function for octet vectors.
;;;;
;;;; https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
;;;;
;;;; algorithm fnv-1a is
;;;;    hash := FNV_offset_basis
;;;;
;;;;    for each byte_of_data to be hashed do
;;;;        hash := hash XOR byte_of_data
;;;;        hash := hash × FNV_prime
;;;;
;;;;    return hash

(in-package #:unicode.utf-8)

(declaim (type (unsigned-byte 32)
               +fnv-offset-basis/32+
               +fnv-prime/32+)
         
         (type (unsigned-byte 64)
               +fnv-offset-basis/64+
               +fnv-prime/64+))

(defparameter +fnv-offset-basis/32+ 2166136261)
(defparameter +fnv-prime/32+ 16777619)

(defparameter +fnv-offset-basis/64+ 14695981039346656037)
(defparameter +fnv-prime/64+ 1099511628211)


(declaim (ftype (function (octets &key (:hash (unsigned-byte 64))) (unsigned-byte 64))
                fnv-1a/64)

         (ftype (function (octets &key (:hash (unsigned-byte 32))) (unsigned-byte 32))
                fnv-1a/32))

(defun fnv-1a/64 (vector &key (hash +fnv-offset-basis/64+))
  "Syntax:
\(fnv-1a/64 vector &key hash\) → result

Arguments and Values:
vector—a byte vector.
hash—a 64 bit unsigned integer. The default is 14695981039346656037.
result—a 64 bit unsigned integer.

Description:
Computes and returns the 64 bit fnv-1a hash for vector.

Note:
The hash argument must keep its default value on the initial call to fnv-1a/64.

Provide the return value from fnv-1a/64 as the hash argument if you are
processing multiple vectors as if they are one vector."
  (loop for byte across vector
        for result = (logand (* (logxor hash byte) +fnv-prime/64+) #xFFFFFFFFFFFFFFFF)
        then (logand (* (logxor result byte) +fnv-prime/64+) #xFFFFFFFFFFFFFFFF)
        finally (return (or result hash))))

(defun fnv-1a/32 (vector &key (hash +fnv-offset-basis/32+))
  "Syntax:
\(fnv-1a/32 vector &key hash\) → result

Arguments and Values:
vector—a byte vector.
hash—a 32 bit unsigned integer. The default is 2166136261.
result—a 32 bit unsigned integer.

Description:
Computes and returns the 32 bit fnv-1a hash for vector.

Note:
The hash argument must keep its default value on the initial call to fnv-1a/32.

Provide the return value from fnv-1a/32 as the hash argument on subsequent
calls if multiple vectors are processed as if they are one vector."
  (loop for byte across vector
        for result = (logand (* (logxor hash byte) +fnv-prime/32+) #xFFFFFFFF)
        then (logand (* (logxor result byte) +fnv-prime/32+) #xFFFFFFFF)
        finally (return (or result hash))))
