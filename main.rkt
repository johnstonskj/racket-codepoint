#lang racket/base

(require racket/format racket/list)

(provide
  *max-codepoint-value*
  codepoint?
  codepoint-non-character?
  codepoint-utf16-surrogate?
  codepoint-private-use?
  codepoint->char
  char->codepoint
  codepoint->unicode-string
  codepoint-plane
  codepoint-plane-name
  assert-codepoint!)

;; ---------- Values

(define *max-codepoint-value* #x10FFFF)

(define *codepoint-plane-names*
  #(basic-multilingual-plane
    supplementary-multilingual-plane
    supplementary-ideographic-plane
    tertiary-ideographic-plane
    #f #f #f #f #f #f #f #f #f #f
    supplementary-special-purpose-plane
    supplementary-private-use-area-A
    supplementary-private-use-area-B))

;; ---------- Implementation - codepoint type

(define (codepoint? v)
  (and 
    (exact-nonnegative-integer? v)
    (<= v *max-codepoint-value*)))

(define (assert-codepoint! v [name 'v])
  (unless (codepoint? v)
          (raise-arguments-error 
            'assert-codepoint 
            "provided value was not a codepoint?" 
            (symbol->string name) v)))

(define (codepoint-non-character? obj)
  ;; see http://www.unicode.org/versions/corrigendum9.html
  ;; and http://www.unicode.org/faq/private_use.html
  (and 
    (exact-nonnegative-integer? obj) 
    (or 
      (<= #xFDD0  obj #xFDEF)
      (<= #x0FFFE obj #x0FFFF)
      (<= #x1FFFE obj #x1FFFF)
      (<= #x2FFFE obj #x2FFFF)
      (<= #x3FFFE obj #x3FFFF)
      (<= #x4FFFE obj #x4FFFF)
      (<= #x5FFFE obj #x5FFFF)
      (<= #x6FFFE obj #x6FFFF)
      (<= #x7FFFE obj #x7FFFF)
      (<= #x8FFFE obj #x8FFFF)
      (<= #x9FFFE obj #x9FFFF)
      (<= #xAFFFE obj #xAFFFF)
      (<= #xBFFFE obj #xBFFFF)
      (<= #xCFFFE obj #xCFFFF)
      (<= #xDFFFE obj #xDFFFF)
      (<= #xEFFFE obj #xEFFFF)
      (<= #xFFFFE obj #xFFFFF)
      (<= #x10FFFE obj #x10FFFF))))

(define (codepoint-utf16-surrogate? obj)
  ;; see https://unicode.org/faq/utf_bom.html
  (and 
    (exact-nonnegative-integer? obj) 
    (<= #xD800 obj #xDFFF)))

(define (codepoint-private-use? obj)
  ;; see http://www.unicode.org/faq/private_use.html
  (and 
    (exact-nonnegative-integer? obj) 
    (or 
      (<= #xE000   obj #xF8FF)
      (<= #xF0000  obj #xFFFFD)
      (<= #x100000 obj #x10FFFD))))

(define (codepoint->char codepoint)
  (assert-codepoint! codepoint)
  (when (or (<= #xD800  codepoint #xDFFF)
            (<= #xE000  codepoint #xF8FF)
            (<= #xFDD0  codepoint #xFDEF)
            (<= #xF0000 codepoint #xFFFFD)
            (<= #x0FFFE codepoint #x0FFFF)
            (<= #x1FFFE codepoint #x1FFFF)
            (<= #x2FFFE codepoint #x2FFFF)
            (<= #x3FFFE codepoint #x3FFFF)
            (<= #x4FFFE codepoint #x4FFFF)
            (<= #x5FFFE codepoint #x5FFFF)
            (<= #x6FFFE codepoint #x6FFFF)
            (<= #x7FFFE codepoint #x7FFFF)
            (<= #x8FFFE codepoint #x8FFFF)
            (<= #x9FFFE codepoint #x9FFFF)
            (<= #xAFFFE codepoint #xAFFFF)
            (<= #xBFFFE codepoint #xBFFFF)
            (<= #xCFFFE codepoint #xCFFFF)
            (<= #xDFFFE codepoint #xDFFFF)
            (<= #xEFFFE codepoint #xEFFFF)
            (<= #xFFFFE codepoint #xFFFFF)
            (<= #x100000 codepoint #x10FFFD)
            (<= #x10FFFE codepoint #x10FFFF))
        (raise-arguments-error 
            'codepoint->char 
            "provided codepoint? does not represent a character" 
            "codepoint" codepoint))
  (integer->char codepoint))

(define char->codepoint char->integer)

(define (codepoint-plane codepoint)
  (assert-codepoint! codepoint)
  (floor (/ codepoint #xFFFF)))

(define (codepoint-plane-name codepoint)
  (vector-ref *codepoint-plane-names* (codepoint-plane codepoint)))

(define (codepoint->unicode-string codepoint)
  (assert-codepoint! codepoint)
  (format "U+~a" (~r codepoint #:base '(up 16) #:min-width 4 #:pad-string "0")))
