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
          rem        setbyte table.
          asm
          ldx temp1
          ldy temp2
          jsr setuppointers

          lda setbyte, x
          and playfield, y
          eor setbyte, x
          beq ReadZero
          lda #$80
ReadZero
          sta temp1
end
          return

