          rem
          rem ChaosFight - Source/Routines/SetGlyph.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Helper: SetGlyph
          rem Sets player sprite pointer to point to 8×16 glyph in ROM FontData and sets height.
          rem INPUT:  temp1 = glyph index (0-15)
          rem         temp3 = player index (0-5)  ; 0=P0, 1=P1, ..., 5=P5
          rem OUTPUT: playerN pointer and height set (16)
          rem NOTES:
          rem   - Glyphs are packed consecutively in FontData (16 bytes per glyph)
          rem   - P0-P5 are all virtual sprites in multisprite kernel - just set pointers to ROM glyphs
          rem   - Must be included in bank 16 to preserve kernel locality
SetGlyph
          asm
SetGlyph

end
          rem Calculate offset into FontData (16 bytes per glyph)
          temp2 = temp1 * 16

          rem Set player pointer and height based on player index (P0 is physical sprite, P1-P5 are virtual sprites)
          rem P1-P5 are all virtual sprites in multisprite kernel - just set pointers to ROM glyphs
          if temp3 = 0 then player0pointer = FontData + temp2 : player0height = 16 : return
          if temp3 = 1 then player1pointer = FontData + temp2 : player1height = 16 : return
          if temp3 = 2 then player2pointer = FontData + temp2 : player2height = 16 : return
          if temp3 = 3 then player3pointer = FontData + temp2 : player3height = 16 : return
          if temp3 = 4 then player4pointer = FontData + temp2 : player4height = 16 : return
          if temp3 = 5 then player5pointer = FontData + temp2 : player5height = 16 : return

          return


