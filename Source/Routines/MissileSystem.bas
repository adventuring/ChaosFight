          rem ChaosFight - Source/Routines/MissileSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem MISSILE SYSTEM - 4-PLAYER MISSILE MANAGEMENT
          rem =================================================================
          rem Manages up to 4 simultaneous missiles/attack visuals (one per player).
          rem Each player can have ONE active missile at a time, which can be:
          rem   - Ranged projectile (bullet, arrow, magic spell)
          rem   - Melee attack visual (sword, fist, kick sprite)

          rem MISSILE VARIABLES (from Variables.bas):
          rem   missileX[0-3] (a-d) - X positions
          rem   missileY[0-3] (w-z) - Y positions
          rem   missileActive (i) - Bit flags for which missiles are active
          rem   missileLifetime (e,f) - Packed nybble counters
          rem     e{7:4} = Player 1 lifetime, e{3:0} = Player 2 lifetime
          rem     f{7:4} = Player 3 lifetime, f{3:0} = Player 4 lifetime
          rem     Values: 0-13 = frame count, 14 = until collision, 15 = until off-screen

          rem TEMP VARIABLE USAGE:
          rem   temp1 = player index (0-3) being processed
          rem   temp2 = missileX delta (momentum/velocity)
          rem   temp3 = missileY delta (momentum/velocity)
          rem   temp4 = scratch for collision checks / flags / target player
          rem   temp5 = scratch for character data lookups / missile flags
          rem   temp6 = scratch for bit manipulation / collision bounds
          rem =================================================================

          rem =================================================================
          rem SPAWN MISSILE
          rem =================================================================
          rem Creates a new missile/attack visual for a player.
          rem Called when player presses attack button.

          rem INPUT:
          rem   temp1 = player index (0-3)

          rem PROCESS:
          rem   1. Look up character type for this player
          rem   2. Read missile properties from character data
          rem   3. Set missile X/Y based on player position, facing, and emission height
          rem   4. Set active bit for this player missile
          rem   5. Initialize lifetime counter from character data
SpawnMissile
          dim SM_playerIndex = temp1
          dim SM_facing = temp4
          dim SM_characterType = temp5
          dim SM_bitFlag = temp6
          dim SM_velocityCalc = temp6
          rem Get character type for this player
          let SM_characterType  = playerChar[SM_playerIndex]
          
          rem Read missile emission height from character data table
          let SM_bitFlag  = CharacterMissileEmissionHeights[SM_characterType]
          
          rem Calculate initial missile position based on player position and facing
          rem Facing is stored in playerState bit 0: 0=left, 1=right
          let SM_facing  = playerState[SM_playerIndex] & 1
          rem Get facing direction
          
          rem Set missile position using array access
          let missileX[SM_playerIndex] = playerX[SM_playerIndex]
          let missileY[SM_playerIndex] = playerY[SM_playerIndex] + SM_bitFlag
          if SM_facing = 0 then missileX[SM_playerIndex] = missileX[SM_playerIndex] - MissileSpawnOffsetLeft
          rem Facing left, spawn left
          if SM_facing = 1 then missileX[SM_playerIndex] = missileX[SM_playerIndex] + MissileSpawnOffsetRight
          rem Facing right, spawn right
          
          rem Set active bit for this player missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if SM_playerIndex = 0 then SM_bitFlag  = 1
          if SM_playerIndex = 1 then SM_bitFlag  = 2
          if SM_playerIndex = 2 then SM_bitFlag  = 4
          if SM_playerIndex = 3 then SM_bitFlag  = 8
          let missileActive  = missileActive | SM_bitFlag
          
          rem Initialize lifetime counter from character data table
          let missileLifetimeValue = CharacterMissileLifetime[SM_characterType]
          
          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile lifetime
          let missileLifetime[SM_playerIndex] = missileLifetimeValue
          
          rem Initialize velocity from character data for friction physics
          let SM_velocityCalc  = CharacterMissileMomentumX[SM_characterType]
          rem Get base X velocity
          if SM_facing = 0 then SM_velocityCalc  = 0 - SM_velocityCalc
          rem Apply facing direction (left = negative)
          let missileVelX[SM_playerIndex] = SM_velocityCalc
          
          let SM_velocityCalc  = CharacterMissileMomentumY[SM_characterType]
          rem Get Y velocity
          
          rem Apply Harpy dive velocity bonus if in dive mode
          if SM_characterType = 6 then HarpyCheckDiveVelocity
          goto VelocityDone
