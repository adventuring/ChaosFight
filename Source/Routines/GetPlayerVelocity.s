;;; ChaosFight - Source/Routines/GetPlayerVelocity.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


GetPlayerVelocity:
.proc
          ;; Get player velocity (integer components only).
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerVelocityX[], playerVelocityY[] (global arrays)
          ;; Output: temp2 = X velocity, temp3 = Y velocity
          ;; Mutates: temp2, temp3
          ;; Constraints: Callers should use the values immediately; temps are volatile.
          ;; let temp2 = playerVelocityX[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerVelocityX,x
          sta temp2
          ;; let temp3 = playerVelocityY[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerVelocityY,x
          sta temp3

          lda currentPlayer
          asl
          tax
          lda playerVelocityY,x
          sta temp3
          rts

.pend

