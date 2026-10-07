
(in-package #:unicode.utf-8)

;;; Compatibilty functions are defined to interop with SBCL during testing.

(declaim (ftype (function (string &optional vector:index vector:end-index)
                          octets)
                string-to-octets)

          (ftype (function (octets &optional vector:index vector:end-index)
                          string)
                 octets-to-string))

(defun string-to-octets (string &optional (start 0) end)
  "Encodes string as an octet vector through sb-ext:string-to-octets."
  (coerce (sb-ext:string-to-octets string :start start :end end :external-format :utf-8)
          'octets))

(defun octets-to-string (vector &optional (start 0) end)
  "Decodes the octet vector into a string through sb-ext:string-to-octets."
  (sb-ext:octets-to-string vector :start start :end end :external-format :utf-8))

