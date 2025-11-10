          rem
          rem ChaosFight - Source/Routines/SetPlayerGlyphFromFont.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Helper: SetPlayerGlyphFromFont
          rem Copies 8×16 glyph from FontData into a player’s sprite pointer and sets height.
          rem INPUT:  temp1 = glyph index (0-15)
          rem         temp3 = player index (0-5)  ; 0=P0, 1=P1, ..., 5=P5
          rem OUTPUT: playerN pointer and height set (16)
          rem NOTES:
          rem   - Glyphs are packed consecutively in FontData (16 bytes per glyph)
          rem   - P0 handled separately; P1-P5 use indexed stores
          rem   - Must be included in bank 16 to preserve kernel locality
SetPlayerGlyphFromFont
          asm
            lda temp1
            asl
            asl
            asl
            asl
            sta temp6
            ; Compute ROM pointer to glyph into temp4/temp5
            lda # <FontData
            clc
            adc temp6
            sta temp4
            lda # >FontData
            adc #0
            sta temp5
end
          
          rem Player 0 handled specially; others via indexed stores
          if temp3 = 0 then SetP0
SetP1to5
          asm
            ldy temp3
            lda temp4
            sta player1pointerlo-1,y
            lda temp5
            sta player1pointerhi-1,y
            lda #$10
            sta player1height-1,y
end
          return

SetP0
          asm
            lda temp4
            sta player0pointerlo
            lda temp5
            sta player0pointerhi
end
          let player0height = 16
          return


