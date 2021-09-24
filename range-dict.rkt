#lang racket/base

(require 
	racket/bool 
	racket/list
	codepoint
	codepoint/range)

(provide
  (rename-out (rangedict? range-dict?))
  make-range-dict
  range-dict-length
  range-dict-ref
  range-dict-has-key?)

(struct rangedict (
	;; (vector-of (pair/c codepoint-range? any/c))
	data)
	#:prefab)

;; (or/c (list-of codepoint-range? (pair/c symbol? any/c))
;;       (list-of (pair/c codepoint-range? hash?))) -> rangedict
(define (make-range-dict data)
  (rangedict (list->vector (sort data codepoint-range<? #:key car))))

(define (assert-range-dict! v [name 'v])
  (unless (rangedict? v)
          (raise-arguments-error 
            'assert-range-dict
            "provided value was not a range-dict?" 
            (symbol->string name) v)))

(define (range-dict-length dict)
  (assert-range-dict! dict)
  (vector-length (rangedict-data dict)))

(define (range-dict-ref dict k [failure-result (lambda () 
													   (raise-arguments-error 
													     'range-dict-ref
													     "no value found for key"
													     "key" k))])
  (assert-range-dict! dict)
  (assert-codepoint! k)
  (range-dict-search dict k 0 (- (vector-length (rangedict-data dict)) 1) failure-result))

(define (range-dict-has-key? dict k)
  (range-dict-ref dict k (lambda () #f)))

(define (range-dict-search dict k start end [failure-result #f])
  (if (<= start end)
	  (let* ([mid (floor (/ (+ start end) 2))]
  			 [mid-row (vector-ref (rangedict-data dict) mid)]
  			 [mid-key (car mid-row)]
  			 [position (codepoint-range-compare mid-key k)])
	  	(cond
	  	  [(symbol=? position 'before) (range-dict-search dict k start (sub1 mid) failure-result)]
	  	  [(symbol=? position 'after)  (range-dict-search dict k (add1 mid) end failure-result)]
	  	  [(symbol=? position 'within) (cdr mid-row)]))
	  (failure-result)))
