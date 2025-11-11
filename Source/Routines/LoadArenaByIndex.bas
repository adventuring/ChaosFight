          rem ChaosFight - Source/Routines/LoadArenaByIndex.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Arena loading function

LoadArenaByIndex
          rem Load arena data by index into playfield RAM
          rem Input: temp1 = arena index (0-31)
          rem Output: Playfield RAM loaded with arena data
          rem Mutates: PF0-PF2 pointers, temp variables

          rem Calculate arena data pointer: Arena0Playfield + (arena_index * 96)
          rem Each arena is 96 bytes: 8 PF rows * 2 bytes each + 8 bytes for color data
          asm
            ; Compute arena offset = arena_index * 96 (96 = 32 * 3)
            lda temp1
            sta temp2
            lda #0
            sta temp3
            ldx #5
.MultiplyBy32
            asl temp2
            rol temp3
            dex
            bne .MultiplyBy32

            lda temp2
            sta temp4
            lda temp3
            sta temp5

            asl temp4
            rol temp5

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
            sta PF0pointer
            lda #>.Arena0Playfield
            adc temp3
            sta PF0pointer+1

            ; Set up PF1 and PF2 pointers
            lda PF0pointer
            clc
            adc #32  ; Next 32 bytes
            sta PF1pointer
            lda PF0pointer+1
            adc #0
            sta PF1pointer+1

            lda PF1pointer
            clc
            adc #32  ; Next 32 bytes
            sta PF2pointer
            lda PF1pointer+1
            adc #0
            sta PF2pointer+1

            ; Check if PF2 crosses page boundary
            bcc .NoAlignPF2
            lda #0
            sta PF2pointer
            lda PF1pointer+1
            clc
            adc #1
            sta PF2pointer+1
            jmp .PF2Done
.NoAlignPF2
            lda PF1pointer+1
            sta PF2pointer+1
.PF2Done
end
          return
