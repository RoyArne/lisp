
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

## utf-8

The **#:unicode.utf-8** package provides functionality for dealing
with utf-8 encoded text.

## table

The **#:unicode.table** package provides table structures that are
mainly used to store data from the Unicode Character Database.

It also provides the functions that are used to load and lookup
characters in the tables.

## rope

We define a rope data structure in **#:unicode.rope**. For now it is
used in our string type, but this may change.
