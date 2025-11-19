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
            
            ; Store to appropriate player pointer based on temp3
            ldx temp3
            beq .SetP0
            dex
            beq .SetP1
            dex
            beq .SetP2
            dex
            beq .SetP3
            dex
            beq .SetP4
            ; else P5
            lda temp4
            sta player5pointerlo
            lda temp5
            sta player5pointerhi
            lda temp6
            sta player5height
            jmp .SetDone
.SetP0
            lda temp4
            sta player0pointerlo
            lda temp5
            sta player0pointerhi
            lda temp6
            sta player0height
            jmp .SetDone
.SetP1
            lda temp4
            sta player1pointerlo
            lda temp5
            sta player1pointerhi
            lda temp6
            sta player1height
            jmp .SetDone
.SetP2
            lda temp4
            sta player2pointerlo
            lda temp5
            sta player2pointerhi
            lda temp6
            sta player2height
            jmp .SetDone
.SetP3
            lda temp4
            sta player3pointerlo
            lda temp5
            sta player3pointerhi
            lda temp6
            sta player3height
            jmp .SetDone
.SetP4
            lda temp4
            sta player4pointerlo
            lda temp5
            sta player4pointerhi
            lda temp6
            sta player4height
.SetDone
end
          return


