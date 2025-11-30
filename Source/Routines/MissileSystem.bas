          rem ChaosFight - Source/Routines/MissileSystem.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem MISSILE SYSTEM - 4-player MISSILE MANAGEMENT
          rem Manages up to 4 simultaneous missiles/attack visuals (one
          rem   per player).
          rem Each player can have ONE active missile at a time, which
          rem   can be:

GetPlayerMissileBitFlag
          rem Returns: Far (return thisbank)
          asm
GetPlayerMissileBitFlag
end
          rem   - Ranged projectile (bullet, arrow, magic spell)
          rem Returns: Far (return otherbank)
          rem   - Mêlée attack visual (sword, fist, kick sprite)
          rem MISSILE VARIABLES (from Variables.bas):
          rem   missileX[0-3] (a-d) - X positions
          rem   missileY[0-3] (SCRAM w097-w100) - Y positions
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
          rem Mutates: temp6 (return otherbank value)
          rem
          rem Called Routines: None
          rem Constraints: None
          rem Calculate bit flag using O(1) array lookup:
          rem BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1]
          return otherbank

SpawnMissile
          rem Returns: Far (return otherbank)
          asm
SpawnMissile

end
          rem
          rem Returns: Far (return otherbank)
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
          rem Get character type for this player
          let temp5 = playerCharacter[temp1]

          rem Read missile emission height from character data table
          let temp6 = CharacterMissileEmissionHeights[temp5]

          rem Calculate initial missile position based on player
          rem   position and facing
          rem Facing is stored in playerState bit 0: 0=left, 1=right
          rem Get facing direction
          let temp4 = playerState[temp1] & PlayerStateBitFacing

          rem Set missile position using array access (write to _W port)
          let missileX[temp1] = playerX[temp1]
          let missileY_W[temp1] = playerY[temp1] + temp6
          rem Facing left, spawn left
          if temp4 = 0 then let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetLeft[temp5]
          rem Facing right, spawn right
          if temp4 = 1 then let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetRight[temp5]

          rem Set active bit for this player missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          gosub GetPlayerMissileBitFlag
          let missileActive  = missileActive | temp6

          rem Initialize lifetime counter from character data table
          let missileLifetimeValue = CharacterMissileLifetime[temp5]

          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile
          rem   lifetime
          let missileLifetime_W[temp1] = missileLifetimeValue

          rem Cache missile flags at spawn to avoid per-frame lookups
          rem Flags are immutable per character, so cache once at spawn
          let temp2 = CharacterMissileFlags[temp5]
          rem Store flags for use in UpdateOneMissile
          let missileFlags_W[temp1] = temp2

          rem Initialize velocity from character data for friction
          rem   physics
          let temp6 = CharacterMissileMomentumX[temp5]
          rem Get base X velocity
          if temp4 = 0 then temp6 = 0 - temp6
          rem Apply facing direction (left = negative)
          let missileVelocityX[temp1] = temp6

          rem Optimized: Use precomputed NUSIZ table instead of arithmetic
          rem NUSIZ values precomputed in CharacterMissileNUSIZ table
          let missileNUSIZ_W[temp1] = CharacterMissileNUSIZ[temp5]

          rem Get Y velocity
          let temp6 = CharacterMissileMomentumY[temp5]

          rem Apply Harpy dive velocity bonus if in dive mode
          rem Handler extracted to MissileCharacterHandlers.bas
          if temp5 = 6 then goto HarpyCheckDiveVelocity
          rem VelocityDone label is in MissileCharacterHandlers.bas
          goto VelocityDone

          return otherbank

UpdateAllMissiles
          rem Returns: Far (return otherbank)
          asm
UpdateAllMissiles
end
          rem
          rem Returns: Far (return otherbank)
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
          return otherbank

UpdateOneMissile
          rem Returns: Far (return thisbank)
          asm
