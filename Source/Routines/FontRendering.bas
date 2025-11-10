          rem
          rem ChaosFight - Source/Routines/FontRendering.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
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
          const ArenaDigitX = $48     ; X position for tens digit (P4)
          const ArenaOnesDigitX = $58 ; X position for ones digit (P5)
          const ArenaDigitY = 20      ; Y position for both digits
          const ArenaDigitColor = ColGrey(14)  ; Always white (single width)

DrawDigit
          rem Thin wrapper: set sprite (temp5→temp3) and copy glyph from FontData
          rem INPUT: temp1 = glyph index (0-15), temp5 = sprite (4 or 5)
          rem OUTPUT: player4/5 pointer set via bank16 helper, height=16
          let temp3 = temp5
          gosub SetPlayerGlyphFromFont bank16
          return
         
