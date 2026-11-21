
(defpackage #:unicode-character-database.normalizationtest
  (:use #:common-lisp
        #:unicode-character-database)
  
  (:local-nicknames (#:files #:unicode-character-database.files)
                    (#:parser #:unicode-character-database.parser)
                    (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

  (:export #:run-tests
           #:nfc-conforms?
           #:nfd-conforms?
           #:nfkc-conforms?
           #:nfkd-conforms?))

(in-package #:unicode-character-database.normalizationtest)

(defparameter *normalizationtest-part0* '())
(defparameter *normalizationtest-part1* '())
(defparameter *normalizationtest-part2* '())
(defparameter *normalizationtest-part3* '())
(defparameter *normalizationtest-part4* '())
(defparameter *normalizationtest-part5* '())

(defun indices (lines)
  "Return a list of indices that can be used with subseq to extract @parts."
  (append (loop with first = 0
                for i = 0 then (1+ i)
                for line in lines
                when (stringp line)
                collect (1+ i))
          (list nil)))

(defun parse-line (line)
  (loop for field in (cons (first line) (mapcar 'parser:parse-code-point-field (rest (subseq line 0 5))))
        collect (parser:code-point-field-to-octets field)))

(defun load-normalizationtest ()
  (let* ((lines (parser:load-database-file "UCD/NormalizationTest.txt"))
         (indices (indices lines)))
    (loop for part from 0 upto 5
          for start in (subseq indices 0 5)
          for end in (rest indices)
          do (ecase part
               (0 (setf *normalizationtest-part0* (mapcar 'parse-line (subseq lines start (1- end)))))
               (1 (setf *normalizationtest-part1* (mapcar 'parse-line (subseq lines start (1- end)))))
               (2 (setf *normalizationtest-part2* (mapcar 'parse-line (subseq lines start (1- end)))))
               (3 (setf *normalizationtest-part3* (mapcar 'parse-line (subseq lines start (1- end)))))
               (4 (setf *normalizationtest-part4* (mapcar 'parse-line (subseq lines start (1- end)))))
               (5 (setf *normalizationtest-part5* (mapcar 'parse-line (subseq lines start end))))))))
    
;; 1. The following invariants must be true for all conformant implementations
;; #
;; # 2. For every code point X assigned in this version of Unicode that is not specifically
;; #    listed in Part 1, the following invariants must be true for all conformant
;; #    implementations:
;; #
;; #      X == toNFC(X) == toNFD(X) == toNFKC(X) == toNFKD(X)

(defun c1 (line)
  (first line))

(defun c2 (line)
  (second line))

(defun c3 (line)
  (third line))

(defun c4 (line)
  (fourth line))

(defun c5 (line)
  (fifth line))


;; (defun conforms? (line)
;;   (unicode.normalization::to-nfd )
;;   (unicode.normalization::to-nfc )
;;   (unicode.normalization::to-nfkd  )
;;   (unicode.normalization::to-nfkc ))

(defun nfc-conforms? (line)
  ;; #    NFC
  ;; #      c2 ==  toNFC(c1) ==  toNFC(c2) ==  toNFC(c3)
  ;; #      c4 ==  toNFC(c4) ==  toNFC(c5)
  (let ((c2 (c2 line))
        (nfc-c1 (unicode.normalization::to-nfc (c1 line)))
        (nfc-c2 (unicode.normalization::to-nfc (c2 line)))
        (nfc-c3 (unicode.normalization::to-nfc (c3 line)))
        (c4 (c4 line))
        (nfc-c4 (unicode.normalization::to-nfc (c4 line)))
        (nfc-c5 (unicode.normalization::to-nfc (c5 line))))
    (and (and (or (utf-8:octets= c2 nfc-c1)
                  (format t "c2 ~S is not nfc-c1 ~S.~%" c2 nfc-c1))
              (or (utf-8:octets= nfc-c1 nfc-c2)
                  (format t "nfc-c1 ~S is not nfc-c2 ~S.~%" nfc-c1 nfc-c2))
              (or (utf-8:octets= nfc-c2 nfc-c3)
                  (format t "nfc-c2 ~S is not nfc-c3 ~S.~%" nfc-c2 nfc-c3)))
         (and (or (utf-8:octets= c4 nfc-c4)
                  (format t "c4 ~S is not nfc-c4 ~S.~%" c4 nfc-c4))
              (or (utf-8:octets= nfc-c4 nfc-c5)
                  (format t "ncf-c4 ~S is not nfc-c5 ~S.~%" nfc-c4 nfc-c5))))))

(defun nfd-conforms? (line)
  ;; #    NFD
  ;; #      c3 ==  toNFD(c1) ==  toNFD(c2) ==  toNFD(c3)
  ;; #      c5 ==  toNFD(c4) ==  toNFD(c5)
  (let ((c3 (c3 line))
        (nfd-c1 (unicode.normalization::to-nfd (c1 line)))
        (nfd-c2 (unicode.normalization::to-nfd (c2 line)))
        (nfd-c3 (unicode.normalization::to-nfd (c3 line)))
        (c5 (c5 line))
        (nfd-c4 (unicode.normalization::to-nfd (c4 line)))
        (nfd-c5 (unicode.normalization::to-nfd (c5 line))))
    (and (and (or (utf-8:octets= c3 nfd-c1)
                  (format t "c3 ~S is not nfd-c1 ~S.~%" c3 nfd-c1))
              (or (utf-8:octets= nfd-c1 nfd-c2)
                  (format t "nfd-c1 ~S is not nfd-c2 ~S.~%" nfd-c1 nfd-c2))
              (or (utf-8:octets= nfd-c2 nfd-c3)
                  (format t "nfd-c2 ~S is not nfd-c3 ~S.~%" nfd-c2 nfd-c3)))
         (and (or (utf-8:octets= c5 nfd-c4)
                  (format t "c4 ~S is not nfd-c4 ~S.~%" c5 nfd-c4))
              (or (utf-8:octets= nfd-c4 nfd-c5)
                  (format t "ncd-c4 ~S is not nfd-c5 ~S.~%" nfd-c4 nfd-c5))))))

(defun nfkc-conforms? (line)
  ;; #    NFKC
  ;; #      c4 == toNFKC(c1) == toNFKC(c2) == toNFKC(c3) == toNFKC(c4) == toNFKC(c5)
  (let ((c4 (c4 line))
        (nfkc-c1 (unicode.normalization::to-nfkc (c1 line)))
        (nfkc-c2 (unicode.normalization::to-nfkc (c2 line)))
        (nfkc-c3 (unicode.normalization::to-nfkc (c3 line)))
        (nfkc-c4 (unicode.normalization::to-nfkc (c4 line)))
        (nfkc-c5 (unicode.normalization::to-nfkc (c5 line))))
    (and (or (utf-8:octets= c4 nfkc-c1)
             (format t "c4 ~S is not nfkc-c1 ~S.~%" c4 nfkc-c1))
         (or (utf-8:octets= nfkc-c1 nfkc-c2)
             (format t "nfkc-c1 ~S is not nfkc-c2 ~S.~%" nfkc-c1 nfkc-c2))
         (or (utf-8:octets= nfkc-c2 nfkc-c3)
             (format t "nfkc-c2 ~S is not nfkc-c3 ~S.~%" nfkc-c2 nfkc-c3))
         (or (utf-8:octets= nfkc-c3 nfkc-c4)
             (format t "nfkc-c3 ~S is not nfkc-c4 ~S.~%" nfkc-c3 nfkc-c4))
         (or (utf-8:octets= nfkc-c4 nfkc-c5)
             (format t "nfkc-c4 ~S is not nfkc-c5 ~S.~%" nfkc-c4 nfkc-c5)))))

(defun nfkd-conforms? (line)
  ;; #    NFKD
  ;; #      c5 == toNFKD(c1) == toNFKD(c2) == toNFKD(c3) == toNFKD(c4) == toNFKD(c5)
  (let ((c5 (c5 line))
        (nfkd-c1 (unicode.normalization::to-nfkd (c1 line)))
        (nfkd-c2 (unicode.normalization::to-nfkd (c2 line)))
        (nfkd-c3 (unicode.normalization::to-nfkd (c3 line)))
        (nfkd-c4 (unicode.normalization::to-nfkd (c4 line)))
        (nfkd-c5 (unicode.normalization::to-nfkd (c5 line))))
    (and (or (utf-8:octets= c5 nfkd-c1)
             (format t "c5 ~S is not nfkd-c1 ~S.~%" c5 nfkd-c1))
         (or (utf-8:octets= nfkd-c1 nfkd-c2)
             (format t "nfkd-c1 ~S is not nfkd-c2 ~S.~%" nfkd-c1 nfkd-c2))
         (or (utf-8:octets= nfkd-c2 nfkd-c3)
             (format t "nfkd-c2 ~S is not nfkd-c3 ~S.~%" nfkd-c2 nfkd-c3))
         (or (utf-8:octets= nfkd-c3 nfkd-c4)
             (format t "nfkd-c3 ~S is not nfkd-c4 ~S.~%" nfkd-c3 nfkd-c4))
         (or (utf-8:octets= nfkd-c4 nfkd-c5)
             (format t "nfkd-c4 ~S is not nfkd-c5 ~S.~%" nfkd-c4 nfkd-c5)))))


(defun run-tests (&key functions tests)
  (unless *normalizationtest-part0* (load-normalizationtest))
  (loop for function in (or functions '(nfc-conforms? nfd-conforms? nfkc-conforms? nfkd-conforms?))
        do (loop for test in (or tests (list *normalizationtest-part0* 
                                             *normalizationtest-part1* 
				             *normalizationtest-part2* 
				             *normalizationtest-part3* 
				             *normalizationtest-part4*))
                 do (loop for line in test
                          do (funcall function line)))
        do (format t "~A done~%" function)))
