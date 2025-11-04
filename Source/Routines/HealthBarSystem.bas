          rem ChaosFight - Source/Routines/HealthBarSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem HEALTH BAR SYSTEM USING PFSCORE

          rem Uses batariBasic built-in score display system to show health bars
          rem P1/P2 health displayed as score bars at top of screen
          rem P3/P4 health will be implemented separately

          rem =================================================================
          rem HEALTH BAR THRESHOLDS AND PATTERNS
          rem =================================================================
          rem Health thresholds split on 12s: 12, 24, 36, 48, 60, 72, 84
          rem Compare health starting from 84 downward to find pixel count
          rem Bit patterns: 0-8 pixels filled from right to left
          rem =================================================================

          rem Health threshold table (split on 12s)
          data HealthThresholds
              84, 72, 60, 48, 36, 24, 12
          end

          rem Bit pattern table for 0-8 pixels (right-aligned fill)
          rem 0 pixels = %00000000, 1 pixel = %00000001, ..., 8 pixels = %11111111
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

          rem =================================================================
          rem UPDATE PLAYER 1 HEALTH BAR
          rem =================================================================
    rem Input: temp1 = health value (0-100)
          rem Output: pfscore1 = health bar pattern (8 pixels, bit pattern)
          rem Uses simple comparisons against threshold table, looks up bit pattern
UpdatePlayer1HealthBar
          rem Clamp health to valid range
          if temp1 > PlayerHealthMax then LET temp1 = PlayerHealthMax
          if temp1 < 0 then LET temp1 = 0
          
          rem Compare health against thresholds starting from 83 downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2 pixels, 0-11 = 0 pixels
          rem temp2 will hold the pattern index (0-8)
          LET temp2 = 0
          
          rem Check thresholds from highest (83) to lowest (11)
          rem 84-100 = 8 pixels
          if temp1 > 83 then LET temp2 = 8 : goto P1SetPattern
          rem 72-83 = 7 pixels
          if temp1 > 71 then LET temp2 = 7 : goto P1SetPattern
          rem 60-71 = 6 pixels
          if temp1 > 59 then LET temp2 = 6 : goto P1SetPattern
          rem 48-59 = 5 pixels
          if temp1 > 47 then LET temp2 = 5 : goto P1SetPattern
          rem 36-47 = 4 pixels
          if temp1 > 35 then LET temp2 = 4 : goto P1SetPattern
          rem 24-35 = 3 pixels
          if temp1 > 23 then LET temp2 = 3 : goto P1SetPattern
          rem 12-23 = 2 pixels
          if temp1 > 11 then LET temp2 = 2 : goto P1SetPattern
          rem 0-11 = 0 pixels (temp2 already 0)
          
P1SetPattern
          rem Look up bit pattern from table using temp2 as index
          LET temp3 = HealthBarPatterns[temp2]
          
          rem Set pfscore1 to health bar pattern
          pfscore1 = temp3
    
    return

          rem =================================================================
          rem UPDATE PLAYER 2 HEALTH BAR
          rem =================================================================
    rem Input: temp1 = health value (0-100)
          rem Output: pfscore2 = health bar pattern (8 pixels, bit pattern)
          rem Uses simple comparisons against threshold table, looks up bit pattern
UpdatePlayer2HealthBar
          rem Clamp health to valid range
          if temp1 > PlayerHealthMax then LET temp1 = PlayerHealthMax
          if temp1 < 0 then LET temp1 = 0
          
          rem Compare health against thresholds starting from 83 downward
          rem 84-100 = 8 pixels, 72-83 = 7 pixels, ..., 12-23 = 2 pixels, 0-11 = 0 pixels
          rem temp2 will hold the pattern index (0-8)
          LET temp2 = 0
          
          rem Check thresholds from highest (83) to lowest (11)
          rem 84-100 = 8 pixels
          if temp1 > 83 then LET temp2 = 8 : goto P2SetPattern
          rem 72-83 = 7 pixels
          if temp1 > 71 then LET temp2 = 7 : goto P2SetPattern
          rem 60-71 = 6 pixels
          if temp1 > 59 then LET temp2 = 6 : goto P2SetPattern
          rem 48-59 = 5 pixels
          if temp1 > 47 then LET temp2 = 5 : goto P2SetPattern
          rem 36-47 = 4 pixels
          if temp1 > 35 then LET temp2 = 4 : goto P2SetPattern
          rem 24-35 = 3 pixels
          if temp1 > 23 then LET temp2 = 3 : goto P2SetPattern
          rem 12-23 = 2 pixels
          if temp1 > 11 then LET temp2 = 2 : goto P2SetPattern
          rem 0-11 = 0 pixels (temp2 already 0)
          
P2SetPattern
          rem Look up bit pattern from table using temp2 as index
          LET temp3 = HealthBarPatterns[temp2]
          
          rem Set pfscore2 to health bar pattern
          pfscore2 = temp3
    
    return

          rem Update both P1 and P2 health bars
          rem Input: playerHealth[0] and playerHealth[1] arrays
