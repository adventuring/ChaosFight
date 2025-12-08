;;; ChaosFight - Source/Routines/MovementApplyGravity.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


MovementApplyGravity .proc
;;; Apply gravity to player velocity (integer component only).
          ;; Input: temp1 = player index (0-3), temp2 = gravity strength (integer, positive downward)
          ;; Output: playerVelocityY[] incremented by gravity strength
          ;; Mutates: playerVelocityY[]
          ;; Constraints: For subpixel gravity, call AddVelocitySubpixelY separately
                    ;; let playerVelocityY[temp1] = playerVelocityY[temp1]
          lda temp1
          asl
          tax
          ;; lda playerVelocityY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          sta playerVelocityY,x + temp2
          rts

.pend

