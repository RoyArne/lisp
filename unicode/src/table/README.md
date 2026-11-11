
# Code Point Tables

## table.lisp

This is the package definition, **#:unicode.table**. It makes use of
**#:common-lisp**, **#:unicode**, **#:unicode.code-point**,
**#:unicode.utf-8**, and **#:system.sequence.vector**.

## type-definitions.lisp

Defines the table structures.

### Exports

- **property-table**—a structure.

  Any code point added to a property table has the property named in
  the tables **property** slot. The function **has-property?** returns
  the property.

- **property-map**—a structure.

  Maps code points to some property. The function
  **property-mapping-of** returns the property.

- **code-point-map**—a structure.

  Maps code points to one other code point. The function
  **code-point-mapping-of** returns the code point.

- **string-map**—a structure.

  Maps code points to octet vectors. The function
  **string-mapping-of** returns the octet vector.

## construction.lisp

Defines a set of macros to create tables. Note that code points
**must** be added in _ascending_ order, otherwise the lookup functions
will not work.

### Exports

- **add-entry**

  The **add-entry** function is locally available inside the macros
  below. Its arguments varies by the type of table being constructed.

- (**construct-property-table** (_property_) &body _body_) → _property-table_

  (**add-entry** _code-point/range_) → (values)
    
- (**construct-code-point-map** () &body _body_) → _code-point-map_

  (**add-entry** _code-point/range_ _code-point_) → (values)

- (**construct-property-map** (&key _test_) &body _body_) → _property-map_

  (**add-entry** _code-point/range property_) → (values)

- (**construct-string-map** (() &body _body_) → _string-map_

  (**add-entry** _code-point/range_ _octets_) → (values)

For example,
```
(construct-property-map (:test #'=)
  (loop for code-point in (sort (map 'list #'char-code "ABCDEFÆØÅ-.,—–·…") #'<)
        for property = (random 3)
        do (add-entry code-point property)))
```

constructs a table mapping characters to a random number chosen at
construction time.

Note that the test argument is **=** because the property is a number,
and entries may be joined if two adjacent code points have the same
property. We also sort the input so that code points are added in
ascending order.


## lookup.lisp

Functions to lookup code points in tables. Note that all the functions
expect to work directly on utf-8 encoded text.

### Exports

- (**has-property?** _vector_ _start_ _property-table_) → _property_

  Returns **t** if the code point is in the table, otherwise *nil*.
  
- (**property-mapping-of** _vector_ _start_ _property-map_) → _property_

  Property here is whatever value it is. Its type definition is **t**.

- (**code-point-mapping-of** _vector_ _start_ _code-point-map_) → _code-point_

  Returns a code point by means of
  #:unicode.utf-8:decode-code-point. The table contains utf-8 encoded
  code points. We probably want a function to write this data into
  some vector upon lookup.

- (**string-mapping-of** _vector_ _start_ _string-map_) → _octets_

  Returns an octet vector. We probably want an option to write this
  into some vector too.

## stream.lisp

Defines functions to read/write tables from/to streams.

### Exports

- (**read-table** &key _stream_ _table-type_) → _table_
- (**write-table** (_table_ &optional _stream_) → _table_
- (**write-property-table** _table_ &optional _stream_) → _property-table_
- (**read-property-table** &optional _stream_) → _property-table_
- (**write-property-map** _table_ &optional _stream_) → _property-map_
- (**read-property-map** &optional _stream_) → _property-map_
- (**write-code-point-map** _table_ &optional _stream_) → _code-point-map_
- (**read-code-point-map** &optional _stream_) → _code-point-map_
- (**write-string-map** _table_ &optional _stream_) → _string-map_
- (**read-string-map** &optional _stream_) → _string-map_

## unicodedata.lisp

Reads table data from the unicode/data/ directory and defines lookup
functions for each table. Default, empty tables are used for any files
that are not found.

The data files are created by the "unicode-character-database" system,
specifically by the **#:unicode-character-database.unicodedata**
package.

The source data file is
[unicodedata.txt](https://www.unicode.org/L2/L1999/UnicodeData.html).

### Exports

- (**mirrored?** _vector_ _start_)
- (**general-category-of** _vector_ _start_)
- (**decimal-digit-value-of** _vector_ _start_)
- (**digit-value-of** _vector_ _start_)
- (**numeric-value-of** _vector_ _start_)
- (**uppercase-of** _vector_ _start_)
- (**lowercase-of** _vector_ _start_)
- (**titlecase-of** _vector_ _start_)
- (**character-name-of** _vector_ _start_)
- (**combining-class-of** _vector_ _start_)
- (**bidirectional-category-of** _vector_ _start_)
- (**canonical-decomposition-of** _vector_ _start_)
- (**compatibility-decomposition-of** _vector_ _start_)
