;;; ChaosFight - Source/Routines/UpdateAttackCooldowns.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdateAttackCooldowns .proc
          ;; Returns: Far (return otherbank)
          ;; Update attack cooldown timers each frame (invoked from main loop).
          ;; Decrements playerAttackCooldown_W[0-3] timers if > 0.
          ;; Input: None
          ;; Output: Attack cooldown timers decremented for all players
          ;; Mutates: temp1 (0-3), playerAttackCooldown_W[] (decremented if > 0)
          ;; Called Routines: None
          ;; Constraints: Must be in same bank as GameLoopMain (Bank 11)
          ;; Optimized: Loop through all players instead of individual calls
          ;; Issue #1254: Loop through temp1 = 0 to 3
          lda # 0
          sta temp1
UAC_Loop:
          ;; Set temp2 = playerAttackCooldown_R[temp1]
          lda temp1
          asl
          tax
          lda playerAttackCooldown_R,x
          sta temp2
          lda temp2
          cmp # 0
          bne DecrementCooldown

          jmp UpdateAttackCooldownSkip

DecrementCooldown:

          dec temp2
          lda temp1
          asl
          tax
          lda temp2
          sta playerAttackCooldown_W,x

UpdateAttackCooldownSkip:
          ;; Issue #1254: Loop increment and check
          inc temp1
          lda temp1
          cmp # 4
          bcs UAC_LoopDone
          jmp UAC_Loop
UAC_LoopDone:

          jmp BS_return

.pend

