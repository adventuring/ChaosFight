          rem ChaosFight - Source/Routines/HealthBarSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem HEALTH BAR SYSTEM USING PFSCORE

          rem Uses batariBasic built-in score display system to show
          rem   health bars
          rem P1/P2 health displayed as score bars at top of screen
          rem P3/P4 health will be implemented separately

          rem ==========================================================
          rem HEALTH BAR THRESHOLDS AND PATTERNS
          rem ==========================================================
          rem Health thresholds split on 12s: 12, 24, 36, 48, 60, 72, 84
          rem Compare health starting from 84 downward to find pixel
          rem   count
          rem Bit patterns: 0-8 pixels filled from right to left
          rem ==========================================================

          rem Health threshold table (split on 12s)
          data HealthThresholds
              84, 72, 60, 48, 36, 24, 12
          end

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

          rem ==========================================================
          rem UPDATE PLAYER 1 HEALTH BAR
          rem ==========================================================
          rem Input: temp1 = health value (0-100)
          rem Output: pfscore1 = health bar pattern (8 pixels, bit
          rem   pattern)
          rem Uses simple comparisons against threshold table, looks up
          rem   bit pattern
UpdatePlayer1HealthBar
          dim UP1HB_health = temp1
          dim UP1HB_patternIndex = temp2
          dim UP1HB_pattern = temp3
          rem Clamp health to valid range
          rem Note: < 0 check removed - unsigned bytes cannot be
          rem   negative
          if UP1HB_health > PlayerHealthMax then let UP1HB_health = PlayerHealthMax
          
          rem Compare health against thresholds starting from 83
          rem   downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2
          rem   pixels, 0-11 = 0 pixels
          rem patternIndex will hold the pattern index (0-8)
          let UP1HB_patternIndex = 0
          
          rem Check thresholds from highest (83) to lowest (11)
          rem 84-100 = 8 pixels
          if UP1HB_health > 83 then let UP1HB_patternIndex = 8 : goto P1SetPattern
          rem 72-83 = 7 pixels
          if UP1HB_health > 71 then let UP1HB_patternIndex = 7 : goto P1SetPattern
          rem 60-71 = 6 pixels
          if UP1HB_health > 59 then let UP1HB_patternIndex = 6 : goto P1SetPattern
          rem 48-59 = 5 pixels
          if UP1HB_health > 47 then let UP1HB_patternIndex = 5 : goto P1SetPattern
          rem 36-47 = 4 pixels
          if UP1HB_health > 35 then let UP1HB_patternIndex = 4 : goto P1SetPattern
          rem 24-35 = 3 pixels
          if UP1HB_health > 23 then let UP1HB_patternIndex = 3 : goto P1SetPattern
          rem 12-23 = 2 pixels
          if UP1HB_health > 11 then let UP1HB_patternIndex = 2 : goto P1SetPattern
          rem 0-11 = 0 pixels (patternIndex already 0)
          
P1SetPattern
          rem Look up bit pattern from table using patternIndex as index
          let UP1HB_pattern = HealthBarPatterns[UP1HB_patternIndex]
          
          rem Set pfscore1 to health bar pattern
          let pfscore1 = UP1HB_pattern
          
          return

          rem ==========================================================
          rem UPDATE PLAYER 2 HEALTH BAR
          rem ==========================================================
          rem Input: temp1 = health value (0-100)
          rem Output: pfscore2 = health bar pattern (8 pixels, bit
          rem   pattern)
          rem Uses simple comparisons against threshold table, looks up
          rem   bit pattern
UpdatePlayer2HealthBar
          dim UP2HB_health = temp1
          dim UP2HB_patternIndex = temp2
          dim UP2HB_pattern = temp3
          rem Clamp health to valid range
          rem Note: < 0 check removed - unsigned bytes cannot be
          rem   negative
          if UP2HB_health > PlayerHealthMax then let UP2HB_health = PlayerHealthMax
          
          rem Compare health against thresholds starting from 83
          rem   downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2
          rem   pixels, 0-11 = 0 pixels
          rem patternIndex will hold the pattern index (0-8)
          let UP2HB_patternIndex = 0
          
          rem Check thresholds from highest (83) to lowest (11)
          rem 84-100 = 8 pixels
          if UP2HB_health > 83 then let UP2HB_patternIndex = 8 : goto P2SetPattern
          rem 72-83 = 7 pixels
          if UP2HB_health > 71 then let UP2HB_patternIndex = 7 : goto P2SetPattern
          rem 60-71 = 6 pixels
          if UP2HB_health > 59 then let UP2HB_patternIndex = 6 : goto P2SetPattern
          rem 48-59 = 5 pixels
          if UP2HB_health > 47 then let UP2HB_patternIndex = 5 : goto P2SetPattern
          rem 36-47 = 4 pixels
          if UP2HB_health > 35 then let UP2HB_patternIndex = 4 : goto P2SetPattern
          rem 24-35 = 3 pixels
          if UP2HB_health > 23 then let UP2HB_patternIndex = 3 : goto P2SetPattern
          rem 12-23 = 2 pixels
          if UP2HB_health > 11 then let UP2HB_patternIndex = 2 : goto P2SetPattern
          rem 0-11 = 0 pixels (patternIndex already 0)
          
