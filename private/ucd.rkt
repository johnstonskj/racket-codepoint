#lang racket/base

(require
  racket/bool
  racket/file
  racket/logging
  racket/system)

(provide fetch-unicode-character-data)

(define (ensure-command-installed command)
  (when (false? (find-executable-path command))
		(displayln (format "No ~a command installed" command) (current-error-port))
		(exit -1)))

(define (ensure-all-commands-installed . commands)
  (for ([command commands])
  	(ensure-command-installed command)))

(define (curl base-url file-name into-path)
  (log-info "curl ~a ~a ~a" base-url file-name into-path)
  (let* ([output-file (path->string (build-path into-path file-name))]
         [command (format "curl ~a~a -o ~a" base-url file-name output-file)])
    (make-directory* into-path)
    (when (false? (system command))
    	    (displayln "failed to execute curl command correctly" (current-error-port))
  	      (exit -2))))

(define (curl-all fetch-all root-dir)
  (log-info "curl-all")
  (for ([fetch-one fetch-all])
  	(curl (car fetch-one) 
          (cadr fetch-one) 
          (build-path root-dir (caddr fetch-one)))))

(define (fetch-unicode-character-data root-dir)
  (log-info "fetch-unicode-character-data")
  (ensure-all-commands-installed "curl" "unzip")
  (curl-all 
    '(("http://www.unicode.org/Public/UCD/latest/" "ReadMe.txt" "data")
      ("http://www.unicode.org/Public/UCD/latest/ucd/" "UCD.zip" "data")
      ("http://www.unicode.org/Public/UCD/latest/ucd/" "Unihan.zip" "data")
      ("http://www.unicode.org/Public/UCD/latest/charts/" "ReadMe.txt" "data/charts")
      ("http://www.unicode.org/Public/UCD/latest/charts/" "CodeCharts.pdf" "data/charts")))
  (when (false? (system (format "unzip -d data/ucd data/UCD.zip")))
    	  (displayln "failed to execute unzip on UCD download" (current-error-port))
  	    (exit -3))
  #t)


(module+ main
  (require racket/logging)
  (with-logging-to-port 
    (current-error-port) 
    (lambda () (fetch-unicode-character-data (current-directory)))
    'info))
