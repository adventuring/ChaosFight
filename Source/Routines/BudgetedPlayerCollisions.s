;;; ChaosFight - Source/Routines/BudgetedPlayerCollisions.bas
          ;; Forward declaration
CheckCollisionPair:

;;; Copyright © 2025 Bruce-Robert Pocock.

CheckCollisionP1vsP2:
          ;; Check collision between player 1 and player 2
          ;; Returns: Near (return thisbank)
          lda # 0
          sta temp3
          lda # 1
          sta temp4
          jsr CheckCollisionPair

          rts

BudgetedCollisionCheck:
          ;; Budget Collision Detection
          ;; Instead of checking all 6 collision pairs every frame in 4-player mode,
          ;; check 2 pairs per frame. This spreads the work across 3 frames.
          ;;
          ;; COLLISION PAIRS (4-player mode):
          ;; Pair 0: P1 vs P2 (always checked, most important)
          ;; Pair 1: P1 vs P3
          ;; Pair 2: P1 vs P4
          ;; Pair 3: P2 vs P3
          ;; Pair 4: P2 vs P4
          ;; Pair 5: P3 vs P4
          ;;
          ;; SCHEDULE:
          ;; Frame 0: Pairs 0, 1 (P1 vs P2, P1 vs P3)
          ;; Frame 1: Pairs 2, 3 (P1 vs P4, P2 vs P3)
          ;; Frame 2: Pairs 4, 5 (P2 vs P4, P3 vs P4)
          ;; Frame 3: Pairs 0, 1 (repeat)
          ;; Always check P1 vs P2 (most important)
          jsr CheckCollisionP1vsP2

          ;; Skip other checks if not Quadtari
          jmp BS_return

          ;; Check additional pairs based on frame phase
          lda framePhase
          cmp # 0
          bne BPC_CheckPhase0

          ;; TODO: #1306 BPC_Phase0

BPC_CheckPhase0:

          lda framePhase
          cmp # 1
          bne BPC_CheckPhase1

          ;; TODO: #1306 BPC_Phase1

BPC_CheckPhase1:

          lda framePhase
          cmp # 2
          bne BPC_CheckPhase2

          ;; TODO: #1306 BPC_Phase2

BPC_CheckPhase2:

          jmp BS_return

BPC_Phase0 .proc
          jmp BS_return

          jsr CheckCollisionP1vsP3

          jmp BS_return

.pend

BPC_Phase1 .proc
          jsr CheckCollisionP1vsP4

          jmp BS_return

          jsr CheckCollisionP2vsP3

          jmp BS_return

.pend

BPC_Phase2 .proc
          jsr CheckCollisionP2vsP4

          jmp BS_return

          jmp BS_return

          jsr CheckCollisionP3vsP4

          jmp BS_return

          ;; Input: temp3 = player 1 index, temp4 = player 2 index
          ;; Output: separates players if collision detected
          ;; If playerX[temp3] >= playerX[temp4], then BPC_CalcDiff
          lda temp3
          asl
          tax
          lda playerX,x
          sta temp2
          lda temp4
          asl
          tax
          lda playerX,x
          cmp temp2
          bcc BPC_CalcDiff
          ;; Set temp2 = playerX[temp4] - playerX[temp3]
          lda temp4
          asl
          tax
          lda playerX,x
          sec
          sbc temp2
          sta temp2
          jmp BPC_CheckSep

BPC_CalcDiff
          ;; Set temp2 = playerX[temp3]
          lda temp3
          asl
          tax
          lda playerX,x
          sta temp2 - playerX[temp4]
          lda temp3
          asl
          tax
          lda playerX,x
          sta temp2

.pend

BPC_CheckSep .proc
          rts

          ;; If playerX[temp3] < playerX[temp4], then BPC_SepLeft
          lda temp3
          asl
          tax
          lda playerX,x
          sta temp2
          lda temp4
          asl
          tax
          lda playerX,x
          cmp temp2
          bcc BPC_SepLeft

          ;; Set playerX[temp3] = playerX[temp3] + 1
          lda temp3
          asl
          tax
          inc playerX,x

          lda temp3
          asl
          tax
          inc playerX,x

          ;; let playerX[temp4] = playerX[temp4] - 1
          lda temp4
          asl
          tax
          dec playerX,x

          lda temp4
          asl
          tax
          dec playerX,x

          rts

.pend

BPC_SepLeft .proc
          ;; let playerX[temp3] = playerX[temp3] - 1
          lda temp3
          asl
          tax
          dec playerX,x

          lda temp3
          asl
          tax
          dec playerX,x

          ;; let playerX[temp4] = playerX[temp4] + 1
          lda temp4
          asl
          tax
          inc playerX,x

          lda temp4
          asl
          tax
          inc playerX,x

          rts

CheckCollisionP1vsP3
CheckCollisionP1vsP3
          lda # 0
          sta temp3
          lda # 2
          sta temp4
          jsr CheckCollisionPair

          rts

CheckCollisionP1vsP4
CheckCollisionP1vsP4
          lda # 0
          sta temp3
          lda # 3
          sta temp4
          jsr CheckCollisionPair

          rts

CheckCollisionP2vsP3
CheckCollisionP2vsP3
          lda # 1
          sta temp3
          lda # 2
          sta temp4
          jsr CheckCollisionPair

          rts

CheckCollisionP2vsP4
CheckCollisionP2vsP4
          lda # 1
          sta temp3
          lda # 3
          sta temp4
          jsr CheckCollisionPair

          rts

CheckCollisionP3vsP4
CheckCollisionP3vsP4
          lda # 2
          sta temp3
          lda # 3
          sta temp4
          jsr CheckCollisionPair

          rts

.pend

