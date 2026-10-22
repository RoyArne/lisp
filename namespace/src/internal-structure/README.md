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

Functions in the package-interface and symbol-interface module relies
on the functionality within to locate, create and delete packages,
designate local nicknames, and share symbols.

Package and symbol manipulators accept their work without checking for
errors: the package-interface and symbol-interface modules are
responsible for signaling and correcting errors.