#lang scribble/manual

@(require 
  racket/sandbox
  scribble/core
  scribble/eval
  (for-label 
    racket/base
    racket/contract
    codepoint
    codepoint/enums
    codepoint/fold))

@title{Case Folding}

Implementation of case-folding based on UCD properties.

@section[]{Module codepoint/fold}
@defmodule[codepoint/fold]


@defproc[(ucd-case-folding [c codepoint?]) (hash/c symbol? (listof codepoint?))]{
  Return the dictionary of case foldings for the source codepoint. The key to this
  hash is one of the symbols from @racket[*case-folding-status*], and the value is
  a list of new codepoints.

  See @racket[*case-folding-status*].
}


@defproc[(case-fold-common [c codepoint?]) (listof codepoint?)]{
  Applies the folding associated with the status @racket['common].
}


@defproc[(case-fold-simple [c codepoint?]) (listof codepoint?)]{
  Applies the folding associated with the status @racket['common], followed by the
  folding associated with the status @racket['simple].
}


@defproc[(case-fold-full [c codepoint?]) (listof codepoint?)]{
  Applies the folding associated with the status @racket['common], followed by the
  folding associated with the status @racket['full].
}