HarpyCheckDiveVelocity
          dim HCDV_velocityCalc = temp6
          let HCDV_velocityCalc = SM_velocityCalc
          if (characterStateFlags[SM_playerIndex] & 4) then HarpyBoostDiveVelocity
          goto VelocityDone
HarpyBoostDiveVelocity
          dim HBDV_halfVelocity = velocityCalculation
          rem Increase downward velocity by 50% for dive attacks
          rem Divide by 2 using bit shift
          asm
            lda HCDV_velocityCalc
            lsr a
            sta HBDV_halfVelocity
          end
          let HCDV_velocityCalc = HCDV_velocityCalc + HBDV_halfVelocity
          let SM_velocityCalc = HCDV_velocityCalc
VelocityDone
          let missileVelY[SM_playerIndex] = SM_velocityCalc
          
          return

          rem =================================================================
          rem UPDATE ALL MISSILES
          rem =================================================================
          rem Called once per frame to update all active missiles.
          rem Updates position, checks collisions, handles lifetime.
UpdateAllMissiles
          rem Check each player missile
          let temp1  = 0
          gosub UpdateOneMissile
          let temp1  = 1
          gosub UpdateOneMissile
          let temp1  = 2
          gosub UpdateOneMissile
          let temp1  = 3
          gosub UpdateOneMissile
          return

          rem =================================================================
          rem UPDATE ONE MISSILE
          rem =================================================================
          rem Updates a single player missile.
          rem Handles movement, gravity, collisions, and lifetime.

          rem INPUT:
          rem   temp1 = player index (0-3)
UpdateOneMissile
          dim UOM_playerIndex = temp1
          dim UOM_bitFlag = temp6
          dim UOM_isActive = temp4
          dim UOM_savedIndex = temp6
          dim UOM_velX = temp2
          dim UOM_velY = temp3
          dim UOM_characterType = temp5
          dim UOM_missileFlags = temp5
          rem Check if this missile is active
          let UOM_bitFlag  = 1
          if UOM_playerIndex = 1 then UOM_bitFlag  = 2
          if UOM_playerIndex = 2 then UOM_bitFlag  = 4
          if UOM_playerIndex = 3 then UOM_bitFlag  = 8
          let UOM_isActive  = missileActive & UOM_bitFlag
          if UOM_isActive  = 0 then return
          rem Not active, skip
          
          rem Preserve player index since GetMissileFlags uses temp1
          rem Use temp6 temporarily to save player index (temp6 is used for bit flags)
          let UOM_savedIndex  = UOM_playerIndex
          rem Save player index temporarily
          
          rem Get current velocities from stored arrays
          let UOM_velX  = missileVelX[UOM_playerIndex]
          rem X velocity (already facing-adjusted from spawn)
          let UOM_velY  = missileVelY[UOM_playerIndex]
          rem Y velocity
          
          rem Read missile flags from character data
          let UOM_characterType  = playerChar[UOM_playerIndex]
          rem Get character index
          let temp1  = UOM_characterType
          rem Use temp1 for flags lookup (temp1 will be overwritten)
          gosub bank6 GetMissileFlags
          let UOM_missileFlags  = temp2
          rem Store flags
          
          rem Restore player index and get flags back
          let UOM_playerIndex  = UOM_savedIndex
          rem Restore player index
          
          rem Apply gravity if flag is set
          if !(UOM_missileFlags & MissileFlagGravity) then GravityDone
          let UOM_velY = UOM_velY + GravityPerFrame
          rem Add gravity (1 pixel/frame down)
          let missileVelY[UOM_playerIndex] = UOM_velY
          rem Update stored Y velocity
GravityDone
          
          rem Apply friction if flag is set (curling stone deceleration with coefficient)
          if !(temp5 & MissileFlagFriction) then FrictionDone
          let missileVelocityX = missileVelX[UOM_playerIndex]
          rem Get current X velocity
          
          rem Apply coefficient-based friction: reduce by 12.5% per frame (32/256 = 1/8)
          rem CurlingFrictionCoefficient = 32 (Q8 fixed-point: 32/256 = 0.125 = 1/8)
          if missileVelocityX = 0 then FrictionDone
          rem Zero velocity, no friction to apply
          
          rem Calculate friction reduction (velocity / 8, approximates 12.5% reduction)
          let velocityCalculation = missileVelocityX
          if velocityCalculation < 0 then FrictionNegative
          rem Positive velocity
          rem Divide by 8 using bit shift (3 right shifts)
          asm
            lda velocityCalculation
            lsr a
            lsr a
            lsr a
            sta velocityCalculation
          end
          rem Reduce by 1/8 (12.5%)
          let missileVelocityX = missileVelocityX - velocityCalculation
          goto FrictionApply
