;;;; This is "namespace/src/package-interface/unintern.lisp".

(in-package #:namespace)

(defgeneric unintern (symbol &optional package)

  (:documentation "Syntax:
\(unintern symbol &optional package\) → generalized-boolean

Arguments and Values:
symbol—a symbol.
package—a package designator. The default is the current package.
generalized-boolean—t, or nil.

Description:
unintern removes symbol from package. If symbol is present in package,
it is removed from package and also from package's shadowing symbols
list if it is present there. If package is the home package for
symbol, symbol is made to have no home package. Symbol may continue to
be accessible in package by inheritance.

Use of unintern can result in a symbol that has no recorded home
package, but that in fact is accessible in some package. Common Lisp
does not check for this pathological case, and such symbols are always
printed preceded by #:.

unintern returns true if it removes symbol, and nil otherwise.")

  (:method ((symbol symbol) &optional (package *package*))
    (declare (type package-designator package))
    (let ((package (resolve-package-designator package *package*)))
      (multiple-value-bind (present-symbol status)
	  (find-symbol (symbol-name symbol) package)
        ;; :inherited symbols are available due to :use-package. Because they
        ;; are not present in either internal-symbols or external-symbols, we
        ;; don't need to do anything (i.e. the symbol is not interned).
	(unless (eql status :inherited)
          ;; if the symbol we found in package is a different symbol then we
          ;; don't need to do anything (i.e. another symbol with the same name
          ;; is interned).
	  (when (eql present-symbol symbol)
            ;; Are we uninterning a shadowing symbol? If so, uninterning it
            ;; could lead to name conflicts between other symbols
            ;; (i.e. symbols that are shadowed will become visible).
	    (when (shadowing-symbol? symbol package)
              ;; This loop checks for name conflicts.
              ;;
              ;; We start out with there being no conflicting-symbol. Then we
              ;; go through the packages used by this package and look for an
              ;; external-symbol with the name that will no longer be
              ;; shadowed.
              ;;
              ;; Finding one is ok, we need two for a conflict.
              ;;
              ;; Since conflicting-symbol starts out as nil, the if test will
              ;; always fail on the first iteration.
              ;;
              ;; But if we find a symbol with the above name, we set
              ;; conflicting-symbol to that symbol. This happens on every
              ;; iteration.
              ;;
              ;; On subsequent iterations, we may find another symbol with the
              ;; same name. If so, uninterning our initial symbol will cause
              ;; them to conflict, and we signal an error.
	      (loop with conflicting-symbol = nil
		    with name = (name symbol)
		    for using-package in (use-list package)
		    for external-symbol = (find-external-symbol name using-package)
		    do (if (and external-symbol conflicting-symbol)
			   (error 'conflicting-symbol-names
			          :package package
			          :context *package*
			          :symbol symbol
			          :conflicting-symbol conflicting-symbol
                                  :message (format nil "Cannot unintern the shadowing symbol~~%  ~~S~~%~
                                                        because it causes conflict between~~%  ~S~~%~
                                                        and~~%  ~~S,~~%~
                                                        both external symbols used by~~%  ~~S~~%~
                                                        in the context~~%  ~~S."
						   external-symbol))
			   (setf conflicting-symbol external-symbol))))
            ;; All clear, do the removing and set symbol's home package to nil.
	    (case status
	      (:internal (remove-internal-symbol symbol package))
	      (:external (remove-external-symbol symbol package)))
	    (remove-shadowing-symbol symbol package)
            (when (eql package (package symbol))
              (setf (package symbol) nil))
	    t))))))
