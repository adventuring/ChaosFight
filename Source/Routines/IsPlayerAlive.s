;;; ChaosFight - Source/Routines/IsPlayerAlive.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


IsPlayerAlive:
.proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Is Player Alive
          ;; Check if specified player is alive (health > 0).
          ;;
          ;; FIXME: #1252 Inline and remove calls to this routine.
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerHealth[] (global array) = player health values
          ;;
          ;; Output: temp2 = player health value (0 if dead, >0 if alive)
          ;; Caller should check if temp2 = 0 for dead, temp2 > 0 for alive
          ;;
          ;; Mutates: temp2 (set to health value)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;; let temp2 = playerHealth[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          sta temp2
          jsr BS_return

.pend

