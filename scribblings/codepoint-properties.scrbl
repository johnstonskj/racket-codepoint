#lang scribble/manual

@(require 
  racket/sandbox
  scribble/core
  scribble/eval
  (for-label 
    racket/base
    racket/contract
    codepoint
    codepoint/properties
    codepoint/enums))

@(define example-eval 
         (make-base-eval
            '(require racket/bool 
                      codepoint
                      codepoint/properties
                      codepoint/enums)))

@title{UCD Properties}

The Unicode standard defines a large number of character properties which describe the type and behavior of
characters and character compositions. The data supporting these properties is collected into the 
@hyperlink["https://unicode.org/ucd/"]{Unicode Character Database} (UCD) and made available as either a set
of text files or XML files.

The functions below rely on a set of racket source files, expressed either as hashes or rang dicts, that are 
loaded lazily to fetch specific property values. The loading of the source data incurs a runtime penalty for
the first call that requires that specific data but once loaded this penalty is avoided in future calls.

These source files are generated by tooling from the 
@hyperlink["http://www.unicode.org/Public/UCD/latest/"]{latest UCD files} as described in the separate 
section @seclink["data-generator"]. 

@section[]{Module codepoint/properties}
@defmodule[codepoint/properties]

The functions below are either directly mapped to to a character property, or are derived from a character
property. 

