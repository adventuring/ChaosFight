;;; ChaosFight - Source/Routines/HealthBarSystem.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



          ;; HEALTH BAR SYSTEM USING PFSCORE



          ;; Uses batariBasic built-in score display system to show

          ;;
          ;; health bars

          ;; P1/P2 health displayed as score bars at top of screen

          ;; P3/P4 health will be implemented separately



          ;; Health Bar Thresholds and Patterns

          ;; Health thresholds split on 12s: 12, 24, 36, 48, 60, 72, 84

          ;; Compare health starting from 84 downward to find pixel

          ;; count

          ;; bit patterns: 0-8 pixels filled from right to left

          ;; Uses hardcoded thresholds



          ;; bit pattern table for 0-8 pixels (right-aligned fill)

          ;; 0 pixels = %00000000, 1 pixel = %00000001, ..., 8 pixels =

          ;; %11111111




UpdatePlayer1HealthBar .proc


          ;;
          ;; Returns: Far (return otherbank)

          ;; Update Player 1 health bar (pfscore1).

          ;; Input: temp1 = health value (0-100)

          ;; PlayerHealthMax (constant) = maximum health value

          ;; HealthBarPatterns (ROM constant, bank6) = bit

          ;; pattern table

          ;;
          ;; Output: pfscore1 set to health bar pattern (8 pixels, bit

          ;; pattern)

          ;;
          ;; Mutates: temp1 (clamped to PlayerHealthMax), temp2

          ;; (pattern index), temp3 (pattern value),

          ;; pfscore1 (TIA register)

          ;;
          ;; Called Routines: None (reads ROM data table)

          ;; Constraints: Must be colocated with P1SetPattern (called via goto)

          ;; Clamp health to valid range (unsigned bytes cannot be negative)

                    ;; if temp1 > PlayerHealthMax then let temp1 = PlayerHealthMax



          ;; Compare health against thresholds starting from 83

          ;; downward

          ;; 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2

          ;; pixels, 0-11 = 0 pixels

          ;; patternIndex will hold the pattern index (0-8)
          lda # 0
          sta temp2



          ;; Check thresholds from highest (83) to lowest (11)

          ;; 84-100 = 8 pixels

          ;; 72-83 = 7 pixels

          ;; lda temp1 (duplicate)
          cmp # 84
          bcc skip_3169
                    ;; let temp2 = 8 : goto P1SetPattern
skip_3169:


          ;; 60-71 = 6 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 72 (duplicate)
          ;; bcc skip_183 (duplicate)
                    ;; let temp2 = 7 : goto P1SetPattern
skip_183:


          ;; 48-59 = 5 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 60 (duplicate)
          ;; bcc skip_5281 (duplicate)
                    ;; let temp2 = 6 : goto P1SetPattern
skip_5281:


          ;; 36-47 = 4 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 48 (duplicate)
          ;; bcc skip_1969 (duplicate)
                    ;; let temp2 = 5 : goto P1SetPattern
skip_1969:


          ;; 24-35 = 3 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 36 (duplicate)
          ;; bcc skip_9302 (duplicate)
                    ;; let temp2 = 4 : goto P1SetPattern
skip_9302:


          ;; 12-23 = 2 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 24 (duplicate)
          ;; bcc skip_9226 (duplicate)
                    ;; let temp2 = 3 : goto P1SetPattern
skip_9226:


          ;; 0-11 = 0 pixels (patternIndex already 0)
          ;; lda temp1 (duplicate)
          ;; cmp # 12 (duplicate)
          ;; bcc skip_4428 (duplicate)
                    ;; let temp2 = 2 : goto P1SetPattern
skip_4428:




.pend

P1SetPattern .proc

          ;; Look up bit pattern from table and set pfscore1
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp2 (from UpdatePlayer1HealthBar),

          ;; HealthBarPatterns (ROM constant, bank6)

          ;;
          ;; Output: pfscore1 set to health bar pattern

          ;;
          ;; Mutates: temp3 (pattern value), pfscore1 (TIA register)

          ;;
          ;; Called Routines: None (reads ROM data table)

          ;;
          ;; Constraints: Must be colocated with UpdatePlayer1HealthBar

          ;; Look up bit pattern from table using patternIndex as index

          ;; Note: HealthBarPatterns is in same bank (Bank 6) as this

          ;; function, so no bank prefix needed

                    ;; let temp3 = HealthBarPatterns[temp2]         
          ;; lda temp2 (duplicate)
          asl
          tax
          ;; lda HealthBarPatterns,x (duplicate)
          ;; sta temp3 (duplicate)



          ;; Set pfscore1 to health bar pattern

          ;; lda temp3 (duplicate)
          ;; sta pfscore1 (duplicate)



          jsr BS_return

.pend

