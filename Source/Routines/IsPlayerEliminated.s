;;; ChaosFight - Source/Routines/IsPlayerEliminated.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


IsPlayerEliminated .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Is Player Eliminated
          ;; Input: currentPlayer (0-3), playerHealth[]
          ;; Output: temp2 = 1 if eliminated, 0 if alive
          ;; Mutates: temp2
          ;; Set temp2 = playerHealth[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          sta temp2
          bne PlayerNotEliminated

          ;; Set temp2 = 1 jmp IsEliminatedDone
          lda # 1
          sta temp2
          jmp IsEliminatedDone

PlayerNotEliminated:

          lda # 0
          sta temp2

IsEliminatedDone:
          jmp BS_return

.pend

