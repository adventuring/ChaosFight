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

          ;; Issue #1254: Loop through currentPlayer = 0 to 3
          lda # 0
          sta currentPlayer
FW_Loop:
          ;; Cross-bank call to IsPlayerEliminated in bank 13
          lda # >(AfterIsPlayerEliminated-1)
          pha
          lda # <(AfterIsPlayerEliminated-1)
          pha
          lda # >(IsPlayerEliminated-1)
          pha
          lda # <(IsPlayerEliminated-1)
          pha
          ldx # 12
          jmp BS_jsr

AfterIsPlayerEliminated:
          ;; Check if this player is not eliminated (temp2 = 0 means not eliminated)
          lda temp2
          bne FindWinnerNextPlayer
          ;; Player is not eliminated - set as winner
          lda currentPlayer
          sta winnerPlayerIndex_W

FindWinnerNextPlayer:
          ;; Issue #1254: Loop increment and check
          inc currentPlayer
          lda currentPlayer
          cmp # 4
          bcs FW_LoopDone
          jmp FW_Loop
FW_LoopDone:

.pend

FindWinnerNoWinnerFound .proc

          ;; If no winner found (all eliminated), pick last eliminated
          lda winnerPlayerIndex_R
          cmp # 255
          bne FindWinnerDone

          jmp FindLastEliminated

FindWinnerDone:

          jmp BS_return

.pend

