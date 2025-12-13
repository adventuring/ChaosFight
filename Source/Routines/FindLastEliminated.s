;;; ChaosFight - Source/Routines/FindLastEliminated.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


FindLastEliminated .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Find player eliminated most recently (highest elimination order).
          ;; Input: currentPlayer loop variable, eliminationOrder[]
          ;; Output: winnerPlayerIndex updated to last eliminated player
          ;; Mutates: temp4, currentPlayer, winnerPlayerIndex
          lda # 0
          sta temp4
          ;; Highest elimination order found
          lda # 0
          sta winnerPlayerIndex_W
          ;; Default winner

          ;; Check each player elimination order using FOR loop
          ;; Issue #1254: Loop through currentPlayer = 3 downto 0
          ;; temp4 stores the highest elimination order found so far
          lda # 3
          sta currentPlayer
FLE_Loop:
          ;; Load current player's elimination order
          lda currentPlayer
          asl
          tax
          lda eliminationOrder_R,x
          ;; Compare to highest found so far (temp4)
          sec
          sbc temp4
          bcc SkipUpdateWinner
          ;; Current player has higher (or equal) elimination order - update winner
          lda currentPlayer
          asl
          tax
          lda eliminationOrder_R,x
          sta temp4
          lda currentPlayer
          sta winnerPlayerIndex_W

SkipUpdateWinner:
          ;; Issue #1254: Loop decrement and check (count down from 3 to 0)
          dec currentPlayer
          bpl FLE_Loop

          jmp BS_return

.pend

