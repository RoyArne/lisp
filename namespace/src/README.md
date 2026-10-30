# A Superset of the Common Lisp Package System

The namespace system is a designed as a hierarchical implementation of
the Common Lisp Package System.

## System Organization

The file "namespace.asd" specifies external dependencies and component load order.

The **#:namespace** package definition is found in "namespace.lisp".

The entire system lives in a single namespace with functionality split
into modules (directories and files inside the "src" directory:

- classes—**package** and **symbol** class definitions.

  The classes serves as data storage and objects for method
  specialization. The internal-structure component below is used to
  manipulate class slots, and store package objects in the top-level
  of the hierarchy.

- conditions—**package-error** condition definitions.

  Defines error conditions. Some are signaled by designator resolution
  in the internal-structure component, but most signal an error during
  package-interface operations.

- internal-structure—variable definitions, package, symbol and
  hierarchy manipulation.

  The internal-structure components serves as a layer between classes
  and package/symbol-interface. The external interfaces combine calls
  into this module to perform their operations.

- package-interface–public interface for packages and their
  interactions with symbols.

  This component defines one function per file. Each is exported from
  the namespace package as part of its external interface. By design,
  errors are intended to be signaled from here: we do not want
  internal operations to appear in a stack trace.

- symbol-interface—public interface for symbols.

  This component is organized like the package-interface
  component. Functions implemented so far are those needed to add
  symbols to packages,

- compatibility—interoperability with standard Common Lisp.

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


## The Package Hierarchy

- _\*package\*_ holds the current package (as in Common Lisp).

- _\*packages\*_ holds the list of top-level packages.

- Each package has a list of internal packages, returned by
(**package-internal-list** _package_) → _list of package objects_.

- They also have a list of packages they are internal to, returned by
(**package-internal-to-list** _package_) → _list of package objects_.

- the three variables _\*lisp\*_, _\*keyword\*_ and _\*user\*_ holds
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