FrictionNegative
          rem Negative velocity - convert to positive for division
          let velocityCalculation = 0 - velocityCalculation
          rem Divide by 8 using bit shift (3 right shifts)
          asm
            lda velocityCalculation
            lsr a
            lsr a
            lsr a
            sta velocityCalculation
          end
          rem Reduce by 1/8 (12.5%)
          let missileVelocityX = missileVelocityX + velocityCalculation
          rem Add back (since missileVelocityX was negative)
FrictionApply
          let missileVelX[UOM_playerIndex] = missileVelocityX
          let temp2  = missileVelocityX
          rem Update temp2 for position calculation
          rem Check if velocity dropped below threshold
          if missileVelocityX < MinimumVelocityThreshold && missileVelocityX > -MinimumVelocityThreshold then gosub DeactivateMissile : return
          rem Update stored X velocity with friction applied
          let missileVelX[UOM_playerIndex] = missileVelocityX
FrictionDone
          
          rem Update missile position
          let missileX[UOM_playerIndex] = missileX[UOM_playerIndex] + temp2
          let missileY[UOM_playerIndex] = missileY[UOM_playerIndex] + temp3
          
          rem Check screen bounds
          gosub CheckMissileBounds
          if temp4 then gosub DeactivateMissile : return 
          rem Off-screen, deactivate
          
          rem Check collision with playfield if flag is set
          if !(temp5 & MissileFlagHitBackground) then PlayfieldCollisionDone
          gosub bank7 MissileCollPF
          if !temp4 then PlayfieldCollisionDone
          if temp5 & MissileFlagBounce then gosub HandleMissileBounce
          gosub DeactivateMissile : return
PlayfieldCollisionDone
          
          rem Check collision with players
          rem This handles both visible missiles and AOE attacks
          gosub bank7 CheckAllMissileCollisions
          rem Check if hit was found (temp4 != MissileHitNotFound)
          if temp4 = MissileHitNotFound then MissileSystemNoHit
          
          rem Check if hit player is guarding before handling hit
          rem temp4 contains hit player index
          let temp6  = playerState[temp4] & 2
          if temp6 then GuardBounceFromCollision
          rem Guarding - bounce instead of damage
          goto HandleMissileDamage
GuardBounceFromCollision
          rem Guarding player - bounce the curling stone
          rem Play guard sound
          let soundEffectID = SoundGuard
          gosub bank15 PlaySoundEffect
          
          rem Bounce the missile: invert X velocity and apply friction damping
          let temp6  = missileVelX[UOM_playerIndex]
          let temp6  = 0 - temp6
          rem Invert X velocity (bounce back)
          rem Apply friction damping on bounce (reduce by 25% for guard bounce)
          rem Divide by 4 using bit shift (2 right shifts)
          asm
            lda temp6
            lsr a
            lsr a
            sta velocityCalculation
          end
          let temp6  = temp6 - velocityCalculation
          rem Reduce bounce velocity by 25%
          let missileVelX[UOM_playerIndex] = temp6
          
          rem Continue without deactivating - missile bounces and continues
          goto MissileSystemNoHit
          
HandleMissileDamage
          gosub HandleMissileHit
          rem HandleMissileHit applies damage and effects
          gosub DeactivateMissile
          rem Missile disappears after hitting player
          return
MissileSystemNoHit
          
          rem Decrement lifetime counter and check expiration
          rem Retrieve current lifetime for this missile
          let missileLifetimeValue = missileLifetime[UOM_playerIndex]
          
          rem Decrement if not set to infinite (infinite until collision)
          if missileLifetimeValue = MissileLifetimeInfinite then MissileUpdateComplete
          let missileLifetimeValue = missileLifetimeValue - 1
          if missileLifetimeValue = 0 then gosub DeactivateMissile : return
          let missileLifetime[UOM_playerIndex] = missileLifetimeValue
