;;; ChaosFight - Source/Routines/IsPlayerEliminated.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


IsPlayerEliminated:
.proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Is Player Eliminated
          ;; Input: currentPlayer (0-3), playerHealth[]
          ;; Output: temp2 = 1 if eliminated, 0 if alive
          ;; Mutates: temp2
          ;; let temp2 = playerHealth[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          sta temp2
          lda temp2
          cmp # 0
          bne skip_9901

          ;; let temp2 = 1 : goto IsEliminatedDone

skip_9901:

          lda # 0
          sta temp2

IsEliminatedDone:
          jsr BS_return

.pend

