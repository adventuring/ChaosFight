
draw_bmp_48x2_4:
          ;; Early exit if window is 0 (bitmap disabled)
          .if ! titlescreenWindow4
          ldy # bmp_48x2_4_window
          beq draw_bmp_48x2_4_done
          .else
          ldy titlescreenWindow4
          beq draw_bmp_48x2_4_done
          dey
          sty aux2
          lda # <(bmp_48x2_4_colors-1+bmp_48x2_4_height-bmp_48x2_4_window)
          sta aux5+0
          lda # >(bmp_48x2_4_colors-1+bmp_48x2_4_height-bmp_48x2_4_window)
          sta aux5+1

          ldy # 11
bmp_48x2_4_pointersetup:
          lda bmp_48x2_4_values,y
          sta scorePointers,y
          dey
          lda bmp_48x2_4_values,y
          sta scorePointers,y
          dey
          bpl bmp_48x2_4_pointersetup

          ldy aux2
          lda (aux5),y
          .fi
          sta COLUP0              ;;;3
          sta COLUP1              ;;;3
          sta HMCLR               ;;;3

          lda titlescreencolor
          sta COLUPF

          ;; NOTE: bB wrote bmp_48x2_4_background/titlescreencolor to
          ;; aux4 here, but nothing in the adapted 48x2 kernel ever
          ;; reads aux4 (the canonical kernel's per-row `lda aux4 /
          ;; sta COLUPF` was dropped when the runtime windows were
          ;; added).  The store was therefore dead - and harmful, as
          ;; aux4 ($C0) is preambleTimer in the prelude screens, so it
          ;; reset the prelude timer to titlescreencolor (=0) every
          ;; frame and the preludes could never auto-advance.
          ;; The following WSYNC in position48 absorbs the 8 cycles.
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