MissileUpdateComplete
          
          return

          rem =================================================================
          rem CHECK MISSILE BOUNDS
          rem =================================================================
          rem Checks if missile is off-screen.

          rem INPUT:
          rem   temp1 = player index (0-3)

          rem OUTPUT:
          rem   temp4 = 1 if off-screen, 0 if on-screen
CheckMissileBounds
          rem Get missile X/Y position
          let temp2  = missileX[temp1]
          let temp3  = missileY[temp1]
          
          rem Check bounds (usable sprite area is 128px wide, 16px inset from each side)
          let temp4  = 0
          if temp2 > ScreenInsetX + ScreenUsableWidth then temp4  = 1
          rem Off right edge (16 + 128)
          if temp2 < ScreenInsetX then temp4  = 1
          rem Off left edge
          if temp3 > ScreenBottom then temp4  = 1
          rem Off bottom
          rem Byte-safe top bound: if wrapped past 0 due to subtract, temp3 will be > original
          let temp5  = temp3
          rem Assuming prior update may have subtracted from temp3 earlier in loop
          if temp3 > ScreenTopWrapThreshold then temp4  = 1
          rem Off top
          
          return

          rem =================================================================
          rem CHECK MISSILE-PLAYFIELD COLLISION
          rem =================================================================
          rem Checks if missile hit the playfield (walls, obstacles).
          rem Uses pfread to check playfield pixel at missile position.

          rem INPUT:
          rem   temp1 = player index (0-3)

          rem OUTPUT:
          rem   temp4 = 1 if hit playfield, 0 if clear
MissileSysPF
          rem Get missile X/Y position
          let temp2  = missileX[temp1]
          let temp3  = missileY[temp1]
          
          rem Convert X/Y to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160), 192 pixels tall
          rem pfread uses playfield coordinates: column (0-31), row (0-11 or 0-31 depending on pfres)
          gosub Div5Compute 
          rem Convert X pixel to playfield column (160/32 = 5)
          rem temp3 is already in pixel coordinates, pfread will handle it
          
          rem Check if playfield pixel is set
          rem pfread(column, row) returns 0 if clear, non-zero if set
          rem pfread can only be used in if/then conditionals
          let temp4 = 0
          rem Default: clear
          if pfread(temp6, temp3) then temp4 = 1
          rem Hit playfield
          
          return

          rem =================================================================
          rem DIVIDE HELPERS (NO MUL/DIV SUPPORT)
          rem =================================================================
          rem HalfTemp7: integer divide temp7 by 2 using bit shift
HalfTemp7
          asm
            lsr temp7
end
          return

          rem Div5Compute: compute floor(temp2/5) into temp6 via repeated subtraction
Div5Compute
          let temp6  = 0
          if temp2 < 5 then return
Div5Loop
          let temp2  = temp2 - 5
          let temp6  = temp6 + 1
          if temp2>= 5 then Div5Loop
          return

          rem =================================================================
          rem CHECK MISSILE-PLAYER COLLISION
          rem =================================================================
          rem Checks if a missile hit any player (except the owner).
          rem Uses axis-aligned bounding box (AABB) collision detection.

          rem INPUT:
          rem   temp1 = missile owner player index (0-3)

          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckMissilePlayerCollision
          rem Get missile X/Y position
          let temp2  = missileX[temp1]
          let temp3  = missileY[temp1]
          
          rem Missile bounding box
          rem temp2 = missile left, temp2+MissileAABBSize = missile right
          rem temp3 = missile top, temp3+MissileAABBSize = missile bottom
          
          rem Check collision with each player (except owner)
          let temp4 = MissileHitNotFound
          rem Default: no hit
          
          rem Check Player 1 (index 0)
          if temp1  = 0 then MissileSkipPlayer0
          if playerHealth[0] = 0 then MissileSkipPlayer0
          if temp2>= playerX[0] + PlayerSpriteHalfWidth then MissileSkipPlayer0
          if temp2 + MissileAABBSize<= playerX[0] then MissileSkipPlayer0
          if temp3>= playerY[0] + PlayerSpriteHeight then MissileSkipPlayer0
          if temp3 + MissileAABBSize<= playerY[0] then MissileSkipPlayer0
          let temp4  = 0 : return
          rem Hit Player 1
