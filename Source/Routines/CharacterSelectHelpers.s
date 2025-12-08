;;; ChaosFight - Source/Routines/CharacterSelectHelpers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


SelectStickLeft .proc
;;; Handle stick-left navigation for the active player
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerCharacter[] (global) = browsing selections
          ;; Output: playerCharacter[currentPlayer] decremented with wrap
          ;; to MaxCharacter, lock state cleared on wrap
          ;; Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          ;; SetPlayerLocked)
          ;; Called Routines: SetPlayerLocked (bank6)
          ;; Constraints: currentPlayer must be set by caller
          ;; ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] - 1
          lda currentPlayer
          asl
          tax
          dec playerCharacter,x

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerCharacter,x (duplicate)

                    ;; if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = MaxCharacter

          ;; Cross-bank call to SetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 5
          jmp BS_jsr
return_point:


          rts

.pend

SelectStickRight .proc
          ;; Handle stick-right navigation for the active player
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerCharacter[] (global) = browsing selections
          ;; Output: playerCharacter[currentPlayer] incremented with wrap
          ;; to 0, lock state cleared on wrap
          ;; Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          ;; SetPlayerLocked)
          ;; Called Routines: SetPlayerLocked (bank6)
          ;; Constraints: currentPlayer must be set by caller
          ;; ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] + 1
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          inc playerCharacter,x

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerCharacter,x (duplicate)

                    ;; if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = 0

          ;; Cross-bank call to SetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; rts (duplicate)

.pend

