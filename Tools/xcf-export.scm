(define (xcf-export source dest)
  (let ((image (car (gimp-file-load RUN-NONINTERACTIVE source))))
    (file-png-export RUN-NONINTERACTIVE image dest
                     0 TRUE 9 TRUE TRUE TRUE TRUE FALSE TRUE "auto")
    (gimp-image-delete image)))
