; Provided under the CC0 license. See the included LICENSE.txt for details.
;
; ---------------------------------------------------------------------------
; Per-instruction cycle annotations (;c=N) follow the standard NMOS 6502
; timing table:
;   * "N"      : fixed cycle cost
;   * "2/3"    : relative branch (2 cycles not taken, 3 taken; +1 on page cross)
;   * "N+1*"   : read instruction that costs one extra cycle on a page crossing
;   * .Sleep N : expands to exactly N cycles (see Source/Common/Macros.s)
;
; NOTE: the legacy ";\tNN" / ";+N\tNN" position comments inherited verbatim
; from batari Basic's includes/multisprite_kernel.asm are inaccurate — the
; upstream author and the AtariAge "Modifying the Multisprite Kernel" thread
; both confirm the cycle-count comments in this kernel are off.  The ;c=
; values added here are authoritative.  On the no-page-cross path the main
; scanline loop body (KernelLoopb -> KernelLoopa) totals 152 cycles = 2
; scanlines per iteration.
; --------------------------------------------------------------------------- 
           .align 256

;; CRITICAL: Compile-time page-alignment check; build fails if page crossing detected.
           .if (($ - $$) % $100) >= $fc
             .error "MultiSpriteKernel entry page-cross detected (within $fc-$ff of page) - add .fill padding before loop entry"
           .fi

MultiSpriteKernel .block

FineAdjustTableBegin:
          .byte range(6, 0) << 4
          .byte range(15, 8, -1) << 4
          FineAdjustTableEnd = FineAdjustTableBegin - 241

PFStart:
          .byte 87, 43, 0, 21, 0, 0, 0, 10
BlankPF:
          .byte 0, 0, 0, 0, 0, 0, 0, 5
pfsub:
          .byte 8, 4, 2, 2, 1, 0, 0, 1, 0

          ;; set initial P1 positions
MultiSpriteSetup:
          lda # 15 ;c=2
          sta pfHeight ;c=3

          ldx # 4 ;c=2
SetCopyHeight:
          txa ;c=2
          sta SpriteGfxIndex, x ;c=4
          sta spritesort, x ;c=4
          dex ;c=2
          bpl SetCopyHeight ;c=2/3

          ;; since we can’t turn off pf, point PF to zeros here
          lda # > BlankPF ;c=2
          sta pf2Pointer + 1 ;c=3
          sta pf1Pointer + 1 ;c=3
          lda # < BlankPF ;c=2
          sta pf2Pointer ;c=3
          sta pf1Pointer ;c=3
          rts ;c=6

drawscreen:
WaitForOverscanEnd:
          lda INTIM ;c=3
          bmi WaitForOverscanEnd ;c=2/3

          lda # 2 ;c=2
          stx WSYNC ;c=3
          sta VSYNC ;c=3
          stx WSYNC ;c=3
          stx WSYNC ;c=3
          lsr a ;c=2
          sta VDELBL ;c=3
          sta VDELP0 ;c=3
          stx WSYNC ;c=3
          sta VSYNC ;c=3 ;turn off VSYNC
          lda # overscan_time+5 + 128 ;c=2
          sta TIM64T ;c=3

          ;; Run optional vblank batariBASIC code (defined by the project).
          lda vblank_bB_code ;c=4
          ora vblank_bB_code + 1 ;c=4
          beq SkipVblankCall ;c=2/3

          jsr vblank_bB_code ;c=6

SkipVblankCall:

                     jsr setscorePointers ;c=6

          jsr SetupP1Subroutine ;c=6

          ;-------------


          ;--position P0, M0, M1, BL

          jsr PrePositionAllObjects ;c=6

          ;--set up player 0 pointer

          dec player0y ;c=5
          lda player0pointer ;c=3 ; player0: must be run every frame!
          sec ;c=2
          sbc player0y ;c=3
          clc ;c=2
          adc player0Height ;c=3
          sta player0pointer ;c=3

          lda player0y ;c=3
          sta p0Top ;c=3
          sec ;c=2
          sbc player0Height ;c=3
          clc ;c=2
          adc #$80 ;c=2
          sta p0Bottom ;c=3
          

          ;--some final setup

          ldx # 4 ;c=2
          lda #$80 ;c=2
