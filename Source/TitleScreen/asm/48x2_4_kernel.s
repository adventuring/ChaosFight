
draw_bmp_48x2_4:
          ;; Early exit if window is 0 (bitmap disabled)
          .if ! titlescreenWindow4
          ldy # bmp_48x2_4_window
          beq draw_bmp_48x2_4_done
          .else
          ;; ldy titlescreenWindow4 (duplicate)
          ;; beq draw_bmp_48x2_4_done (duplicate)
          .fi

          lda # <(bmp_48x2_4_colors-1+bmp_48x2_4_height-bmp_48x2_4_window)
          .if  bmp_48x2_4_index
          sec
          sbc bmp_48x2_4_index
          .fi
          sta aux5+0
          ;; lda # >(bmp_48x2_4_colors-1+bmp_48x2_4_height-bmp_48x2_4_window) (duplicate)
          ;; sta aux5+1 (duplicate)

          ;; ldy # 11 (duplicate)
bmp_48x2_4_pointersetup:
          ;; lda bmp_48x2_4_values,y (duplicate)
          ;; sta scorepointers,y (duplicate)
          dey
          ;; lda bmp_48x2_4_values,y (duplicate)
          .if  bmp_48x2_4_index
          ;; sec (duplicate)
          ;; sbc bmp_48x2_4_index (duplicate)
          .fi
          ;; sta scorepointers,y (duplicate)
          ;; dey (duplicate)
          bpl bmp_48x2_4_pointersetup


	;; Use runtime window variable if available, otherwise fallback to compile-time consta

          .if ! titlescreenWindow4
          ;; ldy # (bmp_48x2_4_window-1) (duplicate)
          .else
          ;; ldy titlescreenWindow4 (duplicate)
          ;; dey (duplicate)
          .fi
          sty aux2

          iny
          ;; lda (aux5),y (duplicate)
          ;; dey (duplicate)

          ;; sta COLUP0              ;;;3 (duplicate)
          ;; sta COLUP1              ;;;3 (duplicate)
          ;; sta HMCLR               ;;;3 (duplicate)

          ;; lda titlescreencolor (duplicate)
          ;; sta COLUPF (duplicate)

          .if  bmp_48x2_4_background
          ;; lda bmp_48x2_4_background (duplicate)
          .else
          ;; lda titlescreencolor (duplicate)
          .fi
          ;; sta aux4 (duplicate)
          .if  bmp_48x2_4_PF1
          ;; lda bmp_48x2_4_PF1 (duplicate)
          .else
          ;; lda # 0 (duplicate)
          nop
          .fi
          ;; sta PF1 (duplicate)

          .if  bmp_48x2_4_PF2
          ;; lda bmp_48x2_4_PF2 (duplicate)
          .else
          ;; lda # 0 (duplicate)
          ;; nop (duplicate)
          .fi
          ;; sta PF2 (duplicate)

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

