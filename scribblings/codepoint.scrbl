#lang scribble/manual

@(require 
  racket/sandbox
  scribble/core
  scribble/eval
  (for-label 
    racket/base
    racket/contract
    codepoint
    codepoint/range
    codepoint/range-dict))

@(define example-eval 
         (make-base-eval
            '(require codepoint
                      codepoint/range
                      codepoint/range-dict)))

@title{Codepoint types}

@section[]{Module codepoint}
@defmodule[codepoint]

@defthing[*max-codepoint-value* codepoint?]{
    The currently defined maximum value for a codepoint.
}

@defproc[(codepoint? [v any/c?]) boolean?]{
    Returns @racket[#t] if the provided value is a valid codepoint.
}

@defproc[(codepoint-non-character?? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is one of the Unicode @italic{non-character} values.
}

@defproc[(codepoint-utf16-surrogate? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is one of the reserved Unicode @italic{UTF-16 surrogate} values.
}

@defproc[(codepoint-private-use? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is one of the reserved Unicode @italic{private use} values.
}

@defproc[(codepoint->char [c codepoint?]) char?]{
    Return the character corresponding to the provided codepoint, @italic{if} the codepoint is valid,
    and is not a non-character, UTF-16 surrogate, or private-use value.
    @examples[
        #:eval example-eval
        (codepoint->char #x00A7)
    ]
}

@defproc[(char->codepoint [v char?]) boolean?]{
    Return the codepoint for the provided character.
    @examples[
        #:eval example-eval
        (format "~x" (char->codepoint #\§))
    ]
}

@defproc[(codepoint->unicode-string [c codepoint?]) string?]{
    Return a string that formats the codepoint in the format used in the Unicode specification.
    @examples[
        #:eval example-eval
        (codepoint->unicode-string (char->codepoint #\§))
    ]
}

@defproc[(assert-codepoint! [v any/c?] [name symbol? 'v]) void?]{
    Raises an argument error if the provided value is not a valid codepoint. The optional parameter
    @racket[name] is used to override the name of the value @racket[v] reported in the error.
    See @racket[raise-argument-error].
}

@section[]{Module codepoint/range}
@defmodule[codepoint/range]

@defstruct[
    codepoint-range (
        [start codepoint?]
        [end codepoint?]
    )
    #:prefab
    #:constructor-name make-codepoint-range
]{
    ...
    @examples[
        #:eval example-eval
        (define ascii (make-codepoint-range 0 127))
        (codepoint-range-start ascii)
        (codepoint-range-end ascii)
        (codepoint-range-contains? ascii (char->codepoint #\a))
        (codepoint-range-contains? ascii (char->codepoint #\§))
    ]
}

@defproc[(assert-codepoint-range! [v any/c?] [name symbol? 'v]) void?]{
    Raises an argument error if the provided value is not a valid codepoint-range. The optional parameter
    @racket[name] is used to override the name of the value @racket[v] reported in the error.
    See @racket[raise-argument-error].
}

@defproc[(pair->codepoint-range [p (cons/c codepoint? codepoint?)]) codepoint-range?]{
    ...
}

@defproc[(codepoint->codepoint-range [c codepoint?]) codepoint-range?]{
    ...
}

@defproc[(codepoint-range-length [cpr codepoint-range?]) exact-nonnegative-integer?]{
    ...
}

@defproc[(codepoint-range=? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    ...
}

@defproc[(codepoint-range<? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    ...
}

@defproc[(codepoint-range>? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    ...
}

@defproc[(codepoint-range-contains? [cpr codepoint-range?]) boolean?]{
    ...
}

@defproc[(codepoint-range-contains-any? [cpr codepoint-range?] [cp codepoint?] ...) boolean?]{
    ...
}

@defproc[(codepoint-range-contains-all? [cpr codepoint-range?] [cp codepoint?] ...) boolean?]{
    ...
}

@defproc[(codepoint-range-intersects? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    ...
}

@defproc[(codepoint-range-any-intersects? [cpr-list (listof codepoint-range?)]) boolean?]{
    ...
}

@defproc[(codepoint->inclusive-range [cpr codepoint-range?]) range?]{
    ...
}

@defproc[(codepoint->in-inclusive-range [cpr codepoint-range?]) range?]{
    ...
}

@defproc[(codepoint-range->unicode-string [cpr codepoint-range?]) string?]{
    ...
}


@section[]{Module codepoint/range-dict}
@defmodule[codepoint/range-dict]

@defproc[(range-dict? [v any/c]) boolean?]{
    ...
}

@defproc[(make-range-dict? [data (listof (cons/c codepoint-range? hash?))]) range-dict?]{
    ...
}

@defproc[(range-dict-length [d range-dict?]) exact-nonnegative-integer?]{
    ...
}

@defproc[(range-dict-has-key? [d range-dict?] [key codepoint-range?]) boolean?]{
    ...
}

@defproc[(range-dict-ref [d range-dict?] [key codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) hash?]{
    ...
}


