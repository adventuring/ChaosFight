;;; ChaosFight - Source/Routines/CountRemainingPlayers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CountRemainingPlayers:
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
          ;; If playerHealth[0] > 0, increment temp1
          lda # 0
          asl
          tax
          lda playerHealth,x
          beq SkipIncrementPlayer0
          lda temp1
          clc
          adc # 1
          sta temp1
SkipIncrementPlayer0:
          ;; If playerHealth[1] > 0, increment temp1
          lda # 1
          asl
          tax
          lda playerHealth,x
          beq SkipIncrementPlayer1

          lda temp1
          clc
          adc # 1
          sta temp1

SkipIncrementPlayer1:

          ;; If playerHealth[2] > 0, increment temp1
          lda # 2
          asl
          tax
          lda playerHealth,x
          beq SkipIncrementPlayer2

          lda temp1
          clc
          adc # 1
          sta temp1

SkipIncrementPlayer2:

          ;; If playerHealth[3] > 0, increment temp1
          lda # 3
          asl
          tax
          lda playerHealth,x
          beq SkipIncrementPlayer3

          lda temp1
          clc
          adc # 1
          sta temp1

SkipIncrementPlayer3:

          lda temp1
          sta playersRemaining_W
          jmp BS_return



