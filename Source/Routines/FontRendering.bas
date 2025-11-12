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

          rem Bank 16 exposes only SetFontGlyph for arena digits
          rem Callers must set temp1 = glyph (0-15) and temp3 = sprite (4 or 5)

