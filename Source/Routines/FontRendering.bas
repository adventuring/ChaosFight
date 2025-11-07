          rem
          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem FONT RENDERING - HEX DIGITS 0-f
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

          rem Include font data (universal for all TV standards)
          #include "Source/Generated/Numbers.bas"

          rem
          rem Draw Digit - Data-driven Version
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

DrawDigit
          rem EXAMPLE USAGE:
          rem   rem Draw level A (10) in white on left using player0
          rem temp1 = 10 : temp2 = 40 : temp3 = 20 : temp4 = ColGrey(14)
          rem   : temp5 = 0 : gosub DrawDigit
          rem   rem Draw player 2 in red on right using player1
          rem temp1 = 2 : temp2 = 120 : temp3 = 20 : temp4 = ColRed(14)
          rem   : temp5 = 1 : gosub DrawDigit
          rem Draws a single hexadecimal digit (0-F) at specified
          rem position
          rem
          rem Input: temp1 = digit value (0-15)
          rem        temp2 = X position (pixel column)
          rem        temp3 = Y position (pixel row)
          rem        temp4 = color ($00-$FF for specific color)
          rem        temp5 = sprite select (0=player0, 1=player1,
          rem        2=player2, 3=player3, 4=player4, 5=player5)
          rem        FontData (ROM constant) = font data array
          rem
          rem Output: player0-5x, player0-5y (TIA registers) set,
          rem COLUP0-COLUP5 set,
          rem         player sprite pointer set via LoadPlayerDigit
          rem
          rem Mutates: temp1 (clamped to 0-15), temp5 (preserved for
          rem LoadPlayerDigit), temp6 (digit offset),
          rem         player0-5x, player0-5y (TIA registers),
          rem         COLUP0-COLUP5 (TIA color registers),
          rem         player sprite pointers (via LoadPlayerDigit)
          rem
          rem Called Routines: LoadPlayerDigit - accesses temp5, temp6,
          rem FontData
          rem
          rem Constraints: Must be colocated with SetSprite0-5,
          rem LoadPlayerDigit (all called via goto)
          dim DD_digit = temp1
          dim DD_xPos = temp2
          dim DD_yPos = temp3
          dim DD_color = temp4
          dim DD_spriteSelect = temp5
          dim DD_digitOffset = temp6
          if DD_digit > 15 then let DD_digit = 15 : rem Clamp digit value to 0-15
          
          let DD_digitOffset = DD_digit * 16 : rem Calculate data offset: digit * 16 (16 bytes per digit)
          
          rem Set sprite position and color based on spriteSelect
          if DD_spriteSelect > 5 then let DD_spriteSelect = 0 : rem Clamp spriteSelect to valid range (0-5)
          let temp5 = DD_spriteSelect
          let temp6 = DD_digitOffset : rem Preserve spriteSelect in temp5 for LoadPlayerDigit
          rem Dispatch to sprite-specific handler using if/goto
          if DD_spriteSelect = 0 then goto SetSprite0
          if DD_spriteSelect = 1 then goto SetSprite1
          if DD_spriteSelect = 2 then goto SetSprite2
          if DD_spriteSelect = 3 then goto SetSprite3
          if DD_spriteSelect = 4 then goto SetSprite4
          if DD_spriteSelect = 5 then goto SetSprite5
          
SetSprite0
          rem Set Player 0 sprite position and color
          rem
          rem Input: DD_xPos, DD_yPos, DD_color (from DrawDigit)
          rem
          rem Output: player0x, player0y, COLUP0 set
          rem
          rem Mutates: player0x, player0y, COLUP0 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          let player0x = DD_xPos : rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player0y = DD_yPos
          let COLUP0 = DD_color
          goto LoadPlayerDigit : rem tail call
SetSprite1
          rem Set Player 1 sprite position and color
          rem
          rem Input: DD_xPos, DD_yPos, DD_color (from DrawDigit)
          rem
          rem Output: player1x, player1y, _COLUP1 set
          rem
          rem Mutates: player1x, player1y, _COLUP1 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          let player1x = DD_xPos : rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player1y = DD_yPos
          let _COLUP1 = DD_color
          goto LoadPlayerDigit : rem tail call
