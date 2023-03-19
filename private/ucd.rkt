#lang racket/base

(require
  racket/bool
  racket/file
  racket/logging
  racket/port
  net/url
  file/unzip)

(provide fetch-unicode-character-data)

(define (download base-url file-name into-path)
  (log-info "download ~a ~a ~a" base-url file-name (path->string into-path))
  (let ([url (combine-url/relative (string->url base-url) file-name)]
        [output-file (build-path into-path file-name)])
    (make-directory* into-path)
    (call-with-output-file output-file #:exists 'truncate/replace
      (lambda (out-port)
        (call/input-url url get-pure-port
                        (lambda (in-port)
                          (copy-port in-port out-port)))))))

(define (download-all fetch-all root-dir)
  (log-info "download-all")
  (for ([fetch-one fetch-all])
    (download (car fetch-one)
              (cadr fetch-one)
              (build-path root-dir (caddr fetch-one)))))

(define (fetch-unicode-character-data root-dir)
  (log-info "fetch-unicode-character-data")
  (download-all
    '(("http://www.unicode.org/Public/UCD/latest/" "ReadMe.txt" "data")
      ("http://www.unicode.org/Public/UCD/latest/ucd/" "UCD.zip" "data")
      ("http://www.unicode.org/Public/UCD/latest/ucd/" "Unihan.zip" "data")
      ("http://www.unicode.org/Public/UCD/latest/charts/" "ReadMe.txt" "data/charts")
      ("http://www.unicode.org/Public/UCD/latest/charts/" "CodeCharts.pdf" "data/charts"))
    root-dir)
  (log-info "Unzipping UCD.zip")
  (unzip "data/UCD.zip" (make-filesystem-entry-reader #:dest "data/ucd" #:exists 'truncate/replace))
  #t)


(module+ main
  (require racket/logging)
  (with-logging-to-port 
    (current-error-port) 
    (lambda () (fetch-unicode-character-data (current-directory)))
    'info))
