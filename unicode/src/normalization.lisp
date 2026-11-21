;;;; This "unicode/src/normalization.lisp".
;;;;
;;;; [Unicode® Standard Annex #15 Unicode Normalization Forms](https://unicode.org/reports/tr15/)

(defpackage #:unicode.normalization
  (:use #:common-lisp)

  (:local-nicknames (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:vector #:system.sequence.vector)
                    (#:table #:unicode.table))

  (:import-from #:unicode
                #:to-nfc #:to-nfd #:to-nfkc #:to-nfkd)

  (:export #:to-nfc #:to-nfd #:to-nfkc #:to-nfkd))

(in-package #:unicode.normalization)


;;; ============================================================================
;;; Canonical Ordering
;;; ============================================================================
;;;
;;;
;;; 3.11.5 Canonical Ordering Algorithm
;;;   https://www.unicode.org/versions/Unicode18.0.0/core-spec/chapter-3/#G49591
;;;
;;; https://www.unicode.org/reports/tr44/#CCC_Values_Table

(defun reorderable-pair? (octets1 start1 octets2 start2)
  ;; The code points also need to be adjacent. We can test that with
  ;;
  ;;   (and (eq octets1 octets2)
  ;;        (= (utf-8:next octets1 start1) start2))
  ;;
  ;; but we assume caller know they are adjacent. Also we may be using ropes
  ;; and having separate vector args accomodate that.
  (> (unicode:canonical-combining-class-of octets1 start1)
     (unicode:canonical-combining-class-of octets2 start2)
     0))

(defun place-in-canonical-order (octets start end)
  ;; Reorder octets from start to end in canonical order.
  ;; There must be at least two code points encoded between 'start' and 'end'.
  (when (and (< start end)
             (< (utf-8:next octets start) end))
    ;; We start with the last two code points and move forward one code point at a time.
    (loop for last = (utf-8:previous octets end) then first
          for first = (utf-8:previous octets last)
          do (when (reorderable-pair? octets first octets last)
               ;; We decode the two code points in order to swap them.
               (let ((1st (utf-8:decode-code-point octets first))
                     (2nd (utf-8:decode-code-point octets last)))
                 ;; '1st-start' is where we will encode '1st' at, i.e. it moves backwards.
                 (let* ((1st-start (utf-8:encode-code-point 2nd octets first))    ; the end of '2nd's encoding
                        (1st-end (utf-8:encode-code-point 1st octets 1st-start))) ; the end of '1st's encoding
                   ;; At this point '2nd' has moved forward to the 'first'
                   ;; position.
                   ;;
                   ;; On the next iteration we need to check if the
                   ;; code point that moved forward needs to be reordered:
                   (setf first (if (= 1st-end end) ; 'first' becomes 'last' on the next iteration
                                   1st-start       ; '1st-start' because we have moved all the way to the 'end'
                                   1st-end)))))
          while (plusp first)))
  octets)


;;; ============================================================================
;;; Algorithmic Decomposition of Hangul Syllables
;;;
;;; [3.12.2 Hangul Syllable Decomposition]
;;; (https://www.unicode.org/versions/Unicode18.0.0/core-spec/chapter-3/#G56669)
;;;
;;; ============================================================================

(declaim (type code-point:code-point *s-base* *l-base* *v-base* *t-base*))

(defparameter *s-base* #xAC00 ; #\HANGUL_SYLLABLE_GA
  "*s-base* is an abbreviation for precomposed Syllable BASE.

This is the first code point in the block of precomposed Hangul syllables
\(U+AC00…U+D7A3\). Code points in this range has the Hangul_Syllable_Type
property :lv or :lvt.

It is used to compute an index into the block during algorithmic composition
and decomposition of Hangul syllables:

  syllable-index = *s-base* - code-point")

(defparameter *l-base* #x1100 ; #\HANGUL_CHOSEONG_KIYEOK
  "*l-base* is an abbreviation for Leading_jamo BASE.

This is the first code point with the Hangul_Syllable_Type property :l in the
Hangul Jamo code block.")

(defparameter *v-base* #x1161 ; #\HANGUL_JUNGSEONG_A
  "*v-base* is an abbreviation for Vowel_jamo BASE.

This is the first code point with the Hangul_Syllable_Type property :v in the
Hangul Jamo code block.")

(defparameter *t-base* #x11A7 ; #\HANGUL_JUNGSEONG_O-YAE
  "*t-base* is an abbreviation for Trailing_jamo BASE.

This is ONE LESS THAN the first code point with the Hangul_Syllable_Type
property :t in the Hangul Jamo code block.")


(declaim (type fixnum *l-count* *v-count* *t-count* *n-count* *s-count*))

(defparameter *l-count* 19
  "This is the number of successive code points with the Hangul_Syllable_Type
property :l starting at *l-base*.")

(defparameter *v-count* 21
  "This is the number of successive code points with the Hangul_Syllable_Type
property :v starting at *v-base*.")

(defparameter *t-count* 28
  "This is ONE MORE THAN the number of successive code points with the
Hangul_Syllable_Type property :t starting at *t-base*.")

(defparameter *n-count* (* *v-count* *t-count*)
  "This is the number of precomposed Hangul syllables starting with the same
leading consonant, counting both the LV_Syllables and the LVT_Syllables for
each possible trailing consonant.")

(defparameter *s-count* (* *l-count* *n-count*)
  "The total count of precomposed Hangul syllables. Equal to *l-count* times
*n-count*.")

(declaim (ftype (function (utf-8:octets vector:index)
                          boolean)
                precomposed-hangul-syllable?)

         (ftype (function (utf-8:octets vector:index)
                          (or null utf-8:octets))
                decompose-hangul-syllable))

(defun precomposed-hangul-syllable? (octets start)
  (case (unicode:hangul-syllable-type-of octets start)
    ((:lv :lvt) t)))

(defun decompose-hangul-syllable (octets start)
  (when (precomposed-hangul-syllable? octets start)
    (let* ((s-index (- (utf-8:decode-code-point octets start) *s-base*))
           (l-index (floor s-index *n-count*))
           (v-index (floor (mod s-index *n-count*) *t-count*))
           (t-index (mod s-index *t-count*)))
      (if (plusp t-index)
          (let ((vector (utf-8:make-octets 9)))
            (utf-8:encode-code-point (+ *l-base* l-index) vector 0)
            (utf-8:encode-code-point (+ *v-base* v-index) vector 3)
            (utf-8:encode-code-point (+ *t-base* t-index) vector 6)
            vector)
          (let ((vector (utf-8:make-octets 6)))
            (utf-8:encode-code-point (+ *l-base* l-index) vector 0)
            (utf-8:encode-code-point (+ *v-base* v-index) vector 3)
            vector)))))


;;; ============================================================================
;;; Canonical and Compatibility Decomposition.
;;; ============================================================================

(declaim (ftype (function (utf-8:octets vector:index vector:index (or function symbol))
                          utf-8:octets)
                decompose)

         (ftype (function (utf-8:octets &key (:start vector:index) (:end vector:end-index))
                          utf-8:octets)
                canonical-decomposition
                compatibility-decomposition))

(defun decompose (octets start end decomposition-of)
  (let ((output (utf-8:make-adjustable-octets (- end start))))
    (loop for i = start then (utf-8:next octets i) while (< i end)
          do (let ((decomposition (or (funcall decomposition-of octets i)
                                      (decompose-hangul-syllable octets i))))
               (if decomposition
                   (loop for octet across decomposition
                         do (vector-push-extend octet output))
                   (loop for j from i below (utf-8:next octets i)
                         do (vector-push-extend (aref octets j) output)))))
    (coerce output 'utf-8:octets)))

(defun canonical-decomposition (octets &key (start 0) end)
  (decompose octets start (vector:end octets end) 'unicode:canonical-decomposition-of))

(defun compatibility-decomposition (octets &key (start 0) end)
  (decompose octets start (vector:end octets end) 'unicode:compatibility-decomposition-of))


;;; ============================================================================
;;; Algorithmic Composition of Hangul Syllables
;;;
;;; [3.12.3 Hangul Syllable Composition]
;;; (https://www.unicode.org/versions/Unicode18.0.0/core-spec/chapter-3/#G59688)
;;; ============================================================================

(declaim (type code-point:range *l-part-range* *v-part-range* *t-part-range*))

(defparameter *l-part-range* (code-point:make-range #x1100 #x1112) ; #\HANGUL_CHOSEONG_KIYEOK … #\HANGUL_CHOSEONG_HIEUH
  "The range of code points encoding l parts of lv and lvt Hangul syllables.")

(defparameter *v-part-range* (code-point:make-range #x1161 #x1175) ; #\HANGUL_JUNGSEONG_A … #\HANGUL_JUNGSEONG_I
  "The range of code points encoding v parts of lv and lvt Hangul syllables.")

(defparameter *t-part-range* (code-point:make-range #x11A8 #x11C2) ; #\HANGUL_JONGSEONG_KIYEOK … #\HANGUL_JONGSEONG_HIEUH
  "The range of code points encoding t parts of lvt Hangul syllables.")

(defun l-and-v-part-of-lv-syllable (octets start end)
  ;; Return 3 values: code point, code point and the sum of their encoding lengths
  ;;              (or        nil         nil     zero).
  (multiple-value-bind (l-part v-start)
      (utf-8:decode-code-point octets start)
    (if (and (code-point:in-range? l-part *l-part-range*)
             (< v-start end))
        (multiple-value-bind (v-part v-end)
            (utf-8:decode-code-point octets v-start)
          (if (code-point:in-range? v-part *v-part-range*)
              (values l-part v-part (- v-end start))
              (values nil nil 0)))
        (values nil nil 0))))
      

(defun t-part-of-lvt-syllable (octets start end)
  ;; Return 2 values: code point and its encoding length.
  ;;;             (or        nil     zero)
  (if (< start end)
      (multiple-value-bind (t-part t-end)
          (utf-8:decode-code-point octets start)
        (if (code-point:in-range? t-part *t-part-range*)
            (values t-part (- t-end start))
            (values nil 0)))
      (values nil 0)))
 
(defun lvt-syllable-parts (octets start end)
  ;; Return 4 values: code point, code-point, code-point and the sum of their encoding lengths.
  ;;              (or        nil         nil         nil     zero)
  (multiple-value-bind (l-part v-part lv-length)
      (l-and-v-part-of-lv-syllable octets start end)
    (if l-part
        (multiple-value-bind (t-part t-length)
            (t-part-of-lvt-syllable octets (+ start lv-length) end)
          (if t-part
              (values l-part v-part t-part (+ lv-length t-length))
              (values l-part v-part nil lv-length)))
        (values nil nil nil 0))))

(defun compose-lv-or-lvt-syllable (l-part v-part &optional t-part)
  (+ *s-base*
     (+ (* (- l-part *l-base*) *n-count*)
        (* (- v-part *v-base*) *t-count*))
     (if t-part
         (- t-part *t-base*)
         0)))

;; We need to deal with lv + t parts U+11A8..U+11C2
(defun lv-and-t-parts (octets start)
  (if (eql :lv (unicode:hangul-syllable-type-of octets start))
      (multiple-value-bind (lv-part lv-length)
          (utf-8:decode-code-point octets start)
        (multiple-value-bind (t-part t-length)
            (t-part-of-lvt-syllable octets (+ start lv-length))
          (if t-part
              (values lv-part t-part (+ lv-length t-length))
              (values nil nil 0))))
      (values nil nil 0)))
    

;;; ============================================================================
;;; Canonical and Compatibility Composition.
;;; ============================================================================
;;;
;;; 3.11.6 Canonical Composition Algorithm
;;;   https://www.unicode.org/versions/Unicode18.0.0/core-spec/chapter-3/#G50628

(defun last-starter-preceding-c (octets c)
  "Returns the index of the first code point preceding c that has a combining
class of zero, or nil if there is no such code point."
  (loop for l = (utf-8:previous octets c) then (utf-8:previous octets l)
        when (zerop (unicode:canonical-combining-class-of octets l))
        do (return l)
        while (plusp l)))

(defun blocked-pair? (octets a c)
  "Returns true if there exists a code point b following a and immediately
preceding c where the canonical combining class of b is zero, or greater than
that of c."
  (let ((b (utf-8:previous octets c)))
    (unless (= a b)
      (let ((ccc-b (unicode:canonical-combining-class-of octets b)))
        (or (zerop ccc-b)
            (>= ccc-b (unicode:canonical-combining-class-of octets c)))))))


(defun canonical-composition (octets &key (start 0) end)
  (let ((start start) ; start may migrate towards end (i.e. code points in front are deleted).
        (end (vector:end octets end)))
    ;; Initially check for a composable Hangul syllable at start. If there is
    ;; one, its encoded length is likely shorter than the 2-3 code points it
    ;; is made up of. We push start towards end so as not to leave a gap
    ;; before the rest of the string.
    (multiple-value-bind (l-part v-part t-part length)
        (lvt-syllable-parts octets start end)
      (when (and l-part v-part)
        (let ((code-point (compose-lv-or-lvt-syllable l-part v-part t-part)))
          (incf start (- length (utf-8:encoded-length code-point)))
          (utf-8:encode-code-point code-point octets start))))
    ;; The loop begins at the second code point.
    (loop for c = (utf-8:next octets start) then (utf-8:next octets c)
          while (< c end)
          do (multiple-value-bind (l-part v-part t-part length)
                 (lvt-syllable-parts octets c end)
               (cond
                 ;; We check for a composable Hangul syllable.
                 ((and l-part v-part)
                  ;; If there is one, we leave a gap in between the new
                  ;; composition and the preceding part of octets. We move
                  ;; the preceding part towards the end, closing the gap, and
                  ;; incrementing our start index.
                  (let* ((code-point (compose-lv-or-lvt-syllable l-part v-part t-part))
                         (offset (- length (utf-8:encoded-length code-point)))
                         (new-c (+ c offset)))
                    (utf-8:encode-code-point code-point octets new-c)
                    (setf (subseq octets (+ start offset) new-c) (subseq octets start c))
                    (incf start offset)
                    (setf c new-c)))
                 (t
                  (let ((l (last-starter-preceding-c octets c)))
                    (when l
                      (unless (blocked-pair? octets l c)
                        ;; in our prototype, primary-composite returns a
                        ;; structure: it contains an octet sequence of two
                        ;; code points and the code point those two are
                        ;; composed of.
                        (let ((p (unicode:primary-composite-of octets l octets c))) ; not defined yet
                          (when p
                            ;; l and c need not be adjacent
                            (let* ((plen (utf-8:encoded-length p))
                                   (lend (+ l (utf-8:encoding-length octets l)))
                                   (cend (+ c (utf-8:encoding-length octets c)))
                                   (pend (+ lend (- cend c)))
                                   (pstart (- pend plen)))
                              (unless (= lend c)
                                ;; If there are code points in between l and c we
                                ;; relocate them so that they overwrite c.
                                (setf (subseq octets pend cend)
                                      (subseq octets lend c)))
                              ;; Insert p
                              (utf-8:encode-code-point p octets pstart)
                              (unless (= pstart l)
                                ;; When there is space between l and pstart we relocate
                                ;; octets from start to l.
                                (setf (subseq octets (+ start (- pstart l)) pstart)
                                      (subseq octets start l))
                                ;; The empty space is now in front of start.
                                (incf start (- pstart l)))
                              ;; The next iteration of the loop starts with the code
                              ;; point following the newly inserted code point.
                              (setf c pstart)))))))))))
    (subseq octets start end)))

(declaim (ftype (function (utf-8:octets)
                          utf-8:octets)
                to-nfd to-nfc to-nfkd to nfkc))

;;; Note that the decompose function (used by canonical-decomposition and
;;; compatibility-decomposition) makes a copy of the input sequence. The
;;; original is left unchanged.

(defun to-nfd (octets)
  (let ((decomposition (canonical-decomposition octets)))
    (place-in-canonical-order decomposition 0 (length decomposition))))

(defun to-nfc (octets)
  (canonical-composition (to-nfd octets)))

(defun to-nfkd (octets)
  (let ((decomposition (compatibility-decomposition octets)))
    (place-in-canonical-order decomposition 0 (length decomposition))))

(defun to-nfkc (octets)
  (canonical-composition (to-nfkd octets)))
