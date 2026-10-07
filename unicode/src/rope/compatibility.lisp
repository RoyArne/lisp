
(in-package #:unicode.rope)

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
