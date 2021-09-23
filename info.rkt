#lang info

(define collection "codepoint")
(define pkg-desc "Unicode Codepoint Data")
(define version "0.1")
(define pkg-authors '(johnstonskj))

(define deps '("base"))

(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))

(define scribblings '(("scribblings/codepoint.scrbl" ())))

(define compile-omit-paths '("data" "generated"))
(define test-omit-paths '("generated" "private" "scribblings"))

(define racket-launcher-names (list "ucd-generate"))
(define racket-launcher-libraries (list "private/generator.rkt"))