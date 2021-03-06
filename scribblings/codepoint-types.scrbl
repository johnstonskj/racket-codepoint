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

A codepoint value is simply a @racket[exact-nonnegative-integer?] in the inclusive range zero to @racket[*max-codepoint-value*].
Note that not all codepoints correspond to characters (see @racket[codepoint-non-character?], @racket[codepoint-utf16-surrogate?], 
and @racket[codepoint-private-use?]).

@section[]{Module codepoint}
@defmodule[codepoint]

@defthing[*max-codepoint-value* codepoint?]{
    The currently defined maximum value for a codepoint.
}

@defproc[(codepoint? [v any/c?]) boolean?]{
    Returns @racket[#t] if the provided value is a valid codepoint; it is a @racket[exact-nonnegative-integer?] in the 
    inclusive range zero to @racket[*max-codepoint-value*].
}

@defproc[(codepoint-non-character? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is one of the Unicode @italic{non-character} values.
}

@defproc[(codepoint-utf16-surrogate? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is one of the reserved Unicode @italic{UTF-16 surrogate} values.
}

@defproc[(codepoint-private-use? [c codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint is one of the reserved Unicode @italic{private use} values.
}

@defproc[(codepoint-plane [c codepoint?]) exact-nonnegative-integer?]{
    Returns the integer (0..16) that represents the plane within the Unicode codepoint set that contains the
    provided codepoint. Planes are described in the standard, 
    @hyperlink["https://www.unicode.org/versions/Unicode14.0.0/ch02.pdf"]{chapter 2}, section 2.8 Unicode Allocation.
    @examples[
        #:eval example-eval
        (codepoint-plane (char->codepoint #\§))
        (codepoint-plane (char->codepoint #\😀))
    ]
}

@defproc[(codepoint-plane-name [c codepoint?]) (or/c symbol? #f)]{
    Returns the name of the plane within the Unicode codepoint set that contains the
    provided codepoint. If the plane is not named by the standard the response is @racket[#f].
    @examples[
        #:eval example-eval
        (codepoint-plane-name (char->codepoint #\§))
        (codepoint-plane-name (char->codepoint #\😀))
    ]
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
    Return a string that formats the codepoint in the manner used in the Unicode specification.
    @examples[
        #:eval example-eval
        (codepoint->unicode-string (char->codepoint #\§))
    ]
}

@defproc[(string->codepoint [str string?]) codepoint?]{
    Convert a string to a codepoint, accepting any Racket integer format, a C-style format, or the
    Unicode format.
    @examples[
        #:eval example-eval
        (string->codepoint "0304")
        (string->codepoint "#x0304")
        (string->codepoint "0x0304")
        (string->codepoint "U+0304")
    ]
}

@defproc[(assert-codepoint! [v any/c?] [name symbol? 'v]) void?]{
    Raises an argument error if the provided value is not a valid codepoint. The optional parameter
    @racket[name] is used to override the name of the value @racket[v] reported in the error.
    See @racket[raise-argument-error].
}

@section[]{Module codepoint/range}
@defmodule[codepoint/range]

Many of the properties defined by the Unicode standard are assigned to a range of codepoints
and the @racket[codepoint-range] structure is a typed pair of @code{start} and @code{end} codepoint values.

@defstruct[
    codepoint-range (
        [start codepoint?]
        [end codepoint?]
    )
    #:prefab
    #:constructor-name make-codepoint-range
]{
    This structure represents an inclusive range @code{start..end}. It ensures that both @code{start} and @code{end} values 
    are codepoints, @code{start} ≤ @code{end}, and can be used to test codepoint inclusion as well as the basis for iteration.
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
    Create a new range from a pair of codepoint values where the @racket[car] is the start and
    the @racket[cdr] is the end.
    @examples[
        #:eval example-eval
        (pair->codepoint-range '(0 . 127))
    ]
}

@defproc[(codepoint->codepoint-range [c codepoint?]) codepoint-range?]{
    Create a new range from a single codepoint value used as both start and end.
    @examples[
        #:eval example-eval
        (codepoint->codepoint-range 0)
    ]
}

@defproc[(codepoint-range-length [cpr codepoint-range?]) exact-nonnegative-integer?]{
    Returns the number of codepoints within the range.
    @examples[
        #:eval example-eval
        (codepoint-range-length (make-codepoint-range 0 127))
    ]
}

@defproc[(codepoint-range=? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    Returns @racket[#t] if the codepoint-range @racket[lhs] is equal to the codepoint-range @racket[rhs].
}

@defproc[(codepoint-range<? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    Returns @racket[#t] if the codepoint-range @racket[lhs] is less than, and not overlapping, 
    the codepoint-range @racket[rhs].
}

@defproc[(codepoint-range>? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    Returns @racket[#t] if the codepoint-range @racket[lhs] is greater than, and not overlapping, 
    the codepoint-range @racket[rhs].
}

@defproc[(codepoint-range-contains? [cpr codepoint-range?] [cp codepoint?]) boolean?]{
    Returns @racket[#t] if the codepoint @racket[cp] is contained within the codepoint-range @racket[cpr].
}

@defproc[(codepoint-range-contains-any? [cpr codepoint-range?] [cp codepoint?] ...) boolean?]{
    Returns @racket[#t] if @italic{any of} the codepoint values in the list @racket[cp] is contained 
    within the codepoint-range @racket[cpr].
}

@defproc[(codepoint-range-contains-all? [cpr codepoint-range?] [cp codepoint?] ...) boolean?]{
    Returns @racket[#t] if @italic{all of} the codepoint values in the list @racket[cp] is contained 
    within the codepoint-range @racket[cpr].
}

@defproc[(codepoint-range-intersects? [lhs codepoint-range?] [rhs codepoint-range?]) boolean?]{
    Returns @racket[#t] if the codepoint-range @racket[lhs] overlaps in any way with 
    the codepoint-range @racket[rhs].
}

@defproc[(codepoint-range-any-intersects? [cpr-list (listof codepoint-range?)]) boolean?]{
    Returns @racket[#t] if any codepoint-range within the list @racket[cpr-list] overlaps in any way with 
    ay other.
}

@defproc[(codepoint-range->inclusive-range [cpr codepoint-range?]) range?]{
    Similar to @racket[codepoint-range->in-inclusive-range], but returns lists.
}

@defproc[(codepoint-range->in-inclusive-range [cpr codepoint-range?]) range?]{
    Returns a sequence (that is also a stream) whose elements are codepoints from start to end.
    @examples[
        #:eval example-eval
        (define ascii-lowercase-letters 
          (make-codepoint-range
            (char->codepoint #\a)
            (char->codepoint #\z)))
        (for ([letter (codepoint-range->in-inclusive-range ascii-lowercase-letters)])
          (display (codepoint->char letter)))
    ]
}

@defproc[(codepoint-range->unicode-string [cpr codepoint-range?]) string?]{
    Return a string that formats the range in the manner used in the Unicode specification.
    @examples[
        #:eval example-eval
        (define ascii-lowercase-letters 
          (make-codepoint-range
            (char->codepoint #\a)
            (char->codepoint #\z)))
        (display (codepoint-range->unicode-string ascii-lowercase-letters))
    ]
}


@section[]{Module codepoint/range-dict}
@defmodule[codepoint/range-dict]

As some of the Unicode character property files maintain common properties for codepoint ranges they take up
less space both as data in the package and in-memory at runtime. However, these cannot be directly indexed
by codepoint to find a property value. The @racket[range-dict] structure provides basic @racket[dict?] functions
taking a codepoint as key but performs a search through the ranges to find a match.

@defproc[(range-dict? [v any/c]) boolean?]{
    Returns @racket[#t] if the provided value is a valid codepoint range-dict.
}

@defproc[(make-range-dict [data (listof (cons/c codepoint-range? hash?))]) range-dict?]{
    Construct a new range-dict from an list of pairs where each pair is a mapping from @racket[codepoint-range] 
    to a property hash.

    @examples[
        #:eval example-eval
        (make-range-dict
          (list
            (cons 
              (make-codepoint-range #x0000  #x007F)
              (make-hash '((block-name "Basic Latin"))))
            (cons 
              (make-codepoint-range #x0080 #x00FF)
              (make-hash '((block-name "Latin-1 Supplement"))))
            (cons 
              (make-codepoint-range #x0100 #x017F)
              (make-hash '((block-name "Latin Extended-A"))))
            (cons 
              (make-codepoint-range #x0180 #x024F)
              (make-hash '((block-name "Latin Extended-B")))))) 
    ]
}

@defproc[(range-dict-count [dict range-dict?]) exact-nonnegative-integer?]{
    Returns the number of keys mapped by @racket[range-dict].
}

@defproc[(range-dict-has-key? [dict range-dict?] [key codepoint-range?]) boolean?]{
    Returns #t if @racket[dict] contains a value for the given @racket[key], #f otherwise.

}

@defproc[(range-dict-ref [dict range-dict?] [key codepoint?] [failure-result (lambda () (raise-arguments-error ...))]) hash?]{
    Returns the value for key in @racket[dict]. If no value is found for @racket[key], then 
    @racket[failure-result] determines the result:

    @itemlist[
        @item{If @racket[failure-result] is a procedure, it is called (through a tail call) with no arguments to produce the result.}
        @item{Otherwise, @racket[failure-result] is returned as the result.}
    ]
}


