;;; ChaosFight - Source/Routines/MissileCharacterHandlers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Character-specific missile handlers extracted from MissileSystem.bas
;;; These handlers must be in the same bank as MissileSystem.bas
;;; (Bank 10) due to goto calls to DeactivateMissile


HarpyCheckDiveVelocity .proc
          ;; Helper: Checks if Harpy is in dive mode and boosts
          ;; Returns: Far (return otherbank)
          ;; velocity if so
          ;;
          ;; Input: temp6 = base Y velocity, temp1 = player
          ;; index, characterStateFlags_R[] (global SCRAM array) =
          ;; character state flags
          ;;
          ;; Output: Y velocity boosted by 50% if in dive mode
          ;;
          ;; Mutates: temp6 (velocity calculation), temp6
          ;; (via HarpyBoostDiveVelocity)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Internal helper for SpawnMissile, only called
          ;; for Harpy (character 6)
          ;; if (characterStateFlags_R[temp1] & 4) then HarpyBoostDiveVelocity
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          and # 4
          beq VelocityDone

          jsr HarpyBoostDiveVelocity

VelocityDone:
          rts

.pend

VelocityDone:
          ;; Global label for cross-file reference from MissileSystem.s (same bank)
          rts

HarpyBoostDiveVelocity .proc
          ;; Helper: Increases Harpy downward velocity by 50% for dive
          ;; attacks
          ;;
          ;; Input: temp6 = base velocity
          ;;
          ;; Output: Velocity increased by 50% (velocity + velocity/2)
          ;;
          ;; Mutates: temp6, temp6 (velocity
          ;; values)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Internal helper for HarpyCheckDiveVelocity,
          ;; only called when dive mode active
          ;; Increase downward velocity by 50% for dive attacks
          ;; Divide by 2 using bit shift
          lda temp6
          lsr
          sta velocityCalculation
          ;; let temp6 = temp6 + velocityCalculation

VelocityDone:
          lda temp1
          asl
          tax
          lda temp6
          sta missileVelocityY,x
          rts

.pend

HandleMegaxMissile .proc
          ;;
          ;; HANDLE MEGAX MISSILE (stationary Fire Breath Visual)
          ;; Megax missile stays adjacent to player, no movement.
          ;; Missile appears when attack starts, stays during attack
          ;; phase,
          and vanishes when attack animation completes.
          ;; Handles Megax stationary fire breath visual (locked to
          ;; player position)
          ;;
          ;; Input: temp1 = player index (0-3), playerX[], playerY[]
          ;; (global arrays) = player positions, playerState[] (global
          ;; array) = player states (facing direction, animation
          ;; state), CharacterMissileEmissionHeights[] (global data
          ;; table) = emission heights,
          ;; CharacterMissileSpawnOffsetLeft[],
          ;; CharacterMissileSpawnOffsetRight[] = spawn
          ;; offsets, PlayerStateBitFacing (global constant) = facing
          bit mask, ActionAttackExecute (global constant) = attack
          ;; animation state (14)
          ;;
          ;; Output: Missile position locked to player, missile
          ;; deactivated when attack animation completes
          ;;
          ;; Mutates: temp1-temp6 (used for calculations), missileX[],
          ;; missileY_W[] (global arrays) = missile positions,
          ;; missileVelocityX[], missileVelocityY[] (global arrays) =
          ;; missile velocities (zeroed), missileActive (global) =
          ;; missile active flags (via DeactivateMissile)
          ;;
          ;; Called Routines: DeactivateMissile - deactivates missile
          ;; when attack completes
          ;;
          ;; Constraints: Megax missile stays adjacent to player with
          ;; zero velocity. Deactivates when animation state ≠
          ;; ActionAttackExecute (14)

          ;; Get facing direction (bit 0: 0=left, 1=right)
                    let temp4 = playerState[temp1] & PlayerStateBitFacing          lda temp1          asl          tax          lda playerState,x          sta temp4

          ;; Get emission height from character data
          ;; let temp5 = CharacterMissileEmissionHeights[temp5]
          lda temp5
          asl
          tax
          lda CharacterMissileEmissionHeights,x
          sta temp5

          ;; Lock missile position to player position (adjacent, no
          ;; movement)
          ;; Calculate X position based on player position and facing
          ;; let temp2 = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; Facing left, spawn left
          lda temp4
          cmp # 0
          bne CheckFacingRight
          ;; let temp2 = temp2 + CharacterMissileSpawnOffsetLeft[temp5]
