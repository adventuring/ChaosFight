;;; ChaosFight - Source/Routines/BudgetedMissileCollisions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

BudgetedMissileCollisionCheck:

          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: (document parameters)
          ;;
          ;; Output: (document return values)
          ;;
          ;; Mutates: (document modified variables)
          ;;
          ;; Called Routines: (document subroutines called)
          ;;
          ;; Constraints: (document colocation/bank requirements)

          ;; Budget Missile Collision Detection
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
          and # SetQuadtariDetected
          bne Use4PlayerMode

          jmp BudgetedMissileCollisionCheck2P

Use4PlayerMode:

          ;; 4-player mode: check one missile per frame
          lda framePhase
          sta temp1
          ;; framePhase 0-3 maps to Game Players 0-3
          ;; Calculate bit flag using O(1) array lookup: BitMask[playerIndex] (1, 2, 4, 8)
          ;; Set temp6 = BitMask[temp1]
          lda temp1
          asl
          tax
          lda BitMask,x
          sta temp6
          lda missileActive
          and temp6
          sta temp4
          ;; Cross-bank call to CheckAllMissileCollisions in bank 8
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterCheckAllMissileCollisions-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckAllMissileCollisions hi (encoded)]
          lda # <(AfterCheckAllMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckAllMissileCollisions hi (encoded)] [SP+0: AfterCheckAllMissileCollisions lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckAllMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckAllMissileCollisions hi (encoded)] [SP+1: AfterCheckAllMissileCollisions lo] [SP+0: CheckAllMissileCollisions hi (raw)]
          lda # <(CheckAllMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckAllMissileCollisions hi (encoded)] [SP+2: AfterCheckAllMissileCollisions lo] [SP+1: CheckAllMissileCollisions hi (raw)] [SP+0: CheckAllMissileCollisions lo]
          ldx # 7
          jmp BS_jsr

AfterCheckAllMissileCollisions:

          rts

BudgetedMissileCollisionCheck2P:
          ;; Simple 2-player mode: alternate missiles
          ;; Set temp1 = frame & 1
          lda frame
          and # 1
          sta temp1

          ;; Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          ;; BitMask[playerIndex] (1, 2, 4, 8)
          ;; Calculate bit flag using O(1) array lookup:
          ;; Set temp6 = BitMask[temp1]
          lda temp1
          asl
          tax
          lda BitMask,x
          sta temp6
          lda missileActive
          and temp6
          sta temp4
          ;; Cross-bank call to CheckAllMissileCollisions in bank 8
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterCheckAllMissileCollisions2P-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckAllMissileCollisions2P hi (encoded)]
          lda # <(AfterCheckAllMissileCollisions2P-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckAllMissileCollisions2P hi (encoded)] [SP+0: AfterCheckAllMissileCollisions2P lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckAllMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckAllMissileCollisions2P hi (encoded)] [SP+1: AfterCheckAllMissileCollisions2P lo] [SP+0: CheckAllMissileCollisions hi (raw)]
          lda # <(CheckAllMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckAllMissileCollisions2P hi (encoded)] [SP+2: AfterCheckAllMissileCollisions2P lo] [SP+1: CheckAllMissileCollisions hi (raw)] [SP+0: CheckAllMissileCollisions lo]
          ldx # 7
          jmp BS_jsr

AfterCheckAllMissileCollisions2P:

          rts


