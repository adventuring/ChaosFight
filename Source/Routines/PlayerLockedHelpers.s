;;; ChaosFight - Source/Routines/PlayerLockedHelpers.bas

;;; Copyright © 2025 Bruce-Robert Pocock.




GetPlayerLocked .proc
          ;; Player Locked Helper Functions
          ;; Returns: Far (return otherbank)

          ;; Helper functions to access bit-packed playerLocked

          ;; variable

          ;; playerLocked is a single byte with 2 bits per player:

          ;; Bits 0-1: Player 0 (0=unlocked, 1=normal, 2=handicap)

          ;;
          ;; Bits 2-3: Player 1

          ;; Bits 4-5: Player 2

          ;; Bits 6-7: Player 3

          ;; Get Player Locked State

          ;; Input: temp1 = player index (0-3), playerLocked (bit-packed)

          ;; Output: temp2 = locked state (0=unlocked, 1=normal, 2=handicap)
          ;; GPL_lockedState = same as temp2

          ;; Mutates: temp2, GPL_lockedState

          ;;
          ;; Called Routines: None

          ;; Constraints: None

          ;; Invalid index check (temp1 should be 0-3)

          ;; If temp1 < 0, set temp2 = 0 return

          jmp BS_return

          ;; Extract 2 bits for this player

          ;; Optimized: Use on...jmp jump table for O(1) dispatch

          ;; Use division and masking operations compatible with batariBASIC

          jmp GetPlayerLockedP0

.pend

GetPlayerLockedP0 .proc
          ;; Set temp2 = playerLocked & 3
          lda playerLocked
          and # 3
          sta temp2
          sta GPL_lockedState

          rts

.pend

GetPlayerLockedP1 .proc
          ;; Set temp2 = (playerLocked / 4) & 3
          lda playerLocked
          lsr
          lsr
          and # 3
          sta temp2
          sta GPL_lockedState

          rts

.pend

GetPlayerLockedP2 .proc
          ;; Set temp2 = (playerLocked / 16) & 3
          lda playerLocked
          lsr
          lsr
          lsr
          lsr
          and # 3
          sta temp2
          sta GPL_lockedState

          rts

.pend

GetPlayerLockedP3 .proc
          ;; Set temp2 = (playerLocked / 64) & 3
          lda playerLocked
          lsr
          lsr
          lsr
          lsr
          lsr
          lsr
          and # 3
          sta temp2
          sta GPL_lockedState

          rts

.pend

SetPlayerLocked .proc


          ;;
          ;; Returns: Far (return otherbank)

          ;; Set Player Locked State

          ;; Sets the locked state for a specific player

          ;;
          ;; Input: currentPlayer (global) = player index (0-3)

          ;; temp1 (fallback) = player index (0-3) when

          ;; currentPlayer is out of range

          ;; temp2 = locked state (0=unlocked, 1=normal,

          ;; 2=handicap)

          ;; Output: playerLocked (global) updated with new state for

          ;; specified player

          ;; Mutates: playerLocked (global), currentPlayer (global)

          ;; Called Routines: None

          ;; Constraints: currentPlayer preferred; temp1 retained for

          ;; legacy callers



          ;; Determine player index from currentPlayer when valid

          ;; if temp3 > 3 then jmp SetPlayerLockedUseTemp
          lda currentPlayer
          sta temp3

          jmp SetPlayerLockedApply



.pend

SetPlayerLockedUseTemp .proc
          ;; If temp3 > 3, then return otherbank
          lda temp3
          cmp # 4
          bcc SetPlayerLockedUseTempContinue
          jmp BS_return
SetPlayerLockedUseTempContinue:
          ;; Returns: Far (return otherbank)

          lda temp1
          sta temp3



.pend

SetPlayerLockedApply .proc
          ;; Returns: Far (return otherbank)

          lda temp3
          sta currentPlayer



          ;; Clear the 2 bits for this player and set the new value
          ;; Returns: Far (return otherbank)

          jmp BS_return

          jmp BS_return

          jmp BS_return

          jmp BS_return



          jmp BS_return



.pend

