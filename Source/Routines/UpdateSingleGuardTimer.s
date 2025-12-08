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
          ;; bit cleared when expired,
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
                    ;; let temp2 = playerState[temp1] & 2         
          lda temp1
          asl
          tax
          ;; lda playerState,x (duplicate)
          sta temp2
          ;; if temp2 then UpdateGuardTimerActive
          ;; lda temp2 (duplicate)
          beq skip_2709
          jmp UpdateGuardTimerActive
skip_2709:
          

          ;; Player not guarding - decrement cooldown timer
          ;; Fix RMW: Read from _R, modify, write to _W
                    ;; let temp3 = playerTimers_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerTimers_R,x (duplicate)
          ;; sta temp3 (duplicate)
          jsr BS_return
          ;; No cooldown active
          dec temp3
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta playerTimers_W,x (duplicate)
          ;; jsr BS_return (duplicate)

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
                    ;; let temp3 = playerTimers_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerTimers_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; Guard timer already expired (shouldn’t happen, but safety
          ;; lda temp3 (duplicate)
          cmp # 0
          bne skip_3844
          ;; TODO: GuardTimerExpired
skip_3844:

          ;; check)

          ;; Decrement guard duration timer
          ;; dec temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta playerTimers_W,x (duplicate)
          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3844 (duplicate)
          ;; TODO: GuardTimerExpired
;; skip_3844: (duplicate)

          ;; jsr BS_return (duplicate)
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
                    ;; let playerState[temp1] = playerState[temp1] & MaskClearGuard
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda GuardTimerMaxFrames (duplicate)
          ;; sta playerTimers_W,x (duplicate)
          ;; jsr BS_return (duplicate)

.pend

