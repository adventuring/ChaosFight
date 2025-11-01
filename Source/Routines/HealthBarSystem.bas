          rem ChaosFight - Source/Routines/HealthBarSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem HEALTH BAR SYSTEM USING PFSCORE

          rem Uses batariBasic built-in score display system to show health bars
          rem P1/P2 health displayed as score bars at top of screen
          rem P3/P4 health will be implemented separately

          rem =================================================================
          rem HEALTH TO SCORE MAPPING
          rem =================================================================
          rem Convert health values (0-100) to score display format
          rem Score system uses 6 digits, we use bar-like display

          rem Update P1 health bar (displayed as score)
          rem Input: temp1 = health value (0-100)
UpdatePlayer1HealthBar
          rem Convert health to score format for bar display
          rem Health 100 = 999999, Health 0 = 000000
          temp2 = temp1 * 9999
          temp2 = temp2 / 100
          
          rem Set score to display as health bar
          score = temp2
          
          return

          rem Update P2 health bar (displayed as score1)  
          rem Input: temp1 = health value (0-100)
UpdatePlayer2HealthBar
          rem Convert health to score format for bar display
          temp2 = temp1 * 9999
          temp2 = temp2 / 100
          
          rem Set score1 to display as health bar
          score1 = temp2
          
          return

          rem Update both P1 and P2 health bars
          rem Input: PlayerHealth[0] and PlayerHealth[1] arrays
UpdatePlayer12HealthBars
          rem Update P1 health bar
          temp1 = PlayerHealth[0]
          gosub UpdatePlayer1HealthBar
          
          rem Update P2 health bar  
          temp1 = PlayerHealth[1]
          gosub UpdatePlayer2HealthBar
          
          return

          rem Initialize health bars at game start
InitializeHealthBars
          rem Set initial health bars to full (100%)
          temp1 = 100
          gosub UpdatePlayer1HealthBar
          temp1 = 100
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
          if !(ControllerStatus & SetPlayers34Active) then return
          
          rem Get Player 3 health (0-100), clamp to 99
          temp1 = PlayerHealth[2]
          if SelectedChar3 = 255 then temp1 = 0
          if temp1 > 99 then temp1 = 99
          
          rem Get Player 4 health (0-100), clamp to 99
          temp2 = PlayerHealth[3]
          if SelectedChar4 = 255 then temp2 = 0
          if temp2 > 99 then temp2 = 99
          
          rem Format score as: P3Health * 10000 + P4Health
          rem This displays as XX00XX where:
          rem   XX (left 2 digits) = Player 3 health (00-99)
          rem   00 (middle 2 digits) = blank separator
          rem   XX (right 2 digits) = Player 4 health (00-99)
          rem Score is stored in BCD format across 3 bytes
          
          rem Calculate score value: P3Health in thousands/hundreds, P4Health in tens/ones
          rem For display as XX00XX, we multiply P3 by 10000 to shift it left
          temp7 = temp1 * 10000
          rem P3 health shifted to left 2 digits (e.g., 75 becomes 750000)
          temp7 = temp7 + temp2
          rem Add P4 health in right 2 digits (e.g., 750000 + 50 = 750050)
          rem Display shows: "75 00 50" (spaces added for clarity, actual display has no spaces)
          
          rem Set score to display P3 and P4 health
          score = temp7
          
          rem Set score colors for score mode
          rem Left side (Player 3): indigo, Right side (Player 4): red
          rem In multisprite kernel, scorecolor applies to the score area
          rem Note: Per-side colors may require additional kernel support
          rem For now, set to indigo (Player 3 color)
          rem TODO: Investigate if multisprite kernel supports separate left/right score colors
          scorecolor = ColIndigo(14)
          
          return

          rem =================================================================
          rem DRAW PLAYFIELD HEALTH BAR
          rem =================================================================
          rem Displays a health bar using playfield pixels
          rem INPUT: temp1 = health (0-100), temp2 = player index (2-3)
          rem        temp3 = Y row (23 for bottom), temp4 = starting X position
DrawPlayfieldHealthBar
          rem Calculate bar length (0-15 pixels)
          temp5 = temp1 * 15
          temp5 = temp5 / 100
          if temp5 > 15 then temp5 = 15
          
          rem Set health bar color based on player
          if temp2 = 2 then COLUPF = ColYellow(12) 
          rem P3 Yellow
          if temp2 = 3 then COLUPF = ColGreen(12)  
          rem P4 Green
          
          rem Clear the health bar area first
          temp6 = temp4 
          rem Starting X position
          rem Clear 15 pixels worth of health bar
          for temp7 = 0 to 15
          rem pfpixel temp6 temp3 off
          temp6 = temp6 + 1
          if temp6 > 31 then temp6 = 31 
          rem Clamp to playfield width
          next
          
          rem Draw the health bar
          temp6 = temp4 
          rem Reset to starting X position
          if temp2 = 2 then 
          rem P3: left-to-right
          for temp7 = 0 to temp5
          rem pfpixel temp6 temp3 on
          temp6 = temp6 + 1
          if temp6 > 31 then temp6 = 31
          next
          
          
          if temp2 = 3 then 
          rem P4: right-to-left
          for temp7 = 0 to temp5
          rem pfpixel temp6 temp3 on
          temp7 = temp6
          temp6 = temp6 - 1
          if temp6 > temp7 then temp6 = 0
          next
          
          
          return