UpdateOneMissile
end
          rem
          rem Returns: Far (return otherbank)
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
          rem flag, CharacterMissileFlags[] (global table) - missile flags
          rem cached at spawn, HandleMegaxMissile - handles Megax stationary
          rem missile, HandleKnightGuyMissile - handles Knight Guy sword swing,
          rem MissileCollPF (bank8) - checks playfield collision,
          rem CheckAllMissileCollisions (bank8) - checks player
          rem collisions, PlaySoundEffect (bank15) - plays guard bounce
          rem sound, HandleMissileBounce (same-bank) - handles bounce physics,
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
          rem Not active, skip
          if temp4  = 0 then return otherbank

          rem Preserve player index since GetMissileFlags uses temp1
          rem Use temp6 temporarily to save player index (temp6 is used
          rem   for bit flags)
          let temp6 = temp1
          rem Save player index temporarily

          rem Get current velocities from stored arrays
          let temp2 = missileVelocityX[temp1]
          rem X velocity (already facing-adjusted from spawn)
          let temp3 = missileVelocityY[temp1]
          rem Y velocity

          rem Use cached missile flags (set at spawn) instead of lookup
          rem This avoids two CharacterMissileFlags lookups per frame
          rem Get cached flags (set at spawn time)
          let temp5 = missileFlags_R[temp1]

          rem Restore player index
          let temp1 = temp6

          rem Issue #1188: Character handler dispatch - look up character ID for special handlers
          rem Special handling for Megax (character 5): stationary fire breath visual
          rem Megax missile stays adjacent to player during attack, no movement
          rem Handler extracted to MissileCharacterHandlers.bas
          rem Get character ID for handler dispatch
          let temp6 = playerCharacter[temp1]
          if temp6 = CharacterMegax then goto HandleMegaxMissile

          rem Special handling for Knight Guy (character 7): sword swing visual
          rem Knight Guy missile appears overlapping, moves away, returns, then vanishes
          rem Handler extracted to MissileCharacterHandlers.bas
          if temp6 = CharacterKnightGuy then goto HandleKnightGuyMissile

          rem Apply gravity if flag is set

          if (temp5 & MissileFlagGravity) = 0 then goto GravityDone
          let temp3 = temp3 + GravityPerFrame
          rem Add gravity (1 pixel/frame down)
          let missileVelocityY[temp1] = temp3
GravityDone
          rem Update stored Y velocity
          rem Returns: Far (return otherbank)

          rem Issue #1188: Apply friction if flag is set (curling stone deceleration)
          rem Consolidated friction calculation - handles both positive and negative velocities
          if (temp5 & MissileFlagFriction) = 0 then goto FrictionDone
          rem Get current X velocity
          let missileVelocityXCalc = missileVelocityX[temp1]
          rem Zero velocity, no friction to apply
          if missileVelocityXCalc = 0 then goto FrictionDone

          rem Apply ice-like friction: reduce by CurlingFrictionCoefficient÷256 per frame
          rem CurlingFrictionCoefficient = 4, so reduction = velocity ÷ 64 (1.56% per frame)
          rem Issue #1188: Consolidated calculation - works for both positive and negative
          rem Calculate reduction amount (velocity ÷ 64 using 6-bit shift)
          let velocityCalculation = missileVelocityXCalc
          asm
            lda velocityCalculation
            bpl FrictionPositive
            eor #$FF
            adc #0
FrictionPositive
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta velocityCalculation
end
          rem Apply reduction: subtract for positive, add for negative (both reduce magnitude)
          if missileVelocityXCalc > 127 then let missileVelocityXCalc = missileVelocityXCalc + velocityCalculation else let missileVelocityXCalc = missileVelocityXCalc - velocityCalculation
          let missileVelocityX[temp1] = missileVelocityXCalc
          rem Update temp2 for position calculation
          let temp2 = missileVelocityXCalc
          rem Check if velocity dropped below threshold
          if missileVelocityXCalc < MinimumVelocityThreshold && missileVelocityXCalc > -MinimumVelocityThreshold then goto DeactivateMissile
