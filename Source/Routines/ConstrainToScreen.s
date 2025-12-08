;;; ChaosFight - Source/Routines/ConstrainToScreen.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

ConstrainToScreen
;;; Clamp player position to on-screen bounds and clear subpixels at edges.
          ;; Input: temp1 = player index (0-3)
          ;; Output: playerX/Y constrained to PlayerLeftEdge..PlayerRightEdge (X) and 20-80 (Y); subpixels zeroed at clamps
          ;; Mutates: playerX[], playerY[], playerSubpixelX_W/WL[], playerSubpixelY_W/WL[]
          ;; Constraints: × bounds PlayerLeftEdge..PlayerRightEdge,y bounds 20-80
          ;; Constrain X position using screen boundary consta

          ;; SCRAM write to playerSubpixelX_W
                    ;; if playerX[temp1] < PlayerLeftEdge then let playerX[temp1] = PlayerLeftEdge
          lda temp1
          asl
          tax
          ;; lda playerX,x (duplicate)
          cmp PlayerLeftEdge
          bcs skip_3749
          ;; lda PlayerLeftEdge (duplicate)
          sta playerX,x
skip_3749:
                    ;; if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_W[temp1] = PlayerLeftEdge
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; cmp PlayerLeftEdge (duplicate)
          ;; bcs skip_3303 (duplicate)
          ;; lda PlayerLeftEdge (duplicate)
          ;; sta playerSubpixelX_W,x (duplicate)
skip_3303:
                    ;; if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_WL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; cmp PlayerLeftEdge (duplicate)
          ;; bcs skip_4739 (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelX_WL,x (duplicate)
skip_4739:
                    ;; if playerX[temp1] > PlayerRightEdge then let playerX[temp1] = PlayerRightEdge
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          sec
          sbc PlayerRightEdge
          bcc skip_8156
          beq skip_8156
          ;; lda PlayerRightEdge (duplicate)
          ;; sta playerX,x (duplicate)
skip_8156:
                    ;; if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_W[temp1] = PlayerRightEdge
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc PlayerRightEdge (duplicate)
          ;; bcc skip_4401 (duplicate)
          ;; beq skip_4401 (duplicate)
          ;; lda PlayerRightEdge (duplicate)
          ;; sta playerSubpixelX_W,x (duplicate)
skip_4401:
                    ;; if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_WL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc PlayerRightEdge (duplicate)
          ;; bcc skip_7460 (duplicate)
          ;; beq skip_7460 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerSubpixelX_WL,x (duplicate)
skip_7460:

          ;; Constrain Y position (20 to 80 for screen bounds)
          ;; SCRAM write to playerSubpixelY_W
                    ;; if playerY[temp1] < 20 then let playerY[temp1] = 20
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; cmp 20 (duplicate)
          ;; bcs skip_9811 (duplicate)
          ;; lda 20 (duplicate)
          ;; sta playerY,x (duplicate)
skip_9811:
                    ;; if playerY[temp1] < 20 then let playerSubpixelY_W[temp1] = 20
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; cmp 20 (duplicate)
          ;; bcs skip_5142 (duplicate)
          ;; lda 20 (duplicate)
          ;; sta playerSubpixelY_W,x (duplicate)
skip_5142:
                    ;; if playerY[temp1] < 20 then let playerSubpixelY_WL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; cmp 20 (duplicate)
          ;; bcs skip_8164 (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelY_WL,x (duplicate)
skip_8164:
                    ;; if playerY[temp1] > 80 then let playerY[temp1] = 80
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 80 (duplicate)
          ;; bcc skip_7749 (duplicate)
          ;; beq skip_7749 (duplicate)
          ;; lda 80 (duplicate)
          ;; sta playerY,x (duplicate)
skip_7749:
                    ;; if playerY[temp1] > 80 then let playerSubpixelY_W[temp1] = 80
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 80 (duplicate)
          ;; bcc skip_7917 (duplicate)
          ;; beq skip_7917 (duplicate)
          ;; lda 80 (duplicate)
          ;; sta playerSubpixelY_W,x (duplicate)
skip_7917:
                    ;; if playerY[temp1] > 80 then let playerSubpixelY_WL[temp1] = 0
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 80 (duplicate)
          ;; bcc skip_7176 (duplicate)
          ;; beq skip_7176 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerSubpixelY_WL,x (duplicate)
skip_7176:

          rts


