;;;; This is "namespace/src/internal-structure/designator-types.lisp".

(in-package #:namespace)

(deftype string-designator ()
  "Description:
String designators are symbols and strings, used in place of package names and
local nicknames.

The function resolve-string-designator returns a string for a given
string-designator.

If the string designator is a symbol then the string that is its name is used.

Strings represent themselves when used as a string designator.

Note:
This definition includes Common Lisp strings and symbols for ease of testing."
  `(or string symbol common-lisp:string common-lisp:symbol))

(deftype package-designator ()
  "Description:
Package designators are used in place of package objects. They can be string
designators or package objects.

The function resolve-package-designator returns a package object for a given
package-designator."
  `(or string-designator package))

(deftype context-designator ()
  "Description:
Context designators are used by the function list-all-packages to
compute its result. They are either nil, or, a package object.

The function resolve-context-designator returns either nil, or, a
package object, for a given context-designator."
  `(or null package))

(deftype home-designator ()
  "Description:
Home designators are used when symbols and packages are assigned home
packages. A home-designator is either nil, or, a package-designator.

The function resolve-home-designator returns a package object, or,
nil, for a given home-designator."
  `(or package-designator null))