FrictionDone

          rem Issue #1188: Update missile position and check bounds (consolidated)
          rem Update X position
          rem Update Y position (Read-Modify-Write)
          let missileX[temp1] = missileX[temp1] + temp2
          let temp4 = missileY_R[temp1] + temp3
          let missileY_W[temp1] = temp4

          rem Issue #1177: Frooty lollipop ricochet - check before wrap/deactivate
          rem Frooty’s projectile bounces off arena bounds instead of wrapping/deactivating
          let temp6 = playerCharacter[temp1]
          if temp6 = CharacterFrooty then goto FrootyRicochetCheck

          rem Wrap around horizontally using shared player thresholds
          let temp2 = missileX[temp1]
          if temp2 < PlayerLeftWrapThreshold then let missileX[temp1] = PlayerRightEdge : let temp2 = PlayerRightEdge
          if temp2 > PlayerRightWrapThreshold then let missileX[temp1] = PlayerLeftEdge : let temp2 = PlayerLeftEdge

          rem Check vertical bounds (deactivate if off-screen)
          let temp3 = temp4
          if temp3 > ScreenBottom then goto DeactivateMissile
          if temp3 > ScreenTopWrapThreshold then goto DeactivateMissile
          goto BoundsCheckDone

FrootyRicochetCheck
          rem Issue #1177: Frooty lollipop ricochets off arena bounds
          rem Returns: Far (return otherbank)
          rem Check horizontal bounds and reverse X velocity
          let temp2 = missileX[temp1]
          if temp2 < PlayerLeftWrapThreshold then goto FrootyRicochetLeft
          if temp2 > PlayerRightWrapThreshold then goto FrootyRicochetRight
          goto FrootyRicochetVerticalCheck
FrootyRicochetLeft
          rem Hit left wall - reverse X velocity and clamp position
          rem Returns: Far (return otherbank)
          let missileX[temp1] = PlayerLeftWrapThreshold
          let missileVelocityX[temp1] = 0 - missileVelocityX[temp1]
          goto FrootyRicochetVerticalCheck
FrootyRicochetRight
          rem Hit right wall - reverse X velocity and clamp position
          rem Returns: Far (return otherbank)
          let missileX[temp1] = PlayerRightWrapThreshold
          let missileVelocityX[temp1] = 0 - missileVelocityX[temp1]
FrootyRicochetVerticalCheck
          rem Check vertical bounds and reverse Y velocity
          rem Returns: Far (return otherbank)
          rem Screen top is around 20 (visible area), bottom is 192
          let temp3 = temp4
          if temp3 < 20 then goto FrootyRicochetTop
          if temp3 > ScreenBottom then goto FrootyRicochetBottom
          goto BoundsCheckDone
FrootyRicochetTop
          rem Hit top wall - reverse Y velocity and clamp position
          rem Returns: Far (return otherbank)
          let missileY_W[temp1] = 20
          let missileVelocityY[temp1] = 0 - missileVelocityY[temp1]
          goto BoundsCheckDone
FrootyRicochetBottom
          rem Hit bottom wall - reverse Y velocity and clamp position
          rem Returns: Far (return otherbank)
          let missileY_W[temp1] = ScreenBottom
          let missileVelocityY[temp1] = 0 - missileVelocityY[temp1]
BoundsCheckDone

          rem Check collision with playfield if flag is set
          rem Reload cached missile flags (temp5 was overwritten with Y position above)
          rem Get cached flags again (restore after temp5 was used for Y position)
          let temp5 = missileFlags_R[temp1]
          if (temp5 & MissileFlagHitBackground) = 0 then goto PlayfieldCollisionDone
          gosub MissileCollPF bank8
          rem Issue #1188: Collision detected - check if should bounce or deactivate
          if !temp4 then goto PlayfieldCollisionDone
          if temp5 & MissileFlagBounce then gosub HandleMissileBounce : return otherbank
          goto DeactivateMissile
