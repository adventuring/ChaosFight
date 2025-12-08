;;; macro.h is already included via MultiSpriteSuperChip.s in Preamble.s

position48 .proc
          ;;position P0 and P1

          sta WSYNC

          lda #$90        ;; 2 cycles
          ;; sta HMP0        ;; 3 cycles (duplicate)
          ;; lda #$A0        ;; 2 cycles (duplicate)
          ;; sta HMP1        ;; 3 cycles (duplicate)

          inc temp1
          dec temp1
          ;; inc temp1 (duplicate)
          ;; dec temp1 (duplicate)
          ;; inc temp1 (duplicate)
          .SLEEP 2
          ;; sta RESP0       ;; +3 cycles (duplicate)
          ;; sta RESP1       ;; +3 cycles (duplicate)
          ;; dec temp1       ;; +5 cycles (duplicate)
          ;; inc temp1       ;; +5 cycles (duplicate)
          ;; dec temp1       ;; +5 cycles (duplicate)
          ;; inc temp1       ;; +5 cycles (duplicate)
          ;; dec temp1       ;; +5 cycles (duplicate)
          .SLEEP 3
          ;; sta HMOVE       ;; +76 cycles (duplicate)
          rts
.pend

