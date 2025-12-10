;;; ChaosFight - Source/Routines/PlayfieldRead.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


PlayfieldRead .proc
;;; Read playfield pixel at specified column and row
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
PlayfieldRead
setuppointers:


calculate:


          ;; TODO: ; X = column (temp1),y = row (temp2)
Result:


Y


                    ldx temp1          ; X = column (0-31)
          ;; TODO: ldy temp2          ; Y = row (0-7)

          ;; TODO: ; Calculate byte offset: (column / 8) + (row * 2)
          ;; TODO: ; Column byte = X / 8 (3 right shifts)
          txa
          ; A = column
          lsr
          ; /2
          lsr
          ; /4
          lsr
          ; /8 (column byte offset)
          sta temp1
          ; Save column byte offset

          ;; TODO: ; Row byte offset = Y * 2 (1 left shift)
          tya
          ; A = row
          asl
          ; *2 (row byte offset)
          clc
          adc temp1
          ; Add column and row offsets
          tay
          ; Y = final byte offset in playfield

          ; X = bit position within byte (column mod 8)
          txa
          ; A = original column
          and # 7
          ; Mask to get bit position (0-7)
          tax
          ; X = bit position for BitMask lookup

          ; Read playfield pixel
          lda BitMask,x     ; Get bit mask for this bit position
          and playfield,y  ; and with playfield byte
          eor BitMask,x     ; XOR to check if bit was set
          beq ReadZero       ; If zero, bit was clear
          lda #$80
          ; bit was set
ReadZero
          sta temp1
          ; Store result
          jsr BS_return

          bit mask lookup table for playfield column bits
          ;; TODO: ifndef BitMask
          ;; TODO: BitMask       BYTE 1,2,4,8,$10,$20,$40,$80



.pend

