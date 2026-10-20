;;; ChaosFight - Source/Routines/MovementApplyGravity.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


MovementApplyGravity .proc
          ;; Apply gravity to player velocity (integer component only).
          ;; Input: temp1 = player index (0-3), temp2 = gravity strength (integer, positive downward)
          ;; Output: playerVelocityY[] incremented by gravity strength
          ;; Mutates: playerVelocityY[]
          ;; Constraints: For subpixel gravity, call AddVelocitySubpixelY separately
          ;; Set playerVelocityY[temp1] = playerVelocityY[temp1] + temp2
          lda temp1
          tax
          lda playerVelocityY,x
          clc
          adc temp2
          sta playerVelocityY,x
          rts

.pend

