;;; ChaosFight - Source/Routines/AddVelocitySubpixelY.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


AddVelocitySubpixelY .proc
          ;; Add fractional gravity to Y velocity (subpixel component).
          ;; Input: temp1 = player index (0-3), temp2 = subpixel amount (0-255)
          ;; Output: playerVelocityYL[] incremented; playerVelocityY[] increments on carry
          ;; Mutates: temp2-temp4, playerVelocityY[], playerVelocityYL[]
          ;; Constraints: Uses 16-bit accumulator; carry promotes to integer component
          ;; Save subpixel amount before using temp2 for accumulator
          ;; 16-bit accumulator for proper carry detection
          lda temp2
          sta temp4
          ;; Use saved amount in accumulator
          ;; Set subpixelAccumulator = playerVelocityYL[temp1] + temp4
          lda temp1
          asl
          tax
          lda playerVelocityYL,x
          clc
          adc temp4
          sta subpixelAccumulator
          ;; No carry: temp3 = 0, use low byte directly
          lda temp3
          cmp # 1
          bcc NoCarryToInteger
          ;; Carry occurred - increment integer component
          lda temp1
          asl
          tax
          lda playerVelocityY,x
          clc
          adc # 1
          sta playerVelocityY,x
NoCarryToInteger:

          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityYL,x
          rts

.pend

VelocityYCarry .proc
          ;; Helper: Handles carry from subpixel to integer part
          ;;
          ;; Input: temp2 = wrapped low byte, temp1 = player
          ;; index, playerVelocityY[] (global array) = Y velocities
          ;;
          ;; Output: Subpixel part set, integer part incremented
          ;;
          ;; Mutates: playerVelocityYL[] (global array) = Y velocity
          ;; subpixel (set), playerVelocityY[] (global array) = Y
          ;; velocity integer (incremented)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Internal helper for AddVelocitySubpixelY,
          ;; only called when carry detected
          ;; Carry detected: temp3 > 0, extract wrapped low byte
          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityYL,x
          ;; Set playerVelocityY[temp1] = playerVelocityY[temp1] + 1
          lda temp1
          asl
          tax
          inc playerVelocityY,x
          rts

.pend

