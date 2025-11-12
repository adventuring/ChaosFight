          rem
          rem ChaosFight - Source/Routines/SetPlayerGlyphFromFont.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem
          rem Helper: SetPlayerGlyphFromFont
          const FontDataPtr = FontData
          rem Copies 8×16 glyph from FontData into a player’s sprite pointer and sets height.
          rem INPUT:  temp1 = glyph index (0-15)
          rem         temp3 = player index (0-5)  ; 0=P0, 1=P1, ..., 5=P5
          rem OUTPUT: playerN pointer and height set (16)
          rem NOTES:
          rem   - Glyphs are packed consecutively in FontData (16 bytes per glyph)
          rem   - P0 handled separately; P1-P5 use indexed stores
          rem   - Must be included in bank 16 to preserve kernel locality
rem SetPlayerGlyphFromFont
          rem asm
          rem   lda temp1
          rem   asl
          rem   asl
          rem   asl
          rem   asl
          rem   sta temp6
          rem   ; Compute ROM pointer to glyph into temp4/temp5
          rem   clc
          rem   adc # <FontDataPtr
          rem   sta temp4
          rem   lda #0
          rem   adc # >FontDataPtr
          rem   sta temp5
          rem end

          rem rem Player 0 handled specially; others via indexed stores
          rem if temp3 = 0 then SetP0
rem SetP1to5
          rem asm
          rem   ldy temp3
          rem   lda temp4
          rem   sta player1pointerlo-1,y
          rem   lda temp5
          rem   sta player1pointerhi-1,y
          rem   lda #$10
          rem   sta player1height-1,y
          rem end
          rem return

rem SetP0
          rem asm
          rem   lda temp4
          rem   sta player0pointerlo
          rem   lda temp5
          rem   sta player0pointerhi
          rem end
          rem let player0height = 16
          rem return


