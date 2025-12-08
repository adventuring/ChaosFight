;;; ChaosFight - Source/Routines/SetPlayerVelocity.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


SetPlayerVelocity .proc
;;; Set player velocity (integer component, reset subpixels).
          ;; Input: temp1 = player index (0-3), temp2 = X velocity, temp3 = Y velocity
          ;; Output: playerVelocityX/Y updated (low bytes cleared)
          ;; Mutates: playerVelocityX[], playerVelocityXL[], playerVelocityY[], playerVelocityYL[]
          ;; Constraints: None
          lda temp1
          asl
          tax
          ;; lda temp2 (duplicate)
          sta playerVelocityX,x
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
          rts

.pend

