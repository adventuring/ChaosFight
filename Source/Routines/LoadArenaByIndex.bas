          rem ChaosFight - Source/Routines/LoadArenaByIndex.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem Arena loading function

LoadArenaByIndex
          rem Returns: Far (return otherbank)
          asm
LoadArenaByIndex

end
          rem Load arena data by index into playfield RAM
          rem Returns: Far (return otherbank)
          rem Input: temp1 = arena index (0-31)
          rem Output: Playfield RAM loaded with arena data
          rem Mutates: PF1pointer, PF2pointer, temp2-temp5
          rem Constraints: PF0pointer remains glued to the status bar layout
          rem             Arena playfield data stored sequentially: PF1|PF2 (8 bytes each)

          rem Calculate arena data pointer: Arena0Playfield + (arena_index × 24)
          rem Each arena stores 16 bytes of playfield data followed by 8 bytes of row colors (16 + 8 = 24)
          asm
            ; Optimized: Multiply by 24 = multiply by 8, then multiply by 3
            ; 24 = 8 * 3, so: arena_index * 24 = (arena_index * 8) * 3
            lda temp1
            sta temp2
            lda #0
            sta temp3
            
            ; Multiply by 8 (3 shifts)
            ldx #3
.MultiplyBy8
            asl temp2
            rol temp3
            dex
            bne .MultiplyBy8
            
            ; Now multiply by 3: temp2/temp3 * 3 = temp2/temp3 + (temp2/temp3 * 2)
            ; Store original value for addition
            lda temp2
            sta temp4
            lda temp3
            sta temp5
            
            ; Multiply by 2 (1 shift)
            asl temp2
            rol temp3
            
            ; Add original to get * 3
            clc
            lda temp2
            adc temp4
            sta temp2
            lda temp3
            adc temp5
            sta temp3

            ; Add base address
            lda #<.Arena0Playfield
            clc
            adc temp2
            sta temp4
            lda #>.Arena0Playfield
            adc temp3
            sta temp5

            lda temp4
            sta PF1pointer
            sta PF2pointer
            lda temp5
            sta PF1pointer+1
            sta PF2pointer+1
end
          return otherbank
