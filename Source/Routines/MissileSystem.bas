          rem ChaosFight - Source/Routines/MissileSystem.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem MISSILE SYSTEM - 4-player MISSILE MANAGEMENT
          rem Manages up to 4 simultaneous missiles/attack visuals (one
          rem   per player).
          rem Each player can have ONE active missile at a time, which
          rem   can be:

GetPlayerMissileBitFlag
          rem   - Ranged projectile (bullet, arrow, magic spell)
          rem   - Melee attack visual (sword, fist, kick sprite)
          rem MISSILE VARIABLES (from Variables.bas):
          rem   missileX[0-3] (a-d) - X positions
          rem   missileY[0-3] (w-z) - Y positions
          rem missileActive (i) - Bit flags for which missiles are
          rem   active
          rem   missileLifetime (e,f) - Packed nybble counters
          rem     e{7:4} = Player 1 lifetime, e{3:0} = Player 2 lifetime
          rem     f{7:4} = Player 3 lifetime, f{3:0} = Player 4 lifetime
          rem Values: 0-13 = frame count, 14 = until collision, 15 =
          rem   until off-screen
          rem TEMP VARIABLE USAGE:
          rem   temp1 = player index (0-3) being processed
          rem   temp2 = missileX delta (momentum/velocity)
          rem   temp3 = missileY delta (momentum/velocity)
          rem temp4 = scratch for collision checks / flags / target
          rem
          rem   player
          rem temp5 = scratch for character data lookups / missile flags
          rem   temp6 = scratch for bit manipulation / collision bounds
          rem Get Player Missile Bit Flag
          rem Input: temp1 = player index (0-3)
          rem Output: temp6 = bit flag (1, 2, 4, or 8)
          rem Mutates: temp6 (return value)
          rem
          rem Called Routines: None
          rem Constraints: None
          rem Calculate bit flag using O(1) array lookup:
          rem BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1]
          return

SpawnMissile
          rem
          rem Spawn Missile
          rem Creates a new missile/attack visual for a player.
          rem Called when player presses attack button.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem PROCESS:
          rem   1. Look up character type for this player
          rem   2. Read missile properties from character data
          rem 3. Set missile X/Y based on player position, facing, and
          rem   emission height
          rem   4. Set active bit for this player missile
          rem   5. Initialize lifetime counter from character data
          rem Creates a new missile/attack visual for a player at spawn
          rem position with initial velocity
          rem
          rem Input: temp1 = player index (0-3), playerCharacter[] (global
          rem array) = character types, playerX[], playerY[] (global
          rem arrays) = player positions, playerState[] (global array) =
          rem player states (facing direction),
          rem CharacterMissileEmissionHeights[],
          rem CharacterMissileSpawnOffsetLeft[],
          rem CharacterMissileSpawnOffsetRight[],
          rem CharacterMissileLifetime[], CharacterMissileMomentumX[],
          rem CharacterMissileMomentumY[], CharacterMissileWidths[]
          rem (global data tables) = missile properties,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags (for Harpy dive mode), CharacterMissileSpawnOffsetLeft[],
          rem CharacterMissileSpawnOffsetRight[] = spawn
          rem offsets, PlayerStateBitFacing (global constant) = facing
          rem bit mask
          rem
          rem Output: Missile spawned at correct position with initial
          rem velocity and lifetime
          rem
          rem Mutates: temp1-temp6 (used for calculations), missileX[],
          rem missileY_W[] (global arrays) = missile positions,
          rem missileActive (global) = missile active flags,
          rem missileLifetime[] (global array) = missile lifetime
          rem counters, missileVelocityX[], missileVelocityY[] (global
          rem arrays) = missile velocities, missileNUSIZ[] (global
          rem array) = missile size registers
          rem
          rem Called Routines: GetPlayerMissileBitFlag - calculates bit
          rem flag for missile active tracking
          rem
          rem Constraints: Only one missile per player at a time. Harpy
          rem dive mode increases downward velocity by 50%
          let temp5 = playerCharacter[temp1]
          rem Get character type for this player
          
          let temp6 = CharacterMissileEmissionHeights[temp5]
          rem Read missile emission height from character data table
          
          rem Calculate initial missile position based on player
          rem   position and facing
          rem Facing is stored in playerState bit 0: 0=left, 1=right
          let temp4 = playerState[temp1] & PlayerStateBitFacing
          rem Get facing direction
          
          let missileX[temp1] = playerX[temp1]
          rem Set missile position using array access (write to _W port)
          let missileY_W[temp1] = playerY[temp1] + temp6
          if temp4 = 0 then let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetLeft[temp5]
          rem Facing left, spawn left
          if temp4 = 1 then let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetRight[temp5]
          rem Facing right, spawn right
          
          rem Set active bit for this player missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          gosub GetPlayerMissileBitFlag
          let missileActive  = missileActive | temp6
          
          let missileLifetimeValue_W = CharacterMissileLifetime[temp5]
          rem Initialize lifetime counter from character data table
          
          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile
          let missileLifetime_W[temp1] = missileLifetimeValue_R
          rem   lifetime
          
          rem Initialize velocity from character data for friction
          let temp6 = CharacterMissileMomentumX[temp5]
          rem   physics
          rem Get base X velocity
          if temp4 = 0 then temp6 = 0 - temp6
          let missileVelocityX[temp1] = temp6
          rem Apply facing direction (left = negative)
          
          rem Optimized: Calculate NUSIZ value with formula instead of if-chain
          rem NUSIZ bits 4-6: width 1=0x00, 2=0x10, 4=0x20 → (width-1)*16
          let temp2 = CharacterMissileWidths[temp5]
          let missileNUSIZ_W[temp1] = (temp2 - 1) * 16
          
          let temp6 = CharacterMissileMomentumY[temp5]
          rem Get Y velocity
          
          rem Apply Harpy dive velocity bonus if in dive mode
          
          if temp5 = 6 then HarpyCheckDiveVelocity
          goto VelocityDone
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
          rem Output: Velocity increased by 50% (velocity + velocity/2)
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
            sta velocityCalculation_W
