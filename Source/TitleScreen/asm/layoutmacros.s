;;;; the macro's used in the "titlescreen_layout.s" file

draw_96x2_1 .macro
          mk_96x2_1_on = 1
          jsr draw_bmp_96x2_1
          .endm

draw_96x2_2 .macro
          mk_96x2_2_on = 1
          ;; jsr draw_bmp_96x2_2 (duplicate)
          .endm

draw_96x2_3 .macro
          mk_96x2_3_on = 1
          ;; jsr draw_bmp_96x2_3 (duplicate)
          .endm

draw_96x2_4 .macro
          mk_96x2_4_on = 1
          ;; jsr draw_bmp_96x2_4 (duplicate)
          .endm

draw_96x2_5 .macro
          mk_96x2_5_on = 1
          ;; jsr draw_bmp_96x2_5 (duplicate)
          .endm

draw_96x2_6 .macro
          mk_96x2_6_on = 1
          ;; jsr draw_bmp_96x2_6 (duplicate)
          .endm

draw_96x2_7 .macro
          mk_96x2_7_on = 1
          ;; jsr draw_bmp_96x2_7 (duplicate)
          .endm

draw_96x2_8 .macro
          mk_96x2_8_on = 1
          ;; jsr draw_bmp_96x2_8 (duplicate)
          .endm

draw_48x1_1 .macro
          mk_48x1_X_on = 1
          mk_48x1_1_on = 1
          ;; jsr draw_bmp_48x1_1 (duplicate)
          .endm

draw_48x1_2 .macro
          ;; mk_48x1_X_on = 1 (duplicate)
          mk_48x1_2_on = 1
          ;; jsr draw_bmp_48x1_2 (duplicate)
          .endm

draw_48x1_3 .macro
          ;; mk_48x1_X_on = 1 (duplicate)
          mk_48x1_3_on = 1
          ;; jsr draw_bmp_48x1_3 (duplicate)
          .endm

draw_48x1_4 .macro
          ;; mk_48x1_X_on = 1 (duplicate)
          mk_48x1_4_on = 1
          ;; jsr draw_bmp_48x1_4 (duplicate)
          .endm

draw_48x1_5 .macro
          ;; mk_48x1_X_on = 1 (duplicate)
          mk_48x1_5_on = 1
          ;; jsr draw_bmp_48x1_5 (duplicate)
          .endm

draw_48x1_6 .macro
          ;; mk_48x1_X_on = 1 (duplicate)
          mk_48x1_6_on = 1
          ;; jsr draw_bmp_48x1_6 (duplicate)
          .endm

draw_48x1_7 .macro
          ;; mk_48x1_X_on = 1 (duplicate)
          mk_48x1_7_on = 1
          ;; jsr draw_bmp_48x1_7 (duplicate)
          .endm

draw_48x1_8 .macro
          ;; mk_48x1_X_on = 1 (duplicate)
          mk_48x1_8_on = 1
          ;; jsr draw_bmp_48x1_8 (duplicate)
          .endm


draw_48x2_1 .macro
          mk_48x2_X_on = 1
          mk_48x2_1_on = 1
          ;; jsr draw_bmp_48x2_1 (duplicate)
          .endm

draw_48x2_2 .macro
          ;; mk_48x2_X_on = 1 (duplicate)
          mk_48x2_2_on = 1
          ;; jsr draw_bmp_48x2_2 (duplicate)
          .endm

draw_48x2_3 .macro
          ;; mk_48x2_X_on = 1 (duplicate)
          mk_48x2_3_on = 1
          ;; jsr draw_bmp_48x2_3 (duplicate)
          .endm

draw_48x2_4 .macro
          ;; mk_48x2_X_on = 1 (duplicate)
          mk_48x2_4_on = 1
          ;; jsr draw_bmp_48x2_4 (duplicate)
          .endm

draw_48x2_5 .macro
          ;; mk_48x2_X_on = 1 (duplicate)
          mk_48x2_5_on = 1
          ;; jsr draw_bmp_48x2_5 (duplicate)
          .endm

draw_48x2_6 .macro
          ;; mk_48x2_X_on = 1 (duplicate)
          mk_48x2_6_on = 1
          ;; jsr draw_bmp_48x2_6 (duplicate)
          .endm

draw_48x2_7 .macro
          ;; mk_48x2_X_on = 1 (duplicate)
          mk_48x2_7_on = 1
          ;; jsr draw_bmp_48x2_7 (duplicate)
          .endm

draw_48x2_8 .macro
          ;; mk_48x2_X_on = 1 (duplicate)
          mk_48x2_8_on = 1
          ;; jsr draw_bmp_48x2_8 (duplicate)
          .endm

draw_player .macro
          mk_player_on = 1
          ;; jsr draw_player_display (duplicate)
          .endm

draw_score .macro
          mk_score_on = 1
          ;; mk_48x1_X_on = 1 (duplicate)
          ;; jsr draw_score_display (duplicate)
          .endm

draw_gameselect .macro
          mk_gameselect_on = 1
          ;; mk_48x1_X_on = 1 (duplicate)
          ;; jsr draw_gameselect_display (duplicate)
          .endm

draw_space .macro lines
          ldy # \lines
.loop:
          sta WSYNC
          dey
          bne loop
          .endm
