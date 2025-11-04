(define (xcf-export source dest)
  (let ((image (car (gimp-file-load RUN-NONINTERACTIVE source))))
    (file-png-export #:run-mode RUN-NONINTERACTIVE
                     #:image image
                     #:file dest
                     #:options 0
                     #:interlaced TRUE
                     #:compression 9
                     #:bkgd TRUE
                     #:offs TRUE
                     #:phys TRUE
                     #:time TRUE
                     #:save-transparent FALSE
                     #:optimize-palette TRUE
                     #:format "auto")
    (gimp-image-delete image)))
