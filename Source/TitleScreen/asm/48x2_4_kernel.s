
draw_bmp_48x2_4:
          ;; Early exit if window is 0 (bitmap disabled)
          .if ! titlescreenWindow4
          ldy # bmp_48x2_4_window
          beq draw_bmp_48x2_4_done
          .else
          ldy titlescreenWindow4
          beq draw_bmp_48x2_4_done
          .fi

          lda # <(bmp_48x2_4_colors-1+bmp_48x2_4_height-bmp_48x2_4_window)
          .if  bmp_48x2_4_index
          sec
          sbc bmp_48x2_4_index
          .fi
          sta aux5+0
          lda # >(bmp_48x2_4_colors-1+bmp_48x2_4_height-bmp_48x2_4_window)
          sta aux5+1

          ldy # 11
bmp_48x2_4_pointersetup:
          lda bmp_48x2_4_values,y
          sta scorePointers,y
          dey
          lda bmp_48x2_4_values,y
          .if  bmp_48x2_4_index
          sec
          sbc bmp_48x2_4_index
          .fi
          sta scorePointers,y
          dey
          bpl bmp_48x2_4_pointersetup


	;; Use runtime window variable if available, otherwise fallback to compile-time consta

          .if ! titlescreenWindow4
          ldy # (bmp_48x2_4_window-1)
          .else
          ldy titlescreenWindow4
          dey
          .fi
          sty aux2

          iny
          lda (aux5),y
          dey

          sta COLUP0              ;;;3
          sta COLUP1              ;;;3
          sta HMCLR               ;;;3

          lda titlescreencolor
          sta COLUPF

          .if  bmp_48x2_4_background
          lda bmp_48x2_4_background
          .else
          lda titlescreencolor
          .fi
          sta aux4
          .if  bmp_48x2_4_PF1
          lda bmp_48x2_4_PF1
          .else
          lda # 0
          nop
          .fi
          sta PF1

          .if  bmp_48x2_4_PF2
          lda bmp_48x2_4_PF2
          .else
          lda # 0
          nop
          .fi
          sta PF2

          jmp draw_bmp_48x2_X

draw_bmp_48x2_4_done:
          rts

bmp_48x2_4_values:
          .word (bmp_48x2_4_00+bmp_48x2_4_height-bmp_48x2_4_window)
          .word (bmp_48x2_4_01+bmp_48x2_4_height-bmp_48x2_4_window)
          .word (bmp_48x2_4_02+bmp_48x2_4_height-bmp_48x2_4_window)
          .word (bmp_48x2_4_03+bmp_48x2_4_height-bmp_48x2_4_window)
          .word (bmp_48x2_4_04+bmp_48x2_4_height-bmp_48x2_4_window)
          .word (bmp_48x2_4_05+bmp_48x2_4_height-bmp_48x2_4_window)

