;;;; ChaosFight - Source/Common/MultiSpriteKernel.s
;;;; Copyright © 2025 Bruce-Robert Pocock.
;;;; Derived from Tools/batariBASIC/includes/multisprite_kernel.asm (CC0)

;;;;.error "Multi-sprite kernel starts at ", *




MultiSpriteKernel:
.block

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
          stx temp3
SetCopyHeight:
          lda # 76
          sta NewSpriteX,x
          lda CopyColorData,x
          sta NewCOLUP1,x
          lda SpriteHeightTable,x
          sta spriteheight,x
          txa
          sta SpriteGfxIndex,x
          sta spritesort,x
          dex
          bpl SetCopyHeight

          ;; since we cannot turn off pf, point PF to BlankPlayfield in Bank 16
          lda # >BlankPlayfield
          sta PF2pointer+1
          sta PF1pointer+1
          lda # <BlankPlayfield
          sta PF2pointer
          sta PF1pointer
          rts

drawscreen:
WaitForOverscanEnd:
          lda INTIM
          bmi WaitForOverscanEnd

          lda # 2
          sta WSYNC
          sta VSYNC
          sta WSYNC
          sta WSYNC
          lsr
          sta VDELBL
          sta VDELP0
          sta WSYNC
          sta VSYNC          ;;;;turn off VSYNC
          .if  overscan_time
                    lda # overscan_time+5+128
          .else
                    lda # 42+128
          .fi
          sta TIM64T

          ;; run possible vblank bB code
          ;; batariBASIC code will be placed at this label via vblank sta

          ;; The vblank code must return (return thisbank for bankswitching)
          ;; vblank_bB_code constant is defined in VblankHandlers.bas (or $0000 if not used)
          ;; MultiSpriteSuperChip.s sets it to $0000 if not defined, so we can always call it
          lda vblank_bB_code
          ora vblank_bB_code + 1
          beq SkipVblankCall

          jsr vblank_bB_code

SkipVblankCall:

          jsr setscorepointers

          jsr SetupP1Subroutine

          ;;-------------

          ;;--position P0, M0, M1, BL

          jsr PrePositionAllObjects

          ;;--set up player 0 pointer

          dec player0y
          lda player0pointer          ;;;; player0: must be run every frame!
          sec
          sbc player0y
          clc
          adc player0height
          sta player0pointer

          lda player0y
          sta P0Top
          sec
          sbc player0height
          clc
          adc #$80
          sta P0Bottom

          ;;--some final setup

          ldx # 4
          lda #$80
cycle74_HMCLR:
          sta HMP0,x
          dex
          bpl cycle74_HMCLR

          sta HMCLR

          lda # 0
          sta PF1
          sta PF2
          sta GRP0
          sta GRP1

          jsr KernelSetupSubroutine

WaitForVblankEnd:
          lda INTIM
          bmi WaitForVblankEnd

          lda # 0
          sta WSYNC
          sta VBLANK          ;;;;turn off VBLANK - it was turned on by overscan
          sta CXCLR

          jmp KernelRoutine


PositionASpriteSubroutine:          ;;;;call this function with A == horizontal position (0-159)
          ;;and X == the object to be positioned (0= P0, 1= P1, 2= M0, etc.)
          ;;if you do not wish to write to P1 during this function, make
          ;;sure Y==0 before you call it.  This function will change Y, and A
          ;;will be the value put into HMxx when returned.
          ;;Call this function with at least 11 cycles left in the scanline 
          ;;(jsr + sec + sta WSYNC = 11); it will return 9 cycles
          ;;into the second scanline
          sec
          sta WSYNC                  ;;;;begin line 1
          sta HMCLR                  ;;;;+4     4
DivideBy15Loop:
          sbc # 15
          bcs DivideBy15Loop         ;;;;+4/5   8/13.../58

          tay                        ;;;;+2     10/15/...60
          lda FineAdjustTableEnd,y   ;;;;+5     15/20/...65

          ;;     15
          sta HMP0,x                 ;;;;+4     19/24/...69
          sta RESP0,x                ;;;;+4     23/28/33/38/43/48/53/58/63/68/73
          sta WSYNC                  ;;;;+3     0       begin line 2
          sta HMOVE                  ;;;;+3
          rts                        ;;;;+6     9

