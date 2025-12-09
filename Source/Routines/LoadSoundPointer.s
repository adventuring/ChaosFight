;;; ChaosFight - Source/Routines/LoadSoundPointer.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




LoadSoundPointer .proc




          ;; Lookup sound pointer from tables (Bank 15 sounds: 0-9)
          ;; Returns: Far (return otherbank)

          ;;
          ;; Input: temp1 = sound ID (0-9), SoundPointersL[],

          ;; SoundPointersH[] (global data tables) = sound pointer

          ;; tables

          ;;
          ;; Output: soundEffectPointer = pointer to Sound_Voice0 stream

          ;;
          ;; Mutates: temp1 (used for sound ID), soundEffectPointer (var41.var42)

          ;;
          ;; Called Routines: None

          ;;
          ;; Constraints: Only 10 sounds (0-9) available. Returns

          ;; soundEffectPointer = 0 if sound ID out of bounds

          ;; Bounds check: only 10 sounds (0-9)

          ;; Build 16-bit pointer: var41 = high byte, var42 = low byte

          lda temp1
          cmp # 10
          bcc skip_3853
skip_3853:


                    ;; let var41 = SoundPointersH[temp1]          lda temp1          asl          tax          lda SoundPointersH,x          sta var41

                    ;; let var42 = SoundPointersL[temp1]
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda SoundPointersL,x (duplicate)
          sta soundEffectPointerH         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SoundPointersL,x (duplicate)
          ;; sta var42 (duplicate)

          jmp LoadSoundPointerReturn

.pend

LoadSoundPointerOutOfRange .proc

          ;; Set pointer to 0 (var41.var42 = 0.0)
          ;; Returns: Far (return otherbank)

          ;; lda # 0 (duplicate)
          ;; sta var41 (duplicate)

          ;; Out of range - mark sound pointer inactive

          ;; lda # 0 (duplicate)
          ;; sta var42 (duplicate)

LoadSoundPointerReturn

          rts

.pend

