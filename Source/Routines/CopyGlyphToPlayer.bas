          rem ChaosFight - Source/Routines/CopyGlyphToPlayer.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Glyph lookup table: sprite type (0-2) -> glyph index
          data GlyphLookupTable
            GlyphQuestionMark, GlyphCPU, GlyphNo
end

          rem Helper: CopyGlyphToPlayer

CopyGlyphToPlayer
          asm
CopyGlyphToPlayer

end
          rem Input: temp3 = player number (0-3)
          rem        temp4 = sprite type (0=QuestionMark, 1=CPU, 2=No)
          rem Output: Sprite data loaded from unified font

          rem Set glyph index based on sprite type (lookup table optimization)
          temp1 = GlyphLookupTable[temp4]

          rem Calculate offset into font data (16 bytes per glyph)
          let temp2 = temp1 * 16

          rem Set player pointer to font data (optimized: calculate once, store conditionally)
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
            ; else P3
            lda temp4
            sta player3pointerlo
            lda temp5
            sta player3pointerhi
            lda temp6
            sta player3height
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
.SetDone
end
          return