cycle74_HMCLR:
          sta HMP0, x ;c=4
          dex ;c=2
          bpl cycle74_HMCLR ;c=2/3

          ;	sta HMCLR


          lda # 0 ;c=2
          sta PF1 ;c=3
          sta PF2 ;c=3
          sta GRP0 ;c=3
          sta GRP1 ;c=3


          jsr KernelSetupSubroutine ;c=6

WaitForVblankEnd:
          lda INTIM ;c=3
          bmi WaitForVblankEnd ;c=2/3

          lda # 0 ;c=2
          stx WSYNC ;c=3
          sta VBLANK ;c=3 ;turn off VBLANK - it was turned on by overscan
          sta CXCLR ;c=3


          jmp KernelRoutine ;c=3

          PositionASpriteSubroutine	;call this function with A == horizontal position (0-159)
          			;and X == the object to be positioned (0=P0, 1=P1, 2=M0, etc.)
          			;if you do not wish to write to P1 during this function, make
          			;sure Y==0 before you call it. This function will change Y, and A
          			;will be the value put into HMxx when returned.
          			;Call this function with at least 11 cycles left in the scanline 
          			;(jsr + sec + stx WSYNC = 11); it will return 9 cycles
          			;into the second scanline
          sec ;c=2
          stx WSYNC ;c=3 ;begin line 1
          sta @w HMCLR ;c=4 ;+4	 4
DivideBy15Loop:
          sbc # 15 ;c=2
          bcs DivideBy15Loop ;c=2/3 ;+4/5	8/13.../58

          tay ;c=2 ;+2	10/15/...60
          lda FineAdjustTableEnd, y ;c=4+1* ;+5	15/20/...65

          		;	15
          sta HMP0, x ;c=4 ;+4	19/24/...69
          sta RESP0, x ;c=4 ;+4	23/28/33/38/43/48/53/58/63/68/73
          stx WSYNC ;c=3 ; + 3	 0	begin line 2
          sta HMOVE ;c=3 ; + 3
          rts ;c=6 ;+6	 9

          ;-------------------------------------------------------------------------

PrePositionAllObjects:

          ldx # 4 ;c=2
          lda ballx ;c=3
          jsr PositionASpriteSubroutine ;c=6

          dex ;c=2
          lda missile1x ;c=3
          jsr PositionASpriteSubroutine ;c=6

          dex ;c=2
          lda missile0x ;c=3
          jsr PositionASpriteSubroutine ;c=6

          dex ;c=2
          dex ;c=2
          lda player0x ;c=3
          jsr PositionASpriteSubroutine ;c=6

          rts ;c=6

          ;-------------------------------------------------------------------------


          ;-------------------------------------------------------------------------


KernelSetupSubroutine:

          ldx # 4 ;c=2
AdjustYValuesUpLoop:
          lda newSpriteY, x ;c=4
          clc ;c=2
          adc # 2 ;c=2
          sta newSpriteY, x ;c=4
          dex ;c=2
          bpl AdjustYValuesUpLoop ;c=2/3

          ldx temp3 ;c=3 ; first sprite displayed

          lda SpriteGfxIndex, x ;c=4
          tay ;c=2
          lda newSpriteY, y ;c=4+1*
          sta repoLine ;c=3

          lda SpriteGfxIndex-1, x ;c=4
          tay ;c=2
          lda newSpriteY, y ;c=4+1*
          sta temp6 ;c=3

          stx spriteIndex ;c=3


          lda # 255 ;c=2
          sta p1Bottom ;c=3

          lda player0y ;c=3
          cmp # screenheight + 1 ;c=2
          bcc nottoohigh ;c=2/3

          lda p0Bottom ;c=3
          sta p0Top ;c=3

          

nottoohigh:
          rts ;c=6

          ;-------------------------------------------------------------------------


          ;*************************************************************************
          ;-------------------------------------------------------------------------
          ;-------------------------Data Below--------------------------------------
          ;-------------------------------------------------------------------------