PlayfieldCollisionDone
          rem No bounce - deactivate on background hit
          rem Returns: Far (return otherbank)

          rem Check collision with players
          rem This handles both visible missiles and AOE attacks
          gosub CheckAllMissileCollisions bank8
          rem Check if hit was found (temp4 != MissileHitNotFound)
          if temp4 = MissileHitNotFound then goto MissileSystemNoHit

          rem Issue #1188: Check if hit player is guarding before handling hit
          let temp6 = playerState[temp4] & 2
          rem Guarding - bounce instead of damage
          if temp6 = 0 then goto HandleMissileDamage
          rem Guard bounce: play sound, invert velocity, reduce by 25%
          let soundEffectID_W = SoundGuardBlock
          gosub PlaySoundEffect bank15
          rem Invert X velocity (bounce back)
          let temp6 = 0 - missileVelocityX[temp1]
          rem Reduce by 25% (divide by 4, then subtract)
          asm
            lda temp6
            lsr
            lsr
            sta velocityCalculation
end
          let missileVelocityX[temp1] = temp6 - velocityCalculation
          rem Continue without deactivating - missile bounces
          goto MissileSystemNoHit

HandleMissileDamage
          rem HandleMissileHit applies damage and effects
          rem Returns: Far (return otherbank)
          gosub HandleMissileHit
          rem tail call
          goto DeactivateMissile
MissileSystemNoHit
          rem Missile disappears after hitting player
          rem Returns: Far (return otherbank)

          rem Decrement lifetime counter and check expiration
          rem Retrieve current lifetime for this missile
          let missileLifetimeValue = missileLifetime_R[temp1]

          rem Decrement if not set to infinite (infinite until
          rem collision)
          if missileLifetimeValue = MissileLifetimeInfinite then goto MissileUpdateComplete
          let missileLifetimeValue = missileLifetimeValue - 1
          if missileLifetimeValue = 0 then goto DeactivateMissile
          rem tail call
          let missileLifetimeValue = missileLifetimeValue - 1
          if missileLifetimeValue = 0 then goto DeactivateMissile
          let missileLifetime_W[temp1] = missileLifetimeValue
MissileUpdateComplete

          return thisbank
          rem Character handlers extracted to MissileCharacterHandlers.bas

MissileSysPF
          rem
          rem Returns: Far (return otherbank)
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
          rem Called Routines: None (uses inline bit shifts for division)
          rem
          rem Constraints: Uses pfread to check playfield pixel at
          rem missile position. X coordinate converted to playfield column
          rem (0-31) by subtracting ScreenInsetX and dividing by 4.
          rem Get missile X/Y position (read from _R port)
          let temp2 = missileX[temp1]
          let temp3 = missileY_R[temp1]

          rem Convert X/Y to playfield coordinates
          rem Playfield is 32 quad-width pixels covering 128 pixels
          rem (from X=16 to X=144), 192 pixels tall
          rem pfread uses playfield coordinates: column (0-31), row
          rem (0-7)
          rem Convert X pixel to playfield column: subtract ScreenInsetX (16),
          rem then divide by 4 (each quad-width pixel is 4 pixels wide)
          rem Save original X in temp6 after removing screen inset
          let temp6 = temp2
          rem Divide by 4 using bit shift (2 right shifts)
          let temp6 = temp6 - ScreenInsetX
          rem temp6 = playfield column (0-31)
          let temp6 = temp6 / 4
          rem Clamp column to valid range
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp6 & $80 then temp6 = 0
          rem temp3 is already in pixel coordinates, pfread will handle
          if temp6 > 31 then temp6 = 31
          rem   it

          rem Check if playfield pixel is set
          let temp4 = 0
          let temp1 = temp6
          let temp2 = temp3
          gosub PlayfieldRead bank16
          rem Default: no collision detected
          if temp1 then let temp4 = 1 : return otherbank
          return otherbank
