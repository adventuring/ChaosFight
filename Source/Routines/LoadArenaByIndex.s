;;; ChaosFight - Source/Routines/LoadArenaByIndex.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Arena loading function


LoadArenaByIndex .proc

          ;; Load arena data by index into playfield RAM
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = arena index (0-31)
          ;; Output: Playfield RAM loaded with arena data
          ;; Mutates: PF1pointer, PF2pointer, temp2-temp5
          ;; Constraints: PF0pointer remains glued to the status bar layout
          ;; Arena playfield data stored sequentially: PF1|PF2 (8 bytes each)
          ;; Calculate arena data pointer: Arena0Playfield + (arena_index × 24)
          ;; Each arena stores 16 bytes of playfield data followed by 8 bytes of row colors (16 + 8 = 24)
          ;; TODO: ; Optimized: Multiply by 24 = multiply by 8, then multiply by 3
so:


arena_index:


            lda temp1
            sta temp2
            lda # 0
            sta temp3

          ;; TODO: ; Multiply by 8 (3 shifts)
                    ldx # 3
MultiplyBy8:

            asl temp2
            rol temp3
            dex
            bne MultiplyBy8

          ;; TODO: ; Now multiply by 3: temp2/temp3 * 3 = temp2/temp3 + (temp2/temp3 * 2)
          ;; TODO: ; Store original value for addition
            lda temp2
            sta temp4
            lda temp3
            sta temp5

          ;; TODO: ; Multiply by 2 (1 shift)
            asl temp2
            rol temp3

          ;; TODO: ; Add original to get * 3
            clc
            lda temp2
            adc temp4
            sta temp2
            lda temp3
            adc temp5
            sta temp3

          ;; TODO: ; Add base address
            lda # <.Arena0Playfield
            clc
            adc temp2
            sta temp4
            lda # >.Arena0Playfield
            adc temp3
            sta temp5

            lda temp4
            sta PF1pointer
            sta PF2pointer
            lda temp5
            sta PF1pointer+1
            sta PF2pointer+1
          jsr BS_return

.pend