MaskTable:
          .byte 1, 3, 7, 15, 31

          ; shove 6-digit score routine here

sixdigscore:
          lda # 0 ;c=2
          ;	sta COLUBK
          sta PF0 ;c=3
          sta PF1 ;c=3
          sta PF2 ;c=3
          sta ENABL ;c=3
          sta ENAM0 ;c=3
          sta ENAM1 ;c=3
          ;end of kernel here


          ; 6 digit score routine
          ; lda # 0
          ; sta PF1
          ; sta PF2
          ; tax

          stx WSYNC ;c=3 ;, x

          ; stx WSYNC ;first one, need one more
          sta REFP0 ;c=3
          sta REFP1 ;c=3
          sta GRP0 ;c=3
          sta GRP1 ;c=3
          sta HMCLR ;c=3

          ; restore P0pointer

          lda player0pointer ;c=3
          clc ;c=2
          adc player0y ;c=3
          sec ;c=2
          sbc player0Height ;c=3
          sta player0pointer ;c=3
          inc player0y ;c=5

          .if screenheight == 84
          	 lda # vblank_time+9 + 128 + 10 ;c=2
          .else
           lda # vblank_time+9 + 128 + 19 ;c=2
          .endif

          sta TIM64T ;c=3
          .if minikernel
                    jsr minikernel ;c=6

          .fi

          ; score pointers contain:
          ; score1-5: lo1, lo2, lo3, lo4, lo5, lo6
          ; swap lo2->temp1
          ; swap lo4->temp3
          ; swap lo6->temp5

          lda scorePointers+5 ;c=3
          sta temp5 ;c=3
          lda scorePointers + 1 ;c=3
          sta temp1 ;c=3
          lda scorePointers + 3 ;c=3
          sta temp3 ;c=3

          lda #>FontData ;c=2
          sta scorePointers + 1 ;c=3
          sta scorePointers + 3 ;c=3
          sta scorePointers+5 ;c=3
          sta temp2 ;c=3
          sta temp4 ;c=3
          sta temp6 ;c=3

          rts ;c=6

          ;-------------------------------------------------------------------------
          ;----------------------Kernel Routine-------------------------------------
          ;-------------------------------------------------------------------------


          ;-------------------------------------------------------------------------
          ; repeat $f147-*
          ; brk
          ; repend
          ;	org $F240

          SwitchDrawP0K1				;	72
          lda p0Bottom ;c=3
          sta p0Top ;c=3 ;+6	 2
          jmp BackFromSwitchDrawP0K1 ;c=3 ; + 3	 5

          WaitDrawP0K1				;	74
          .Sleep 4 ;c=4 ;+4	 2
          jmp BackFromSwitchDrawP0K1 ;c=3 ; + 3	 5

          SkipDrawP1K1				;	11
          lda # 0 ;c=2
          sta GRP1 ;c=3 ;+5	16	so Ball gets drawn
          jmp BackFromSkipDrawP1 ;c=3 ; + 3	19

          ;-------------------------------------------------------------------------

KernelRoutine:
          .Sleep 6 ;c=6
          tsx ;c=2
          stx aux2 ;c=3
          ldx # ENABL ;c=2
          txs ;c=2 ;+9	 9

          ldx # 0 ;c=2
          lda pfHeight ;c=3
          bpl + ;c=2/3

          .byte $24 ;c=3
          +
          tax ;c=2

          lda PFStart, x ;c=4+1* ; get pf pixel resolution for heights 15, 7, 3, 1, 0

          .if screenheight == 84
          sbc pfsub + 1, x ;c=4+1*
          .else
          sbc pfsub, x ;c=4+1*
          .endif
          
          sta pfPixelHeight ;c=3

          ldy # screenheight ;c=2
          
          ;	lda #$02
          ;	sta COLUBK		;+5	18
          ; sleep 25
          .Sleep 2 ;c=2
          KernelLoopa			;	50
          .Sleep 7 ;c=7 ;+4	54
          KernelLoopb			;	54
          .Sleep 2 ;c=2 ; + 12	66
          cpy p0Top ;c=3 ; + 3	69
          beq SwitchDrawP0K1 ;c=2/3 ;+2	71

          bpl WaitDrawP0K1 ;c=2/3 ;+2	73

          lda (player0pointer), y ;c=5+1* ;+5	 2
          sta GRP0 ;c=3 ; + 3	 5	VDEL because of repokernel
