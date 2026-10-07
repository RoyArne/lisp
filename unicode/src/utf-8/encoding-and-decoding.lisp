
(in-package #:unicode.utf-8)

;;; UTF-8 Encoding and Decoding
;;;
;;; · Code points are encoded as an initial octet followed by zero, one, two,
;;;   or three continuation octets.
;;;
;;;   Generally, functions and variables are named after the total number of
;;;   octets in the code point they operate on. For example
;;;
;;;     (1/3? octet) → boolean,
;;;     (continuation? octet) → boolean,
;;;     (decode3 vector start) → code-point , and
;;;     (setf (octet3 vector start) octet) → octet.
;;;
;;;
;;; Accessing Octets
;;;
;;;   There are a number of octet accessor functions that read and write the
;;;   Nth octet of a code points encoding. For example
;;;
;;;     (octet1 vector start)
;;;
;;;   returns the octet at the start + 0 position, and
;;;
;;;     (setf (octet3 vector start) #b10001100)
;;;
;;;   writes a value to the octet at start + 2 (i.e. the third octet).
;;;
;;;
;;; Octet Bit Patterns
;;;
;;; · Every octet conforms to a bit pattern that defines its role in the
;;;   encoding.
;;;
;;; · The top 1-5 bits of the initial octet indicates the number of
;;;   continuation octets.
;;;
;;; · Continuation octets has the top two bits set to 10.
;;;
;;;   We use bit masks and patterns to test for different types of octets. For
;;;   example, the +1/1-mask+ is used to check if an octet conforms to the
;;;   +1/1-pattern+. There is also a +continuation-mask+ and a
;;;   +continuation-pattern+ to test for continuation octets.
;;;
;;;
;;; Encoding and Decoding Code Points
;;;
;;; · When code points are decoded we first investigate the octet bit
;;;   patterns. The functions (1/N? octet) and (continuation? octet) returns
;;;   true if the octet matches the corresponding bit pattern.
;;;
;;; · Data is extracted from octets by functions (1/N-data octet) and
;;;   (continuation-data octet).
;;;
;;; · Likewise, data is extracted from code points and written to octets by
;;;   (set-1/N-data code-point)
;;;
;;; · The function to write continuation-data to an octet depends on prior
;;;   work that extracts the relevant bits from a code point.
;;;
;;; · Functions decodeN and encodeN combines the above functions to encode and
;;;   decode N-octet code points.
;;;
;;; · Finally the functions
;;;
;;;     (encode-code-point code-point vector start) → index
;;;
;;;   and
;;;
;;;     (decode-code-point vector start) → code-point, index
;;;
;;;  provides the front end for encoding and decoding code points. The indices
;;;  returned are the encodings end indices (i.e. the index of the next code
;;;  point in vector).


;;; Octet Accessors

(declaim (inline
          octet1 (setf octet1)
          octet2 (setf octet2)
          octet3 (setf octet3)
          octet4 (setf octet4))
         
         (ftype (function (octets vector:index)
                          octet)
                octet1 octet2 octet3 octet4)
         
         (ftype (function (octet octets vector:index)
                          octet)
                (setf octet1) (setf octet2) (setf octet3) (setf octet4)))

(defun octet1 (octets start)
  (aref octets start))

(defun (setf octet1) (octet octets start)
  (setf (aref octets start) octet))

(defun octet2 (octets start)
  (aref octets (1+ start)))

(defun (setf octet2) (octet octets start)
  (setf (aref octets (1+ start)) octet))

(defun octet3 (octets start)
  (aref octets (+ 2 start)))

(defun (setf octet3) (octet octets start)
  (setf (aref octets (+ 2 start)) octet))

(defun octet4 (octets start)
  (aref octets (+ 3 start)))

(defun (setf octet4) (octet octets start)
  (setf (aref octets (+ 3 start)) octet))


;;; Lead Octet and Continuation Octet Bit Patterns

(declaim (type octet +1/1-mask+ +1/1-pattern+
                     +continuation-mask+ +continuation-pattern+
                     +1/2-mask+ +1/2-pattern+
                     +1/3-mask+ +1/3-pattern+
                     +1/4-mask+ +1/4-pattern+))

(defconstant +1/1-mask+             #b10000000)
(defconstant +1/1-pattern+          #b00000000)
(defconstant +continuation-mask+    #b11000000)
(defconstant +continuation-pattern+ #b10000000)
(defconstant +1/2-mask+             #b11100000)
(defconstant +1/2-pattern+          #b11000000)
(defconstant +1/3-mask+             #b11110000)
(defconstant +1/3-pattern+          #b11100000)
(defconstant +1/4-mask+             #b11111000)
(defconstant +1/4-pattern+          #b11110000)

(defmacro match? (pattern mask octet)
  `(= ,pattern (logand ,octet ,mask)))


;;; One Octet Encoding and Decoding
;;; Continuation Octets for Multi-Octet Encoding and Decoding
;;; Multi-Octet Encoding and Decoding

(declaim (inline 1/1? decode1 encode1
                 1/2? decode2 encode2
                 1/3? decode3 encode3
                 1/4? decode4 encode4
                 continuation? continuation-data set-continuation-data)
         
         (ftype (function (octet)
                          boolean)
                1/1? 1/2? 1/3? 1/4? continuation?)
         
         (ftype (function (octets vector:index)
                          code-point:code-point)
                decode1 decode2 decode3 decode4)
         
         (ftype (function (code-point:code-point octets vector:index)
                          octet)
                encode1 encode2 encode3 encode4)
         
         (ftype (function (code-point:code-point octets)
                          vector:index)
                push1 push2 push3 push4)

         (ftype (function (octet)
                          octet)
                1/2-data 1/3-data 1/4-data
                continuation-data set-continuation-data)

         (ftype (function (code-point:code-point)
                          code-point:code-point)
                set-1/2-data set-1/-data set-1/4-data))

(defun 1/1? (octet)
  (declare (optimize (speed 3) (safety 0)))
  (match? +1/1-pattern+ +1/1-mask+ octet))

(defun decode1 (vector start)
  (octet1 vector start))

(defun encode1 (code-point vector start)
  (setf (octet1 vector start) code-point))

(defun push1 (code-point vector)
  (1+ (vector-push-extend code-point vector)))

(defun continuation? (octet)
  (declare (optimize (speed 3) (safety 0)))
  (match? +continuation-pattern+ +continuation-mask+ octet))

(defun continuation-data (octet)
  (declare (optimize (speed 3) (safety 0)))
  (ldb (byte 6 0) octet))

(defun set-continuation-data (octet)
  (declare (optimize (speed 3) (safety 0)))
  (deposit-field +continuation-pattern+
		 (byte 2 6)
		 octet))

(defun 1/2? (octet)
  (declare (optimize (speed 3) (safety 0)))
  (match? +1/2-pattern+ +1/2-mask+ octet))

(defun 1/2-data (octet)
  (declare (optimize (speed 3) (safety 0)))
  (ldb (byte 5 0) octet))

(defun decode2 (vector start)
  (dpb (1/2-data (octet1 vector start))
       (byte 5 6)
       (continuation-data (octet2 vector start))))

(defun set-1/2-data (code-point)
  (declare (optimize (speed 3) (safety 0)))
  (deposit-field +1/2-pattern+
		 (byte 3 5)
		 (ldb (byte 5 6) code-point)))

(defun encode2 (code-point vector start)
  (setf (octet1 vector start) (set-1/2-data code-point)
	(octet2 vector start) (set-continuation-data (ldb (byte 6 0) code-point))))

(defun push2 (code-point vector)
  (vector-push-extend (set-1/2-data code-point) vector 2)
  (1+ (vector-push-extend (set-continuation-data (ldb (byte 6 0) code-point)) vector)))

(defun 1/3? (octet)
  (declare (optimize (speed 3) (safety 0)))
  (match? +1/3-pattern+ +1/3-mask+ octet))

(defun 1/3-data (octet)
  (declare (optimize (speed 3) (safety 0)))
  (ldb (byte 4 0) octet))

(defun decode3 (vector start)
  (dpb (1/3-data (octet1 vector start))
       (byte 4 12)
       (dpb (continuation-data (octet2 vector start))
	    (byte 6 6)
	    (continuation-data (octet3 vector start)))))

(defun set-1/3-data (code-point)
  (declare (optimize (speed 3) (safety 0)))
  (deposit-field +1/3-pattern+
		 (byte 4 4)
		 (ldb (byte 4 12) code-point)))

(defun encode3 (code-point vector start)
  (setf (octet1 vector start) (set-1/3-data code-point)
	(octet2 vector start) (set-continuation-data (ldb (byte 6 6) code-point))
	(octet3 vector start) (set-continuation-data (ldb (byte 6 0) code-point))))

(defun push3 (code-point vector)
  (vector-push-extend (set-1/3-data code-point) vector 3)
  (vector-push-extend (set-continuation-data (ldb (byte 6 6) code-point)) vector)
  (1+ (vector-push-extend (set-continuation-data (ldb (byte 6 0) code-point)) vector)))
  
(defun 1/4? (octet)
  (declare (optimize (speed 3) (safety 0)))
  (match? +1/4-pattern+ +1/4-mask+ octet))

(defun 1/4-data (octet)
  (declare (optimize (speed 3) (safety 0)))
  (ldb (byte 3 0) octet))

(defun decode4 (vector start)
  (dpb (1/4-data (octet1 vector start))
       (byte 3 18)
       (dpb (continuation-data (octet2 vector start))
	    (byte 6 12)
	    (dpb (continuation-data (octet3 vector start))
		 (byte 6 6)
		 (continuation-data (octet4 vector start))))))

(defun set-1/4-data (code-point)
  (declare (optimize (speed 3) (safety 0)))
  (deposit-field +1/4-pattern+
		 (byte 5 3)
		 (ldb (byte 3 18) code-point)))

(defun encode4 (code-point vector start)
  (setf (octet1 vector start) (set-1/4-data code-point)
	(octet2 vector start) (set-continuation-data (ldb (byte 6 12) code-point))
	(octet3 vector start) (set-continuation-data (ldb (byte 6 6) code-point))
	(octet4 vector start) (set-continuation-data (ldb (byte 6 0) code-point))))

(defun push4 (code-point vector)
  (vector-push-extend (set-1/4-data code-point) vector 4)
  (vector-push-extend (set-continuation-data (ldb (byte 6 12) code-point)) vector)
  (vector-push-extend (set-continuation-data (ldb (byte 6 6) code-point)) vector)
  (1+ (vector-push-extend (set-continuation-data (ldb (byte 6 0) code-point)) vector)))


;;; Octet Encoding Lengths for Ranges of Code Points

(declaim (type code-point:code-point
               +1-octet-range-start+ +1-octet-range-end+
               +2-octet-range-start+ +2-octet-range-end+
               +3-octet-range-start+ +3-octet-range-low-end+
               +3-octet-range-low-start+ +3-octet-range-end+
               +4-octet-range-start+ +4-octet-range-end+))

(defconstant +1-octet-range-start+  #x0000)
(defconstant +1-octet-range-end+    #x007F)
(defconstant +2-octet-range-start+  #x0080)
(defconstant +2-octet-range-end+    #x07FF)
(defconstant +3-octet-range-start+  #x0800)
(defconstant +3-octet-range-end+    #xFFFF)
(defconstant +4-octet-range-start+ #x10000)
(defconstant +4-octet-range-end+  #x10FFFF)


(declaim (inline in-1-octet-range? in-2-octet-range? in-3-octet-range? in-4-octet-range?)
         
         (ftype (function (code-point:code-point)
                          boolean)
                in-1-octet-range? in-2-octet-range? in-3-octet-range? in-4-octet-range?))

(defun in-1-octet-range? (code-point)
  (declare (optimize (speed 3) (safety 0)))
  (<= +1-octet-range-start+ code-point +1-octet-range-end+))

(defun in-2-octet-range? (code-point)
  (declare (optimize (speed 3) (safety 0)))
  (<= +2-octet-range-start+ code-point +2-octet-range-end+))

(defun in-3-octet-range? (code-point)
  (declare (optimize (speed 3) (safety 0)))
  (<= +3-octet-range-start+ code-point +3-octet-range-end+))

(defun in-4-octet-range? (code-point)
  (declare (optimize (speed 3) (safety 0)))
  (<= +4-octet-range-start+ code-point +4-octet-range-end+))


(declaim (ftype (function (encoding-length)
                          code-point:code-point)
                octet-range-start octet-range-end))

(defun octet-range-start (length)
  "Return the first code point that is encoded by LENGTH octets."
  (ecase length
    (1 +1-octet-range-start+)
    (2 +2-octet-range-start+)
    (3 +3-octet-range-start+)
    (4 +4-octet-range-start+)))

(defun octet-range-end (length)
  "Return the last code point that is encoded by LENGTH octets."
  (ecase length
    (1 +1-octet-range-end+)
    (2 +2-octet-range-end+)
    (3 +3-octet-range-end+)
    (4 +4-octet-range-end+)))


(declaim (ftype (function (octet)
                          encoding-length)
                %encoding-length)
         
         (ftype (function (octets vector:index)
                          encoding-length)
                encoding-length)
         
         (ftype (function (code-point:code-point)
                          encoding-length)
                encoded-length)
         
         (ftype (function (code-point:code-point)
                          octet)
                initial-octet))

(defun %encoding-length (initial-octet)
  "Return the number of octets needed to encode a code point which has
INITIAL-OCTET as its initial octet. Return zero if INITIAL-OCTET does not
match the bit pattern of any initial octet."
  (declare (optimize (speed 3) (safety 0)))
  (cond
    ((1/1? initial-octet) 1)
    ((1/2? initial-octet) 2)
    ((1/3? initial-octet) 3)
    ((1/4? initial-octet) 4)
    (t (error "Cannot compute the encoding length of ~B." initial-octet))))

(defun encoding-length (vector start)
  "Return the encoding length of the code point encoded at START in
VECTOR. Return zero if the octet at START does not match the bit pattern of
any initial octet."
  (declare (optimize (speed 3) (safety 0)))
  (%encoding-length (octet1 vector start)))

(defun encoded-length (code-point)
  "Return the number of octets needed to encode CODE-POINT."
  (declare (optimize (speed 3) (safety 0)))
  (cond
    ((in-1-octet-range? code-point) 1)
    ((in-2-octet-range? code-point) 2)
    ((in-3-octet-range? code-point) 3)
    ((in-4-octet-range? code-point) 4)
    (t (error "Cannot compute the encoded length of ~X." code-point))))

(defun initial-octet (code-point)
  "Return the initial octet of CODE-POINT."
  (declare (optimize (speed 3) (safety 0)))
  (ecase (encoded-length code-point)
    (1 (coerce code-point 'octet))
    (2 (set-1/2-data code-point))
    (3 (set-1/3-data code-point))
    (4 (set-1/4-data code-point))))


;;; Decoding and Encoding Functions

(declaim (ftype (function (octets vector:index)
                          code-point:code-point)
                decode-code-point)
         
         (ftype (function (code-point:code-point octets vector:index)
                          vector:index)
                encode-code-point)
         
         (ftype (function (code-point:code-point octets)
                          vector:index)
                push-code-point))

(defun decode-code-point (vector start)
  "Return two values: a code point encoded at the START position in VECTOR, and
the end index of the encoding.

Signals an error if the octet at START is a continuation octet.
Signals an error if the octets at START encodes a surrogate code point, or a
code point outside the unicode range."
  (cond
    ((1/1? (octet1 vector start))
     (values (decode1 vector start) (1+ start)))
    ((1/2? (octet1 vector start))
     (values (decode2 vector start) (+ start 2)))
    ((1/3? (octet1 vector start))
     (values (decode3 vector start) (+ start 3)))
    ((1/4? (octet1 vector start))
     (let ((code-point (decode4 vector start)))
       (if (<= code-point +4-octet-range-end+)
           (values code-point (+ start 4))
           (error "Cannot decode a code point beginning at~%  ~S~%~
                   in~%  ~S~%~
                   because the octets at that position encodes a code point outside the unicode range."
                  start vector))))
    (t
     (error "Cannot decode a code point beginning at~%  ~S~%~
             in~%  ~S~%~
             because the octet at that position is a continuation octet."
            start vector))))

(defun encode-code-point (code-point vector start)
  "Encode CODE-POINT at the START position in VECTOR and return the end index of
the encoding."
  (let ((length (encoded-length code-point)))
    (ecase length
      (1 (encode1 (the octet code-point) vector start))
      (2 (encode2 code-point vector start))
      (3 (encode3 code-point vector start))
      (4 (encode4 code-point vector start)))
    (+ start length)))

(defun push-code-point (code-point vector)
  "Append CODE-POINT to the end of VECTOR. VECTOR must be adjustable with a
fill-pointer."
  (let ((length (encoded-length code-point)))
    (ecase length
      (1 (push1 (the octet code-point) vector))
      (2 (push2 code-point vector))
      (3 (push3 code-point vector))
      (4 (push4 code-point vector)))))