CheckMissilePlayerCollision
          rem
          rem Returns: Far (return otherbank)
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
          rem Get missile X/Y position (read from _R port)
          let temp2 = missileX[temp1]
          let temp3 = missileY_R[temp1]

          rem Missile bounding box
          rem temp2 = missile left, temp2+MissileAABBSize = missile
          rem   right
          rem temp3 = missile top, temp3+MissileAABBSize = missile
          rem   bottom

          rem Check collision with each player (except owner)
          let temp4 = MissileHitNotFound
          rem Default: no hit

          rem Optimized: Loop through all players instead of copy-paste code
          rem This reduces ROM footprint by ~150 bytes
          rem Skip owner player
          for temp6 = 0 to 3
          rem Skip eliminated players
          if temp6 = temp1 then goto MissileCheckNextPlayer
          rem AABB collision check: missile vs player bounding box
          if playerHealth[temp6] = 0 then goto MissileCheckNextPlayer
          if temp2 >= playerX[temp6] + PlayerSpriteHalfWidth then goto MissileCheckNextPlayer
          if temp2 + MissileAABBSize <= playerX[temp6] then goto MissileCheckNextPlayer
          if temp3 >= playerY[temp6] + PlayerSpriteHeight then goto MissileCheckNextPlayer
          rem Collision detected - return otherbank hit player index
          if temp3 + MissileAABBSize <= playerY[temp6] then goto MissileCheckNextPlayer
          let temp4 = temp6
          goto MissileCollisionReturn
MissileCheckNextPlayer
          next
MissileCollisionReturn
          return otherbank
HandleMissileHit
          rem Returns: Far (return thisbank)
          asm
HandleMissileHit
end
          rem
          rem Returns: Far (return otherbank)
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
          rem Called Routines: GetCharacterDamage (bank12) - obtains base
          rem damage per character, PlaySoundEffect (bank15) - plays hit
          rem sound
          rem
          rem Constraints: Harpy dive mode increases damage by 50%.
          rem Knockback scales with character weight (heavier = less
          rem knockback). Minimum 1 pixel knockback even for heaviest
          rem characters
          rem Get character type for damage calculation
          let temp5 = playerCharacter[temp1]

          rem Apply damage from attacker to defender
          let temp3 = temp1
          rem GetCharacterDamage inlined - weight-based damage calculation
          let temp1 = temp5
          let temp3 = CharacterWeights[temp1]
          if temp3 <= 15 then temp2 = 12 : goto MissileDamageDone
          if temp3 <= 25 then temp2 = 18 : goto MissileDamageDone
          let temp2 = 22
MissileDamageDone
          let temp6 = temp2
          rem Base damage derived from character definition
          let temp1 = temp3

          rem Apply dive damage bonus for Harpy

          if temp5 = 6 then goto HarpyCheckDive
          goto DiveCheckDone
HarpyCheckDive
          rem Check if Harpy is in dive mode
          rem Returns: Far (return otherbank)
          rem Not diving, skip bonus
          if (characterStateFlags_R[temp1] & 4) = 0 then goto DiveCheckDone
          rem Apply 1.5× damage for diving attacks (temp6 + temp6÷2 =
          rem   1.5 × temp6)
          let temp2 = temp6
          asm
            lsr temp2
end
          let velocityCalculation = temp2
          let temp6 = temp6 + velocityCalculation
DiveCheckDone

          rem Guard check is now handled before HandleMissileHit is
          rem   called
          rem This function only handles damage application

          rem Apply damage
          let oldHealthValue = playerHealth[temp4]
          let playerHealth[temp4] = playerHealth[temp4] - temp6
          if playerHealth[temp4] > oldHealthValue then let playerHealth[temp4] = 0

          rem Apply knockback (weight-based scaling - heavier characters
          rem   resist more)
          rem Calculate direction: if missile moving right, push
          rem   defender right
          let temp2 = missileX[temp1]

          rem Issue #1188: Weight-based knockback scaling (simplified)
          rem Heavier characters resist knockback more (weight 5-100)
          let temp6 = playerCharacter[temp4]
          rem Light characters (weight < 50): full knockback
          let characterWeight = CharacterWeights[temp6]
          if characterWeight >= 50 then goto WeightBasedKnockbackScale
          let impulseStrength = KnockbackImpulse
          goto WeightBasedKnockbackApply
