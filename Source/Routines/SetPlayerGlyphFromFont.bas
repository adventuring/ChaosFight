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
          rem Set player sprite pointer to glyph data
          rem temp1 = glyph index (0-15), temp3 = player index (0-5)

          rem Calculate offset into font data (16 bytes per glyph)
          let temp4 = temp1 * 16

          if temp3 = 0 then goto SetP0
          if temp3 = 1 then goto SetP1
          if temp3 = 2 then goto SetP2
          if temp3 = 3 then goto SetP3
          if temp3 = 4 then goto SetP4
          goto SetP5

SetP0
          player0pointer = FontData + temp4
          player0height = 16
          return

SetP1
          player1pointer = FontData + temp4
          player1height = 16
          return

SetP2
          player2pointer = FontData + temp4
          player2height = 16
          return

SetP3
          player3pointer = FontData + temp4
          player3height = 16
          return

SetP4
          player4pointer = FontData + temp4
          player4height = 16
          return

SetP5
          player5pointer = FontData + temp4
          player5height = 16
          return


