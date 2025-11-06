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
          rem   rem Draw level A (10) in white on left using player0
          rem temp1 = 10 : temp2 = 40 : temp3 = 20 : temp4 = ColGrey(14)
          rem   : temp5 = 0 : gosub DrawDigit
          rem   rem Draw player 2 in red on right using player1
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
          rem Clamp spriteSelect to valid range (0-5)
          if DD_spriteSelect > 5 then let DD_spriteSelect = 0
          let temp5 = DD_spriteSelect
          rem Preserve spriteSelect in temp5 for LoadPlayerDigit
          let temp6 = DD_digitOffset
          rem Dispatch to sprite-specific handler using on/goto
          on DD_spriteSelect goto SetSprite0, SetSprite1, SetSprite2, SetSprite3, SetSprite4, SetSprite5
          
SetSprite0
          let player0x = DD_xPos
          let player0y = DD_yPos
          let COLUP0 = DD_color
          rem tail call
          goto LoadPlayerDigit
SetSprite1
          let player1x = DD_xPos
          let player1y = DD_yPos
          let _COLUP1 = DD_color
          rem tail call
          goto LoadPlayerDigit
SetSprite2
          let player2x = DD_xPos
          let player2y = DD_yPos
          let COLUP2 = DD_color
          rem tail call
          goto LoadPlayerDigit
SetSprite3
          let player3x = DD_xPos
          let player3y = DD_yPos
          let COLUP3 = DD_color
          rem tail call
          goto LoadPlayerDigit
SetSprite4
          let player4x = DD_xPos
          let player4y = DD_yPos
          let COLUP4 = DD_color
          rem tail call
          goto LoadPlayerDigit
SetSprite5
          let player5x = DD_xPos
          let player5y = DD_yPos
          let COLUP5 = DD_color
          rem tail call
          goto LoadPlayerDigit

          rem ==========================================================
          rem LOAD DIGIT DATA INTO SPRITES
          rem ==========================================================
          rem Consolidated generic loader that dispatches to sprite-specific
          rem   pointer assignment based on spriteSelect
          rem INPUT: temp5 = spriteSelect (0-5), temp6 = digitOffset
          rem Uses spriteSelect from previous DrawDigit call (stored in DD_spriteSelect)
          rem   but we need to preserve it in temp5
LoadPlayerDigit
          dim LPD_digitOffset = temp6
          dim LPD_spriteSelect = temp5
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if LPD_digitOffset > 240 then let LPD_digitOffset = 240
          rem Dispatch to sprite-specific pointer loader based on spriteSelect
          rem   (still in temp5 from DrawDigit)
          if LPD_spriteSelect > 5 then let LPD_spriteSelect = 0
          on LPD_spriteSelect goto LoadSprite0Ptr, LoadSprite1Ptr, LoadSprite2Ptr, LoadSprite3Ptr, LoadSprite4Ptr, LoadSprite5Ptr
          
LoadSprite0Ptr
          asm
            lda # <FontData
            clc
            adc LPD_digitOffset
            sta player0pointerlo
            lda # >FontData
            adc #0
            sta player0pointerhi
end
          let player0height = 16
          return
          
LoadSprite1Ptr
          asm
            lda # <FontData
            clc
            adc LPD_digitOffset
            sta player1pointerlo
            lda # >FontData
            adc #0
            sta player1pointerhi
end
          let player1height = 16
          return
          
LoadSprite2Ptr
          asm
            lda # <FontData
            clc
            adc LPD_digitOffset
            sta player2pointerlo
            lda # >FontData
            adc #0
            sta player2pointerhi
end
          let player2height = 16
          return
          
LoadSprite3Ptr
          asm
            lda # <FontData
            clc
            adc LPD_digitOffset
            sta player3pointerlo
            lda # >FontData
            adc #0
            sta player3pointerhi
end
          let player3height = 16
          return
          
LoadSprite4Ptr
          asm
            lda # <FontData
            clc
            adc LPD_digitOffset
            sta player4pointerlo
            lda # >FontData
            adc #0
            sta player4pointerhi
end
          let player4height = 16
          return
          
LoadSprite5Ptr
          asm
            lda # <FontData
            clc
            adc LPD_digitOffset
            sta player5pointerlo
            lda # >FontData
            adc #0
            sta player5pointerhi
end
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
