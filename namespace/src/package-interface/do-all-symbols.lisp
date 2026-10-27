;;;; This is "namespace/src/package-interface/do-all-symbols.lisp".

(in-package #:namespace)


(defmacro do-all-symbols ((var &optional (result-form 'nil)) &body body)
  "Syntax:
\(do-all-symbols \(var &optional result-form\) &body body\)

Arguments and Values:
var—a variable name.
result-form—a form: The default is nil.
body—a body form as described below.

Description:
Iterates over the symbols accessible in package. For each symbol, var is bound
to the symbol, and statements in the body form are executed. When all the
symbols have been processed, result-form is evaluated and returned.

The body form is an optional declare form followed by zero or more
statements. Any tag in the body is treated as with tagbody.

Statements may execute more than once for symbols that are present in multiple
packages.

An implicit block named nil surronds the entire do-all-symbols. return or
return-from may be used to end the iteration prematurely.

var is bound to nil when result-form is evaluated."
  (let ((function-name (common-lisp:gensym "DO-ALL-SYMBOLS-BODY"))
        (package-variable (common-lisp:gensym "DO-ALL-SYMBOLS-PACKAGE")))
    ;; separate-declarations-and-body is defined in src/utilities.lisp.
    (multiple-value-bind (declarations body-forms)
        (separate-declarations-and-body body)
      `(block nil
         (flet ((,function-name (,var)
                  ,@declarations
                  (tagbody ,@body-forms)))
           (loop for ,package-variable in (list-all-packages)
                 do (process-internal-symbols (symbol ,package-variable)
                      (,function-name symbol))
                 do (process-external-symbols (symbol ,package-variable)
                      (,function-name symbol))))
         (let ((,var nil))
           ,result-form)))))
