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
          rem Input: temp5 = sprite (4 or 5), temp1 = glyph index (0-15)
          rem Output: player4/5 pointer set via bank16 helper, height=16
          if temp5 = 4 then temp3 = 4 else temp3 = 5
          gosub SetPlayerGlyphFromFont bank16
          return

DrawArenaNumber
          rem
          rem Draw Arena Number - P4/P5 ONLY for arena selection
          rem Arena digits always at fixed positions: P4=X80, P5=X88, Y=20, white
          rem Never replicated, never reflected (single width)
          rem INPUT: temp1 = arena number (1-32)
          rem OUTPUT: Arena number displayed using P4/P5 sprites
          rem
          rem Clamp and compute tens/ones via lookup tables (tables contain leading space)
          if temp1 > 32 then temp1 = 32
          if temp1 < 1 then temp1 = 1
          let temp6 = ArenaTens[temp1]
          let temp7 = ArenaOnes[temp1]
          rem Always draw both digits
          let temp1 = temp6
          let temp5 = 4  : gosub DrawArenaDigit bank16
          let temp1 = temp7
          let temp5 = 5  : goto DrawArenaDigit
          rem tail call

          rem Lookup tables to replace division and modulo by 10
          rem Index 0..32 inclusive
          data ArenaTens
            $e, $e, $e, $e, $e, $e, $e, $e, $e,
            1,1,1,1,1,1,1,1,1,1,
            2,2,2,2,2,2,2,2,2,2,
            3,3,3
end
          data ArenaOnes
            1,2,3,4,5,6,7,8,9,
            0,1,2,3,4,5,6,7,8,9,
            0,1,2,3,4,5,6,7,8,9,
            0,1,2
end
