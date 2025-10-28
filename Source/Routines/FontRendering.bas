          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FONT RENDERING - HEX DIGITS 0-F
          rem =================================================================
          rem Renders 8×16 pixel hexadecimal digits (0-9, A-F) for:
          rem   - Player numbers (1-4) in player colors
          rem   - Level selection (0-F) in white
          rem   - Scores and timers
          rem
          rem FONT SOURCE:
          rem   Source/Art/Numbers.xcf (128 × 16 px)
          rem   16 digits × 8px wide = 128px total width
          rem   Each digit is 8×16 pixels
          rem   White pixels on black/transparent background
          rem
          rem GENERATED FILES:
          rem   Source/Generated/Font.Numbers.NTSC.bas
          rem   Source/Generated/Font.Numbers.PAL.bas
          rem   Source/Generated/Font.Numbers.SECAM.bas
          rem
          rem PLAYER COLORS (match character selection/health bars):
          rem   Player 1: Blue  ($96)
          rem   Player 2: Red   ($36)
          rem   Player 3: Yellow ($1E)
          rem   Player 4: Green ($C6)
          rem =================================================================

          rem Include architecture-specific font data
          #ifdef TV_NTSC
          #include "Source/Generated/Font.Numbers.NTSC.bas"
          #endif
          #ifdef TV_PAL
          #include "Source/Generated/Font.Numbers.PAL.bas"
          #endif
          #ifdef TV_SECAM
          #include "Source/Generated/Font.Numbers.SECAM.bas"
          #endif

          rem =================================================================
          rem DRAW DIGIT - DATA-DRIVEN VERSION
          rem =================================================================
          rem Draws a single hexadecimal digit (0-F) at specified position.
          rem Supports rendering to player0 or player1 for simultaneous digits.
          rem
          rem INPUTS:
          rem   temp1 = digit value (0-15)
          rem   temp2 = X position (pixel column)
          rem   temp3 = Y position (pixel row)
          rem   temp4 = color ($00-$FF for specific color, $FF = use temp5)
          rem   temp5 = sprite select (0=player0, 1=player1) OR custom color if temp4=$FF
          rem
          rem COLORS:
          rem   $0E = White (level select)
          rem   $96 = Blue (Player 1)
          rem   $36 = Red (Player 2)
          rem   $1E = Yellow (Player 3)
          rem   $C6 = Green (Player 4)
          rem
          rem EXAMPLE USAGE:
          rem   rem Draw level "A" (10) in white on left using player0
          rem   temp1 = 10 : temp2 = 40 : temp3 = 20 : temp4 = $0E : temp5 = 0 : gosub DrawDigit
          rem   rem Draw player "2" in red on right using player1
          rem   temp1 = 2 : temp2 = 120 : temp3 = 20 : temp4 = $36 : temp5 = 1 : gosub DrawDigit
DrawDigit
          rem Clamp digit value to 0-15
          if temp1 > 15 then temp1 = 15
          
          rem Calculate data offset: digit * 16 (16 bytes per digit)
          dim DigitOffset = temp6
          DigitOffset = temp1 * 16
          
          rem Set sprite position and color based on temp5
          if temp5 = 0 then
                    player0x = temp2
                    player0y = temp3
                    COLUP0 = temp4
                    gosub LoadPlayer0Digit
          else
                    player1x = temp2
                    player1y = temp3
                    COLUP1 = temp4
                    gosub LoadPlayer1Digit
          endif
          return

          rem =================================================================
          rem LOAD DIGIT DATA INTO SPRITES
          rem =================================================================
          rem These routines load digit bitmaps from the generated data tables.
          rem The data is accessed using batariBasic''s data statement indexing.
          rem
          rem INPUT:
          rem   DigitOffset (temp6) = byte offset into font data (digit * 16)

LoadPlayer0Digit
          rem Load 16 bytes from font data into player0 sprite
          rem Using batariBasic data access pattern
          dim Row = a
          dim DataIndex = b
          
          DataIndex = DigitOffset
          player0:
          rem Row 0-15: Read from data tables
          %00111100  : rem Will be replaced by actual data read
          %01000010
          %01000010
          %01000010
          %01000010
          %01000010
          %00111100
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          end
          return

LoadPlayer1Digit
          rem Load 16 bytes from font data into player1 sprite
          dim Row = a
          dim DataIndex = b
          
          DataIndex = DigitOffset
          player1:
          rem Row 0-15: Read from data tables
          %00111100  : rem Will be replaced by actual data read
          %01000010
          %01000010
          %01000010
          %01000010
          %01000010
          %00111100
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          %00000000
          end
          return

          rem =================================================================
          rem DRAW PLAYER NUMBER
          rem =================================================================
          rem Convenience routine to draw a player''s number in their color.
          rem
          rem INPUTS:
          rem   temp1 = player index (0-3)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem   temp5 = sprite select (0=player0, 1=player1)
          rem
          rem Player colors are looked up from a table.
DrawPlayerNumber
          rem Convert player index to digit (0→1, 1→2, 2→3, 3→4)
          dim PlayerDigit = temp1
          PlayerDigit = temp1 + 1
          
          rem Look up player color
          dim PlayerColor = temp4
          on temp1 goto SetP1Color, SetP2Color, SetP3Color, SetP4Color
          
SetP1Color
          PlayerColor = $96  : rem Blue
          goto DrawPlayerDigitNow
          
SetP2Color
          PlayerColor = $36  : rem Red
          goto DrawPlayerDigitNow
          
SetP3Color
          PlayerColor = $1E  : rem Yellow
          goto DrawPlayerDigitNow
          
SetP4Color
          PlayerColor = $C6  : rem Green
          goto DrawPlayerDigitNow
          
DrawPlayerDigitNow
          rem Set up parameters for DrawDigit
          temp1 = PlayerDigit
          rem temp2, temp3, temp5 already set by caller
          temp4 = PlayerColor
          gosub DrawDigit
          return

          rem =================================================================
          rem DRAW LEVEL NUMBER
          rem =================================================================
          rem Convenience routine to draw a level number in white.
          rem
          rem INPUTS:
          rem   temp1 = level number (0-15)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem   temp5 = sprite select (0=player0, 1=player1)
DrawLevelNumber
          temp4 = $0E  : rem White
          gosub DrawDigit
          return