end
          let temp6 = temp6 + velocityCalculation_R
VelocityDone
          let missileVelocityY[temp1] = temp6
          
          return

UpdateAllMissiles
          rem
          rem Update All Missiles
          rem Called once per frame to update all active missiles.
          rem Updates position, checks collisions, handles lifetime.
          rem Updates all active missiles (called once per frame)
          rem
          rem Input: None (processes all players 0-3)
          rem
          rem Output: All active missiles updated (position, velocity,
          rem lifetime, collisions)
          rem
          rem Mutates: All missile state (via UpdateOneMissile for each
          rem player)
          rem
          rem Called Routines: UpdateOneMissile (for each player 0-3)
          rem
          rem Constraints: None
          rem Optimized: Loop through all player missiles instead of individual calls
          for temp1 = 0 to 3
            gosub UpdateOneMissile
          next
          return

UpdateOneMissile
          rem
          rem Update One Missile
          rem Updates a single player missile.
          rem Handles movement, gravity, collisions, and lifetime.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem Updates a single player missile (movement, gravity,
          rem friction, collisions, lifetime)
          rem
          rem Input: temp1 = player index (0-3), missileActive (global)
          rem = missile active flags, missileVelocityX[],
          rem missileVelocityY[] (global arrays) = missile velocities,
          rem missileX[], missileY_R[] (global arrays) = missile
          rem positions, playerCharacter[] (global array) = character types,
          rem playerState[] (global array) = player states, playerX[],
          rem playerY[] (global arrays) = player positions, BitMask[]
          rem (global data table) = bit masks, MissileFlagGravity,
          rem MissileFlagFriction, MissileFlagHitBackground,
          rem MissileFlagBounce (global constants) = missile flags,
          rem GravityPerFrame, CurlingFrictionCoefficient,
          rem MinimumVelocityThreshold (global constants) = physics
          rem constants, ScreenBottom, ScreenTopWrapThreshold (global
          rem constants) = screen bounds, MissileLifetimeInfinite,
          rem MissileHitNotFound (global constants) = missile constants,
          rem CharacterMegax, CharacterKnightGuy (global constants) = character
          rem indices, SoundGuardBlock (global constant) = sound effect
          rem ID
          rem
          rem Output: Missile updated (position, velocity, lifetime),
          rem collisions checked, missile deactivated if expired or
          rem off-screen
          rem
          rem Mutates: temp1-temp6 (used for calculations), missileX[],
          rem missileY_W[] (global arrays) = missile positions,
          rem missileVelocityX[], missileVelocityY[] (global arrays) =
          rem missile velocities, missileActive (global) = missile
          rem active flags (via DeactivateMissile), missileLifetime[]
          rem (global array) = missile lifetime counters, soundEffectID
          rem (global) = sound effect ID (via guard bounce)
          rem
          rem Called Routines: GetPlayerMissileBitFlag - calculates bit
          rem flag, GetMissileFlags (bank12) - gets missile flags,
          rem HandleMegaxMissile - handles Megax stationary missile,
          rem HandleKnightGuyMissile - handles Knight Guy sword swing,
          rem MissileCollPF (bank7) - checks playfield collision,
          rem CheckAllMissileCollisions (bank7) - checks player
          rem collisions, PlaySoundEffect (bank15) - plays guard bounce
          rem sound, HandleMissileBounce - handles bounce physics,
          rem HandleMissileHit - handles damage application,
          rem DeactivateMissile - deactivates missile
          rem
          rem Constraints: Special handling for Megax (stationary) and
          rem Knight Guy (sword swing). Missiles wrap horizontally,
          rem deactivate if off-screen vertically. Guard bounce reduces
          rem velocity by 25%
          rem Check if this missile is active
          gosub GetPlayerMissileBitFlag
          let temp4 = missileActive & temp6
          if temp4  = 0 then return
          rem Not active, skip
          
          rem Preserve player index since GetMissileFlags uses temp1
          rem Use temp6 temporarily to save player index (temp6 is used
          let temp6 = temp1
          rem   for bit flags)
          rem Save player index temporarily
          
          let temp2 = missileVelocityX[temp1]
          rem Get current velocities from stored arrays
          let temp3 = missileVelocityY[temp1]
          rem X velocity (already facing-adjusted from spawn)
          rem Y velocity
          
          let temp5 = playerCharacter[temp1]
          rem Read missile flags from character data
          let temp1 = temp5
          rem Get character index
          gosub GetMissileFlags bank12
          rem Use temp1 for flags lookup (temp1 will be overwritten)
          let temp5 = temp2
          rem Store flags
          
          let temp1 = temp6
          rem Restore player index and get flags back
          rem Restore player index
          
          rem Special handling for Megax (character 5): stationary fire
          rem breath visual
          rem Megax missile stays adjacent to player during attack, no movement
          if temp5 = CharacterMegax then goto HandleMegaxMissile
          
          rem Special handling for Knight Guy (character 7): sword swing
          rem visual
          rem Knight Guy missile appears overlapping, moves away, returns, then vanishes
          if temp5 = CharacterKnightGuy then goto HandleKnightGuyMissile
          
          rem Apply gravity if flag is set
          
          if !(temp5 & MissileFlagGravity) then GravityDone
          let temp3 = temp3 + GravityPerFrame
          let missileVelocityY[temp1] = temp3
          rem Add gravity (1 pixel/frame down)
