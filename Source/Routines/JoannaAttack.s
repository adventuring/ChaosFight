;;; ChaosFight - Source/Routines/JoannaAttack.s
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Joanna (character 16) orbital missile.
;;; Spawns centered on player, moves outward facing, orbits ~12 frames,
;;; deactivates if struck by other missile (AABB) or lifetime expires.
;;; Uses missileX/Y_W, missileVelocityX/Y, missileActive, missileFlags_W.
;;; Works with 4-player multiplexing via temp1 = 0..3 indexing.

JoannaAttack .proc
;; ------------------------------------------------------------------
;; SPAWN (called by CharacterAttacksDispatch.s when temp4 == CharacterJoanna)
;; ------------------------------------------------------------------
lda temp1
 tax
lda playerX,x
sta missileX,x          ;; spawn centered on player X
lda temp1
 tax
lda playerY,x
clc
adc # 4                 ;; vertical center (~half of 4px height)
sta missileY_W,x

;; Cache flags (low nibble = 3 = HitBackground|HitPlayer; high = phase 0)
lda # 3
sta temp5
lda # 0
asl
asl
asl
asl
ora temp5
sta temp6
lda temp1
 tax
sta missileFlags_W,x

;; Outward velocity based on facing bit (playerState bit 0)
lda temp1
 tax
lda playerState,x
and # 1
bne JoannaFaceRight
lda # 0
sec
sbc # 3                 ;; velocity = -3
sta missileVelocityX,x
jmp JoannaSpawnVelDone
JoannaFaceRight:
lda # 3
sta missileVelocityX,x
JoannaSpawnVelDone:
lda # 0
sta missileVelocityY,x

;; Activate missile bit
jsr GetPlayerMissileBitFlag
lda missileActive
ora temp6
sta missileActive

;; Lifetime = 12 (table value; orbit duration ~200ms)
lda temp1
 tax
lda # 12
sta missileLifetime_W,x

rts
.pend

