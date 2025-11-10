          rem ChaosFight - Source/Banks/Bank16.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem
          rem SPECIAL PURPOSE BANK: Arenas + Drawscreen
          rem Main loop, drawscreen, arena data/loader, special sprites, numbers font, font rendering

          bank 16

          rem First — data. Must come first. Cannot be moved.
#include "Source/Data/Arenas.bas"
#include "Source/Generated/Numbers.bas"

SetPlayerGlyphFromFont
          rem INPUT: temp1 = glyph index (0-15), temp3 = player index (0-5)
          rem Copies glyph into PlayerFrameBuffer for P0-P3, or points P4/P5 at ROM glyph
          rem Sets corresponding player height to 16
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
            dey
            lda temp4
            sta player1pointerlo,y
            lda temp5
            sta player1pointerhi,y
end
          if temp3 = 1 then player1height = 16 : return
          if temp3 = 2 then player2height = 16 : return
          if temp3 = 3 then player3height = 16 : return
          if temp3 = 4 then player4height = 16 : return
          player5height = 16
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

          

          rem Then — general code. must stay in this bank, but
          rem some sections may be vunerable to relocation if needed.
#include "Source/Routines/ArenaLoader.bas"
#include "Source/Routines/MainLoop.bas"
#include "Source/Routines/SpriteLoader.bas"
#include "Source/Routines/FontRendering.bas"

