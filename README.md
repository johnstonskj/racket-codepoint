codepoint
=========

Library for operations on Unicode codepoints, and UCD properties.

[![GitHub release](https://img.shields.io/github/release/johnstonskj/racket-codepoint.svg?style=flat-square)](https://github.com/johnstonskj/racket-codepoint/releases)
[![raco pkg install codepoint](https://img.shields.io/badge/raco%20pkg%20install-codepoint-blue.svg)](https://pkgs.racket-lang.org/package/codepoint)
[![Documentation](https://img.shields.io/badge/raco%20docs-codepoint-blue.svg)](http://docs.racket-lang.org/codepoint/index.html)
[![GitHub stars](https://img.shields.io/github/stars/johnstonskj/racket-codepoint.svg)](https://github.com/johnstonskj/racket-codepoint/stargazers)
![MIT License](https://img.shields.io/badge/license-MIT-118811.svg)

This package provides types that describe individual Unicode [codepoints](https://unicode.org/glossary/#code_point),
codepoint ranges, and [character properties](https://unicode.org/glossary/#character_properties). The following 
example demonstrates the query of certain character properties that explain the behavior of combining the letter `#\a`
with the character `U+0304`.

```racket
(codepoint? #x0304)
; -> #t
(ucd-name #x0304)
; -> "COMBINING MACRON"
(ucd-general-category #x0304)
; -> 'Mn
(cdr (assoc (ucd-general-category #x0304) *general-categories*))
; -> "Non-spacing mark"
(ucd-canonical-combining-class #x0304)
; -> 230
(cdr (assoc (ucd-canonical-combining-class #x0304) *combining-classes*))
; -> "Distinct marks directly above"
(string #\a (codepoint->char #x0304))
; -> "ā"
```

The functions in `codepoint/properties` return the values extracted from the Unicode Character Database, and the only 
conversion is typically string to number or string to symbol. Descriptions of the values that are returned are gathered in 
`codepoint/enums` for display purposes.

# Modules

* `codepoint` -- functions on the type `codepoint?`.
* `codepoint/range` -- functions on an inclusive range of `codepoint?` values.
* `codepoint/range-dict` -- a dictionary keyed by `codepoint-range?` values.
* `codepoint/properties` -- Unicode Character Database (UCD) properties for `codepoint?` values.
* `codepoint/enums` -- enumeration values found in UCD properties.
* `codepoint/fold` -- implementation of case-folding based on UCD properties.

# Data Generation

TBD

# Version History

**Version 0.2**

* Most documentation now complete, renamed scribbling root file from index to codepoint.
* Removed the shell script for fetching UCD files and rewrote as ucd module.

**Version 0.1**

* Initial upload.