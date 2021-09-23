#lang racket/base

(require 
  racket/bool
  racket/list
  racket/promise
  codepoint
  codepoint/range-dict)

(require 
  "./private/generator.rkt")

(provide
  ucd-ascii?
  ucd-latin-1?
  ucd-name
  ucd-name-aliases
  ucd-general-category
  ucd-canonical-combining-class
  ucd-bidi-class
  ucd-bidi-mirrored?
  ucd-bracket?
  ucd-bracket-type
  ucd-has-mirror-glyph?
  ucd-matching-bracket
  ucd-mirror-glyph
  ucd-decomposition-type
  ucd-decomposition-mapping
  ucd-numeric-type
  ucd-numeric-value
  ucd-simple-uppercase-mapping
  ucd-simple-lowercase-mapping
  ucd-simple-titlecase-mapping
  ucd-age
  ucd-block-name
  ucd-scripts
  ucd-script-extensions
  ucd-line-break)

;; ---------- Implementation - codepoint functions

(define (ucd-ascii? cp)
  (and (codepoint? cp) (<= cp 127)))

(define (ucd-latin-1? cp)
  (and (codepoint? cp) (<= cp 255)))

;; ---------- Implementation - codepoint name

(define *ucd-name*
  (load-generated-module (current-directory) "name"))

(define (ucd-name codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (force *ucd-name*) codepoint))

;; ---------- Implementation - codepoint name-aliases

(define *ucd-name-aliases*
  (load-generated-module (current-directory) "name-aliases"))

(define (ucd-name-aliases codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (force *ucd-name-aliases*) codepoint))

;; ---------- Implementation - codepoint general-category

(define *ucd-general-category*
  (load-generated-module (current-directory) "general-category"))

(define (ucd-general-category codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (force *ucd-general-category*) codepoint))

;; ---------- Implementation - codepoint combining-class

(define *ucd-combining-class*
  (load-generated-module (current-directory) "combining-class"))

(define (ucd-canonical-combining-class codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (force *ucd-combining-class*) codepoint))

;; ---------- Implementation - codepoint bidi*

(define *ucd-bidi*
  (load-generated-module (current-directory) "bidi"))

(define (ucd-bidi-class codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-bidi*) codepoint) 'class))

(define (ucd-bidi-mirrored? codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-bidi*) codepoint) 'mirrored))

(define *ucd-bidi-brackets*
  (load-generated-module (current-directory) "bidi-brackets"))

(define (ucd-bracket? codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-has-key? (force *ucd-bidi-brackets*) codepoint))

(define (ucd-bracket-type codepoint)
  (if (ucd-bracket? codepoint)
      (hash-ref 
        (hash-ref (force *ucd-bidi-brackets*) codepoint) 
        'type)
      #f))

(define (ucd-matching-bracket codepoint)
  (if (ucd-bracket? codepoint)
      (hash-ref 
        (hash-ref (force *ucd-bidi-brackets*) codepoint) 
        'matching)
      #f))

(define *ucd-bidi-mirroring*
  (load-generated-module (current-directory) "bidi-mirroring"))

(define (ucd-has-mirror-glyph? codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-has-key? (force *ucd-bidi-mirroring*) codepoint))

(define (ucd-mirror-glyph codepoint)
  (if (ucd-has-mirror-glyph? codepoint)
      (hash-ref (force *ucd-bidi-mirroring*) codepoint)
      #f))

;; ---------- Implementation - codepoint decomposition*

(define *ucd-decomposition*
  (load-generated-module (current-directory) "decomposition"))

(define (ucd-decomposition-type codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-decomposition*) codepoint) 'type))

(define (ucd-decomposition-mapping codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-decomposition*) codepoint) 'mapping))

;; ---------- Implementation - codepoint numerics*

(define *ucd-numerics*
  (load-generated-module (current-directory) "numerics"))

(define (ucd-numeric-type codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-numerics*) codepoint) 'type))

(define (ucd-numeric-value codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-numerics*) codepoint) 'value))

;; ---------- Implementation - codepoint simple-*-mappings

(define *ucd-simple-mapping*
  (load-generated-module (current-directory) "simple-mapping"))

(define (ucd-simple-uppercase-mapping codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-simple-mapping*) codepoint) 'uppercase))

(define (ucd-simple-lowercase-mapping codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-simple-mapping*) codepoint) 'lowercase))

(define (ucd-simple-titlecase-mapping codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref (hash-ref (force *ucd-simple-mapping*) codepoint) 'titlecase))

;; ---------- Implementation - codepoint age

(define *ucd-derived-age*
  (load-generated-module (current-directory) "derived-age"))

(define (ucd-age codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (range-dict-ref (force *ucd-derived-age*) codepoint))

;; ---------- Implementation - codepoint block-name

(define *ucd-block-names*
  (load-generated-module (current-directory) "block-names"))

(define (ucd-block-name codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (range-dict-ref (force *ucd-block-names*) codepoint))

;; ---------- Implementation - codepoint scripts

(define *ucd-scripts*
  (load-generated-module (current-directory) "scripts"))

(define (ucd-scripts codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (range-dict-ref (force *ucd-scripts*) codepoint))

;; ---------- Implementation - codepoint script-extensions

(define *ucd-script-extensions*
  (load-generated-module (current-directory) "script-extensions"))

(define (ucd-script-extensions codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (range-dict-ref (force *ucd-script-extensions*) codepoint))

;; ---------- Implementation - codepoint line-break

(define *ucd-line-break*
  (load-generated-module (current-directory) "line-break"))

(define (ucd-line-break codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (range-dict-ref (force *ucd-line-break*) codepoint))
