;;; ChaosFight - Source/Routines/CharacterSelectHelpers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


SelectStickLeft .proc
          ;; Handle stick-left navigation for the active player
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerCharacter[] (global) = browsing selections
          ;; Output: playerCharacter[currentPlayer] decremented with wrap
          ;; to MaxCharacter, lock state cleared on wrap
          ;; Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          ;; SetPlayerLocked)
          ;; Called Routines: SetPlayerLocked (bank6)
          ;; Constraints: currentPlayer must be set by caller
          ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] - 1
          lda currentPlayer
          asl
          tax
          dec playerCharacter,x

          ;; If playerCharacter[currentPlayer] > MaxCharacter, then set playerCharacter[currentPlayer] = MaxCharacter
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          cmp # MaxCharacter
          bcc CheckMaxCharacterDoneLeft
          lda # MaxCharacter
          sta playerCharacter,x
CheckMaxCharacterDoneLeft:

          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(AfterSetPlayerLockedLeft-1)
          pha
          lda # <(AfterSetPlayerLockedLeft-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
          ldx # 5
          jmp BS_jsr

AfterSetPlayerLockedLeft:

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
          ;; let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] + 1
          lda currentPlayer
          asl
          tax
          inc playerCharacter,x

          ;; If playerCharacter[currentPlayer] > MaxCharacter, then set playerCharacter[currentPlayer] = 0
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          cmp # MaxCharacter
          bcc CheckMaxCharacterDoneRight
          lda # 0
          sta playerCharacter,x
CheckMaxCharacterDoneRight:

          ;; Cross-bank call to SetPlayerLocked in bank 6
          lda # >(AfterSetPlayerLockedRight-1)
          pha
          lda # <(AfterSetPlayerLockedRight-1)
          pha
          lda # >(SetPlayerLocked-1)
          pha
          lda # <(SetPlayerLocked-1)
          pha
          ldx # 5
          jmp BS_jsr

AfterSetPlayerLockedRight:

          rts

.pend

