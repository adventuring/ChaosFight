;;; ChaosFight - Source/Routines/UpdateGuardTimers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateGuardTimers .proc
          ;; Returns: Far (return otherbank)
          ;; Update guard duration and cooldown timers each frame (invoked from main loop).
          ;; Input: None
          ;; Output: Guard timers refreshed for all players
          ;; Mutates: temp1 (0-3), playerTimers_W[] (decremented), playerState[] (guard bit cleared)
          ;; Called Routines: UpdateSingleGuardTimer - updates guard
          ;; timer for one player
          ;; Constraints: Tail call to UpdateSingleGuardTimer for
          ;; player 3
          ;; Issue #1254: Loop through temp1 = 0 to 3
          lda # 0
          sta temp1
UGT_Loop:
          ;; Cross-bank call to UpdateSingleGuardTimer in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(UpdateGuardTimersReturn-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: UpdateGuardTimersReturn hi (encoded)]
          lda # <(UpdateGuardTimersReturn-1)
          pha
          ;; STACK PICTURE: [SP+1: UpdateGuardTimersReturn hi (encoded)] [SP+0: UpdateGuardTimersReturn lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdateSingleGuardTimer-1)
          pha
          ;; STACK PICTURE: [SP+2: UpdateGuardTimersReturn hi (encoded)] [SP+1: UpdateGuardTimersReturn lo] [SP+0: UpdateSingleGuardTimer hi (raw)]
          lda # <(UpdateSingleGuardTimer-1)
          pha
          ;; STACK PICTURE: [SP+3: UpdateGuardTimersReturn hi (encoded)] [SP+2: UpdateGuardTimersReturn lo] [SP+1: UpdateSingleGuardTimer hi (raw)] [SP+0: UpdateSingleGuardTimer lo]
          ldx # 5
          jmp BS_jsr

UpdateGuardTimersReturn:
          ;; Issue #1254: Loop increment and check
          inc temp1
          lda temp1
          cmp # 4
          bcs UGT_LoopDone
          jmp UGT_Loop
UGT_LoopDone:

.pend

UpdateGuardTimersDone .proc
          jmp BS_return

.pend

