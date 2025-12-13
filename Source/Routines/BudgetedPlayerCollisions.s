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
          lda controllerStatus
          and # $80
          cmp # 0
          beq BPC_NotQuadtari

          ;; Check additional pairs based on frame phase
          lda framePhase
          cmp # 0
          bne BPC_CheckPhase1
          jsr BPC_Phase0
          jmp BS_return

BPC_CheckPhase1:
          lda framePhase
          cmp # 1
          bne BPC_CheckPhase2
          jsr BPC_Phase1
          jmp BS_return

BPC_CheckPhase2:
          lda framePhase
          cmp # 2
          bne BPC_Phase3
          jsr BPC_Phase2
          jmp BS_return

BPC_Phase3:
          ;; Frame phase 3: repeat phase 0 pairs
          jsr BPC_Phase0
          jmp BS_return

BPC_NotQuadtari:
          jmp BS_return

BPC_Phase0 .proc
          ;; Returns: Near (called from same bank)
          ;; Check pairs 0, 1: P1 vs P2 (already checked), P1 vs P3
          jsr CheckCollisionP1vsP3
          rts

.pend

BPC_Phase1 .proc
          ;; Returns: Near (called from same bank)
          ;; Check pairs 2, 3: P1 vs P4, P2 vs P3
          jsr CheckCollisionP1vsP4
          jsr CheckCollisionP2vsP3
          rts

.pend

BPC_Phase2 .proc
          ;; Returns: Near (called from same bank)
          ;; Check pairs 4, 5: P2 vs P4, P3 vs P4
          jsr CheckCollisionP2vsP4
          jsr CheckCollisionP3vsP4
          rts

.pend

CheckCollisionP1vsP3 .proc
          ;; Returns: Near (called from same bank)
          lda # 0
          sta temp3
          lda # 2
          sta temp4
          jsr CheckCollisionPair
          rts

.pend

CheckCollisionP1vsP4 .proc
          ;; Returns: Near (called from same bank)
          lda # 0
          sta temp3
          lda # 3
          sta temp4
          jsr CheckCollisionPair
          rts

.pend

CheckCollisionP2vsP3 .proc
          ;; Returns: Near (called from same bank)
          lda # 1
          sta temp3
          lda # 2
          sta temp4
          jsr CheckCollisionPair
          rts

.pend

CheckCollisionP2vsP4 .proc
          ;; Returns: Near (called from same bank)
          lda # 1
          sta temp3
          lda # 3
          sta temp4
          jsr CheckCollisionPair
          rts

.pend

CheckCollisionP3vsP4 .proc
          ;; Returns: Near (called from same bank)
          lda # 2
          sta temp3
          lda # 3
          sta temp4
          jsr CheckCollisionPair
          rts

.pend
