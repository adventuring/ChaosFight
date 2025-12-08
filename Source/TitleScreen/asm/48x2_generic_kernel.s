;;;; Generic 48x2 bitmap kernel that handles all 4 bitmap sets
;;;; For backwards compatibility, draw_bmp_48x2_3 defaults to ChaosFight (index 3)

draw_bmp_48x2_3:
	;; Hardcoded to ChaosFight bitmap (index 3)
          lda # <(bmp_48x2_3_colors-1+bmp_48x2_3_height-bmp_48x2_3_window)
          sta aux5+0
          ;; lda # >(bmp_48x2_3_colors-1+bmp_48x2_3_height-bmp_48x2_3_window) (duplicate)
          ;; sta aux5+1 (duplicate)

          ldy # 11
bmp_48x2_3_pointersetup:
          ;; lda bmp_48x2_3_values,y (duplicate)
          ;; sta scorepointers,y (duplicate)
          dey
          ;; lda bmp_48x2_3_values,y (duplicate)
          ;; sta scorepointers,y (duplicate)
          ;; dey (duplicate)
          bpl bmp_48x2_3_pointersetup

	;; Use runtime window variable
          .if ! titlescreenWindow3
          ;; ldy # (bmp_48x2_3_window-1) (duplicate)
          .else
          ;; ldy titlescreenWindow3 (duplicate)
          ;; dey (duplicate)
          .fi
          sty aux2

          iny
          ;; lda (aux5),y (duplicate)
          ;; dey (duplicate)

          ;; sta COLUP0 (duplicate)
          ;; sta COLUP1 (duplicate)
          ;; sta HMCLR (duplicate)

          ;; lda titlescreencolor (duplicate)
          ;; sta COLUPF (duplicate)

          ;; lda titlescreencolor (duplicate)
          ;; sta aux4 (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta PF1 (duplicate)
          ;; sta PF2 (duplicate)

          jmp draw_bmp_48x2_X
