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
          ;; lda playerX,x (duplicate)
          sta temp4
                    ;; if temp4 < temp2 then let playerX[temp1] = temp4 + 1
          ;; Update Y axis (one pixel per frame)
                    ;; if temp4 > temp2 then let
          ;; lda temp4 (duplicate)
          sec
          sbc temp2
          bcc skip_6165
          beq skip_6165
          jmp let_label
skip_6165: playerX[temp1] = temp4 - 1
                    ;; let temp4 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp4 (duplicate)
                    ;; if temp4 < temp3 then let playerY[temp1] = temp4 + 1
          ;; Check if at target and nudge if needed
                    ;; if temp4 > temp3 then let
          ;; lda temp4 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp3 (duplicate)
          ;; bcc skip_2624 (duplicate)
          ;; beq skip_2624 (duplicate)
          ;; jmp let_label (duplicate)
skip_2624: playerY[temp1] = temp4 - 1
          jsr NudgePlayerFromPlayfield
          ;; jsr NudgePlayerFromPlayfield (duplicate)
          ;; jsr BS_return (duplicate)

.pend

NudgePlayerFromPlayfield .proc
          ;; Nudge player away from playfield collision
          ;; Returns: Near (return thisbank) - called same-bank from MovePlayerToTarget
          ;; Input: temp1 = player index
          ;; Output: Player position adjusted to avoid playfield
                    ;; let originalPlayerX_W = playerX[temp1]          lda temp1          asl          tax          lda playerX,x          sta originalPlayerX_W
                    ;; let originalPlayerY_W = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta originalPlayerY_W (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta originalPlayerY_W (duplicate)
          ;; jsr MPT_NudgeRight (duplicate)

          ;; jsr MPT_NudgeLeft (duplicate)

          rts

.pend

MPT_NudgeRight .proc
                    ;; let playerX[temp1] = originalPlayerX_R + 1
          ;; jsr MPT_CheckCollision (duplicate)

          ;; lda temp6 (duplicate)
          cmp # 1
          bne skip_2842
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda originalPlayerX_R (duplicate)
          ;; sta playerX,x (duplicate)
skip_2842:

          ;; rts (duplicate)

.pend

MPT_NudgeLeft .proc
                    ;; let playerX[temp1] = originalPlayerX_R - 1
          ;; jsr MPT_CheckCollision (duplicate)

          ;; lda temp6 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_2842 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda originalPlayerX_R (duplicate)
          ;; sta playerX,x (duplicate)
;; skip_2842: (duplicate)

          ;; rts (duplicate)

MPT_CheckCollision
          ;; Returns: Near (return thisbank)
;; MPT_CheckCollision (duplicate)
          ;; Check collision at current position
          ;; Returns: Near (return thisbank) - called same-bank from MPT_NudgeRight/Left
          ;; Input: temp1 = player index, playerX[temp1] = test position, originalPlayerY_R = Y
          ;; Output: temp6 = 1 if collision, 0 if clear
                    ;; let temp2 = playerX[temp1] - ScreenInsetX         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 / 4          lda temp2          lsr          lsr          sta temp2
          ;; lda temp2 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_7663 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
skip_7663:

                    ;; if temp2 & $80 then let temp2 = 0
          ;; lda originalPlayerY_R (duplicate)
          ;; sta temp3 (duplicate)
                    ;; let temp5 = temp3 / 16
          ;; lda # 0 (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp5 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 15
          ;; jmp BS_jsr (duplicate)
return_point:

                    ;; if temp1 then let temp6 = 1          lda temp1          beq skip_8161
skip_8161:
          ;; jmp skip_8161 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp3 (duplicate)
          clc
          adc # 16
          ;; sta temp3 (duplicate)
                    ;; let temp5 = temp3 / 16
          ;; MPT_CheckCollision is called same-bank, so use return thisbank
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; rts (duplicate)

.pend

