# Internal Structure

The internal-structure module is used to intersect classes and
conditions with the public facing interfaces in package-interface and
symbol-interface:

- package-interface and symbol-interface defines what can be done,
- internal structure provides methods to do it.

## Designator Types

We define a few types to be used in place of names and package
objects.

- string-designator—these are symbols or strings, to be used where a
  name is expected.

- package-designator—these are string-designators, or package
  objects. They can be used where a package is expected.

- home-designators—a few function calls require a home package. These
  are either nil (meaning a top-level package), or a package object.

- context-designators—these are used when a function needs to work
  from a place in the package hierarchy. Usually this defaults to
  \*package\*, and some functions like **list-all-packages* does this
  implicitly.

For each designator there is a function, resolve-X-designator, which
returns the designated value. Note that failed designator resolution
may signal an error of type package-error, check the individual
resolutors.

## Initial Packages and Locations

We define a few variables to store and help navigate the package hierarchy:

- \*packages\*—the list of top-level packages.
- \*package\*—the current package.
- \*lisp\*—expected to hold the system library (for example "COMMON-LISP").
- \*keyword\*—the keyword package.
- \*user\*—the initial current package. empty, uses \*lisp\* and \*keyword\*.


## Package and Symbol Manipulation

Operations in the package interface, like find-symbol, export, intern,
import and shadow relies on "symbol-manipulation.lisp" to manipulate
the relevant slots in package objects

Slots related to the package hierarchy are manipulated through
"package-manipulation.lisp".


## Package Manipulation

The file "package-manipulation.lisp" implements functions for

- adding and removing nicknames,
- producing lists of packages that are accessible,
- searching for packages in the above lists,
- adding and removing packages from the hierarchy, and
- manipulating the package use and used by lists.


No error checking is performed in the above operations: the package
interface is responsible for that.


## Symbol Manipulation

The "symbol-manipulation.lisp" file is implements functions for

- adding and removing symbols from packages, and
- searching for symbols.

No error checking is performed, the package interface is responsible
for that.


## Status

Better type checking for \*packages\*, \*lisp\* and \*keyword\* is required:

- \*packages\* must hold a list of packages, and those packages must
  be top-level packages.
- \*lisp\* and \*keyword\* must hold a top-level package.

However, type definitions are not implemented yet, and they don't
belong in the namespace system.

Name validation likely goes in this module, it is manipulation of the
name slots in symbols and packages.