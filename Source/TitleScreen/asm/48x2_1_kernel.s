
draw_bmp_48x2_1:
          ;; Runtime check: exit if window variable at $B8 is 0
          ldy titlescreenWindow1
          beq draw_bmp_48x2_1_done
          sty aux2           ;;; NO dey - color index = aux2 (not aux2-1)
          lda # <(bmp_48x2_1_colors+bmp_48x2_1_height-bmp_48x2_1_window)
          sta aux5+0
          lda # >(bmp_48x2_1_colors+bmp_48x2_1_height-bmp_48x2_1_window)
          sta aux5+1

          ldy # 11
bmp_48x2_1_pointersetup:
          lda bmp_48x2_1_values,y
          sta scorePointers,y
          dey
          lda bmp_48x2_1_values,y
          sta scorePointers,y
          dey
          bpl bmp_48x2_1_pointersetup

          ldy aux2
          lda (aux5),y
          sta COLUP0              ;;;3
          sta COLUP1              ;;;3
          sta HMCLR               ;;;3

          lda titlescreencolor
          sta COLUPF

          ;; NOTE: bB wrote bmp_48x2_1_background/titlescreencolor to
          ;; aux4 here, but nothing in the adapted 48x2 kernel ever
          ;; reads aux4 (the canonical kernel's per-row `lda aux4 /
          ;; sta COLUPF` was dropped when the runtime windows were
          ;; added).  The store was therefore dead - and harmful, as
          ;; aux4 ($C0) is preambleTimer in the prelude screens, so it
          ;; reset the prelude timer to titlescreencolor (=0) every
          ;; frame and the preludes could never auto-advance.
          ;; The following WSYNC in position48 absorbs the 8 cycles.
          .if  bmp_48x2_1_PF1
          lda bmp_48x2_1_PF1
          .else
          lda # 0
          nop
          .fi
          sta PF1

          .if  bmp_48x2_1_PF2
          lda bmp_48x2_1_PF2
          .else
          lda # 0
          nop
          .fi
          sta PF2

          jmp draw_bmp_48x2_X

draw_bmp_48x2_1_done:
          rts

bmp_48x2_1_values:
          .word (bmp_48x2_1_00+bmp_48x2_1_height-bmp_48x2_1_window)
          .word (bmp_48x2_1_01+bmp_48x2_1_height-bmp_48x2_1_window)
          .word (bmp_48x2_1_02+bmp_48x2_1_height-bmp_48x2_1_window)
          .word (bmp_48x2_1_03+bmp_48x2_1_height-bmp_48x2_1_window)
          .word (bmp_48x2_1_04+bmp_48x2_1_height-bmp_48x2_1_window)
          .word (bmp_48x2_1_05+bmp_48x2_1_height-bmp_48x2_1_window)