GravityDone
          rem Update stored Y velocity
          
          rem Apply friction if flag is set (curling stone deceleration
          rem with coefficient)
          if !(temp5 & MissileFlagFriction) then FrictionDone
          let missileVelocityXCalc_W = missileVelocityX[temp1]
          rem Get current X velocity
          
          rem Apply ice-like friction: reduce by
          rem   CurlingFrictionCoefficient/256 per frame
          rem CurlingFrictionCoefficient = 4 (Q8 fixed-point: 4/256 =
          rem   1.56% per frame)
          rem Derived from constant: reduction = velocity / (256 /
          rem CurlingFrictionCoefficient) = velocity / 64
          if missileVelocityXCalc_R = 0 then FrictionDone
          rem Zero velocity, no friction to apply
          
          rem Calculate friction reduction (velocity / 64, approximates
          let velocityCalculation_W = missileVelocityXCalc_R
          rem   1.56% reduction)
          rem Check if velocity is negative (twos complement: values >
          rem   127 are negative)
          rem For unsigned bytes, negative values in twos complement
          rem are 128-255
          if velocityCalculation_R > 127 then FrictionNegative
          rem Positive velocity
          rem Divide by 64 using bit shift (6 right shifts) - derived
          rem   from CurlingFrictionCoefficient
          asm
            lda velocityCalculation_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta velocityCalculation_W
end
          let missileVelocityXCalc_W = missileVelocityXCalc_R - velocityCalculation_R
          rem Reduce by 1/64 (1.56% - ice-like friction)
          goto FrictionApply
FrictionNegative
          let velocityCalculation_W = 0 - velocityCalculation_R
          rem Negative velocity - convert to positive for division
          rem Divide by 64 using bit shift (6 right shifts) - derived
          rem   from CurlingFrictionCoefficient
          asm
            lda velocityCalculation_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta velocityCalculation_W
end
          let missileVelocityXCalc_W = missileVelocityXCalc_R + velocityCalculation_R
          rem Reduce by 1/64 (1.56% - ice-like friction)
FrictionApply
          rem Add back (since missileVelocityXCalc was negative)
          let missileVelocityX[temp1] = missileVelocityXCalc_R
          let temp2 = missileVelocityXCalc_R
          rem Update temp2 for position calculation
          rem Check if velocity dropped below threshold
          rem tail call
          if missileVelocityXCalc_R < MinimumVelocityThreshold && missileVelocityXCalc_R > -MinimumVelocityThreshold then goto DeactivateMissile
          let missileVelocityX[temp1] = missileVelocityXCalc_R
          rem Update stored X velocity with friction applied
