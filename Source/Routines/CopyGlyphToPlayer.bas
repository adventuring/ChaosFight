          rem ChaosFight - Source/Routines/CopyGlyphToPlayer.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Glyph lookup table: sprite type (0-2) -> glyph index
          data GlyphLookupTable
            GlyphQuestionMark, GlyphCPU, GlyphNo
end

          rem Helper function to copy glyph sprite to player
CopyGlyphToPlayer
          rem CopyGlyphToPlayer - Helper function to copy glyph sprite to player
          rem Input: temp3 = player number (0-3)
          rem        temp4 = sprite type (0=QuestionMark, 1=CPU, 2=No)
          rem Output: Sprite data loaded from unified font

          rem Set glyph index based on sprite type (lookup table optimization)
          temp1 = GlyphLookupTable[temp4]

          rem Calculate offset into font data (16 bytes per glyph)
          let temp2 = temp1 * 16

          rem Set player pointer to font data
          if temp3 = 0 then player0pointer = FontData + temp2 : player0height = 16
          if temp3 = 1 then player1pointer = FontData + temp2 : player1height = 16
          if temp3 = 2 then player2pointer = FontData + temp2 : player2height = 16
          if temp3 = 3 then player3pointer = FontData + temp2 : player3height = 16

          return

          rem Global label for cross-bank access to CopyGlyphToPlayer
          asm
CopyGlyphToPlayer = .CopyGlyphToPlayer
end
