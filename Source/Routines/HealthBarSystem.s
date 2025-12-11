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

          ;; Bit patterns: 0-8 pixels filled from right to left

          ;; Uses hardcoded thresholds



          ;; Bit pattern table for 0-8 pixels (right-aligned fill)

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

          if temp1 > PlayerHealthMax then let temp1 = PlayerHealthMax

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

          lda temp1
          cmp # 84
          bcc CheckHealth72
          ;; Set temp2 = 8 jmp P1SetPattern
CheckHealth72:


          ;; 60-71 = 6 pixels
          lda temp1
          cmp # 72
          bcc CheckHealth60
          ;; Set temp2 = 7 jmp P1SetPattern
CheckHealth60:


          ;; 48-59 = 5 pixels
          lda temp1
          cmp # 60
          bcc CheckHealth48
          ;; Set temp2 = 6 jmp P1SetPattern
CheckHealth48:


          ;; 36-47 = 4 pixels
          lda temp1
          cmp # 48
          bcc CheckHealth36
          ;; Set temp2 = 5 jmp P1SetPattern
CheckHealth36:


          ;; 24-35 = 3 pixels
          lda temp1
          cmp # 36
          bcc CheckHealth24
          ;; Set temp2 = 4 jmp P1SetPattern
CheckHealth24:


          ;; 12-23 = 2 pixels
          lda temp1
          cmp # 24
          bcc CheckHealth12
          ;; Set temp2 = 3 jmp P1SetPattern
CheckHealth12:


          ;; 0-11 = 0 pixels (patternIndex already 0)
          lda temp1
          cmp # 12
          bcc P1SetPattern
          ;; Set temp2 = 2 jmp P1SetPattern
P1SetPattern:




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

          ;; Set temp3 = HealthBarPatterns[temp2]
          lda temp2
          asl
          tax
          lda HealthBarPatterns,x
          sta temp3



          ;; Set pfscore1 to health bar pattern

          lda temp3
          sta pfscore1



          jmp BS_return

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

                    if temp1 > PlayerHealthMax then let temp1 = PlayerHealthMax



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

          lda temp1
          cmp # 84
          bcc CheckHealth72P2
          ;; Set temp2 = 8 jmp P2SetPattern
CheckHealth72P2:


          ;; 60-71 = 6 pixels
          lda temp1
          cmp # 72
          bcc CheckHealth60P2
          ;; Set temp2 = 7 jmp P2SetPattern
CheckHealth60P2:


          ;; 48-59 = 5 pixels
          lda temp1
          cmp # 60
          bcc CheckHealth48P2
          ;; Set temp2 = 6 jmp P2SetPattern
CheckHealth48P2:


          ;; 36-47 = 4 pixels
          lda temp1
          cmp # 48
          bcc CheckHealth36P2
          ;; Set temp2 = 5 jmp P2SetPattern
CheckHealth36P2:


          ;; 24-35 = 3 pixels
          lda temp1
          cmp # 36
          bcc CheckHealth24P2
          ;; Set temp2 = 4 jmp P2SetPattern
CheckHealth24P2:


          ;; 12-23 = 2 pixels
          lda temp1
          cmp # 24
          bcc CheckHealth12P2
          ;; Set temp2 = 3 jmp P2SetPattern
CheckHealth12P2:


          ;; 0-11 = 0 pixels (patternIndex already 0)
          lda temp1
          cmp # 12
          bcc P2SetPattern
          ;; Set temp2 = 2 jmp P2SetPattern
P2SetPattern:




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

          ;; Set temp3 = HealthBarPatterns[temp2]
          lda temp2
          asl
          tax
          lda HealthBarPatterns,x
          sta temp3



          ;; Set pfscore2 to health bar pattern

          lda temp3
          sta pfscore2



          jmp BS_return

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

                    ;; Set temp1 = playerHealth[0]
                    lda 0          asl          tax          lda playerHealth,x          sta temp1

          jsr UpdatePlayer1HealthBar



          ;; Update P2 health bar

          ;; Set temp1 = playerHealth[1]
          lda 1
          asl
          tax
          lda playerHealth,x
          sta temp1
          lda 1
          asl
          tax
          lda playerHealth,x
          sta temp1

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

          lda PlayerHealthMax
          sta temp1

          jsr UpdatePlayer1HealthBar

          ;; tail call

          jmp UpdatePlayer2HealthBar



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


ConvertToBCD


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


            lda temp1    ; A = value (0..$63)

            tax
            ; save original value

            lsr
            ; divide by 16 (high nibble)

            lsr

            lsr

            lsr

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

            adc # 6       ; add 6 to adjust for decimal (BCD correction)

            dey
            ; decrement tens counter

          ;; TODO: #1265 bpl ConvertToBCDLoop

            cld
            ; clear decimal mode

            sta temp1    ; store result (packed BCD, e.g., $75 for 75)


          rts

