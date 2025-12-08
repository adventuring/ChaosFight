;;; ChaosFight - Source/Routines/BudgetedPlayerCollisions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CheckCollisionP1vsP2:
          ;; Check collision between player 1 and player 2
          ;; Returns: Near (return thisbank)
          ;; lda # 0 (duplicate)
          sta temp3
          ;; lda # 1 (duplicate)
          ;; sta temp4 (duplicate)
          ;; jsr CheckCollisionPair (duplicate)

          rts

BudgetedCollisionCheck
;;; Budget Collision Detection
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
          ;; jsr BS_return (duplicate)

          ;; Check additional pairs based on frame phase
          lda framePhase
          cmp # 0
          bne BPC_CheckPhase0
          ;; TODO: BPC_Phase0
BPC_CheckPhase0:


          ;; lda framePhase (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne BPC_CheckPhase1 (duplicate)
          ;; TODO: BPC_Phase1
BPC_CheckPhase1:


          ;; lda framePhase (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne BPC_CheckPhase2 (duplicate)
          ;; TODO: BPC_Phase2
BPC_CheckPhase2:


          ;; jsr BS_return (duplicate)


BPC_Phase0 .proc
          ;; jsr BS_return (duplicate)

          ;; jsr CheckCollisionP1vsP3 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

BPC_Phase1 .proc
          ;; jsr CheckCollisionP1vsP4 (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr CheckCollisionP2vsP3 (duplicate)

          ;; jsr BS_return (duplicate)

.pend

BPC_Phase2 .proc
          ;; jsr CheckCollisionP2vsP4 (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; jsr CheckCollisionP3vsP4 (duplicate)

          ;; jsr BS_return (duplicate)

CheckCollisionPair
;; CheckCollisionPair (duplicate)
          ;; Input: temp3 = player 1 index, temp4 = player 2 index
          ;; Output: separates players if collision detected
                    ;; if playerX[temp3] >= playerX[temp4] then BPC_CalcDiff

                    ;; let temp2 = playerX[temp4] - playerX[temp3]          lda temp4          asl          tax          lda playerX,x          sta temp2
          jmp BPC_CheckSep

BPC_CalcDiff
                    ;; let temp2 = playerX[temp3]
          ;; lda temp3 (duplicate)
          asl
          tax
          ;; lda playerX,x (duplicate)
          ;; sta temp2 - playerX[temp4] (duplicate)
          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)

.pend

BPC_CheckSep .proc
          ;; rts (duplicate)

                    ;; if playerX[temp3] < playerX[temp4] then BPC_SepLeft

          ;; ;; let playerX[temp3] = playerX[temp3] + 1
          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          inc playerX,x

          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerX,x (duplicate)

          ;; ;; let playerX[temp4] = playerX[temp4] - 1
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          dec playerX,x

          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerX,x (duplicate)

          ;; rts (duplicate)

.pend

BPC_SepLeft .proc
          ;; ;; let playerX[temp3] = playerX[temp3] - 1
          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerX,x (duplicate)

          ;; lda temp3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; dec playerX,x (duplicate)

          ;; ;; let playerX[temp4] = playerX[temp4] + 1
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerX,x (duplicate)

          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; inc playerX,x (duplicate)

          ;; rts (duplicate)

CheckCollisionP1vsP3
;; CheckCollisionP1vsP3 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda # 2 (duplicate)
          ;; sta temp4 (duplicate)
          ;; jsr CheckCollisionPair (duplicate)

          ;; rts (duplicate)

CheckCollisionP1vsP4
;; CheckCollisionP1vsP4 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda # 3 (duplicate)
          ;; sta temp4 (duplicate)
          ;; jsr CheckCollisionPair (duplicate)

          ;; rts (duplicate)

CheckCollisionP2vsP3
;; CheckCollisionP2vsP3 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda # 2 (duplicate)
          ;; sta temp4 (duplicate)
          ;; jsr CheckCollisionPair (duplicate)

          ;; rts (duplicate)

CheckCollisionP2vsP4
;; CheckCollisionP2vsP4 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda # 3 (duplicate)
          ;; sta temp4 (duplicate)
          ;; jsr CheckCollisionPair (duplicate)

          ;; rts (duplicate)

CheckCollisionP3vsP4
;; CheckCollisionP3vsP4 (duplicate)
          ;; lda # 2 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda # 3 (duplicate)
          ;; sta temp4 (duplicate)
          ;; jsr CheckCollisionPair (duplicate)

          ;; rts (duplicate)

.pend

