;;; ChaosFight - Source/Routines/SetPlayerPosition.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

SetPlayerPosition
;;; Set player position (integer coordinates, subpixels cleared).
          ;; Input: temp1 = player index (0-3), temp2 = X position, temp3 = Y position
          ;; Output: playerX/Y and subpixel buffers updated
          ;; Mutates: playerX[], playerY[], playerSubpixelX_W/WL[], playerSubpixelY_W/WL[]
          ;; Constraints: None
          lda temp1
          asl
          tax
          ;; lda temp2 (duplicate)
          sta playerX,x
          ;; SCRAM write to playerSubpixelX_W
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerSubpixelX_W,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelX_WL,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; SCRAM write to playerSubpixelY_W
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta playerSubpixelY_W,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelY_WL,x (duplicate)
          rts


