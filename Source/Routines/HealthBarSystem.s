;;; ChaosFight - Source/Routines/HealthBarSystem.s

;;; Copyright © 2025 Bruce-Robert Pocock.

          ;; HEALTH BAR SYSTEM USING PFSCORE

          ;; Uses the batari Basic built-in score display to show health
          ;; bars: P1/P2 as the two pfscore bars at the top of the screen,
          ;; P3/P4 as two-digit values in the centre score field
          ;; (the "nnCFmm" layout).

          ;; Health thresholds split on 12s: 12, 24, 36, 48, 60, 72, 84.
          ;; Patterns are right-aligned fills from 0 to 8 pixels.
          ;; The table lives here (Bank 10) because the health-bar code
          ;; lives here; the original table in Bank 5 is not reachable
          ;; without a bank switch.

HealthBarPatternsLocal:
          .byte %00000000
          .byte %00000001
          .byte %00000011
          .byte %00000111
          .byte %00001111
          .byte %00011111
          .byte %00111111
          .byte %01111111
          .byte %11111111

UpdatePlayer1HealthBar .proc
          ;; Update Player 1 health bar (pfScore1).
          ;;
          ;; Input: temp1 = health value (0-100)
          ;; Output: pfScore1 set to the health-bar pattern
          ;; Returns: Far (return otherbank)
          ;; Mutates: temp1, temp2, temp3, pfScore1

          ;; Clamp health to PlayerHealthMax.
          lda # PlayerHealthMax
          cmp temp1
          bcs UpdatePlayer1HealthClamped
          lda # PlayerHealthMax
          sta temp1
UpdatePlayer1HealthClamped:

          lda # 0
          sta temp2

          ;; 84-100 = 8 pixels
          lda # 83
          cmp temp1
          bcs P1Check72
          lda # 8
          sta temp2
          jmp P1SetPattern
P1Check72:
          ;; 72-83 = 7 pixels
          lda # 71
          cmp temp1
          bcs P1Check60
          lda # 7
          sta temp2
          jmp P1SetPattern
P1Check60:
          ;; 60-71 = 6 pixels
          lda # 59
          cmp temp1
          bcs P1Check48
          lda # 6
          sta temp2
          jmp P1SetPattern
P1Check48:
          ;; 48-59 = 5 pixels
          lda # 47
          cmp temp1
          bcs P1Check36
          lda # 5
          sta temp2
          jmp P1SetPattern
P1Check36:
          ;; 36-47 = 4 pixels
          lda # 35
          cmp temp1
          bcs P1Check24
          lda # 4
          sta temp2
          jmp P1SetPattern
P1Check24:
          ;; 24-35 = 3 pixels
          lda # 23
          cmp temp1
          bcs P1Check12
          lda # 3
          sta temp2
          jmp P1SetPattern
P1Check12:
          ;; 12-23 = 2 pixels
          lda # 11
          cmp temp1
          bcs P1SetPattern
          lda # 2
          sta temp2

P1SetPattern:
          ldx temp2
          lda HealthBarPatternsLocal,x
          sta temp3
          sta pfScore1
          jmp BS_return
.pend

UpdatePlayer2HealthBar .proc
          ;; Update Player 2 health bar (pfScore2).
          ;;
          ;; Input: temp1 = health value (0-100)
          ;; Output: pfScore2 set to the health-bar pattern
          ;; Returns: Far (return otherbank)
          ;; Mutates: temp1, temp2, temp3, pfScore2

          lda # PlayerHealthMax
          cmp temp1
          bcs UpdatePlayer2HealthClamped
          lda # PlayerHealthMax
          sta temp1
UpdatePlayer2HealthClamped:

          lda # 0
          sta temp2

          lda # 83
          cmp temp1
          bcs P2Check72
          lda # 8
          sta temp2
          jmp P2SetPattern
P2Check72:
          lda # 71
          cmp temp1
          bcs P2Check60
          lda # 7
          sta temp2
          jmp P2SetPattern
P2Check60:
          lda # 59
          cmp temp1
          bcs P2Check48
          lda # 6
          sta temp2
          jmp P2SetPattern
P2Check48:
          lda # 47
          cmp temp1
          bcs P2Check36
          lda # 5
          sta temp2
          jmp P2SetPattern
P2Check36:
          lda # 35
          cmp temp1
          bcs P2Check24
          lda # 4
          sta temp2
          jmp P2SetPattern
P2Check24:
          lda # 23
          cmp temp1
          bcs P2Check12
          lda # 3
          sta temp2
          jmp P2SetPattern
