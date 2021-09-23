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
  codepoint->unicode-string)

;; ---------- Values

(define *max-codepoint-value* #x10FFFF)

;; ---------- Implementation - codepoint type

(define (codepoint? obj)
  (and 
    (exact-nonnegative-integer? obj)
    (<= obj *max-codepoint-value*)))

(define (codepoint-non-character? obj)
  ;; see http://www.unicode.org/versions/corrigendum9.html
  ;; and http://www.unicode.org/faq/private_use.html
  (and 
    (exact-nonnegative-integer? obj) 
    (or 
      (and (>= obj #xFDD0)  (<= obj #xFDEF))
      (and (>= obj #x0FFFE) (<= obj #x0FFFF))
      (and (>= obj #x1FFFE) (<= obj #x1FFFF))
      (and (>= obj #x2FFFE) (<= obj #x2FFFF))
      (and (>= obj #x3FFFE) (<= obj #x3FFFF))
      (and (>= obj #x4FFFE) (<= obj #x4FFFF))
      (and (>= obj #x5FFFE) (<= obj #x5FFFF))
      (and (>= obj #x6FFFE) (<= obj #x6FFFF))
      (and (>= obj #x7FFFE) (<= obj #x7FFFF))
      (and (>= obj #x8FFFE) (<= obj #x8FFFF))
      (and (>= obj #x9FFFE) (<= obj #x9FFFF))
      (and (>= obj #xAFFFE) (<= obj #xAFFFF))
      (and (>= obj #xBFFFE) (<= obj #xBFFFF))
      (and (>= obj #xCFFFE) (<= obj #xCFFFF))
      (and (>= obj #xDFFFE) (<= obj #xDFFFF))
      (and (>= obj #xEFFFE) (<= obj #xEFFFF))
      (and (>= obj #xFFFFE) (<= obj #xFFFFF))
      (and (>= obj #x10FFFE) (<= obj #x10FFFF)))))

(define (codepoint-utf16-surrogate? obj)
  ;; see https://unicode.org/faq/utf_bom.html
  (and 
    (exact-nonnegative-integer? obj) 
    (>= obj #xD800)
    (<= obj #xDFFF)))

(define (codepoint-private-use? obj)
  ;; see http://www.unicode.org/faq/private_use.html
  (and 
    (exact-nonnegative-integer? obj) 
    (or 
      (and (>= obj #xE000) (<= obj #xF8FF))
      (and (>= obj #xF0000) (<= obj #xFFFFD))
      (and (>= obj #x100000) (<= obj #x10FFFD)))))

(define codepoint->char integer->char)

(define char->codepoint char->integer)

(define (codepoint->unicode-string codepoint)
  (unless (codepoint? codepoint) (raise-expecting-codepoint 'codepoint->unicode-string))
  (format "U+~a" (~r codepoint #:base '(up 16) #:min-width 4 #:pad-string "0")))

(define (raise-expecting-codepoint fn)
  (raise-arguments-error fn "argument was not a codepoint? value"))