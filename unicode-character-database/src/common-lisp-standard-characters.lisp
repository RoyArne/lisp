
(defpackage #:unicode-character-database.common-lisp
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:code-point #:unicode.code-point)
                    (#:utf-8 #:unicode.utf-8)
                    (#:table #:unicode.table))

  (:export #:common-lisp-syntax-types
           #:write-common-lisp-syntax-types
           #:common-lisp-traits
           #:write-common-lisp-traits))
  
(in-package #:unicode-character-database.common-lisp)

(defparameter *common-lisp-characters*
  "a;small a;LA01;constituent;alphadigit;standard
A;capital A;LA02;constituent;alphadigit;standard
b;small b;LB01;constituent;alphadigit;standard
B;capital B;LB02;constituent;alphadigit;standard
c;small c;LC01;constituent;alphadigit;standard
C;capital C;LC02;constituent;alphadigit;standard
d;small d;LD01;constituent;alphadigit;standard
D;capital D;LD02;constituent;alphadigit;standard
e;small e;LE01;constituent;alphadigit;standard
E;capital E;LE02;constituent;alphadigit;standard
f;small f;LF01;constituent;alphadigit;standard
F;capital F;LF02;constituent;alphadigit;standard
g;small g;LG01;constituent;alphadigit;standard
G;capital G;LG02;constituent;alphadigit;standard
h;small h;LH01;constituent;alphadigit;standard
H;capital H;LH02;constituent;alphadigit;standard
i;small i;LI01;constituent;alphadigit;standard
I;capital I;LI02;constituent;alphadigit;standard
j;small j;LJ01;constituent;alphadigit;standard
J;capital J;LJ02;constituent;alphadigit;standard
k;small k;LK01;constituent;alphadigit;standard
K;capital K;LK02;constituent;alphadigit;standard
l;small l;LL01;constituent;alphadigit;standard
L;capital L;LL02;constituent;alphadigit;standard
m;small m;LM01;constituent;alphadigit;standard
M;capital M;LM02;constituent;alphadigit;standard
n;small n;LN01;constituent;alphadigit;standard
N;capital N;LN02;constituent;alphadigit;standard
o;small o;LO01;constituent;alphadigit;standard
O;capital O;LO02;constituent;alphadigit;standard
p;small p;LP01;constituent;alphadigit;standard
P;capital P;LP02;constituent;alphadigit;standard
q;small q;LQ01;constituent;alphadigit;standard
Q;capital Q;LQ02;constituent;alphadigit;standard
r;small r;LR01;constituent;alphadigit;standard
R;capital R;LR02;constituent;alphadigit;standard
s;small s;LS01;constituent;alphadigit;standard
S;capital S;LS02;constituent;alphadigit;standard
t;small t;LT01;constituent;alphadigit;standard
T;capital T;LT02;constituent;alphadigit;standard
u;small u;LU01;constituent;alphadigit;standard
U;capital U;LU02;constituent;alphadigit;standard
v;small v;LV01;constituent;alphadigit;standard
V;capital V;LV02;constituent;alphadigit;standard
w;small w;LW01;constituent;alphadigit;standard
W;capital W;LW02;constituent;alphadigit;standard
x;small x;LX01;constituent;alphadigit;standard
X;capital X;LX02;constituent;alphadigit;standard
y;small y;LY01;constituent;alphadigit;standard
Y;capital Y;LY02;constituent;alphadigit;standard
z;small z;LZ01;constituent;alphadigit;standard
Z;capital Z;LZ02;constituent;alphadigit;standard
1;digit 1;ND01;constituent;alphadigit;standard
2;digit 2;ND02;constituent;alphadigit;standard
3;digit 3;ND03;constituent;alphadigit;standard
4;digit 4;ND04;constituent;alphadigit;standard
5;digit 5;ND05;constituent;alphadigit;standard
6;digit 6;ND06;constituent;alphadigit;standard
7;digit 7;ND07;constituent;alphadigit;standard
8;digit 8;ND08;constituent;alphadigit;standard
9;digit 9;ND09;constituent;alphadigit;standard
0;digit 0;ND10;constituent;alphadigit;standard
!;exclamation mark;SP02;constituent;alphabetic;standard
$;dollar sign;SC03;constituent;alphabetic;standard
\";quotation mark, or double quote;SP04;terminating macro character;alphabetic;standard
';apostrophe, or single quote;SP05;terminating macro character;alphabetic;standard
(;left parenthesis, or open parenthesis;SP06;terminating macro character;alphabetic;standard
);right parenthesis, or close parenthesis;SP07;terminating macro character;alphabetic;standard
,;comma;SP08;terminating macro character;alphabetic;standard
_;low line, or underscore;SP09;constituent;alphabetic;standard
-;hyphen, or minus sign;SP10;constituent;alphabetic;standard
.;full stop, period, or dot;SP11;constituent;alphabetic;standard
/;solidus, or slash;SP12;constituent;alphabetic;standard
\\;reverse solidus, or backslash;SM07;single escape;alphabetic;standard
:;colon;SP13;constituent;package marker;standard
?;question mark;SP15;constituent;alphabetic;standard
+;plus sign;SA01;constituent;alphabetic;standard
=;equals sign;SA04;constituent;alphabetic;standard
<;less-than sign;SA03;constituent;alphabetic;standard
>;greater-than sign;SA05;constituent;alphabetic;standard
%;percent [sign];SM02;constituent;alphabetic;standard
&;ampersand;SM03;constituent;alphabetic;standard
*;asterisk, or star;SM04;constituent;alphabetic;standard
@;commercial at, or at-sign;SM05;constituent;alphabetic;standard
[;left square bracket;SM06;constituent;alphabetic;standard
];right square bracket;SM08;constituent;alphabetic;standard
{;left curly bracket, or left brace;SM11;constituent;alphabetic;standard
};right curly bracket, or right brace;SM14;constituent;alphabetic;standard
|;vertical bar;SM13;multiple escape;alphabetic;standard
`;grave accent, or backquote;SD13;terminating macro character;alphabetic;standard
^;circumflex accent;SD15;constituent;alphabetic;standard
#;number sign, or sharp sign;SM01;non-terminating macro character;alphabetic;standard
~;tilde;SD19;constituent;alphabetic;standard"
  "Fields separated by ';': code-point; name; graphic-id; syntax-type; traits; status")


;;; The *common-lisp-characters* variable holds a string that summarises 2.1.3
;;; Standard Characters (https://www.lispworks.com/documentation/HyperSpec/Body/02_ac.htm),
;;; 2.1.4 Character Syntax Types (https://www.lispworks.com/documentation/HyperSpec/Body/02_ad.htm), and
;;; 2.1.4.2 Constituent Traits (https://www.lispworks.com/documentation/HyperSpec/Body/02_adb.htm)
;;; in the Common Lisp HyperSpec.
;;;
;;; Some characters are omitted from the table because they are annoying to
;;; deal with: ; semicolon, newline, space, tab, linefeed, page, return,
;;; backspace and rubout.
;;;
;;; They are supplied in the functions below.

(defun list-fields (line &optional code-point)
  ;; Accepts a line of fields separated by semi-colons. Optionally, the first
  ;; field may be ommitted from line and supplied as a code point.
  ;;
  ;; The fields are: (code-point name graphic-id syntax-type traits)
  (let ((fields (split-sequence:split-sequence #\; line :test #'char= :remove-empty-subseqs nil)))
    (cons (or code-point
              (char-code (char (first fields) 0)))
          (mapcar #'(lambda (field)
                      (string-trim '(#\Space) field))
                  (if code-point
                      fields
                      (rest fields))))))

(defun read-fields (&optional (data *common-lisp-characters*))
  (sort (with-input-from-string (stream data)
          (append (loop for line = (read-line stream nil nil) while line
                        collect (list-fields line))
                  (list (list-fields "semicolon;SP14;terminating macro character;alphabetic;standard" (char-code #\;))
                        (list-fields "newline;not-applicable;whitespace;invalid;standard" (char-code #\Linefeed))
                        (list-fields "space;not-applicable;whitespace;invalid;standard" (char-code #\Space))
                        (list-fields "tabulator;not applicable;whitespace;invalid;" (char-code #\Tab))
                        (list-fields "page;not applicable;whitespace;invalid;" (char-code #\Page))
                        (list-fields "return;not applicable;whitespace;invalid;"  (char-code #\Return))
                        (list-fields "backspace;not applicable;constituent;invalid;" (char-code #\Backspace))
                        (list-fields "rubout;not applicable;constituent;invalid;" (char-code #\Rubout)))))
        '<
        :key 'first))

(defun print-character (line &optional (stream *standard-output*))
  ;;      code-point;name;graphic ID;syntax-type;Traits;status
  (destructuring-bind (code-point name graphic-id syntax-type traits status)
      line
    (format stream "~4,'0X;~A;~A;~A;~A;~A~%" code-point name graphic-id syntax-type traits status)))

(defun print-characters (lines &optional (stream *standard-output*))
  (loop for line in lines
        do (print-character line stream)))

(defun read-common-lisp-standard-characters ()
  (with-input-from-string (stream (with-output-to-string (stream) (print-characters (read-fields) stream)))
    (read-database-stream stream)))

(defparameter *common-lisp-character-database* nil)

(defun common-lisp-character-database! ()
  (when (null *common-lisp-character-database*)
    (setf *common-lisp-character-database* (read-common-lisp-standard-characters)))
  *common-lisp-character-database*)

(defun string-to-keyword (string)
  (intern (substitute #\- #\Space (string-upcase string)) "KEYWORD"))

(defmacro with-output-stream ((stream filename) &body body)
  `(with-open-file (,stream
                   (data-pathname ,filename)
                   :direction :output
                   :if-exists :supersede
                   :if-does-not-exist :create
                   :external-format :utf-8)
     ,@body))

;;; We make a syntax-type property-map with the following
;;; properties:"whitespace" "non-terminating macro character" "single escape"
;;; "terminating macro character" "multiple escape" "constituent"

(defun common-lisp-syntax-types ()
  (table:construct-property-map (:test 'eql)
    (loop for line in (common-lisp-character-database!)
          do (with-nth-fields line ((code-point 0)
                                    (syntax-type 3))
               (table:add-entry code-point (string-to-keyword syntax-type))))))
          
(defun write-common-lisp-syntax-types ()
  (with-output-stream (stream "common-lisp-syntax-types.lisp")
    (table:write-property-map (common-lisp-syntax-types) stream)))

;;; We make a traits property map with the following properties: "package
;;; marker" "alphadigit" "alphabetic" "invalid".

(defun common-lisp-traits ()
  (table:construct-property-map (:test 'eql)
    (loop for line in (common-lisp-character-database!)
          do (with-nth-fields line ((code-point 0)
                                    (trait 4))
               (table:add-entry code-point (string-to-keyword trait))))))

(defun write-common-lisp-traits ()
  (with-output-stream (stream "common-lisp-traits.lisp")
    (table:write-property-map (common-lisp-traits) stream)))
