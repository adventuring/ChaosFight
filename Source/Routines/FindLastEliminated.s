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
          ;; lda # 0 (duplicate)
          ;; sta winnerPlayerIndex_W (duplicate)
          ;; Default winner

          ;; Check each player elimination order using FOR loop
          ;; TODO: for currentPlayer = 0 to 3
                    ;; let temp4 = eliminationOrder_R[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          asl
          tax
          ;; lda eliminationOrder_R,x (duplicate)
          ;; sta temp4 (duplicate)
                    ;; if temp4 > temp4 then let winnerPlayerIndex_W = currentPlayer
          ;; lda temp4 (duplicate)
          sec
          sbc temp4
          bcc skip_5738
          beq skip_5738
          ;; lda currentPlayer (duplicate)
          ;; sta winnerPlayerIndex_W (duplicate)
skip_5738:
.pend

FLE_next_label_1:.proc


.pend

