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
          rem AVAILABLE VARIABLES:
          rem   temp1 = digit value (0-15)
          rem   temp2 = X position
          rem   temp3 = Y position
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
          rem
          rem INPUTS:
          rem   temp1 = digit value (0-15)
          rem     0-9 = decimal digits
          rem     10-15 = hex digits A-F
          rem   temp2 = X position (pixel column)
          rem   temp3 = Y position (pixel row)
          rem
          rem USES:
          rem   player0 or player1 sprite (8 pixels wide)
          rem   COLUP0 or COLUP1 for color
          rem
          rem NOTES:
          rem   Digit is rendered using sprite hardware
          rem   Only 2 digits can be displayed simultaneously (player0, player1)
          rem   For more digits, multiplex or use playfield
DrawDigit
          rem Clamp digit value to 0-15
          if temp1 > 15 then temp1 = 15
          
          rem Calculate data pointer offset
          rem Each digit is 16 bytes, so offset = digit * 16
          dim DigitOffset = temp4
          DigitOffset = temp1
          DigitOffset = DigitOffset << 4  : rem Multiply by 16
          
          rem TODO: Load digit bitmap from data table
          rem For now, use placeholder sprite
          
          rem Set sprite position
          player0x = temp2
          player0y = temp3
          
          rem Set sprite color (white)
          COLUP0 = $0E  : rem White
          
          rem Load sprite data based on digit
          on temp1 goto DrawDigit0, DrawDigit1, DrawDigit2, DrawDigit3, DrawDigit4, DrawDigit5, DrawDigit6, DrawDigit7, DrawDigit8, DrawDigit9, DrawDigitA, DrawDigitB, DrawDigitC, DrawDigitD, DrawDigitE, DrawDigitF
          
          return

          rem =================================================================
          rem DIGIT SPRITE DATA (Placeholders - will be replaced by generated data)
          rem =================================================================
          rem Each digit is 8×16 pixels stored as 16 bytes

DrawDigit0
          player0:
          %01111110  : rem  ******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %01111110  : rem  ******
          %00000000
          end
          return

DrawDigit1
          player0:
          %00011000  : rem    **
          %00111000  : rem   ***
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %00011000  : rem    **
          %01111110  : rem  ******
          %00000000
          end
          return

DrawDigit2
          player0:
          %01111110  : rem  ******
          %11000011  : rem **    **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000110  : rem      **
          %00001100  : rem     **
          %00011000  : rem    **
          %00110000  : rem   **
          %01100000  : rem  **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11111111  : rem ********
          %11111111  : rem ********
          %00000000
          %00000000
          end
          return

DrawDigit3
          player0:
          %01111110  : rem  ******
          %11000011  : rem **    **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000110  : rem      **
          %00111100  : rem   ****
          %00000110  : rem      **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %01111110  : rem  ******
          %00000000
          %00000000
          end
          return

DrawDigit4
          player0:
          %00000110  : rem      **
          %00001110  : rem     ***
          %00011110  : rem    ****
          %00110110  : rem   ** **
          %01100110  : rem  **  **
          %11000110  : rem **   **
          %11111111  : rem ********
          %00000110  : rem      **
          %00000110  : rem      **
          %00000110  : rem      **
          %00000110  : rem      **
          %00000110  : rem      **
          %00000110  : rem      **
          %00000110  : rem      **
          %00000000
          %00000000
          end
          return

DrawDigit5
          player0:
          %11111111  : rem ********
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11111110  : rem *******
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %01111110  : rem  ******
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigit6
          player0:
          %01111110  : rem  ******
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11111110  : rem *******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %01111110  : rem  ******
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigit7
          player0:
          %11111111  : rem ********
          %00000011  : rem       **
          %00000110  : rem      **
          %00000110  : rem      **
          %00001100  : rem     **
          %00001100  : rem     **
          %00011000  : rem    **
          %00011000  : rem    **
          %00110000  : rem   **
          %00110000  : rem   **
          %01100000  : rem  **
          %01100000  : rem  **
          %11000000  : rem **
          %11000000  : rem **
          %00000000
          %00000000
          end
          return

DrawDigit8
          player0:
          %01111110  : rem  ******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %01111110  : rem  ******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %01111110  : rem  ******
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigit9
          player0:
          %01111110  : rem  ******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %01111111  : rem  *******
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %00000011  : rem       **
          %01111110  : rem  ******
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigitA
          player0:
          %01111110  : rem  ******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11111111  : rem ********
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %00000000
          %00000000
          end
          return

DrawDigitB
          player0:
          %11111110  : rem *******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11111110  : rem *******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11111110  : rem *******
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigitC
          player0:
          %01111110  : rem  ******
          %11000011  : rem **    **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000011  : rem **    **
          %01111110  : rem  ******
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigitD
          player0:
          %11111110  : rem *******
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11000011  : rem **    **
          %11111110  : rem *******
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigitE
          player0:
          %11111111  : rem ********
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11111110  : rem *******
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11111111  : rem ********
          %00000000
          %00000000
          %00000000
          end
          return

DrawDigitF
          player0:
          %11111111  : rem ********
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11111110  : rem *******
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %11000000  : rem **
          %00000000
          %00000000
          %00000000
          end
          return

