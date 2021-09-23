#lang scribble/manual

@(require 
  racket/sandbox
  scribble/core
  scribble/eval
  (for-label 
    racket/base
    racket/contract
    codepoint))

@section[]{Module codepoint/properties}
@defmodule[codepoint/properties]

Functions on the type @code{codepoint?}.
