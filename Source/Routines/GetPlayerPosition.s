;;; ChaosFight - Source/Routines/GetPlayerPosition.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

GetPlayerPosition:
          ;; Get player position (integer components only).
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; Output: temp2 = X position, temp3 = Y position
          ;; Mutates: temp2, temp3
          ;; Constraints: Callers should consume the values immediately; temps are volatile.
          ;; let temp2 = playerX[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerX,x
          sta temp2
          ;; let temp3 = playerY[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp3
         
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp3
          rts


