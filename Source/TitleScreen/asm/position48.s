;;; macro.h is already included via MultiSpriteSuperChip.s in Preamble.s

position48 .proc
          ;;position P0 and P1

          sta WSYNC

          lda #$90        ;; 2 cycles
          sta HMP0        ;; 3 cycles
          lda #$A0        ;; 2 cycles
          sta HMP1        ;; 3 cycles

          inc temp1
          dec temp1
          inc temp1
          dec temp1
          inc temp1
          .SLEEP 2
          sta RESP0       ;; +3 cycles
          sta RESP1       ;; +3 cycles
          dec temp1       ;; +5 cycles
          inc temp1       ;; +5 cycles
          dec temp1       ;; +5 cycles
          inc temp1       ;; +5 cycles
          dec temp1       ;; +5 cycles
          .SLEEP 3
          sta HMOVE       ;; +76 cycles
          rts
.pend

