          rem ChaosFight - Source/Routines/HealthBarSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem HEALTH BAR SYSTEM USING PFSCORE

          rem Uses batariBasic built-in score display system to show
          rem
          rem   health bars
          rem P1/P2 health displayed as score bars at top of screen
          rem P3/P4 health will be implemented separately

          rem Health Bar Thresholds And Patterns
          rem Health thresholds split on 12s: 12, 24, 36, 48, 60, 72, 84
          rem Compare health starting from 84 downward to find pixel
          rem   count
          rem Bit patterns: 0-8 pixels filled from right to left
          rem NOTE: HealthThresholds table removed - code uses hardcoded
          rem thresholds

          rem Bit pattern table for 0-8 pixels (right-aligned fill)
          rem 0 pixels = %00000000, 1 pixel = %00000001, ..., 8 pixels =
          rem   %11111111

UpdatePlayer1HealthBar
          rem
          rem Update Player 1 health bar (pfscore1).
          rem Input: temp1 = health value (0-100)
          rem        PlayerHealthMax (constant) = maximum health value
          rem        HealthBarPatterns (ROM constant, bank8) = bit
          rem        pattern table
          rem
          rem Output: pfscore1 set to health bar pattern (8 pixels, bit
          rem pattern)
          rem
          rem Mutates: temp1 (clamped to PlayerHealthMax), temp2
          rem (pattern index), temp3 (pattern value),
          rem         pfscore1 (TIA register)
          rem
          rem Called Routines: None (reads ROM data table)
          rem Constraints: Must be colocated with P1SetPattern (called via goto)
          rem Clamp health to valid range
          rem Note: < 0 check removed - unsigned bytes cannot be
          rem negative
          if temp1 > PlayerHealthMax then temp1 = PlayerHealthMax

          rem Compare health against thresholds starting from 83
          rem   downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2
          rem   pixels, 0-11 = 0 pixels
          let temp2 = 0
          rem patternIndex will hold the pattern index (0-8)

          rem Check thresholds from highest (83) to lowest (11)
          rem 84-100 = 8 pixels
          if temp1 > 83 then temp2 = 8 : goto P1SetPattern
          rem 72-83 = 7 pixels
          if temp1 > 71 then temp2 = 7 : goto P1SetPattern
          rem 60-71 = 6 pixels
          if temp1 > 59 then temp2 = 6 : goto P1SetPattern
          rem 48-59 = 5 pixels
          if temp1 > 47 then temp2 = 5 : goto P1SetPattern
          rem 36-47 = 4 pixels
          if temp1 > 35 then temp2 = 4 : goto P1SetPattern
          rem 24-35 = 3 pixels
          if temp1 > 23 then temp2 = 3 : goto P1SetPattern
          rem 12-23 = 2 pixels
          if temp1 > 11 then temp2 = 2 : goto P1SetPattern
          rem 0-11 = 0 pixels (patternIndex already 0)

P1SetPattern
          rem Look up bit pattern from table and set pfscore1
          rem
          rem Input: temp2 (from UpdatePlayer1HealthBar),
          rem HealthBarPatterns (ROM constant, bank8)
          rem
          rem Output: pfscore1 set to health bar pattern
          rem
          rem Mutates: temp3 (pattern value), pfscore1 (TIA register)
          rem
          rem Called Routines: None (reads ROM data table)
          rem
          rem Constraints: Must be colocated with UpdatePlayer1HealthBar
          rem Look up bit pattern from table using patternIndex as index
          rem Note: HealthBarPatterns is in same bank (Bank 8) as this
          rem function, so no bank prefix needed
          let temp3 = HealthBarPatterns[temp2]

          let pfscore1 = temp3
          rem Set pfscore1 to health bar pattern

          return

UpdatePlayer2HealthBar
          rem Update Player 2 health bar (pfscore2).
          rem Input: temp1 = health value (0-100)
          rem        PlayerHealthMax (constant) = maximum health value
          rem        HealthBarPatterns (ROM constant, bank8) = bit
          rem        pattern table
          rem
          rem Output: pfscore2 set to health bar pattern (8 pixels, bit
          rem pattern)
          rem
          rem Mutates: temp1 (clamped to PlayerHealthMax), temp2
          rem (pattern index), temp3 (pattern value),
          rem         pfscore2 (TIA register)
          rem
          rem Called Routines: None (reads ROM data table)
          rem Constraints: Must be colocated with P2SetPattern (called via goto)
          rem Clamp health to valid range
          rem Note: < 0 check removed - unsigned bytes cannot be
          rem negative
          if temp1 > PlayerHealthMax then temp1 = PlayerHealthMax

          rem Compare health against thresholds starting from 83
          rem   downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2
          rem   pixels, 0-11 = 0 pixels
          let temp2 = 0
          rem patternIndex will hold the pattern index (0-8)

          rem Check thresholds from highest (83) to lowest (11)
          rem 84-100 = 8 pixels
          if temp1 > 83 then temp2 = 8 : goto P2SetPattern
          rem 72-83 = 7 pixels
          if temp1 > 71 then temp2 = 7 : goto P2SetPattern
          rem 60-71 = 6 pixels
          if temp1 > 59 then temp2 = 6 : goto P2SetPattern
          rem 48-59 = 5 pixels
          if temp1 > 47 then temp2 = 5 : goto P2SetPattern
          rem 36-47 = 4 pixels
          if temp1 > 35 then temp2 = 4 : goto P2SetPattern
          rem 24-35 = 3 pixels
          if temp1 > 23 then temp2 = 3 : goto P2SetPattern
          rem 12-23 = 2 pixels
          if temp1 > 11 then temp2 = 2 : goto P2SetPattern
          rem 0-11 = 0 pixels (patternIndex already 0)

