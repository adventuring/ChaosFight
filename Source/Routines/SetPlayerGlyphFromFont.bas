          rem
          rem ChaosFight - Source/Routines/SetGlyph.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Helper: SetGlyph
          rem Copies 8×16 glyph from FontData into a player’s sprite pointer and sets height.
          rem INPUT:  temp1 = glyph index (0-15)
          rem         temp3 = player index (0-5)  ; 0=P0, 1=P1, ..., 5=P5
          rem OUTPUT: playerN pointer and height set (16)
          rem NOTES:
          rem   - Glyphs are packed consecutively in FontData (16 bytes per glyph)
          rem   - P0 handled separately; P1-P5 use indexed stores
          rem   - Must be included in bank 16 to preserve kernel locality
SetGlyph
          rem Stub - function not implemented yet
          return


