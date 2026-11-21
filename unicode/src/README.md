
# The Unicode System

## unicode.lisp

This is the package definition for the whole unicode system. It
exports names and lookup functions for properties from the Unicode
Character Database.

## files.lisp

The **#:unicode.files** package provides an interface for getting our
data file pathnames.

- (**data-directory-pathname**) → pathname

  Returns the path to our data directory, "unicode/data/".

- (**table-pathname _filespec_) → pathname

  Returns the pathname to _filespec_ within our data directory.

Our data directory mirrors the [Unicode Character
Database](https://www.unicode.org/Public/UCD/latest/). It may have
additional data files, and our tables are saved as one table per
file. For example:

Take the file "UCD/PropList.txt". It lists a number of properties, for
example _white-space_ and _pattern-white-space_. One table is created
for both properties, and stored as
"unicode/data/UCD/PropList/white-space.lisp" and
"unicode/data/UCD/PropList/pattern-white-space.lisp".

Note the addition of the "PropList" directory, replacing the
"PropList.txt" file in the original database. Other files from the UCD
are treated the same way.

We also have some additions of our own. They mimic the system outlined
above.

## code-point.lisp

The **#:unicode.code-point** package defines a code-point type as a 21-bit
unsigned integer. It also provides a range structure and some
functions for working with code-point ranges.

The main use for these types is in the unicode-character-database
system, for parsing data files and producing character tables.

The **code-point** type:

- **code-point**
- (**code-point?** _object_) → _boolean_

The **range** structure and accessors/type predicate.

- **range**
- (**range-start** _range_) → _code-point_
- (**range-end** _range_) → _code-point_
- (**make-range** _start_ _end_) → _range_
- (**range-p** _object_) → _boolean_

Interface for dealing with code points and ranges:

- (**start** _value_) → _code-point_
- (**end** _value_) →  _code-point_

  Both **start** and **end** accepts a **range** or a **code-point**,
  returning the lowest/highest code-point in the **range**. Code
  points are their own min and max value.
  
- (**in-range?** _value_) → _boolean_
- (**less-than-range?** _value_) → _boolean_
- (**greater-than-range?** _value_) → _boolean_
- (**overlapping-ranges?** _value_) → _boolean_
- (**adjacent-ranges?** _value_) → _boolean_

  The above predicates all accept a **range** or a **code-point**.

Finally we export

- (**in-unicode-range?** _code-point_) → _boolean_
- (**in-surrogate-range?** _code-point_) → _boolean_

## utf-8

The **#:unicode.utf-8** package provides functionality for dealing
with utf-8 encoded text.

## table

The **#:unicode.table** package provides table structures that are
mainly used to store data from the Unicode Character Database.

It also provides the functions that are used to load and lookup
characters in the tables.

## normalization.lisp

The **#:unicode.normalization** package implements the unicode
normalization forms found in [3.11.3 Specification of Unicode
Normalization
Forms](https://www.unicode.org/versions/Unicode18.0.0/core-spec/chapter-3/#G49576).

The interface is exported from the **#:unicode** package as well as
the **#:unicode.normalization** package:

- (**to-nfd** _octets_) → _canonical-decomposition_
- (**to-nfc** _octets_) → _canonical-composition-of-canonical-decomposition_
- (**to-nfkd** _octets_) → _compatibilty-decomposition_
- (**to-nfkc** _octets_) →  _canonical-composition-of-compatibility-composition_

The interface is not finalized, we likely want to pass start and end indices.

Se also [Unicode® Standard Annex #15 Unicode Normalization
Forms](https://unicode.org/reports/tr15/).

## rope

We define a rope data structure in **#:unicode.rope**. For now it is
used in our string type, but this may change.
