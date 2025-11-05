          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem FONT RENDERING - HEX DIGITS 0-F
          rem ==========================================================
          rem Renders 8×16 pixel hexadecimal digits (0-9, A-F) for:
          rem   - Player numbers (1-4) in player colors
          rem   - Arena selection (0-9) in white
          rem   - Scores and timers

          rem FONT SOURCE:
          rem   Source/Art/Numbers.xcf (128 × 16 px)
          rem   16 digits × 8px wide = 128px total width
          rem   Each digit is 8×16 pixels
          rem   Solid pixels on transparent background

          rem GENERATED FILES:
          rem Source/Generated/Numbers.bas (universal, not TV-specific)

          rem PLAYER COLORS (match character selection/health bars):
          rem   Player 1: Indigo (ColIndigo(14))
          rem   Player 2: Red   (ColRed(14))
          rem   Player 3: Yellow (ColYellow(14))
          rem Player 4: Turquoise (ColTurquoise(14), SECAM maps to
          rem   Green)
          rem ==========================================================

          rem Include font data (universal for all TV standards)
          #include "Source/Generated/Numbers.bas"

          rem ==========================================================
          rem DRAW DIGIT - DATA-DRIVEN VERSION
          rem ==========================================================
          rem Draws a single hexadecimal digit (0-F) at specified
          rem   position.
          rem Supports rendering to player0, player1, player2, player3,
          rem   player4, or player5 for simultaneous digits.

          rem INPUTS:
          rem   temp1 = digit value (0-15)
          rem   temp2 = X position (pixel column)
          rem   temp3 = Y position (pixel row)
          rem temp4 = color ($00-$FF for specific color, $FF = use
          rem   temp5)
          rem temp5 = sprite select (0=player0, 1=player1, 2=player2,
          rem   3=player3, 4=player4, 5=player5) OR custom color if
          rem   temp4=$FF

          rem COLORS:
          rem   ColGrey(14) = White (arena select)
          rem   ColIndigo(14) = Indigo (Player 1)
          rem   ColRed(14) = Red (Player 2)
          rem   ColYellow(14) = Yellow (Player 3)
          rem ColTurquoise(14) = Turquoise (Player 4, SECAM maps to
          rem   Green)

          rem EXAMPLE USAGE:
          rem   rem Draw level "A" (10) in white on left using player0
          rem temp1 = 10 : temp2 = 40 : temp3 = 20 : temp4 = ColGrey(14)
          rem   : temp5 = 0 : gosub DrawDigit
          rem   rem Draw player "2" in red on right using player1
          rem temp1 = 2 : temp2 = 120 : temp3 = 20 : temp4 = ColRed(14)
          rem   : temp5 = 1 : gosub DrawDigit
DrawDigit
          dim DD_digit = temp1
          dim DD_xPos = temp2
          dim DD_yPos = temp3
          dim DD_color = temp4
          dim DD_spriteSelect = temp5
          dim DD_digitOffset = temp6
          rem Clamp digit value to 0-15
          if DD_digit > 15 then let DD_digit = 15
          
          rem Calculate data offset: digit * 16 (16 bytes per digit)
          let DD_digitOffset = DD_digit * 16
          
          rem Set sprite position and color based on spriteSelect
          if DD_spriteSelect = 0 then DrawPlayer0Digit
          if DD_spriteSelect = 1 then DrawPlayer1Digit
          if DD_spriteSelect = 2 then DrawPlayer2Digit
          if DD_spriteSelect = 3 then DrawPlayer3Digit
          if DD_spriteSelect = 4 then DrawPlayer4Digit
          if DD_spriteSelect = 5 then DrawPlayer5Digit
          rem Default to player0 if invalid spriteSelect
          goto DrawPlayer0Digit

DrawPlayer0Digit
          rem Use player0 sprite
          let player0x = DD_xPos
          let player0y = DD_yPos
          let COLUP0 = DD_color
          rem tail call
          let temp6 = DD_digitOffset
          goto LoadPlayer0Digit

DrawPlayer1Digit
          rem Use player1 sprite
          let player1x = DD_xPos
          let player1y = DD_yPos
          let _COLUP1 = DD_color
          let temp6 = DD_digitOffset
          rem tail call
          goto LoadPlayer1Digit

