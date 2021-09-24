#lang scribble/manual

@(require 
	racket/file
  racket/sandbox
  scribble/core
  scribble/eval
  (for-label 
    racket/base
    racket/contract
    codepoint
    codepoint/enums
    codepoint/properties))

@(define example-eval 
         (make-base-eval
            '(require codepoint codepoint/enums codepoint/properties)))

@title[#:version "0.1"]{Package codepoint}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

This package provides types that describe individual Unicode @hyperlink["https://unicode.org/glossary/#code_point"]{codepoints},
codepoint ranges, and @hyperlink["https://unicode.org/glossary/#character_properties"]{character properties}. The following 
example demonstrates the query of certain character properties that explain the behavior of combining the letter @racket[#\a]
with the character @code{U+0304}.

@examples[
    #:eval example-eval
    (codepoint? #x0304)
    (ucd-name #x0304)
    (ucd-general-category #x0304)
    (cdr (assoc (ucd-general-category #x0304) *general-categories*))
    (ucd-canonical-combining-class #x0304)
    (cdr (assoc (ucd-canonical-combining-class #x0304) *combining-classes*))
    (string #\a (codepoint->char #x0304))
]

The functions in @racket[codepoint/properties] return the values extracted from the Unicode Character Database, and the only 
conversion is typically string to number or string to symbol. Descriptions of the values that are returned are gathered in 
@racket[codepoint/enums] for display purposes.

@include-section["codepoint.scrbl"]

@include-section["codepoint-properties.scrbl"]

@include-section["codepoint-fold.scrbl"]

@include-section["generator.scrbl"]

@section{License}

@verbatim|{|@file->string["LICENSE"]}|
