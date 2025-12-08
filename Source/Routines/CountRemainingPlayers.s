;;; ChaosFight - Source/Routines/CountRemainingPlayers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CountRemainingPlayers
;;; Returns: Far (return otherbank)
;; CountRemainingPlayers (duplicate)
          ;;
          ;; Returns: Far (return otherbank)
          ;; Count Remaining Players
          ;; Input: playerHealth[] (global array)
          ;; Output: playersRemaining (global) and temp1 updated with alive player count
          ;; Mutates: temp1, playersRemaining
          ;; Counter
          lda # 0
          sta temp1

          ;; Check each player
                    ;; if playerHealth[0] > 0 then let temp1 = 1
                    ;; if playerHealth[1] > 0 then let temp1 = 1 + temp1
          ;; lda # 1 (duplicate)
          asl
          tax
          ;; lda playerHealth,x (duplicate)
          beq skip_7125
          ;; lda temp1 (duplicate)
          clc
          adc # 1
          ;; sta temp1 (duplicate)
skip_7125:
                    ;; if playerHealth[2] > 0 then let temp1 = 1 + temp1
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; beq skip_774 (duplicate)
          ;; lda temp1 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp1 (duplicate)
skip_774:
                    ;; if playerHealth[3] > 0 then let temp1 = 1 + temp1
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; beq skip_3562 (duplicate)
          ;; lda temp1 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp1 (duplicate)
skip_3562:
          ;; lda temp1 (duplicate)
          ;; sta playersRemaining_W (duplicate)
          jsr BS_return