DrawPlayer2Digit
          rem Use player2 sprite
          let player2x = DD_xPos
          let player2y = DD_yPos
          let COLUP2 = DD_color
          let temp6 = DD_digitOffset
          rem tail call
          goto LoadPlayer2Digit

DrawPlayer3Digit
          rem Use player3 sprite
          let player3x = DD_xPos
          let player3y = DD_yPos
          let COLUP3 = DD_color
          let temp6 = DD_digitOffset
          rem tail call
          goto LoadPlayer3Digit

DrawPlayer4Digit
          rem Use player4 sprite
          let player4x = DD_xPos
          let player4y = DD_yPos
          let COLUP4 = DD_color
          let temp6 = DD_digitOffset
          rem tail call
          goto LoadPlayer4Digit

DrawPlayer5Digit
          rem Use player5 sprite
          let player5x = DD_xPos
          let player5y = DD_yPos
          let COLUP5 = DD_color
          let temp6 = DD_digitOffset
          rem tail call
          goto LoadPlayer5Digit

          rem ==========================================================
          rem LOAD DIGIT DATA INTO SPRITES
          rem ==========================================================
          rem These routines load digit bitmaps from the generated data
          rem   tables.
          rem The data is accessed using batariBasic data statement
          rem   indexing.

          rem INPUT:
          rem DigitOffset (temp6) = byte offset into font data (digit *
          rem   16)

LoadPlayer0Digit
          dim LP0D_digitOffset = temp6
          rem Load digit graphics from Numbers font data into player0
          rem   sprite
          rem Input: temp6 = byte offset into font data (digit * 16,
          rem   where digit is 0-9)
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if LP0D_digitOffset > 240 then let LP0D_digitOffset = 240
          
          rem Calculate sprite pointer = FontData + offset using
          rem   assembly
          asm
            ; Load low byte of FontData base address
            lda # <FontData
            clc
            adc LP0D_digitOffset
            sta player0pointerlo
            
            ; Load high byte of FontData base address and add carry
            lda # >FontData
            adc #0
            sta player0pointerhi
end
          
          rem Set sprite height (16 pixels tall)
          let player0height = 16
          return

LoadPlayer1Digit
          dim LP1D_digitOffset = temp6
          rem Load digit graphics from Numbers font data into player1
          rem   sprite
          rem Input: temp6 = byte offset into font data (digit * 16,
          rem   where digit is 0-9)
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if LP1D_digitOffset > 240 then let LP1D_digitOffset = 240
          
          rem Calculate sprite pointer = FontData + offset using
          rem   assembly
          asm
            ; Load low byte of FontData base address
            lda # <FontData
            clc
            adc LP1D_digitOffset
            sta player1pointerlo
            
            ; Load high byte of FontData base address and add carry
            lda # >FontData
            adc #0
            sta player1pointerhi
end
          
          rem Set sprite height (16 pixels tall)
          let player1height = 16
          return

LoadPlayer2Digit
          dim LP2D_digitOffset = temp6
          rem Load digit graphics from Numbers font data into player2
          rem   sprite
          rem Input: temp6 = byte offset into font data (digit * 16,
          rem   where digit is 0-15)
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if LP2D_digitOffset > 240 then let LP2D_digitOffset = 240
          
          rem Calculate sprite pointer = FontData + offset using
          rem   assembly
          asm
            ; Load low byte of FontData base address
            lda # <FontData
            clc
            adc LP2D_digitOffset
            sta player2pointerlo
            
            ; Load high byte of FontData base address and add carry
            lda # >FontData
            adc #0
            sta player2pointerhi
end
          
          rem Set sprite height (16 pixels tall)
          let player2height = 16
          return

LoadPlayer3Digit
          dim LP3D_digitOffset = temp6
          rem Load digit graphics from Numbers font data into player3
          rem   sprite
          rem Input: temp6 = byte offset into font data (digit * 16,
          rem   where digit is 0-15)
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if LP3D_digitOffset > 240 then let LP3D_digitOffset = 240
          
          rem Calculate sprite pointer = FontData + offset using
          rem   assembly
          asm
            ; Load low byte of FontData base address
            lda # <FontData
            clc
            adc LP3D_digitOffset
            sta player3pointerlo
            
            ; Load high byte of FontData base address and add carry
            lda # >FontData
            adc #0
            sta player3pointerhi
end
          
          rem Set sprite height (16 pixels tall)
          let player3height = 16
          return

