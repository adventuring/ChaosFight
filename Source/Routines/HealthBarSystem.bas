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
          data HealthBarPatterns
              %00000000
              %00000001
              %00000011
              %00000111
              %00001111
              %00011111
              %00111111
              %01111111
              %11111111
end

UpdatePlayer1HealthBar
          rem
          rem UPDATE PLAYER 1 HEALTH BAR
          rem
          rem Input: temp1 = health value (0-100)
          rem
          rem Output: pfscore1 = health bar pattern (8 pixels, bit
          rem   pattern)
          rem Uses simple comparisons against threshold table, looks up
          rem   bit pattern
          rem Update Player 1 health bar using pfscore1
          rem
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
          dim UP1HB_health = temp1 : rem Constraints: Must be colocated with P1SetPattern (called via goto)
          dim UP1HB_patternIndex = temp2
          dim UP1HB_pattern = temp3
          rem Clamp health to valid range
          rem Note: < 0 check removed - unsigned bytes cannot be
          if UP1HB_health > PlayerHealthMax then let UP1HB_health = PlayerHealthMax : rem   negative
          
          rem Compare health against thresholds starting from 83
          rem   downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2
          rem   pixels, 0-11 = 0 pixels
          let UP1HB_patternIndex = 0 : rem patternIndex will hold the pattern index (0-8)
          
          rem Check thresholds from highest (83) to lowest (11)
          if UP1HB_health > 83 then let UP1HB_patternIndex = 8 : goto P1SetPattern : rem 84-100 = 8 pixels
          if UP1HB_health > 71 then let UP1HB_patternIndex = 7 : goto P1SetPattern : rem 72-83 = 7 pixels
          if UP1HB_health > 59 then let UP1HB_patternIndex = 6 : goto P1SetPattern : rem 60-71 = 6 pixels
          if UP1HB_health > 47 then let UP1HB_patternIndex = 5 : goto P1SetPattern : rem 48-59 = 5 pixels
          if UP1HB_health > 35 then let UP1HB_patternIndex = 4 : goto P1SetPattern : rem 36-47 = 4 pixels
          if UP1HB_health > 23 then let UP1HB_patternIndex = 3 : goto P1SetPattern : rem 24-35 = 3 pixels
          if UP1HB_health > 11 then let UP1HB_patternIndex = 2 : goto P1SetPattern : rem 12-23 = 2 pixels
          rem 0-11 = 0 pixels (patternIndex already 0)
          
P1SetPattern
          rem Look up bit pattern from table and set pfscore1
          rem
          rem Input: UP1HB_patternIndex (from UpdatePlayer1HealthBar),
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
          let UP1HB_pattern = HealthBarPatterns[UP1HB_patternIndex]
          
          let pfscore1 = UP1HB_pattern : rem Set pfscore1 to health bar pattern
          
          return

UpdatePlayer2HealthBar
          rem
          rem UPDATE PLAYER 2 HEALTH BAR
          rem
          rem Input: temp1 = health value (0-100)
          rem
          rem Output: pfscore2 = health bar pattern (8 pixels, bit
          rem   pattern)
          rem Uses simple comparisons against threshold table, looks up
          rem   bit pattern
          rem Update Player 2 health bar using pfscore2
          rem
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
          dim UP2HB_health = temp1 : rem Constraints: Must be colocated with P2SetPattern (called via goto)
          dim UP2HB_patternIndex = temp2
          dim UP2HB_pattern = temp3
          rem Clamp health to valid range
          rem Note: < 0 check removed - unsigned bytes cannot be
          if UP2HB_health > PlayerHealthMax then let UP2HB_health = PlayerHealthMax : rem   negative
          
          rem Compare health against thresholds starting from 83
          rem   downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2
          rem   pixels, 0-11 = 0 pixels
          let UP2HB_patternIndex = 0 : rem patternIndex will hold the pattern index (0-8)
          
          rem Check thresholds from highest (83) to lowest (11)
          if UP2HB_health > 83 then let UP2HB_patternIndex = 8 : goto P2SetPattern : rem 84-100 = 8 pixels
          if UP2HB_health > 71 then let UP2HB_patternIndex = 7 : goto P2SetPattern : rem 72-83 = 7 pixels
          if UP2HB_health > 59 then let UP2HB_patternIndex = 6 : goto P2SetPattern : rem 60-71 = 6 pixels
          if UP2HB_health > 47 then let UP2HB_patternIndex = 5 : goto P2SetPattern : rem 48-59 = 5 pixels
          if UP2HB_health > 35 then let UP2HB_patternIndex = 4 : goto P2SetPattern : rem 36-47 = 4 pixels
          if UP2HB_health > 23 then let UP2HB_patternIndex = 3 : goto P2SetPattern : rem 24-35 = 3 pixels
          if UP2HB_health > 11 then let UP2HB_patternIndex = 2 : goto P2SetPattern : rem 12-23 = 2 pixels
          rem 0-11 = 0 pixels (patternIndex already 0)
          
