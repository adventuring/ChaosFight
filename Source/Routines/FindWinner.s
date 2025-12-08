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
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(IsPlayerEliminated-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(IsPlayerEliminated-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 12
          jmp BS_jsr
return_point:

          ;; lda temp2 (duplicate)
          bne skip_610
          ;; lda currentPlayer (duplicate)
          ;; sta winnerPlayerIndex_W (duplicate)
skip_610:

.pend

FW_next_label_1:.proc

          ;; If no winner found (all eliminated), pick last eliminated
          ;; lda winnerPlayerIndex_R (duplicate)
          cmp # 255
          ;; bne skip_6101 (duplicate)
          ;; jmp FindLastEliminated (duplicate)
skip_6101:

          ;; tail call
          ;; lda winnerPlayerIndex_R (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_6101 (duplicate)
          ;; jmp FindLastEliminated (duplicate)
;; skip_6101: (duplicate)

          jsr BS_return


.pend

