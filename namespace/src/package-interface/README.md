# Package Interface

The package interface module defines the public interface for
interacting with packages. The goal here is to:

1. Implement all the functions, macros and variables mentioned in
chapter [11.2 The Packages
Dictionary](https://www.lispworks.com/documentation/HyperSpec/Body/c_packag.htm)
in the Common Lisp Hyperspec.
2. in a way that is compatible with Common Lisp,
3. including package local nicknames as defined in chapter [7.2
Package-Local
Nicknames](https://www.sbcl.org/manual/#package-local-nicknames) of
the SBCL manual,
4. while adding a package hierarchy.

We do add some incompatible constraints:

1. There are no package nicknames,
2. and we end predicate names with a question mark (**?**), not **p**.

## Organization

Every symbol is defined in its own file, i.e. there is one file
"defpackage.lisp" defining **defpackage**,
"package-shadowing-symbols.lisp" **defining
package-shadowing-symbols**, and so on.

Documentation strings in this module differs from others in that they
**specify** what our implementation **should do**, they do not
_describe what it does_.

## Status

- Test definitions are in progress.
- Name validation is missing. Consider [Unicode Security Mechanisms](http://www.unicode.org/reports/tr39/), [Unicode Identifiers and Syntax](https://www.unicode.org/reports/tr31/).
- A way to copy the current contents of a running Lisps package system could be useful.
- I probably want a way to export packages, and resolve dotted package designators.