SetSprite2
          rem Set Player 2 sprite position and color
          rem
          rem Input: DD_xPos, DD_yPos, DD_color (from DrawDigit)
          rem
          rem Output: player2x, player2y, COLUP2 set
          rem
          rem Mutates: player2x, player2y, COLUP2 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          let player2x = DD_xPos : rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player2y = DD_yPos
          let COLUP2 = DD_color
          goto LoadPlayerDigit : rem tail call
SetSprite3
          rem Set Player 3 sprite position and color
          rem
          rem Input: DD_xPos, DD_yPos, DD_color (from DrawDigit)
          rem
          rem Output: player3x, player3y, COLUP3 set
          rem
          rem Mutates: player3x, player3y, COLUP3 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          let player3x = DD_xPos : rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player3y = DD_yPos
          let COLUP3 = DD_color
          goto LoadPlayerDigit : rem tail call
SetSprite4
          rem Set Player 4 sprite position and color
          rem
          rem Input: DD_xPos, DD_yPos, DD_color (from DrawDigit)
          rem
          rem Output: player4x, player4y, COLUP4 set
          rem
          rem Mutates: player4x, player4y, COLUP4 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          let player4x = DD_xPos : rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player4y = DD_yPos
          let COLUP4 = DD_color
          goto LoadPlayerDigit : rem tail call
SetSprite5
          rem Set Player 5 sprite position and color
          rem
          rem Input: DD_xPos, DD_yPos, DD_color (from DrawDigit)
          rem
          rem Output: player5x, player5y, COLUP5 set
          rem
          rem Mutates: player5x, player5y, COLUP5 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          let player5x = DD_xPos : rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player5y = DD_yPos
          let COLUP5 = DD_color
          goto LoadPlayerDigit : rem tail call

LoadPlayerDigit
          rem
          rem Load Digit Data Into Sprites
          rem Consolidated generic loader that dispatches to
          rem sprite-specific
          rem   pointer assignment based on spriteSelect
          rem
          rem INPUT: temp5 = spriteSelect (0-5), temp6 = digitOffset
          rem Uses spriteSelect from previous DrawDigit call (stored in
          rem DD_spriteSelect)
          rem   but we need to preserve it in temp5
          rem Consolidated generic loader that dispatches to
          rem sprite-specific pointer assignment
          rem
          rem Input: temp5 = spriteSelect (0-5), temp6 = digitOffset
          rem        FontData (ROM constant) = font data array base
          rem        address
          rem
          rem Output: player0-5pointerlo/hi set to FontData +
          rem digitOffset, player0-5height set to 16
          rem
          rem Mutates: temp5 (clamped to 0-5), temp6 (clamped to 0-240),
          rem         player0-5pointerlo, player0-5pointerhi (set via
          rem         inline assembly),
          rem         player0-5height (set to 16)
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with LoadSprite0Ptr-5Ptr
          rem (all called via on/goto)
          dim LPD_digitOffset = temp6
          dim LPD_spriteSelect = temp5
          if LPD_digitOffset > 240 then let LPD_digitOffset = 240 : rem Clamp digit offset to valid range (0-240 for digits 0-15)
          rem Dispatch to sprite-specific pointer loader based on
          rem spriteSelect
          if LPD_spriteSelect > 5 then let LPD_spriteSelect = 0 : rem   (still in temp5 from DrawDigit)
          if LPD_spriteSelect = 0 then goto LoadSprite0Ptr
          if LPD_spriteSelect = 1 then goto LoadSprite1Ptr
          if LPD_spriteSelect = 2 then goto LoadSprite2Ptr
          if LPD_spriteSelect = 3 then goto LoadSprite3Ptr
          if LPD_spriteSelect = 4 then goto LoadSprite4Ptr
          if LPD_spriteSelect = 5 then goto LoadSprite5Ptr
          
