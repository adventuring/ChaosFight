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
          
          return

          rem =================================================================
          rem P3/P4 HEALTH BAR SYSTEM (TO BE IMPLEMENTED)
          rem =================================================================
          rem P3/P4 health bars will use a different approach since score system
          rem only supports 2 players. Options:
          rem 1. Use playfield pixels for bar display
          rem 2. Use player graphics for bar segments  
          rem 3. Use missiles for bar indicators

          rem Update P3/P4 health bars using playfield-based display
          rem P3: Bottom-left corner, P4: Bottom-right corner
UpdatePlayer34HealthBars
          rem Only update if 4-player mode is active
          if !QuadtariDetected then return
          
          rem Update P3 health bar (bottom-left, right-growing)
          if SelectedChar3 <> 255 then temp1 = PlayerHealth[2] : temp2 = 2 : temp3 = 23 : temp4 = 0 : goto UpdateP3HealthBar
          goto SkipP3HealthBar
UpdateP3HealthBar
          rem P3 health (0-100)
          rem Player 3 index for color
          rem Bottom row of screen (Y=184 pixels)
          rem Start from left edge (X=0)
          gosub DrawPlayfieldHealthBar
SkipP3HealthBar
          
          rem Update P4 health bar (bottom-right, left-growing)
          if SelectedChar4 <> 255 then temp1 = PlayerHealth[3] : temp2 = 3 : temp3 = 23 : temp4 = 32 : goto UpdateP4HealthBar
          goto SkipP4HealthBar
UpdateP4HealthBar
          rem P4 health (0-100)
          rem Player 4 index for color
          rem Bottom row of screen (Y=184 pixels)
          rem Start from right edge (X=248 pixels)
          gosub DrawPlayfieldHealthBar
SkipP4HealthBar
          
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