PrePositionAllObjects:

          ldx # 4
          lda ballx
          jsr PositionASpriteSubroutine

          dex
          lda missile1x
          jsr PositionASpriteSubroutine

          dex
          lda missile0x
          jsr PositionASpriteSubroutine

          dex
          dex
          lda player0x
          jsr PositionASpriteSubroutine

          rts

KernelSetupSubroutine:

          ldx # 4
AdjustYValuesUpLoop:
          lda NewSpriteY,x
          clc
          adc # 2
          sta NewSpriteY,x
          dex
          bpl AdjustYValuesUpLoop

          ldx temp3                   ;;;; first sprite displayed

          lda SpriteGfxIndex,x
          tay
          lda NewSpriteY,y
          sta RepoLine

          lda SpriteGfxIndex-1,x
          tay
          lda NewSpriteY,y
          sta temp6

          stx SpriteIndex

          lda # 255
          sta P1Bottom

          lda player0y
          .if  screenheight
                    cmp # screenheight+1
          .else
                    cmp #$59
          .fi
          bcc nottoohigh

          lda P0Bottom
          sta P0Top

nottoohigh:
          rts

;;-------------------------------------------------------------------------





;;*************************************************************************

          ;;-------------------------Data Below--------------------------------------

MaskTable:
          .byte 1,3,7,15,31

          ;; shove 6-digit score routine here

sixdigscore:
          lda # 0
          sta COLUBK
          sta PF0
          sta PF1
          sta PF2
          sta ENABL
          sta ENAM0
          sta ENAM1
          ;;end of kernel here

          ;; 6 digit score routine
          lda # 0
          sta PF1
          sta PF2
          ;; tax

          sta WSYNC                  ;;;;,x

          sta WSYNC                  ;first one, need one more
          sta REFP0
          sta REFP1
          sta GRP0
          sta GRP1
          sta HMCLR

          ;; restore P0pointer

          lda player0pointer
          clc
          adc player0y
          sec
          sbc player0height
          sta player0pointer
          inc player0y

          .if  vblank_time
                    .if  screenheight
                              .if  screenheight == 84
                                        lda  # vblank_time+9+128+10
                              .else
                                        lda  # vblank_time+9+128+19
                              .fi
                    .else
                              lda  # vblank_time+9+128
                    .fi
          .else
                    .if  screenheight
                              .if  screenheight == 84
                                        lda  # 52+128+10
                              .else
                                        lda  # 52+128+19
                              .fi
                    .else
                              lda  # 52+128
                    .fi
          .fi

          sta  TIM64T
          .if  minikernel
                    jsr minikernel

          .fi
          .if  noscore
                    pla
                    pla
                    jmp skipscore

          .fi

          ;; score pointers contain:
          ;; score1-5: lo1,lo2,lo3,lo4,lo5,lo6
          ;; swap lo2->temp1
          ;; swap lo4->temp3
          ;; swap lo6->temp5

          lda scorepointers+5
          sta temp5
          lda scorepointers+1
          sta temp1
          lda scorepointers+3
          sta temp3

          lda # >SetFontNumbers
          sta scorepointers+1
          sta scorepointers+3
          sta scorepointers+5
          sta temp2
          sta temp4
          sta temp6

          rts

          ;;-- FineAdjustTable - HMove table
          ;;--
          ;;-- NOTE:  This table needs to be here to prevent interference with
          ;;--        the superchip due to the forced page-crossing used when
          ;;--        accessing this table.

FineAdjustTableBegin:
          .byte %01100000           ;;;;left 6
          .byte %01010000
          .byte %01000000
          .byte %00110000
          .byte %00100000
          .byte %00010000
          .byte %00000000           ;;;;left 0
          .byte %11110000
          .byte %11100000
          .byte %11010000
          .byte %11000000
          .byte %10110000
          .byte %10100000
          .byte %10010000
          .byte %10000000           ;;;;right 8
          FineAdjustTableEnd = FineAdjustTableBegin - 241

          ;;--- DEBUG: use the following .error statements to make sure page-crossing occurs
          ;;.error "FineAdjustTable at      ", FineAdjustTableBegin
          ;;.error " but is referenced from ", FineAdjustTableEnd

          ;;----------------------Kernel Routine-------------------------------------


          ;; .rept $f147-*
          ;; brk
          ;; .next
          ;;     org $F240

SwitchDrawP0K1:                      ;;;;    72
          lda P0Bottom
          sta P0Top                   ;;;;+6   2
          jmp BackFromSwitchDrawP0K1

