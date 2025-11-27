          rem ChaosFight - Source/Routines/SetPlayerGlyph.bas

          rem Copyright © 2025 Bruce-Robert Pocock.

          rem

          rem Unified helper: SetPlayerGlyph

          rem Sets player sprite pointer to point to 8×16 glyph in ROM FontData and sets height.

          rem Supports both direct glyph index and sprite type lookup modes.

          rem

          rem INPUT MODE 1 (direct glyph index):

          rem   temp1 = glyph index (0-15)

          rem   temp3 = player index (0-5)

          rem

          rem INPUT MODE 2 (sprite type lookup):

          rem   temp3 = player index (0-5)

          rem   temp4 = sprite type (0=QuestionMark, 1=CPU, 2=No)

          rem   If temp4 is provided, temp1 is looked up from GlyphLookupTable

          rem

          rem OUTPUT: playerN pointer and height set (16)

          rem

          rem NOTES:

          rem   - Glyphs are packed consecutively in FontData (16 bytes per glyph)

          rem   - P0-P5 are all virtual sprites in multisprite kernel - just set pointers to ROM glyphs

          rem   - Must be included in bank 16 to preserve kernel locality



          rem Glyph lookup table: sprite type (0-2) -> glyph index

          data GlyphLookupTable

            GlyphQuestionMark, GlyphCPU, GlyphNo

end



SetPlayerGlyph

          asm

SetPlayerGlyph

end

          rem Unified function supports two input modes:

          rem Mode 1 (direct): temp1 = glyph index, temp3 = player index

          rem Mode 2 (lookup): temp3 = player index, temp4 = sprite type (0-2)

          rem Detect mode: if temp4 is valid sprite type (0-2), use lookup mode

          rem Otherwise assume temp1 already contains glyph index

          rem temp4 is 0-2, so this is sprite type lookup mode

          if temp4 > 2 then goto SetPlayerGlyphDirectMode

          rem Look up glyph index from table (overwrites temp1)

          temp1 = GlyphLookupTable[temp4]

SetPlayerGlyphDirectMode

          rem Calculate offset into FontData (16 bytes per glyph)

          temp2 = temp1 * 16



          rem Set player pointer and height based on player index

          rem Calculate base address: FontData + temp2 (shared calculation)

          asm

            lda #<FontData

            clc

            adc temp2

            sta temp4

            lda #>FontData

            adc #0

            sta temp5

end

          rem Store to appropriate player pointer based on temp3 (using on...goto for efficiency)

          rem Fall through to P5 if temp3 > 4

          on temp3 goto SetPlayerGlyphP0 SetPlayerGlyphP1 SetPlayerGlyphP2 SetPlayerGlyphP3 SetPlayerGlyphP4 SetPlayerGlyphP5

SetPlayerGlyphP5

          asm

            lda temp4

            sta player5pointerlo

            lda temp5

            sta player5pointerhi

            lda #16

            sta player5height

end

          return thisbank

SetPlayerGlyphP0

          asm

            lda temp4

            sta player0pointerlo

            lda temp5

            sta player0pointerhi

            lda #16

            sta player0height

end

          return thisbank

SetPlayerGlyphP1

          asm

            lda temp4

            sta player1pointerlo

            lda temp5

            sta player1pointerhi

            lda #16

            sta player1height

end

          return thisbank

SetPlayerGlyphP2

          asm

            lda temp4

            sta player2pointerlo

            lda temp5

            sta player2pointerhi

            lda #16

            sta player2height

end

          return thisbank

SetPlayerGlyphP3

          asm

            lda temp4

            sta player3pointerlo

            lda temp5

            sta player3pointerhi

            lda #16

            sta player3height

end

          return thisbank

SetPlayerGlyphP4

          asm

            lda temp4

            sta player4pointerlo

            lda temp5

            sta player4pointerhi

            lda #16

            sta player4height

end

          return thisbank



          rem Backward compatibility wrappers

SetGlyph

          asm

SetGlyph

end

          rem Wrapper for SetPlayerGlyph - direct glyph index mode

          rem Input: temp1 = glyph index, temp3 = player index

          rem Set temp4 to invalid value to force direct mode

          let temp4 = 255

          goto SetPlayerGlyph



CopyGlyphToPlayer

          asm

CopyGlyphToPlayer

end

          rem Wrapper for SetPlayerGlyph - sprite type lookup mode

          rem Input: temp3 = player index, temp4 = sprite type (0-2)

          rem temp4 already set by caller, will trigger lookup mode

          goto SetPlayerGlyph


