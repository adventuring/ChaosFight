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
          bne skip_3745
          jmp HGI_CheckGuardRelease
skip_3745:


.pend

HGI_HandleDownPressed .proc
          ;; DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          ;; Returns: Far (return otherbank)
                    ;; let temp4 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          sta temp4
          jsr BS_return
          ;; lda temp4 (duplicate)
          cmp # 2
          ;; bne skip_5422 (duplicate)
          ;; jmp DragonOfStormsDown (duplicate)
skip_5422:

          ;; lda temp4 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bne skip_3530 (duplicate)
          ;; jmp HarpyDown (duplicate)
skip_3530:

          ;; lda temp4 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bne skip_9973 (duplicate)
          ;; jmp FrootyDown (duplicate)
skip_9973:

          ;; lda temp4 (duplicate)
          ;; cmp # 13 (duplicate)
          ;; bne skip_2334 (duplicate)
          ;; jmp DCD_HandleRoboTitoDown_HGI (duplicate)
skip_2334:

          ;; Tail call: goto instead of gosub to save 2 bytes on sta

          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          ;; jmp StandardGuard (duplicate)

.pend

DCD_HandleRoboTitoDown_HGI .proc
          ;; Tail call optimization: goto instead of gosub to save 2 bytes on sta

          ;; Note: RoboTitoDown may return early, so we need to handle that case
          ;; Cross-bank call to RoboTitoDown in bank 13
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RoboTitoDown-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 12
          ;; jmp BS_jsr (duplicate)
return_point:

          ;; jsr BS_return (duplicate)
          ;; Same-bank call (both in Bank 12) - saves 2 bytes vs cross-bank
          ;; jmp StandardGuard (duplicate)

.pend

HGI_CheckGuardRelease .proc
          ;; DOWN released - check for early guard release
          ;; Returns: Far (return otherbank)
                    ;; let temp2 = playerState[temp1] & 2         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; Not guarding, nothing to do
          ;; jsr BS_return (duplicate)
          ;; Stop guard early and start cooldown
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          ;; Start cooldown timer
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda GuardTimerMaxFrames (duplicate)
          ;; sta playerTimers_W,x (duplicate)
          ;; jsr BS_return (duplicate)

.pend