CheckFacingRight:


          ;; Facing right, spawn right
          lda temp4
          cmp # 1
          bne CalculateYPosition
          ;; let temp2 = temp2 + CharacterMissileSpawnOffsetRight[temp5]
CalculateYPosition:


          ;; Calculate Y position (player Y + emission height)
                    let temp3 = playerY[temp1] + temp5          lda temp1          asl          tax          lda playerY,x          sta temp3

          ;; Update missile position (locked to player)
          lda temp1
          asl
          tax
          lda temp2
          sta missileX,x
          lda temp1
          asl
          tax
          lda temp3
          sta missileY_W,x

          ;; Zero velocities to prevent any movement
          lda temp1
          asl
          tax
          lda 0
          sta missileVelocityX,x
          lda temp1
          asl
          tax
          lda 0
          sta missileVelocityY,x

          ;; Check if attack animation is complete
          ;; Animation state is in bits 4-7 of playerState
          ActionAttackExecute = 14 (0xE)
          ;; Extract animation state (bits 4-7)
          ;; let temp6 = playerState[temp1]
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6
          ;; Extract animation state (bits 4-7) using bit shift
            lsr temp6
            lsr temp6
            lsr temp6
            lsr temp6
          If animation state is not ActionAttackExecute (14), attack
          ;; is complete
          ;; deactivate
          ActionAttackExecute = 14, so if animationState ≠ 14,
          lda temp6
          cmp # 14
          bne DeactivateMissile
          ;; TODO: #1311 MegaxMissileActive
DeactivateMissile:


          ;; Attack complete - deactivate missile
          jmp DeactivateMissile

.pend

MegaxMissileActive .proc
          ;; Attack still active - missile stays visible
          ;; Skip normal movement and collision checks
          rts

.pend

HandleKnightGuyMissile .proc
          ;;
          ;; HANDLE KNIGHT GUY MISSILE (sword Swing Visual)
          ;; Knight Guy missile appears partially overlapping player,
          ;; moves slightly away during attack phase (sword swing),
          ;; returns to start position, and vanishes when attack
          ;; completes.
          ;; Handles Knight Guy sword swing visual (moves away then
          ;; returns during attack)
          ;;
          ;; Input: temp1 = player index (0-3), playerX[], playerY[]
          ;; (global arrays) = player positions, playerState[] (global
          ;; array) = player states (facing direction, animation
          ;; state), CharacterMissileEmissionHeights[] (global data
          ;; table) = emission heights, currentAnimationFrame_R[]
          ;; (global SCRAM array) = animation frames,
          ;; PlayerStateBitFacing (global constant) = facing bit mask,
          ;; ActionAttackExecute (global constant) = attack animation
          ;; state (14)
          ;;
          ;; Output: Missile position animated based on animation frame
          ;; (swing out frames 0-3, return frames 4-7), missile
          ;; deactivated when attack completes
          ;;
          ;; Mutates: temp1-temp6 (used for calculations), missileX[],
          ;; missileY_W[] (global arrays) = missile positions,
          ;; missileVelocityX[], missileVelocityY[] (global arrays) =
          ;; missile velocities (zeroed), missileActive (global) =
          ;; missile active flags (via DeactivateMissile)
          ;;
          ;; Called Routines: DeactivateMissile - deactivates missile
          ;; when attack completes
          ;;
          ;; Constraints: Knight Guy missile swings out 1-4 pixels
          ;; (frames 0-3) then returns (frames 4-7). Deactivates when
          ;; animation state ≠ ActionAttackExecute (14)

          ;; Get facing direction (bit 0: 0=left, 1=right)
                    let temp4 = playerState[temp1] & PlayerStateBitFacing          lda temp1          asl          tax          lda playerState,x          sta temp4

          ;; Get emission height from character data
          ;; let temp5 = CharacterMissileEmissionHeights[temp5]
          lda temp5
          asl
          tax
          lda CharacterMissileEmissionHeights,x
          sta temp5

          ;; Check if attack animation is complete
          ;; Extract animation state (bits 4-7)
          ;; let temp6 = playerState[temp1]
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp6
          ;; Extract animation state (bits 4-7) using bit shift
            lsr temp6
            lsr temp6
            lsr temp6
            lsr temp6
          If animation state is not ActionAttackExecute (14), attack is complete
          lda temp6
          cmp # 14
          bne DeactivateMissile
          ;; TODO: #1311 KnightGuyAttackActive