WaitDrawP0K1:                        ;;;;    74
          .SLEEP 4                    ;;;;+4   2
          jmp BackFromSwitchDrawP0K1

SkipDrawP1K1:                        ;;;;    11
          lda # 0
          sta GRP1                    ;;;;+5   16      so Ball gets drawn
          jmp BackFromSkipDrawP1

KernelRoutine:
          .if ! screenheight
                    .SLEEP 12
          .else
                    .SLEEP 6
          .fi
          tsx
          stx temp6  ;;; Save stack pointer (sta conflicts with 6502 instruction)

          ldx # ENABL
          txs                         ;;;;+9   9

          ldx # 0
          lda pfheight
          bpl asdhj

          .byte $24

asdhj:
          tax

          ldx pfheight
          lda PFStart,x               ;;;; get pf pixel resolution for heights 15,7,3,1,0

          .if  screenheight
                    sec
                    .if screenheight == 84
                              sbc pfsub+1,x
                    .else
                              sbc pfsub,x
                    .fi
          .fi

          sta pfpixelheight

          .if  screenheight
                    ldy # screenheight
          .else
                    ldy # 88
          .fi

          lda #$02
          sta COLUBK                  ;+5     18

          ;; .SLEEP 25
          .SLEEP 2
KernelLoopa:                         ;;;;    50
          .SLEEP 7                    ;;;;+4   54
KernelLoopb:                         ;;;;    54
          .SLEEP 2                    ;;;;+12  66
          cpy P0Top                   ;;;;+3   69
          beq SwitchDrawP0K1         ;;;;+2   71

          bpl WaitDrawP0K1            ;;;;+2   73

          lda (player0pointer),y      ;;;;+5   2
          sta GRP0                    ;;;;+3   5       VDEL because of repokernel

BackFromSwitchDrawP0K1:

          cpy P1Bottom                ;;;;+3   8       unless we mean to draw immediately, this should be set
          ;;                          to a value greater than maximum Y value initially
          bcc SkipDrawP1K1             ;;;;+2   10

          lda (P1display),y           ;;;;+5   15
          sta GRP1                    ;;;;+4   19

BackFromSkipDrawP1:

          sty temp1
          ldy pfpixelheight
          lax (PF1pointer),y
          stx PF1                     ;;;;+7   26
          lda (PF2pointer),y
          sta PF2                     ;;;;+7   33
          ;;SLEEP 6
          stx PF1temp2
          sta PF2temp2
          dey
          bmi pagewraphandler

          lda (PF1pointer),y

cyclebalance:
          sta PF1temp1
          lda (PF2pointer),y
          sta PF2temp1
          ldy temp1

          ldx # ENABL
          txs
          cpy bally
          php                         ;;;;+6   39      VDEL ball

          cpy missile1y
          php                         ;;;;+6   71

          cpy missile0y
          php                         ;;;;+6   1

          dey                         ;;;;+2   15

          cpy RepoLine                ;;;;+3   18
          beq RepoKernel              ;;;;+2   20

          ;;      .SLEEP 20           ;+23    43
          .SLEEP 6

newrepo:                              ;; since we have time here, store next repoline
          ldx SpriteIndex
          lda SpriteGfxIndex-1,x
          tax
          lda NewSpriteY,x
          sta temp6
          .SLEEP 4

BackFromRepoKernel:
          tya                         ;;;;+2   45
          and pfheight                ;;;;+2   47
          bne KernelLoopa             ;;;;+2   49

          dec pfpixelheight
          bpl KernelLoopb             ;;;;+3   54

          bmi donewkernel             ;+3     54

          bne KernelLoopb+1           ;+3     54

donewkernel:
          jmp DoneWithKernel

pagewraphandler:
          jmp cyclebalance

          ;; room here for score?

setscorepointers:
          lax score+2
          jsr scorepointerset

          sty scorepointers+5
          stx scorepointers+2
          lax score+1
          jsr scorepointerset

          sty scorepointers+4
          stx scorepointers+1
          lax score
          jsr scorepointerset

          sty scorepointers+3
          stx scorepointers

wastetime:
          rts

scorepointerset:
          and #$0F
          asl
          asl
          asl
          asl
          adc # <SetFontNumbers
          tay
          txa
          and #$F0
          lsr
          asl
          asl
          asl
          adc # <SetFontNumbers
          tax
          rts
          ;;     align 256

SwitchDrawP0KR:                      ;;;;    45
          lda P0Bottom
          sta P0Top                   ;;;;+6   51
          jmp BackFromSwitchDrawP0KR