FrictionDone
          
          rem Update missile position
          let missileX[temp1] = missileX[temp1] + temp2
          rem Read-Modify-Write: Read from _R, modify, write to _W
          let temp4 = missileY_R[temp1]
          let temp4 = temp4 + temp3
          let missileY_W[temp1] = temp4
          
          rem Check screen bounds and wrap around horizontally
          rem Missiles wrap around horizontally like players (all
          rem arenas)
          let temp2 = missileX[temp1]
          rem Get missile X/Y position (read from _R port)
          let temp3 = missileY_R[temp1]
          
          rem Wrap around horizontally using shared player thresholds
          if temp2 < PlayerLeftWrapThreshold then temp2 = PlayerRightEdge : let missileX[temp1] = PlayerRightEdge
          rem Off left edge, wrap to right
          if temp2 > PlayerRightWrapThreshold then temp2 = PlayerLeftEdge : let missileX[temp1] = PlayerLeftEdge
          rem Off right edge, wrap to left
          
          rem Check vertical bounds (deactivate if off top/bottom, like
          let temp4 = 0
          rem   players are clamped)
          if temp3 > ScreenBottom then temp4  = 1
          rem Off bottom, deactivate
          rem Byte-safe top bound: if wrapped past 0 due to subtract,
          let temp5 = temp3
          rem   temp3 will be > original
          rem Assuming prior update may have subtracted from temp3
          rem earlier in loop
          if temp3 > ScreenTopWrapThreshold then temp4  = 1
          rem Off top, deactivate
          if temp4 then goto DeactivateMissile
          rem Off-screen vertically, deactivate
          
          rem Check collision with playfield if flag is set
          rem Reload missile flags (temp5 was overwritten with Y
          let temp5 = playerCharacter[temp1]
          rem   position above)
          let temp1 = temp5
          gosub GetMissileFlags bank12
          let temp5 = temp2
          rem temp5 now contains missile flags again
          rem Restore player index for MissileCollPF
          if !(temp5 & MissileFlagHitBackground) then PlayfieldCollisionDone
          gosub MissileCollPF bank7
          if !temp4 then PlayfieldCollisionDone
          rem Collision detected - check if should bounce or deactivate
          if temp5 & MissileFlagBounce then goto HandleMissileBounceTail
          rem Bounced - continue moving (HandleMissileBounce returns)
          goto DeactivateMissile
PlayfieldCollisionDone
          rem No bounce - deactivate on background hit
          
          rem Check collision with players
          gosub CheckAllMissileCollisions bank7
          rem This handles both visible missiles and AOE attacks
          rem Check if hit was found (temp4 != MissileHitNotFound)
          if temp4 = MissileHitNotFound then MissileSystemNoHit
          
          rem Check if hit player is guarding before handling hit
          let temp6 = playerState[temp4] & 2
          rem temp4 contains hit player index
          if temp6 then GuardBounceFromCollision
          goto HandleMissileDamage
          rem Guarding - bounce instead of damage
GuardBounceFromCollision
          rem Guarding player - bounce the curling stone
          let soundEffectID_W = SoundGuardBlock
          rem Play guard sound
          gosub PlaySoundEffect bank15
          
          rem Bounce the missile: invert X velocity and apply friction
          let temp6 = missileVelocityX[temp1]
          rem   damping
          let temp6 = 0 - temp6
          rem Invert X velocity (bounce back)
          rem Apply friction damping on bounce (reduce by 25% for guard
          rem   bounce)
          rem Divide by 4 using bit shift (2 right shifts)
          let temp2 = temp6
          rem Copy to temp2 for shift
          asm
            lsr temp2
            lsr temp2
end
          let velocityCalculation_W = temp2
          let temp6 = temp6 - velocityCalculation_R
          let missileVelocityX[temp1] = temp6
          rem Reduce bounce velocity by 25%
          
          rem Continue without deactivating - missile bounces and
          goto MissileSystemNoHit
          rem   continues
          
HandleMissileDamage
          gosub HandleMissileHit
          rem HandleMissileHit applies damage and effects
          goto DeactivateMissile
          rem tail call
MissileSystemNoHit
          rem Missile disappears after hitting player
          
          rem Decrement lifetime counter and check expiration
          let missileLifetimeValue_W = missileLifetime_R[temp1]
          rem Retrieve current lifetime for this missile
          
          rem Decrement if not set to infinite (infinite until
          rem collision)
          if missileLifetimeValue_R = MissileLifetimeInfinite then MissileUpdateComplete
          let missileLifetimeValue_W = missileLifetimeValue_R - 1
          rem tail call
          if missileLifetimeValue_R = 0 then goto DeactivateMissile
          let missileLifetime_W[temp1] = missileLifetimeValue_R
MissileUpdateComplete
          
          return

HandleMissileBounceTail
          gosub HandleMissileBounce
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
          
          let temp4 = playerState[temp1] & PlayerStateBitFacing
          rem Get facing direction (bit 0: 0=left, 1=right)
          
          let temp5 = CharacterMissileEmissionHeights[temp5]
          rem Get emission height from character data
          
          rem Lock missile position to player position (adjacent, no
          rem movement)
          let temp2 = playerX[temp1]
          rem Calculate X position based on player position and facing
          if temp4 = 0 then temp2 = temp2 + CharacterMissileSpawnOffsetLeft[temp5]
          rem Facing left, spawn left
          if temp4 = 1 then temp2 = temp2 + CharacterMissileSpawnOffsetRight[temp5]
          rem Facing right, spawn right
          
          let temp3 = playerY[temp1] + temp5
          rem Calculate Y position (player Y + emission height)
          
          let missileX[temp1] = temp2
          rem Update missile position (locked to player)
          let missileY_W[temp1] = temp3
          
          let missileVelocityX[temp1] = 0
          rem Zero velocities to prevent any movement
          let missileVelocityY[temp1] = 0
          
          rem Check if attack animation is complete
          rem Animation state is in bits 4-7 of playerState
          rem ActionAttackExecute = 14 (0xE)
          let temp6 = playerState[temp1]
          rem Extract animation state (bits 4-7)
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
          goto DeactivateMissile
          rem Attack complete - deactivate missile
          
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
          
          let temp4 = playerState[temp1] & PlayerStateBitFacing
          rem Get facing direction (bit 0: 0=left, 1=right)
          
          let temp5 = CharacterMissileEmissionHeights[temp5]
          rem Get emission height from character data
          
          rem Check if attack animation is complete
          let temp6 = playerState[temp1]
          rem Extract animation state (bits 4-7)
          rem Extract animation state (bits 4-7) using bit shift
          asm
            lsr temp6
            lsr temp6
            lsr temp6
            lsr temp6