UpdatePlayer12HealthBars
          rem Update P1 health bar
          temp1 = playerHealth[0]
          gosub UpdatePlayer1HealthBar
          
          rem Update P2 health bar  
          temp1 = playerHealth[1]
          gosub UpdatePlayer2HealthBar
          
          return

          rem Initialize health bars at game start
InitializeHealthBars
          rem Set initial health bars to full (100%)
          temp1 = PlayerHealthMax
          gosub UpdatePlayer1HealthBar
          temp1 = PlayerHealthMax
          gosub UpdatePlayer2HealthBar
          return

          rem =================================================================
          rem P3/P4 HEALTH DISPLAY (SCORE MODE)
          rem =================================================================
          rem Display players 3 and 4 health as 2-digit numbers in score area
          rem Format: XX__XX where:
          rem   Left 2 digits (XX): Player 3 health (00-99) - indigo color
          rem   Middle 2 digits (__): blank (00)
          rem   Right 2 digits (XX): Player 4 health (00-99) - red color
          rem Score display uses 6 digits total (3 bytes BCD)

UpdatePlayer34HealthBars
          rem Only update if players 3 or 4 are active
          if !(controllerStatus & SetPlayers34Active) then return
          
          rem Get Player 3 health (0-100), clamp to 99
          rem Hide if inactive (selectedChar = 255) or eliminated
          temp1 = playerHealth[2]
          if selectedChar3 = 255 then temp1 = 0
          rem Check if Player 3 is eliminated (bit 2 of playersEliminated = 4)
          temp3 = playersEliminated & 4
          if temp3 then temp1 = 0
          rem Hide digits if eliminated or inactive
          if temp1 > PlayerHealthMax - 1 then temp1 = PlayerHealthMax - 1
          
          rem Get Player 4 health (0-100), clamp to 99
          rem Hide if inactive (selectedChar = 255) or eliminated
          temp2 = playerHealth[3]
          if selectedChar4 = 255 then temp2 = 0
          rem Check if Player 4 is eliminated (bit 3 of playersEliminated = 8)
          temp3 = playersEliminated & 8
          if temp3 then temp2 = 0
          rem Hide digits if eliminated or inactive
          if temp2 > 99 then temp2 = 99
          
          rem Format score as: P3Health * 10000 + P4Health
          rem This displays as XX00XX where:
          rem   XX (left 2 digits) = Player 3 health (00-99)
          rem   00 (middle 2 digits) = blank separator
          rem   XX (right 2 digits) = Player 4 health (00-99)
          rem Score is stored in BCD format across 3 bytes
          rem Format: score (digits 0-1), score+1 (digits 2-3), score+2 (digits 4-5)
          
          rem Convert binary health values to BCD and set score
          rem Use binary-to-decimal conversion: divide by 10 to extract tens and ones
          rem Calculate P3 health in BCD format (tens and ones digits)
          temp3 = temp1 / 10
          rem Tens digit (0-9)
          temp4 = temp1 - (temp3 * 10)
          rem Ones digit (0-9)
          rem Combine into BCD: tens * 16 + ones (BCD format)
          temp5 = temp3 * 16
          temp5 = temp5 + temp4
          rem temp5 now contains P3 health as BCD (e.g., $75 for 75)
          
          rem Calculate P4 health in BCD format
          temp6 = temp2 / 10
          rem Tens digit (0-9)
          temp7 = temp2 - (temp6 * 10)
          rem Ones digit (0-9)
          rem Combine into BCD: tens * 16 + ones
          temp6 = temp6 * 16
          temp6 = temp6 + temp7
          rem temp6 now contains P4 health as BCD (e.g., $50 for 50)
          
          rem Set score for XX00XX format using assembly to directly set BCD bytes
          rem score (high byte, digits 0-1) = P3 BCD (temp5) or $00 if inactive/eliminated
          rem score+1 (middle byte, digits 2-3) = $00 (always hidden - separator)
          rem score+2 (low byte, digits 4-5) = P4 BCD (temp6) or $00 if inactive/eliminated
          rem Digits are hidden by setting to $00 (displays as "00" - visible but indicates inactive/eliminated)
          asm
            SED
            LDA temp5
            STA score
            rem Middle 2 digits always hidden (separator between P3 and P4)
            LDA # 0
            STA score+1
            LDA temp6
            STA score+2
            CLD
          end
          
          rem Set score colors for score mode
          rem Left side (Player 3): indigo, Right side (Player 4): red
          rem In multisprite kernel, scorecolor applies to the score area
          rem Note: Per-side colors may require additional kernel support
          rem For now, set to white (Neutral color)
          rem TODO: Investigate if multisprite kernel supports separate left/right score colors
          let scorecolor = ColGrey(14)
          
          return
