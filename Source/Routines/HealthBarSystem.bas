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
    rem Simple approach: display health as 2-digit number (00-99)
    rem Limit to 99 max
    if temp1 > 99 then temp1 = 99
    rem Temporarily disable score update to fix build errors
    rem TODO: Implement proper binary-to-BCD conversion for score display
    rem score assignment causes immediate value errors when using variables
    
    return

    rem Update P2 health bar (displayed as score1)  
    rem Input: temp1 = health value (0-100)
UpdatePlayer2HealthBar
    rem Convert health to score format for bar display
    rem Temporarily disable score update to fix build errors
    rem TODO: Implement proper binary-to-BCD conversion for score1 display
    rem score1 assignment causes immediate value errors when using variables
    
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
          rem Format: XX00XX where:
          rem   Left 2 digits (XX): Player 3 health (00-100) - indigo color
          rem   Middle 2 digits (00): blank separator
          rem   Right 2 digits (XX): Player 4 health (00-100) - red color
          rem Score display uses 6 digits total (3 bytes BCD)
          rem Score format: score (digits 5-4), score+1 (digits 3-2), score+2 (digits 1-0)
          rem Each byte stores 2 BCD digits (high nibble = tens, low nibble = ones)

UpdatePlayer34HealthBars
          rem Only update if players 3 or 4 are active
          if !(ControllerStatus & SetPlayers34Active) then return
          
          rem Get Player 3 health (0-100), support full range
          temp1 = PlayerHealth[2]
          if selectedChar3 = 255 then temp1 = 0
          rem Clamp to 0-100 for display (100 will show as "00" in 2-digit display)
          if temp1 > 100 then temp1 = 100
          
          rem Get Player 4 health (0-100), support full range
          temp2 = PlayerHealth[3]
          if selectedChar4 = 255 then temp2 = 0
          rem Clamp to 0-100 for display
          if temp2 > 100 then temp2 = 100
          
          rem Convert binary health values (0-100) to BCD and set score bytes
          rem For XX00XX format:
          rem   score (digits 5-4): P3 health tens and ones as BCD
          rem   score+1 (digits 3-2): 00 (blank separator)
          rem   score+2 (digits 1-0): P4 health tens and ones as BCD
          
          rem Convert P3 health (temp1, 0-100) to BCD
          rem Extract tens and ones digits
          rem For values 0-99: tens = temp1/10, ones = temp1 - (tens*10)
          rem For value 100: display as "00" (wrap to 2-digit display)
          if temp1 = 100 then goto P3Health100
          rem Calculate tens digit (0-9)
          temp3 = temp1 / 10
          rem Calculate ones digit (0-9)
          temp4 = temp1 - (temp3 * 10)
          goto P3HealthConvertDone
P3Health100
          rem Display 100 as "00" for 2-digit display
          temp3 = 0
          temp4 = 0
P3HealthConvertDone
          
          rem Convert P4 health (temp2, 0-100) to BCD
          if temp2 = 100 then goto P4Health100
          rem Calculate tens digit (0-9)
          temp5 = temp2 / 10
          rem Calculate ones digit (0-9)
          temp6 = temp2 - (temp5 * 10)
          goto P4HealthConvertDone
P4Health100
          rem Display 100 as "00" for 2-digit display
          temp5 = 0
          temp6 = 0
P4HealthConvertDone
          
          rem Set score bytes in BCD format using assembly
          rem score (digits 5-4): P3 tens (high nibble) and ones (low nibble)
          rem score+1 (digits 3-2): CF (separator)
          rem score+2 (digits 1-0): P4 tens (high nibble) and ones (low nibble)
          rem BCD format: high nibble = tens digit, low nibble = ones digit
          rem Example: 75 = $75 (BCD), 50 = $50 (BCD)
          rem Build BCD byte: (tens << 4) | ones
          rem Note: CF ($CF) is stored directly as hex value for separator
          
          asm
          lda temp3
          asl
          asl
          asl
          asl
          ora temp4
          sta score
          lda #$CF
          sta score+1
          lda temp5
          asl
          asl
          asl
          asl
          ora temp6
          sta score+2
          end
          
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
          let temp7 = temp6
          temp6 = temp6 - 1
          if temp6 > temp7 then temp6 = 0
          next
          
          
          return