LoadSprite0Ptr
          asm
          rem Load Player 0 sprite pointer to font data
          rem
          rem Input: LPD_digitOffset (from LoadPlayerDigit), FontData
          rem (ROM constant)
          rem
          rem Output: player0pointerlo/hi set, player0height set to 16
          rem
          rem Mutates: player0pointerlo, player0pointerhi (set via
          rem inline assembly), player0height
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with LoadPlayerDigit
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
          rem Load Player 1 sprite pointer to font data
          rem
          rem Input: LPD_digitOffset (from LoadPlayerDigit), FontData
          rem (ROM constant)
          rem
          rem Output: player1pointerlo/hi set, player1height set to 16
          rem
          rem Mutates: player1pointerlo, player1pointerhi (set via
          rem inline assembly), player1height
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with LoadPlayerDigit
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
          rem Load Player 2 sprite pointer to font data
          rem
          rem Input: LPD_digitOffset (from LoadPlayerDigit), FontData
          rem (ROM constant)
          rem
          rem Output: player2pointerlo/hi set, player2height set to 16
          rem
          rem Mutates: player2pointerlo, player2pointerhi (set via
          rem inline assembly), player2height
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with LoadPlayerDigit
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
          rem Load Player 3 sprite pointer to font data
          rem
          rem Input: LPD_digitOffset (from LoadPlayerDigit), FontData
          rem (ROM constant)
          rem
          rem Output: player3pointerlo/hi set, player3height set to 16
          rem
          rem Mutates: player3pointerlo, player3pointerhi (set via
          rem inline assembly), player3height
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with LoadPlayerDigit
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
          rem Load Player 4 sprite pointer to font data
          rem
          rem Input: LPD_digitOffset (from LoadPlayerDigit), FontData
          rem (ROM constant)
          rem
          rem Output: player4pointerlo/hi set, player4height set to 16
          rem
          rem Mutates: player4pointerlo, player4pointerhi (set via
          rem inline assembly), player4height
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with LoadPlayerDigit
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

DrawPlayerNumber
          rem
          rem Draw Player Number
          rem Convenience routine to draw a player number in their
          rem   color.
          rem INPUTS:
          rem   temp1 = player index (0-3)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem   temp5 = sprite select (0=player0, 1=player1)
          rem Player colors are looked up from a table.
          dim DPN_playerIndex = temp1
          dim DPN_playerDigit = temp1
          dim DPN_xPos = temp2
          dim DPN_yPos = temp3
          dim DPN_playerColor = temp4
          dim DPN_spriteSelect = temp5
          let DPN_playerDigit = DPN_playerIndex + 1 : rem Convert player index to digit (0→1, 1→2, 2→3, 3→4)
          
          let temp1 = DPN_playerIndex : rem Look up player color
          if temp1 = 0 then goto SetP1Color
          if temp1 = 1 then goto SetP2Color
          if temp1 = 2 then goto SetP3Color
          if temp1 = 3 then goto SetP4Color
          
SetP1Color
          let DPN_playerColor = ColIndigo(14)
          goto DrawPlayerDigitNow : rem Indigo
          
SetP2Color
          let DPN_playerColor = ColRed(14)
          goto DrawPlayerDigitNow : rem Red
          
SetP3Color
          let DPN_playerColor = ColYellow(14)
          goto DrawPlayerDigitNow : rem Yellow
          
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
          let temp1 = DPN_playerDigit : rem Set up parameters for DrawDigit
          let temp2 = DPN_xPos
          let temp3 = DPN_yPos
          let temp4 = DPN_playerColor
          let temp5 = DPN_spriteSelect
          goto DrawDigit : rem tail call

DrawArenaNumber
          rem
          rem Draw Arena Number
          rem Convenience routine to draw an arena number in white.
          rem INPUTS:
          rem   temp1 = arena number (0-31, displays as 1-32)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem temp5 = sprite select (0=player0, 1=player1, 2=player2,
          dim DLN_arenaNumber = temp1 : rem 3=player3, 4=player4, 5=player5)
          dim DLN_xPos = temp2
          dim DLN_yPos = temp3
          dim DLN_color = temp4
          dim DLN_spriteSelect = temp5
          let DLN_color = ColGrey(14)
          let temp1 = DLN_arenaNumber : rem White
          let temp2 = DLN_xPos
          let temp3 = DLN_yPos
          let temp4 = DLN_color
          let temp5 = DLN_spriteSelect
          goto DrawDigit : rem tail call
