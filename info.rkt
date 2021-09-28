#lang info
;;
;; Collection codepoint.
;;   Library for operations on Unicode codepoints, and UCD properties
;;
;; Copyright (c) 2021 Simon Johnston (johnstonskj@gmail.com).
;;
(define collection "codepoint")
(define pkg-desc "Library for operations on Unicode codepoints, and UCD properties")
(define version "0.2")
(define pkg-authors '(johnstonskj))

(define deps '("base" "srfi-lite-lib"))

(define build-deps '("scribble-lib" "racket-doc" "sandbox-lib" "rackunit-lib"))

(define scribblings '(("scribblings/codepoint.scrbl" (multi-page))))

(define compile-omit-paths '("data" "generated"))
(define test-omit-paths '("generated" "private" "scribblings"))

(define racket-launcher-names (list "ucd-generate"))
(define racket-launcher-libraries (list "private/generator.rkt"))