LoadPlayer4Digit
          dim LP4D_digitOffset = temp6
          rem Load digit graphics from Numbers font data into player4
          rem   sprite
          rem Input: temp6 = byte offset into font data (digit * 16,
          rem   where digit is 0-15)
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if LP4D_digitOffset > 240 then let LP4D_digitOffset = 240
          
          rem Calculate sprite pointer = FontData + offset using
          rem   assembly
          asm
            ; Load low byte of FontData base address
            lda # <FontData
            clc
            adc LP4D_digitOffset
            sta player4pointerlo
            
            ; Load high byte of FontData base address and add carry
            lda # >FontData
            adc #0
            sta player4pointerhi
end
          
          rem Set sprite height (16 pixels tall)
          let player4height = 16
          return

LoadPlayer5Digit
          dim LP5D_digitOffset = temp6
          rem Load digit graphics from Numbers font data into player5
          rem   sprite
          rem Input: temp6 = byte offset into font data (digit * 16,
          rem   where digit is 0-15)
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if LP5D_digitOffset > 240 then let LP5D_digitOffset = 240
          
          rem Calculate sprite pointer = FontData + offset using
          rem   assembly
          asm
            ; Load low byte of FontData base address
            lda # <FontData
            clc
            adc LP5D_digitOffset
            sta player5pointerlo
            
            ; Load high byte of FontData base address and add carry
            lda # >FontData
            adc #0
            sta player5pointerhi
end
          
          rem Set sprite height (16 pixels tall)
          let player5height = 16
          return

          rem ==========================================================
          rem DRAW PLAYER NUMBER
          rem ==========================================================
          rem Convenience routine to draw a player number in their
          rem   color.

          rem INPUTS:
          rem   temp1 = player index (0-3)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem   temp5 = sprite select (0=player0, 1=player1)

          rem Player colors are looked up from a table.
DrawPlayerNumber
          dim DPN_playerIndex = temp1
          dim DPN_playerDigit = temp1
          dim DPN_xPos = temp2
          dim DPN_yPos = temp3
          dim DPN_playerColor = temp4
          dim DPN_spriteSelect = temp5
          rem Convert player index to digit (0→1, 1→2, 2→3, 3→4)
          let DPN_playerDigit = DPN_playerIndex + 1
          
          rem Look up player color
          let temp1 = DPN_playerIndex
          on temp1 goto SetP1Color, SetP2Color, SetP3Color, SetP4Color
          
SetP1Color
          let DPN_playerColor = ColIndigo(14)
          rem Indigo
          goto DrawPlayerDigitNow
          
SetP2Color
          let DPN_playerColor = ColRed(14)
          rem Red
          goto DrawPlayerDigitNow
          
SetP3Color
          let DPN_playerColor = ColYellow(14)
          rem Yellow
          goto DrawPlayerDigitNow
          
SetP4Color
#ifdef TV_SECAM
          let DPN_playerColor = ColGreen(14)
          rem Green (SECAM-specific, Turquoise maps to Cyan on SECAM)
#else
          let DPN_playerColor = ColTurquoise(14)
          rem Turquoise (NTSC/PAL)
#endif
          goto DrawPlayerDigitNow
          
DrawPlayerDigitNow
          rem Set up parameters for DrawDigit
          let temp1 = DPN_playerDigit
          let temp2 = DPN_xPos
          let temp3 = DPN_yPos
          let temp4 = DPN_playerColor
          let temp5 = DPN_spriteSelect
          rem tail call
          goto DrawDigit

          rem ==========================================================
          rem DRAW ARENA NUMBER
          rem ==========================================================
          rem Convenience routine to draw an arena number in white.

          rem INPUTS:
          rem   temp1 = arena number (0-31, displays as 1-32)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem temp5 = sprite select (0=player0, 1=player1, 2=player2,
          rem   3=player3, 4=player4, 5=player5)
DrawArenaNumber
          dim DLN_arenaNumber = temp1
          dim DLN_xPos = temp2
          dim DLN_yPos = temp3
          dim DLN_color = temp4
          dim DLN_spriteSelect = temp5
          let DLN_color = ColGrey(14)
          rem White
          let temp1 = DLN_arenaNumber
          let temp2 = DLN_xPos
          let temp3 = DLN_yPos
          let temp4 = DLN_color
          let temp5 = DLN_spriteSelect
          rem tail call
          goto DrawDigit