P2Check12:
          lda # 11
          cmp temp1
          bcs P2SetPattern
          lda # 2
          sta temp2

P2SetPattern:
          ldx temp2
          lda HealthBarPatternsLocal,x
          sta temp3
          sta pfScore2
          jmp BS_return
.pend

UpdatePlayer12HealthBars .proc
          ;; Update both P1 and P2 health bars.
          ;; Returns: Far (return otherbank)
          ldx # 0
          lda playerHealth,x
          sta temp1
          jsr UpdatePlayer1HealthBar

          ldx # 2
          lda playerHealth,x
          sta temp1
          jmp UpdatePlayer2HealthBar
.pend

InitializeHealthBars .proc
          ;; Initialise both P1/P2 bars to full health.
          ;; Returns: Far (return otherbank)
          lda # PlayerHealthMax
          sta temp1
          jsr UpdatePlayer1HealthBar

          lda # PlayerHealthMax
          sta temp1
          jmp UpdatePlayer2HealthBar
.pend

ConvertToBCD .proc
          ;; Convert binary 0-99 in temp1 to packed BCD in temp1.
          ;; Optimised routine by Thomas Jentsch (used with permission).
          ;; Returns: Near (return thisbank)
          lda temp1        ; A = value (0..$63)
          tax              ; save original
          lsr              ; divide by 16
          lsr
          lsr
          lsr
          tay              ; Y = tens digit
          txa              ; restore original
          clc
          sed              ; decimal mode
          adc # 0          ; start with low nibble
          .byte $2c        ; BIT $xxxx (skip next 2-byte instruction)
ConvertToBCDLoop:
          adc # 6          ; BCD correction
          dey
          bpl ConvertToBCDLoop
          cld
          sta temp1        ; packed BCD
          rts
.pend

UpdatePlayer34HealthBars .proc
          ;; Display P3/P4 health in the score field as nnCFmm, or
          ;; CF2026 when QuadTari is absent.
          ;; Returns: Far (return otherbank)

          ;; Without QuadTari, show the CF2026 banner.
          lda controllerStatus
          and # SetQuadtariDetected
          bne UpdatePlayer34Health
          jmp DisplayCF2026
UpdatePlayer34Health:

          ;; Only update if players 3 or 4 are active.
          lda controllerStatus
          and # SetPlayers34Active
          bne UpdatePlayer34Active
          jmp BS_return
UpdatePlayer34Active:

          ;; ---- Player 3 ----
          ldx # 4
          lda playerHealth,x
          sta temp1

          ldx # 4
          lda playerCharacter,x
          cmp # NoCharacter
          beq P3UseAA
          lda temp1
          beq P3UseAA

          ;; Clamp to PlayerHealthMax - 1 (99).
          lda # PlayerHealthMax
          sec
          sbc # 1
          cmp temp1
          bcs P3ConvertHealth
          lda # PlayerHealthMax
          sec
          sbc # 1
          sta temp1
          jmp P3ConvertHealth
P3UseAA:
          lda # $ee
          sta temp4
          jmp P4GetHealth
P3ConvertHealth:
          jsr ConvertToBCD
          lda temp1
          sta temp4

          ;; ---- Player 4 ----
P4GetHealth:
          ldx # 6
          lda playerHealth,x
          sta temp2

          ldx # 6
          lda playerCharacter,x
          cmp # NoCharacter
          beq P4UseAA
          lda temp2
          beq P4UseAA

          ;; Clamp to 99.
          lda # 99
          cmp temp2
          bcs P4ConvertHealth
          lda # 99
          sta temp2
          jmp P4ConvertHealth
P4UseAA:
          lda # $ee
          sta temp5
          jmp SetScoreBytes
P4ConvertHealth:
          lda temp2
          sta temp1
          jsr ConvertToBCD
          lda temp1
          sta temp5

SetScoreBytes:
          ;; nnCFmm: P3 BCD (or $ee), literal CF, P4 BCD (or $ee).
          lda temp4
          sta score
          lda # $CF
          sta score+1
          lda temp5
          sta score+2

          ;; Score colours are set directly in MultiSpriteKernel.s
          ;; (COLUP0 = $7C, COLUP1 = $4C, COLUPF = $7C).
          jmp BS_return
.pend

DisplayCF2026 .proc
          ;; No QuadTari - display CF2026 using deliberately bad BCD.
          ;; Returns: Far (return otherbank)
          lda # $CF
          sta score
          lda # $20
          sta score+1
          lda # $26
          sta score+2
          jmp BS_return
.pend
