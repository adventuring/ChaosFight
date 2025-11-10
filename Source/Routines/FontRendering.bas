          rem
          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          
          rem ARENA DIGIT RENDERING - P4/P5 only
          rem Renders arena selection numbers using player sprites 4 and 5
          rem Always at fixed positions (X=80,88 Y=20), always white

          rem FONT SOURCE:
          rem   Source/Art/Numbers.xcf (128 × 16 px)
          rem   16 digits × 8px wide = 128px total width
          rem   Each digit is 8×16 pixels
          rem   Solid pixels on transparent background

          rem GENERATED FILES:
          rem Source/Generated/Numbers.bas (universal, not TV-specific)

          rem ARENA SELECTION DIGIT CONSTANTS
          rem P4/P5 sprites are used ONLY for arena selection display
          rem Always at fixed positions, always white, never replicated/reflected
          const ArenaDigitX = 80    ; X position for tens digit (P4)
          const ArenaOnesDigitX = 88 ; X position for ones digit (P5)
          const ArenaDigitY = 20    ; Y position for both digits
          const ArenaDigitColor = ColGrey(14)  ; Always white (single width)

          rem Include font data (universal for all TV standards)

          rem
          rem Draw Arena Digit - P4/P5 only, fixed positions, white
          rem Simplified for arena selection: always P4/P5, always white,
          rem always at ArenaDigitX/Y positions

DrawArenaDigit
          rem INPUT: temp1 = digit value (0-15), temp5 = sprite (4 or 5)
          rem OUTPUT: Digit drawn to P4 or P5 at arena positions, white
          rem
          rem Clamp digit value to 0-15
          if temp1 > 15 then temp1 = 15

          let temp6 = temp1 * 16
          rem Calculate data offset: digit * 16 (16 bytes per digit)

          rem Set fixed arena positions and white color
          if temp5 = 4 then goto SetArenaSprite4 else goto SetArenaSprite5

SetArenaSprite4
          let player4x = ArenaDigitX
          let player4y = ArenaDigitY
          let COLUP4 = ArenaDigitColor
          goto LoadArenaPlayerDigit
          rem tail call

SetArenaSprite5
          let player5x = ArenaOnesDigitX
          let player5y = ArenaDigitY
          let COLUP5 = ArenaDigitColor
          goto LoadArenaPlayerDigit
          rem tail call

LoadArenaPlayerDigit
          rem
          rem Load Arena Digit Data Into P4/P5 Sprites
          rem Simplified for arena digits: always P4 or P5, temp6 = digitOffset
          rem
          rem Input: temp5 = sprite (4 or 5), temp6 = digitOffset
          rem Output: player4/5pointerlo/hi set, player4/5height set to 16
          rem
          rem Clamp digit offset to valid range (0-240 for digits 0-15)
          if temp6 > 240 then temp6 = 240

          if temp5 = 4 then goto LoadArenaSprite4Ptr else goto LoadArenaSprite5Ptr

LoadArenaSprite4Ptr
          asm
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

LoadArenaSprite5Ptr
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
          rem Draw Arena Number - P4/P5 ONLY for arena selection
          rem Arena digits always at fixed positions: P4=X80, P5=X88, Y=20, white
          rem Never replicated, never reflected (single width)
          rem INPUT: temp1 = arena number (1-32)
          rem OUTPUT: Arena number displayed using P4/P5 sprites
          rem
          rem Calculate tens and ones digits
          let temp6 = temp1 / 10  ; Tens digit (0-3)
          let temp7 = temp1 - (temp6 * 10)  ; Ones digit (0-9)
          rem
          rem Tens digit (P4) - only shown for arenas 10-32
          if temp6 > 0 then DrawArenaTensDigit
          rem Ones digit (P5) - always shown
          let temp1 = temp7
          goto DrawArenaOnesDigit

DrawArenaTensDigit
          let temp1 = temp6
          let temp5 = 4  ; P4 for tens digit
          gosub DrawArenaDigit bank16
          rem Fall through to ones digit

DrawArenaOnesDigit
          let temp1 = temp7
          let temp5 = 5  ; P5 for ones digit
          goto DrawArenaDigit
          rem tail call
