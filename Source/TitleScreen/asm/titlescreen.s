
 include "TitleScreen/asm/layoutmacros.s"
 include "TitleScreen/titlescreen_layout.s"

titledrawscreen
title_eat_overscan
 	;bB runs in overscan. Wait for the overscan to run out...
	clc
	lda INTIM
	bmi title_eat_overscan
	jmp title_do_vertical_sync

title_do_vertical_sync
	lda #2
	sta WSYNC ;one line with VSYNC
	sta VSYNC ;enable VSYNC
	sta WSYNC ;one line with VSYNC
	sta WSYNC ;one line with VSYNC
	lda #0
	sta WSYNC ;one line with VSYNC
	sta VSYNC ;turn off VSYNC

        ;lda #42+128
	ifnconst vblank_time
 	lda #42+128
 	else
 	lda #vblank_time+128
 	endif

	sta TIM64T

titleframe = missile0x
        inc titleframe ; increment the frame counter

	ifconst .title_vblank
	jsr .title_vblank
	endif

title_vblank_loop
	lda INTIM
	bmi title_vblank_loop
	lda #0
	sta WSYNC
	sta VBLANK
	sta ENAM0
	sta ENABL

title_playfield

; ======== BEGIN of the custom kernel!!!!! All of the work is done in the playfield.

        lda #230
        sta TIM64T

	lda #1
	sta CTRLPF
	clc

	lda #0
        sta REFP0
        sta REFP1
	sta WSYNC
	lda titlescreencolor
	sta COLUBK

	titlescreenlayout

	jmp PFWAIT ; kernel is done. Finish off the screen

 include "TitleScreen/asm/position48.s"
 include "TitleScreen/titlescreen_color.s"

	; Unused 48x1 kernels removed - only 48x2_1, 48x2_2, 48x2_3 are used

	; Include all title screen kernels unconditionally
	include "TitleScreen/asm/48x2_1_kernel.s"
	include "TitleScreen/asm/48x2_2_kernel.s"
	include "TitleScreen/asm/48x2_3_kernel.s"
	include "TitleScreen/asm/48x2_4_kernel.s"

	; Unused minikernels removed: 48x2_5-8, 48x1_*, 96x2_* - 48x2_1, 48x2_2, 48x2_3, 48x2_4 are used

	ifconst mk_score_on
		include "TitleScreen/asm/score_kernel.s"
	endif ;mk_score_on

	ifconst mk_gameselect_on
		include "TitleScreen/asm/gameselect_kernel.s"
	endif ;mk_gameselect_on

PFWAIT
        lda INTIM 
        bne PFWAIT
        sta WSYNC

OVERSCAN
 	ifnconst overscan_time
 	lda #34+128
 	else
 	lda #overscan_time+128-5
 	endif
	sta TIM64T

	;fix height variables we borrowed
	ifconst player9height
		ldy #8
		lda #0
		sta player0height
TitleScreenFixPlayerHeights:
.playerheightfixloop
		sta player1height,y
		ifconst _NUSIZ1
			sta _NUSIZ1,y
		endif
		dey
		bpl .playerheightfixloop
	endif

	lda #%11000010
	sta WSYNC
	sta VBLANK
	RETURN

	; Unused image files removed: 48x1_*, 48x2_5-8, 96x2_* - 48x2_1, 48x2_2, 48x2_3, 48x2_4 are used
	; Note: Bitmap image data is now included from generated Art.*.s files in Bank1.bas
	; The TitleScreen/48x2_N_image.s files are NOT included here to avoid duplicate definitions
	; ifconst mk_48x2_1_on
	;	include "TitleScreen/48x2_1_image.s"
	; endif
	; ifconst mk_48x2_2_on
	;	include "TitleScreen/48x2_2_image.s"
	; endif
	; ifconst mk_48x2_3_on
	;	include "TitleScreen/48x2_3_image.s"
	; endif
	; ifconst mk_48x2_4_on
	;	include "TitleScreen/48x2_4_image.s"
	; endif

	ifconst mk_player_on
		include "TitleScreen/player_image.s"
	endif

	ifconst mk_score_on
		include "TitleScreen/score_image.s"
	endif

	ifconst mk_gameselect_on
		include "TitleScreen/gameselect_image.s"
	endif

	ifconst mk_player_on
		include "TitleScreen/asm/player_kernel.s"
	endif ;mk_player_on



	RETURN
