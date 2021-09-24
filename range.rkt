#lang racket/base

(require 
  racket/format 
  racket/list
  codepoint)

(provide
  (except-out (struct-out codepoint-range) codepoint-range)
  make-codepoint-range
  assert-codepoint-range!
  pair->codepoint-range
  codepoint->codepoint-range
  codepoint-range-length
  codepoint-range=?
  codepoint-range<?
  codepoint-range>?
  codepoint-range-compare
  codepoint-range-contains?
  codepoint-range-contains-any?
  codepoint-range-contains-all?
  codepoint-range-intersects?
  codepoint-range-any-intersect?
  codepoint-range->inclusive-range
  codepoint-range->in-inclusive-range
  codepoint-range->unicode-string)

;; ---------- Implementation - codepoint-range type

(struct codepoint-range (
  start
  end)
  #:prefab)

(define (make-codepoint-range start end)
  (assert-codepoint! start 'start)
  (assert-codepoint! end 'end)
  (unless (<= start end) 
          (raise-arguments-error 
            'make-codepoint-range
            "the value of start must be less than, or equal, to end" 
            "start" start
            "end" end))
  (codepoint-range start end))

(define (assert-codepoint-range! v [name 'v])
  (unless (codepoint-range? v)
          (raise-arguments-error 
            'assert-codepoint-range
            "provided value was not a codepoint-range?" 
            (symbol->string name) v)))

(define (pair->codepoint-range cpr)
  (assert-codepoint! (car cpr) 'start)
  (assert-codepoint! (cdr cpr) 'end)
  (make-codepoint-range (car cpr) (cdr cpr)))

(define (codepoint->codepoint-range cp)
  (assert-codepoint! cp)
  (make-codepoint-range cp cp))

(define (codepoint-range-length cpr)
  (assert-codepoint-range! cpr)
  (- (codepoint-range-end cpr) (codepoint-range-start cpr)))

(define (codepoint-range=? lhs rhs)
  (assert-codepoint-range! lhs 'lhs)
  (assert-codepoint-range! rhs 'rhs)
  (and 
    (= (codepoint-range-start lhs) (codepoint-range-start rhs))
    (= (codepoint-range-end lhs) (codepoint-range-end rhs))))

(define (codepoint-range<? lhs rhs)
  (assert-codepoint-range! lhs 'lhs)
  (assert-codepoint-range! rhs 'rhs)
  (< (codepoint-range-end lhs) (codepoint-range-start rhs)))

(define (codepoint-range>? lhs rhs)
  (assert-codepoint-range! lhs 'lhs)
  (assert-codepoint-range! rhs 'rhs)
  (> (codepoint-range-end lhs) (codepoint-range-start rhs)))

(define (codepoint-range-compare cpr cp)
  (assert-codepoint-range! cpr)
  (assert-codepoint! cp)
  (cond 
    [(< cp (codepoint-range-start cpr)) 'before]
    [(> cp (codepoint-range-end cpr)) 'after]
    [else 'within]))

(define (codepoint-range-contains? cpr cp)
  (assert-codepoint-range! cpr)
  (assert-codepoint! cp)
  (and (>= cp (codepoint-range-start cpr)) (<= cp (codepoint-range-end cpr))))

(define (codepoint-range-contains-all? cpr . cpl)
  (for/and ([cp cpl]) (codepoint-range-contains? cpr cp)))

(define (codepoint-range-contains-any? cpr . cpl)
  (for/or ([cp cpl]) (codepoint-range-contains? cpr cp)))

(define (codepoint-range-intersects? cpr1 cpr2)
  (or 
    (codepoint-range-contains-any? cpr1 (codepoint-range-start cpr2) (codepoint-range-end cpr2))
    (codepoint-range-contains-any? cpr2 (codepoint-range-start cpr1) (codepoint-range-end cpr1))))

(define (codepoint-range-any-intersect? cpr-list)
  (for/or ([pair (in-combinations cpr-list 2)]) 
    (codepoint-range-intersects? (car pair) (car (cdr pair)))))

(define (codepoint-range->inclusive-range cpr [step 1])
  (assert-codepoint-range! cpr)
  (inclusive-range (codepoint-range-start cpr) (codepoint-range-end cpr) step))

(define (codepoint-range->in-inclusive-range cpr [step 1])
  (assert-codepoint-range! cpr)
  (in-inclusive-range (codepoint-range-start cpr) (codepoint-range-end cpr) step))

(define (codepoint-range->unicode-string cpr)
  (assert-codepoint-range! cpr)
  (format 
    "~a..~a" 
    (codepoint->unicode-string (codepoint-range-start cpr)) 
    (codepoint->unicode-string (codepoint-range-end cpr))))
