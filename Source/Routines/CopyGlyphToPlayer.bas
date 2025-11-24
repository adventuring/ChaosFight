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
end
          rem Store to appropriate player pointer based on temp3 (using then goto to avoid branch out of range)
          if temp3 = 0 then goto CopyGlyphP0
          if temp3 = 1 then goto CopyGlyphP1
          if temp3 = 2 then goto CopyGlyphP2
          rem else P3
          asm
            lda temp4
            sta player3pointerlo
            lda temp5
            sta player3pointerhi
            lda #16
            sta player3height
end
          return otherbank
          
CopyGlyphP0
          asm
            lda temp4
            sta player0pointerlo
            lda temp5
            sta player0pointerhi
            lda #16
            sta player0height
end
          return otherbank

CopyGlyphP1
          asm
            lda temp4
            sta player1pointerlo
            lda temp5
            sta player1pointerhi
            lda #16
            sta player1height
end
          return otherbank

CopyGlyphP2
          asm
            lda temp4
            sta player2pointerlo
            lda temp5
            sta player2pointerhi
            lda #16
            sta player2height
end
          return otherbank
