;;; ChaosFight - Source/Routines/ConstrainToScreen.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

ConstrainToScreen:
          ;; Clamp player position to on-screen bounds and clear subpixels at edges.
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
          lda playerX,x
          cmp # PlayerLeftEdge
          bcs CheckRightEdge

          lda # PlayerLeftEdge
          sta playerX,x

CheckRightEdge:
          ;; if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_W[temp1] = PlayerLeftEdge
          lda temp1
          asl
          tax
          lda playerX,x
          cmp # PlayerLeftEdge
          bcs CheckRightEdgeSubpixel

          lda # PlayerLeftEdge
          sta playerSubpixelX_W,x

CheckRightEdgeSubpixel:
          ;; if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          cmp # PlayerLeftEdge
          bcs CheckRightEdgeClamp

          lda # 0
          sta playerSubpixelX_WL,x

CheckRightEdgeClamp:
          ;; if playerX[temp1] > PlayerRightEdge then let playerX[temp1] = PlayerRightEdge
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc # PlayerRightEdge
          bcc CheckTopEdge
          beq CheckTopEdge

          lda # PlayerRightEdge
          sta playerX,x

CheckTopEdge:
          ;; if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_W[temp1] = PlayerRightEdge
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc # PlayerRightEdge
          bcc CheckTopEdgeSubpixel
          beq CheckTopEdgeSubpixel

          lda # PlayerRightEdge
          sta playerSubpixelX_W,x

CheckTopEdgeSubpixel:
          ;; if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc # PlayerRightEdge
          bcc CheckTopEdgeClamp
          beq CheckTopEdgeClamp

          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
CheckTopEdgeClamp:

          ;; Constrain Y position (20 to 80 for screen bounds)
          ;; SCRAM write to playerSubpixelY_W
          ;; if playerY[temp1] < 20 then let playerY[temp1] = 20
          lda temp1
          asl
          tax
          lda playerY,x
          cmp # 20
          bcs CheckBottomEdge
          lda # 20
          sta playerY,x
CheckBottomEdge:
          ;; if playerY[temp1] < 20 then let playerSubpixelY_W[temp1] = 20
          lda temp1
          asl
          tax
          lda playerY,x
          cmp # 20
          bcs CheckBottomEdgeSubpixel
          lda # 20
          sta playerSubpixelY_W,x
CheckBottomEdgeSubpixel:
          ;; if playerY[temp1] < 20 then let playerSubpixelY_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerY,x
          cmp # 20
          bcs CheckBottomEdgeClamp
          lda # 0
          sta playerSubpixelY_WL,x
CheckBottomEdgeClamp:
          ;; if playerY[temp1] > 80 then let playerY[temp1] = 80
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc # 80
          bcc ConstrainToScreenDone
          beq ConstrainToScreenDone
          lda # 80
          sta playerY,x
ConstrainToScreenDone:
          ;; if playerY[temp1] > 80 then let playerSubpixelY_W[temp1] = 80
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc # 80
          bcc ConstrainToScreenDoneSubpixel
          beq ConstrainToScreenDoneSubpixel
          lda # 80
          sta playerSubpixelY_W,x
ConstrainToScreenDoneSubpixel:
          ;; if playerY[temp1] > 80 then let playerSubpixelY_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerY,x
          sec
          sbc # 80
          bcc ConstrainToScreenDoneClamp
          beq ConstrainToScreenDoneClamp
          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x
ConstrainToScreenDoneClamp:

          rts


