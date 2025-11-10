          rem
          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          
          rem FONT RENDERING - HEX DIGITS 0-F
          rem Renders 8×16 pixel hexadecimal digits (0-9, A-F) for:
          rem   - Arena selection (0-9) in white
          rem   - Scores and timers

          rem FONT SOURCE:
          rem   Source/Art/Numbers.xcf (128 × 16 px)
          rem   16 digits × 8px wide = 128px total width
          rem   Each digit is 8×16 pixels
          rem   Solid pixels on transparent background

          rem GENERATED FILES:
          rem Source/Generated/Numbers.bas (universal, not TV-specific)

          rem Include font data (universal for all TV standards)

          rem
          rem Draw Digit - Data-driven Version
          rem Draws a single hexadecimal digit (0-F) at specified
          rem   position.
          rem Supports rendering to any player sprite (0-5) for
          rem   simultaneous digits.

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
          rem   Other colors available for custom digit rendering

DrawDigit
          rem EXAMPLE USAGE:
          rem   rem Draw level A (10) in white using player4
          rem temp1 = 10 : temp2 = 40 : temp3 = 20 : temp4 = ColGrey(14)
          rem : temp5 = 4 : gosub DrawDigit
          rem   rem Draw player 2 in red using player5
          rem temp1 = 2 : temp2 = 120 : temp3 = 20 : temp4 = ColRed(14)
          rem : temp5 = 5 : gosub DrawDigit
          rem Draws a single hexadecimal digit (0-F) at specified
          rem position
          rem
          rem Input: temp1 = digit value (0-15)
          rem        temp2 = X position (pixel column)
          rem        temp3 = Y position (pixel row)
          rem        temp4 = color ($00-$FF for specific color)
          rem        temp5 = sprite select (4=player4, 5=player5)
          rem        FontData (ROM constant) = font data array
          rem
          rem Output: player4/5x, player4/5y (TIA registers) set,
          rem COLUP4-COLUP5 set,
          rem         player sprite pointer set via LoadPlayerDigit
          rem
          rem Mutates: temp1 (clamped to 0-15), temp5 (preserved for
          rem LoadPlayerDigit), temp6 (digit offset),
          rem         player4/5x, player4/5y (TIA registers),
          rem         COLUP4-COLUP5 (TIA color registers),
          rem         player sprite pointers (via LoadPlayerDigit)
          rem
          rem Called Routines: LoadPlayerDigit - accesses temp5, temp6,
          rem FontData
          rem
          rem Constraints: Must be colocated with SetSprite0-5,
          rem LoadPlayerDigit (all called via goto)
          rem Clamp digit value to 0-15
          if temp1 > 15 then temp1 = 15
          
          let temp6 = temp1 * 16
          rem Calculate data offset: digit * 16 (16 bytes per digit)
          
          rem Set sprite position and color based on spriteSelect
          rem Clamp spriteSelect to valid range (4-5 only)
          if temp5 < 4 then temp5 = 4
          if temp5 > 5 then temp5 = 4
          rem Preserve spriteSelect in temp5 for LoadPlayerDigit
          if temp5 = 4 then goto SetSprite4 else goto SetSprite5
          
SetSprite4
          rem Set Player 4 sprite position and color
          rem
          rem Input: temp2, temp3, temp4 (from DrawDigit)
          rem
          rem Output: player4x, player4y, COLUP4 set
          rem
          rem Mutates: player4x, player4y, COLUP4 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player4x = temp2
          let player4y = temp3
          let COLUP4 = temp4
          goto LoadPlayerDigit
          rem tail call
SetSprite5
          rem Set Player 5 sprite position and color
          rem
          rem Input: temp2, temp3, temp4 (from DrawDigit)
          rem
          rem Output: player5x, player5y, COLUP5 set
          rem
          rem Mutates: player5x, player5y, COLUP5 (TIA registers)
          rem
          rem Called Routines: None (tail call to LoadPlayerDigit)
          rem Constraints: Must be colocated with DrawDigit, LoadPlayerDigit
          let player5x = temp2
          let player5y = temp3
          let COLUP5 = temp4
          goto LoadPlayerDigit
          rem tail call

LoadPlayerDigit
          rem
          rem Load Digit Data Into Sprites
          rem Consolidated loader that dispatches pointer assignment based on spriteSelect.
          rem Input: temp5 = spriteSelect (4-5), temp6 = digitOffset
          rem Uses spriteSelect from previous DrawDigit call (stored in temp5),
          rem   but we need to preserve it in temp5
          rem        FontData (ROM constant) = font data array base
          rem        address
          rem
          rem Output: player4/5pointerlo/hi set to FontData +
          rem digitOffset, player4/5height set to 16
          rem
          rem Mutates: temp5 (clamped to 4-5), temp6 (clamped to 0-240),
          rem         player4/5pointerlo, player4/5pointerhi (set via
          rem         inline assembly),
          rem         player4/5height (set to 16)
          rem
          rem Called Routines: None (uses inline assembly)
          rem
          rem Constraints: Must be colocated with LoadSprite4Ptr-5Ptr
          rem (all called via on/goto)
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if temp6 > 240 then temp6 = 240
          rem Dispatch to sprite-specific pointer loader based on
          rem spriteSelect
          rem (still in temp5 from DrawDigit)
          if temp5 < 4 then temp5 = 4
          if temp5 > 5 then temp5 = 4
          if temp5 = 4 then goto LoadSprite4Ptr else goto LoadSprite5Ptr
          
LoadSprite4Ptr
          asm
          ; Load Player 4 sprite pointer to font data
          ;
          ; Input: temp6 (from LoadPlayerDigit), FontData
          ; (ROM constant)
          ;
          ; Output: player4pointerlo/hi set, player4height set to 16
          ;
          ; Mutates: player4pointerlo, player4pointerhi (set via
          ; inline assembly), player4height
          ;
          ; Called Routines: None (uses inline assembly)
          ;
          ; Constraints: Must be colocated with LoadPlayerDigit
            lda # <FontData
            clc
            adc temp6
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
            adc temp6
            sta player5pointerlo
            lda # >FontData
            adc #0
            sta player5pointerhi
end
          let player5height = 16
          return

DrawArenaNumber
          rem
          rem Draw Arena Number
          rem Convenience routine to draw an arena number in white.
          rem INPUTS:
          rem   temp1 = arena number (0-31, displays as 1-32)
          rem   temp2 = X position
          rem   temp3 = Y position
          rem temp5 = sprite select (0=player0, 1=player1, 2=player2,
          rem 3=player3, 4=player4, 5=player5)
          let temp4 = ColGrey(14)
          rem White
          goto DrawDigit
          rem tail call
