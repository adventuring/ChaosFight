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
          lda temp2
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          lda temp1
          asl
          tax
          lda temp3
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x
          rts

.pend

