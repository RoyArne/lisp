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

### Extending Packages

Extending a package makes symbols from the home package available to
the named package. This is distinct from exporting which makes symbols
available to all who uses the exporting package.

One use-case is test packages, like "TEST-NAMESPACE" for the
"NAMESPACE" package. If we take a look at tests in
"src/classes/test-classes.lisp" we see direct references to symbols in
"NAMESPACE" that are not exported from "NAMESPACE", for example:

```
ns::local-nicknames
```

I do not intend to implement this syntax, namespaces should be closed
with only explicitly exported symbols accessible: there should be a
record of symbols being shared (from where and to whom). We want to be
able to inspect/investigate the system at any point in its lifetime.

However, there is a need to investigate the internal workings of
"NAMESPACE" during testing. We could define the tests inside the
"NAMESPACE" package, but this feels messy. There is no longer a clean
boundary between distinct systems, even if this boundary is only
crossed while running tests.

Using some sort of (:extends …) syntax would make the symbols
explicitly available to "TEST-NAMESPACE" in the defpackage form for
"NAMESPACE", while keeping other packages out:

```
(defpackage #:namespace
  …
  (:extends #:test-namespace                   ; package we're extending
            #:name #:local-nicknames           ; symbols being shared
	    #:internal-lits #:internal-to-list
	    #:use-list #:used-by-list
	    #:internal-symbols #:external-symbols #:shadowing-symbols)
  …)
```

Again, we will need a forward referenced packages. We must also
include some sort of storage for the symbols we're extending with, and
some way to tie these to the package being extended. And we need an
underlying interface that defpackage can employ to extend
packages. This interface would also be exported from
package-interface.

Say we use the **import** function to place a symbol in
"TEST-NAMESPACE". This stores the symbol in the internal-symbols
slot. It may also signal correctable errors and end up shadowing the
symbol or uninterning another one. It leaves no trace of how the
symbol ended up there. Do we want the extended package to know this?

Maybe it doesn't need to. The home package is in charge of this
process, and could be responsible for storing this information:

We have then,

- a package name (the forward reference to the extended package)
- a package object (the extended package)
- a list of symbols (to be imported in the extended package)

The extending package must store the forward reference and the
associated list of symbols upon executing the :extends option. This
could be done with a hash-table, mapping package names to lists of
symbols.

```
(unresolved-extensions …) ; possible slot name
```

When can we resolve the extension? The extended package will add
itself to its home package as step 1 of the defpackage
option execution (the name is not an option).

1. :home.
2. :local-nicknames
3. :shadow and :shadowing-import-from.
4. :use.
5. :import-from and :intern.
6. :export.

We need to consider symbol collisions that may arise. If we add them
at step 2, our extension may be shadowed. We can't add them later,
unless we install som signaling between the packages:

- having it's internal-list updated is the only way the extending
  package gets a notification of the package we want to extend.
- other interactions do not include the extended package in a way that
  says it is special. we have to do extra work to figure that out.

We need to push the symbols we're extending with at step 1. Do we also
need to say "you're being extended"?

Take the following example, we create a top-level package "BYSTANDER"
first. The "SOURCE" package follows.

```
(defpackage "BYSTANDER"
  (:export "B"))
  
(defpackage "SOURCE"
  (:extend "TARGET"
           "A" "B" "C"))

(defpackage "TARGET"
  (:home "SOURCE")
  (:shadow "A")
  (:shadowing-import-from "BYSTANDER"
                          "B")
  (:intern "C"))
```

Third, we make the "TARGET" package:

1. :home option executed. "TARGET" places itself in "SOURCE"s
   internal-list.

   "SOURCE" executes (import '(A B C) "TARGET"), placing 3 symbols in
   "TARGET"s internal-symbols.

2. ~~we ignore package nicknames for now.~~

3. "TARGET" shadows "A". It adds our extended "A" to its shadowing-symbols.

   "TARGET" executes (shadowing-import "B" "BYSTANDER"). Our "B" extension is gone.

4. ~~not present here.~~

5. "TARGET" interns "C". Our extended "C" is left alone.

From this it looks like the problematic one is :shadowing-import,
silently nuking our extension "B".

We did not do an :import-from but if we did (:import-from "BYSTANDER"
"B") it would signal a name conflict. It's the silently part of
:shadowing-import that is problematic:

- on the one hand, we want "TARGET" to be in charge of it's namespace,
  that is the point of them.
- on the other hand, "SOURCE" is in a way superior to "TARGET". It may
  be surprise the "SOURCE" definer if the instructions are quietly
  ignored.

Ulitmately I do believe "TARGET" should have final say.

### Finally

Not mentioned above, the :publish and :extends options should only be
allowed for packages that are directly related, i.e the one who
publishes and extends must be the home package of the other.

Nothing stops an extended package from extending downwards in the
hierarchy.