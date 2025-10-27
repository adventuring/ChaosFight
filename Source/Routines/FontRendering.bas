          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FONT RENDERING - HEX DIGITS 0-F
          rem =================================================================
          rem Renders 8×16 pixel hexadecimal digits (0-9, A-F) for:
          rem   - Player numbers (1-4)
          rem   - Level selection (0-F)
          rem   - Scores and timers
          rem   - Debug displays
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
          rem FONT DATA FORMAT:
          rem   Each digit stored as 16 bytes (one per row)
          rem   data Digit0, Digit1, ... DigitF
          rem   Access: digit_index * 16 + row_offset
          rem
          rem USAGE:
          rem   temp1 = digit value (0-15)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem   temp4 = sprite select (0=player0, 1=player1)
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
          rem DRAW DIGIT
          rem =================================================================
          rem Draws a single hexadecimal digit (0-F) at specified position.
          rem Supports rendering to player0 or player1 for simultaneous digits.
          rem
          rem INPUTS:
          rem   temp1 = digit value (0-15)
          rem     0-9 = decimal digits
          rem     10-15 = hex digits A-F
          rem   temp2 = X position (pixel column)
          rem   temp3 = Y position (pixel row)
          rem   temp4 = sprite select (0=use player0, 1=use player1)
          rem
          rem EXAMPLE USAGE:
          rem   rem Draw level "A" (10) on left using player0
          rem   temp1 = 10 : temp2 = 40 : temp3 = 20 : temp4 = 0 : gosub DrawDigit
          rem   rem Draw player "2" on right using player1
          rem   temp1 = 2 : temp2 = 120 : temp3 = 20 : temp4 = 1 : gosub DrawDigit
DrawDigit
          rem Clamp digit value to 0-15
          if temp1 > 15 then temp1 = 15
          
          rem Set sprite position based on temp4
          if temp4 = 0 then
                    player0x = temp2
                    player0y = temp3
                    COLUP0 = $0E  : rem White
          else
                    player1x = temp2
                    player1y = temp3
                    COLUP1 = $0E  : rem White
          endif
          
          rem Load sprite data based on digit using on goto
          on temp1 goto LoadDigit0, LoadDigit1, LoadDigit2, LoadDigit3, LoadDigit4, LoadDigit5, LoadDigit6, LoadDigit7, LoadDigit8, LoadDigit9, LoadDigitA, LoadDigitB, LoadDigitC,i LoadDigitD, LoadDigitE, LoadDigitF
          return

          rem =================================================================
          rem LOAD DIGIT SPRITE DATA
          rem =================================================================
          rem These subroutines load digit bitmaps from generated data tables.
          rem The actual bitmap data is in Source/Generated/Font.Numbers.*.bas
          rem and is loaded via the data statements above.
          rem
          rem Each subroutine loads 16 bytes into the appropriate player sprite.

LoadDigit0
          if temp4 = 0 then
                    rem Load into player0
                    dim DigitPtr = temp5
                    DigitPtr = 0  : rem Digit 0 offset
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 0
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit1
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 16  : rem Digit 1 offset (16 bytes per digit)
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 16
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit2
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 32
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 32
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit3
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 48
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 48
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit4
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 64
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 64
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit5
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 80
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 80
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit6
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 96
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 96
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit7
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 112
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 112
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit8
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 128
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 128
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigit9
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 144
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 144
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigitA
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 160
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 160
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigitB
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 176
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 176
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigitC
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 192
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 192
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigitD
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 208
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 208
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigitE
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 224
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 224
                    gosub LoadPlayer1FromData
          endif
          return

LoadDigitF
          if temp4 = 0 then
                    dim DigitPtr = temp5
                    DigitPtr = 240
                    gosub LoadPlayer0FromData
          else
                    dim DigitPtr = temp5
                    DigitPtr = 240
                    gosub LoadPlayer1FromData
          endif
          return

          rem =================================================================
          rem DATA LOADING HELPERS
          rem =================================================================
          rem These subroutines read from the font data tables and load into
          rem the player sprite registers. The actual implementation depends
          rem on how batariBasic handles data access.
          rem
          rem For now, these are placeholders that will be replaced with
          rem proper data table access when the font data is generated.

LoadPlayer0FromData
          rem Load 16 bytes from DigitPtr offset into player0 sprite
          rem This will use the data statements from Generated/Font.Numbers.*.bas
          rem For now, use a simple pattern
          player0:
          %00111100
          %01100110
          %01101110
          %01110110
          %01100110
          %01100110
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

LoadPlayer1FromData
          rem Load 16 bytes from DigitPtr offset into player1 sprite
          player1:
          %00111100
          %01100110
          %01101110
          %01110110
          %01100110
          %01100110
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