BackFromSwitchDrawP0K1:
          cpy p1Bottom ;c=3 ; + 3	 8	unless we mean to draw immediately, this should be set
          			;		to a value greater than maximum Y value initially
          bcc SkipDrawP1K1 ;c=2/3 ;+2	10

          lda (p1Display), y ;c=5+1* ;+5	15
          sta @w GRP1 ;c=4 ;+4	19
BackFromSkipDrawP1:

          sty temp1 ;c=3
          ldy pfPixelHeight ;c=3
          lax (pf1Pointer), y ;c=5+1*
          stx PF1 ;c=3 ;+7	26
          lda (pf2Pointer), y ;c=5+1*
          sta PF2 ;c=3 ;+7	33
          ;sleep 6
          stx pf1Temp2 ;c=3
          sta pf2Temp2 ;c=3
          dey ;c=2
          bmi pagewraphandler ;c=2/3

          lda (pf1Pointer), y ;c=5+1*
cyclebalance:
          sta pf1Temp1 ;c=3
          lda (pf2Pointer), y ;c=5+1*
          sta pf2Temp1 ;c=3
          ldy temp1 ;c=3

          ldx # ENABL ;c=2
          txs ;c=2
          cpy bally ;c=3
          php ;c=3 ;+6	39	VDEL ball


          cpy missile1y ;c=3
          php ;c=3 ;+6	71

          cpy missile0y ;c=3
          php ;c=3 ;+6	 1
          

          dey ;c=2 ;+2	15

          cpy repoLine ;c=3 ; + 3	18
          beq RepoKernel ;c=2/3 ;+2	20

          ;	.Sleep 20		;+23	43
          .Sleep 6 ;c=6

          newrepo ; since we have time here, store next repoline
          ldx spriteIndex ;c=3
          lda SpriteGfxIndex-1, x ;c=4
          tax ;c=2
          lda newSpriteY, x ;c=4
          sta temp6 ;c=3
          .Sleep 4 ;c=4

BackFromRepoKernel:
          tya ;c=2 ;+2	45
          and pfHeight ;c=3 ;+2	47
          bne KernelLoopa ;c=2/3 ;+2	49

          dec pfPixelHeight ;c=5
          bpl KernelLoopb ;c=2/3 ; + 3	54

          ;	bmi donewkernel		; + 3	54
          ;	bne KernelLoopb + 1		; + 3	54

donewkernel:
          jmp DoneWithKernel ;c=3 ; + 3	56

pagewraphandler:
          jmp cyclebalance ;c=3

          ;-------------------------------------------------------------------------
          ; room here for score?

setscorePointers:
          lax score+2 ;c=3
          jsr scorePointerset ;c=6

          sty scorePointers+5 ;c=3
          stx scorePointers+2 ;c=3
          lax score + 1 ;c=3
          jsr scorePointerset ;c=6

          sty scorePointers+4 ;c=3
          stx scorePointers + 1 ;c=3
          lax score ;c=3
          jsr scorePointerset ;c=6

          sty scorePointers + 3 ;c=3
          stx scorePointers ;c=3
wastetime:
          rts ;c=6

scorePointerset:
          and #$0f ;c=2
          asl a ;c=2
          asl a ;c=2
          asl a ;c=2
          asl a ;c=2
          adc #<FontData ;c=2
          tay ;c=2
          txa ;c=2
          and #$f0 ;c=2
          lsr a ;c=2
          asl a ;c=2
          asl a ;c=2
          asl a ;c=2
          adc #<FontData ;c=2
          tax ;c=2
          rts ;c=6

          ;	align 256

          SwitchDrawP0KR				;	45
          lda p0Bottom ;c=3
          sta p0Top ;c=3 ;+6	51
          jmp BackFromSwitchDrawP0KR ;c=3 ; + 3	54

          WaitDrawP0KR				;	47
          .Sleep 4 ;c=4 ;+4	51
          jmp BackFromSwitchDrawP0KR ;c=3 ; + 3	54

          ;-----------------------------------------------------------

