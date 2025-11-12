          rem ChaosFight - Source/Routines/CopyGlyphToPlayer.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Helper: CopyGlyphToPlayer

CopyGlyphToPlayer
          asm
; Input: temp3 = player number (0-3)
;        temp4 = sprite type (0=QuestionMark, 1=CPU, 2=No)
; Output: Sprite data loaded from unified font
          end
          if temp4 = 0 then temp1 = GlyphQuestionMark
          if temp4 = 1 then temp1 = GlyphCPU
          if temp4 = 2 then temp1 = GlyphNo
          gosub SetFontGlyph bank16
          return
