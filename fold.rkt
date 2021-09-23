#lang racket/base

(require 
  racket/bool
  racket/list
  racket/promise
  codepoint 
  codepoint/properties)

(require 
  "./private/generator.rkt")

(provide
  ucd-case-folding
  case-fold-common
  case-fold-simple
  case-fold-full)

;; ---------- Implementation - codepoint case-folding

(define *ucd-case-folding*
  (load-generated-module (current-directory) "case-folding"))

(define (ucd-case-folding codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref 
    (force *ucd-case-folding*) 
    codepoint 
    (lambda () (hash 'common (list codepoint)))))

(define (case-fold-twice codepoint second)
  (flatten 
    (map (lambda (cp) (hash-ref (ucd-case-folding codepoint) second (lambda () (list codepoint))))
      (case-fold-common codepoint))))

(define (case-fold-common codepoint)
  (unless (codepoint? codepoint) (raise 'expecting-codepoint))
  (hash-ref 
    (ucd-case-folding codepoint) 
    'common
    (lambda () (list codepoint))))

(define (case-fold-simple codepoint)
  (case-fold-twice codepoint 'simple))

(define (case-fold-full codepoint)
  (case-fold-twice codepoint 'full))
