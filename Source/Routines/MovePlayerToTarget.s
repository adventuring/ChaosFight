;;; ChaosFight - Source/Routines/MovePlayerToTarget.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Helper functions for falling animation player movement


MovePlayerToTarget .proc

          ;; Move player toward target position (called from FallingAnimation1)
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index (0-3)
          ;; temp2 = target X position
          ;; temp3 = target Y position
          ;; Output: Player moved closer to target, or at target
          ;; Mutates: playerX[], playerY[], temp4-temp6, distanceUp_W

          ;; Update × axis (one pixel per frame)
          ;; let temp4 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp4
          ;; if temp4 < temp2 then let playerX[temp1] = temp4 + 1
          ;; Update Y axis (one pixel per frame)
          ;; if temp4 > temp2 then let
          lda temp4
          sec
          sbc temp2
          bcc MovePlayerXRight
          beq MovePlayerXRight

          lda temp4
          sec
          sbc # 1
          sta playerX,x

MovePlayerXRight:
          ;; let temp4 = playerY[temp1]         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp4
          ;; if temp4 < temp3 then let playerY[temp1] = temp4 + 1
          ;; Check if at target and nudge if needed
          ;; if temp4 > temp3 then let
          lda temp4
          sec
          sbc temp3
          bcc MovePlayerYDown
          beq MovePlayerYDown

          lda temp4
          sec
          sbc # 1
          sta playerY,x

MovePlayerYDown:
          jsr NudgePlayerFromPlayfield
          jsr NudgePlayerFromPlayfield
          jmp BS_return

.pend

NudgePlayerFromPlayfield .proc
          ;; Nudge player away from playfield collision
          ;; Returns: Near (return thisbank) - called same-bank from MovePlayerToTarget
          ;; Input: temp1 = player index
          ;; Output: Player position adjusted to avoid playfield
          ;; let originalPlayerX_W = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          sta originalPlayerX_W
          ;; let originalPlayerY_W = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta originalPlayerY_W
          jsr NudgeRightMovePlayer

          jsr NudgeLeftMovePlayer

          rts

.pend

NudgeRightMovePlayer .proc
          ;; let playerX[temp1] = originalPlayerX_R + 1
          jsr CheckCollisionMovePlayer

          lda temp6
          cmp # 1
          bne NudgeRightMovePlayerDone
          lda temp1
          asl
          tax
          lda originalPlayerX_R
          sta playerX,x
NudgeRightMovePlayerDone:

          rts

.pend

NudgeLeftMovePlayer .proc
          ;; let playerX[temp1] = originalPlayerX_R - 1
          jsr CheckCollisionMovePlayer

          lda temp6
          cmp # 1
          bne NudgeLeftMovePlayerDone
          lda temp1
          asl
          tax
          lda originalPlayerX_R
          sta playerX,x
NudgeLeftMovePlayerDone:
          rts
.pend

CheckCollisionMovePlayer:
          ;; Returns: Near (return thisbank)
          ;; Check collision at current position
          ;; Returns: Near (return thisbank) - called same-bank from NudgeRightMovePlayer/NudgeLeftMovePlayer
          ;; Input: temp1 = player index, playerX[temp1] = test position, originalPlayerY_R = Y
          ;; Output: temp6 = 1 if collision, 0 if clear
          ;; let temp2 = playerX[temp1] - ScreenInsetX         
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc # ScreenInsetX
          sta temp2
          ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          lda temp2
          lsr
          lsr
          sta temp2

          lda temp2
          lsr
          lsr
          sta temp2

          lda temp2
          cmp # 32
          bcc CheckPlayfieldPixel
          lda # 31
          sta temp2
CheckPlayfieldPixel:

          ;; if temp2 & $80 then let temp2 = 0
          lda originalPlayerY_R
          sta temp3
          ;; let temp5 = temp3 / 16
          lda # 0
          sta temp6
          lda temp1
          sta temp4
          lda temp2
          sta temp1
          lda temp5
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadNudge1-1)
          pha
          lda # <(AfterPlayfieldReadNudge1-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadNudge1:

          ;; if temp1 then let temp6 = 1          lda temp1          beq CheckCollisionMovePlayerDone
CheckCollisionMovePlayerDone:
          jmp CheckCollisionMovePlayerDone
          lda temp4
          sta temp1
          lda temp3
          clc
          adc # 16
          sta temp3
          ;; let temp5 = temp3 / 16
          ;; CheckCollisionMovePlayer is called same-bank, so use return thisbank
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadNudge2-1)
          pha
          lda # <(AfterPlayfieldReadNudge2-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadNudge2:

          rts

