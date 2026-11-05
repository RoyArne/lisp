
# A Superset of the Common Lisp Package System

The namespace system is a designed as a hierarchical implementation of
the Common Lisp Package System. It is intended to be compatible with
the following exceptions:

- we use _?_ (question mark) to end predicate function names, for
  example **packagep** becomes **package?**.

- we do not allow nicknames (local nicknames are allowed).


## System Organization

The file "namespace.asd" specifies external dependencies and component
load order. If the system is located in [a place quicklisp can
see](http://blog.quicklisp.org/2018/01/the-quicklisp-local-projects-mechanism.html),
you can load it with (ql:quickload "namespace").

The **#:namespace** package definition is found in "namespace.lisp".

The entire system lives in a single namespace with functionality split
into modules (directories and files inside the "src" directory:

- _classes_—**package** and **symbol** class definitions.

  **package** objects stores data regarding relationships between
  packages and which symbols are accessible. **symbol** objects are
  implemented as names that can be shared between packages.
  
- _internal-structure_–a layer between the _classes_ and
  _package-interface_/_symbol-interface_ modules.

  Functions to manipulate and locate packages in the hierarchy are
  defined in _package-manipulation.lisp_. Functions to locate and
  share symbols are defined in _symbol-manipulation.lisp_.

- _designator-resolution_—turn designators into the designated
  objects.

  Designator types are defined in the _internal-structure_
  module. They are objects that are used in place of other objects.
  For example, a string designator is a symbol or a string; both of
  which resolves into a string.

- _conditions_—**package-error** condition definitions.

- _package-interface_–public interface for **package** operations.

  Defines a superset of the functions listed in [The Packages
  Dictionary](https://www.lispworks.com/documentation/HyperSpec/Body/c_packag.htm).

- _symbol-interface_—public interface for **symbol** operations.

  This component is organized like the _package-interface_
  component. Functions implemented so far are those needed to add
  symbols to packages,

- _compatibility_—interoperability with standard Common Lisp.

  This includes printer functions to display our packages and symbols,
  and methods that allow us to use standard CL strings and symbols as
  arguments to our public interface.


## Test System Organization

We also have a **#:test-namespace** package found in "test-namespace.lisp".

Tests are distributed in one file per component, named
"test-\<component name\>.lisp". For example
"test-package-interface.lisp" in "src/package-interface".

To load the tests, do

- (ql:quickload "namespace/tests")
- (fiveam:run! 'test-namespace:namespace)


## Terms

- _location_—indicates where to look for a package.

- _home_—where a package is located.

- _peer_—a package that has the same home as a given package.

- _top-level_—the list of packages that are not located inside another
  package, **\*packages\***.

- _internal package_—a a package that is not at the top-level.

- _visible_—a package that can be found by **find-package**, and appears
  in **list-all-packages**.

- _current package_—package operations act on this package unless
  specified otherwise, **\*package\***.


## The Package Hierarchy

- **\*package\*** holds the current package (as in Common Lisp).

- **\*packages\*** holds the list of top-level packages.

- Each package has a list of internal packages, returned by
  (**package-internal-list** _package_) → _list of package objects_.

- They also have a list of packages they are internal to, returned by
  (**package-internal-to-list** _package_) → _list of package
  objects_.

- the three variables **\*lisp\***, **\*keyword\*** and **\*user\*** holds
  packages equivalent to "COMMON-LISP", "KEYWORD", and "CL-USER" in
  Common Lisp.


```
──────────────────────────────────────────────────────────────────────────────
 ┌─┐                                  ┌─┐                  ┌─┐
 │a│                                  │b│                  │c│    ← top-level
 └┬┘                                  └┬┘                  └─┘ 
─ ├──────────────────┬─────┐ ─ ─ ─ ─ ─ ├────┐ ─ ─ ─ ─ ─ ─ ─ ─ ─  ─────────────
 ┌┴─┐               ┌┴─┐  ┌┴─┐        ┌┴─┐ ┌┴─┐
 │aa│               │ab│  │ac│        │ba│ │bb│                   ← internal
 └┬─┘               └┬─┘  └┬─┘        └┬─┘ └──┘
─ ├──────┐ ─ ─ ─ ─ ─ │ ─ ─ ├─────┐ ─ ─ ├──────┬─────┐ ─ ─ ─ ─ ─  ─────────────
 ┌┴──┐  ┌┴──┐       ┌┴──┐ ┌┴──┐ ┌┴──┐ ┌┴──┐  ┌┴──┐ ┌┴──┐
 │aaa│  │aab│       │aba│ │aca│ │acb│ │baa│  │bab│ │bac│          ← internal
 └┬──┘  └┬──┘       └───┘ └───┘ └───┘ └┬──┘  └┬──┘ └───┘
─ │ ─ ─  ├──────┬──────┐ ─ ─ ─ ─ ─ ─ ─ │ ─ ─  ├──────┐ ─ ─ ─ ─ ─ ─────────────
 ┌┴───┐ ┌┴───┐ ┌┴───┐ ┌┴───┐          ┌┴───┐ ┌┴───┐ ┌┴───┐
 │aaaa│ │aaba│ │aabb│ │aabc│          │baaa│ │baba│ │babb│        ← internal
 └────┘ └────┘ └────┘ └────┘          └────┘ └────┘ └────┘
──────────────────────────────────────────────────────────────────────────────
                    Above: A sample package hierarchy.
──────────────────────────────────────────────────────────────────────────────
```

In the sample above, _\*packages\*_ would hold **(a b c)**. We let
_\*package\*_ be **a** initially. The variables _\*lisp\*_,
_\*keyword\*_ and _\*user\*_ are not relevant for this example.

### Inspecting the Package Hierarchy

Using the sample above:

- (**list-all-packages**) → (ac ab aa a b c)

  returns a list of all packages that are visible from the current
  package.
  
- (**list-peer-packages**) → (a b c)

  returns a list of packages that share the same home package as the
  current package.

- (**package-package** "a") → nil

  returns the home package of the given package. This is _nil_ for
  top-level packages.

- (**package-internal-to-list** "a") → nil

  returns a list of packages that are direct ancestors of the given package,
  i.e. its home package, the home package of the home package, and so
  on.

- (**package-internal-list** "a") → (ac ab aa)

  returns a list of packages that are direct children of the given
  package. Packages are listed in the order they were added to the
  system, most recent first.

### Visible Packages

As seen above, **list-all-packages** does not return every package in
the system; only __visible__ packages are returned: Given a package
_p_, the visible packages are the concatenation of:

- its internal list, and the peer list of each of its direct
  ancestors.

Let the current package be aab:

- (**list-all-packages**) → (aabc aabb aaba aab aaa ac ab aa a b c)

meaning that **list-all-packages** looks one level down from the
current package, and then up and to the sides of every level above.

### Finding Packages

- (**find-package** "ac") → \#\<PACKAGE ac\>

  returns a visible package with the given name, or a locally
  nicknamed package with that name.
