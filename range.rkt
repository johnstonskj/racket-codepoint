#lang racket/base

(require 
  racket/format 
  racket/list
  codepoint)

(provide
  (except-out (struct-out codepoint-range) codepoint-range)
  make-codepoint-range
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
  (unless (and (codepoint? start) (codepoint? end)) (raise-expecting-codepoint 'make-codepoint-range))
  (unless (<= start end) (raise-invalid-codepoint-range 'make-codepoint-range start end))
  (codepoint-range start end))

(define (pair->codepoint-range cpr)
  (unless (and (pair? cpr) (codepoint? (car cpr)) (codepoint? (cdr cpr))) (raise-expecting-codepoint 'pair->codepoint-range))
  (make-codepoint-range (car cpr) (cdr cpr)))

(define (codepoint->codepoint-range cp)
  (unless (codepoint? cp) (raise-expecting-codepoint 'codepoint->codepoint-range))
  (make-codepoint-range cp cp))

(define (codepoint-range-length cpr)
  (unless (codepoint-range? cpr) (raise-expecting-codepoint-range 'codepoint-range-length))
  (- (codepoint-range-end cpr) (codepoint-range-start cpr)))

(define (codepoint-range=? lhs rhs)
  (and 
    (= (codepoint-range-start lhs) (codepoint-range-start rhs))
    (= (codepoint-range-end lhs) (codepoint-range-end rhs))))

(define (codepoint-range<? lhs rhs)
  (< (codepoint-range-end lhs) (codepoint-range-start rhs)))

(define (codepoint-range>? lhs rhs)
  (> (codepoint-range-end lhs) (codepoint-range-start rhs)))

(define (codepoint-range-compare cpr cp)
  (unless (codepoint-range? cpr) (raise-expecting-codepoint-range 'codepoint-range-compare))
  (unless (codepoint? cp) (raise-expecting-codepoint 'codepoint-range-compare))
  (cond 
    [(< cp (codepoint-range-start cpr)) 'before]
    [(> cp (codepoint-range-end cpr)) 'after]
    [else 'within]))

(define (codepoint-range-contains? cpr cp)
  (unless (codepoint-range? cpr) (raise-expecting-codepoint-range 'codepoint-range-contains?))
  (unless (codepoint? cp) (raise-expecting-codepoint 'codepoint-range-contains?))
  (and (>= cp (codepoint-range-start cpr)) (<= cp (codepoint-range-end cpr))))

(define (codepoint-range-contains-all? cpr . cpl)
  (unless (codepoint-range? cpr) (raise-expecting-codepoint-range 'codepoint-range-contains-all?))
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
  (unless (codepoint-range? cpr) (raise-expecting-codepoint-range 'codepoint-range->inclusive-range))
  (inclusive-range (codepoint-range-start cpr) (codepoint-range-end cpr) step))

(define (codepoint-range->in-inclusive-range cpr [step 1])
  (unless (codepoint-range? cpr) (raise-expecting-codepoint-range 'codepoint-range->in-inclusive-range))
  (in-inclusive-range (codepoint-range-start cpr) (codepoint-range-end cpr) step))

(define (codepoint-range->unicode-string cpr)
  (unless (codepoint-range? cpr) (raise-expecting-codepoint-range 'codepoint-range->unicode-string))
  (format 
    "~a..~a" 
    (codepoint->unicode-string (codepoint-range-start cpr)) 
    (codepoint->unicode-string (codepoint-range-end cpr))))


(define (raise-expecting-codepoint-range fn)
  (raise-arguments-error fn "argument was not a codepoint-range? value"))

(define (raise-invalid-codepoint-range fn start end)
  (raise-arguments-error fn "start value must not be less than end value" "start" start "end" end))

(define (raise-expecting-codepoint fn)
  (raise-arguments-error fn "argument was not a codepoint? value"))