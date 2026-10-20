;;; ChaosFight - Source/Routines/SetPlayerPosition.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

SetPlayerPosition:
          ;; Set player position (integer coordinates, subpixels cleared).
          ;; Input: temp1 = player index (0-3), temp2 = X position, temp3 = Y position
          ;; Output: playerX/Y and subpixel buffers updated
          ;; Mutates: playerX[], playerY[], playerSubpixelX_W/WL[], playerSubpixelY_W/WL[]
          ;; Constraints: None
          lda temp1
          tax
          lda temp2
          sta playerX,x
          ;; SCRAM write to playerSubpixelX_W
          lda temp1
          tax
          lda temp2
          sta playerSubpixelX_W,x
          lda temp1
          tax
          lda # 0
          sta playerSubpixelX_WL,x
          lda temp1
          tax
          lda temp3
          sta playerY,x
          ;; SCRAM write to playerSubpixelY_W
          lda temp1
          tax
          lda temp3
          sta playerSubpixelY_W,x
          lda temp1
          tax
          lda # 0
          sta playerSubpixelY_WL,x
          rts


