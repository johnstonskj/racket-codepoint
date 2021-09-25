#lang racket/base

(require 
  rackunit
  codepoint)

(define predicate-tests
  (test-case
    "Check basic predicates"
  	(check-true (codepoint? #x0000))
  ))