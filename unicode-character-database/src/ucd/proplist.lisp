
(defpackage #:unicode-character-database.proplist
  (:use #:common-lisp
        #:unicode-character-database)

  (:local-nicknames (#:files #:unicode-character-database.files)
                    (#:parser #:unicode-character-database.parser)
                    (#:table #:unicode.table))

  (:export #:proplist!
           #:write-proplist-tables)
  
  (:documentation
   "The #:unicode-character-database.proplist package creates property tables from
PropList.txt in the Unicode Character Database.

We export two functions, proplist! which returns a list of data base lines
where each line takes the form:

  \(code-point property-name-symbol\)

and write-proplist-tables which will write the tables to the
\"unicode/data/UCD/PropList/\" directory, one file per property table.

See (Table 9. Property Table,
PropList.txt)[https://www.unicode.org/reports/tr44/#PropList.txt] for a
description of the named properties."))

(in-package #:unicode-character-database.proplist)

(defparameter *names* nil)

(defun parse-proplist-name (field)
  (let* ((name (parser:parse-symbol-name field))
         (symbol (find-symbol name "UNICODE")))
    (unless symbol
      (error "While parsing~%  PropList.txt~%~
              There is no symbol corresponding to~%  ~S~%~
              in the UNICODE package."
             field))
    (pushnew symbol *names*)
    symbol))

(defun parse-proplist-line (line)
  (list (first line) (parse-proplist-name (second line))))

(defun parse-proplist (proplist)
  (mapcar 'parse-proplist-line proplist))

(defparameter *proplist* nil)

(defun load-proplist! ()
  (setf *proplist* (parse-proplist (parser:load-database-file "UCD/PropList.txt")))
  t)

(defun proplist! ()
  (unless *proplist*
    (load-proplist!))
  *proplist*)

(defun make-table (property-name)
  (table:construct-property-table (property-name)
    (loop for code-point in (mapcar 'first (parser:filter-lines 1 (proplist!) :predicate (lambda (name)
                                                                                           (eql name property-name))))
          do (table:add-entry code-point))))

(defun write-proplist-tables ()
  (load-proplist!)
  (files:write-tables (files:input-pathname "UCD/PropList.txt") *names* (mapcar 'make-table *names*))
  t)

  