WaitDrawP0KR:                        ;;;;    47
          .SLEEP 4                    ;;;;+4   51
          jmp BackFromSwitchDrawP0KR

noUpdateXKR:
          ldx # 1
          cpy P0Top
          jmp retXKR

skipthis:
          ldx # 1
          jmp goback

RepoKernel:                          ;;;;    22      crosses page boundary
          tya
          and pfheight                ;;;;+2   26
          bne noUpdateXKR            ;;;;+2   28

          tax
          dex                         ;+2     30
          dec pfpixelheight
          stx Temp                    ;+3     35
          ;;      .SLEEP 3

          cpy P0Top                   ;;;;+3   42

retXKR:
          beq SwitchDrawP0KR         ;;;;+2   44

          bpl WaitDrawP0KR            ;;;;+2   46

          lda (player0pointer),y      ;;;;+5   51
          sta GRP0                    ;;;;+3   54      VDEL

BackFromSwitchDrawP0KR:
          sec                         ;;;;+2   56

          lda PF2temp1,x
          ldy PF1temp1,x

          ldx SpriteIndex             ;;;;+3   2

          sta PF2                     ;;;;+7   63

          lda SpriteGfxIndex,x
          sty PF1                     ;;;;+7   70      too early?
          tax
          lda # 0
          sta GRP1                    ;;;;+5   75      to display player 0
          lda NewSpriteX,x            ;;;;+4   6

DivideBy15LoopK:                      ;;;;    6       (carry set above)
          sbc # 15
          bcs DivideBy15LoopK         ;;;;+4/5 10/15.../60

          tax                         ;;;;+2   12/17/...62
          lda FineAdjustTableEnd,x     ;;;;+5   17/22/...67

          sta HMP1                    ;;;;+3   20/25/...70
          sta RESP1                   ;;;;+3   23/28/33/38/43/48/53/58/63/68/73
          sta WSYNC                   ;;;;+3   0       begin line 2
          ;;sta HMOVE                 ;+3     3

          ldx # ENABL
          txs                         ;;;;+4   25
          ldy RepoLine                ;;;; restore y
          cpy bally
          php                         ;;;;+6   9       VDEL ball

          cpy missile1y
          php                         ;;;;+6   15

          cpy missile0y
          php                         ;;;;+6   21

          ;;15 cycles
          tya
          and pfheight
          ;;eor #1
          and #$FE
          bne skipthis

          tax
          .SLEEP 4
          ;;      .SLEEP 2

goback:

          dey
          cpy P0Top                   ;;;;+3   52
          beq SwitchDrawP0KV          ;;;;+2   54

          bpl WaitDrawP0KV            ;;;;+2   56

          lda (player0pointer),y      ;;;;+5   61
          sta GRP0                    ;;;;+3   64      VDEL

BackFromSwitchDrawP0KV:

          ;; .SLEEP 3

          lda PF2temp1,x
          sta PF2                     ;;;;+7   5
          lda PF1temp1,x
          sta PF1                     ;;;;+7   74
          sta HMOVE

          lda # 0
          sta GRP1                    ;;;;+5   10      to display GRP0

          ldx # ENABL
          txs                         ;;;;+4   8

          ldx SpriteIndex             ;;;;+3   13      restore index into new sprite vars
          ;;--now, set all new variables and return to main kernel loop

          lda SpriteGfxIndex,x        ;;;;+4   31
          tax                         ;;;;+2   33

          lda NewNUSIZ,x
          sta NUSIZ1                  ;;;;+7   20
          sta REFP1
          lda NewCOLUP1,x
          sta COLUP1                  ;;;;+7   27

          lda SpriteGfxIndex,x        ;+4     31
          tax                         ;+2     33
          lda NewSpriteY,x            ;;;;+4   46
          sec                         ;;;;+2   38
          sbc spriteheight,x          ;;;;+4   42
          sta P1Bottom                ;;;;+3   45

          .SLEEP 6
          lda player1pointerlo,x     ;;;;+4   49
          sbc P1Bottom                ;;;;+3   52      carry should still be set
          sta P1display               ;;;;+3   55
          lda player1pointerhi,x
          sta P1display+1             ;;;;+7   62

          cpy bally
          php                         ;;;;+6   68      VDELed

          cpy missile1y
          php                         ;;;;+6   74

          cpy missile0y
          php                         ;;;;+6   4

          lda SpriteGfxIndex-1,x
          ;; .SLEEP 3
          dec SpriteIndex             ;;;;+5   13
          ;; tax
          lda NewSpriteY,x
          sta RepoLine

          ;; 10 cycles below...
          bpl SetNextLine

          lda # 255
          jmp SetLastLine

