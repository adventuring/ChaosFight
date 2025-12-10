;;; ChaosFight - Source/Routines/BudgetedMissileCollisions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

BudgetedMissileCollisionCheck
;;; Budget Missile Collision Detection
          ;; Check missile collisions for at most 2 missiles per frame.
          ;;
          ;; SCHEDULE (2-player mode):
          ;; Even frames: Check Game Player 0 missile collisions
          ;; Odd frames: Check Game Player 1 missile collisions
          ;;
          ;; SCHEDULE (4-player mode):
          ;; Frame 0: Check Game Player 0 missile vs all players
          ;; Frame 1: Check Game Player 1 missile vs all players
          ;; Frame 2: Check Game Player 2 missile vs all players
          ;; Frame 3: Check Game Player 3 missile vs all players
          ;; Use missileActive bit flags: bit 0 = Player 0, bit 1 = Player 1,
          ;; bit 2 = Player 2, bit 3 = Player 3
          ;; Use CheckAllMissileCollisions from MissileCollision.bas which checks one player missile
          lda controllerStatus
          and SetQuadtariDetected
          cmp # 0
          bne skip_9367
skip_9367:


          ;; 4-player mode: check one missile per frame
          lda framePhase
          sta temp1
          ;; framePhase 0-3 maps to Game Players 0-3
          ;; Calculate bit flag using O(1) array lookup: BitMask[playerIndex] (1, 2, 4, 8)
          ;; let temp6 = BitMask[temp1]
          lda temp1
          asl
          tax
          lda BitMask,x
          sta temp6
          lda missileActive
          and temp6
          sta temp4
          ;; Cross-bank call to CheckAllMissileCollisions in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckAllMissileCollisions-1)
          pha
          lda # <(CheckAllMissileCollisions-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:


          rts

BudgetedMissileCollisionCheck2P
          ;; Simple 2-player mode: alternate missiles
          ;; let temp1 = frame & 1
          lda frame
          and # 1
          sta temp1

          lda frame
          and # 1
          sta temp1

          ;; Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          ;; BitMask[playerIndex] (1, 2, 4, 8)
          ;; Calculate bit flag using O(1) array lookup:
          ;; let temp6 = BitMask[temp1]
          lda temp1
          asl
          tax
          lda BitMask,x
          sta temp6
          lda missileActive
          and temp6
          sta temp4
          ;; Cross-bank call to CheckAllMissileCollisions in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckAllMissileCollisions-1)
          pha
          lda # <(CheckAllMissileCollisions-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:


          rts


