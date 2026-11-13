
# The Unicode System

## unicode.lisp

This is the package definition for the whole unicode system. It is an
empty package presently; we still need to figure out what goes in it.

## configuration.lisp

Provides pathname information regarding the Unicode Character Database
tables. The "unicode-character-database" system depends these to parse
the database and store the generated tables.

We still need to determine the directory structure for the data files.
At the moment we have one file per table, all in the "unicode/data/"
directory.

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

## rope

We define a rope data structure in **#:unicode.rope**. For now it is
used in our string type, but this may change.
