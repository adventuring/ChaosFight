;;; ChaosFight - Source/Routines/CheckRoboTitoStretchMissileCollisions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CheckRoboTitoStretchMissileCollisions:
          ;; Returns: Far (return otherbank)
          ;; Detects RoboTito stretch missile hits against other players
          ;; Inputs: playerCharacter[], playerState[], characterStateFlags_R[],
          ;; missileStretchHeight_R[], playerX[], playerY[], playerHealth[]
          ;; Outputs: Updates via HandleRoboTitoStretchMissileHit when collisions occur
          ;; Mutates: temp1-temp6, playerState[], characterStateFlags_W[],
          ;; missileStretchHeight_W[], characterSpecialAbility_W[]
          ;; Calls: HandleRoboTitoStretchMissileHit
          ;; Constraints: None

          ;; Loop through all players
          lda # 0
          sta temp1

PlayerLoopStretchMissileCheck .proc
          ;; Check if player is RoboTito and stretching
          ;; if playerCharacter[temp1] = CharacterRoboTito then IsRoboTitoStretchCheck
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterRoboTito
          beq IsRoboTitoStretchCheck
          jmp NextPlayerStretchCheck

IsRoboTitoStretchCheck:

          jmp NextPlayerStretchCheck

.pend

IsRoboTitoStretchCheck .proc
          ;; Player is RoboTito, check stretching sta

          ;; Check if stretching (not latched, ActionJumping animation
          ;; = 10)
          ;; Latched to ceiling, no stretch missile
          ;; let temp5 = characterStateFlags_R[temp1] & 1         
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          sta temp5
          ;; if temp5 then goto NextPlayerStretchCheck
          lda temp5
          beq CheckStretchingAnimation

          jmp NextPlayerStretchCheck

