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

HGI_CheckJoy0 .proc
          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)
          lda joy0down
          bne HandleDownPressed
          jmp HGI_CheckGuardRelease
HandleDownPressed:


.pend

HGI_HandleDownPressed .proc
          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)
          ;; let temp4 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4
          jsr BS_return
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
          jmp DCD_HandleRoboTitoDown_HGI
UseStandardGuard:

          ;; Tail call: goto instead of gosub to save 2 bytes on sta

          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          jmp StandardGuard

.pend

DCD_HandleRoboTitoDown_HGI .proc
          ;; Tail call optimization: goto instead of gosub to save 2 bytes on sta

          ;; Note: RoboTitoDown may return early, so we need to handle that case
          ;; Cross-bank call to RoboTitoDown in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RoboTitoDown-1)
          pha
          lda # <(RoboTitoDown-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:

          jsr BS_return
          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          jmp StandardGuard

.pend

HGI_CheckGuardRelease .proc
          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)
          ;; let temp2 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; Not guarding, nothing to do
          jsr BS_return
          ;; Stop guard early and start cooldown
                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          ;; Start cooldown timer
          lda temp1
          asl
          tax
          lda GuardTimerMaxFrames
          sta playerTimers_W,x
          jsr BS_return

.pend