MissileSkipPlayer0
          
          rem Check Player 2 (index 1)
          if temp1  = 1 then MissileSkipPlayer1
          if playerHealth[1] = 0 then MissileSkipPlayer1
          if temp2>= playerX[1] + PlayerSpriteHalfWidth then MissileSkipPlayer1
          if temp2 + MissileAABBSize<= playerX[1] then MissileSkipPlayer1
          if temp3>= playerY[1] + PlayerSpriteHeight then MissileSkipPlayer1
          if temp3 + MissileAABBSize<= playerY[1] then MissileSkipPlayer1
          let temp4  = 1 : return
          rem Hit Player 2
MissileSkipPlayer1
          
          rem Check Player 3 (index 2)
          if temp1  = 2 then MissileSkipPlayer2
          if playerHealth[2] = 0 then MissileSkipPlayer2
          if temp2>= playerX[2] + PlayerSpriteHalfWidth then MissileSkipPlayer2
          if temp2 + MissileAABBSize<= playerX[2] then MissileSkipPlayer2
          if temp3>= playerY[2] + PlayerSpriteHeight then MissileSkipPlayer2
          if temp3 + MissileAABBSize<= playerY[2] then MissileSkipPlayer2
          let temp4  = 2 : return
          rem Hit Player 3
MissileSkipPlayer2
          
          rem Check Player 4 (index 3)
          if temp1  = 3 then MissileSkipPlayer3
          if playerHealth[3] = 0 then MissileSkipPlayer3
          if temp2>= playerX[3] + PlayerSpriteHalfWidth then MissileSkipPlayer3
          if temp2 + MissileAABBSize<= playerX[3] then MissileSkipPlayer3
          if temp3>= playerY[3] + PlayerSpriteHeight then MissileSkipPlayer3
          if temp3 + MissileAABBSize<= playerY[3] then MissileSkipPlayer3
          let temp4  = 3 : return
          rem Hit Player 4
MissileSkipPlayer3
          
          return

          rem =================================================================
          rem HANDLE MISSILE HIT
          rem =================================================================
          rem Processes a missile hitting a player.
          rem Applies damage, knockback, and visual/audio feedback.

          rem INPUT:
          rem   temp1 = attacker player index (0-3, missile owner)
          rem   temp4 = defender player index (0-3, hit player)
HandleMissileHit
          rem Get character type for damage calculation
          let temp5  = playerChar[temp1]
          
          rem Apply damage from attacker to defender
          rem Use playerDamage array for base damage amount
          let temp6  = playerDamage[temp1]
          
          rem Apply dive damage bonus for Harpy
          if temp5 = 6 then HarpyCheckDive
          goto DiveCheckDone
HarpyCheckDive
          rem Check if Harpy is in dive mode
          if (characterStateFlags[temp1] & 4) = 0 then DiveCheckDone
          rem Not diving, skip bonus
          rem Apply 1.5x damage for diving attacks (temp6 + temp6/2 = 1.5 * temp6)
          rem Divide by 2 using bit shift right 1 bit
          dim HMS_temp6Half = temp7
          let HMS_temp6Half = temp6
          asm
            lsr HMS_temp6Half
          end
          let temp6 = temp6 + HMS_temp6Half
DiveCheckDone
          
          rem Guard check is now handled before HandleMissileHit is called
          rem This function only handles damage application
          
          rem Apply damage
          let oldHealthValue = playerHealth[temp4]
          let playerHealth[temp4] = playerHealth[temp4] - temp6
          if playerHealth[temp4] > oldHealthValue then playerHealth[temp4] = 0
          
          rem Apply knockback (weight-based scaling - heavier characters resist more)
          rem Calculate direction: if missile moving right, push defender right
          let temp2  = missileX[temp1]
          
          rem Calculate weight-based knockback scaling
          rem Heavier characters resist knockback more (max weight = 100)
          let characterWeight = playerChar[temp4]
          rem Get character index
          let characterWeight = CharacterWeights[characterWeight]
          rem Get character weight (5-100) - overwrite with weight value
          rem Calculate scaled knockback: KnockbackImpulse * (100 - weight) / 100
          rem Approximate: (KnockbackImpulse * (100 - weight)) / 100
          rem For KnockbackImpulse = 4: scaled = (4 * (100 - weight)) / 100
          rem Simplify to avoid division: if weight < 50, use full knockback; else scale down
          if characterWeight >= 50 then WeightBasedKnockbackScale
          rem Light characters (weight < 50): full knockback
          let impulseStrength = KnockbackImpulse
          goto WeightBasedKnockbackApply
