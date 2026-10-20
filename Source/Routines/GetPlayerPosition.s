;;; ChaosFight - Source/Routines/GetPlayerPosition.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

GetPlayerPosition:
          ;; Get player position (integer components only).
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; Output: temp2 = X position, temp3 = Y position
          ;; Mutates: temp2, temp3
          ;; Constraints: Callers should consume the values immediately; temps are volatile.
          ;; Set temp2 = playerX[currentPlayer]
          lda currentPlayer
          tax
          lda playerX,x
          sta temp2
          ;; Set temp3 = playerY[currentPlayer]
          lda currentPlayer
          tax
          lda playerY,x
          sta temp3
         
          lda currentPlayer
          tax
          lda playerY,x
          sta temp3
          rts


