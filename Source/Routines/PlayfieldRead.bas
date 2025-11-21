          rem ChaosFight - Source/Routines/PlayfieldRead.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

PlayfieldRead
          rem Read playfield pixel at specified column and row
          rem
          rem Input: temp1 = playfield column (0-31), temp2 = playfield
          rem        row (0-7)
          rem
          rem Output: temp1 = result (0 = clear, $80 = set)
          rem
          rem Mutates: temp1, temp2, X, Y, A registers
          rem
          rem Called Routines: None (setuppointers inlined and optimized)
          rem
          rem Constraints: Must be in Bank 16 where playfield data
          rem        resides. Uses BitMask table.
          rem
          rem Optimized: Inlined setuppointers calculation - column/8 + row*2
          rem        No need to save/restore temp2 since we do not use it
          asm
PlayfieldRead
end
          asm
          ; Inlined setuppointers: calculate playfield byte offset
          ; X = column (temp1), Y = row (temp2)
          ; Result: Y = byte offset, X = bit position (0-7)
          ldx temp1          ; X = column (0-31)
          ldy temp2          ; Y = row (0-7)
          
          ; Calculate byte offset: (column / 8) + (row * 2)
          ; Column byte = X / 8 (3 right shifts)
          txa                ; A = column
          lsr                ; /2
          lsr                ; /4
          lsr                ; /8 (column byte offset)
          sta temp1          ; Save column byte offset
          
          ; Row byte offset = Y * 2 (1 left shift)
          tya                ; A = row
          asl                ; *2 (row byte offset)
          clc
          adc temp1          ; Add column and row offsets
          tay                ; Y = final byte offset in playfield
          
          ; X = bit position within byte (column mod 8)
          txa                ; A = original column
          and #7             ; Mask to get bit position (0-7)
          tax                ; X = bit position for BitMask lookup
          
          ; Read playfield pixel
          lda BitMask, x     ; Get bit mask for this bit position
          and playfield, y  ; AND with playfield byte
          eor BitMask, x     ; XOR to check if bit was set
          beq ReadZero       ; If zero, bit was clear
          lda #$80           ; Bit was set
ReadZero
          sta temp1          ; Store result
end
          return

          rem Bit mask lookup table for playfield column bits
          asm
            ifndef BitMask
BitMask       BYTE 1,2,4,8,$10,$20,$40,$80
            endif
end

