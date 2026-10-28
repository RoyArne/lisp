# Classes

The classes module defines the **package** and **symbol** classes, and
tests in "test-classes.lisp".

## Package

The package class is a piece of data storage for the namespace
hierarchy: it stores

- the name for this package object, a string.

- nicknames that may only be used from this package to locate other
  package objects. Also strings.

- package objects. We do not refer to packages by names, instead
  direct references to package objets are stored.

- symbol objects.

The package class autodefines methods for reading its slots, but not
for writing. They can only be manipulated by functions in the
internal-structure module.

### Package Slots

The **name** and **local-nicknames** are used to locate packages.

**name**

- a string.

**local-nicknames**

- an association list. Each element is a cons cell, (nickname . package).


The **internal-list** and **internal-to-list** are used to place the
package in the hierarchy. A package that has an empty
**internal-to-list** is placed in the top-level list of packages,
\*packages\*.

**internal-list**

- a list of package objects that have this package as their home
  package.

**internal-to-list**

- a list of package objects that this package is internal to. The
  first package in this list is its home package, the second is the
  home package of its home package, and so on.


The **use-list** and **used-by-list** are used to check for symbol
name conflicts. They allow packages access to symbols in other
packages without importing them, or using their qualified names (like
**namespace:delete-package**).

Symbols accessible by means of the **use-list** are _inherited_ by the
package.

**use-list**

- a list of package objects that this package inherits symbols from.

**used-by-list**

- a list of package objects that inherits symbols from this package.

The **internal-symbols**, **external-symbols**, and
**shadowing-symbols** slots store symbol objects which are _present_
in package, either as _internal_ or _external_ symbols.

A symbol must not be stored in both **internal-symbols** and
**external-symbols**.

A symbol being _present_ does not mean that it is their home package,
the symbol may have been imported.

**internal-symbols**

- implemented as a hash-table. Symbol names are keys and objects are
  values.
- Symbols stored here are not accessible by means of use-package
  (i.e. packages in the **used-by-list** cannot see these symbols).

**external-symbols**

- implemented like **internal-symbols**.
- Symbols stored here _are_ accessible by means of use-package
  (i.e. packages in the **used-by-list** _can_ see these symbols).

**shadowing-symbols**

- a list of symbol objects.
- Symbols in this list must also be present in either
  **internal-symbols** or **external-symbol**.
- Being present in this list means that the symbol takes precedence in
  a potential name conflict.

## Exporting and Extending Packages

The hierarchy as designed does not allow access to internal packages
from outside a package.

Say the current package is a top-level package "P" with two internal
packages, "P1" and "P2". The top-level looks like this: ("P" "A" "B").

list-all-packages would return ("P1" "P2" "P" "A" "B") even if each of
those packages had their own internal packages.

I'd like to implement a method to make internal packages
accessible. First, by using "dotted" package names, for example using
"unicode.utf-8" to refer to an internal "utf-8" package in the
"unicode" package.

This would work by first checking if the "unicode" package was
accessible. If it was, we'd check if "utf-8" had been published by the
"unicode" package before allowing access.

In terms of **defpackage** it might look something like this:

```
(defpackage "P"
  (:publish "P1" "P2")
  (:extend "P1" "A-SYMBOL" "B-SYMBOL")
  (:extend "P2" "B-SYMBOL" "C-SYMBOL"))

(defpackage "P1"
  (:export "A-SYMBOL" "B-SYMBOL"))

(defpackage "P2"
  (:export "B-SYMBOL" "C-SYMBOL"))
```

This means we need forward references, because the home package "P"
must be defined before the internal packages "P1" and "P2" (or we'de
need forward references in "P1" and "P2", but probably messier).

The forward references would be names, resolved as soon as "P1"/"P2"
made "P" their home package.

It would be an error if we tried to access any internal package before
their home package resolved the forward references.

Simply having a forward reference is not an error, and if it is never
accessed we may end up with a technically broken, but functioning
system.

Extending packages means we forcibly make them import the symbols we
are extending them with.