noUpdateXKR:
          ldx # 1 ;c=2
          cpy @w p0Top ;c=4
          jmp retXKR ;c=3

skipthis:
          ldx # 1 ;c=2
          jmp goback ;c=3

          RepoKernel			;	22	crosses page boundary
          tya ;c=2
          and pfHeight ;c=3 ;+2	26
          bne noUpdateXKR ;c=2/3 ;+2	28

          tax ;c=2
          ;	dex			;+2	30
          dec pfPixelHeight ;c=5
          ;	stx Temp		; + 3	35
          ;	.Sleep 3

          cpy p0Top ;c=3 ; + 3	42
retXKR:
          beq SwitchDrawP0KR ;c=2/3 ;+2	44

          bpl WaitDrawP0KR ;c=2/3 ;+2	46

          lda (player0pointer), y ;c=5+1* ;+5	51
          sta GRP0 ;c=3 ; + 3	54	VDEL
BackFromSwitchDrawP0KR:
          sec ;c=2 ;+2	56
          


          lda pf2Temp1, x ;c=4
          ldy pf1Temp1, x ;c=4

          ldx spriteIndex ;c=3 ; + 3	 2

          sta PF2 ;c=3 ;+7	63

          lda SpriteGfxIndex, x ;c=4
          sty PF1 ;c=3 ;+7	70	too early?
          tax ;c=2
          lda # 0 ;c=2
          sta GRP1 ;c=3 ;+5	75	to display player 0
          lda newSpriteX, x ;c=4 ;+4	 6
          
          DivideBy15LoopK				;	 6	(carry set above)
          sbc # 15 ;c=2
          bcs DivideBy15LoopK ;c=2/3 ;+4/5	10/15.../60

          tax ;c=2 ;+2	12/17/...62
          lda FineAdjustTableEnd, x ;c=4+1* ;+5	17/22/...67

          sta HMP1 ;c=3 ; + 3	20/25/...70
          sta RESP1 ;c=3 ; + 3	23/28/33/38/43/48/53/58/63/68/73
          stx WSYNC ;c=3 ; + 3	 0	begin line 2
          ;sta HMOVE			; + 3	 3

          ldx # ENABL ;c=2
          txs ;c=2 ;+4	25
          ldy repoLine ;c=3 ; restore y
          cpy bally ;c=3
          php ;c=3 ;+6	 9	VDEL ball

          cpy missile1y ;c=3
          php ;c=3 ;+6	15

          cpy missile0y ;c=3
          php ;c=3 ;+6	21
          ;15 cycles
          tya ;c=2
          and pfHeight ;c=3
          ;eor #1
          and #$FE ;c=2
          bne skipthis ;c=2/3

          tax ;c=2
          .Sleep 4 ;c=4
goback:
          dey ;c=2
          cpy p0Top ;c=3 ; + 3	52
          beq SwitchDrawP0KV ;c=2/3 ;+2	54

          bpl WaitDrawP0KV ;c=2/3 ;+2	56

          lda (player0pointer), y ;c=5+1* ;+5	61
          sta GRP0 ;c=3 ; + 3	64	VDEL