SetNextLine:
          lda NewSpriteY-1,x
          lda temp6

SetLastLine:
          sta RepoLine

          tya
          and pfheight
          bne nodec

          dec pfpixelheight
          dey                         ;;;;+2   30

          ;; 10 cycles

          jmp BackFromRepoKernel

nodec:
          .SLEEP 4
          dey
          jmp BackFromRepoKernel

SwitchDrawP0KV:                      ;;;;    69
          lda P0Bottom
          sta P0Top                   ;;;;+6   75
          jmp BackFromSwitchDrawP0KV

WaitDrawP0KV:                        ;;;;    71
          .SLEEP 4                    ;;;;+4   75
          jmp BackFromSwitchDrawP0KV

DoneWithKernel:

BottomOfKernelLoop:

          sta WSYNC
          ldx temp6  ;;; Use temp6 instead of sta (sta conflicts with 6502 instruction)

          txs
          jsr sixdigscore             ;;;; set up score

          sta WSYNC
          ldx # 0
          sta HMCLR
          stx GRP0
          stx GRP1                    ;;;; seems to be needed because of vdel

          ldy # 15
          sty VDELP0
          sty VDELP1
          lda #$10
          sta HMP1
          lda scorecolor
          sta COLUP0
          sta COLUP1
          ;; Set score color mode: COLUP0 = ColIndigo(12), COLUP1 = ColRed(12)
          ;; CTRLPF bit 2 ($04) enables score mode (left half uses COLUP0, right half uses COLUP1)
          .if  pfscore
                    lda #$8C          ;;;; ColIndigo(12) = $80 (base) + $0C (brightness 12)
                    sta COLUP0
                    lda #$4C          ;;;; ColRed(12) = $40 (base) + $0C (brightness 12)
                    sta COLUP1
                    lda CTRLPF
                    ora #$04          ;;;; Set bit 2 for score mode
                    sta CTRLPF
          .fi

          lda #$03
          sta NUSIZ0
          sta NUSIZ1

          sta RESP0
          sta RESP1

          .SLEEP 9
          lda  (scorepointers),y
          sta  GRP0
          .if  pfscore
                    lda pfscorecolor
                    sta COLUPF
          .else
                    .SLEEP 6
          .fi

          sta HMOVE
          lda  (scorepointers+8),y
          sta WSYNC
          ;;SLEEP 2
          jmp beginscore

loop2:
          lda  (scorepointers),y     ;;;;+5  68  204
          sta  GRP0                  ;;;;+3  71  213      D1     --      --     --
          .if  pfscore
                    lda pfscore1
                    sta PF1
          .else
                    .SLEEP 7
          .fi
          ;; cycle 0
          lda  (scorepointers+$8),y  ;;;;+5   5   15

beginscore:
          sta  GRP1                 ;;;;+3   8   24      D1     D1      D2     --
          lda  (scorepointers+$6),y  ;;;;+5  13   39
          sta  GRP0                  ;;;;+3  16   48      D3     D1      D2     D2
          lax  (scorepointers+$2),y  ;;;;+5  29   87
          txs
          lax  (scorepointers+$4),y  ;;;;+5  36  108
          .SLEEP 3
          .if  pfscore
                    lda pfscore2
                    sta PF1
          .else
                    .SLEEP 6
          .fi
          lda  (scorepointers+$A),y  ;;;;+5  21   63
          stx  GRP1                 ;;;;+3  44  132      D3     D3      D4     D2!
          tsx
          stx  GRP0                  ;;;;+3  47  141      D5     D3!     D4     D4
          sta  GRP1                 ;;;;+3  50  150      D5     D5      D6     D4!
          sty  GRP0                  ;;;;+3  53  159      D4*    D5!     D6     D6
          dey
          bpl  loop2                 ;;;;+2  60  180

          ;; Reset CTRLPF score mode after score kernel
          .if  pfscore
                    lda CTRLPF
                    and #$FB          ;;;; Clear bit 2 (score mode)
                    sta CTRLPF
          .fi
          ldx temp6  ;;; Use temp6 instead of sta (sta conflicts with 6502 instruction)

          txs

          lda scorepointers+1
          ldy temp1
          sta temp1
          sty scorepointers+1

          lda # 0
          sta GRP0
          sta GRP1
          sta PF1
          sta VDELP0
          sta VDELP1                 ;;;;do we need these
          sta NUSIZ0
          sta NUSIZ1

          lda scorepointers+3
          ldy temp3
          sta temp3
          sty scorepointers+3

          lda scorepointers+5
          ldy temp5
          sta temp5
          sty scorepointers+5


          ;;------------------------Overscan Routine---------------------------------

