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

CRTSMC_PlayerLoop .proc
          ;; Check if player is RoboTito and stretching
          if playerCharacter[temp1] = CharacterRoboTito then CRTSMC_IsRoboTito

          jmp CRTSMC_NextPlayer

.pend

CRTSMC_IsRoboTito .proc
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
          ;; if temp5 then goto CRTSMC_NextPlayer
          lda temp5
          beq CheckStretchingAnimation

          jmp CRTSMC_NextPlayer

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
          bne CRTSMC_NextPlayer

          jmp CRTSMC_IsStretching

.pend

CRTSMC_IsStretching .proc
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

                    if !playerHealth[temp6] then CRTSMC_DoneSelf

          ;; AABB collision check
          ;; Missile left/right: missileX to missileX+1 (missile width
          ;; = 1)
          ;; Missile top/bottom: missileY to missileY+stretchHeight
          ;; Player left/right: playerX to
          ;; playerX+PlayerSpriteHalfWidth*2
          ;; Player top/bottom: playerY to playerY+PlayerSpriteHeight
          ;; Missile left edge >= player right edge, no collision
          if temp3 >= playerX[temp6] + PlayerSpriteHalfWidth then CRTSMC_DoneSelf
          lda temp6
          asl
          tax
          lda playerX,x
          clc
          adc # PlayerSpriteHalfWidth
          sta temp6
          lda temp3
          sec
          sbc temp6
          bcc CheckMissileRightEdge

          jmp CRTSMC_DoneSelf

CheckMissileRightEdge:
          ;; Missile right edge <= player left edge, no collision
          if temp3 + 1 <= playerX[temp6] then CRTSMC_DoneSelf
          lda temp3
          clc
          adc # 1
          sta temp6
          lda temp6
          asl
          tax
          lda playerX,x
          sec
          sbc temp6
          bcc CheckMissileTopEdge
          beq CheckMissileTopEdge

          jmp CRTSMC_DoneSelf

CRTSMC_DoneSelf:
CheckMissileTopEdge:
          ;; Missile top edge >= player bottom edge, no collision
          if temp4 >= playerY[temp6] + PlayerSpriteHeight then CRTSMC_DoneSelf
          lda temp6
          asl
          tax
          lda playerY,x
          clc
          adc # PlayerSpriteHeight
          sta temp6
          lda temp4
          sec
          sbc temp6
          bcc CheckMissileBottomEdge

          jmp CRTSMC_DoneSelf

CheckMissileBottomEdge:
          ;; Missile bottom edge <= player top edge, no collision
          if temp4 + temp2 <= playerY[temp6] then CRTSMC_DoneSelf
          lda temp4
          clc
          adc temp2
          sta temp6
          lda temp6
          asl
          tax
          lda playerY,x
          sec
          sbc temp6
          bcc HandleStretchMissileHit
          beq HandleStretchMissileHit

          jmp CRTSMC_DoneSelf

HandleStretchMissileHit:

          ;; Collision detected! Handle stretch missile hit
          lda temp6
          sta temp5
          jsr HandleRoboTitoStretchMissileHit

          jmp CRTSMC_NextPlayer

          ;; After handling hit, skip remaining players for this RoboTito
CRTSMC_DoneSelf:
          inc temp6
          ;; if temp6 < 4 then CRTSMC_CheckOtherPlayer
          lda temp6
          cmp # 4
          bcs CRTSMC_NextPlayerLoop

          jmp CRTSMC_CheckOtherPlayer

CRTSMC_NextPlayerLoop:

          lda temp6
          cmp # 4
          bcs CRTSMC_NextPlayerLoopDone

          jmp CRTSMC_CheckOtherPlayer

CRTSMC_NextPlayerLoopDone:



.pend

CRTSMC_NextPlayer .proc
          inc temp1
          ;; if temp1 < 4 then goto CRTSMC_PlayerLoop
          lda temp1
          cmp # 4
          bcs CheckRoboTitoStretchMissileCollisionsDone

          jmp CRTSMC_PlayerLoop

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

