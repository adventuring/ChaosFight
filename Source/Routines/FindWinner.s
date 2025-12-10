;;; ChaosFight - Source/Routines/FindWinner.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


FindWinner .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Find Winner
          ;; Identify the last standing player.
          ;; Input: currentPlayer (loop), playerHealth[], eliminationOrder[]
          ;; Output: winnerPlayerIndex (0-3, 255 if all eliminated)
          ;; Mutates: temp2, currentPlayer, winnerPlayerIndex
          ;; Calls: IsPlayerEliminated, FindLastEliminated (if needed)
          ;; Find the player who is not eliminated
          lda # 255
          sta winnerPlayerIndex_W
          ;; Invalid initially

          ;; Check each player using FOR loop
          ;; TODO: for currentPlayer = 0 to 3
          ;; Cross-bank call to IsPlayerEliminated in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(IsPlayerEliminated-1)
          pha
          lda # <(IsPlayerEliminated-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:

          lda temp2
          bne skip_610
          lda currentPlayer
          sta winnerPlayerIndex_W
skip_610:

.pend

FW_next_label_1:.proc

          If no winner found (all eliminated), pick last eliminated
          lda winnerPlayerIndex_R
          cmp # 255
          bne skip_6101
          jmp FindLastEliminated
skip_6101:

          ;; tail call
          lda winnerPlayerIndex_R
          cmp # 255
          bne skip_6101
          jmp FindLastEliminated
skip_6101:

          jsr BS_return


.pend

