          rem ChaosFight - Source/Routines/MissileCharacterHandlers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Character-specific missile handlers extracted from MissileSystem.bas
          rem These handlers must be in the same bank as MissileSystem.bas
          rem (Bank 10) due to goto calls to DeactivateMissile

HarpyCheckDiveVelocity
          rem Helper: Checks if Harpy is in dive mode and boosts
          rem velocity if so
          rem
          rem Input: temp6 = base Y velocity, temp1 = player
          rem index, characterStateFlags_R[] (global SCRAM array) =
          rem character state flags
          rem
          rem Output: Y velocity boosted by 50% if in dive mode
          rem
          rem Mutates: temp6 (velocity calculation), temp6
          rem (via HarpyBoostDiveVelocity)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for SpawnMissile, only called
          rem for Harpy (character 6)
          if (characterStateFlags_R[temp1] & 4) then HarpyBoostDiveVelocity
          goto VelocityDone
HarpyBoostDiveVelocity
          rem Helper: Increases Harpy downward velocity by 50% for dive
          rem attacks
          rem
          rem Input: temp6 = base velocity
          rem
          rem Output: Velocity increased by 50% (velocity + velocity÷2)
          rem
          rem Mutates: temp6, temp6 (velocity
          rem values)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for HarpyCheckDiveVelocity,
          rem only called when dive mode active
          rem Increase downward velocity by 50% for dive attacks
          rem Divide by 2 using bit shift
          asm
            lda temp6
            lsr
            sta velocityCalculation
end
          let temp6 = temp6 + velocityCalculation
VelocityDone
          let missileVelocityY[temp1] = temp6

          return

HandleMegaxMissile
          rem
          rem HANDLE MEGAX MISSILE (stationary Fire Breath Visual)
          rem Megax missile stays adjacent to player, no movement.
          rem Missile appears when attack starts, stays during attack
          rem phase,
          rem   and vanishes when attack animation completes.
          rem Handles Megax stationary fire breath visual (locked to
          rem player position)
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, playerState[] (global
          rem array) = player states (facing direction, animation
          rem state), CharacterMissileEmissionHeights[] (global data
          rem table) = emission heights,
          rem CharacterMissileSpawnOffsetLeft[],
          rem CharacterMissileSpawnOffsetRight[] = spawn
          rem offsets, PlayerStateBitFacing (global constant) = facing
          rem bit mask, ActionAttackExecute (global constant) = attack
          rem animation state (14)
          rem
          rem Output: Missile position locked to player, missile
          rem deactivated when attack animation completes
          rem
          rem Mutates: temp1-temp6 (used for calculations), missileX[],
          rem missileY_W[] (global arrays) = missile positions,
          rem missileVelocityX[], missileVelocityY[] (global arrays) =
          rem missile velocities (zeroed), missileActive (global) =
          rem missile active flags (via DeactivateMissile)
          rem
          rem Called Routines: DeactivateMissile - deactivates missile
          rem when attack completes
          rem
          rem Constraints: Megax missile stays adjacent to player with
          rem zero velocity. Deactivates when animation state !=
          rem ActionAttackExecute (14)

          rem Get facing direction (bit 0: 0=left, 1=right)
          let temp4 = playerState[temp1] & PlayerStateBitFacing

          rem Get emission height from character data
          let temp5 = CharacterMissileEmissionHeights[temp5]

          rem Lock missile position to player position (adjacent, no
          rem movement)
          rem Calculate X position based on player position and facing
          let temp2 = playerX[temp1]
          rem Facing left, spawn left
          if temp4 = 0 then temp2 = temp2 + CharacterMissileSpawnOffsetLeft[temp5]
          rem Facing right, spawn right
          if temp4 = 1 then temp2 = temp2 + CharacterMissileSpawnOffsetRight[temp5]

          rem Calculate Y position (player Y + emission height)
          let temp3 = playerY[temp1] + temp5

          rem Update missile position (locked to player)
          let missileX[temp1] = temp2
          let missileY_W[temp1] = temp3

          rem Zero velocities to prevent any movement
          let missileVelocityX[temp1] = 0
          let missileVelocityY[temp1] = 0

          rem Check if attack animation is complete
          rem Animation state is in bits 4-7 of playerState
          rem ActionAttackExecute = 14 (0xE)
          rem Extract animation state (bits 4-7)
          let temp6 = playerState[temp1]
          rem Extract animation state (bits 4-7) using bit shift
          asm
            lsr temp6
            lsr temp6
            lsr temp6
            lsr temp6
end
          rem If animation state is not ActionAttackExecute (14), attack
          rem is complete
          rem   deactivate
          rem ActionAttackExecute = 14, so if animationState != 14,
          if temp6 = 14 then MegaxMissileActive
          rem Attack complete - deactivate missile
          goto DeactivateMissile

