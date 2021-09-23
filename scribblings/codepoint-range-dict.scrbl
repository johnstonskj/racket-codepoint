#lang scribble/manual

@(require 
  racket/sandbox
  scribble/core
  scribble/eval
  (for-label 
    racket/base
    racket/contract
    codepoint))

@section[]{Module codepoint/range-dict}
@defmodule[codepoint/range-dict]

Functions on the type @code{codepoint?}.