BackFromSwitchDrawP0KV:
          ; .Sleep 3

          lda pf2Temp1, x ;c=4
          sta PF2 ;c=3 ;+7	 5
          lda pf1Temp1, x ;c=4
          sta PF1 ;c=3 ;+7	74 
          sta HMOVE ;c=3

          lda # 0 ;c=2
          sta GRP1 ;c=3 ;+5	10	to display GRP0

          ldx # ENABL ;c=2
          txs ;c=2 ;+4	 8

          ldx spriteIndex ;c=3 ; + 3	13	restore index into new sprite vars
          ;--now, set all new variables and return to main kernel loop


          ;
          lda SpriteGfxIndex, x ;c=4 ;+4	31
          tax ;c=2 ;+2	33
          ;


          lda newNUSIZ, x ;c=4
          sta NUSIZ1 ;c=3 ;+7	20
          sta REFP1 ;c=3
          lda NewCOLUP1, x ;c=4
          sta COLUP1 ;c=3 ;+7	27

          ;	lda SpriteGfxIndex, x	;+4	31
          ;	tax				;+2	33
          lda newSpriteY, x ;c=4 ;+4	46
          sec ;c=2 ;+2	38
          sbc spriteHeight, x ;c=4 ;+4	42
          sta p1Bottom ;c=3 ; + 3	45

          .Sleep 6 ;c=6
          lda player1PointerLo, x ;c=4 ;+4	49
          sbc p1Bottom ;c=3 ; + 3	52	carry should still be set
          sta p1Display ;c=3 ; + 3	55
          lda player1PointerHi, x ;c=4
          sta p1Display + 1 ;c=3 ;+7	62


          cpy bally ;c=3
          php ;c=3 ;+6	68	VDELed

          cpy missile1y ;c=3
          php ;c=3 ;+6	74

          cpy missile0y ;c=3
          php ;c=3 ;+6	 4


          ; lda SpriteGfxIndex-1, x
          ; .Sleep 3
          dec spriteIndex ;c=5 ;+5	13
          ; tax
          ; lda newSpriteY, x
          ; sta repoLine
          ; 10 cycles below...
          bpl SetNextLine ;c=2/3

          lda # 255 ;c=2
          jmp SetLastLine ;c=3

SetNextLine:
          ;	lda newSpriteY-1, x
          lda @w temp6 ;c=4
SetLastLine:
          sta repoLine ;c=3

          tya ;c=2
          and pfHeight ;c=3
          bne nodec ;c=2/3

          dec pfPixelHeight ;c=5
          dey ;c=2 ;+2	30

          ; 10 cycles
          

          jmp BackFromRepoKernel ;c=3 ; + 3	43

nodec:
          .Sleep 4 ;c=4
          dey ;c=2
          jmp BackFromRepoKernel ;c=3

          ;-------------------------------------------------------------------------


          SwitchDrawP0KV				;	69
          lda p0Bottom ;c=3
          sta p0Top ;c=3 ;+6	75
          jmp BackFromSwitchDrawP0KV ;c=3 ; + 3	 2

          WaitDrawP0KV				;	71
          .Sleep 4 ;c=4 ;+4	75
          jmp BackFromSwitchDrawP0KV ;c=3 ; + 3	 2

          ;-------------------------------------------------------------------------

DoneWithKernel:

BottomOfKernelLoop:
          lda # CTRLPFSCORE | CTRLPFREF ;c=2
          sta CTRLPF ;c=3

          stx WSYNC ;c=3
          ldx aux2 ;c=3
          txs ;c=2
          jsr sixdigscore ;c=6 ; set up score

          stx WSYNC ;c=3
          ldx # 0 ;c=2
          sta HMCLR ;c=3
          stx GRP0 ;c=3
          stx GRP1 ;c=3 ; seems to be needed because of vdel

          ldy # 7 ;c=2
          sty VDELP0 ;c=3
          sty VDELP1 ;c=3
          lda #$10 ;c=2
          sta HMP1 ;c=3
          lda scorecolor ;c=3
          sta COLUP0 ;c=3
          sta COLUP1 ;c=3
          
          lda #$03 ;c=2
          sta NUSIZ0 ;c=3
          sta NUSIZ1 ;c=3

          sta RESP0 ;c=3
          sta RESP1 ;c=3

          .Sleep 9 ;c=9
          lda (scorePointers), y ;c=5+1*
          sta GRP0 ;c=3
          .Sleep 6 ;c=6

          sta HMOVE ;c=3
          lda (scorePointers + 8), y ;c=5+1*
          jmp beginscore ;c=3

