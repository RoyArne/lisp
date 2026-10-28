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

- \*lisp\*—expected to hold the system library (for example "COMMON-LISP").
- \*keyword\*—the keyword package.
- \*user\*—the initial current package. empty, uses \*lisp\* and \*keyword\*.
- \*package\*—the current package.
- \*packages\*—the list of top-level packages.

### \*lisp\*

This is a system package. We do not have a special class of system
packages, but the package held in this variable receives special
treatment by delete-package:

- a package-is-a-system-package error is signaled if we attempt to
  delete it. An option allows us to 'continue' without deleting the
  package.

We should consider special treatment by other functions as well. For
example, what are the consequences of renaming the \*lisp\* package?

- initially, packages that are already loaded will function as they
  did before: our packages stores references to package objects, not
  to their names.
- further name resolution becomes impossible, which means new packages
  cannot be loaded (unless they do not depend on the system library at
  all).

This is not desirable.

Moving on we should first enumerate which functions could leave name
resolution impossible.

Then we probably need to implement a system like [SBCLs package lock
mechanism](https://www.sbcl.org/manual/#package-locks). We could use
our existing variables, but this is neither flexible nor robust:

- if a package should not be tampered with it should not rely on
  external mechanisms to say that,

- a system of special variables means user cannot implement their own
  locks (not easily anyway, they'd have to wrap the package interface
  inside their own interface).


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