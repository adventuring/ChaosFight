;;; ChaosFight - Source/Routines/HandleGuardInput.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HandleGuardInput .proc

          ;; Shared Guard Input Handling (inlined version)
          ;; Handles down/guard input for both ports
          ;; INPUT: temp1 = player index (0-3)
          ;; Uses: joy0down for players 0,2; joy1down for players 1,3
          ;; Determine which joy port to use based on player index
          ;; Frooty (8) cannot guard
          ;; Players 0,2 use joy0; Players 1,3 use joy1

.pend

CheckJoy0GuardInput .proc
          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)
          lda joy0down
          bne HandleDownPressed

          jmp CheckGuardReleaseGuardInput

HandleDownPressed:

.pend

HandleDownPressedGuardInput .proc
          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)
          ;; Set temp4 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4
          jmp BS_return

          lda temp4
          cmp # 2
          bne CheckHarpy

          jmp DragonOfStormsDown

CheckHarpy:

          lda temp4
          cmp # 6
          bne CheckFrooty

          jmp HarpyDown

CheckFrooty:

          lda temp4
          cmp # 8
          bne CheckRoboTito

          jmp FrootyDown

CheckRoboTito:

          lda temp4
          cmp # 13
          bne UseStandardGuard

          jmp HandleRoboTitoDownGuardInput

UseStandardGuard:

          ;; Tail call: jmp instead of cross-bank call to to save 2 bytes on sta

          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          jmp StandardGuard

.pend

HandleRoboTitoDownGuardInput .proc
          ;; Tail call optimization: jmp instead of cross-bank call to to save 2 bytes on sta

          ;; Note: RoboTitoDown may return early, so we need to handle that case
          ;; Cross-bank call to RoboTitoDown in bank 13
          lda # >(AfterRoboTitoDownGuard-1)
          pha
          lda # <(AfterRoboTitoDownGuard-1)
          pha
          lda # >(RoboTitoDown-1)
          pha
          lda # <(RoboTitoDown-1)
          pha
          ldx # 12
          jmp BS_jsr

AfterRoboTitoDownGuard:

          jmp BS_return

          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          jmp StandardGuard

.pend

CheckGuardReleaseGuardInput .proc
          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)
          ;; Set temp2 = playerState[temp1] & 2
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; Not guarding, nothing to do
          jmp BS_return

          ;; Stop guard early and start cooldown
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          ;; Start cooldown timer
          lda temp1
          asl
          tax
          lda # GuardTimerMaxFrames
          sta playerTimers_W,x
          jmp BS_return

.pend

