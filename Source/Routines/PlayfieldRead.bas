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
          rem Called Routines: setuppointers (kernel routine)
          rem
          rem Constraints: Must be in Bank 16 where playfield data
          rem        resides. Uses kernel routines setuppointers and
          rem        BitMask table.
          asm
          ldx temp1
          ldy temp2
          jsr setuppointers

          lda BitMask, x
          and playfield, y
          eor BitMask, x
          beq ReadZero
          lda #$80
ReadZero
          sta temp1
end
          return

          rem Bit mask lookup table for playfield column bits
          asm
BitMask   BYTE 1,2,4,8,$10,$20,$40,$80
end