WeightBasedKnockbackScale
          rem Heavy characters (weight >= 50): reduced knockback
          rem Calculate: KnockbackImpulse * (100 - weight) / 100
          rem KnockbackImpulse = 4, so: 4 * (100 - weight) / 100
          rem Multiply first: 4 * velocityCalculation using bit shift (ASL 2)
          let velocityCalculation = 100 - characterWeight
          rem Resistance factor (0-50 for weights 50-100)
          let impulseStrength = velocityCalculation
          rem Multiply by 4 (KnockbackImpulse = 4) using left shift 2 bits
          asm
            asl impulseStrength
            asl impulseStrength
          end
          rem Divide by 100 using DivideBy100 helper
          let temp2 = impulseStrength
          gosub DivideBy100
          let impulseStrength = temp2
          rem Scaled knockback (0, 1, or 2)
          if impulseStrength = 0 then impulseStrength = 1
          rem Minimum 1 pixel knockback even for heaviest characters
WeightBasedKnockbackApply
          rem Apply scaled knockback impulse to velocity (not momentum)
          if temp2 < playerX[temp4] then let playerVelocityX[temp4] = playerVelocityX[temp4] + impulseStrength : let playerVelocityX_lo[temp4] = 0 : goto KnockbackDone 
          rem Missile from left, push right (positive velocity)
          let playerVelocityX[temp4] = playerVelocityX[temp4] - impulseStrength
          rem Missile from right, push left (negative velocity)
          let playerVelocityX_lo[temp4] = 0
          rem Zero subpixel when applying knockback impulse
KnockbackDone
          
          rem Set recovery/hitstun frames
          let playerRecoveryFrames[temp4] = HitstunFrames
          rem 10 frames of hitstun
          
          rem Synchronize playerState bit 3 with recovery frames
          let playerState[temp4] = playerState[temp4] | 8
          rem Set bit 3 (recovery flag) when recovery frames are set
          
          rem Play hit sound effect
          let temp1  = SoundHit
          gosub bank15 PlaySoundEffect
          
          rem Spawn damage indicator visual
          rem NOTE: VisualEffects.bas was phased out - damage indicators handled inline
          
          return

          rem =================================================================
          rem HANDLE MISSILE BOUNCE
          rem =================================================================
          rem Handles wall bounce for missiles with bounce flag set.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp5 = missile flags
HandleMissileBounce
          let missileVelocityX = missileVelX[temp1]
          rem Get current X velocity
          let missileVelocityX = MaxByteValue - missileVelocityX + 1
          rem Invert velocity (bounce back) using two's complement
          
          rem Apply friction damping if friction flag is set
          if !(temp5 & MissileFlagFriction) then BounceDone
          rem Multiply by bounce multiplier for friction missiles
          if missileVelocityX > 0 then BounceMultiply
          let missileVelocityX = missileVelocityX + (missileVelocityX / BounceDampenDivisor)
          goto BounceDone
BounceMultiply
          let missileVelocityX = missileVelocityX - (missileVelocityX / BounceDampenDivisor)
BounceDone
          let missileVelX[temp1] = missileVelocityX
          
          rem Continue bouncing (don’t deactivate)
          return

          rem =================================================================
          rem DEACTIVATE MISSILE
          rem =================================================================
          rem Removes a missile from active status.

          rem INPUT:
          rem   temp1 = player index (0-3)
DeactivateMissile
          rem Clear active bit for this player missile
          let temp6  = 1
          if temp1 = 1 then temp6  = 2
          if temp1 = 2 then temp6  = 4
          if temp1 = 3 then temp6  = 8
          let temp6 = MaxByteValue - temp6
          rem Invert bits
          let missileActive  = missileActive & temp6
          return

          rem =================================================================
          rem RENDER ALL MISSILES
          rem =================================================================
          rem NOTE: Missile rendering is now handled in SetSpritePositions (PlayerRendering.bas)
          rem This function is kept for compatibility but does nothing
          rem The multisprite kernel only provides 2 hardware missiles (missile0, missile1)
          rem In 2-player mode: missile0 = Player 0, missile1 = Player 1 (no multiplexing)
          rem In 4-player mode: Frame multiplexing handles 4 logical missiles:
          rem   Even frames: missile0 = Player 0, missile1 = Player 1
          rem   Odd frames:  missile0 = Player 2, missile1 = Player 3
RenderAllMissiles
          rem Missile positions are set in SetSpritePositions (PlayerRendering.bas)
          rem which handles 2-player vs 4-player mode automatically
          rem No additional rendering needed here
          return