WeightBasedKnockbackScale
          rem Heavy characters: reduced knockback (4 × (100-weight) ÷ 100)
          rem Returns: Far (return otherbank)
          let velocityCalculation = 100 - characterWeight
          asm
            lda velocityCalculation
            asl
            asl
            sta impulseStrength
end
          let temp2 = impulseStrength
          if temp2 > 200 then let impulseStrength = 2 : goto WeightBasedKnockbackApply
          if temp2 > 100 then let impulseStrength = 1 : goto WeightBasedKnockbackApply
          let impulseStrength = 0
          if impulseStrength = 0 then let impulseStrength = 1
WeightBasedKnockbackApply
          rem Apply knockback: missile from left pushes right, from right pushes left
          rem Returns: Far (return otherbank)
          if temp2 >= playerX[temp4] then goto KnockbackRight
          let playerVelocityX[temp4] = playerVelocityX[temp4] + impulseStrength
          goto KnockbackDone
KnockbackRight
          let playerVelocityX[temp4] = playerVelocityX[temp4] - impulseStrength
KnockbackDone
          rem Zero subpixel when applying knockback impulse
          rem Returns: Far (return otherbank)
          let playerVelocityXL[temp4] = 0

          rem Set recovery/hitstun frames
          let playerRecoveryFrames[temp4] = HitstunFrames
          rem 10 frames of hitstun

          rem Synchronize playerState bit 3 with recovery frames
          let playerState[temp4] = playerState[temp4] | 8
          rem Set bit 3 (recovery flag) when recovery frames are set

          rem Play hit sound effect
          let temp1 = SoundAttackHit
          gosub PlaySoundEffect bank15

          rem Spawn damage indicator visual (handled inline)

          return otherbank
HandleMissileBounce
          rem Returns: Far (return thisbank)
          asm
HandleMissileBounce

end
          rem
          rem Returns: Far (return otherbank)
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
          rem Get current X velocity
          let missileVelocityXCalc = missileVelocityX[temp1]
          rem Invert velocity (bounce back) using twos complement
          rem Split calculation to avoid sbc #256 (256 > 255)
          let temp6 = MaxByteValue - missileVelocityXCalc
          rem tempCalc = 255 - velocity
          let missileVelocityXCalc = temp6 + 1
          rem velocity = (255 - velocity) + 1 = 256 - velocity (twos
          rem complement)

          rem Apply friction damping if friction flag is set

          rem Reduce velocity by half (bit shift right by 1)
          if (temp5 & MissileFlagFriction) = 0 then goto BounceDone
          rem Use bit shift instead of division to avoid complexity
          rem issues
          rem Subtraction works for both positive and negative values:
          rem   Positive: velocity - (velocity >> 1) = 0.5 velocity
          rem   (reduces)
          rem   Negative: velocity - (velocity >> 1) = 0.5 velocity
          rem   (reduces magnitude)
          rem Divide by 2 using bit shift right (LSR) - direct memory
          let temp2 = missileVelocityXCalc
          rem mode
          asm
            lsr temp2
end
          let missileVelocityXCalc = missileVelocityXCalc - temp2
BounceDone
          let missileVelocityX[temp1] = missileVelocityXCalc

          rem Continue bouncing (do not deactivate)
          return otherbank
DeactivateMissile
          rem
          rem Returns: Far (return otherbank)
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
          rem Clear active bit for this player missile
          let temp6 = BitMask[temp1]
          let temp6 = MaxByteValue - temp6
          rem Invert bits
          let missileActive  = missileActive & temp6
          return otherbank

