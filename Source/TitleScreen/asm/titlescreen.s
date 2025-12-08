
.include "TitleScreen/asm/layoutmacros.s"
;; titlescreen_layout.s macro expanded inline below (line 85-88) - .include removed to avoid macro definition processing

;; Optional bitmap index offsets - data (.byte 0) moved to Bank9.bas data segment
;; Symbol definitions only (no data) - these are compile-time consta

bmp_48x2_1_index = bmp_48x2_1_index_value
bmp_48x2_2_index = bmp_48x2_2_index_value
bmp_48x2_3_index = bmp_48x2_3_index_value
bmp_48x2_4_index = bmp_48x2_4_index_value
scorefade_1:= 0
score_kernel_fade = 0

titledrawscreen:
title_eat_overscan:
 	;;bB runs in overscan. Wait for the overscan to run out...
	clc
          lda INTIM
          bmi title_eat_overscan
          ;; Fall through to title_do_vertical_sync (no alignment needed)
          
title_do_vertical_sync:
          ;; lda # 2 (duplicate)
          sta WSYNC ;;;one line with VSYNC
          ;; sta VSYNC ;;;enable VSYNC (duplicate)
          ;; sta WSYNC ;;;one line with VSYNC (duplicate)
          ;; sta WSYNC ;;;one line with VSYNC (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta WSYNC ;;;one line with VSYNC (duplicate)
          ;; sta VSYNC ;;;turn off VSYNC (duplicate)

          ;; VBLANK: Use Reference cycle-exact timing
          .if ! vblank_time
          .if TVStandard == 1
          ;; lda # 42+128 (duplicate)
          ;; sta TIM64T (duplicate)
          .else
          .if TVStandard == 2
          ;; lda # 42+128 (duplicate)
          ;; sta TIM64T (duplicate)
          .else
          ;; lda # 37+128 (duplicate)
          ;; sta TIM64T (duplicate)
          .fi
          .fi
          .else
          ;; lda # vblank_time+128 (duplicate)
          ;; sta TIM64T (duplicate)
          .fi

titleframe = missile0x
          inc titleframe ;;; increment the frame counter

	;; Removed unused .title_vblank conditional

title_vblank_loop:
          ;; lda INTIM (duplicate)
          ;; bmi title_vblank_loop (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta VBLANK (duplicate)
          ;; sta ENAM0 (duplicate)
          ;; sta ENABL (duplicate)

title_playfield:

;; ======== BEGIN of the custom kernel!!!!! All of the work is done in the playfield.

          ;; lda # 230 (duplicate)
          ;; sta TIM64T (duplicate)

          ;; lda # 1 (duplicate)
          ;; sta CTRLPF (duplicate)
          ;; clc (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta REFP0 (duplicate)
          ;; sta REFP1 (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta COLUBK (duplicate)
          ;; Clear playfield to prevent garbage display
          ;; sta PF0 (duplicate)
          ;; sta PF1 (duplicate)
          ;; sta PF2 (duplicate)

;; Manually expanded titlescreenlayout macro (labels must be column aligned)
;; For 48×42 bitmaps using ×2 drawing style (double-height mode)
;; Each bitmap row is displayed as 2 scanlines: 42 rows → 84 scanlines on screen
;; Three admin screens use four minikernel slots:
;;   - 48x2_1: AtariAge logo bitmap
;;   - 48x2_2: AtariAge text bitmap
;;   - 48x2_3: ChaosFight title bitmap
;;   - 48x2_4: BRP signature bitmap (Author screen)
;; Publisher screen: Shows 48x2_1 (logo) + 48x2_2 (text) - both window=42
;; Author screen: Shows only 48x2_4 (BRP) - window=42
;; Title screen: Shows only 48x2_3 (ChaosFight) - window=42
;; Each screen activates only its minikernel by setting height/window = 0 for others
draw_48x2_1_1:

draw_48x2_2_1:

draw_48x2_3_1:

draw_48x2_4_1:


          jmp PFWAIT ;;; kernel is done. Finish off the screen

          .include "TitleScreen/asm/position48.s"
          .include "TitleScreen/titlescreen_color.s"
          ;; titlescreen_colors.s is now included in Bank9.bas after bitmap data,
          ;;   not here, to avoid origin reverse-indexed errors

	;; Unused 48x1 kernels removed - only 48x2 bitmaps are active

	;; Load per-bitmap pointer tables and wrappers
          .include "TitleScreen/asm/48x2_1_kernel.s"
          .include "TitleScreen/asm/48x2_2_kernel.s"
          .include "TitleScreen/asm/48x2_3_kernel.s"
          .include "TitleScreen/asm/48x2_4_kernel.s"

          .include "TitleScreen/asm/draw_bmp_48x2_X.s"

	;; Unused minikernels removed: 48x2_5-8, 48x1_*, 96x2_* - 48x2_1, 48x2_2, 48x2_3, 48x2_4 are used

          .if  mk_score_on
.include "TitleScreen/asm/score_kernel.s"
          .fi ;;;mk_score_on

	;; Gameselect minikernel removed - not used (mk_gameselect_on = 0)
	;; Gameselect symbols defined as stubs to avoid unresolved symbol errors
	;; These are referenced by batariBASIC compiler output but never used
bmp_gameselect_color:
          .byte $00
bmp_gameselect_CHAR0:
          .byte $00, $00, $00, $00, $00
bmp_gameselect_CHAR1:
          .byte $00, $00, $00, $00, $00
bmp_gameselect_CHAR2:
          .byte $00, $00, $00, $00, $00
bmp_gameselect_CHAR3:
          .byte $00, $00, $00, $00, $00
font_gameselect_img:
          .byte $00
gamenumber_ts:
gamenumber_titlescreen:
          .byte $00

PFWAIT:
          ;; lda INTIM (duplicate)
          bne PFWAIT
          ;; sta WSYNC (duplicate)

OVERSCAN:
          ;; Overscan: Use Reference cycle-exact timing
          .if ! overscan_time
          .if TVStandard == 1
          ;; lda # 34+128 (duplicate)
          ;; sta TIM64T (duplicate)
          .else
          .if TVStandard == 2
          ;; lda # 34+128 (duplicate)
          ;; sta TIM64T (duplicate)
          .else
          ;; lda # 30+128 (duplicate)
          ;; sta TIM64T (duplicate)
          .fi
          .fi
          .else
          ;; lda # overscan_time+128-5 (duplicate)
          ;; sta TIM64T (duplicate)
          .fi

	;;fix height variables we borrowed
          .if  player9height
          ldy # 8
          ;; lda # 0 (duplicate)
          ;; sta player0height (duplicate)
TitleScreenFixPlayerHeights:
playerheightfixloop:
          ;; sta player1height,y (duplicate)
          ;; .if _NUSIZ1 != 0  ;;; Commented out - code inside is duplicate
          dey
          bpl playerheightfixloop
          ;; .fi  ;;; Commented out
          .fi  ;;; Close .if player9height

          ;; lda # %11000010 (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta VBLANK (duplicate)
          rts

	;; Unused image files removed: 48x1_*, 48x2_5-8, 96x2_* - 48x2_1, 48x2_2, 48x2_3, 48x2_4 are used
	;; Bitmap image data is included from generated Art.*.s files in Bank8
	;; The TitleScreen/48x2_N_image.s files are NOT included here to avoid duplicate definitions
	;; .if  mk_48x2_1_on
	;;	.include "TitleScreen/48x2_1_image.s"
	;; .fi
	;; .if  mk_48x2_2_on
	;;	.include "TitleScreen/48x2_2_image.s"
	;; .fi
	;; .if  mk_48x2_3_on
	;;	.include "TitleScreen/48x2_3_image.s"
	;; .fi
	;; .if  mk_48x2_4_on
	;;	.include "TitleScreen/48x2_4_image.s"
	;; .fi

	;; Removed unused player, score, and gameselect minikernels

          ;; rts (duplicate)
