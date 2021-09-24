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
            '(require codepoint
                      codepoint/properties
                      codepoint/enums)))

@title{UCD Properties}

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


@section[]{Module codepoint/properties}
@defmodule[codepoint/properties]

@defthing[*corresponding-unicode-version* string?]{ 
    ...
    @examples[
        #:eval example-eval
        (format 
          "Generated from UCD data, version ~a" 
          *corresponding-unicode-version*)
    ]
}

@defproc[(ucd-ascii? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is in the ASCII range.
}

@defproc[(ucd-latin-1? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is in the Latin-1 range.
}

@defproc[(ucd-name [c codepoint?]) string?]{
    Returns the name of this codepoint.
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
    ...
}

@defproc[(ucd-general-category [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
    @examples[
        #:eval example-eval
        (for ([char (list #\a #\A #\] #\space #\§ (codepoint->char #x0F00))])
          (displayln 
            (format "~a  =>  ~a"
              char
              (cdr 
                (assoc 
                  (ucd-general-category (char->codepoint char)) 
                  *general-categories*)))))
    ]

    See @racket[*general-categories*].
}

@defproc[(ucd-canonical-combining-class [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
}

@defproc[(ucd-bidi-class [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...

    See @racket[*bidi-classes*].
}

@defproc[(ucd-bidi-mirrored? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    ...
}

@defproc[(ucd-bracket? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    ...
    @examples[
        #:eval example-eval
        (ucd-bracket? (char->codepoint #\[))
        (ucd-bracket? (char->codepoint #\!))
    ]
}

@defproc[(ucd-bracket-type [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
    @examples[
        #:eval example-eval
        (ucd-bracket-type (char->codepoint #\[))
        (ucd-bracket-type (char->codepoint #\]))
    ]
}

@defproc[(ucd-has-mirror-glyph? [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) boolean?]{
    @examples[
        #:eval example-eval
        (ucd-has-mirror-glyph? (char->codepoint #\[))
        (ucd-has-mirror-glyph? (char->codepoint #\!))
    ]
}

@defproc[(ucd-matching-bracket [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    ...
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-matching-bracket (char->codepoint #\[)))
    ]
}

@defproc[(ucd-mirror-glyph [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    ...
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-mirror-glyph (char->codepoint #\[)))
    ]
}

@defproc[(ucd-decomposition-type [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
}

@defproc[(ucd-decomposition-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) (listof codepoint?)]{
    ...
}

@defproc[(ucd-numeric-type [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...
    @examples[
        #:eval example-eval
        (ucd-numeric-type (char->codepoint #\3)) 
        (ucd-numeric-type #x00BC) 
    ]
}

@defproc[(ucd-numeric-value [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) rational?]{
    ...
    @examples[
        #:eval example-eval
        (ucd-numeric-value (char->codepoint #\3)) 
        (ucd-numeric-value #x00BC) 
    ]
}

@defproc[(ucd-simple-uppercase-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    ...
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-simple-uppercase-mapping (char->codepoint #\a)))
    ]
}

@defproc[(ucd-simple-lowercase-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    ...
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-simple-lowercase-mapping (char->codepoint #\A)))
    ]
}

@defproc[(ucd-simple-titlecase-mapping [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) codepoint?]{
    ...
    @examples[
        #:eval example-eval
        (codepoint->char (ucd-simple-titlecase-mapping (char->codepoint #\a)))
    ]
}

@defproc[(ucd-age [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) string?]{
    ...
}

@defproc[(ucd-block-name [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) string?]{
    ...
}

@defproc[(ucd-scripts [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) (listof symbol?)]{
    ...
}

@defproc[(ucd-script-extensions [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) (listof symbol?)]{
    ...
}

@defproc[(ucd-line-break [c codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) symbol?]{
    ...

    See @racket[*line-breaks*].
}


@section[]{Module codepoint/enums}
@defmodule[codepoint/enums]

@defthing[*bidi-classes* (listof (cons/c symbol? string?))]{
    A mapping from the abbreviation for a Bidi class to it's description in @hyperlink["https://www.unicode.org/reports/tr44/#Bidi_Class_Values"]{UAX #44; Bidirectional Class Values}.
}

@defthing[*case-folding-status* (listof (cons/c symbol? string?))]{
    ...
}

@defthing[*decomposition-compatibility-tags* (listof (cons/c symbol? string?))]{
    ...
    @hyperlink["https://www.unicode.org/reports/tr44/#Formatting_Tags_Table"]{UAX #44; Table 14. Compatibility Formatting Tags}
}

@defthing[*general-categories* (listof (cons/c symbol? string?))]{
    ...
    @hyperlink["https://www.unicode.org/reports/tr44/#General_Category_Values"]{UAX #44; General_Category_Values}
}

@defthing[*line-breaks* (listof (cons/c symbol? string?))]{
    ...
    @hyperlink["https://www.unicode.org/reports/tr14/#Table1"]{UAX #14; Table 1. Line Breaking Classes}
}

@defthing[*name-alias-types* (listof (cons/c symbol? string?))]{
    ...
}

@defthing[*numeric-types* (listof (cons/c symbol? string?))]{
    ...
    @hyperlink["https://www.unicode.org/reports/tr44/#Numeric_Type"]{UAX #44; Numeric_Type}
}