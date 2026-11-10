
### UTF-8

## utf-8.lisp

Defines the package **#:unicode.utf-8**.

## type-definitions.lisp

Type definitions for **octet**, **octets** and **encoding-length**. We
also define the corresponding type predicates **octet?**, **octets?**
and **encoding-length?**.

### Exports

- **octet**—a byte, and
- **octets**—an octet vector.

## conditions.lisp

For now we define a general purpose condition, **utf-8-error**, that
is signaled for all kinds of errors related to the utf-8 encoding.

### Exports
- **utf-8-error**—a condition,
- (**utf-8-error-octets** _utf-8-error_)—a reader, may return nil, an octet, octets or a code-point, and
- (**utf-8-error-message** _utf-8-error_)—a reader, returning the format message used to report the condition.

## encoding-and-decoding.lisp

Defines functions and variables needed to read and write the
components of utf-8 encoded text.

### Exports

- (**initial-octet** _code-point_) → octet,
- (**%encoding-length** _octet_) → encoding-length,
- (**encoded-length** _vector_ _start_ → encoding-length),
- (**octet-range-start** _encoding-length_) → code-point,
- (**octet-range-end** _encoding-length_) → code-point,
- (**encode-code-point** _code-point_ _vector_ _start_) → index,
- (**decode-code-point** _vector_ _start_) → code-point, index,
- (**push-code-point** _code-point_ _vector_) → index,
- (**in-1-octet-range?** _code-point_) → boolean,
- **+1-octet-range-start+**—code-point constant,
- **+1-octet-range-end+**—code-point constant,
- (**in-2-octet-range?** _code-point_) → boolean,
- **+2-octet-range-start+**—code-point constant,
- **+2-octet-range-end+**—code-point constant,
- (**in-3-octet-range?** _code-point_) → boolean,
- (**in-low-3-octet-range?** _code-point_) → boolean,
- (**in-high-3-octet-range?** _code-point_) → boolean,
- **+3-octet-range-start+**—code-point constant,
- **+3-octet-range-low-end+**—code-point constant,
- **+1-octet-range-high-start+**—code-point constant,
- **+3-octet-range-end+**—code-point constant,
- (**in-4-octet-range?** _code-point_) → boolean,
- **+4-octet-range-start+**—code-point constant, and
- **+4-octet-range-end+**—code-point constant.

## vectors.lisp

Contains functions to create and navigate vectors of utf-8 encoded
text.

### Exports
- (**make-octets** (or _vector:size_ _list_ _vector_)) → octets,
- (**make-adjustable-octets** _vector:size_) → octets,
- ~~empty?~~ Not defined in this file!,
- **\*empty\***—an octets constant,
- (**next** _vector_ _start_) → index, and
- (**previous** _vector_ _start_) → index.

## stream.lisp

Defines an **octet-stream** structure that is wrapped around a stream
by means of **initialize-octet-stream**. Once wrapped, we can use
**read-code-point** to move utf-8 encoded text from the stream into an
octet vector.

### Exports

- **octet-stream**—a structure,
- (**initialize-octet-stream** _stream_) → octet-stream, and
- (**read-code-point** _octet-stream_ _vector_ _start_) → index, boolean indicating end of file if true.

## comparisons.lisp

Defines functions to compare vectors of utf-8 encoded text.

### Exports

- (**compare** _vector1_ _start1_ _end1_ _vector2_ _start2_ _end2_) → integer, mismatch index,
- (**octets=** _vector1_ _vector2_ &key _start1_ _end1_ _vector2_ _start2_ _end2_) → integer, mismatch index,
- (**octets≠** _vector1_ _vector2_ &key _start1_ _end1_ _vector2_ _start2_ _end2_) → mismatch index or nil,
- (**octets<** _vector1_ _vector2_ &key _start1_ _end1_ _vector2_ _start2_ _end2_) → mismatch index or nil,
- (**octets>** _vector1_ _vector2_ &key _start1_ _end1_ _vector2_ _start2_ _end2_) → mismatch index or nil,
- (**octets≤** _vector1_ _vector2_ &key _start1_ _end1_ _vector2_ _start2_ _end2_) → mismatch index or nil,
- (**octets≥** _vector1_ _vector2_ &key _start1_ _end1_ _vector2_ _start2_ _end2_) → mismatch index or nil,
- (**code-point=** _vector1_ _start1_ _ _vector2_ _start2_) → boolean
- (**code-point≠** _vector1_ _start1_ _ _vector2_ _start2_) → boolean
- (**code-point<** _vector1_ _start1_ _ _vector2_ _start2_) → boolean
- (**code-point>** _vector1_ _start1_ _ _vector2_ _start2_) → boolean
- (**code-point≤** _vector1_ _start1_ _ _vector2_ _start2_) → boolean
- (**code-point≥** _vector1_ _start1_ _ _vector2_ _start2_) → boolean

## fnv-1a.lisp

Defines the [Fowler–Noll–Vo hash
function](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function)
for octet vectors.

### Exports

- (**fnv-1a/64** _vector_ &key _hash_) → hash
- (**fnv-1a/32** _vector_ &key _hash_) → hash

## compatibility.lisp

### Exports

- (**string-to-octets** _string_ &optional _start_ _end_) → octets
- (**octets-to-string** _vector_ &optional _start_ _end_) → string