loop2:
          lda (scorePointers), y ;c=5+1* ;+5 68 204
          sta GRP0 ;c=3 ; + 3 71 213 D1 -- -- --
          lda @w pfScore1 ;c=4
          sta PF1 ;c=3
          ; cycle 0
          lda (scorePointers + $8), y ;c=5+1* ;+5 5 15
beginscore:
          sta GRP1 ;c=3 ; + 3 8 24 D1 D1 D2 --
          lda (scorePointers + $6), y ;c=5+1* ;+5 13 39
          sta GRP0 ;c=3 ; + 3 16 48 D3 D1 D2 D2
          lax (scorePointers + $2), y ;c=5+1* ;+5 29 87
          txs ;c=2
          lax (scorePointers + $4), y ;c=5+1* ;+5 36 108
          .Sleep 3 ;c=3
          lda pfScore2 ;c=3
          sta PF1 ;c=3
          lda (scorePointers + $A), y ;c=5+1* ;+5 21 63
          stx GRP1 ;c=3 ; + 3 44 132 D3 D3 D4 D2!
          tsx ;c=2
          stx GRP0 ;c=3 ; + 3 47 141 D5 D3! D4 D4
          sta GRP1 ;c=3 ; + 3 50 150 D5 D5 D6 D4!
          sty GRP0 ;c=3 ; + 3 53 159 D4* D5! D6 D6
          dey ;c=2
          bpl loop2 ;c=2/3 ;+2 60 180

          	ldx aux2 ;c=3
          txs ;c=2


          ; lda scorePointers + 1
          ldy temp1 ;c=3
          ; sta temp1
          sty scorePointers + 1 ;c=3

          lda # 0 ;c=2
          sta GRP0 ;c=3
          sta GRP1 ;c=3
          sta PF1 ;c=3
          sta VDELP0 ;c=3
          sta VDELP1 ;c=3 ; do we need these?
          sta NUSIZ0 ;c=3
          sta NUSIZ1 ;c=3

          ldy temp3 ;c=3
          sty scorePointers + 3 ;c=3

          ldy temp5 ;c=3
          sty scorePointers + 5 ;c=3

          ;------------------------Overscan Routine---------------------------------

OverscanRoutine:
SkipScore:
          .if qtcontroller
                    lda qtcontroller ;c=3
                    lsr a ;c=2 ; bit 0 in carry
                    lda # 4 ;c=2 ; will be 2 after ror
                    ror a ;c=2 ; carry into top of A
          .else
                    lda # 2 ;c=2
          .fi
          sta WSYNC ;c=3
          sta VBLANK ;c=3 ;turn on VBLANK

          ; Set overscan timer before returning to MainLoop, which runs
          ; the mode handlers during overscan.
          .if overscan_time
                    lda # overscan_time+128 ;c=2
          .else
                    lda # 30+128 ;c=2
          .fi
          sta TIM64T ;c=3

          ldx # 15 ;c=2
          nop $ffe0, x ;c=4+1*
          jmp MainLoop ;c=3

          ;----------------------Begin Subroutines----------------------------------

KernelCleanupSubroutine:

          ldx # 4 ;c=2
AdjustYValuesDownLoop:
          lda newSpriteY, x ;c=4
          sec ;c=2
          sbc # 2 ;c=2
          sta newSpriteY, x ;c=4
          dex ;c=2
          bpl AdjustYValuesDownLoop ;c=2/3

          rts ;c=6

SetupP1Subroutine:
          ; flickersort algorithm
          ; count 4-0
          ; table2=table1 (?)
          ; detect overlap of sprites in table 2
          ; if overlap, do regular sort in table2, then place one sprite at top of table 1, decrement # displayed
          ; if no overlap, do regular sort in table 2 and table 1
fsstart:
          ldx # 255 ;c=2
copytable:
          inx ;c=2
          lda spritesort, x ;c=4
          sta SpriteGfxIndex, x ;c=4
          cpx # 4 ;c=2
          bne copytable ;c=2/3

          stx temp3 ;c=3 ; highest displayed sprite
          dex ;c=2
          stx temp2 ;c=3