@examples[
    #:eval example-eval
    (define cp (char->codepoint #\§))
    (ucd-latin-1? cp)
    (ucd-name cp)
    (ucd-name-aliases cp)
    (ucd-general-category cp)
    (cdr (assoc (ucd-general-category cp) *general-categories*))
    (ucd-age cp)
    (ucd-block-name cp)
    (ucd-scripts cp)
    (ucd-script-extensions cp (lambda () "None found!"))
    (ucd-line-break cp)
    (cdr (assoc (ucd-line-break cp) *line-breaks*))
]

For @italic{any} function below that performs a property lookup @italic{and} has a parameter named
@racket[failure-result], if no value is found for @racket[codepoint], then @racket[failure-result] determines the result:

@itemlist[
    @item{
        If @racket[failure-result] is a procedure, it is called (through a tail call) with no arguments to produce 
        the result.}

    @item{Otherwise, @racket[failure-result] is returned as the result.}
]

@defthing[*corresponding-unicode-version* string?]{ 
    This is a string representation of the Unicode version of the data files used to generate the
    functions below.
    @examples[
        #:eval example-eval
        (format 
          "Generated from UCD data, version ~a" 
          *corresponding-unicode-version*)
    ]
}

@defproc[(ucd-ascii? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is in the ASCII range. This function does not rely on loading any data.
}

@defproc[(ucd-latin-1? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is in the Latin-1 range. This function does not rely on loading any data.
}

@defproc[(ucd-name [c codepoint?]) string?]{
    Returns the name of this codepoint, this name is expressed in ASCII uppercase and a small set of punctuation
    characters.
}

@defproc[(ucd-name->symbol [c codepoint?]) symbol?]{
    Returns the name of this codepoint transformed into a symbol. Certain characters are replaced during the transform
    and so it is not bi-directional.
    @examples[
        #:eval example-eval
        (ucd-name->symbol #x49)
        (ucd-name->symbol 0)
        (ucd-name->symbol #x3400)
        (ucd-name->symbol #xF90B)
    ]
}

@defproc[(ucd-name-aliases [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) (listof string?)]{
    Return a list of alias names for the codepoint. 
}

@defproc[(ucd-general-category [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    Returns a symbol corresponding to the codepoint general category. This symbol is the commonly used abbreviated
    for, for example @racket['Lu] for @italic{Letter, uppercase}.
    @examples[
        #:eval example-eval
        (define macron (codepoint->char #x0304))
        (for ([char (list #\null #\space #\a #\A #\ༀ #\1 #\½ #\, #\] #\¥ macron)])
          (displayln 
            (format "~a  =>  ~a"
              char
              (cdr 
                (assoc 
                  (ucd-general-category (char->codepoint char)) 
                  *general-categories*)))))
    ]

    See @racket[*general-categories*] for a mapping from this symbol to a description.
}

@defproc[(ucd-letter-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as a letter.
    @examples[
        #:eval example-eval
        (ucd-letter-category? (char->codepoint #\null))
        (ucd-letter-category? (char->codepoint #\space))
        (ucd-letter-category? (char->codepoint #\a))
        (ucd-letter-category? (char->codepoint #\A))
        (ucd-letter-category? (char->codepoint #\ༀ))
        (ucd-letter-category? (char->codepoint #\1))
        (ucd-letter-category? (char->codepoint #\½))
        (ucd-letter-category? (char->codepoint #\,))
        (ucd-letter-category? (char->codepoint #\]))
        (ucd-letter-category? (char->codepoint #\¥))
        (ucd-letter-category? #x0304)
    ]
}

@defproc[(ucd-cased-letter-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as a cased (lower, upper, title) letter.
    @examples[
        #:eval example-eval
        (ucd-cased-letter-category? (char->codepoint #\null))
        (ucd-cased-letter-category? (char->codepoint #\space))
        (ucd-cased-letter-category? (char->codepoint #\a))
        (ucd-cased-letter-category? (char->codepoint #\A))
        (ucd-cased-letter-category? (char->codepoint #\ༀ))
        (ucd-cased-letter-category? (char->codepoint #\1))
        (ucd-cased-letter-category? (char->codepoint #\½))
        (ucd-cased-letter-category? (char->codepoint #\,))
        (ucd-cased-letter-category? (char->codepoint #\]))
        (ucd-cased-letter-category? (char->codepoint #\¥))
        (ucd-cased-letter-category? #x0304)
    ]
}

@defproc[(ucd-mark-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as a mark.
    @examples[
        #:eval example-eval
        (ucd-mark-category? (char->codepoint #\null))
        (ucd-mark-category? (char->codepoint #\space))
        (ucd-mark-category? (char->codepoint #\a))
        (ucd-mark-category? (char->codepoint #\A))
        (ucd-mark-category? (char->codepoint #\ༀ))
        (ucd-mark-category? (char->codepoint #\1))
        (ucd-mark-category? (char->codepoint #\½))
        (ucd-mark-category? (char->codepoint #\,))
        (ucd-mark-category? (char->codepoint #\]))
        (ucd-mark-category? (char->codepoint #\¥))
        (ucd-mark-category? #x0304)
    ]
}

@defproc[(ucd-number-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as a number.
    @examples[
        #:eval example-eval
        (ucd-number-category? (char->codepoint #\null))
        (ucd-number-category? (char->codepoint #\space))
        (ucd-number-category? (char->codepoint #\a))
        (ucd-number-category? (char->codepoint #\A))
        (ucd-number-category? (char->codepoint #\ༀ))
        (ucd-number-category? (char->codepoint #\1))
        (ucd-number-category? (char->codepoint #\½))
        (ucd-number-category? (char->codepoint #\,))
        (ucd-number-category? (char->codepoint #\]))
        (ucd-number-category? (char->codepoint #\¥))
        (ucd-number-category? #x0304)
    ]
}

@defproc[(ucd-punctuation-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as punctuation.
    @examples[
        #:eval example-eval
        (ucd-punctuation-category? (char->codepoint #\null))
        (ucd-punctuation-category? (char->codepoint #\space))
        (ucd-punctuation-category? (char->codepoint #\a))
        (ucd-punctuation-category? (char->codepoint #\A))
        (ucd-punctuation-category? (char->codepoint #\ༀ))
        (ucd-punctuation-category? (char->codepoint #\1))
        (ucd-punctuation-category? (char->codepoint #\½))
        (ucd-punctuation-category? (char->codepoint #\,))
        (ucd-punctuation-category? (char->codepoint #\]))
        (ucd-punctuation-category? (char->codepoint #\¥))
        (ucd-punctuation-category? #x0304)
    ]
}

@defproc[(ucd-symbol-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as a symbol.
    @examples[
        #:eval example-eval
        (ucd-symbol-category? (char->codepoint #\null))
        (ucd-symbol-category? (char->codepoint #\space))
        (ucd-symbol-category? (char->codepoint #\a))
        (ucd-symbol-category? (char->codepoint #\A))
        (ucd-symbol-category? (char->codepoint #\ༀ))
        (ucd-symbol-category? (char->codepoint #\1))
        (ucd-symbol-category? (char->codepoint #\½))
        (ucd-symbol-category? (char->codepoint #\,))
        (ucd-symbol-category? (char->codepoint #\]))
        (ucd-symbol-category? (char->codepoint #\¥))
        (ucd-symbol-category? #x0304)
    ]
}

@defproc[(ucd-separator-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as a separator.
    @examples[
        #:eval example-eval
        (ucd-separator-category? (char->codepoint #\null))
        (ucd-separator-category? (char->codepoint #\space))
        (ucd-separator-category? (char->codepoint #\a))
        (ucd-separator-category? (char->codepoint #\A))
        (ucd-separator-category? (char->codepoint #\ༀ))
        (ucd-separator-category? (char->codepoint #\1))
        (ucd-separator-category? (char->codepoint #\½))
        (ucd-separator-category? (char->codepoint #\,))
        (ucd-separator-category? (char->codepoint #\]))
        (ucd-separator-category? (char->codepoint #\¥))
        (ucd-separator-category? #x0304)
    ]
}

@defproc[(ucd-other-category? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    Returns @racket[#t] if the codepoint's general category denotes it as an @italic{other} value, these are generally
    non-character codepoints.
    @examples[
        #:eval example-eval
        (ucd-other-category? (char->codepoint #\null))
        (ucd-other-category? (char->codepoint #\space))
        (ucd-other-category? (char->codepoint #\a))
        (ucd-other-category? (char->codepoint #\A))
        (ucd-other-category? (char->codepoint #\ༀ))
        (ucd-other-category? (char->codepoint #\1))
        (ucd-other-category? (char->codepoint #\½))
        (ucd-other-category? (char->codepoint #\,))
        (ucd-other-category? (char->codepoint #\]))
        (ucd-other-category? (char->codepoint #\¥))
        (ucd-other-category? #x0304)
    ]
}

@defproc[(ucd-codepoint-type [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    Codepoint general categories can be grouped into one of a set of types, this function returns the type as 
    a symbol derived from it's general category.
    @examples[
        #:eval example-eval
        (ucd-codepoint-type (char->codepoint #\null))
        (ucd-codepoint-type (char->codepoint #\space))
        (ucd-codepoint-type (char->codepoint #\a))
        (ucd-codepoint-type (char->codepoint #\A))
        (ucd-codepoint-type (char->codepoint #\ༀ))
        (ucd-codepoint-type (char->codepoint #\1))
        (ucd-codepoint-type (char->codepoint #\½))
        (ucd-codepoint-type (char->codepoint #\,))
        (ucd-codepoint-type (char->codepoint #\]))
        (ucd-codepoint-type (char->codepoint #\¥))
        (ucd-codepoint-type #x0304)
    ]

    See @racket[*codepoint-types*] for a mapping from this symbol to a description.
}

@defproc[(ucd-canonical-combining-class [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
    @examples[
        #:eval example-eval
        (assoc (ucd-canonical-combining-class (char->codepoint #\space)) *combining-classes*)
        (assoc (ucd-canonical-combining-class (char->codepoint #\a)) *combining-classes*)
        (assoc (ucd-canonical-combining-class #x0304) *combining-classes*)
        (assoc (ucd-canonical-combining-class #x0F72) *combining-classes*)
    ]

    See @racket[*combining-classes*] for a mapping from this symbol to a description.
}

@defproc[(ucd-bidi-class [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
    @examples[
        #:eval example-eval
        (assoc (ucd-bidi-class (char->codepoint #\null)) *bidi-classes*)
        (assoc (ucd-bidi-class (char->codepoint #\space)) *bidi-classes*)
        (assoc (ucd-bidi-class (char->codepoint #\A)) *bidi-classes*)
        (assoc (ucd-bidi-class (char->codepoint #\א)) *bidi-classes*)
        (assoc (ucd-bidi-class (char->codepoint #\ؠ)) *bidi-classes*)
        (assoc (ucd-bidi-class (char->codepoint #\1)) *bidi-classes*)
        (assoc (ucd-bidi-class (char->codepoint #\!)) *bidi-classes*)
    ]

    See @racket[*bidi-classes*] for a mapping from this symbol to a description.
}

@defproc[(ucd-bidi-mirrored? [c codepoint?]) boolean?]{
    ...
    @examples[
        #:eval example-eval
        (ucd-bidi-mirrored? (char->codepoint #\A))
        (ucd-bidi-mirrored? (char->codepoint #\[))
        (ucd-bidi-mirrored? (char->codepoint #\∈))
        (ucd-bidi-mirrored? (char->codepoint #\༼))
        (ucd-bidi-mirrored? (char->codepoint #\!))
    ]
}

@defproc[(ucd-has-mirror-glyph? [c codepoint?]) boolean?]{
    ...
    @examples[
        #:eval example-eval
        (ucd-has-mirror-glyph? (char->codepoint #\[))
        (ucd-has-mirror-glyph? (char->codepoint #\∈))
        (ucd-has-mirror-glyph? (char->codepoint #\༼))
        (ucd-has-mirror-glyph? (char->codepoint #\!))
    ]
}

@defproc[(ucd-mirror-glyph [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    ...
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-mirror-glyph (char->codepoint #\[)))
        (codepoint->char (ucd-mirror-glyph (char->codepoint #\∈)))
        (codepoint->char (ucd-mirror-glyph (char->codepoint #\༼)))
        (ucd-mirror-glyph (char->codepoint #\!))
    ]
}

@defproc[(ucd-bracket? [c codepoint?]) boolean?]{
    Returns @racket[#t] if this codepoint is considered to be a bracket.
    @examples[
        #:eval example-eval
        (ucd-bracket? (char->codepoint #\[))
        (ucd-bracket? (char->codepoint #\)))
        (ucd-bracket? (char->codepoint #\⌈))
        (ucd-bracket? (char->codepoint #\༺))
        (ucd-bracket? (char->codepoint #\⟅))
        (ucd-bracket? (char->codepoint #\«))
        (ucd-bracket? (char->codepoint #\!))
    ]
}

@defproc[(ucd-bracket-type [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    Returns one of @racket[open], @racket[close], or @racket[none] to denote the type of the bracket
    codepoint.
    @examples[
        #:eval example-eval
        (ucd-bracket-type (char->codepoint #\[))
        (ucd-bracket-type (char->codepoint #\)))
        (ucd-bracket-type (char->codepoint #\⌈))
        (ucd-bracket-type (char->codepoint #\༺))
        (ucd-bracket-type (char->codepoint #\⟅))
        (ucd-bracket-type (char->codepoint #\«))
        (ucd-bracket-type (char->codepoint #\!))
    ]
}

@defproc[(ucd-matching-bracket [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    Returns the matching bracket codepoint, for a bracket whose type is @racket[open] it will return the corresponding
    closing bracket codepoint and for a bracket whose type is @racket[close] it will return the corresponding
    opening bracket codepoint.
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-matching-bracket (char->codepoint #\[)))
        (codepoint->char (ucd-matching-bracket (char->codepoint #\))))
        (codepoint->char (ucd-matching-bracket (char->codepoint #\⌈)))
        (codepoint->char (ucd-matching-bracket (char->codepoint #\༺)))
        (codepoint->char (ucd-matching-bracket (char->codepoint #\⟅)))
        (ucd-matching-bracket (char->codepoint #\«))
        (ucd-matching-bracket (char->codepoint #\!))
    ]
}

@defproc[(ucd-decomposition-type [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
}

@defproc[(ucd-decomposition-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) (listof codepoint?)]{
    ...
}

@defproc[(ucd-numeric-type [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    Returns the type of value a codepoint represents, if it is a numeric representation.
    @examples[
        #:eval example-eval
        (ucd-numeric-type (char->codepoint #\3)) 
        (ucd-numeric-type (char->codepoint #\¼))
        (ucd-numeric-type (char->codepoint #\⒍))
        (ucd-numeric-type (char->codepoint #\㊾))
        (ucd-numeric-type (char->codepoint #\₂))
        (ucd-numeric-type (char->codepoint #\ⅳ))
        (ucd-numeric-type (char->codepoint #\六))
        (ucd-numeric-type (char->codepoint #\༣))
        (ucd-numeric-type (char->codepoint #\𐄎))
    ]

    See @racket[*numeric-types*] for a mapping from this symbol to a description.
}

@defproc[(ucd-numeric-value [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) rational?]{
    Returns the actual value a codepoint represents, if it is a numeric representation.
    @examples[
        #:eval example-eval
        (ucd-numeric-value (char->codepoint #\3)) 
        (ucd-numeric-value (char->codepoint #\¼))
        (ucd-numeric-value (char->codepoint #\⒍))
        (ucd-numeric-value (char->codepoint #\㊾))
        (ucd-numeric-value (char->codepoint #\₂))
        (ucd-numeric-value (char->codepoint #\ⅳ))
        (ucd-numeric-value (char->codepoint #\六))
        (ucd-numeric-value (char->codepoint #\༣))
        (ucd-numeric-value (char->codepoint #\𐄎))
    ]
}

@defproc[(ucd-simple-uppercase-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    A simple mapping from a title or lower cased codepoint to it's corresponding upper cased codepoint.
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-simple-uppercase-mapping (char->codepoint #\a)))
        (codepoint->char (ucd-simple-uppercase-mapping (char->codepoint #\α)))
        (codepoint->char (ucd-simple-uppercase-mapping (char->codepoint #\ა)))
        (codepoint->char (ucd-simple-uppercase-mapping (char->codepoint #\uAB70)))
        (codepoint->char (ucd-simple-uppercase-mapping (char->codepoint #\ж)))
        (codepoint->char (ucd-simple-uppercase-mapping (char->codepoint #\ǆ)))
    ]
}

@defproc[(ucd-simple-lowercase-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    A simple mapping from a title or upper cased codepoint to it's corresponding lower cased codepoint.
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-simple-lowercase-mapping (char->codepoint #\A)))
        (codepoint->char (ucd-simple-lowercase-mapping (char->codepoint #\Α)))
        (codepoint->char (ucd-simple-lowercase-mapping (char->codepoint #\u1C90)))
        (codepoint->char (ucd-simple-lowercase-mapping (char->codepoint #\Ꭰ)))
        (codepoint->char (ucd-simple-lowercase-mapping (char->codepoint #\Ж)))
        (codepoint->char (ucd-simple-lowercase-mapping (char->codepoint #\Ǆ)))
    ]
}

@defproc[(ucd-simple-titlecase-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    A simple mapping from a lower or upper cased codepoint to it's corresponding title cased codepoint.
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-simple-titlecase-mapping (char->codepoint #\a)))
        (codepoint->char (ucd-simple-titlecase-mapping (char->codepoint #\α)))
        (codepoint->char (ucd-simple-titlecase-mapping (char->codepoint #\ა)))
        (codepoint->char (ucd-simple-titlecase-mapping (char->codepoint #\ǆ)))
    ]
}

@defproc[(ucd-age [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) string?]{
    Returns a string denoting the version of the Unicode standard the codepoint was introduced.
    @examples[
        #:eval example-eval
        (define groucho-emoji #\🥸)
        (ucd-age (char->codepoint #\null))
        (ucd-age (char->codepoint #\space))
        (ucd-age (char->codepoint #\a))
        (ucd-age (char->codepoint #\A))
        (ucd-age (char->codepoint #\ༀ))
        (ucd-age (char->codepoint #\1))
        (ucd-age (char->codepoint #\½))
        (ucd-age (char->codepoint #\,))
        (ucd-age (char->codepoint #\]))
        (ucd-age (char->codepoint #\¥))
        (ucd-age (char->codepoint #\€))
        (ucd-age (char->codepoint groucho-emoji))
        (ucd-age #x0304)
    ]
}

@defproc[(ucd-block-name [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) string?]{
    Returns the name of the block (codepoint range) containing the codepoint.
    @examples[
        #:eval example-eval
        (ucd-block-name (char->codepoint #\null))
        (ucd-block-name (char->codepoint #\space))
        (ucd-block-name (char->codepoint #\a))
        (ucd-block-name (char->codepoint #\A))
        (ucd-block-name (char->codepoint #\ༀ))
        (ucd-block-name (char->codepoint #\1))
        (ucd-block-name (char->codepoint #\½))
        (ucd-block-name (char->codepoint #\,))
        (ucd-block-name (char->codepoint #\]))
        (ucd-block-name (char->codepoint #\¥))
        (ucd-block-name #x0304)
    ]
}

@defproc[(ucd-scripts [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) (listof symbol?)]{
    ...
    @examples[
        #:eval example-eval
        (ucd-scripts (char->codepoint #\null))
        (ucd-scripts (char->codepoint #\space))
        (ucd-scripts (char->codepoint #\a))
        (ucd-scripts (char->codepoint #\A))
        (ucd-scripts (char->codepoint #\ༀ))
        (ucd-scripts (char->codepoint #\1))
        (ucd-scripts (char->codepoint #\½))
        (ucd-scripts (char->codepoint #\,))
        (ucd-scripts (char->codepoint #\]))
        (ucd-scripts (char->codepoint #\¥))
        (ucd-scripts #x0304)
    ]
}

@defproc[(ucd-script-extensions [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) (listof symbol?)]{
    ...
    @examples[
        #:eval example-eval
        (define (display-scripts cpc)
          (display (format "~a => Script: ~a" cpc (ucd-scripts (char->codepoint cpc))))
          (let ([extensions (ucd-script-extensions (char->codepoint cpc) #f)])
            (if (false? extensions)
                (newline)
                (displayln (format ", extensions: ~a" extensions)))))

        (display-scripts #\𐋡)
        (display-scripts #\჻)
        (display-scripts #\꜀)
        (display-scripts #\a)
    ]
}

@defproc[(ucd-line-break [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    Returns the line break property for this codepoint according to the report 
    @hyperlink["https://www.unicode.org/reports/tr14/"]{UAX #14: Unicode Line Breaking Algorithm}.
    @examples[
        #:eval example-eval
        (assoc (ucd-line-break (char->codepoint #\space)) *line-breaks*)
        (assoc (ucd-line-break (char->codepoint #\-)) *line-breaks*)
        (assoc (ucd-line-break (char->codepoint #\,)) *line-breaks*)
        (assoc (ucd-line-break (char->codepoint #\a)) *line-breaks*)
        (assoc (ucd-line-break (char->codepoint #\Z)) *line-breaks*)
    ]

    See @racket[*line-breaks*] for a mapping from this symbol to a description.
}


@section[]{Module codepoint/enums}
@defmodule[codepoint/enums]

@defthing[*bidi-classes* (listof (cons/c symbol? string?))]{
    A mapping from the abbreviation for a Bidi class to their descriptions taken from 
    @hyperlink["https://www.unicode.org/reports/tr44/#Bidi_Class_Values"]{UAX #44; Bidirectional Class Values}.
}

@defthing[*case-folding-status* (listof (cons/c symbol? string?))]{
    ...
}

@defthing[*codepoint-types* (listof (cons/c symbol? string?))]{
    A mapping from codepoint type symbols to their descriptions taken from 
    @hyperlink["https://www.unicode.org/versions/Unicode14.0.0/ch02.pdf"]{Chapter 2}, Table 2-3 Types of Code Points.
}

@defthing[*combining-classes* (listof (cons/c symbol? string?))]{
    A mapping from canonical combining class symbols to their descriptions taken from 
    @hyperlink["https://www.unicode.org/reports/tr44/#CCC_Values_Table"]{UAX #44; Table 15. Canonical_Combining_Class Values}
}

@defthing[*decomposition-compatibility-tags* (listof (cons/c symbol? string?))]{
    A mapping from decomposition compatibility formatting tag symbols to their descriptions taken from 
    @hyperlink["https://www.unicode.org/reports/tr44/#Formatting_Tags_Table"]{UAX #44; Table 14. Compatibility Formatting Tags}
}

@defthing[*general-categories* (listof (cons/c symbol? string?))]{
    A mapping from general category abbreviation symbols to their descriptions taken from 
    @hyperlink["https://www.unicode.org/reports/tr44/#General_Category_Values"]{UAX #44; General_Category_Values}
}

@defthing[*line-breaks* (listof (cons/c symbol? string?))]{
    A mapping from line break symbols to their descriptions taken from 
    @hyperlink["https://www.unicode.org/reports/tr14/#Table1"]{UAX #14; Table 1. Line Breaking Classes}
}

@defthing[*name-alias-types* (listof (cons/c symbol? string?))]{
    A mapping from name alias type symbols to their descriptions. These descriptions were taken from the source
    UCD file; they are further described in @hyperlink["https://en.wikipedia.org/wiki/Unicode_alias_names_and_abbreviations"]{this article}.
}

@defthing[*numeric-types* (listof (cons/c symbol? string?))]{
    A mapping from numeric type symbols to their descriptions taken from 
    @hyperlink["https://www.unicode.org/reports/tr44/#Numeric_Type"]{UAX #44; Numeric_Type}
}