#lang racket/base

(provide
  load-source-codepoints
  load-generated-module
  generate-modules)

;; ---------- Requirements

(require
  racket/bool
  racket/file
  racket/hash
  racket/list
  racket/promise
  racket/string
  racket/system
  (only-in srfi/13 string-index)
  codepoint/range
  codepoint/range-dict
  "./ucd.rkt")

;; ---------- Constant Values

(define *source-data-directory* "data/ucd")

(define *ucd-field-sep* ";")

(define *ucd-comment-start* "#")

(define *generate-module-directory* "generated")

;; ---------- Implementation - File Handling

(define (load-source-codepoints file-root root-dir)
  (map
    (lambda (row) (string->codepoint-range (vector-ref row 0)))
    (lines->data 
      (load-data-file file-root root-dir))))

;; (source? path?) -> (listof vector?)
(define (read-source-file source root-dir)
  (lines->data 
    (load-data-file (source-file-root source) root-dir)))

;; (string? path?) -> (listof string?)
(define (load-data-file file-root root-dir)
  (filter-map
    (λ (line)
    ;; this filters out comments from each line
      (let* ([comment (string-index line #\#)]
             [line (if (false? comment) line (substring line 0 comment))]
             [trimmed (string-trim line #:repeat? #t)])
        (if (non-empty-string? trimmed)
            trimmed
            #f)))
   (file->lines (ucd-data-file-name root-dir file-root))))

;; ((listof string?)) -> (listof vector?)
(define (lines->data lines)
  (map
    (lambda (line)
      (list->vector 
        (map 
          (lambda (field) (string-trim field #:repeat? #t)) 
          (string-split line *ucd-field-sep*))))
    lines))

;; (path? string?) -> future?
(define (load-generated-module root-dir file-root)
  (delay 
    (with-input-from-file
      (generated-module-name root-dir file-root)
      (lambda () (read)))))

;; (path? string?) -> path?
(define (ucd-data-file-name root-dir file-root)
  (path-add-extension 
    (build-path 
      root-dir 
      *source-data-directory* 
      file-root) 
    ".txt"))

;; (path? string?) -> path?
(define (generated-module-name root-dir file-root)
  (path-add-extension 
    (build-path 
      root-dir 
      *generate-module-directory* 
      file-root)
    ".rkt-src"))

(define (generate-from-source source root-dir)
  (log-info (format "Processing source ~a" (source-file-root source)))
  (let ([source-data (read-source-file source root-dir)])
    (for ([target (source-targets source)])
      (let ([target-data (source-data->target 
                           source-data
                           (target-field-mapping target)
                           (target-row-filter target)
                           (if (source-compressed? source)
                               string->codepoint-range
                               string->codepoint))])
      (write-target-file
        root-dir
        (target-file-root target)
        (target-data-final 
          target-data 
          (source-compressed? source)
          (target-duplicates? target)
          (target-finalizer target)))))))

(define (source-data->target source-data field-mapping row-filter key-constructor)
  (filter-map
    (lambda (row)
      (if (or (false? row-filter) (row-filter row))
        (cons
          (key-constructor (vector-ref row 0))
          (map-row-fields field-mapping row))
        #f))
    source-data))

(define (target-data-final target-data compressed? duplicates? row-finalizer)
  (cond
    [(and compressed? duplicates?)
;     (for ([key-value target-data])
;       (let ([key (car key-value)] [value (cdr key-value)])
;         (for ([existing-key-value target-data])
;           (when (and (not (equal? (car existing-key-value) key))
;                      (if (codepoint-range? key)
;                          (codepoint-range-intersects? (car existing-key-value) key)
;                          (codepoint-range-contains? (car existing-key-value) key)))
;             (displayln (format "~a ?= ~a" (car existing-key-value) key))))))
     (raise 'unexpected)]
    [(and (false? compressed?) duplicates?)
     (let ([results (make-hash)])
       (for ([key-value target-data])
         (let ([key (car key-value)] [value (cdr key-value)])
           (if (hash-has-key? results key)
               (let ([existing-value (hash-ref results key)])
                 (hash-set! results key (append existing-value (list value))))
               (hash-set! results key (list value)))))
       (finalize-data results row-finalizer))]
    [(and compressed? (false? duplicates?))
     (make-range-dict (finalize-data target-data row-finalizer))]
    [(and (false? compressed?) (false? duplicates?))
     (make-hash (finalize-data target-data row-finalizer))]))

(define (finalize-data target-data row-finalizer)
  (cond
    [(and (hash? target-data) row-finalizer)
     (hash-for-each target-data (lambda (key value) (hash-set! target-data key (row-finalizer value))))
     target-data]
    [(and (list? target-data) row-finalizer)
     (map (lambda (key-value)
               (cons
                 (car key-value)
                 ((target-finalizer target) (cdr key-value))))
             target-data)]
    [else target-data]))

(define (map-row-fields field-mapping row)
  (if (= (length field-mapping) 1)
      (cdr (map-row-field (car field-mapping) row))
      (make-hash 
        (map (lambda (field) (map-row-field field row)) field-mapping))))

(define (map-row-field field row)
  (cons 
    (source-field-name field) 
    ((source-field-converter field) 
      (let ([index (source-field-index field)])
        (if (list? index)
          (map
            (lambda (index)
              (if (< index (vector-length row))
                (vector-ref row index)
                (string)))
            index)
          (if (< index (vector-length row))
            (vector-ref row index)
            (string)))))))

;; (string? path? hash?) -> #<void>
(define (write-target-file root-dir file-root data)
  (log-info (format "Writing target ~a" file-root))
  (with-output-to-file 
    (generated-module-name root-dir file-root)
    (lambda ()
      (writeln data))))

;; ---------- Implementation - Data Value Conversions

;; (string?) -> string?
(define (as-is o) o)

;; (string?) -> codepoint?
(define (string->codepoint str)
  (or (string->number str 16) 0))

;; (string?) -> (or codepoint? #f)
(define (string->maybe-codepoint str)
  (or (string->number str 16) #f))

;; (string?) -> (listof codepoint?)
(define (string->codepoint-list str)
  (map string->codepoint (string-split str " ")))

;; (string?) -> (codepoint? . codepoint?)
(define (string->codepoint-range str)
  (let ([dot (string-index str #\.)])
    (if (false? dot) 
        (let ([low (string->codepoint str)])
          (make-codepoint-range low low))
        (let ([low (string->codepoint (substring str 0 dot))]
              [high (string->codepoint (substring str (+ dot 2)))])
          (make-codepoint-range low high)))))
  
;; (string?) -> symbol?
(define (string->decomposition-type str)
  (let ([end (string-index str #\>)])
    (if (false? end)
        'canonical
        (string->symbol (substring str 1 end)))))

;; (string?) -> (listof codepoint?)
(define (string->decomposition-mapping str)
  (let* ([angle (string-index str #\>)]
         [start (if (false? angle) 0 (+ angle 1))])
    (string->codepoint-list (substring str start))))

;; (string?) -> (listof symbol?)
(define (string->script-names str)
  (map
    (lambda (s) (string->symbol (string-trim s #:repeat? #t)))
    (string-split str " ")))


;; (string?) -> (or 'decimal 'digit 'numeric #f)
(define (string->numeric-type lst)
  (let ([values (map string->number lst)])
    (cond
      [(and (false? (car values)) (false? (cadr values)) (false? (caddr values)))
        #f]
      [(and (false? (car values)) (false? (cadr values)))
        'numeric]
      [(and (false? (car values)) (not (false? (cadr values))))
        'digit]
      [else 'decimal])))

;; (string?) -> (or 'open 'close 'none #f)
(define (string->bracket-type str)
    (cond
      [(string=? str "o")
        'open]
      [(string=? str "c")
        'close]
      [(string=? str "n")
        'none]
      [else #f]))

;; ---------- Implementation - Row Filters

(define (has-bidi-mappings row)
  (or (non-empty-string? (vector-ref row 4)) (non-empty-string? (vector-ref row 9))))

(define (has-decomposition-mappings row)
  (non-empty-string? (vector-ref row 5)))

(define (has-numeric-mappings row)
  (or (non-empty-string? (vector-ref row 6)) 
      (non-empty-string? (vector-ref row 7))
      (non-empty-string? (vector-ref row 8))))

(define (has-simple-case-mappings row)
  (or (non-empty-string? (vector-ref row 12)) 
      (non-empty-string? (vector-ref row 13))
      (if (> (vector-length row) 14)
          (non-empty-string? (vector-ref row 14))
          #f)))

(define (pivot-case-hashes value)
  (if (list? value)
    (for/hash ([mapping value])
      (values 
        (hash-ref mapping 'status)
        (hash-ref mapping 'mapping)))
    (hash
      (hash-ref value 'status)
      (quote (hash-ref value 'mapping)))))

;; ---------- Implementation - Data File Mappings

(struct source-field (
  index
  name
  converter))

(struct source (
  file-root
  targets
  compressed?)
  #:transparent)

(struct target (
  file-root
  field-mapping
  row-filter
  duplicates?
  finalizer))

(define (make-source file-root #:compressed? [compressed? #f] . targets)
  (source 
    file-root
    targets
    compressed?))

(define (make-target 
          file-root 
          #:duplicates? [duplicates? #f] 
          #:row-filter [row-filter #f] 
          #:finalizer [finalizer #f] 
          . field-mapping)
  (target
    file-root
    field-mapping
    row-filter
    duplicates?
    finalizer))

(define *age-data-source*
  (make-source 
    "DerivedAge"
    #:compressed? #t
    (make-target "derived-age" (source-field 1 'assigned as-is))))

(define *bidi-brackets-data-source*
  (make-source 
    "BidiBrackets"
    (make-target
      "bidi-brackets"
      (source-field 1 'matching string->codepoint)
      (source-field 2 'type string->bracket-type))))

(define *bidi-mirroring-data-source*
  (make-source 
    "BidiMirroring"
    (make-target "bidi-mirroring" (source-field 1 'glyph string->codepoint))))

(define *block-names-data-source*
  (make-source 
    "Blocks"
    #:compressed? #t
    (make-target "block-names" (source-field 1 'name as-is))))

(define *case-folding-data-source*
  (make-source 
    "CaseFolding"
    (make-target
      "case-folding"
      #:duplicates? #t
      #:finalizer pivot-case-hashes
      (source-field 1 'status 
        (lambda (status) 
          (cond
            [(string=? status "C") 'common]
            [(string=? status "S") 'simple]
            [(string=? status "F") 'full]
            [(string=? status "T") 'turkic])))
      (source-field 2 'mapping string->codepoint-list))))

(define *line-break-data-source*
  (make-source 
    "LineBreak" 
    #:compressed? #t
    (make-target "line-break" (source-field 1 'property string->symbol))))

(define *name-alias-data-source*
  (make-source 
    "NameAliases" 
    (make-target
      "name-aliases"
      #:duplicates? #t
      (source-field 1 'alias as-is) 
      (source-field 2 'type string->symbol))))

(define *scripts-data-source*
  (make-source 
    "Scripts"
    #:compressed? #t
    (make-target "scripts" (source-field 1 'name string->script-names))))

(define *script-extensions-data-source*
  (make-source 
    "ScriptExtensions" 
    #:compressed? #t
    (make-target "script-extensions" (source-field 1 'extensions string->script-names))))

(define *unicode-data-source*
  (make-source 
    "UnicodeData"
    (make-target "name" (source-field 1 'name as-is))
    (make-target "general-category" (source-field 2 'general-category string->symbol))
    (make-target "combining-class" (source-field 3 'canonical-combining-class string->number))
    (make-target
      "simple-mapping"
      #:row-filter has-simple-case-mappings
      (source-field 12 'uppercase string->maybe-codepoint)
      (source-field 13 'lowercase string->maybe-codepoint)
      (source-field 14 'titlecase string->maybe-codepoint))
    (make-target 
      "bidi"
      #:row-filter has-bidi-mappings
      (source-field 4 'class string->symbol)
      (source-field 9 'mirrored 
        (lambda (status) 
          (cond
            [(string=? status "Y") #t]
            [else #f]))))
    (make-target
      "decomposition"
      #:row-filter has-decomposition-mappings
      (source-field 5 'type string->decomposition-type)
      (source-field 5 'mapping string->decomposition-mapping))
    (make-target
      "numerics"
      #:row-filter has-numeric-mappings
      (source-field '(6 7 8) 'type string->numeric-type)
      (source-field 8 'value string->number))))

;; ---------- Implementation - Generator

;; provided (path?) -> #<void>
(define (generate-modules root-dir)

  (unless (directory-exists? *source-data-directory*)
    (log-info "Fetching UCD data files...")
    (fetch-unicode-character-data root-dir))

  (unless (directory-exists? *generate-module-directory*)
    (make-directory *generate-module-directory*))

  (for ([source (list 
                  *age-data-source* 
                  *bidi-brackets-data-source*
                  *bidi-mirroring-data-source*
                  *block-names-data-source*
                  *case-folding-data-source* 
                  *line-break-data-source*
                  *name-alias-data-source*
                  *scripts-data-source*
                  *script-extensions-data-source*
                  *unicode-data-source*)])
    (generate-from-source source root-dir)))

;; ---------- Implementation - command-line tool

(module+ main
  (require racket/logging)
  (with-logging-to-port 
    (current-error-port) 
    (lambda ()
      (generate-modules (current-directory)))
    'info))