P2SetPattern
          rem Look up bit pattern from table and set pfscore2
          rem
          rem Input: temp2 (from UpdatePlayer2HealthBar),
          rem HealthBarPatterns (ROM constant, bank8)
          rem
          rem Output: pfscore2 set to health bar pattern
          rem
          rem Mutates: temp3 (pattern value), pfscore2 (TIA register)
          rem
          rem Called Routines: None (reads ROM data table)
          rem
          rem Constraints: Must be colocated with UpdatePlayer2HealthBar
          rem Look up bit pattern from table using patternIndex as index
          rem Note: HealthBarPatterns is in same bank (Bank 8) as this
          rem function, so no bank prefix needed
          let temp3 = HealthBarPatterns[temp2]

          let pfscore2 = temp3
          rem Set pfscore2 to health bar pattern

          return

UpdatePlayer12HealthBars
          rem Update both P1 and P2 health bars
          rem
          rem Input: playerHealth[0] and playerHealth[1] arrays
          rem Update both Player 1 and Player 2 health bars
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem
          rem Output: pfscore1, pfscore2 updated
          rem
          rem Mutates: temp1 (passed to
          rem UpdatePlayer1HealthBar/UpdatePlayer2HealthBar),
          rem         pfscore1, pfscore2 (TIA registers, via
          rem         UpdatePlayer1HealthBar/UpdatePlayer2HealthBar)
          rem
          rem Called Routines: UpdatePlayer1HealthBar - accesses temp1,
          rem HealthBarPatterns,
          rem   UpdatePlayer2HealthBar - accesses temp1,
          rem   HealthBarPatterns
          rem Constraints: Tail call to UpdatePlayer2HealthBar
          let temp1 = playerHealth[0]
          rem Update P1 health bar
          gosub UpdatePlayer1HealthBar

          let temp1 = playerHealth[1]
          rem Update P2 health bar
          goto UpdatePlayer2HealthBar
          rem tail call


InitializeHealthBars
          asm
InitializeHealthBars
end
          rem Initialize health bars at game start
          rem Initialize health bars at game start - set to full (100%)
          rem
          rem Input: PlayerHealthMax (constant) = maximum health value
          rem
          rem Output: pfscore1, pfscore2 set to full health pattern
          rem
          rem Mutates: temp1 (passed to
          rem UpdatePlayer1HealthBar/UpdatePlayer2HealthBar),
          rem         pfscore1, pfscore2 (TIA registers, via
          rem         UpdatePlayer1HealthBar/UpdatePlayer2HealthBar)
          rem
          rem Called Routines: UpdatePlayer1HealthBar - accesses temp1,
          rem HealthBarPatterns,
          rem   UpdatePlayer2HealthBar - accesses temp1,
          rem   HealthBarPatterns
          rem Constraints: Tail call to UpdatePlayer2HealthBar
          let temp1 = PlayerHealthMax
          rem Set initial health bars to full (100%)
          gosub UpdatePlayer1HealthBar
          rem tail call
          goto UpdatePlayer2HealthBar

          rem
          rem P3/p4 HEALTH DISPLAY (score Mode)
          rem Display players 3 and 4 health as 2-digit numbers in score
          rem   area
          rem Format: AACFAA where:
          rem Left 2 digits (AA): Player 3 health (00-99 in BCD) or $AA if inactive/eliminated
          rem Middle 2 digits (CF): Literal CF ($CF - bad BCD displays
          rem   as hex)
          rem Right 2 digits (AA): Player 4 health (00-99 in BCD) or $AA if inactive/eliminated
          rem Score display uses 6 digits total (3 bytes)
          rem Uses bad BCD technique: $AA and $CF are invalid BCD but
          rem   display as hex characters