end
          rem If animation state is not ActionAttackExecute (14), attack is complete
          if temp6 = 14 then KnightGuyAttackActive
          goto DeactivateMissile
          rem Attack complete - deactivate missile
          
KnightGuyAttackActive
          rem Get current animation frame within Execute sequence (0-7)
          let velocityCalculation_W = currentAnimationFrame_R[temp1]
          rem Read from SCRAM and calculate offset immediately
          
          rem Calculate sword swing offset based on animation frame
          rem Frames 0-3: Move away from player (sword swing out)
          rem Frames 4-7: Return to start (sword swing back)
          rem Maximum swing distance: 4 pixels
          if velocityCalculation_R < 4 then KnightGuySwingOut
          rem Frames 4-7: Returning to start
          rem Calculate return offset: (7 - frame) pixels
          rem Frame 4: 3 pixels away, Frame 5: 2 pixels, Frame 6: 1
          rem pixel, Frame 7: 0 pixels
          let velocityCalculation_W = 7 - velocityCalculation_R
          goto KnightGuySetPosition
          
KnightGuySwingOut
          rem Frames 0-3: Moving away from player
          rem Calculate swing offset: (frame + 1) pixels
          let velocityCalculation_W = velocityCalculation_R + 1
          rem Frame 0: 1 pixel, Frame 1: 2 pixels, Frame 2: 3 pixels, Frame 3: 4 pixels
          
KnightGuySetPosition
          rem Calculate base X position (partially overlapping player)
          rem Start position: player X + 8 pixels (halfway through
          rem player sprite)
          let temp2 = playerX[temp1] + 8
          rem Then apply swing offset in facing direction
          rem Base position: center of player sprite
          
          rem Apply swing offset in facing direction
          
          if temp4 = 0 then KnightGuySwingLeft
          let temp2 = temp2 + velocityCalculation_R
          rem Facing right: move right (positive offset)
          goto KnightGuySetY
          
KnightGuySwingLeft
          let temp2 = temp2 - velocityCalculation_R
          rem Facing left: move left (negative offset)
          
KnightGuySetY
          let temp3 = playerY[temp1] + temp5
          rem Calculate Y position (player Y + emission height)
          
          let missileX[temp1] = temp2
          rem Update missile position
          let missileY_W[temp1] = temp3
          
          rem Zero velocities to prevent projectile movement
          rem   frame
          let missileVelocityX[temp1] = 0
          rem Position is updated directly each frame based on animation
          let missileVelocityY[temp1] = 0
          
          rem Skip normal movement and collision checks
          return

CheckMissileBounds
          rem
          rem Check Missile Bounds
          rem Checks if missile is off-screen.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = 1 if off-screen, 0 if on-screen
          return
MissileSysPF
          rem Checks if missile is off-screen (currently
          rem incomplete/unused)
          rem
          rem Input: temp1 = player index (0-3)
          rem
          rem Output: temp4 = 1 if off-screen, 0 if on-screen (not
          rem implemented)
          rem
          rem Mutates: None (incomplete)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Currently incomplete/unused - bounds checking
          rem handled inline in UpdateOneMissile
          rem Get missile X/Y position (read from _R port)
          rem
          rem Check Missile-playfield Collision
          rem Checks if missile hit the playfield (walls, obstacles).
          rem Uses pfread to check playfield pixel at missile position.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = 1 if hit playfield, 0 if clear
          rem Checks if missile hit the playfield (walls, obstacles)
          rem using pfread
          rem
          rem Input: temp1 = player index (0-3), missileX[] (global
          rem array) = missile X positions, missileY_R[] (global SCRAM
          rem array) = missile Y positions
          rem
          rem Output: temp4 = 1 if hit playfield, 0 if clear, temp6 =
          rem playfield column (0-31)
          rem
          rem Mutates: temp2-temp6 (used for calculations)
          rem
          rem Called Routines: Div5Compute - converts X pixel to
          rem playfield column
          rem
          rem Constraints: Uses pfread to check playfield pixel at
          rem missile position. X coordinate divided by 5 to get column
          rem (0-31)
          let temp2 = missileX[temp1]
          rem Get missile X/Y position (read from _R port)
          let temp3 = missileY_R[temp1]
          
          rem Convert X/Y to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160), 192 pixels
          rem   tall
          rem pfread uses playfield coordinates: column (0-31), row
          gosub Div5Compute
          rem   (0-11 or 0-31 depending on pfres)
          rem Convert X pixel to playfield column (160/32 = 5)
          rem temp3 is already in pixel coordinates, pfread will handle
          rem   it
          
          rem Check if playfield pixel is set
          let temp4 = 0
          rem pfread can only be used in if/then conditionals
          if pfread(temp6, temp3) then temp4 = 1 : return
          rem Default: no collision detected
          return

