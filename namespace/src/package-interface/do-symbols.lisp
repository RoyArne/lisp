;;;; This is "namespace/src/package-interface/do-symbols.lisp".

(in-package #:namespace)

(defmacro do-symbols ((var &optional (package '*package) (result-form 'nil)) &body body)
  "Syntax:
\(do-symbols \(var &optional package result-form\) &body body\)

Arguments and Values:
var—a variable name.
package—a package designator. The default is *package*.
result-form—a form: The default is nil.
body—a body form as described below.

Description:
Iterates over the symbols accessible in package. For each symbol, var is bound
to the symbol, and statements in the body form are executed. When all the
symbols have been processed, result-form is evaluated and returned.

The body form is an optional declare form followed by zero or more
statements. Any tag in the body is treated as with tagbody.

Statements may execute more than once for symbols that are inherited from
multiple packages.

An implicit block named nil surronds the entire do-symbols. return or
return-from may be used to end the iteration prematurely.

var is bound to nil when result-form is evaluated."
  (let ((function-name (common-lisp:gensym "DO-SYMBOLS-BODY"))
        (package-variable (common-lisp:gensym "DO-SYMBOLS-PACKAGE")))
    ;; separate-declarations-and-body is defined in src/utilities.lisp.
    (multiple-value-bind (declarations body-forms)
        (separate-declarations-and-body body)
      `(block nil
         (flet ((,function-name (,var)
                  ,@declarations
                  (tagbody ,@body-forms)))
           (let ((,package-variable (resolve-package-designator ,package)))
             (loop for symbol being each hash-value of (external-symbols ,package-variable)
                   do (,function-name symbol))
             (loop for symbol being each hash-value of (internal-symbols ,package-variable)
                   do (,function-name symbol))
             (loop for used-package in (use-list ,package-variable)
                   do (loop
                        for symbol being each hash-value of (external-symbols ,package-variable)
                        unless (find symbol (shadowing-symbols ,package-variable))
                        do (,function-name symbol)))))
         (let ((,var nil))
           ,result-form)))))
