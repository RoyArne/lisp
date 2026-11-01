
# The "System" System

## Condition

Contains one file, "condition.lisp", which defines the program-error
condition. At the moment it is only used in the "namespace" system.

This module will define system wide conditions and the condition
system itself.

## Sequence

Contains one file. "vector.lisp", which implements some type
definitions and functions that operate on vectoprs in general.

Their use at the moment, is in the "unicode" system, primarily for
octet vectors.

## Documentation

Nothing implemented yet, but a system wide documentation system is
probably needed.

Presently, it will be used in the "namespace" system to provide the
documentation slot for packages.