MegaxMissileActive
          rem Attack still active - missile stays visible
          rem Skip normal movement and collision checks
          return

HandleKnightGuyMissile
          rem
          rem HANDLE KNIGHT GUY MISSILE (sword Swing Visual)
          rem Knight Guy missile appears partially overlapping player,
          rem   moves slightly away during attack phase (sword swing),
          rem   returns to start position, and vanishes when attack
          rem   completes.
          rem Handles Knight Guy sword swing visual (moves away then
          rem returns during attack)
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, playerState[] (global
          rem array) = player states (facing direction, animation
          rem state), CharacterMissileEmissionHeights[] (global data
          rem table) = emission heights, currentAnimationFrame_R[]
          rem (global SCRAM array) = animation frames,
          rem PlayerStateBitFacing (global constant) = facing bit mask,
          rem ActionAttackExecute (global constant) = attack animation
          rem state (14)
          rem
          rem Output: Missile position animated based on animation frame
          rem (swing out frames 0-3, return frames 4-7), missile
          rem deactivated when attack completes
          rem
          rem Mutates: temp1-temp6 (used for calculations), missileX[],
          rem missileY_W[] (global arrays) = missile positions,
          rem missileVelocityX[], missileVelocityY[] (global arrays) =
          rem missile velocities (zeroed), missileActive (global) =
          rem missile active flags (via DeactivateMissile)
          rem
          rem Called Routines: DeactivateMissile - deactivates missile
          rem when attack completes
          rem
          rem Constraints: Knight Guy missile swings out 1-4 pixels
          rem (frames 0-3) then returns (frames 4-7). Deactivates when
          rem animation state != ActionAttackExecute (14)

          rem Get facing direction (bit 0: 0=left, 1=right)
          let temp4 = playerState[temp1] & PlayerStateBitFacing

          rem Get emission height from character data
          let temp5 = CharacterMissileEmissionHeights[temp5]

          rem Check if attack animation is complete
          rem Extract animation state (bits 4-7)
          let temp6 = playerState[temp1]
          rem Extract animation state (bits 4-7) using bit shift
          asm
            lsr temp6
            lsr temp6
            lsr temp6
            lsr temp6
end
          rem If animation state is not ActionAttackExecute (14), attack is complete
          if temp6 = 14 then KnightGuyAttackActive
          rem Attack complete - deactivate missile
          goto DeactivateMissile

KnightGuyAttackActive
          rem Get current animation frame within Execute sequence (0-7)
          rem Read from SCRAM and calculate offset immediately
          let velocityCalculation = currentAnimationFrame_R[temp1]

          rem Calculate sword swing offset based on animation frame
          rem Frames 0-3: Move away from player (sword swing out)
          rem Frames 4-7: Return to start (sword swing back)
          rem Maximum swing distance: 4 pixels
          rem Frames 4-7: Returning to start
          if velocityCalculation < 4 then KnightGuySwingOut
          rem Calculate return offset: (7 - frame) pixels
          rem Frame 4: 3 pixels away, Frame 5: 2 pixels, Frame 6: 1
          rem pixel, Frame 7: 0 pixels
          let velocityCalculation = 7 - velocityCalculation
          goto KnightGuySetPosition

KnightGuySwingOut
          rem Frames 0-3: Moving away from player
          rem Calculate swing offset: (frame + 1) pixels
          rem Frame 0: 1 pixel, Frame 1: 2 pixels, Frame 2: 3 pixels, Frame 3: 4 pixels
          let velocityCalculation = velocityCalculation + 1

KnightGuySetPosition
          rem Calculate base X position (partially overlapping player)
          rem Start position: player X + 8 pixels (halfway through
          rem player sprite)
          rem Then apply swing offset in facing direction
          let temp2 = playerX[temp1] + 8
          rem Base position: center of player sprite

          rem Apply swing offset in facing direction

          if temp4 = 0 then KnightGuySwingLeft
          rem Facing right: move right (positive offset)
          let temp2 = temp2 + velocityCalculation
          goto KnightGuySetY

KnightGuySwingLeft
          rem Facing left: move left (negative offset)
          let temp2 = temp2 - velocityCalculation

KnightGuySetY
          rem Calculate Y position (player Y + emission height)
          let temp3 = playerY[temp1] + temp5

          rem Update missile position
          let missileX[temp1] = temp2
          let missileY_W[temp1] = temp3

          rem Zero velocities to prevent projectile movement
          rem   frame
          rem Position is updated directly each frame based on animation
          let missileVelocityX[temp1] = 0
          let missileVelocityY[temp1] = 0

          rem Skip normal movement and collision checks
          return