Div5Compute
          rem Div5Compute: compute floor(temp2/5) into temp6 via
          rem   repeated subtraction
          rem Helper: Computes floor(temp2/5) into temp6 via repeated
          rem subtraction
          rem
          rem Input: temp2 = value to divide by 5
          rem
          rem Output: temp6 = floor(temp2/5), temp2 = temp2 mod 5
          rem (remainder)
          rem
          rem Mutates: temp2 (reduced by multiples of 5), temp6 (result)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for playfield coordinate
          rem conversion, uses repeated subtraction (no division
          rem support)
          let temp6 = 0
          if temp2 < 5 then return
Div5Loop
          let temp2 = temp2 - 5
          let temp6 = temp6 + 1
          if temp2>= 5 then Div5Loop
          return

CheckMissilePlayerCollision
          rem
          rem Check Missile-player Collision
          rem Checks if a missile hit any player (except the owner).
          rem Uses axis-aligned bounding box (AABB) collision detection.
          rem
          rem INPUT:
          rem   temp1 = missile owner player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
          rem Checks if missile hit any player (except owner) using AABB
          rem collision detection
          rem
          rem Input: temp1 = missile owner player index (0-3),
          rem missileX[] (global array) = missile X positions,
          rem missileY_R[] (global SCRAM array) = missile Y positions,
          rem playerX[], playerY[] (global arrays) = player positions,
          rem playerHealth[] (global array) = player health,
          rem MissileAABBSize, PlayerSpriteHalfWidth, PlayerSpriteHeight
          rem (global constants) = collision bounds, MissileHitNotFound
          rem (global constant) = no hit value (255)
          rem
          rem Output: temp4 = hit player index (0-3), or
          rem MissileHitNotFound (255) if no hit
          rem
          rem Mutates: temp2-temp4 (used for calculations)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Skips owner player and eliminated players
          rem (health = 0). Uses axis-aligned bounding box (AABB)
          rem collision detection
          let temp2 = missileX[temp1]
          rem Get missile X/Y position (read from _R port)
          let temp3 = missileY_R[temp1]
          
          rem Missile bounding box
          rem temp2 = missile left, temp2+MissileAABBSize = missile
          rem   right
          rem temp3 = missile top, temp3+MissileAABBSize = missile
          rem   bottom
          
          let temp4 = MissileHitNotFound
          rem Check collision with each player (except owner)
          rem Default: no hit
          
          rem Check Player 1 (index 0)
          
          if temp1  = 0 then MissileDonePlayer0
          if playerHealth[0] = 0 then MissileDonePlayer0
          if temp2>= playerX[0] + PlayerSpriteHalfWidth then MissileDonePlayer0
          if temp2 + MissileAABBSize<= playerX[0] then MissileDonePlayer0
          if temp3>= playerY[0] + PlayerSpriteHeight then MissileDonePlayer0
          if temp3 + MissileAABBSize<= playerY[0] then MissileDonePlayer0
          let temp4 = 0
          goto MissileCollisionReturn
MissileDonePlayer0
          rem Hit Player 1
          
          rem Check Player 2 (index 1)
          
          if temp1  = 1 then MissileDonePlayer1
          if playerHealth[1] = 0 then MissileDonePlayer1
          if temp2>= playerX[1] + PlayerSpriteHalfWidth then MissileDonePlayer1
          if temp2 + MissileAABBSize<= playerX[1] then MissileDonePlayer1
          if temp3>= playerY[1] + PlayerSpriteHeight then MissileDonePlayer1
          if temp3 + MissileAABBSize<= playerY[1] then MissileDonePlayer1
          let temp4 = 1
          goto MissileCollisionReturn
MissileDonePlayer1
          rem Hit Player 2
          
          rem Check Player 3 (index 2)
          
          if temp1  = 2 then MissileDonePlayer2
          if playerHealth[2] = 0 then MissileDonePlayer2
          if temp2>= playerX[2] + PlayerSpriteHalfWidth then MissileDonePlayer2
          if temp2 + MissileAABBSize<= playerX[2] then MissileDonePlayer2
          if temp3>= playerY[2] + PlayerSpriteHeight then MissileDonePlayer2
          if temp3 + MissileAABBSize<= playerY[2] then MissileDonePlayer2
          let temp4 = 2
          goto MissileCollisionReturn
MissileDonePlayer2
          rem Hit Player 3
          
          rem Check Player 4 (index 3)
          
          if temp1  = 3 then MissileDonePlayer3
          if playerHealth[3] = 0 then MissileDonePlayer3
          if temp2>= playerX[3] + PlayerSpriteHalfWidth then MissileDonePlayer3
          if temp2 + MissileAABBSize<= playerX[3] then MissileDonePlayer3
          if temp3>= playerY[3] + PlayerSpriteHeight then MissileDonePlayer3
          if temp3 + MissileAABBSize<= playerY[3] then MissileDonePlayer3
          let temp4 = 3
          goto MissileCollisionReturn