UpdatePlayer2HealthBar .proc

          ;; Update Player 2 health bar (pfscore2).
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = health value (0-100)

          ;; PlayerHealthMax (constant) = maximum health value

          ;; HealthBarPatterns (ROM constant, bank6) = bit

          ;; pattern table

          ;;
          ;; Output: pfscore2 set to health bar pattern (8 pixels, bit

          ;; pattern)

          ;;
          ;; Mutates: temp1 (clamped to PlayerHealthMax), temp2

          ;; (pattern index), temp3 (pattern value),

          ;; pfscore2 (TIA register)

          ;;
          ;; Called Routines: None (reads ROM data table)

          ;; Constraints: Must be colocated with P2SetPattern (called via goto)

          ;; Clamp health to valid range (unsigned bytes cannot be negative)

                    ;; if temp1 > PlayerHealthMax then let temp1 = PlayerHealthMax



          ;; Compare health against thresholds starting from 83

          ;; downward

          ;; 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2

          ;; pixels, 0-11 = 0 pixels

          ;; patternIndex will hold the pattern index (0-8)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)



          ;; Check thresholds from highest (83) to lowest (11)

          ;; 84-100 = 8 pixels

          ;; 72-83 = 7 pixels

          ;; lda temp1 (duplicate)
          ;; cmp # 84 (duplicate)
          ;; bcc skip_4534 (duplicate)
                    ;; let temp2 = 8 : goto P2SetPattern
skip_4534:


          ;; 60-71 = 6 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 72 (duplicate)
          ;; bcc skip_9565 (duplicate)
                    ;; let temp2 = 7 : goto P2SetPattern
skip_9565:


          ;; 48-59 = 5 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 60 (duplicate)
          ;; bcc skip_8978 (duplicate)
                    ;; let temp2 = 6 : goto P2SetPattern
skip_8978:


          ;; 36-47 = 4 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 48 (duplicate)
          ;; bcc skip_7424 (duplicate)
                    ;; let temp2 = 5 : goto P2SetPattern
skip_7424:


          ;; 24-35 = 3 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 36 (duplicate)
          ;; bcc skip_8762 (duplicate)
                    ;; let temp2 = 4 : goto P2SetPattern
skip_8762:


          ;; 12-23 = 2 pixels
          ;; lda temp1 (duplicate)
          ;; cmp # 24 (duplicate)
          ;; bcc skip_1470 (duplicate)
                    ;; let temp2 = 3 : goto P2SetPattern
skip_1470:


          ;; 0-11 = 0 pixels (patternIndex already 0)
          ;; lda temp1 (duplicate)
          ;; cmp # 12 (duplicate)
          ;; bcc skip_6939 (duplicate)
                    ;; let temp2 = 2 : goto P2SetPattern
skip_6939:




.pend

P2SetPattern .proc

          ;; Look up bit pattern from table and set pfscore2
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp2 (from UpdatePlayer2HealthBar),

          ;; HealthBarPatterns (ROM constant, bank6)

          ;;
          ;; Output: pfscore2 set to health bar pattern

          ;;
          ;; Mutates: temp3 (pattern value), pfscore2 (TIA register)

          ;;
          ;; Called Routines: None (reads ROM data table)

          ;;
          ;; Constraints: Must be colocated with UpdatePlayer2HealthBar

          ;; Look up bit pattern from table using patternIndex as index

          ;; Note: HealthBarPatterns is in same bank (Bank 6) as this

          ;; function, so no bank prefix needed

                    ;; let temp3 = HealthBarPatterns[temp2]         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda HealthBarPatterns,x (duplicate)
          ;; sta temp3 (duplicate)



          ;; Set pfscore2 to health bar pattern

          ;; lda temp3 (duplicate)
          ;; sta pfscore2 (duplicate)



          ;; jsr BS_return (duplicate)

.pend

UpdatePlayer12HealthBars .proc




          ;; Update both P1 and P2 health bars
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: playerHealth[0] and playerHealth[1] arrays

          ;; Update both Player 1 and Player 2 health bars

          ;;
          ;; Input: playerHealth[] (global array) = player health

          ;; values

          ;;
          ;; Output: pfscore1, pfscore2 updated

          ;;
          ;; Mutates: temp1 (passed to

          ;; UpdatePlayer1HealthBar/UpdatePlayer2HealthBar),

          ;; pfscore1, pfscore2 (TIA registers, via

          ;; UpdatePlayer1HealthBar/UpdatePlayer2HealthBar)

          ;;
          ;; Called Routines: UpdatePlayer1HealthBar - accesses temp1,

          ;; HealthBarPatterns,

          ;; UpdatePlayer2HealthBar - accesses temp1,

          ;; HealthBarPatterns

          ;; Constraints: Tail call to UpdatePlayer2HealthBar

          ;; Update P1 health bar

                    ;; let temp1 = playerHealth[0]          lda 0          asl          tax          lda playerHealth,x          sta temp1

          ;; jsr UpdatePlayer1HealthBar (duplicate)



          ;; Update P2 health bar

                    ;; let temp1 = playerHealth[1]
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sta temp1 (duplicate)

          ;; tail call

          jmp UpdatePlayer2HealthBar





