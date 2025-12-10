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
          ;; TODO: for temp1 = 0 to 3
                    let temp2 = playerAttackCooldown_R[temp1]         
          lda temp1
          asl
          tax
          lda playerAttackCooldown_R,x
          sta temp2
          lda temp2
          cmp # 0
          bne skip_2323
          ;; TODO: UpdateAttackCooldownSkip
skip_2323:

          dec temp2
          lda temp1
          asl
          tax
          lda temp2
          sta playerAttackCooldown_W,x
.pend

UpdateAttackCooldownSkip .proc
.pend

next_label_1_L39:.proc
          jsr BS_return

.pend