MissileDonePlayer3
          rem Hit Player 4
          
MissileCollisionReturn
          return

HandleMissileHit
          rem
          rem Handle Missile Hit
          rem Processes a missile hitting a player.
          rem Applies damage, knockback, and visual/audio feedback.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3, missile owner)
          rem   temp4 = defender player index (0-3, hit player)
          rem Processes missile hitting a player (damage, knockback,
          rem hitstun, sound)
          rem
          rem Input: temp1 = attacker player index (0-3, missile owner),
          rem temp4 = defender player index (0-3, hit player),
          rem playerCharacter[] (global array) = character types,
          rem playerDamage[] (global array) = damage values,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags (for Harpy dive mode), missileX[] (global
          rem array) = missile X positions, playerX[], playerY[] (global
          rem arrays) = player positions, CharacterWeights[] (global
          rem data table) = character weights, KnockbackImpulse,
          rem HitstunFrames (global constants) = physics constants,
          rem SoundAttackHit (global constant) = sound effect ID
          rem
          rem Output: Damage applied, knockback applied (weight-based),
          rem hitstun set, sound played
          rem
          rem Mutates: temp1-temp6 (used for calculations),
          rem playerHealth[] (global array) = player health
          rem (decremented), playerVelocityX[], playerVelocityXL[]
          rem (global arrays) = player velocities (knockback applied),
          rem playerRecoveryFrames[] (global array) = recovery frames
          rem (set to HitstunFrames), playerState[] (global array) =
          rem player states (recovery flag set), soundEffectID (global)
          rem = sound effect ID
          rem
          rem Called Routines: PlaySoundEffect (bank15) - plays hit
          rem sound
          rem
          rem Constraints: Harpy dive mode increases damage by 50%.
          rem Knockback scales with character weight (heavier = less
          rem knockback). Minimum 1 pixel knockback even for heaviest
          rem characters
          let temp5 = playerCharacter[temp1]
          rem Get character type for damage calculation
          
          rem Apply damage from attacker to defender
          let temp6 = playerDamage_R[temp1]
          rem Use playerDamage array for base damage amount
          
          rem Apply dive damage bonus for Harpy
          
          if temp5 = 6 then HarpyCheckDive
          goto DiveCheckDone
HarpyCheckDive
          rem Check if Harpy is in dive mode
          if !(characterStateFlags_R[temp1] & 4) then DiveCheckDone
          rem Not diving, skip bonus
          rem Apply 1.5x damage for diving attacks (temp6 + temp6/2 =
          rem   1.5 * temp6)
          let temp2 = temp6
          asm
            lsr temp2
end
          let velocityCalculation_W = temp2
          let temp6 = temp6 + velocityCalculation_R
DiveCheckDone
          
          rem Guard check is now handled before HandleMissileHit is
          rem   called
          rem This function only handles damage application
          
          let oldHealthValue_W = playerHealth[temp4]
          rem Apply damage
          let playerHealth[temp4] = playerHealth[temp4] - temp6
          if playerHealth[temp4] > oldHealthValue_R then let playerHealth[temp4] = 0
          
          rem Apply knockback (weight-based scaling - heavier characters
          rem   resist more)
          rem Calculate direction: if missile moving right, push
          let temp2 = missileX[temp1]
          rem   defender right
          
          rem Calculate weight-based knockback scaling
          rem Heavier characters resist knockback more (max weight =
          let characterWeight_W = playerCharacter[temp4]
          rem   100)
          let characterWeight_W = CharacterWeights[characterWeight_R]
          rem Get character index
          rem Get character weight (5-100) - overwrite with weight value
          rem Calculate scaled knockback: KnockbackImpulse * (100 -
          rem   weight) / 100
          rem Approximate: (KnockbackImpulse * (100 - weight)) / 100
          rem For KnockbackImpulse = 4: scaled = (4 * (100 - weight)) /
          rem   100
          rem Simplify to avoid division: if weight < 50, use full
          rem Heavy characters use reduced knockback scaling
          if characterWeight_R >= 50 then WeightBasedKnockbackScale
          let impulseStrength_W = KnockbackImpulse
          rem Light characters (weight < 50): full knockback
          goto WeightBasedKnockbackApply
WeightBasedKnockbackScale
          rem Heavy characters (weight >= 50): reduced knockback
          rem Calculate: KnockbackImpulse * (100 - weight) / 100
          rem KnockbackImpulse = 4, so: 4 * (100 - weight) / 100
          rem Multiply first: 4 * velocityCalculation using bit shift
          let velocityCalculation_W = 100 - characterWeight_R
          rem   (ASL 2)
          let impulseStrength_W = velocityCalculation_R
          rem Resistance factor (0-50 for weights 50-100)
          rem Multiply by 4 (KnockbackImpulse = 4) using left shift 2
          rem   bits
          asm
            lda impulseStrength_R
            asl
            asl
            sta impulseStrength_W
