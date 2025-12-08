;;;; ChaosFight - Source/Common/MultiSpriteKernel.s
;;;; Copyright © 2025 Bruce-Robert Pocock.
;;;; Derived from Tools/batariBASIC/includes/multisprite_kernel.asm (CC0)

;;;;.error "Multi-sprite kernel starts at ", *

PFStart:
          .byte 87,43,0,21,0,0,0,10
          .if  screenheight
pfsub:
          .byte 8,4,2,2,1,0,0,1,0
          .fi
	;;--set initial P1 positions
multisprite_setup:
          lda # 15
          sta pfheight

          ldx # 4
;; stx temp3
SetCopyHeight:
;;	lda #76
;;	sta NewSpriteX,x
;;	lda CopyColorData,x
;;	sta NewCOLUP1,x
 ;;lda SpriteHeightTable,x
;; sta spriteheight,x
          txa
          ;; sta SpriteGfxIndex,x (duplicate)
          ;; sta spritesort,x (duplicate)
          dex
          bpl SetCopyHeight



;; since we cannot turn off pf, point PF to BlankPlayfield in Bank 16
          ;; lda # >BlankPlayfield (duplicate)
          ;; sta PF2pointer+1 (duplicate)
          ;; sta PF1pointer+1 (duplicate)
          ;; lda # <BlankPlayfield (duplicate)
          ;; sta PF2pointer (duplicate)
          ;; sta PF1pointer (duplicate)
          rts