.pend

UpdatePlayer34HealthBars .proc






          ;; Check if Quadtari is present
          ;; Returns: Far (return otherbank)

          If no Quadtari, display CF2026 instead of player health

          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne UpdatePlayer34Health
          jmp DisplayCF2026
UpdatePlayer34Health:




          ;; Only update player health if players 3 or 4 are active

          jmp BS_return



          ;; Get Player 3 health (0-100), clamp to 99

          ;; Use $ee (’  ’) if inactive

          ;; (playerCharacter = NoCharacter) or eliminated

          ;; Set temp1 = playerHealth[2]
          lda 2
          asl
          tax
          lda playerHealth,x
          sta temp1

          ;; Check if Player 3 is eliminated (health = 0)

          ;; if playerCharacter[2] = NoCharacter then jmp P3UseAA
          lda temp1
          cmp # 0
          bne P3ConvertHealth
          jmp P3UseAA
P3ConvertHealth:


          ;; Clamp health to valid range

          ;; If PlayerHealthMax - 1 < temp1, set temp1 = PlayerHealthMax - 1          lda PlayerHealthMax          sec          sbc 1          sta temp1
          jmp P3ConvertHealth



.pend

P3UseAA .proc

          ;; Player 3 inactive/eliminated - use $ee (displays as ’  ’)
          ;; Returns: Far (return otherbank)

          lda $ee
          sta temp4

          jmp P4GetHealth



P3ConvertHealth

          ;; Convert Player 3 health to packed BCD (00-99)
          ;; Returns: Far (return otherbank)

          jsr ConvertToBCD

          ;; temp4 now contains P3 health as BCD (e.g., $75 for 75)

          lda temp1
          sta temp4



.pend

P4GetHealth .proc

          ;; Get Player 4 health (0-100), clamp to 99
          ;; Returns: Far (return otherbank)

          ;; Use $ee (displays as ’  ’) if inactive

          ;; (playerCharacter = NoCharacter) or eliminated

          ;; Set temp2 = playerHealth[3]
          lda 3
          asl
          tax
          lda playerHealth,x
          sta temp2

          ;; Check if Player 4 is eliminated (health = 0)

          ;; if playerCharacter[3] = NoCharacter then jmp P4UseAA
          lda temp2
          cmp # 0
          bne ClampPlayer4Health
          jmp P4UseAA
ClampPlayer4Health:


          ;; Clamp health to valid range

          lda temp2
          cmp # 100
          bcc P4ConvertHealth
          lda # 99
          sta temp2
P4ConvertHealth:


          jmp P4ConvertHealth



.pend

P4UseAA .proc

          ;; Player 4 inactive/eliminated - use $ee (displays as ’  ’)
          ;; Returns: Far (return otherbank)

          lda $ee
          sta temp5

          jmp SetScoreBytes



P4ConvertHealth

          ;; Convert Player 4 health to packed BCD (00-99)
          ;; Returns: Far (return otherbank)

          lda temp2
          sta temp1

          jsr ConvertToBCD

          ;; temp5 now contains P4 health as BCD (e.g., $50 for 50)

          lda temp1
          sta temp5



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

          if inactive/eliminated

          ;; Note: $ee and #$CF are invalid BCD but display as hex

          ;; characters via score font



          ;; Set score bytes directly (no BCD arithmetic needed - we

          ;; already have BCD or bad BCD values)

          ;; Write raw byte values: $ee/$CF/$ee or health BCD values


          ;; TODO: #1265 lda temp4

          ;; TODO: #1265 sta score

          ;; TODO: #1265 ; Middle 2 digits always "CF" (literal hex - bad BCD)

          ;; TODO: #1265 lda # $CF

          ;; TODO: #1265 sta score+1

          ;; TODO: #1265 lda temp5

          ;; TODO: #1265 sta score+2




          ;; Score colors are now set directly in MultiSpriteKernel.s
          ;; Note: These assignments are obsolete - colors set in MultiSpriteKernel.s
          lda # ColIndigo(12)
          sta COLUP0
          lda # ColRed(12)
          sta COLUP1
          lda # ColIndigo(12)
          sta COLUPF

          ;; (Issue #600 - completed)



          jmp BS_return



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


          ;; TODO: #1265 lda # $CF

          ;; TODO: #1265 sta score

          ;; TODO: #1265 lda # $20

          ;; TODO: #1265 sta score+1

          ;; TODO: #1265 lda # $26

          ;; TODO: #1265 sta score+2




          ;; Score colors are set directly in MultiSpriteKernel.s

          ;; (Issue #600 - completed)



          jmp BS_return

.pend

