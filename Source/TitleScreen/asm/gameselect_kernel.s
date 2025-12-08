.proc draw_gameselect_display
          lda # 0
          sta GRP0
          ;; sta GRP1 (duplicate)

          ldy # 4
          sty aux2

          ;; lda bmp_gameselect_color (duplicate)
          ;; sta COLUP0 (duplicate)
          ;; sta COLUP1 (duplicate)

	;;change gamenumber to a BCD number and stick it in temp5
          ;; lda gamenumber (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)
          ldx # 8
          clc
          sed
converttobcd:
          asl temp3
          ;; lda temp4 (duplicate)
          adc temp4
          ;; sta temp4 (duplicate)
          dex
          bne converttobcd
          cld

          ;; lda temp4 (duplicate)
          and #$0f
          ;; sta temp3 (duplicate)
          ;; asl (duplicate)
          ;; asl (duplicate)
          ;; clc (duplicate)
          ;; adc temp3 ;;; *5 (duplicate)
          ;; clc (duplicate)
          ;; adc # <(font_gameselect_img) (duplicate)
          ;; sta scorepointers+10 (duplicate)

          ;; lda temp4 (duplicate)
          ;; and #$f0 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; sta temp3 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; clc (duplicate)
          ;; adc temp3 ;;; *5 (duplicate)
          ;; clc (duplicate)
          ;; adc # <(font_gameselect_img) (duplicate)
          ;; sta scorepointers+8 (duplicate)


        ;;setup score pointers to point at my bitmap slices instead
          ;; lda # <(bmp_gameselect_CHAR0) (duplicate)
          ;; sta scorepointers+0 (duplicate)
          ;; lda # >(bmp_gameselect_CHAR0) (duplicate)
          ;; sta scorepointers+1 (duplicate)
          ;; lda # <(bmp_gameselect_CHAR1) (duplicate)
          ;; sta scorepointers+2 (duplicate)
          ;; lda # >(bmp_gameselect_CHAR1) (duplicate)
          ;; sta scorepointers+3 (duplicate)
          ;; lda # <(bmp_gameselect_CHAR2) (duplicate)
          ;; sta scorepointers+4 (duplicate)
          ;; lda # >(bmp_gameselect_CHAR2) (duplicate)
          ;; sta scorepointers+5 (duplicate)
          ;; lda # <(bmp_gameselect_CHAR3) (duplicate)
          ;; sta scorepointers+6 (duplicate)
          ;; lda # >(bmp_gameselect_CHAR3) (duplicate)
          ;; sta scorepointers+7 (duplicate)

          ;; lda # >(font_gameselect_img) (duplicate)
          ;; sta scorepointers+9 (duplicate)

          ;; lda # >(font_gameselect_img) (duplicate)
          ;; sta scorepointers+11 (duplicate)

          jmp draw_bmp_48x1_X
.pend
