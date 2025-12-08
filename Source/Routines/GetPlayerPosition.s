;;; ChaosFight - Source/Routines/GetPlayerPosition.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

GetPlayerPosition
;;; Get player position (integer components only).
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; Output: temp2 = X position, temp3 = Y position
          ;; Mutates: temp2, temp3
          ;; Constraints: Callers should consume the values immediately; temps are volatile.
                    ;; let temp2 = playerX[currentPlayer]
          lda currentPlayer
          asl
          tax
          ;; lda playerX,x (duplicate)
          sta temp2
                    ;; let temp3 = playerY[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
          rts


