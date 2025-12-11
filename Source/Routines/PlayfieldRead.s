;;; ChaosFight - Source/Routines/PlayfieldRead.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


PlayfieldRead .proc
          ;; Read playfield pixel at specified column and row
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp1 = playfield column (0-31), temp2 = playfield
          ;; row (0-7)
          ;;
          ;; Output: temp1 = result (0 = clear, $80 = set)
          ;;
          ;; Mutates: temp1, temp2,x,y, A registers
          ;;
          ;; Called Routines: None (setuppointers inlined and optimized)
          ;;
          ;; Constraints: Must be in Bank 16 where playfield data
          ;; resides. Uses BitMask table.
          ;;
          ;; Optimized: Inlined setuppointers calculation - column/8 + row*2
          ;; No need to save/restore temp2 since we do not use it
          ;; X = column (temp1), Y = row (temp2)
          ldx temp1
          ldy temp2

          ;; Calculate byte offset: (column / 8) + (row * 2)
          ;; Column byte = X / 8 (3 right shifts)
          txa
          lsr
          lsr
          lsr
          sta temp1

          ;; Row byte offset = Y * 2 (1 left shift)
          tya
          asl
          clc
          adc temp1
          tay

          ;; X = bit position within byte (column mod 8)
          txa
          and # 7
          tax

          ;; Read playfield pixel
          lda BitMask,x
          and playfield,y
          eor BitMask,x
          beq ReadZero

          lda #$80

ReadZero:
          sta temp1
          ; Store result
          jsr BS_return

          ;; Bit mask lookup table for playfield column bits
          ;; TODO: #1311 ifndef BitMask
          ;; TODO: #1311 BitMask       BYTE 1,2,4,8,$10,$20,$40,$80



.pend