P2SetPattern
          rem Look up bit pattern from table using patternIndex as index
          let UP2HB_pattern = HealthBarPatterns[UP2HB_patternIndex]
          
          rem Set pfscore2 to health bar pattern
          let pfscore2 = UP2HB_pattern
          
          return

          rem Update both P1 and P2 health bars
          rem Input: playerHealth[0] and playerHealth[1] arrays
UpdatePlayer12HealthBars
          dim UP12HB_health = temp1
          rem Update P1 health bar
          let UP12HB_health = playerHealth[0]
          let temp1 = UP12HB_health
          gosub UpdatePlayer1HealthBar
          
          rem Update P2 health bar  
          let UP12HB_health = playerHealth[1]
          let temp1 = UP12HB_health
          rem tail call
          goto UpdatePlayer2HealthBar
          

          rem Initialize health bars at game start
InitializeHealthBars
          dim IHB_health = temp1
          rem Set initial health bars to full (100%)
          let IHB_health = PlayerHealthMax
          let temp1 = IHB_health
          gosub UpdatePlayer1HealthBar
          let temp1 = IHB_health
          rem tail call
          goto UpdatePlayer2HealthBar

          rem ==========================================================
          rem P3/P4 HEALTH DISPLAY (SCORE MODE)
          rem ==========================================================
          rem Display players 3 and 4 health as 2-digit numbers in score
          rem   area
          rem Format: AACFAA where:
          rem Left 2 digits (AA): Player 3 health (00-99 in BCD) OR $AA
          rem   if inactive/eliminated
          rem Middle 2 digits (CF): Literal "CF" ($CF - bad BCD displays
          rem   as hex)
          rem Right 2 digits (AA): Player 4 health (00-99 in BCD) OR $AA
          rem   if inactive/eliminated
          rem Score display uses 6 digits total (3 bytes)
          rem Uses "bad BCD" technique: $AA and $CF are invalid BCD but
          rem   display as hex characters

UpdatePlayer34HealthBars
          dim UP34HB_p3Health = temp1
          dim UP34HB_p4Health = temp2
          dim UP34HB_isEliminated = temp3
          dim UP34HB_p3Tens = temp3
          dim UP34HB_p3Ones = temp4
          dim UP34HB_p3BCD = temp5
          dim UP34HB_p4Tens = temp6
          dim UP34HB_p4Ones = temp7
          
          rem Check if Quadtari is present
          rem If no Quadtari, display "CF2025" instead of player health
          if !(controllerStatus & SetQuadtariDetected) then goto DisplayCF2025
          
          rem Only update player health if players 3 or 4 are active
          if !(controllerStatus & SetPlayers34Active) then return
          
          rem Get Player 3 health (0-100), clamp to 99
          rem Use $AA (bad BCD displays as "AA") if inactive
          rem   (selectedChar = 255) or eliminated
          let UP34HB_p3Health = playerHealth[2]
          if selectedChar3_R = 255 then goto P3UseAA
          rem Check if Player 3 is eliminated (bit 2 of
          rem   playersEliminated = 4)
          let UP34HB_isEliminated = PlayerEliminatedPlayer2 & playersEliminated_R
          if UP34HB_isEliminated then goto P3UseAA
          rem Clamp health to valid range
          if PlayerHealthMax - 1 < UP34HB_p3Health then let UP34HB_p3Health = PlayerHealthMax - 1
          goto P3ConvertHealth
          
P3UseAA
          rem Player 3 inactive/eliminated - use $AA (bad BCD displays
          rem   as "AA")
          let UP34HB_p3BCD = $AA
          goto P4GetHealth
          
