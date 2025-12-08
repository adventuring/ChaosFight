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
            ;; lda # 0 (duplicate)
            ;; sta temp3 (duplicate)

          ;; TODO: ; Multiply by 8 (3 shifts)
                    ldx # 3
MultiplyBy8:

            asl temp2
            rol temp3
            dex
            bne MultiplyBy8

          ;; TODO: ; Now multiply by 3: temp2/temp3 * 3 = temp2/temp3 + (temp2/temp3 * 2)
          ;; TODO: ; Store original value for addition
            ;; lda temp2 (duplicate)
            ;; sta temp4 (duplicate)
            ;; lda temp3 (duplicate)
            ;; sta temp5 (duplicate)

          ;; TODO: ; Multiply by 2 (1 shift)
            ;; asl temp2 (duplicate)
            ;; rol temp3 (duplicate)

          ;; TODO: ; Add original to get * 3
            clc
            ;; lda temp2 (duplicate)
            adc temp4
            ;; sta temp2 (duplicate)
            ;; lda temp3 (duplicate)
            ;; adc temp5 (duplicate)
            ;; sta temp3 (duplicate)

          ;; TODO: ; Add base address
            ;; lda # <.Arena0Playfield (duplicate)
            ;; clc (duplicate)
            ;; adc temp2 (duplicate)
            ;; sta temp4 (duplicate)
            ;; lda # >.Arena0Playfield (duplicate)
            ;; adc temp3 (duplicate)
            ;; sta temp5 (duplicate)

            ;; lda temp4 (duplicate)
            ;; sta PF1pointer (duplicate)
            ;; sta PF2pointer (duplicate)
            ;; lda temp5 (duplicate)
            ;; sta PF1pointer+1 (duplicate)
            ;; sta PF2pointer+1 (duplicate)
          jsr BS_return

.pend