end
          rem Divide by 100 - inlined for performance (fast
          let temp2 = impulseStrength_R
          rem   approximation for values 0-255)
          if temp2 > 200 then let impulseStrength_W = 2
          if temp2 > 100 then if temp2 <= 200 then let impulseStrength_W = 1
          if temp2 <= 100 then let impulseStrength_W = 0
          rem Scaled knockback (0, 1, or 2)
          if impulseStrength_R = 0 then let impulseStrength_W = 1
WeightBasedKnockbackApply
          rem Minimum 1 pixel knockback even for heaviest characters
          rem Apply scaled knockback impulse to velocity (not momentum)
          if temp2 >= playerX[temp4] then KnockbackRight
          let playerVelocityX[temp4] = playerVelocityX[temp4] + impulseStrength_R
          rem Missile from left, push right (positive velocity)
          let playerVelocityXL[temp4] = 0
          goto KnockbackDone
          rem Zero subpixel when applying knockback impulse
KnockbackRight
          let playerVelocityX[temp4] = playerVelocityX[temp4] - impulseStrength_R
          rem Missile from right, push left (negative velocity)
          let playerVelocityXL[temp4] = 0
KnockbackDone
          rem Zero subpixel when applying knockback impulse
          
          let playerRecoveryFrames[temp4] = HitstunFrames
          rem Set recovery/hitstun frames
          rem 10 frames of hitstun
          
          let playerState[temp4] = playerState[temp4] | 8
          rem Synchronize playerState bit 3 with recovery frames
          rem Set bit 3 (recovery flag) when recovery frames are set
          
          let temp1 = SoundAttackHit
          rem Play hit sound effect
          gosub PlaySoundEffect bank15
          
          rem Spawn damage indicator visual
          rem NOTE: VisualEffects.bas was phased out - damage indicators
          rem   handled inline
          
          return

HandleMissileBounce
          rem
          rem Handle Missile Bounce
          rem Handles wall bounce for missiles with bounce flag set.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp5 = missile flags
          rem Handles wall bounce for missiles with bounce flag set
          rem (inverts X velocity, applies friction damping)
          rem
          rem Input: temp1 = player index (0-3), temp5 = missile flags,
          rem missileVelocityX[] (global array) = missile X velocities,
          rem MissileFlagFriction (global constant) = friction flag,
          rem MaxByteValue (global constant) = 255
          rem
          rem Output: X velocity inverted (bounced), friction damping
          rem applied if flag set
          rem
          rem Mutates: temp2, temp6 (used for calculations),
          rem missileVelocityX[] (global array) = missile X velocity
          rem (inverted and dampened)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Velocity inverted using two’s complement. If
          rem friction flag set, velocity reduced by 50% (half). Missile
          rem continues bouncing (not deactivated)
          let missileVelocityXCalc_W = missileVelocityX[temp1]
          rem Get current X velocity
          rem Invert velocity (bounce back) using twos complement
          rem Split calculation to avoid sbc #256 (256 > 255)
          let temp6 = MaxByteValue - missileVelocityXCalc_R
          let missileVelocityXCalc_W = temp6 + 1
          rem tempCalc = 255 - velocity
          rem velocity = (255 - velocity) + 1 = 256 - velocity (twos
          rem complement)
          
          rem Apply friction damping if friction flag is set
          
          if !(temp5 & MissileFlagFriction) then BounceDone
          rem Reduce velocity by half (bit shift right by 1)
          rem Use bit shift instead of division to avoid complexity
          rem issues
          rem Subtraction works for both positive and negative values:
          rem   Positive: velocity - (velocity >> 1) = 0.5 velocity
          rem   (reduces)
          rem   Negative: velocity - (velocity >> 1) = 0.5 velocity
          rem   (reduces magnitude)
          let temp2 = missileVelocityXCalc_R
          rem Divide by 2 using bit shift right (LSR) - direct memory
          rem mode
          asm
            lsr temp2
end
          let missileVelocityXCalc_W = missileVelocityXCalc_R - temp2
BounceDone
          let missileVelocityX[temp1] = missileVelocityXCalc_R
          
          rem Continue bouncing (do not deactivate)
          return

DeactivateMissile
          rem
          rem Deactivate Missile
          rem Removes a missile from active status.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem Removes a missile from active status (clears active bit)
          rem
          rem Input: temp1 = player index (0-3), BitMask[] (global data
          rem table) = bit masks, MaxByteValue (global constant) = 255,
          rem missileActive (global) = missile active flags
          rem
          rem Output: Missile deactivated (active bit cleared)
          rem
          rem Mutates: temp6 (used for bit manipulation), missileActive
          rem (global) = missile active flags (bit cleared)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp6 = BitMask[temp1]
          rem Clear active bit for this player missile
          let temp6 = MaxByteValue - temp6
          let missileActive  = missileActive & temp6
          rem Invert bits
          return