sortloop:
          ldx temp2 ;c=3
          lda spritesort, x ;c=4
          tax ;c=2
          lda newSpriteY, x ;c=4
          sta temp1 ;c=3

          ldx temp2 ;c=3
          lda spritesort + 1, x ;c=4
          tax ;c=2
          lda newSpriteY, x ;c=4
          sec ;c=2
          clc ;c=2
          sbc temp1 ;c=3
          bcc largerXislower ;c=2/3

          ; larger x is higher (A>=temp1)
          cmp spriteHeight, x ;c=4
          bcs countdown ;c=2/3

          ; overlap with x + 1>x
          ;
          ; stick x at end of gfxtable, dec counter
overlapping:
          dec temp3 ;c=5
          ldx temp2 ;c=3
          ; inx
          jsr ShiftNumbers ;c=6

          jmp SkipSwapGfxTable ;c=3

          largerXislower ; (temp1>A)
          tay ;c=2
          ldx temp2 ;c=3
          lda spritesort, x ;c=4
          tax ;c=2
          tya ;c=2
          eor #$FF ;c=2
          sbc # 1 ;c=2
          bcc overlapping ;c=2/3

          cmp spriteHeight, x ;c=4
          bcs notoverlapping ;c=2/3

          dec temp3 ;c=5
          ldx temp2 ;c=3
          ; inx
          jsr ShiftNumbers ;c=6

          jmp SkipSwapGfxTable ;c=3

notoverlapping:
          ; ldx temp2 ; swap display table
          ; ldy SpriteGfxIndex + 1, x
          ; lda SpriteGfxIndex, x
          ; sty SpriteGfxIndex, x
          ; sta SpriteGfxIndex + 1, x

SkipSwapGfxTable:
          ldx temp2 ;c=3 ; swap sort table
          ldy spritesort + 1, x ;c=4
          lda spritesort, x ;c=4
          sty spritesort, x ;c=4
          sta spritesort + 1, x ;c=4

countdown:
          dec temp2 ;c=5
          bpl sortloop ;c=2/3

CheckTooHigh:
          ldx temp3 ;c=3
          lda SpriteGfxIndex, x ;c=4
          tax ;c=2
          lda newSpriteY, x ;c=4
          cmp # screenheight - 3 ;c=2
          bcc NoneTooHigh ;c=2/3

          dec temp3 ;c=5
          bne CheckTooHigh ;c=2/3

NoneTooHigh:
          rts ;c=6

ShiftNumbers:
SwapLoop:
          cpx # 4 ;c=2
          bge ShiftDone ;c=2/3

          lda SpriteGfxIndex + 1, x ;c=4
          sta SpriteGfxIndex, x ;c=4
          inx ;c=2
          jmp SwapLoop ;c=3

ShiftDone:
          rts ;c=6

          bmi CyclesLeft ;c=2/3

          ldx # 64 ;c=2
          eor #$ff ;c=2 ;make negative
CyclesLeft:
          stx scorecolor ;c=3
          and #$7f ;c=2 ; clear sign bit
          tax ;c=2
          lda ScoreBCD, x ;c=4+1*
          sta score+2 ;c=3
          lda ScoreBCD1, x ;c=4+1*
          sta score + 1 ;c=3
          rts ;c=6

ScoreBCD:
          .byte $00, $64, $28, $92, $56, $20, $84, $48, $12, $76, $40
          .byte $04, $68, $32, $96, $60, $24, $88, $52, $16, $80, $44
          .byte $08, $72, $36, $00, $64, $28, $92, $56, $20, $84, $48
          .byte $12, $76, $40, $04, $68, $32, $96, $60, $24, $88
ScoreBCD1:
          .byte 0, 0, 1, 1, 2, 3, 3, 4, 5, 5, 6
          .byte 7, 7, 8, 8, 9, $10, $10, $11, $12, $12, $13
          .byte $14, $14, $15, $16, $16, $17, $17, $18, $19, $19, $20
          .byte $21, $21, $22, $23, $23, $24, $24, $25, $26, $26

          .bend


