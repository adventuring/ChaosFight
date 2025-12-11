;;; ChaosFight - Source/Routines/ApplyFriction.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

ApplyFriction
;;; Apply friction to player X velocity (simple decrement/increment).
          ;; Input: temp1 = player index (0-3), playerVelocityX[], playerVelocityXL[]
          ;; Output: X velocity reduced by 1 toward zero; subpixel cleared when velocity hits zero
          ;; Mutates: playerVelocityX[], playerVelocityXL[]
          ;;
          ;; Constraints: Simple decrement approach for 8-bit CPU.
          ;; Positive velocities (>0 and not negative) decremented,
          ;; negative velocities (≥128 in two’s complement) incremented
          ;; Check for negative velocity using twos complement (values
          ;; if playerVelocityX[temp1] > 0 then let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          beq CheckNegativeVelocity
          dec playerVelocityX,x
CheckNegativeVelocity:

          lda temp1
          asl
          tax
          lda playerVelocityX,x
          beq CheckNegativeVelocityLabel
          dec playerVelocityX,x
CheckNegativeVelocityLabel:


          ;; ≥ 128 are negative)
          ;; Also zero subpixel if velocity reaches zero
          ;; if playerVelocityX[temp1] & $80 then let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          and #$80
          beq ClearSubpixel

          inc playerVelocityX,x

ClearSubpixel:

          ;; If playerVelocityX[temp1] = 0, then set playerVelocityXL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          bne ApplyFrictionDone

          lda # 0
          sta playerVelocityXL,x

ApplyFrictionDone:
          rts