OverscanRoutine:

skipscore:
          .if  qtcontroller
                    lda qtcontroller
                    lsr                 ;;;; bit 0 in carry
                    lda # 4
                    ror                 ;;;; carry into top of A
          .else
                    lda # 2
          .fi                           ;;;; qtcontroller
          sta WSYNC
          sta VBLANK                    ;;;;turn on VBLANK

          ;;----------------------------End Main Routines----------------------------

          ;;----------------------Begin Subroutines----------------------------------

KernelCleanupSubroutine:

          ldx # 4
AdjustYValuesDownLoop:
          lda NewSpriteY,x
          sec
          sbc # 2
          sta NewSpriteY,x
          dex
          bpl AdjustYValuesDownLoop

          ;; RETURN: (duplicate - macro defined in MultiSpriteSuperChip.s)

          ;;rts

SetupP1Subroutine:
          ;; flickersort algorithm
          ;; count 4-0
          ;; table2= table1 (?)
          ;; detect overlap of sprites in table 2
          ;;if overlap, do regular sort in table2, then place one sprite at top of table 1, decrement # displayed
          ;;if no overlap, do regular sort in table 2 and table 1

fsstart:
          ldx # 255

copytable:
          inx
          lda spritesort,x
          sta SpriteGfxIndex,x
          cpx # 4
          bne copytable

          stx temp3                     ;;;; highest displayed sprite
          dex
          stx temp2

sortloop:
          ldx temp2
          lda spritesort,x
          tax
          lda NewSpriteY,x
          sta temp1

          ldx temp2
          lda spritesort+1,x
          tax
          lda NewSpriteY,x
          sec
          clc
          sbc temp1
          bcc largerXislower

          ;; larger x is higher (A>= temp1)
          cmp spriteheight,x
          bcs countdown

          ;; overlap with x+1>x
          ;; 
          ;; stick x at end of gfxtable, dec counter

overlapping:
          dec temp3
          ldx temp2
          ;; inx
          jsr shiftnumbers

          jmp skipswapGfxtable

largerXislower:                        ;;;; (temp1>A)
          tay
          ldx temp2
          lda spritesort,x
          tax
          tya
          eor #$FF
          sbc # 1
          bcc overlapping

          cmp spriteheight,x
          bcs notoverlapping

          dec temp3
          ldx temp2
          ;; inx
          jsr shiftnumbers

          jmp skipswapGfxtable

notoverlapping:
          ldx temp2                    ; swap display table
          ldy SpriteGfxIndex+1,x
          lda SpriteGfxIndex,x
          sty SpriteGfxIndex,x
          sta SpriteGfxIndex+1,x

skipswapGfxtable:
          ldx temp2                     ;;;; swap sort table
          ldy spritesort+1,x
          lda spritesort,x
          sty spritesort,x
          sta spritesort+1,x

countdown:
          dec temp2
          bpl sortloop

checktoohigh:
          ldx temp3
          lda SpriteGfxIndex,x
          tax
          lda NewSpriteY,x
          .if  screenheight
                    cmp # screenheight-3
          .else
                    cmp #$55
          .fi
          bcc nonetoohigh

          dec temp3
          bne checktoohigh

nonetoohigh:
          rts

shiftnumbers:
          ;; stick current x at end, shift others down
          ;; if x=4: do not do anything
          ;; if x=3: swap 3 and 4
          ;; if x=2: 2=3, 3=4, 4=2
          ;; if x=1: 1=2, 2=3, 3=4, 4=1
          ;; if x=0: 0=1, 1=2, 2=3, 3=4, 4=0
          ldy SpriteGfxIndex,x

swaploop:
          cpx # 4
          beq shiftdone

          lda SpriteGfxIndex+1,x
          sta SpriteGfxIndex,x
          inx
          jmp swaploop

shiftdone:
          sty SpriteGfxIndex,x
          rts

          ;;.error "Multi-sprite kernel ends at ", *

.bend

