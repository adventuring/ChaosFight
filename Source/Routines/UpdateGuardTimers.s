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
          ;; Optimized: Loop through all players instead of individual calls
          ;; TODO: for temp1 = 0 to 3
          ;; Cross-bank call to UpdateSingleGuardTimer in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdateSingleGuardTimer-1)
          pha
          lda # <(UpdateSingleGuardTimer-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:

.pend

next_label_1:.proc
          jsr BS_return

.pend