CheckStretchingAnimation:
          ;; Mask bits 4-7 (animation sta

          ;; let playerStateTemp = playerState[temp1]         
          lda temp1
          asl
          tax
          lda playerState,x
          sta playerStateTemp
          ;; Shift right by 4 to get animation sta

          lda playerStateTemp
          and # MaskPlayerStateAnimation
          sta playerStateTemp
          ;; let playerStateTemp = playerStateTemp / 16
          lda playerStateTemp
          cmp # 10
          bne NextPlayerStretchCheck

          jmp IsStretchingAnimation

.pend

IsStretchingAnimation .proc
          ;; In stretching animation, check for stretch missile

          ;; Check if stretch missile has height > 0
          ;; let temp2 = missileStretchHeight_R[temp1]         
          lda temp1
          asl
          tax
          lda missileStretchHeight_R,x
          sta temp2
          lda temp2
          bne CalculateMissilePosition

          jmp CRTSMC_NextPlayer

CalculateMissilePosition:

          ldx temp1
          let temp3 = playerX,x + 7
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp3
          ;; let temp4 = playerY[temp1] + 16
          lda temp1
          asl
          tax
          lda playerY,x
          clc
          adc # 16
          sta temp4

          ;; Check collision with other players
          ;; Missile extends from playerY down by stretchHeight
          ;; Bounding box: × = missileX,y = missileY, Width = 4, Height = stretchHeight
          lda # 0
          sta temp6

.pend

CRTSMC_CheckOtherPlayer .proc
          ;; Skip self
          lda temp6
          cmp temp1
          bne CheckPlayerHealth
          ;; TODO: #1310 CRTSMC_DoneSelf
CheckPlayerHealth:


          ;; Skip eliminated players
          ;; if !playerHealth[temp6] then CRTSMC_DoneSelf
          lda temp6
          asl
          tax
          lda playerHealth,x
          beq CRTSMC_DoneSelf

          ;; AABB collision check
          ;; Missile left/right: missileX to missileX+1 (missile width
          ;; = 1)
          ;; Missile top/bottom: missileY to missileY+stretchHeight
          ;; Player left/right: playerX to
          ;; playerX+PlayerSpriteHalfWidth*2
          ;; Player top/bottom: playerY to playerY+PlayerSpriteHeight
          ;; Missile left edge >= player right edge, no collision
          ;; if temp3 >= playerX[temp6] + PlayerSpriteHalfWidth then DoneSelfStretchCheck
          lda temp6
          asl
          tax
          lda playerX,x
          clc
          adc # PlayerSpriteHalfWidth
          sta temp4  ;;; Store player right edge
          lda temp3
          sec
          sbc temp4
          bcc CheckMissileRightEdge
          jmp DoneSelfStretchCheck

CheckMissileRightEdge:
          ;; Missile right edge <= player left edge, no collision
          ;; if temp3 + 1 <= playerX[temp6] then DoneSelfStretchCheck
          lda temp3
          clc
          adc # 1
          sta temp4  ;;; Missile right edge
          lda temp6
          asl
          tax
          lda playerX,x
          sec
          sbc temp4
          bcc CheckMissileTopEdge
          jmp DoneSelfStretchCheck

CheckMissileTopEdge:
          ;; Missile top edge >= player bottom edge, no collision
          ;; if temp4 >= playerY[temp6] + PlayerSpriteHeight then DoneSelfStretchCheck
          lda temp6
          asl
          tax
          lda playerY,x
          clc
          adc # PlayerSpriteHeight
          sta temp5  ;;; Player bottom edge
          lda temp4
          sec
          sbc temp5
          bcc CheckMissileBottomEdge
          jmp DoneSelfStretchCheck

CheckMissileBottomEdge:
          ;; Missile bottom edge <= player top edge, no collision
          ;; if temp4 + temp2 <= playerY[temp6] then DoneSelfStretchCheck
          lda temp4
          clc
          adc temp2
          sta temp5  ;;; Missile bottom edge
          lda temp6
          asl
          tax
          lda playerY,x
          sec
          sbc temp5
          bcc CollisionDetectedStretchMissile
          jmp DoneSelfStretchCheck

CollisionDetectedStretchMissile:
          ;; Collision detected! Handle stretch missile hit
          lda temp6
          sta temp5
          jsr HandleRoboTitoStretchMissileHit

          jmp NextPlayerStretchCheck

DoneSelfStretchCheck:
          inc temp6
          ;; if temp6 < 4 then CheckOtherPlayerStretchMissile
          lda temp6
          cmp # 4
          bcs NextPlayerLoopStretchCheck

          jmp CheckOtherPlayerStretchMissile

NextPlayerLoopStretchCheck:

          lda temp6
          cmp # 4
          bcs NextPlayerLoopStretchCheckDone

          jmp CheckOtherPlayerStretchMissile

NextPlayerLoopStretchCheckDone:



.pend

NextPlayerStretchCheck .proc
          inc temp1
          ;; if temp1 < 4 then goto PlayerLoopStretchMissileCheck
          lda temp1
          cmp # 4
          bcs CheckRoboTitoStretchMissileCollisionsDone

          jmp PlayerLoopStretchMissileCheck

CheckRoboTitoStretchMissileCollisionsDone:

          rts

.pend

HandleRoboTitoStretchMissileHit .proc
          ;; Resolves stretch missile collisions and resets stretch sta

          ;; Inputs: temp1 = RoboTito player index, temp5 = hit player index
          ;; Outputs: Updates playerState[], characterStateFlags_W[],
          ;; characterSpecialAbility_W[]
          ;; Mutates: temp2-temp3 (scratch), missileStretchHeight_W[]
          ;; Calls: None
          ;; Constraints: Keep contiguous with CRTSMC logic for bank locality
          ;; owner), temp5 = hit player index (victim), playerState[]
          ;; (global array) = player states, characterSpecialAbility_R[]
          ;; (global SCRAM array) = stretch permission (for RoboTito),
          ;; characterStateFlags_R[] (global SCRAM array) = character
          ;; state flags
          ;;
          ;; Output: RoboTito falls, stretch missile removed, stretch
          ;; permission cleared
          ;;
          ;; Mutates: missileStretchHeight_W[] (global SCRAM array) =
          ;; stretch missile heights, playerState[] (global array) =
          ;; player states, playerVelocityY[], playerVelocityYL[]
          ;; (global arrays) = vertical velocity, characterSpecialAbility_W[]
          ;; (global SCRAM array) = stretch permission,
          ;; characterStateFlags_W[] (global SCRAM array) = character
          ;; state flags, temp2-temp3 (used for calculations)
          ;;
          ;; Called Routines: None
          ;; Constraints: None
          ;; Vanish stretch missile (set height to 0)
          lda temp1
          asl
          tax
          lda # 0
          sta missileStretchHeight_W,x

          ;; Set RoboTito to free fall
          ldx temp1
          lda playerState,x
          ora # PlayerStateBitJumping
          sta playerState,x
          ldx temp1
          lda playerState,x
          ora # ActionFallingShifted
          sta playerState,x

          ;; Clear stretch permission for this player
          ;; Optimized: Simple array assignment instead of bit manipulation
          ;; Clear stretch permission
          lda temp1
          asl
          tax
          lda # 0
          sta characterSpecialAbility_W,x

          ;; Clear latched flag if set (falling from ceiling)
          ;; let temp3 = characterStateFlags_R[temp1]         
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          sta temp3
          ;; let temp3 = temp3 & 254
          lda temp3
          and # 254
          sta temp3

          ;; Clear bit 0 (latched flag)
          lda temp1
          asl
          tax
          lda temp3
          sta characterStateFlags_W,x

          rts

.pend

