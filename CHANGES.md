# CHANGES

This release of srcml is a drop-in replacement for the previous srcml client and libsrcml library. Except for Python, v1.1.0 does not make any changes to the markup for C, C++, Java, and C#. It does fix many markup bugs.

It includes:

* In addition to C, C++, C#, and Java, 1.0.0 markup for the Python programming language
* New query language srcQL, which allows querying by using code statements and includes unification, e.g., `FIND $T $N = new $T()`
* New output format for source with null separators (similar to `find`) and an optional YAML header with attributes and namespaces
* Additional libsrcml functions, including per-language versions, srcql, and full control of attributes and namespaces for units and archives
* Multiple bug fixes, including more accurate line/column position
* Many build improvements
