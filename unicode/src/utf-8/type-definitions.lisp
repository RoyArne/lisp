
(in-package #:unicode.utf-8)

(deftype octet ()
  "An 8-bit unsigned integer. The code unit of the UTF-8 encoding."
  `(unsigned-byte 8))

(deftype octets ()
  "A vector of octets."
  `(vector octet))

(deftype encoding-length ()
  "The number of octets used to encode a code point."
  `(integer 1 4))

(declaim (inline octet?
                 octets?
                 encoding-length?)
         
         (ftype (function (t)
                          boolean)
                octet?
                octets?
                encoding-length?))

(defun octet? (object)
  (typep object 'octet))

(defun octets? (object)
  (typep object 'octets))

(defun encoding-length? (object)
  (typep object 'encoding-length))
