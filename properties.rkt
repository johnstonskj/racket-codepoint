#lang racket/base

(require 
  racket/bool
  racket/list
  racket/promise
  racket/string
  codepoint
  codepoint/range-dict)

(require 
  "./private/generator.rkt")

(provide
  *corresponding-unicode-version*
  ucd-ascii?
  ucd-latin-1?
  ucd-name
  ucd-name->symbol
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

(define *corresponding-unicode-version* "14.0.0")

;; ---------- Implementation - codepoint functions

(define (ucd-ascii? codepoint)
  (assert-codepoint! codepoint)
  (<= codepoint 127))

(define (ucd-latin-1? codepoint)
  (assert-codepoint! codepoint)
  (<= codepoint 255))

;; ---------- Implementation - codepoint name

(define *ucd-name*
  (load-generated-module (current-directory) "name"))

(define (ucd-name codepoint [failure-result (lambda () (codepoint-not-found codepoint 'name))])
  (assert-codepoint! codepoint)
  (hash-ref (force *ucd-name*) codepoint failure-result))

(define (ucd-name->symbol codepoint [failure-result (lambda () (codepoint-not-found codepoint 'name))])
  (assert-codepoint! codepoint)
  (let ([initial (ucd-name codepoint)])
    (string->symbol
      (if (string=? initial "<control>")
          (format "control/~x" codepoint)
          (foldl
            (lambda (repl str) (string-replace str (car repl) (cdr repl)))
            (string-downcase initial)
            '((", " . "/") ("-" . "/") ("<" . "") (">" . "") (" " . "-")))))))

;; ---------- Implementation - codepoint name-aliases

(define *ucd-name-aliases*
  (load-generated-module (current-directory) "name-aliases"))

(define (ucd-name-aliases codepoint [failure-result (lambda () (codepoint-not-found codepoint 'name-aliases))])
  (assert-codepoint! codepoint)
  (hash-ref (force *ucd-name-aliases*) codepoint failure-result))

;; ---------- Implementation - codepoint general-category

(define *ucd-general-category*
  (load-generated-module (current-directory) "general-category"))

(define (ucd-general-category codepoint [failure-result (lambda () (codepoint-not-found codepoint 'general-category))])
  (assert-codepoint! codepoint)
  (hash-ref (force *ucd-general-category*) codepoint failure-result))

;; ---------- Implementation - codepoint combining-class

(define *ucd-combining-class*
  (load-generated-module (current-directory) "combining-class"))

(define (ucd-canonical-combining-class codepoint [failure-result (lambda () (codepoint-not-found codepoint 'canonical-combining-class))])
  (assert-codepoint! codepoint)
  (hash-ref (force *ucd-combining-class*) codepoint failure-result))

;; ---------- Implementation - codepoint bidi*

(define *ucd-bidi*
  (load-generated-module (current-directory) "bidi"))

(define (ucd-bidi-class codepoint [failure-result (lambda () (codepoint-not-found codepoint 'bidi-class))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-bidi*) codepoint failure-result) 'class failure-result))

(define (ucd-bidi-mirrored? codepoint [failure-result (lambda () (codepoint-not-found codepoint 'bidi-mirrored?))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-bidi*) codepoint failure-result) 'mirrored failure-result))

(define *ucd-bidi-brackets*
  (load-generated-module (current-directory) "bidi-brackets"))

(define (ucd-bracket? codepoint)
  (assert-codepoint! codepoint)
  (hash-has-key? (force *ucd-bidi-brackets*) codepoint))

(define (ucd-bracket-type codepoint [failure-result (lambda () (codepoint-not-found codepoint 'bracket-type))])
  (if (ucd-bracket? codepoint)
      (hash-ref 
        (hash-ref (force *ucd-bidi-brackets*) codepoint failure-result) 
        'type)
      #f))

(define (ucd-matching-bracket codepoint [failure-result (lambda () (codepoint-not-found codepoint 'matching-bracket))])
  (if (ucd-bracket? codepoint)
      (hash-ref 
        (hash-ref (force *ucd-bidi-brackets*) codepoint failure-result) 
        'matching)
      #f))

(define *ucd-bidi-mirroring*
  (load-generated-module (current-directory) "bidi-mirroring"))

(define (ucd-has-mirror-glyph? codepoint)
  (assert-codepoint! codepoint)
  (hash-has-key? (force *ucd-bidi-mirroring*) codepoint))

(define (ucd-mirror-glyph codepoint [failure-result (lambda () (codepoint-not-found codepoint 'matching-bracket))])
  (if (ucd-has-mirror-glyph? codepoint)
      (hash-ref (force *ucd-bidi-mirroring*) codepoint failure-result)
      #f))

;; ---------- Implementation - codepoint decomposition*

(define *ucd-decomposition*
  (load-generated-module (current-directory) "decomposition"))

(define (ucd-decomposition-type codepoint [failure-result (lambda () (codepoint-not-found codepoint 'decomposition-type))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-decomposition*) codepoint failure-result) 'type failure-result))

(define (ucd-decomposition-mapping codepoint [failure-result (lambda () (codepoint-not-found codepoint 'decomposition-mapping))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-decomposition*) codepoint failure-result) 'mapping failure-result))

;; ---------- Implementation - codepoint numerics*

(define *ucd-numerics*
  (load-generated-module (current-directory) "numerics"))

(define (ucd-numeric-type codepoint [failure-result (lambda () (codepoint-not-found codepoint 'numeric-type))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-numerics*) codepoint failure-result) 'type))

(define (ucd-numeric-value codepoint [failure-result (lambda () (codepoint-not-found codepoint 'numeric-value))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-numerics*) codepoint failure-result) 'value))

;; ---------- Implementation - codepoint simple-*-mappings

(define *ucd-simple-mapping*
  (load-generated-module (current-directory) "simple-mapping"))

(define (ucd-simple-uppercase-mapping codepoint [failure-result (lambda () (codepoint-not-found codepoint 'simple-uppercase-mapping))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-simple-mapping*) codepoint failure-result) 'uppercase failure-result))

(define (ucd-simple-lowercase-mapping codepoint [failure-result (lambda () (codepoint-not-found codepoint 'simple-lowercase-mapping))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-simple-mapping*) codepoint failure-result) 'lowercase failure-result))

(define (ucd-simple-titlecase-mapping codepoint [failure-result (lambda () (codepoint-not-found codepoint 'simple-titlecase-mapping))])
  (assert-codepoint! codepoint)
  (hash-ref (hash-ref (force *ucd-simple-mapping*) codepoint failure-result) 'titlecase failure-result))

;; ---------- Implementation - codepoint age

(define *ucd-derived-age*
  (load-generated-module (current-directory) "derived-age"))

(define (ucd-age codepoint [failure-result (lambda () (codepoint-not-found codepoint 'age))])
  (assert-codepoint! codepoint)
  (range-dict-ref (force *ucd-derived-age*) codepoint failure-result))

;; ---------- Implementation - codepoint block-name

(define *ucd-block-names*
  (load-generated-module (current-directory) "block-names"))

(define (ucd-block-name codepoint [failure-result (lambda () (codepoint-not-found codepoint 'block-name))])
  (assert-codepoint! codepoint)
  (range-dict-ref (force *ucd-block-names*) codepoint failure-result))

;; ---------- Implementation - codepoint scripts

(define *ucd-scripts*
  (load-generated-module (current-directory) "scripts"))

(define (ucd-scripts codepoint [failure-result (lambda () (codepoint-not-found codepoint 'scripts))])
  (assert-codepoint! codepoint)
  (range-dict-ref (force *ucd-scripts*) codepoint failure-result))

;; ---------- Implementation - codepoint script-extensions

(define *ucd-script-extensions*
  (load-generated-module (current-directory) "script-extensions"))

(define (ucd-script-extensions codepoint [failure-result (lambda () (codepoint-not-found codepoint 'script-extensions))])
  (assert-codepoint! codepoint)
  (range-dict-ref (force *ucd-script-extensions*) codepoint failure-result))

;; ---------- Implementation - codepoint line-break

(define *ucd-line-break*
  (load-generated-module (current-directory) "line-break"))

(define (ucd-line-break codepoint [failure-result (lambda () (codepoint-not-found codepoint 'line-break))])
  (assert-codepoint! codepoint)
  (range-dict-ref (force *ucd-line-break*) codepoint failure-result))

(define (codepoint-not-found cp p)
  (raise-arguments-error 
    (string->symbol (format "ucd-~a" p)) 
    "no property data found for codepoint" 
    "codepoint" cp 
    "property" p))