P3ConvertHealth
          rem Convert Player 3 health to BCD format (00-99)
          rem Calculate P3 health in BCD format (tens and ones digits)
          let UP34HB_p3Tens = UP34HB_p3Health / 10
          rem Tens digit (0-9)
          rem Calculate ones digit: p3Health - (p3Tens * 10)
          rem Multiply p3Tens by 10 using assembly: 10 = 8 + 2
          asm
            lda UP34HB_p3Tens
            sta temp8
            asl a
            asl a
            asl a
            clc
            adc temp8
            asl a
            sta temp8
          end
          rem temp8 = p3Tens * 10
          let UP34HB_p3Ones = UP34HB_p3Health - temp8
          rem Ones digit (0-9)
          rem Combine into BCD: tens * 16 + ones (BCD format)
          let UP34HB_p3BCD = UP34HB_p3Tens * 16
          let UP34HB_p3BCD = UP34HB_p3BCD + UP34HB_p3Ones
          rem p3BCD now contains P3 health as BCD (e.g., $75 for 75)
          
P4GetHealth
          rem Get Player 4 health (0-100), clamp to 99
          rem Use $AA (bad BCD displays as "AA") if inactive
          rem   (selectedChar = 255) or eliminated
          let UP34HB_p4Health = playerHealth[3]
          if selectedChar4_R = 255 then goto P4UseAA
          rem Check if Player 4 is eliminated (bit 3 of
          rem   playersEliminated = 8)
          let UP34HB_isEliminated = PlayerEliminatedPlayer3 & playersEliminated_R
          if UP34HB_isEliminated then goto P4UseAA
          rem Clamp health to valid range
          if UP34HB_p4Health > 99 then let UP34HB_p4Health = 99
          goto P4ConvertHealth
          
P4UseAA
          rem Player 4 inactive/eliminated - use $AA (bad BCD displays
          rem   as "AA")
          rem Reuse UP34HB_p4Tens variable to hold $AA value
          let UP34HB_p4Tens = $AA
          goto SetScoreBytes
          
P4ConvertHealth
          rem Convert binary health values to BCD and set score
          rem Use binary-to-decimal conversion: divide by 10 to extract
          rem   tens and ones
          rem Calculate P4 health in BCD format
          let UP34HB_p4Tens = UP34HB_p4Health / 10
          rem Tens digit (0-9)
          rem Calculate ones digit: p4Health - (p4Tens * 10)
          rem Multiply p4Tens by 10 using assembly: 10 = 8 + 2
          asm
            lda UP34HB_p4Tens
            sta temp8
            asl a
            asl a
            asl a
            clc
            adc temp8
            asl a
            sta temp8
          end
          rem temp8 = p4Tens * 10
          let UP34HB_p4Ones = UP34HB_p4Health - temp8
          rem Ones digit (0-9)
          rem Combine into BCD: tens * 16 + ones
          let UP34HB_p4Tens = UP34HB_p4Tens * 16
          let UP34HB_p4Tens = UP34HB_p4Tens + UP34HB_p4Ones
          rem p4Tens now contains P4 health as BCD (e.g., $50 for 50)
          
SetScoreBytes
          rem Set score for AACFAA format using "bad BCD" values
          rem Format: score (digits 0-1), score+1 (digits 2-3), score+2
          rem   (digits 4-5)
          rem score (high byte, digits 0-1) = P3 BCD ($00-$99) OR $AA if
          rem   inactive/eliminated
          rem score+1 (middle byte, digits 2-3) = $CF (literal "CF" -
          rem   bad BCD)
          rem score+2 (low byte, digits 4-5) = P4 BCD ($00-$99) OR $AA
          rem   if inactive/eliminated
          rem Note: $AA and $CF are invalid BCD but display as hex
          rem   characters via score font
          
          rem Set score bytes directly (no BCD arithmetic needed - we
          rem   already have BCD or bad BCD values)
          rem Write raw byte values: $AA/$CF/$AA or health BCD values
          asm
            LDA UP34HB_p3BCD
            STA score
            rem Middle 2 digits always "CF" (literal hex - bad BCD)
            LDA # $CF
            STA score+1
            LDA UP34HB_p4Tens
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
          rem   left/right score colors (Issue #600)
          let scorecolor = ColGrey(14)
          
          return
          
DisplayCF2025
          rem No Quadtari detected - display "CF2025" using bad BCD
          rem   values
          rem Format: CF2025 = $CF $20 $25 (bad BCD displays as hex
          rem   characters)
          rem score (digits 0-1) = $CF ("CF")
          rem score+1 (digits 2-3) = $20 ("20")
          rem score+2 (digits 4-5) = $25 ("25")
          asm
            LDA # $CF
            STA score
            LDA # $20
            STA score+1
            LDA # $25
            STA score+2
          end
          
          rem Set score color to white
          let scorecolor = ColGrey(14)
          
          return
