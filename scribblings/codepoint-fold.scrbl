#lang scribble/manual

@(require 
  racket/sandbox
  scribble/core
  scribble/eval
  (for-label 
    racket/base
    racket/contract
    codepoint))

@section[]{Module codepoint/fold}
@defmodule[codepoint/fold]

Functions on the type @code{codepoint?}.