P2SetPattern
          rem Look up bit pattern from table and set pfscore2
          rem
          rem Input: UP2HB_patternIndex (from UpdatePlayer2HealthBar),
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
          let UP2HB_pattern = HealthBarPatterns[UP2HB_patternIndex]
          
          let pfscore2 = UP2HB_pattern : rem Set pfscore2 to health bar pattern
          
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
          dim UP12HB_health = temp1 : rem Constraints: Tail call to UpdatePlayer2HealthBar
          let UP12HB_health = playerHealth[0] : rem Update P1 health bar
          let temp1 = UP12HB_health
          gosub UpdatePlayer1HealthBar
          
          let UP12HB_health = playerHealth[1] : rem Update P2 health bar
          let temp1 = UP12HB_health
          goto UpdatePlayer2HealthBar : rem tail call
          
          
InitializeHealthBars
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
          dim IHB_health = temp1
          rem Constraints: Tail call to UpdatePlayer2HealthBar
          let IHB_health = PlayerHealthMax
          rem Set initial health bars to full (100%)
          let temp1 = IHB_health
          gosub UpdatePlayer1HealthBar
          let temp1 = IHB_health
          rem tail call
          goto UpdatePlayer2HealthBar

          rem
          rem P3/p4 HEALTH DISPLAY (score Mode)
          rem Display players 3 and 4 health as 2-digit numbers in score
          rem   area
          rem Format: AACFAA where:
          rem Left 2 digits (AA): Player 3 health (00-99 in BCD) OR $AA
          rem   if inactive/eliminated
          rem Middle 2 digits (CF): Literal CF ($CF - bad BCD displays
          rem   as hex)
          rem Right 2 digits (AA): Player 4 health (00-99 in BCD) OR $AA
          rem   if inactive/eliminated
          rem Score display uses 6 digits total (3 bytes)
          rem Uses bad BCD technique: $AA and $CF are invalid BCD but
          rem   display as hex characters
UpdatePlayer34HealthBars
          dim UHB_player3Health = temp1
          dim UHB_player4Health = temp2
          dim UHB_isEliminated = temp3
          dim UHB_player3BCD = temp4
          dim UHB_player4BCD = temp5
          dim UHB_tensCounter = temp6
          
          rem Check if Quadtari is present
          if !(controllerStatus & SetQuadtariDetected) then goto DisplayCF2025
          rem If no Quadtari, display CF2025 instead of player health
          
          if !(controllerStatus & SetPlayers34Active) then return
          rem Only update player health if players 3 or 4 are active
          
          rem Get Player 3 health (0-100), clamp to 99
          rem Use $AA (bad BCD displays as AA) if inactive
          let UHB_player3Health = playerHealth[2]
          rem (selectedCharacter = 255) or eliminated
          if selectedCharacter3_R = 255 then goto P3UseAA
          rem Check if Player 3 is eliminated (bit 2 of playersEliminated = 4)
          let UHB_isEliminated = playersEliminated_R & PlayerEliminatedPlayer2
          if UHB_isEliminated then goto P3UseAA
          if PlayerHealthMax - 1 < UHB_player3Health then let UHB_player3Health = PlayerHealthMax - 1
          rem Clamp health to valid range
          goto P3ConvertHealth
          
P3UseAA
          rem Player 3 inactive/eliminated - use $AA (bad BCD displays as AA)
          let UHB_player3BCD = $AA
          goto P4GetHealth
          
P3ConvertHealth
          rem Convert Player 3 health to packed BCD (00-99)
          let UHB_tensCounter = 0
P3ConvertLoop
          if UHB_player3Health < 10 then goto P3Finalize
          let UHB_player3Health = UHB_player3Health - 10
          let UHB_tensCounter = UHB_tensCounter + 1
          goto P3ConvertLoop
P3Finalize
          let UHB_player3BCD = UHB_tensCounter * 16
          let UHB_player3BCD = UHB_player3BCD + UHB_player3Health
          rem p3BCD now contains P3 health as BCD (e.g., $75 for 75)
          
P4GetHealth
          rem Get Player 4 health (0-100), clamp to 99
          rem Use $AA (bad BCD displays as AA) if inactive
          let UHB_player4Health = playerHealth[3]
          rem (selectedCharacter = 255) or eliminated
          if selectedCharacter4_R = 255 then goto P4UseAA
          rem Check if Player 4 is eliminated (bit 3 of playersEliminated = 8)
          let UHB_isEliminated = playersEliminated_R & PlayerEliminatedPlayer3
          if UHB_isEliminated then goto P4UseAA
          if UHB_player4Health > 99 then let UHB_player4Health = 99
          rem Clamp health to valid range
          goto P4ConvertHealth
          
P4UseAA
          rem Player 4 inactive/eliminated - use $AA (bad BCD displays as AA)
          let UHB_player4BCD = $AA
          goto SetScoreBytes
          
P4ConvertHealth
          rem Convert Player 4 health to packed BCD (00-99)
          let UHB_tensCounter = 0
P4ConvertLoop
          if UHB_player4Health < 10 then goto P4Finalize
          let UHB_player4Health = UHB_player4Health - 10
          let UHB_tensCounter = UHB_tensCounter + 1
          goto P4ConvertLoop
P4Finalize
          let UHB_player4BCD = UHB_tensCounter * 16
          let UHB_player4BCD = UHB_player4BCD + UHB_player4Health
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
            LDA UHB_player3BCD
            STA score
            ; Middle 2 digits always "CF" (literal hex - bad BCD)
            LDA # $CF
            STA score+1
            LDA UHB_player4BCD
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
          let scorecolor = ColGrey(14) : rem   left/right score colors (Issue #600)
          
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
          
          let scorecolor = ColGrey(14) : rem Set score color to white
          
          return
