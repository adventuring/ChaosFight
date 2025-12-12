;;; ChaosFight - Source/Routines/UpdateSingleGuardTimer.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateSingleGuardTimer .proc
          ;; Update guard timer or cooldown for a single player
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp1 = player index (0-3)
          ;; playerState[] (global array) = player state flags
          ;; (bit 1 = guarding)
          ;; playerTimers_R[] (global SCRAM array) = guard
          ;; duration or cooldown timer
          ;; GuardTimerMaxFrames (constant) = guard duration in
          ;; frames
          ;; MaskClearGuard (constant) = bitmask to clear guard
          ;; bit
          ;;
          ;; Output: playerTimers_W[] decremented, playerState[] guard
          bit cleared when expired,
          ;; cooldown started when guard expires
          ;;
          ;; Mutates: temp1-temp3 (used for calculations),
          ;; playerTimers_W[] (decremented),
          ;; playerState[] (guard bit cleared when expired)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with
          ;; UpdateGuardTimerActive, GuardTimerExpired (called via
          ;; goto)
          ;; Update guard timer or cooldown for a single player
          ;;
          ;; INPUT: temp1 = player index (0-3)
          ;; playerState = player state flags (bit 1 = guarding)
          ;; playerTimers = guard duration or cooldown timer
          ;;
          ;; OUTPUT: None
          ;;
          ;; EFFECTS: If guarding: decrements guard duration timer,
          ;; clears guard and starts cooldown when expired
          ;; If not guarding: decrements cooldown timer (if active)
          ;; Check if player is guarding
          ;; Set temp2 = playerState[temp1] & 2
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; If temp2, then UpdateGuardTimerActive
          beq UpdateCooldownTimer
          jmp UpdateGuardTimerActive

UpdateCooldownTimer:

          ;; Player not guarding - decrement cooldown timer
          ;; Fix RMW: Read from _R, modify, write to _W
          ;; Set temp3 = playerTimers_R[temp1]
          lda temp1
          asl
          tax
          lda playerTimers_R,x
          sta temp3
          beq NoCooldownActive

          dec temp3
          lda temp1
          asl
          tax
          lda temp3
          sta playerTimers_W,x

NoCooldownActive:
          jmp BS_return

.pend

UpdateGuardTimerActive .proc
          ;; Player is guarding - decrement guard duration timer
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: temp1 (from UpdateSingleGuardTimer),
          ;; playerTimers_R[] (global SCRAM array)
          ;;
          ;; Output: playerTimers_W[] decremented, dispatches to
          ;; GuardTimerExpired when timer reaches 0
          ;;
          ;; Mutates: temp3 (timer value), playerTimers_W[]
          ;; (decremented)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with UpdateSingleGuardTimer, GuardTimerExpired
          ;; Player is guarding - decrement guard duration timer
          ;; Set temp3 = playerTimers_R[temp1]
          lda temp1
          asl
          tax
          lda playerTimers_R,x
          sta temp3
          ;; Guard timer already expired (shouldn’t happen, but safety
          cmp # 0
          bne SkipExpiredCheck
          jmp GuardTimerExpired
SkipExpiredCheck:

          ;; check)

          ;; Decrement guard duration timer
          dec temp3
          lda temp1
          asl
          tax
          lda temp3
          sta playerTimers_W,x
          cmp # 0
          bne GuardTimerStillActive
          jmp GuardTimerExpired
GuardTimerStillActive:

          jmp BS_return
.pend

GuardTimerExpired .proc
          ;; Guard duration expired - clear guard bit and sta

          ;; Returns: Far (return otherbank)
          ;; cooldown
          ;;
          ;; Input: temp1 (from UpdateGuardTimerActive),
          ;; playerState[] (global array),
          ;; GuardTimerMaxFrames (consta

          ;;
          ;; Output: playerState[] guard bit cleared, playerTimers_W[]
          ;; set to cooldown duration
          ;;
          ;; Mutates: playerState[] (guard bit cleared),
          ;; playerTimers_W[] (set to GuardTimerMaxFrames)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with UpdateSingleGuardTimer, UpdateGuardTimerActive
          ;; Start cooldown timer (same duration as guard)
          ;; Set playerState[temp1] = playerState[temp1] & MaskClearGuard
          lda temp1
          asl
          tax
          lda playerState,x
          and # MaskClearGuard
          sta playerState,x
          lda GuardTimerMaxFrames
          sta playerTimers_W,x
          jmp BS_return

.pend

