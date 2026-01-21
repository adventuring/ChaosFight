
draw_bmp_48x2_2:
          ;; Early exit if window is 0 (bitmap disabled)
          .if ! titlescreenWindow2
          ldy # bmp_48x2_2_window
          beq draw_bmp_48x2_2_done
          .else
          ldy titlescreenWindow2
          beq draw_bmp_48x2_2_done
          .fi
          
          ;; Clear PF0 to prevent garbage when this bitmap is active
          ;; (PF1 and PF2 are set below, but PF0 is never set by bitmaps)
          lda # 0
          sta PF0

          lda # <(bmp_48x2_2_colors-1+bmp_48x2_2_height-bmp_48x2_2_window)
          .if  bmp_48x2_2_index
          sec
          sbc bmp_48x2_2_index
          .fi
          sta aux5+0
          lda # >(bmp_48x2_2_colors-1+bmp_48x2_2_height-bmp_48x2_2_window)
          sta aux5+1

          ldy # 11
bmp_48x2_2_pointersetup:
          lda bmp_48x2_2_values,y
          sta scorePointers,y
          dey
          lda bmp_48x2_2_values,y
          .if  bmp_48x2_2_index
          sec
          sbc bmp_48x2_2_index
          .fi
          sta scorePointers,y
          dey
          bpl bmp_48x2_2_pointersetup


	;; Use runtime window variable if available, otherwise fallback to compile-time consta

          .if ! titlescreenWindow2
          ldy # (bmp_48x2_2_window-1)
          .else
          ldy titlescreenWindow2
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

          .if  bmp_48x2_2_background
          lda bmp_48x2_2_background
          .else
          lda titlescreencolor
          .fi
          sta aux4
          .if  bmp_48x2_2_PF1
          lda bmp_48x2_2_PF1
          .else
          lda # 0
          nop
          .fi
          sta PF1

          .if  bmp_48x2_2_PF2
          lda bmp_48x2_2_PF2
          .else
          lda # 0
          nop
          .fi
          sta PF2

          jmp draw_bmp_48x2_X

draw_bmp_48x2_2_done:
          rts

bmp_48x2_2_values:
          .word (bmp_48x2_2_00+bmp_48x2_2_height-bmp_48x2_2_window)
          .word (bmp_48x2_2_01+bmp_48x2_2_height-bmp_48x2_2_window)
          .word (bmp_48x2_2_02+bmp_48x2_2_height-bmp_48x2_2_window)
          .word (bmp_48x2_2_03+bmp_48x2_2_height-bmp_48x2_2_window)
          .word (bmp_48x2_2_04+bmp_48x2_2_height-bmp_48x2_2_window)
          .word (bmp_48x2_2_05+bmp_48x2_2_height-bmp_48x2_2_window)