UpdatePlayer34HealthBars

          rem Check if Quadtari is present
          if (controllerStatus & SetQuadtariDetected) = 0 then goto DisplayCF2025
          rem If no Quadtari, display CF2025 instead of player health

          if (controllerStatus & SetPlayers34Active) = 0 then return
          rem Only update player health if players 3 or 4 are active

          rem Get Player 3 health (0-100), clamp to 99
          rem Use $AA (bad BCD displays as AA) if inactive
          let temp1 = playerHealth[2]
          rem (playerCharacter = NoCharacter) or eliminated
          if playerCharacter[2] = NoCharacter then goto P3UseAA
          rem Check if Player 3 is eliminated (bit 2 of playersEliminated = 4)
          let temp3 = playersEliminated_R & PlayerEliminatedPlayer2
          if temp3 then goto P3UseAA
          if PlayerHealthMax - 1 < temp1 then temp1 = PlayerHealthMax - 1
          rem Clamp health to valid range
          goto P3ConvertHealth

P3UseAA
          rem Player 3 inactive/eliminated - use $AA (bad BCD displays as AA)
          let temp4 = $AA
          goto P4GetHealth

P3ConvertHealth
          rem Convert Player 3 health to packed BCD (00-99)
          let temp6 = 0
P3ConvertLoop
          if temp1 < 10 then goto P3Finalize
          let temp1 = temp1 - 10
          let temp6 = temp6 + 1
          goto P3ConvertLoop
P3Finalize
          let temp4 = temp6 * 16
          let temp4 = temp4 + temp1
          rem p3BCD now contains P3 health as BCD (e.g., $75 for 75)

P4GetHealth
          rem Get Player 4 health (0-100), clamp to 99
          rem Use $AA (bad BCD displays as AA) if inactive
          let temp2 = playerHealth[3]
          rem (playerCharacter = NoCharacter) or eliminated
          if playerCharacter[3] = NoCharacter then goto P4UseAA
          rem Check if Player 4 is eliminated (bit 3 of playersEliminated = 8)
          let temp3 = playersEliminated_R & PlayerEliminatedPlayer3
          if temp3 then goto P4UseAA
          if temp2 > 99 then temp2 = 99
          rem Clamp health to valid range
          goto P4ConvertHealth

P4UseAA
          rem Player 4 inactive/eliminated - use $AA (bad BCD displays as AA)
          let temp5 = $AA
          goto SetScoreBytes

P4ConvertHealth
          rem Convert Player 4 health to packed BCD (00-99)
          let temp6 = 0
P4ConvertLoop
          if temp2 < 10 then goto P4Finalize
          let temp2 = temp2 - 10
          let temp6 = temp6 + 1
          goto P4ConvertLoop
P4Finalize
          let temp5 = temp6 * 16
          let temp5 = temp5 + temp2
          rem p4BCD now contains P4 health as BCD (e.g., $50 for 50)

SetScoreBytes
          rem Set score for AACFAA format using bad BCD values
          rem Format: score (digits 0-1), score+1 (digits 2-3), score+2
          rem   (digits 4-5)
          rem score (high byte, digits 0-1) = P3 BCD ($00-$99) OR $AA if
          rem   inactive/eliminated
          rem score+1 (middle byte, digits 2-3) = $CF (literal CF -
          rem   bad BCD)
          rem score+2 (low byte, digits 4-5) = P4 BCD ($00-$99) OR $AA
          rem   if inactive/eliminated
          rem Note: $AA and $CF are invalid BCD but display as hex
          rem   characters via score font

          rem Set score bytes directly (no BCD arithmetic needed - we
          rem   already have BCD or bad BCD values)
          rem Write raw byte values: $AA/$CF/$AA or health BCD values
          asm
            LDA temp4
            STA score
            ; Middle 2 digits always "CF" (literal hex - bad BCD)
            LDA # $CF
            STA score+1
            LDA temp5
            STA score+2
end

          rem Set score colors for score mode
          rem Left side (Player 3): indigo, Right side (Player 4): red
          rem In multisprite kernel, scorecolor applies to the score
          rem   area
          rem Note: Per-side colors may require additional kernel
          rem   support
          rem For now, set to white (Neutral color)
          rem TODO: Investigate if multisprite kernel supports separate
          let scorecolor = ColGrey(14)
          rem   left/right score colors (Issue #600)

          return

DisplayCF2025
          rem No Quadtari detected - display CF2025 using bad BCD
          rem   values
          rem Format: CF2025 = $CF $20 $25 (bad BCD displays as hex
          rem   characters)
          rem score (digits 0-1) = $CF (CF)
          rem score+1 (digits 2-3) = $20 (20)
          rem score+2 (digits 4-5) = $25 (25)
          asm
            LDA # $CF
            STA score
            LDA # $20
            STA score+1
            LDA # $25
            STA score+2
end

          let scorecolor = ColGrey(14)
          rem Set score color to white

          return