drawscreen:
WaitForOverscanEnd:
          ;; lda INTIM (duplicate)
          bmi WaitForOverscanEnd

          ;; lda # 2 (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta VSYNC (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta WSYNC (duplicate)
          lsr
          ;; sta VDELBL (duplicate)
          ;; sta VDELP0 (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta VSYNC	;;;;turn off VSYNC (duplicate)
          .if  overscan_time
          ;; lda # overscan_time+5+128 (duplicate)
          .else
          ;; lda # 42+128 (duplicate)
          .fi
          ;; sta TIM64T (duplicate)

;; run possible vblank bB code
;; batariBASIC code will be placed at this label via vblank sta

;; The vblank code must return (return thisbank for bankswitching)
;; vblank_bB_code constant is defined in VblankHandlers.bas (or $0000 if not used)
;; MultiSpriteSuperChip.s sets it to $0000 if not defined, so we can always call it
          ;; lda vblank_bB_code (duplicate)
          ora vblank_bB_code + 1
          beq skip_vblank_call
          jsr vblank_bB_code
skip_vblank_call:

          ;; jsr setscorepointers (duplicate)
          ;; jsr SetupP1Subroutine (duplicate)

	;;-------------





	;;--position P0, M0, M1, BL

          ;; jsr PrePositionAllObjects (duplicate)

	;;--set up player 0 pointer

          dec player0y
          ;; lda player0pointer ;;;; player0: must be run every frame! (duplicate)
          sec
          sbc player0y
          clc
          adc player0height
          ;; sta player0pointer (duplicate)

          ;; lda player0y (duplicate)
          ;; sta P0Top (duplicate)
          ;; sec (duplicate)
          ;; sbc player0height (duplicate)
          ;; clc (duplicate)
          ;; adc #$80 (duplicate)
          ;; sta P0Bottom (duplicate)


	;;--some final setup

          ;; ldx # 4 (duplicate)
          ;; lda #$80 (duplicate)
cycle74_HMCLR:
          ;; sta HMP0,x (duplicate)
          ;; dex (duplicate)
          ;; bpl cycle74_HMCLR (duplicate)
;;	sta HMCLR


          ;; lda # 0 (duplicate)
          ;; sta PF1 (duplicate)
          ;; sta PF2 (duplicate)
          ;; sta GRP0 (duplicate)
          ;; sta GRP1 (duplicate)


          ;; jsr KernelSetupSubroutine (duplicate)

WaitForVblankEnd:
          ;; lda INTIM (duplicate)
          ;; bmi WaitForVblankEnd (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta WSYNC (duplicate)
          ;; sta VBLANK	;;;;turn off VBLANK - it was turned on by overscan (duplicate)
          ;; sta CXCLR (duplicate)


          jmp KernelRoutine


PositionASpriteSubroutine	;;;;call this function with A == horizontal position (0-159)
				;;and X == the object to be positioned (0= P0, 1= P1, 2= M0, etc.)
				;;if you do not wish to write to P1 during this function, make
				;;sure Y==0 before you call it.  This function will change Y, and A
				;;will be the value put into HMxx when returned.
				;;Call this function with at least 11 cycles left in the scanline 
				;;(jsr + sec + sta WSYNC = 11); it will return 9 cycles
				;;into the second scanline
          ;; sec (duplicate)
          ;; sta WSYNC			;;;;begin line 1 (duplicate)
          ;; sta HMCLR			;;;;+4	 4 (duplicate)
DivideBy15Loop:
          ;; sbc # 15 (duplicate)
          bcs DivideBy15Loop			;;;;+4/5	8/13.../58

          tay				;;;;+2	10/15/...60
          ;; lda FineAdjustTableEnd,y	;;;;+5	15/20/...65 (duplicate)

			;;	15
          ;; sta HMP0,x	;;;;+4	19/24/...69 (duplicate)
          ;; sta RESP0,x	;;;;+4	23/28/33/38/43/48/53/58/63/68/73 (duplicate)
          ;; sta WSYNC	;;;;+3	 0	begin line 2 (duplicate)
          ;; sta HMOVE	;;;;+3 (duplicate)
          ;; rts		;;;;+6	 9 (duplicate)

;;-------------------------------------------------------------------------

PrePositionAllObjects:

          ;; ldx # 4 (duplicate)
          ;; lda ballx (duplicate)
          ;; jsr PositionASpriteSubroutine (duplicate)

          ;; dex (duplicate)
          ;; lda missile1x (duplicate)
          ;; jsr PositionASpriteSubroutine (duplicate)

          ;; dex (duplicate)
          ;; lda missile0x (duplicate)
          ;; jsr PositionASpriteSubroutine (duplicate)

          ;; dex (duplicate)
          ;; dex (duplicate)
          ;; lda player0x (duplicate)
          ;; jsr PositionASpriteSubroutine (duplicate)

          ;; rts (duplicate)



;;-------------------------------------------------------------------------


KernelSetupSubroutine:

          ;; ldx # 4 (duplicate)
AdjustYValuesUpLoop:
          ;; lda NewSpriteY,x (duplicate)
          ;; clc (duplicate)
          ;; adc # 2 (duplicate)
          ;; sta NewSpriteY,x (duplicate)
          ;; dex (duplicate)
          ;; bpl AdjustYValuesUpLoop (duplicate)


          ;; ldx temp3 ;;;; first sprite displayed (duplicate)

          ;; lda SpriteGfxIndex,x (duplicate)
          ;; tay (duplicate)
          ;; lda NewSpriteY,y (duplicate)
          ;; sta RepoLine (duplicate)

          ;; lda SpriteGfxIndex-1,x (duplicate)
          ;; tay (duplicate)
          ;; lda NewSpriteY,y (duplicate)
          ;; sta temp6 (duplicate)

          stx SpriteIndex



          ;; lda # 255 (duplicate)
          ;; sta P1Bottom (duplicate)

          ;; lda player0y (duplicate)
          .if  screenheight
          cmp # screenheight+1
          .else
          ;; cmp #$59 (duplicate)
          .fi
          bcc nottoohigh
          ;; lda P0Bottom (duplicate)
          ;; sta P0Top (duplicate)



nottoohigh:
          ;; rts (duplicate)

;;-------------------------------------------------------------------------





;;*************************************************************************

;;-------------------------------------------------------------------------
;;-------------------------Data Below--------------------------------------
;;-------------------------------------------------------------------------

MaskTable:
          .byte 1,3,7,15,31

 ;; shove 6-digit score routine here

sixdigscore:
          ;; lda # 0 (duplicate)
;;	sta COLUBK
          ;; sta PF0 (duplicate)
          ;; sta PF1 (duplicate)
          ;; sta PF2 (duplicate)
          ;; sta ENABL (duplicate)
          ;; sta ENAM0 (duplicate)
          ;; sta ENAM1 (duplicate)
	;;end of kernel here


 ;; 6 digit score routine
;; lda #0
;; sta PF1
;; sta PF2
;; tax

          ;; sta WSYNC;;;;,x (duplicate)

;;                sta WSYNC ;first one, need one more
          ;; sta REFP0 (duplicate)
          ;; sta REFP1 (duplicate)
          ;; sta GRP0 (duplicate)
          ;; sta GRP1 (duplicate)
          ;; sta HMCLR (duplicate)

 ;; restore P0pointer

          ;; lda player0pointer (duplicate)
          ;; clc (duplicate)
          ;; adc player0y (duplicate)
          ;; sec (duplicate)
          ;; sbc player0height (duplicate)
          ;; sta player0pointer (duplicate)
          inc player0y

          .if  vblank_time
          .if  screenheight
          .if  screenheight == 84
          ;; lda  # vblank_time+9+128+10 (duplicate)
          .else
          ;; lda  # vblank_time+9+128+19 (duplicate)
          .fi
          .else
          ;; lda  # vblank_time+9+128 (duplicate)
          .fi
          .else
          .if  screenheight
          .if  screenheight == 84
          ;; lda  # 52+128+10 (duplicate)
          .else
          ;; lda  # 52+128+19 (duplicate)
          .fi
          .else
          ;; lda  # 52+128 (duplicate)
          .fi
          .fi

          ;; sta  TIM64T (duplicate)
          .if  minikernel
          ;; jsr minikernel (duplicate)
          .fi
          .if  noscore
          pla
          ;; pla (duplicate)
          ;; jmp skipscore (duplicate)
          .fi

;; score pointers contain:
;; score1-5: lo1,lo2,lo3,lo4,lo5,lo6
;; swap lo2->temp1
;; swap lo4->temp3
;; swap lo6->temp5

          ;; lda scorepointers+5 (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda scorepointers+1 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda scorepointers+3 (duplicate)
          ;; sta temp3 (duplicate)

          ;; lda # >SetFontNumbers (duplicate)
          ;; sta scorepointers+1 (duplicate)
          ;; sta scorepointers+3 (duplicate)
          ;; sta scorepointers+5 (duplicate)
          ;; sta temp2 (duplicate)
          ;; sta temp4 (duplicate)
          ;; sta temp6 (duplicate)

          ;; rts (duplicate)

;;------------------------------------------------------------------------
;;-- FineAdjustTable - HMove table
;;--
;;-- NOTE:  This table needs to be here to prevent interference with
;;--        the superchip due to the forced page-crossing used when
;;--        accessing this table.

FineAdjustTableBegin:
          .byte %01100000		;;;;left 6
          .byte %01010000
          .byte %01000000
          .byte %00110000
          .byte %00100000
          .byte %00010000
          .byte %00000000		;;;;left 0
          .byte %11110000
          .byte %11100000
          .byte %11010000
          .byte %11000000
          .byte %10110000
          .byte %10100000
          .byte %10010000
          .byte %10000000		;;;;right 8
FineAdjustTableEnd	=	FineAdjustTableBegin - 241

    ;;--- DEBUG: use the following .error statements to make sure page-crossing occurs
    ;;.error "FineAdjustTable at      ", FineAdjustTableBegin
    ;;.error " but is referenced from ", FineAdjustTableEnd

;;-------------------------------------------------------------------------
;;----------------------Kernel Routine-------------------------------------
;;-------------------------------------------------------------------------


;;-------------------------------------------------------------------------
;; .rept $f147-*
;; brk
;; .next
;;	org $F240

SwitchDrawP0K1				;;;;	72
          ;; lda P0Bottom (duplicate)
          ;; sta P0Top			;;;;+6	 2 (duplicate)
          ;; jmp BackFromSwitchDrawP0K1	;;;;+3	 5 (duplicate)

WaitDrawP0K1				;;;;	74
          .SLEEP 4				;;;;+4	 2
          ;; jmp BackFromSwitchDrawP0K1	;;;;+3	 5 (duplicate)

SkipDrawP1K1				;;;;	11
          ;; lda # 0 (duplicate)
          ;; sta GRP1			;;;;+5	16	so Ball gets drawn (duplicate)
          ;; jmp BackFromSkipDrawP1		;;;;+3	19 (duplicate)

;;-------------------------------------------------------------------------

KernelRoutine:
          .if ! screenheight
          .SLEEP 12
 ;; jsr wastetime ; waste 12 cycles
          .else
          .SLEEP 6
          .fi
          tsx
          ;; stx sta (duplicate)

          ;; ldx # ENABL (duplicate)
          txs			;;;;+9	 9

          ;; ldx # 0 (duplicate)
          ;; lda pfheight (duplicate)
          ;; bpl asdhj (duplicate)
          .byte $24
asdhj:
          tax

;; ldx pfheight
          ;; lda PFStart,x ;;;; get pf pixel resolution for heights 15,7,3,1,0 (duplicate)

          .if  screenheight
          ;; sec (duplicate)
          .if screenheight == 84
          ;; sbc pfsub+1,x (duplicate)
          .else
          ;; sbc pfsub,x (duplicate)
          .fi
          .fi

          ;; sta pfpixelheight (duplicate)

          .if  screenheight
          ldy # screenheight
          .else
          ;; ldy # 88 (duplicate)
          .fi

;;	lda #$02
;;	sta COLUBK		;+5	18

;; .SLEEP 25
          .SLEEP 2
KernelLoopa			;;;;	50
          .SLEEP 7			;;;;+4	54
KernelLoopb			;;;;	54
          .SLEEP 2		;;;;+12	66
          cpy P0Top		;;;;+3	69
          ;; beq SwitchDrawP0K1	;;;;+2	71 (duplicate)
          ;; bpl WaitDrawP0K1	;;;;+2	73 (duplicate)
          ;; lda (player0pointer),y	;;;;+5	 2 (duplicate)
          ;; sta GRP0		;;;;+3	 5	VDEL because of repokernel (duplicate)
BackFromSwitchDrawP0K1:

          ;; cpy P1Bottom		;;;;+3	 8	unless we mean to draw immediately, this should be set (duplicate)
				;;		to a value greater than maximum Y value initially
          ;; bcc SkipDrawP1K1	;;;;+2	10 (duplicate)
          ;; lda (P1display),y	;;;;+5	15 (duplicate)
          ;; sta GRP1		;;;;+4	19 (duplicate)
BackFromSkipDrawP1:

          sty temp1
          ;; ldy pfpixelheight (duplicate)
          lax (PF1pointer),y
          ;; stx PF1			;;;;+7	26 (duplicate)
          ;; lda (PF2pointer),y (duplicate)
          ;; sta PF2			;;;;+7	33 (duplicate)
 ;;SLEEP 6
          ;; stx PF1temp2 (duplicate)
          ;; sta PF2temp2 (duplicate)
          dey
          ;; bmi pagewraphandler (duplicate)
          ;; lda (PF1pointer),y (duplicate)
cyclebalance:
          ;; sta PF1temp1 (duplicate)
          ;; lda (PF2pointer),y (duplicate)
          ;; sta PF2temp1 (duplicate)
          ;; ldy temp1 (duplicate)

          ;; ldx # ENABL (duplicate)
          ;; txs (duplicate)
          ;; cpy bally (duplicate)
          php			;;;;+6	39	VDEL ball


          ;; cpy missile1y (duplicate)
          ;; php			;;;;+6	71 (duplicate)

          ;; cpy missile0y (duplicate)
          ;; php			;;;;+6	 1 (duplicate)


          ;; dey			;;;;+2	15 (duplicate)

          ;; cpy RepoLine		;;;;+3	18 (duplicate)
          ;; beq RepoKernel		;;;;+2	20 (duplicate)
;;	.SLEEP 20		;+23	43
          .SLEEP 6

newrepo ;; since we have time here, store next repoline
          ;; ldx SpriteIndex (duplicate)
          ;; lda SpriteGfxIndex-1,x (duplicate)
          ;; tax (duplicate)
          ;; lda NewSpriteY,x (duplicate)
          ;; sta temp6 (duplicate)
          .SLEEP 4 

BackFromRepoKernel:
          tya			;;;;+2	45
          and pfheight			;;;;+2	47
          bne KernelLoopa		;;;;+2	49
          ;; dec pfpixelheight (duplicate)
          ;; bpl KernelLoopb		;;;;+3	54 (duplicate)
;;	bmi donewkernel		;+3	54
;;	bne KernelLoopb+1		;+3	54

donewkernel:
          ;; jmp DoneWithKernel	;;;;+3	56 (duplicate)

pagewraphandler:
          ;; jmp cyclebalance (duplicate)

;;-------------------------------------------------------------------------

 ;; room here for score?

setscorepointers:
          ;; lax score+2 (duplicate)
          ;; jsr scorepointerset (duplicate)
          ;; sty scorepointers+5 (duplicate)
          ;; stx scorepointers+2 (duplicate)
          ;; lax score+1 (duplicate)
          ;; jsr scorepointerset (duplicate)
          ;; sty scorepointers+4 (duplicate)
          ;; stx scorepointers+1 (duplicate)
          ;; lax score (duplicate)
          ;; jsr scorepointerset (duplicate)
          ;; sty scorepointers+3 (duplicate)
          ;; stx scorepointers (duplicate)
wastetime:
          ;; rts (duplicate)

scorepointerset:
          ;; and #$0F (duplicate)
          asl
          ;; asl (duplicate)
          ;; asl (duplicate)
          ;; asl (duplicate)
          ;; adc # <SetFontNumbers (duplicate)
          ;; tay (duplicate)
          ;; txa (duplicate)
          ;; and #$F0 (duplicate)
          ;; lsr (duplicate)
          ;; asl (duplicate)
          ;; asl (duplicate)
          ;; asl (duplicate)
          ;; adc # <SetFontNumbers (duplicate)
          ;; tax (duplicate)
          ;; rts (duplicate)
;;	align 256

SwitchDrawP0KR				;;;;	45
          ;; lda P0Bottom (duplicate)
          ;; sta P0Top			;;;;+6	51 (duplicate)
          ;; jmp BackFromSwitchDrawP0KR	;;;;+3	54 (duplicate)

WaitDrawP0KR				;;;;	47
          .SLEEP 4				;;;;+4	51
          ;; jmp BackFromSwitchDrawP0KR	;;;;+3	54 (duplicate)

;;-----------------------------------------------------------

noUpdateXKR:
          ;; ldx # 1 (duplicate)
          ;; cpy P0Top (duplicate)
          ;; jmp retXKR (duplicate)

skipthis:
          ;; ldx # 1 (duplicate)
          ;; jmp goback (duplicate)

RepoKernel			;;;;	22	crosses page boundary
          ;; tya (duplicate)
          ;; and pfheight			;;;;+2	26 (duplicate)
          ;; bne noUpdateXKR		;;;;+2	28 (duplicate)
          ;; tax (duplicate)
;;	dex			;+2	30
          ;; dec pfpixelheight (duplicate)
;;	stx Temp		;+3	35
;;	.SLEEP 3

          ;; cpy P0Top		;;;;+3	42 (duplicate)
retXKR:
          ;; beq SwitchDrawP0KR	;;;;+2	44 (duplicate)
          ;; bpl WaitDrawP0KR	;;;;+2	46 (duplicate)
          ;; lda (player0pointer),y	;;;;+5	51 (duplicate)
          ;; sta GRP0		;;;;+3	54	VDEL (duplicate)
BackFromSwitchDrawP0KR:
          ;; sec			;;;;+2	56 (duplicate)



          ;; lda PF2temp1,x (duplicate)
          ;; ldy PF1temp1,x (duplicate)

          ;; ldx SpriteIndex	;;;;+3	 2 (duplicate)

          ;; sta PF2			;;;;+7	63 (duplicate)

          ;; lda SpriteGfxIndex,x (duplicate)
          ;; sty PF1			;;;;+7	70	too early? (duplicate)
          ;; tax (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta GRP1		;;;;+5	75	to display player 0 (duplicate)
          ;; lda NewSpriteX,x	;;;;+4	 6 (duplicate)

DivideBy15LoopK				;;;;	 6	(carry set above)
          ;; sbc # 15 (duplicate)
          ;; bcs DivideBy15LoopK		;;;;+4/5	10/15.../60 (duplicate)

          ;; tax				;;;;+2	12/17/...62 (duplicate)
          ;; lda FineAdjustTableEnd,x	;;;;+5	17/22/...67 (duplicate)

          ;; sta HMP1			;;;;+3	20/25/...70 (duplicate)
          ;; sta RESP1			;;;;+3	23/28/33/38/43/48/53/58/63/68/73 (duplicate)
          ;; sta WSYNC			;;;;+3	 0	begin line 2 (duplicate)
	;;sta HMOVE			;+3	 3

          ;; ldx # ENABL (duplicate)
          ;; txs			;;;;+4	25 (duplicate)
          ;; ldy RepoLine ;;;; restore y (duplicate)
          ;; cpy bally (duplicate)
          ;; php			;;;;+6	 9	VDEL ball (duplicate)

          ;; cpy missile1y (duplicate)
          ;; php			;;;;+6	15 (duplicate)

          ;; cpy missile0y (duplicate)
          ;; php			;;;;+6	21 (duplicate)





;;15 cycles
          ;; tya (duplicate)
          ;; and pfheight (duplicate)
 ;;eor #1
          ;; and #$FE (duplicate)
          ;; bne skipthis (duplicate)
          ;; tax (duplicate)
          .SLEEP 4
;;	.SLEEP 2
goback:

          ;; dey (duplicate)
          ;; cpy P0Top			;;;;+3	52 (duplicate)
          ;; beq SwitchDrawP0KV	;;;;+2	54 (duplicate)
          ;; bpl WaitDrawP0KV		;;;;+2	56 (duplicate)
          ;; lda (player0pointer),y		;;;;+5	61 (duplicate)
          ;; sta GRP0			;;;;+3	64	VDEL (duplicate)
BackFromSwitchDrawP0KV:

;; .SLEEP 3

          ;; lda PF2temp1,x (duplicate)
          ;; sta PF2			;;;;+7	 5 (duplicate)
          ;; lda PF1temp1,x (duplicate)
          ;; sta PF1			;;;;+7	74 (duplicate)
          ;; sta HMOVE (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta GRP1			;;;;+5	10	to display GRP0 (duplicate)

          ;; ldx # ENABL (duplicate)
          ;; txs			;;;;+4	 8 (duplicate)

          ;; ldx SpriteIndex	;;;;+3	13	restore index into new sprite vars (duplicate)
	;;--now, set all new variables and return to main kernel loop


;
          ;; lda SpriteGfxIndex,x	;;;;+4	31 (duplicate)
          ;; tax				;;;;+2	33 (duplicate)
;



          ;; lda NewNUSIZ,x (duplicate)
          ;; sta NUSIZ1			;;;;+7	20 (duplicate)
          ;; sta REFP1 (duplicate)
          ;; lda NewCOLUP1,x (duplicate)
          ;; sta COLUP1			;;;;+7	27 (duplicate)

;;	lda SpriteGfxIndex,x	;+4	31
;;	tax				;+2	33
          ;; lda NewSpriteY,x		;;;;+4	46 (duplicate)
          ;; sec				;;;;+2	38 (duplicate)
          ;; sbc spriteheight,x	;;;;+4	42 (duplicate)
          ;; sta P1Bottom		;;;;+3	45 (duplicate)

          .SLEEP 6
          ;; lda player1pointerlo,x	;;;;+4	49 (duplicate)
          ;; sbc P1Bottom		;;;;+3	52	carry should still be set (duplicate)
          ;; sta P1display		;;;;+3	55 (duplicate)
          ;; lda player1pointerhi,x (duplicate)
          ;; sta P1display+1		;;;;+7	62 (duplicate)


          ;; cpy bally (duplicate)
          ;; php			;;;;+6	68	VDELed (duplicate)

          ;; cpy missile1y (duplicate)
          ;; php			;;;;+6	74 (duplicate)

          ;; cpy missile0y (duplicate)
          ;; php			;;;;+6	 4 (duplicate)



;; lda SpriteGfxIndex-1,x
;; .SLEEP 3
          ;; dec SpriteIndex	;;;;+5	13 (duplicate)
;; tax
;; lda NewSpriteY,x
;; sta RepoLine

;; 10 cycles below...
          ;; bpl SetNextLine (duplicate)
          ;; lda # 255 (duplicate)
          ;; jmp SetLastLine (duplicate)
SetNextLine:
;;	lda NewSpriteY-1,x
          ;; lda temp6 (duplicate)
SetLastLine:
          ;; sta RepoLine (duplicate)

          ;; tya (duplicate)
          ;; and pfheight (duplicate)
          ;; bne nodec (duplicate)
          ;; dec pfpixelheight (duplicate)
          ;; dey			;;;;+2	30 (duplicate)

;; 10 cycles 


          ;; jmp BackFromRepoKernel	;;;;+3	43 (duplicate)

nodec:
          .SLEEP 4
          ;; dey (duplicate)
          ;; jmp BackFromRepoKernel (duplicate)

;;-------------------------------------------------------------------------


SwitchDrawP0KV				;;;;	69
          ;; lda P0Bottom (duplicate)
          ;; sta P0Top			;;;;+6	75 (duplicate)
          ;; jmp BackFromSwitchDrawP0KV	;;;;+3	 2 (duplicate)

WaitDrawP0KV				;;;;	71
          .SLEEP 4				;;;;+4	75
          ;; jmp BackFromSwitchDrawP0KV	;;;;+3	 2 (duplicate)

;;-------------------------------------------------------------------------

DoneWithKernel

BottomOfKernelLoop:

          ;; sta WSYNC (duplicate)
          ;; ldx sta (duplicate)

          ;; txs (duplicate)
          ;; jsr sixdigscore ;;;; set up score (duplicate)


          ;; sta WSYNC (duplicate)
          ;; ldx # 0 (duplicate)
          ;; sta HMCLR (duplicate)
          ;; stx GRP0 (duplicate)
          ;; stx GRP1 ;;;; seems to be needed because of vdel (duplicate)

          ;; ldy # 15 (duplicate)
          ;; sty VDELP0 (duplicate)
          ;; sty VDELP1 (duplicate)
          ;; lda #$10 (duplicate)
          ;; sta HMP1 (duplicate)
          ;; lda scorecolor (duplicate)
          ;; sta COLUP0 (duplicate)
          ;; sta COLUP1 (duplicate)
        ;; Set score color mode: COLUP0 = ColIndigo(12), COLUP1 = ColRed(12)
        ;; CTRLPF bit 2 ($04) enables score mode (left half uses COLUP0, right half uses COLUP1)
          .if  pfscore
          ;; lda #$8C  ;;;; ColIndigo(12) = $80 (base) + $0C (brightness 12) (duplicate)
          ;; sta COLUP0 (duplicate)
          ;; lda #$4C  ;;;; ColRed(12) = $40 (base) + $0C (brightness 12) (duplicate)
          ;; sta COLUP1 (duplicate)
          ;; lda CTRLPF (duplicate)
          ;; ora #$04  ;;;; Set bit 2 for score mode (duplicate)
          ;; sta CTRLPF (duplicate)
          .fi

          ;; lda #$03 (duplicate)
          ;; sta NUSIZ0 (duplicate)
          ;; sta NUSIZ1 (duplicate)

          ;; sta RESP0 (duplicate)
          ;; sta RESP1 (duplicate)

          .SLEEP 9
          ;; lda  (scorepointers),y (duplicate)
          ;; sta  GRP0 (duplicate)
          .if  pfscore
          ;; lda pfscorecolor (duplicate)
          ;; sta COLUPF (duplicate)
          .else
          .SLEEP 6
          .fi

          ;; sta HMOVE (duplicate)
          ;; lda  (scorepointers+8),y (duplicate)
;; sta WSYNC
 ;;SLEEP 2
          ;; jmp beginscore (duplicate)


loop2:
          ;; lda  (scorepointers),y     ;;;;+5  68  204 (duplicate)
          ;; sta  GRP0            ;;;;+3  71  213      D1     --      --     -- (duplicate)
          .if  pfscore
          ;; lda pfscore1 (duplicate)
          ;; sta PF1 (duplicate)
          .else
          .SLEEP 7
          .fi
 ;; cycle 0
          ;; lda  (scorepointers+$8),y  ;;;;+5   5   15 (duplicate)
beginscore:
          ;; sta  GRP1            ;;;;+3   8   24      D1     D1      D2     -- (duplicate)
          ;; lda  (scorepointers+$6),y  ;;;;+5  13   39 (duplicate)
          ;; sta  GRP0            ;;;;+3  16   48      D3     D1      D2     D2 (duplicate)
          ;; lax  (scorepointers+$2),y  ;;;;+5  29   87 (duplicate)
          ;; txs (duplicate)
          ;; lax  (scorepointers+$4),y  ;;;;+5  36  108 (duplicate)
          .SLEEP 3
          .if  pfscore
          ;; lda pfscore2 (duplicate)
          ;; sta PF1 (duplicate)
          .else
          .SLEEP 6
          .fi
          ;; lda  (scorepointers+$A),y  ;;;;+5  21   63 (duplicate)
          ;; stx  GRP1            ;;;;+3  44  132      D3     D3      D4     D2! (duplicate)
          ;; tsx (duplicate)
          ;; stx  GRP0            ;;;;+3  47  141      D5     D3!     D4     D4 (duplicate)
          ;; sta  GRP1            ;;;;+3  50  150      D5     D5      D6     D4! (duplicate)
          ;; sty  GRP0            ;;;;+3  53  159      D4*    D5!     D6     D6 (duplicate)
          ;; dey (duplicate)
          ;; bpl  loop2           ;;;;+2  60  180 (duplicate)
        ;; Reset CTRLPF score mode after score kernel
          .if  pfscore
          ;; lda CTRLPF (duplicate)
          ;; and #$FB  ;;;; Clear bit 2 (score mode) (duplicate)
          ;; sta CTRLPF (duplicate)
          .fi
          ;; ldx sta (duplicate)

          ;; txs (duplicate)


;; lda scorepointers+1
          ;; ldy temp1 (duplicate)
;; sta temp1
          ;; sty scorepointers+1 (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta GRP0 (duplicate)
          ;; sta GRP1 (duplicate)
          ;; sta PF1 (duplicate)
          ;; sta VDELP0 (duplicate)
          ;; sta VDELP1;;;;do we need these (duplicate)
          ;; sta NUSIZ0 (duplicate)
          ;; sta NUSIZ1 (duplicate)

;; lda scorepointers+3
          ;; ldy temp3 (duplicate)
;; sta temp3
          ;; sty scorepointers+3 (duplicate)

;; lda scorepointers+5
          ;; ldy temp5 (duplicate)
;; sta temp5
          ;; sty scorepointers+5 (duplicate)


;;-------------------------------------------------------------------------
;;------------------------Overscan Routine---------------------------------
;;-------------------------------------------------------------------------

OverscanRoutine



skipscore:
          .if  qtcontroller
          ;; lda qtcontroller (duplicate)
          ;; lsr    ;;;; bit 0 in carry (duplicate)
          ;; lda # 4 (duplicate)
          ror    ;;;; carry into top of A
          .else
          ;; lda # 2 (duplicate)
          .fi ;;;; qtcontroller
          ;; sta WSYNC (duplicate)
          ;; sta VBLANK	;;;;turn on VBLANK (duplicate)





;;-------------------------------------------------------------------------
;;----------------------------End Main Routines----------------------------
;;-------------------------------------------------------------------------


;;*************************************************************************

;;-------------------------------------------------------------------------
;;----------------------Begin Subroutines----------------------------------
;;-------------------------------------------------------------------------




KernelCleanupSubroutine:

          ;; ldx # 4 (duplicate)
AdjustYValuesDownLoop:
          ;; lda NewSpriteY,x (duplicate)
          ;; sec (duplicate)
          ;; sbc # 2 (duplicate)
          ;; sta NewSpriteY,x (duplicate)
          ;; dex (duplicate)
          ;; bpl AdjustYValuesDownLoop (duplicate)


;; RETURN: (duplicate - macro defined in MultiSpriteSuperChip.s)

	;;rts

SetupP1Subroutine:
;; flickersort algorithm
;; count 4-0
;; table2= table1 (?)
;; detect overlap of sprites in table 2
;; if overlap, do regular sort in table2, then place one sprite at top of table 1, decrement # displayed
;; if no overlap, do regular sort in table 2 and table 1
fsstart:
          ;; ldx # 255 (duplicate)
copytable:
          inx
          ;; lda spritesort,x (duplicate)
          ;; sta SpriteGfxIndex,x (duplicate)
          cpx # 4
          ;; bne copytable (duplicate)

          ;; stx temp3 ;;;; highest displayed sprite (duplicate)
          ;; dex (duplicate)
          ;; stx temp2 (duplicate)
sortloop:
          ;; ldx temp2 (duplicate)
          ;; lda spritesort,x (duplicate)
          ;; tax (duplicate)
          ;; lda NewSpriteY,x (duplicate)
          ;; sta temp1 (duplicate)

          ;; ldx temp2 (duplicate)
          ;; lda spritesort+1,x (duplicate)
          ;; tax (duplicate)
          ;; lda NewSpriteY,x (duplicate)
          ;; sec (duplicate)
          ;; clc (duplicate)
          ;; sbc temp1 (duplicate)
          ;; bcc largerXislower (duplicate)

;; larger x is higher (A>= temp1)
          ;; cmp spriteheight,x (duplicate)
          ;; bcs countdown (duplicate)
;; overlap with x+1>x
;; 
;; stick x at end of gfxtable, dec counter
overlapping:
          ;; dec temp3 (duplicate)
          ;; ldx temp2 (duplicate)
;; inx
          ;; jsr shiftnumbers (duplicate)
          ;; jmp skipswapGfxtable (duplicate)

largerXislower ;;;; (temp1>A)
          ;; tay (duplicate)
          ;; ldx temp2 (duplicate)
          ;; lda spritesort,x (duplicate)
          ;; tax (duplicate)
          ;; tya (duplicate)
          eor #$FF
          ;; sbc # 1 (duplicate)
          ;; bcc overlapping (duplicate)
          ;; cmp spriteheight,x (duplicate)
          ;; bcs notoverlapping (duplicate)

          ;; dec temp3 (duplicate)
          ;; ldx temp2 (duplicate)
;; inx
          ;; jsr shiftnumbers (duplicate)
          ;; jmp skipswapGfxtable (duplicate)
notoverlapping:
;; ldx temp2 ; swap display table
;; ldy SpriteGfxIndex+1,x
;; lda SpriteGfxIndex,x
;; sty SpriteGfxIndex,x
;; sta SpriteGfxIndex+1,x 

skipswapGfxtable:
          ;; ldx temp2 ;;;; swap sort table (duplicate)
          ;; ldy spritesort+1,x (duplicate)
          ;; lda spritesort,x (duplicate)
          ;; sty spritesort,x (duplicate)
          ;; sta spritesort+1,x (duplicate)

countdown:
          ;; dec temp2 (duplicate)
          ;; bpl sortloop (duplicate)

checktoohigh:
          ;; ldx temp3 (duplicate)
          ;; lda SpriteGfxIndex,x (duplicate)
          ;; tax (duplicate)
          ;; lda NewSpriteY,x (duplicate)
          .if  screenheight
          ;; cmp # screenheight-3 (duplicate)
          .else
          ;; cmp #$55 (duplicate)
          .fi
          ;; bcc nonetoohigh (duplicate)
          ;; dec temp3 (duplicate)
          ;; bne checktoohigh (duplicate)

nonetoohigh:
          ;; rts (duplicate)


shiftnumbers:
 ;; stick current x at end, shift others down
 ;; if x=4: do not do anything
 ;; if x=3: swap 3 and 4
 ;; if x=2: 2=3, 3=4, 4=2
 ;; if x=1: 1=2, 2=3, 3=4, 4=1
 ;; if x=0: 0=1, 1=2, 2=3, 3=4, 4=0
;; ldy SpriteGfxIndex,x
swaploop:
          ;; cpx # 4 (duplicate)
          ;; beq shiftdone (duplicate)
          ;; lda SpriteGfxIndex+1,x (duplicate)
          ;; sta SpriteGfxIndex,x (duplicate)
          ;; inx (duplicate)
          ;; jmp swaploop (duplicate)
shiftdone:
;; sty SpriteGfxIndex,x
          ;; rts (duplicate)

    ;;.error "Multi-sprite kernel ends at ", *

