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
**shadowing-symbols** slots store symbol objects. Symbols stored here
are _present_ in package, either as _internal_ or _external_ symbols.

A symbol being present in a package does not mean that it is their
home package, the symbol may have been imported.

**internal-symbols**

- implemented as hash-table using symbol names as keys and objects as
  values. Symbols stored here are not accessible by means of
  use-package (i.e. packages in the **used-by-list** cannot see these
  symbols).

**external-symbols**

- implemented as hash-table using symbol names as keys and objects as
  values. Symbols stored here _are_ accessible by means of use-package
  (i.e. packages in the **used-by-list** _can_ see these symbols).

**shadowing-symbols**

- a list of symbol objects. Symbols in this list must also be present
  in either **internal-symbols** or **external-symbol**. Being present
  in this list means that the symbol takes precedence in a potential
  name conflict.
