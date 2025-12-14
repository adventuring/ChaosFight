
;; CRITICAL: Preamble.s is already included by platform files (NTSC.s/PAL.s/SECAM.s)
;; Do NOT include it here to prevent duplicate definitions
;; .include "../../Source/Common/Preamble.s"

.include "TitleScreen/asm/layoutmacros.s"

;; Optional bitmap index offsets - data (.byte 0) moved to Bank9.bas data segment
;; Symbol definitions only (no data) - these are compile-time consta

bmp_48x2_1_index = bmp_48x2_1_index_value
bmp_48x2_2_index = bmp_48x2_2_index_value
bmp_48x2_3_index = bmp_48x2_3_index_value
bmp_48x2_4_index = bmp_48x2_4_index_value
scorefade_1:= 0
scoreKernelFade = 0

titledrawscreen:
title_eat_overscan:
 	;;bB runs in overscan. Wait for the overscan to run out...
	clc
          lda INTIM
          bmi title_eat_overscan
          ;; Fall through to title_do_vertical_sync (no alignment needed)
          
title_do_vertical_sync:
          lda # 2
          sta WSYNC ;;;one line with VSYNC
          sta VSYNC ;;;enable VSYNC
          sta WSYNC ;;;one line with VSYNC
          sta WSYNC ;;;one line with VSYNC
          lda # 0
          sta WSYNC ;;;one line with VSYNC
          sta VSYNC ;;;turn off VSYNC

          ;; VBLANK: Use Reference cycle-exact timing
          .if ! vblank_time
          .if TVStandard == PAL
          lda # 42+128
          sta TIM64T
          .else
          .if TVStandard == SECAM
          lda # 42+128
          sta TIM64T
          .else
          lda # 37+128
          sta TIM64T
          .fi
          .fi
          .else
          lda # vblank_time+128
          sta TIM64T
          .fi

titleframe = missile0x
          inc titleframe ;;; increment the frame counter


title_vblank_loop:
          lda INTIM
          bmi title_vblank_loop
          lda # 0
          sta WSYNC
          sta VBLANK
          sta ENAM0
          sta ENABL

title_playfield:

;; ======== BEGIN of the custom kernel!!!!! All of the work is done in the playfield.

          lda # 230
          sta TIM64T

          lda # 1
          sta CTRLPF
          clc

          lda # 0
          sta REFP0
          sta REFP1
          sta WSYNC
          sta COLUBK
          ;; Clear playfield to prevent garbage display
          sta PF0
          sta PF1
          sta PF2

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


	;; Load per-bitmap pointer tables and wrappers
          .include "TitleScreen/asm/48x2_1_kernel.s"
          .include "TitleScreen/asm/48x2_2_kernel.s"
          .include "TitleScreen/asm/48x2_3_kernel.s"
          .include "TitleScreen/asm/48x2_4_kernel.s"

          .include "TitleScreen/asm/draw_bmp_48x2_X.s"


          .if  mk_score_on
.include "TitleScreen/asm/score_kernel.s"
          .fi ;;;mk_score_on

	;; Gameselect minikernel removed - not used (mk_gameselect_on = 0)
	;; Gameselect symbols defined as stubs to avoid unresolved symbol errors
	;; These are referenced by batariBASIC compiler output but never used
bmpGameselectColor:
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
          lda INTIM
          bne PFWAIT
          sta WSYNC

OVERSCAN:
          ;; Overscan: Use Reference cycle-exact timing
          .if ! overscan_time
          .if TVStandard == PAL
          lda # 34+128
          sta TIM64T
          .else
          .if TVStandard == SECAM
          lda # 34+128
          sta TIM64T
          .else
          lda # 30+128
          sta TIM64T
          .fi
          .fi
          .else
          lda # overscan_time+128-5
          sta TIM64T
          .fi

	;;fix height variables we borrowed
          .if  player9height
          ldy # 8
          lda # 0
          sta player0Height
TitleScreenFixPlayerHeights:
playerheightfixloop:
          sta player1Height,y
          ;; .if _NUSIZ1 != 0  ;;; Commented out - code inside is duplicate
          dey
          bpl playerheightfixloop
          ;; .fi  ;;; Commented out
          .fi  ;;; Close .if player9height

          lda # %11000010
          sta WSYNC
          sta VBLANK
          rts

	;; Bitmap image data is included from generated Art.*.s files in Bank8
	;; The TitleScreen/48x2_N_image.s files are NOT included here to avoid duplicate definitions
	;; .if  mk_48x2_1_on
	;; .include "TitleScreen/48x2_1_image.s"
	;; .fi
	;; .if  mk_48x2_2_on
	;; .include "TitleScreen/48x2_2_image.s"
	;; .fi
	;; .if  mk_48x2_3_on
	;; .include "TitleScreen/48x2_3_image.s"
	;; .fi
	;; .if  mk_48x2_4_on
	;; .include "TitleScreen/48x2_4_image.s"
	;; .fi


          rts