.pend

InitializeHealthBars .proc


          ;; Initialize health bars at game sta

          ;; Returns: Far (return otherbank)

          ;; Initialize health bars at game start - set to full (100%)

          ;;
          ;; Input: PlayerHealthMax (constant) = maximum health value

          ;;
          ;; Output: pfscore1, pfscore2 set to full health pattern

          ;;
          ;; Mutates: temp1 (passed to

          ;; UpdatePlayer1HealthBar/UpdatePlayer2HealthBar),

          ;; pfscore1, pfscore2 (TIA registers, via

          ;; UpdatePlayer1HealthBar/UpdatePlayer2HealthBar)

          ;;
          ;; Called Routines: UpdatePlayer1HealthBar - accesses temp1,

          ;; HealthBarPatterns,

          ;; UpdatePlayer2HealthBar - accesses temp1,

          ;; HealthBarPatterns

          ;; Constraints: Tail call to UpdatePlayer2HealthBar

          ;; Set initial health bars to full (100%)

          ;; lda PlayerHealthMax (duplicate)
          ;; sta temp1 (duplicate)

          ;; jsr UpdatePlayer1HealthBar (duplicate)

          ;; tail call

          ;; jmp UpdatePlayer2HealthBar (duplicate)



          ;;
          ;; P3/p4 HEALTH DISPLAY (score Mode)

          ;; Display players 3 and 4 health as 2-digit numbers in score

          ;; area

          ;; Format: nnCFmm where:

          ;; Left 2 digits (nn): Player 3 health (00-99 in BCD) or $ee if inactive/eliminated

          ;; Middle 2 digits (CF): Literal CF ($CF - bad BCD displays

          ;; as hex)

          ;; Right 2 digits (mm): Player 4 health (00-99 in BCD) or $ee if inactive/eliminated

          ;; Score display uses 6 digits total (3 bytes)

          ;; Uses bad BCD technique: $ee and #$CF are invalid BCD but

          ;; display as hex characters



ConvertToBCD
          ;; Returns: Far (return thisbank)


;; ConvertToBCD (duplicate)


          ;; Convert binary value (0-99) to packed BCD format
          ;; Returns: Far (return otherbank)

          ;; Optimized routine by Thomas Jentsch (used with permission)

          ;;
          ;; Input: temp1 = binary value (0-99, max $63)

          ;;
          ;; Output: temp1 = packed BCD value (e.g., 75 -> $75)

          ;;
          ;; Mutates: temp1 (input value, then output), temp6 (scratch, used as Y)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Must be colocated with UpdatePlayer34HealthBars

          ;; Input must be <= $63 (99 decimal)


            ;; lda temp1    ; A = value (0..$63) (duplicate)

            ;; tax (duplicate)
            ; save original value

            lsr
            ; divide by 16 (high nibble)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            tay
            ; Y = high nibble (tens digit)

            txa
            ; restore original value

            clc

            sed
            ; decimal mode

            adc # 0       ; start with low nibble in decimal mode

byte: $2c    ; bit abs (skip next instruction)

ConvertToBCDLoop

            ;; adc # 6       ; add 6 to adjust for decimal (BCD correction) (duplicate)

            dey
            ; decrement tens counter

          ;; TODO: bpl ConvertToBCDLoop

            cld
            ; clear decimal mode

            ;; sta temp1    ; store result (packed BCD, e.g., $75 for 75) (duplicate)


          rts

.pend

UpdatePlayer34HealthBars .proc






          ;; Check if Quadtari is present
          ;; Returns: Far (return otherbank)

          ;; If no Quadtari, display CF2026 instead of player health

          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          ;; cmp # 0 (duplicate)
          bne skip_9352
          ;; jmp DisplayCF2026 (duplicate)
skip_9352:




          ;; Only update player health if players 3 or 4 are active

          ;; jsr BS_return (duplicate)



          ;; Get Player 3 health (0-100), clamp to 99

          ;; Use $ee (’  ’) if inactive

          ;; (playerCharacter = NoCharacter) or eliminated

                    ;; let temp1 = playerHealth[2]         
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sta temp1 (duplicate)

          ;; Check if Player 3 is eliminated (health = 0)

                    ;; if playerCharacter[2] = NoCharacter then goto P3UseAA
          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8659 (duplicate)
          ;; jmp P3UseAA (duplicate)
