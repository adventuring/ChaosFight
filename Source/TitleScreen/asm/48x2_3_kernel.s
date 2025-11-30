
draw_bmp_48x2_3
          ; Early exit if window is 0 (bitmap disabled)
          ifnconst titlescreenWindow3
          ldy #bmp_48x2_3_window
          beq draw_bmp_48x2_3_done
          else
          ldy titlescreenWindow3
          beq draw_bmp_48x2_3_done
          endif

          lda #<(bmp_48x2_3_colors-1+bmp_48x2_3_height-bmp_48x2_3_window)
          ifconst bmp_48x2_3_index
          sec
          sbc bmp_48x2_3_index
          endif
          sta aux5+0
          lda #>(bmp_48x2_3_colors-1+bmp_48x2_3_height-bmp_48x2_3_window)
          sta aux5+1

          ldy #11
bmp_48x2_3_pointersetup
          lda bmp_48x2_3_values,y
          sta scorepointers,y
          dey
          lda bmp_48x2_3_values,y
          ifconst bmp_48x2_3_index
          sec
          sbc bmp_48x2_3_index
          endif
          sta scorepointers,y
          dey
          bpl bmp_48x2_3_pointersetup


	; Use runtime window variable if available, otherwise fallback to compile-time constant
          ifnconst titlescreenWindow3
          ldy #(bmp_48x2_3_window-1)
          else
          ldy titlescreenWindow3
          dey
          endif
          sty aux2

          iny
          lda (aux5),y
          dey

          sta COLUP0              ;3
          sta COLUP1              ;3
          sta HMCLR               ;3

          lda titlescreencolor
          sta COLUPF

          ifconst bmp_48x2_3_background
          lda bmp_48x2_3_background
          else
          lda titlescreencolor
          endif
          sta aux4
          ifconst bmp_48x2_3_PF1
          lda bmp_48x2_3_PF1
          else
          lda #0
          nop
          endif
          sta PF1

          ifconst bmp_48x2_3_PF2
          lda bmp_48x2_3_PF2
          else
          lda #0
          nop
          endif
          sta PF2

          jmp draw_bmp_48x2_X

draw_bmp_48x2_3_done
          rts

bmp_48x2_3_values
          .word (bmp_48x2_3_00+#bmp_48x2_3_height-#bmp_48x2_3_window)
          .word (bmp_48x2_3_01+#bmp_48x2_3_height-#bmp_48x2_3_window)
          .word (bmp_48x2_3_02+#bmp_48x2_3_height-#bmp_48x2_3_window)
          .word (bmp_48x2_3_03+#bmp_48x2_3_height-#bmp_48x2_3_window)
          .word (bmp_48x2_3_04+#bmp_48x2_3_height-#bmp_48x2_3_window)
          .word (bmp_48x2_3_05+#bmp_48x2_3_height-#bmp_48x2_3_window)

