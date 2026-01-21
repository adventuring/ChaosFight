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

          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedLeft-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedLeft hi (encoded)]
          lda # <(AfterSetPlayerLockedLeft-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedLeft hi (encoded)] [SP+0: AfterSetPlayerLockedLeft lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedLeft hi (encoded)] [SP+1: AfterSetPlayerLockedLeft lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedLeft hi (encoded)] [SP+2: AfterSetPlayerLockedLeft lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
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

          ;; Cross-bank call to SetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSetPlayerLockedRight-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerLockedRight hi (encoded)]
          lda # <(AfterSetPlayerLockedRight-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerLockedRight hi (encoded)] [SP+0: AfterSetPlayerLockedRight lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerLockedRight hi (encoded)] [SP+1: AfterSetPlayerLockedRight lo] [SP+0: SetPlayerLocked hi (raw)]
          lda # <(SetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerLockedRight hi (encoded)] [SP+2: AfterSetPlayerLockedRight lo] [SP+1: SetPlayerLocked hi (raw)] [SP+0: SetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerLockedRight:


          rts

.pend

