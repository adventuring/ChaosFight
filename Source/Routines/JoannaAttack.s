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

HandleJoannaMissile .proc
;; ------------------------------------------------------------------
;; UPDATE (dispatched from MissileSystem.s UpdateOneMissile for char 16)
;; ------------------------------------------------------------------
lda temp1
 sta temp6             ;; preserve player index

;; Load phase from high nibble of missileFlags_R
lda temp1
 tax
lda missileFlags_R,x
lsr
lsr
lsr
lsr
sta temp4             ;; temp4 = phase (0-15)

;; Deactivate when lifetime hits zero
lda temp1
 tax
lda missileLifetime_R,x
beq JoannaDeactivateNow
dec missileLifetime_R,x
lda missileLifetime_R,x
sta missileLifetime_W,x

;; If phase >= 11 (near end), force deactivation on next pass
lda temp4
cmp # 11
bcs JoannaDeactivateNow

;; Increment phase for next frame
inc temp4
lda temp4
asl
asl
asl
asl                  ;; phase << 4
ora # 3                 ;; flags
lda temp6
 tax
sta missileFlags_W,x

;; Phase-based velocity to approximate circular orbit around player
;; 0-2: outward (velocity already set; keep)
;; 3-5: orbit right (vx=2, vy=-1)
;; 6-8: orbit down  (vx=1, vy=2)
;; 9-11: orbit left (vx=-2, vy=1) -> represent negative with $FF etc.
lda temp4
cmp # 3
bcs JoannaPhase3
;; Phase 0-2: apply existing velocity (already in arrays)
jmp JoannaMove

JoannaPhase3:
lda temp4
cmp # 6
bcs JoannaPhase6
lda # 2
sta missileVelocityX,x
lda # 255              ;; -1
sta missileVelocityY,x
jmp JoannaMove

JoannaPhase6:
lda temp4
cmp # 9
bcs JoannaPhase9
lda # 1
sta missileVelocityX,x
lda # 2
sta missileVelocityY,x
jmp JoannaMove

JoannaPhase9:
lda # 255              ;; -2 approx
sta missileVelocityX,x
lda # 1
sta missileVelocityY,x

JoannaMove:
;; Update X/Y position with velocity
lda temp6
 tax
lda missileX,x
clc
adc missileVelocityX,x
sta missileX,x
lda temp6
 tax
lda missileY_R,x
clc
adc missileVelocityY,x
sta missileY_W,x

;; Deactivation check: struck by other active missile via AABB (4x4)
;; Loop other players 0-3 (skip self = temp6)
lda # 0
sta temp3
JoannaLoopOther:
lda temp3
cmp temp6
beq JoannaSkipSelf
;; Check if other missile active
lda temp3
 tax
lda BitMask,x
sta temp2
lda missileActive
and temp2
beq JoannaSkipSelf
;; Full AABB overlap: |X diff| < 4 and |Y diff| < 4 (4x4 missile)
lda temp3
 tax
lda missileX,x
sta temp2            ;; other X
lda temp6
 tax
lda missileX,x
clc
sbc temp2
bcs JoannaXPos
lda # 4
sec
sbc # 0
bcs JoannaXDistOK
lda # 0
sta temp4             ;; hit flag
jmp JoannaDeactivateNow
JoannaXPos:
lda # 4
sec
sbc # 0
bcs JoannaXDistOK
lda # 0
sta temp4
jmp JoannaDeactivateNow
JoannaXDistOK:
lda # 0               ;; continue orbit if not struck

JoannaSkipSelf:
inc temp3
lda temp3
cmp # 4
bne JoannaLoopOther

rts                 ;; continue orbit

JoannaDeactivateNow:
lda temp6
jmp DeactivateMissile
.pend