DeactivateMissile:


          ;; Attack complete - deactivate missile
          jmp DeactivateMissile

.pend

KnightGuyAttackActive .proc
          ;; Get current animation frame within Execute sequence (0-7)
          ;; Read from SCRAM and calculate offset immediately
          ;; let velocityCalculation = currentAnimationFrame_R[temp1]         
          lda temp1
          asl
          tax
          lda currentAnimationFrame_R,x
          sta velocityCalculation

          ;; Calculate sword swing offset based on animation frame
          ;; Frames 0-3: Move away from player (sword swing out)
          ;; Frames 4-7: Return to start (sword swing back)
          ;; Maximum swing distance: 4 pixels
          ;; Frames 4-7: Returning to sta

          ;; if velocityCalculation < 4 then KnightGuySwingOut
          lda velocityCalculation
          cmp # 4
          bcs KnightGuySwingReturn
          jmp KnightGuySwingOut
KnightGuySwingReturn:

          lda velocityCalculation
          cmp # 4
          bcs KnightGuySwingReturnLabel
          jmp KnightGuySwingOut
KnightGuySwingReturnLabel:



          ;; Calculate return offset: (7 - frame) pixels
          ;; Frame 4: 3 pixels away, Frame 5: 2 pixels, Frame 6: 1
          ;; pixel, Frame 7: 0 pixels
          ;; let velocityCalculation = 7 - velocityCalculation          lda 7          sec          sbc velocityCalculation          sta velocityCalculation
          lda 7
          sec
          sbc velocityCalculation
          sta velocityCalculation

          lda 7
          sec
          sbc velocityCalculation
          sta velocityCalculation

          jmp KnightGuySetPosition

.pend

KnightGuySwingOut .proc
          ;; Frames 0-3: Moving away from player
          ;; Calculate swing offset: (frame + 1) pixels
          ;; Frame 0: 1 pixel, Frame 1: 2 pixels, Frame 2: 3 pixels, Frame 3: 4 pixels
          inc velocityCalculation

KnightGuySetPosition
          ;; Calculate base X position (partially overlapping player)
          ;; Start position: player × + 8 pixels (halfway through
          ;; player sprite)
          Then apply swing offset in facing direction
          ;; let temp2 = playerX[temp1] + 8         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; Base position: center of player sprite

          ;; Apply swing offset in facing direction
          lda temp4
          cmp # 0
          bne KnightGuySwingRight
          ;; TODO: #1311 KnightGuySwingLeft
KnightGuySwingRight:


          ;; Facing right: move right (positive offset)
          ;; let temp2 = temp2 + velocityCalculation
          jmp KnightGuySetY

.pend

KnightGuySwingLeft .proc
          ;; Facing left: move left (negative offset)
                    let temp2 = temp2 - velocityCalculation          lda temp2          sec          sbc velocityCalculation          sta temp2

.pend

KnightGuySetY .proc
          ;; Calculate Y position (player Y + emission height)
          ;; let temp3 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3 + temp5
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp3

          ;; Update missile position
          lda temp1
          asl
          tax
          lda temp2
          sta missileX,x
          lda temp1
          asl
          tax
          lda temp3
          sta missileY_W,x

          ;; Zero velocities to prevent projectile movement
          ;; frame
          ;; Position is updated directly each frame based on animation
          lda temp1
          asl
          tax
          lda 0
          sta missileVelocityX,x
          lda temp1
          asl
          tax
          lda 0
          sta missileVelocityY,x

          ;; Skip normal movement and collision checks
          rts

.pend

