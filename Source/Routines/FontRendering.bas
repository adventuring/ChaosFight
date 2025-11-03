          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FONT RENDERING - HEX DIGITS 0-F
          rem =================================================================
          rem Renders 8×16 pixel hexadecimal digits (0-9, A-F) for:
          rem   - Player numbers (1-4) in player colors
          rem   - Level selection (0-9) in white
          rem   - Scores and timers

          rem FONT SOURCE:
          rem   Source/Art/Numbers.xcf (128 × 16 px)
          rem   16 digits × 8px wide = 128px total width
          rem   Each digit is 8×16 pixels
          rem   Solid pixels on transparent background

          rem GENERATED FILES:
          rem   Source/Generated/Font.Numbers.NTSC.bas
          rem   Source/Generated/Font.Numbers.PAL.bas
          rem   Source/Generated/Font.Numbers.SECAM.bas

          rem PLAYER COLORS (match character selection/health bars):
          rem   Player 1: Indigo (ColIndigo(14))
          rem   Player 2: Red   (ColRed(14))
          rem   Player 3: Yellow (ColYellow(14))
          rem   Player 4: Green (ColGreen(14))
          rem =================================================================

          rem Include architecture-specific font data
          #ifdef TV_NTSC
          #include "Source/Generated/Font.Numbers.NTSC.bas"
          #ifdef TV_PAL
          #include "Source/Generated/Font.Numbers.PAL.bas"
          #ifdef TV_SECAM
          #include "Source/Generated/Font.Numbers.SECAM.bas"

          rem =================================================================
          rem DRAW DIGIT - DATA-DRIVEN VERSION
          rem =================================================================
          rem Draws a single hexadecimal digit (0-F) at specified position.
          rem Supports rendering to player0 or player1 for simultaneous digits.

          rem INPUTS:
          rem   temp1 = digit value (0-15)
          rem   temp2 = X position (pixel column)
          rem   temp3 = Y position (pixel row)
          rem   temp4 = color ($00-$FF for specific color, $FF = use temp5)
          rem   temp5 = sprite select (0=player0, 1=player1) OR custom color if temp4=$FF

          rem COLORS:
          rem   ColGrey(14) = White (level select)
          rem   ColIndigo(14) = Indigo (Player 1)
          rem   ColRed(14) = Red (Player 2)
          rem   ColYellow(14) = Yellow (Player 3)
          rem   ColGreen(14) = Green (Player 4)

          rem EXAMPLE USAGE:
          rem   rem Draw level "A" (10) in white on left using player0
          rem   temp1 = 10 : temp2 = 40 : temp3 = 20 : temp4 = ColGrey(14) : temp5 = 0 : gosub DrawDigit
          rem   rem Draw player "2" in red on right using player1
          rem   temp1 = 2 : temp2 = 120 : temp3 = 20 : temp4 = ColRed(14) : temp5 = 1 : gosub DrawDigit
DrawDigit
          rem Clamp digit value to 0-15
          if temp1 > 15 then temp1 = 15
          
          rem Calculate data offset: digit * 16 (16 bytes per digit)
          dim FR_digitOffset = temp6
          FR_digitOffset = temp1 * 16
          
          rem Set sprite position and color based on temp5
          if temp5 then SkipPlayer0Sprite

          rem Use player0 sprite
          let player0x = temp2
          let player0y = temp3
          COLUP0 = temp4
          rem tail call
          goto LoadPlayer0Digit

SkipPlayer0Sprite
          rem Use player1 sprite
          player1x = temp2
          player1y = temp3
          _COLUP1 = temp4
          gosub LoadPlayer1Digit
          return

          rem =================================================================
          rem LOAD DIGIT DATA INTO SPRITES
          rem =================================================================
          rem These routines load digit bitmaps from the generated data tables.
          rem The data is accessed using batariBasic data statement indexing.

          rem INPUT:
          rem   DigitOffset (temp6) = byte offset into font data (digit * 16)

LoadPlayer0Digit
          rem Load 16 bytes from font data into player0 sprite
 
          return

LoadPlayer1Digit

          return

          rem =================================================================
          rem DRAW PLAYER NUMBER
          rem =================================================================
          rem Convenience routine to draw a player number in their color.

          rem INPUTS:
          rem   temp1 = player index (0-3)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem   temp5 = sprite select (0=player0, 1=player1)

          rem Player colors are looked up from a table.
DrawPlayerNumber
          rem Convert player index to digit (0→1, 1→2, 2→3, 3→4)
          dim FR_playerDigit = temp1
          let FR_playerDigit = temp1 + 1
          
          rem Look up player color
          dim FR_playerColor = temp4
          on temp1 goto SetP1Color, SetP2Color, SetP3Color, SetP4Color
          
SetP1Color
          let FR_playerColor = ColIndigo(14)
          rem Indigo
          goto DrawPlayerDigitNow
          
SetP2Color
          let FR_playerColor = ColRed(14)
          rem Red
          goto DrawPlayerDigitNow
          
SetP3Color
          FR_playerColor = ColYellow(14)
          rem Yellow
          goto DrawPlayerDigitNow
          
SetP4Color
          FR_playerColor = ColGreen(14)
          rem Green
          goto DrawPlayerDigitNow
          
DrawPlayerDigitNow
          rem Set up parameters for DrawDigit
          temp1 = FR_playerDigit
          rem temp2, temp3, temp5 already set by caller
          temp4 = FR_playerColor
          gosub DrawDigit
          return

          rem =================================================================
          rem DRAW LEVEL NUMBER
          rem =================================================================
          rem Convenience routine to draw a level number in white.

          rem INPUTS:
          rem   temp1 = level number (0-15)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem   temp5 = sprite select (0=player0, 1=player1)
DrawLevelNumber
          temp4 = ColGrey(14)
          rem White
          gosub DrawDigit
          return
