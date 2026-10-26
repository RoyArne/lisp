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

Below, symbols that are not crossed out ~~like this~~ have an initial
implementation, but tests are not complete yet.

### Status of The Packages Dictionary Implementation

- [ ] **package** (System Class)

  Implemented but tests are not written. Note that the class is
  implemented in the classes module.

- [ ] **export** (Function)

  Implemented with tests written. There is one [unresolved
  issue](https://github.com/RoyArne/lisp/issues/1#issue-5945890843). It
  has to do with error correction during an export/import interaction.
  
- [x] **find-symbol** (Function)
      
- [x] **find-package** (Function)

- [ ] **find-all-symbols** (Function)

- [x] **import** (Function)

- [x] **list-all-packages** (Function)

- [x] **rename-package** (Function)

- [x] **shadow** (Function)

- [ ] **shadowing-import** (Function)

- [x] **delete-package** (Function)

- [ ] **make-package** (Function)

- [ ] ~~with-package-iterator~~ (Macro)

- [ ] **unexport** (Function)

- [x] **unintern** (Function)

- [x] **in-package** (Macro)

- [x] **unuse-package** (Function)

- [x] **use-package** (Function)

- [ ] **defpackage** (Macro)

  We need to define a program-error condition, defpackage is required
  to call it if :size or :documentation appears more than once.

  We also need to signal a program-error if an option we do not
  recognize appear (for example :nicknames, see package-nicknames).

  The :documentation and :size options are not implemented.

- [ ] **do-symbols** (Macro)

- [ ] **do-external-symbols** (Macro)

- [ ] **do-all-symbols** (Macro)

- [x] **intern** (Function)

- [x] **package-name** (Function)

- [x] ~~package-nicknames~~ (Function) (**will NOT implement**)

  Package nicknames will not be added. However, if I want to load
  Common Lisp source code I have to deal with nicknames somehow.

  One way is to simply add a duplicate package for every nickname. Or
  inject a package local nickname into every package that references a
  nickname (for example "CL" for Common Lisp).

  This leaves defpackage forms, the make-package function and of
  course calls to package-nicknames.

  One option is to define a package subclass, common-lisp-package, and
  add the required machinery around it. Most functions will work the
  same, with the exception of conflict cheks.

  The conflict testing could involve a large number of functions (and
  work).

- [ ] **package-shadowing-symbols** (Function)

- [x] **package-use-list** (Function)

- [x] **package-used-by-list** (Function)

- [x] ~~packagep~~ (Function) (**implementing as package?**)

  All predicates are implemented as _name_?. packagep is implemented
  as package?.

- [x] **package?** (Function)

- [x] **\*package\*** (Variable)

      Note that \*package\* is implemented in the internal-structure module.

- [ ] **package-error** (Condition Type)

- [ ] **package-error-package** (Function)


### Status of Specialized package-error Conditions

The conditions below are subtypes of **package-error**, their initial
implementation is complete but I still need to test them.

- [x] **conflicting-package-names** (Condition Type)

Tested in the package local nickname and rename-package tests.

- [x] **conflicting-symbol-names** (Condition Type)

Tested in the **export** and **use-package** tests.

- [x] **package-does-not-exist** (Condition Type)

Tested in the **in-package** and package local nickname tests. 	    

- [ ] **package-error-conflicting-name** (Function)

- [ ] **package-error-conflicting-symbol** (Function)

- [ ] **package-error-context** (Function)

- [ ] **package-error-message** (Function)

- [ ] **package-error-symbol** (Function)

- [x] **package-is-a-system-package** (Condition Type)

Tested in the delete-package tests.

- [x] **package-is-in-use** (Condition Type)

Tested in the delete-package tests.

- [x] **package-is-the-current-package** (Condition Type)

Tested in the delete-package tests.

- [ ] **package-symbol-error** (Condition Type)

- [x] **symbol-is-not-accessible** (Condition Type)

Tested in the **export** tests.


### Status of Package-Local Nicknames Implementation

- [x] **package-local-nicknames** (Function)

- [ ] ~~package-locally-nicknamed-by-list~~ (Function)

- [x] **add-package-local-nickname** (Function)

- [x] **remove-package-local-nickname** (Function)



### Status of Package Hierarchy Implementation

At some point I need to make an "initialise-system-packages" module,
subsytem or function. It needs to setup the variables \*packages\*,
\*package\*, \*lisp\*, \*keyword\*, and \*user\*.

- [x] **list-peer-packages** (Function)

- [x] **package-internal-list** (Function)

- [x] **package-internal-to-list** (Function)

- [x] **package-package** (Function)

- [ ] **\*keyword\*** (Variable)

  Holds an empty package named "keyword". Note that \*keyword\* is
  implemented in the internal-structure module.

  There is an unresolved issue regarding what type of package can be
  stored in it: we want it to be a top-level package that posess any
  special properties that a keyword package has (this is not defined
  yet).

- [ ] **\*lisp\*** (Variable)

  Intended to hold the system library package. For now it is an empty
  package named "lisp". Note that \*lisp\* is implemented in the
  internal-structure module.

  There is an unresolved issue regarding what type of package can be
  stored in it: we want it to be a top-level package. Preferably one
  that implements the lisp-system, but maybe it is ok to allow users
  to replace it. For example, we may want to make a \*packages\*
  top-level for a Common Lisp compatibility system. It would have its
  own \*lisp\*.

  ```
  (defun top-level-package? (object)
    (and (package? object)
         (null (package-package object))))
	 
  (deftype top-level-package ()
    `(satisfies top-level-package?))
  ```

- [ ] **\*packages\*** (Variable)

  When it comes to internal functionality, this works as expected. But
  it does not have the restrictions I would like for external users.

  The top-level list of packages is defined as a list for now. It
  **really** needs to be a list of packages, and I need a type system
  that enforces that. I suppose something like

  ```
  (defun package-list? (object)
    (and (typep object 'list)
         (every #'(lambda (element)
	            (typep element 'package))
	        object)))
	 
  (deftype package-list ()
    `(satisfies package-list?))
  ```

  defines the type, but I'm not sure Common Lisp enforces it in all
  situations.


- [ ] **\*user\*** (Variable)

  Holds an empty package named "user".