skip_8659:


          ;; Clamp health to valid range

          ;;           ;; if PlayerHealthMax - 1 < temp1 then let temp1 = PlayerHealthMax - 1          lda PlayerHealthMax          sec          sbc 1          sta temp1
          ;; jmp P3ConvertHealth (duplicate)



.pend

P3UseAA .proc

          ;; Player 3 inactive/eliminated - use $ee (displays as ’  ’)
          ;; Returns: Far (return otherbank)

          ;; lda $ee (duplicate)
          ;; sta temp4 (duplicate)

          ;; jmp P4GetHealth (duplicate)



P3ConvertHealth

          ;; Convert Player 3 health to packed BCD (00-99)
          ;; Returns: Far (return otherbank)

          ;; jsr ConvertToBCD (duplicate)

          ;; temp4 now contains P3 health as BCD (e.g., $75 for 75)

          ;; lda temp1 (duplicate)
          ;; sta temp4 (duplicate)



.pend

P4GetHealth .proc

          ;; Get Player 4 health (0-100), clamp to 99
          ;; Returns: Far (return otherbank)

          ;; Use $ee (displays as ’  ’) if inactive

          ;; (playerCharacter = NoCharacter) or eliminated

                    ;; let temp2 = playerHealth[3]         
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; Check if Player 4 is eliminated (health = 0)

                    ;; if playerCharacter[3] = NoCharacter then goto P4UseAA
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_9418 (duplicate)
          ;; jmp P4UseAA (duplicate)
skip_9418:


          ;; Clamp health to valid range

          ;; lda temp2 (duplicate)
          ;; cmp # 100 (duplicate)
          ;; bcc skip_6777 (duplicate)
          ;; lda # 99 (duplicate)
          ;; sta temp2 (duplicate)
skip_6777:


          ;; jmp P4ConvertHealth (duplicate)



.pend

P4UseAA .proc

          ;; Player 4 inactive/eliminated - use $ee (displays as ’  ’)
          ;; Returns: Far (return otherbank)

          ;; lda $ee (duplicate)
          ;; sta temp5 (duplicate)

          ;; jmp SetScoreBytes (duplicate)



P4ConvertHealth

          ;; Convert Player 4 health to packed BCD (00-99)
          ;; Returns: Far (return otherbank)

          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)

          ;; jsr ConvertToBCD (duplicate)

          ;; temp5 now contains P4 health as BCD (e.g., $50 for 50)

          ;; lda temp1 (duplicate)
          ;; sta temp5 (duplicate)



.pend

SetScoreBytes .proc

          ;; Set score for nnCFmm format using bad BCD values
          ;; Returns: Far (return otherbank)

          ;; Format: score (digits 0-1), score+1 (digits 2-3), score+2

          ;; (digits 4-5)

          ;; score (high byte, digits 0-1) = P3 BCD ($00-$99) OR $ee if

          ;; inactive/eliminated

          ;; score+1 (middle byte, digits 2-3) = $CF (literal CF -

          ;; bad BCD)

          ;; score+2 (low byte, digits 4-5) = P4 BCD ($00-$99) OR $ee

          ;; if inactive/eliminated

          ;; Note: $ee and #$CF are invalid BCD but display as hex

          ;; characters via score font



          ;; Set score bytes directly (no BCD arithmetic needed - we

          ;; already have BCD or bad BCD values)

          ;; Write raw byte values: $ee/$CF/$ee or health BCD values


          ;; TODO: lda temp4

          ;; TODO: sta score

          ;; TODO: ; Middle 2 digits always "CF" (literal hex - bad BCD)

          ;; TODO: lda # $CF

          ;; TODO: sta score+1

          ;; TODO: lda temp5

          ;; TODO: sta score+2




          ;; Score colors are now set directly in MultiSpriteKernel.s

          ;; COLUP0 = ColIndigo(12), COLUP1 = ColRed(12)

          ;; COLUPF = ColIndigo(12) (for pfscore mode)

          ;; (Issue #600 - completed)



          ;; jsr BS_return (duplicate)



.pend

DisplayCF2026 .proc

          ;; No Quadtari detected - display CF2026 using bad BCD
          ;; Returns: Far (return otherbank)

          ;; values

          ;; Format: CF2026 = $CF $20 $26 (bad BCD displays as hex

          ;; characters)

          ;; score (digits 0-1) = $CF (CF)

          ;; score+1 (digits 2-3) = $20 (20)

          ;; score+2 (digits 4-5) = $26 (26)


          ;; TODO: lda # $CF

          ;; TODO: sta score

          ;; TODO: lda # $20

          ;; TODO: sta score+1

          ;; TODO: lda # $26

          ;; TODO: sta score+2




          ;; Score colors are set directly in MultiSpriteKernel.s

          ;; (Issue #600 - completed)



          ;; jsr BS_return (duplicate)

.pend

