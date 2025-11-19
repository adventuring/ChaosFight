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

          rem Set player pointer and height based on player index (optimized: calculate once, store conditionally)
          rem P1-P5 are all virtual sprites in multisprite kernel - just set pointers to ROM glyphs
          asm
            ; Calculate base address: FontData + temp2 (shared calculation)
            lda #<FontData
            clc
            adc temp2
            sta temp4
            lda #>FontData
            adc #0
            sta temp5
            lda #16
            sta temp6  ; Height constant
end
          rem Store to appropriate player pointer based on temp3 (using then goto to avoid branch out of range)
          if temp3 = 0 then goto SetGlyphP0
          if temp3 = 1 then goto SetGlyphP1
          if temp3 = 2 then goto SetGlyphP2
          if temp3 = 3 then goto SetGlyphP3
          if temp3 = 4 then goto SetGlyphP4
          rem else P5
          asm
            lda temp4
            sta player5pointerlo
            lda temp5
            sta player5pointerhi
            lda temp6
            sta player5height
end
          goto SetGlyphDone
SetGlyphP0
          asm
            lda temp4
            sta player0pointerlo
            lda temp5
            sta player0pointerhi
            lda temp6
            sta player0height
end
          goto SetGlyphDone
SetGlyphP1
          asm
            lda temp4
            sta player1pointerlo
            lda temp5
            sta player1pointerhi
            lda temp6
            sta player1height
end
          goto SetGlyphDone
SetGlyphP2
          asm
            lda temp4
            sta player2pointerlo
            lda temp5
            sta player2pointerhi
            lda temp6
            sta player2height
end
          goto SetGlyphDone
SetGlyphP3
          asm
            lda temp4
            sta player3pointerlo
            lda temp5
            sta player3pointerhi
            lda temp6
            sta player3height
end
          goto SetGlyphDone
SetGlyphP4
          asm
            lda temp4
            sta player4pointerlo
            lda temp5
            sta player4pointerhi
            lda temp6
            sta player4height
end
SetGlyphDone
          return


