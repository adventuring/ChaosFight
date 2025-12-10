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
                    if playerX[temp1] < PlayerLeftEdge then let playerX[temp1] = PlayerLeftEdge
          lda temp1
          asl
          tax
          lda playerX,x
          cmp PlayerLeftEdge
          bcs skip_3749
          lda PlayerLeftEdge
          sta playerX,x
skip_3749:
                    if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_W[temp1] = PlayerLeftEdge
          lda temp1
          asl
          tax
          lda playerX,x
          cmp PlayerLeftEdge
          bcs skip_3303
          lda PlayerLeftEdge
          sta playerSubpixelX_W,x
skip_3303:
                    if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          cmp PlayerLeftEdge
          bcs skip_4739
          lda 0
          sta playerSubpixelX_WL,x
skip_4739:
                    if playerX[temp1] > PlayerRightEdge then let playerX[temp1] = PlayerRightEdge
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc PlayerRightEdge
          bcc skip_8156
          beq skip_8156
          lda PlayerRightEdge
          sta playerX,x
skip_8156:
                    if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_W[temp1] = PlayerRightEdge
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc PlayerRightEdge
          bcc skip_4401
          beq skip_4401
          lda PlayerRightEdge
          sta playerSubpixelX_W,x
skip_4401:
                    if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc PlayerRightEdge
          bcc skip_7460
          beq skip_7460
          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
skip_7460:

          ;; Constrain Y position (20 to 80 for screen bounds)
          ;; SCRAM write to playerSubpixelY_W
                    if playerY[temp1] < 20 then let playerY[temp1] = 20
          lda temp1
          asl
          tax
          lda playerY,x
          cmp 20
          bcs skip_9811
          lda 20
          sta playerY,x
skip_9811:
                    if playerY[temp1] < 20 then let playerSubpixelY_W[temp1] = 20
          lda temp1
          asl
          tax
          lda playerY,x
          cmp 20
          bcs skip_5142
          lda 20
          sta playerSubpixelY_W,x
skip_5142:
                    if playerY[temp1] < 20 then let playerSubpixelY_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerY,x
          cmp 20
          bcs skip_8164
          lda 0
          sta playerSubpixelY_WL,x
skip_8164:
                    if playerY[temp1] > 80 then let playerY[temp1] = 80
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc 80
          bcc skip_7749
          beq skip_7749
          lda 80
          sta playerY,x
skip_7749:
                    if playerY[temp1] > 80 then let playerSubpixelY_W[temp1] = 80
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc 80
          bcc skip_7917
          beq skip_7917
          lda 80
          sta playerSubpixelY_W,x
skip_7917:
                    if playerY[temp1] > 80 then let playerSubpixelY_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc 80
          bcc skip_7176
          beq skip_7176
          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x
skip_7176:

          rts


