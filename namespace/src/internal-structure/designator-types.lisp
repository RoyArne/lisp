;;;; This is "namespace/src/internal-structure/designator-types.lisp".

(in-package #:namespace)

;;; Location designators are used within the internal-structure module.

(deftype location-designator ()
  "An object that is used in place of where a package may be located: either nil
or a package object."
  `(or null package))

;;; String, package and home designators are used in the conditions,
;;; designator-resolution and package-interface modules.

(deftype string-designator ()
  "An object that is used in place of a string: either a string, symbol,
common-lisp:string or a common-lisp:symbol."
  `(or string symbol common-lisp:string common-lisp:symbol))

(deftype package-designator ()
  "An object that is used in place of a package object: either a string
designator or a package object."
  `(or string-designator package))

(deftype home-designator ()
  "An object that is used in place of a package home: either nil or a package
designator."
  `(or null package-designator))
