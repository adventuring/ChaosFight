.proc draw_gameselect_display
          lda # 0
          sta GRP0
          sta GRP1

          ldy # 4
          sty aux2

          lda bmpGameselectColor
          sta COLUP0
          sta COLUP1

	;;change gamenumber to a BCD number and stick it in temp5
          lda gamenumber
          sta temp3
          lda # 0
          sta temp4
          ldx # 8
          clc
          sed
converttobcd:
          asl temp3
          lda temp4
          adc temp4
          sta temp4
          dex
          bne converttobcd
          cld

          lda temp4
          and #$0f
          sta temp3
          asl
          asl
          clc
          adc temp3 ;;; *5
          clc
          adc # <(font_gameselect_img)
          sta scorePointers+10

          lda temp4
          and #$f0
          lsr
          lsr
          sta temp3
          lsr
          lsr
          clc
          adc temp3 ;;; *5
          clc
          adc # <(font_gameselect_img)
          sta scorePointers+8


        ;;setup score pointers to point at my bitmap slices instead
          lda # <(bmp_gameselect_CHAR0)
          sta scorePointers+0
          lda # >(bmp_gameselect_CHAR0)
          sta scorePointers+1
          lda # <(bmp_gameselect_CHAR1)
          sta scorePointers+2
          lda # >(bmp_gameselect_CHAR1)
          sta scorePointers+3
          lda # <(bmp_gameselect_CHAR2)
          sta scorePointers+4
          lda # >(bmp_gameselect_CHAR2)
          sta scorePointers+5
          lda # <(bmp_gameselect_CHAR3)
          sta scorePointers+6
          lda # >(bmp_gameselect_CHAR3)
          sta scorePointers+7

          lda # >(font_gameselect_img)
          sta scorePointers+9

          lda # >(font_gameselect_img)
          sta scorePointers+11

          jmp draw_bmp_48x1_X
.pend
