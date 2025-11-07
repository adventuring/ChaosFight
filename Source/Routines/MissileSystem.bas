GetPlayerMissileBitFlag
          rem
          rem ChaosFight - Source/Routines/MissileSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem MISSILE SYSTEM - 4-player MISSILE MANAGEMENT
          rem Manages up to 4 simultaneous missiles/attack visuals (one
          rem   per player).
          rem Each player can have ONE active missile at a time, which
          rem   can be:
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
          rem Calculates the bit flag for missile active tracking
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp6 = bit flag (1, 2, 4, or 8)
          rem EFFECTS: Uses temp6 for calculation
          rem Calculates the bit flag for missile active tracking (1, 2,
          rem 4, or 8)
          rem Input: temp1 = player index (0-3), BitMask[] (global data
          rem table) = bit masks
          rem Output: temp6 = bit flag (1, 2, 4, or 8)
          rem Mutates: temp6 (return value)
          rem Called Routines: None
          dim GPMBF_playerIndex = temp1 : rem Constraints: None
          dim GPMBF_bitFlag = temp6
          rem Calculate bit flag using O(1) array lookup:
          rem BitMask[playerIndex] (1, 2, 4, 8)
          let GPMBF_bitFlag = BitMask[GPMBF_playerIndex]
          let temp6 = GPMBF_bitFlag
          return

SpawnMissile
          rem
          rem Spawn Missile
          rem Creates a new missile/attack visual for a player.
          rem Called when player presses attack button.
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
          rem Input: temp1 = player index (0-3), playerChar[] (global
          rem array) = character types, playerX[], playerY[] (global
          rem arrays) = player positions, playerState[] (global array) =
          rem player states (facing direction),
          rem CharacterMissileEmissionHeights[],
          rem CharacterMissileLifetime[], CharacterMissileMomentumX[],
          rem CharacterMissileMomentumY[], CharacterMissileWidths[]
          rem (global data tables) = missile properties,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags (for Harpy dive mode), MissileSpawnOffsetLeft,
          rem MissileSpawnOffsetRight (global constants) = spawn
          rem offsets, PlayerStateBitFacing (global constant) = facing
          rem bit mask
          rem Output: Missile spawned at correct position with initial
          rem velocity and lifetime
          rem Mutates: temp1-temp6 (used for calculations), missileX[],
          rem missileY_W[] (global arrays) = missile positions,
          rem missileActive (global) = missile active flags,
          rem missileLifetime[] (global array) = missile lifetime
          rem counters, missileVelocityX[], missileVelocityY[] (global
          rem arrays) = missile velocities, missileNUSIZ[] (global
          rem array) = missile size registers
          rem Called Routines: GetPlayerMissileBitFlag - calculates bit
          rem flag for missile active tracking
          rem Constraints: Only one missile per player at a time. Harpy
          rem dive mode increases downward velocity by 50%
          dim SM_playerIndex = temp1
          dim SM_facing = temp4
          dim SM_characterType = temp5
          dim SM_bitFlag = temp6
          dim SM_velocityCalc = temp6
          let SM_characterType  = playerChar[SM_playerIndex] : rem Get character type for this player
          
          let SM_bitFlag  = CharacterMissileEmissionHeights[SM_characterType] : rem Read missile emission height from character data table
          
          rem Calculate initial missile position based on player
          rem   position and facing
          rem Facing is stored in playerState bit 0: 0=left, 1=right
          let SM_facing = playerState[SM_playerIndex] & PlayerStateBitFacing
          rem Get facing direction
          
          let missileX[SM_playerIndex] = playerX[SM_playerIndex] : rem Set missile position using array access (write to _W port)
          let missileY_W[SM_playerIndex] = playerY[SM_playerIndex] + SM_bitFlag
          if SM_facing = 0 then let missileX[SM_playerIndex] = missileX[SM_playerIndex] - MissileSpawnOffsetLeft
          if SM_facing = 1 then let missileX[SM_playerIndex] = missileX[SM_playerIndex] + MissileSpawnOffsetRight : rem Facing left, spawn left
          rem Facing right, spawn right
          
          rem Set active bit for this player missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          let temp1 = SM_playerIndex : rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          gosub GetPlayerMissileBitFlag
          let SM_bitFlag = temp6
          let missileActive  = missileActive | SM_bitFlag
          
          let missileLifetimeValue = CharacterMissileLifetime[SM_characterType] : rem Initialize lifetime counter from character data table
          
          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile
          let missileLifetime[SM_playerIndex] = missileLifetimeValue : rem   lifetime
          
          rem Initialize velocity from character data for friction
          let SM_velocityCalc  = CharacterMissileMomentumX[SM_characterType] : rem   physics
          if SM_facing = 0 then let SM_velocityCalc  = 0 - SM_velocityCalc : rem Get base X velocity
          let missileVelocityX[SM_playerIndex] = SM_velocityCalc : rem Apply facing direction (left = negative)
          
          rem Initialize NUSIZ tracking from missile width
          rem NUSIZ bits 4-6: 00=1x, 01=2x, 10=4x (multiplied by 16:
          dim SM_missileWidth = temp2 : rem   0x00, 0x10, 0x20)
          let SM_missileWidth = CharacterMissileWidths[SM_characterType]
          rem Convert width to NUSIZ value (width 1=0x00, 2=0x10,
          if SM_missileWidth = 1 then let missileNUSIZ[SM_playerIndex] = 0 : goto SM_NUSIZDone : rem 4=0x20) - inlined for performance
          if SM_missileWidth = 2 then let missileNUSIZ[SM_playerIndex] = 16 : goto SM_NUSIZDone : rem 1x size (NUSIZ bits 4-6 = 00)
          rem 2x size (NUSIZ bits 4-6 = 01, value = 0x10 = 16)
          if SM_missileWidth = 4 then let missileNUSIZ[SM_playerIndex] = 32 : goto SM_NUSIZDone
          rem 4x size (NUSIZ bits 4-6 = 10, value = 0x20 = 32)
          let missileNUSIZ[SM_playerIndex] = 0 : rem Default to 1x if width not recognized
SM_NUSIZDone
          
          let SM_velocityCalc  = CharacterMissileMomentumY[SM_characterType]
          rem Get Y velocity
          
          if SM_characterType = 6 then HarpyCheckDiveVelocity : rem Apply Harpy dive velocity bonus if in dive mode
          goto VelocityDone
HarpyCheckDiveVelocity
          rem Helper: Checks if Harpy is in dive mode and boosts
          rem velocity if so
          rem Input: temp6 = base Y velocity, SM_playerIndex = player
          rem index, characterStateFlags_R[] (global SCRAM array) =
          rem character state flags
          rem Output: Y velocity boosted by 50% if in dive mode
          rem Mutates: temp6 (velocity calculation), SM_velocityCalc
          rem (via HarpyBoostDiveVelocity)
          rem Called Routines: None
          rem Constraints: Internal helper for SpawnMissile, only called
          rem for Harpy (character 6)
          dim HCDV_velocityCalc = temp6
          let HCDV_velocityCalc = SM_velocityCalc
          if (characterStateFlags_R[SM_playerIndex] & 4) then HarpyBoostDiveVelocity
          goto VelocityDone
HarpyBoostDiveVelocity
          rem Helper: Increases Harpy downward velocity by 50% for dive
          rem attacks
          rem Input: HCDV_velocityCalc = base velocity
          rem Output: Velocity increased by 50% (velocity + velocity/2)
          rem Mutates: HCDV_velocityCalc, SM_velocityCalc (velocity
          rem values)
          rem Called Routines: None
          rem Constraints: Internal helper for HarpyCheckDiveVelocity,
          rem only called when dive mode active
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
          let missileVelocityY[SM_playerIndex] = SM_velocityCalc
          
          return

          rem
          rem Update All Missiles
          rem Called once per frame to update all active missiles.
          rem Updates position, checks collisions, handles lifetime.
UpdateAllMissiles
          rem Updates all active missiles (called once per frame)
          rem Input: None (processes all players 0-3)
          rem Output: All active missiles updated (position, velocity,
          rem lifetime, collisions)
          rem Mutates: All missile state (via UpdateOneMissile for each
          rem player)
          rem Called Routines: UpdateOneMissile (for each player 0-3)
          rem Constraints: None
          let temp1  = 0 : rem Check each player missile
          gosub UpdateOneMissile
          let temp1  = 1
          gosub UpdateOneMissile
          let temp1  = 2
          gosub UpdateOneMissile
          let temp1  = 3
          goto UpdateOneMissile : rem tail call

UpdateOneMissile
          rem
          rem Update One Missile
          rem Updates a single player missile.
          rem Handles movement, gravity, collisions, and lifetime.
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem Updates a single player missile (movement, gravity,
          rem friction, collisions, lifetime)
          rem Input: temp1 = player index (0-3), missileActive (global)
          rem = missile active flags, missileVelocityX[],
          rem missileVelocityY[] (global arrays) = missile velocities,
          rem missileX[], missileY_R[] (global arrays) = missile
          rem positions, playerChar[] (global array) = character types,
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
          rem CharMegax, CharKnightGuy (global constants) = character
          rem indices, SoundGuardBlock (global constant) = sound effect
          rem ID
          rem Output: Missile updated (position, velocity, lifetime),
          rem collisions checked, missile deactivated if expired or
          rem off-screen
          rem Mutates: temp1-temp6 (used for calculations), missileX[],
          rem missileY_W[] (global arrays) = missile positions,
          rem missileVelocityX[], missileVelocityY[] (global arrays) =
          rem missile velocities, missileActive (global) = missile
          rem active flags (via DeactivateMissile), missileLifetime[]
          rem (global array) = missile lifetime counters, soundEffectID
          rem (global) = sound effect ID (via guard bounce)
          rem Called Routines: GetPlayerMissileBitFlag - calculates bit
          rem flag, GetMissileFlags (bank6) - gets missile flags,
          rem HandleMegaxMissile - handles Megax stationary missile,
          rem HandleKnightGuyMissile - handles Knight Guy sword swing,
          rem MissileCollPF (bank7) - checks playfield collision,
          rem CheckAllMissileCollisions (bank7) - checks player
          rem collisions, PlaySoundEffect (bank15) - plays guard bounce
          rem sound, HandleMissileBounce - handles bounce physics,
          rem HandleMissileHit - handles damage application,
          rem DeactivateMissile - deactivates missile
          rem Constraints: Special handling for Megax (stationary) and
          rem Knight Guy (sword swing). Missiles wrap horizontally,
          rem deactivate if off-screen vertically. Guard bounce reduces
          rem velocity by 25%
          dim UOM_playerIndex = temp1
          dim UOM_bitFlag = temp6
          dim UOM_isActive = temp4
          dim UOM_savedIndex = temp6
          dim UOM_velocityX = temp2
          dim UOM_velocityY = temp3
          dim UOM_characterType = temp5
          dim UOM_missileFlags = temp5
          let temp1 = UOM_playerIndex : rem Check if this missile is active
          gosub GetPlayerMissileBitFlag
          let UOM_bitFlag = temp6
          let UOM_isActive  = missileActive & UOM_bitFlag
          if UOM_isActive  = 0 then return
          rem Not active, skip
          
          rem Preserve player index since GetMissileFlags uses temp1
          rem Use temp6 temporarily to save player index (temp6 is used
          let UOM_savedIndex  = UOM_playerIndex : rem   for bit flags)
          rem Save player index temporarily
          
          let UOM_velocityX  = missileVelocityX[UOM_playerIndex] : rem Get current velocities from stored arrays
          let UOM_velocityY  = missileVelocityY[UOM_playerIndex] : rem X velocity (already facing-adjusted from spawn)
          rem Y velocity
          
          let UOM_characterType  = playerChar[UOM_playerIndex] : rem Read missile flags from character data
          let temp1  = UOM_characterType : rem Get character index
          gosub GetMissileFlags bank6 : rem Use temp1 for flags lookup (temp1 will be overwritten)
          let UOM_missileFlags  = temp2
          rem Store flags
          
          let UOM_playerIndex  = UOM_savedIndex : rem Restore player index and get flags back
          rem Restore player index
          
          rem Special handling for Megax (character 5): stationary fire
          rem breath visual
          if UOM_characterType = CharMegax then goto HandleMegaxMissile : rem Megax missile stays adjacent to player during attack, no movement
          
          rem Special handling for Knight Guy (character 7): sword swing
          rem visual
          if UOM_characterType = CharKnightGuy then goto HandleKnightGuyMissile : rem Knight Guy missile appears overlapping, moves away, returns, then vanishes
          
          if !(UOM_missileFlags & MissileFlagGravity) then GravityDone : rem Apply gravity if flag is set
          let UOM_velocityY = UOM_velocityY + GravityPerFrame
          let missileVelocityY[UOM_playerIndex] = UOM_velocityY : rem Add gravity (1 pixel/frame down)
          rem Update stored Y velocity
GravityDone
          
          rem Apply friction if flag is set (curling stone deceleration
          if !(temp5 & MissileFlagFriction) then FrictionDone : rem   with coefficient)
          let missileVelocityXCalc = missileVelocityX[UOM_playerIndex]
          rem Get current X velocity
          
          rem Apply ice-like friction: reduce by
          rem   CurlingFrictionCoefficient/256 per frame
          rem CurlingFrictionCoefficient = 4 (Q8 fixed-point: 4/256 =
          rem   1.56% per frame)
          rem Derived from constant: reduction = velocity / (256 /
          if missileVelocityXCalc = 0 then FrictionDone : rem CurlingFrictionCoefficient) = velocity / 64
          rem Zero velocity, no friction to apply
          
          rem Calculate friction reduction (velocity / 64, approximates
          let velocityCalculation = missileVelocityXCalc : rem   1.56% reduction)
          rem Check if velocity is negative (twos complement: values >
          rem   127 are negative)
          rem For unsigned bytes, negative values in twos complement
          if velocityCalculation > 127 then FrictionNegative : rem   are 128-255
          rem Positive velocity
          rem Divide by 64 using bit shift (6 right shifts) - derived
          rem   from CurlingFrictionCoefficient
          asm
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
end
          let missileVelocityXCalc = missileVelocityXCalc - velocityCalculation : rem Reduce by 1/64 (1.56% - ice-like friction)
          goto FrictionApply
FrictionNegative
          let velocityCalculation = 0 - velocityCalculation : rem Negative velocity - convert to positive for division
          rem Divide by 64 using bit shift (6 right shifts) - derived
          rem   from CurlingFrictionCoefficient
          asm
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
            lsr velocityCalculation
end
          let missileVelocityXCalc = missileVelocityXCalc + velocityCalculation : rem Reduce by 1/64 (1.56% - ice-like friction)
          rem Add back (since missileVelocityXCalc was negative)
FrictionApply
          let missileVelocityX[UOM_playerIndex] = missileVelocityXCalc
          let temp2  = missileVelocityXCalc
          rem Update temp2 for position calculation
          rem Check if velocity dropped below threshold
          if missileVelocityXCalc < MinimumVelocityThreshold && missileVelocityXCalc > -MinimumVelocityThreshold then goto DeactivateMissile : rem tail call
          let missileVelocityX[UOM_playerIndex] = missileVelocityXCalc : rem Update stored X velocity with friction applied
FrictionDone
          
          rem Update missile position
          let missileX[UOM_playerIndex] = missileX[UOM_playerIndex] + temp2 : rem Read-Modify-Write: Read from _R, modify, write to _W
          dim UOM_missileY = temp4
          let UOM_missileY = missileY_R[UOM_playerIndex]
          let UOM_missileY = UOM_missileY + temp3
          let missileY_W[UOM_playerIndex] = UOM_missileY
          
          rem Check screen bounds and wrap around horizontally
          rem Missiles wrap around horizontally like players (all
          rem arenas)
          let temp2  = missileX[temp1] : rem Get missile X/Y position (read from _R port)
          let temp3  = missileY_R[temp1]
          
          rem Wrap around horizontally: X < 10 wraps to 150, X > 150
          rem wraps
          rem   to 10
          if temp2 < 10 then let temp2 = 150 : let missileX[temp1] = 150 : rem Match player wrap-around behavior (same boundaries: 10-150)
          if temp2 > 150 then let temp2 = 10 : let missileX[temp1] = 10 : rem Off left edge, wrap to right
          rem Off right edge, wrap to left
          
          rem Check vertical bounds (deactivate if off top/bottom, like
          let temp4  = 0 : rem   players are clamped)
          if temp3 > ScreenBottom then temp4  = 1
          rem Off bottom, deactivate
          rem Byte-safe top bound: if wrapped past 0 due to subtract,
          let temp5  = temp3 : rem   temp3 will be > original
          rem Assuming prior update may have subtracted from temp3
          if temp3 > ScreenTopWrapThreshold then temp4  = 1 : rem   earlier in loop
          if temp4 then goto DeactivateMissile : rem Off top, deactivate
          rem Off-screen vertically, deactivate
          
          rem Check collision with playfield if flag is set
          rem Reload missile flags (temp5 was overwritten with Y
          let temp5 = playerChar[UOM_playerIndex] : rem   position above)
          let temp1 = temp5
          gosub GetMissileFlags bank6
          let temp5 = temp2
          let temp1 = UOM_playerIndex : rem temp5 now contains missile flags again
          if !(temp5 & MissileFlagHitBackground) then PlayfieldCollisionDone : rem Restore player index for MissileCollPF
          gosub MissileCollPF bank7
          if !temp4 then PlayfieldCollisionDone
          rem Collision detected - check if should bounce or deactivate
          if temp5 & MissileFlagBounce then gosub HandleMissileBounce : return
          gosub DeactivateMissile : return : rem Bounced - continue moving (HandleMissileBounce returns)
          rem No bounce - deactivate on background hit
PlayfieldCollisionDone
          
          rem Check collision with players
          gosub CheckAllMissileCollisions bank7 : rem This handles both visible missiles and AOE attacks
          rem Check if hit was found (temp4 != MissileHitNotFound)
          if temp4 = MissileHitNotFound then MissileSystemNoHit
          
          rem Check if hit player is guarding before handling hit
          let temp6  = playerState[temp4] & 2 : rem temp4 contains hit player index
          if temp6 then GuardBounceFromCollision
          goto HandleMissileDamage : rem Guarding - bounce instead of damage
GuardBounceFromCollision
          rem Guarding player - bounce the curling stone
          let soundEffectID = SoundGuardBlock : rem Play guard sound
          gosub PlaySoundEffect bank15
          
          rem Bounce the missile: invert X velocity and apply friction
          let temp6  = missileVelocityX[UOM_playerIndex] : rem   damping
          let temp6  = 0 - temp6
          rem Invert X velocity (bounce back)
          rem Apply friction damping on bounce (reduce by 25% for guard
          rem   bounce)
          rem Divide by 4 using bit shift (2 right shifts)
          let velocityCalculation = temp6 : rem Copy to velocityCalculation first, then shift in-place
          asm
            lsr velocityCalculation
            lsr velocityCalculation
end
          let temp6  = temp6 - velocityCalculation
          let missileVelocityX[UOM_playerIndex] = temp6 : rem Reduce bounce velocity by 25%
          
          rem Continue without deactivating - missile bounces and
          goto MissileSystemNoHit : rem   continues
          
HandleMissileDamage
          gosub HandleMissileHit
          rem HandleMissileHit applies damage and effects
          goto DeactivateMissile : rem tail call
          rem Missile disappears after hitting player
MissileSystemNoHit
          
          rem Decrement lifetime counter and check expiration
          let missileLifetimeValue = missileLifetime[UOM_playerIndex] : rem Retrieve current lifetime for this missile
          
          rem Decrement if not set to infinite (infinite until
          if missileLifetimeValue = MissileLifetimeInfinite then MissileUpdateComplete : rem   collision)
          let missileLifetimeValue = missileLifetimeValue - 1
          if missileLifetimeValue = 0 then goto DeactivateMissile : rem tail call
          let missileLifetime[UOM_playerIndex] = missileLifetimeValue
MissileUpdateComplete
          
          return

          rem
          rem HANDLE MEGAX MISSILE (stationary Fire Breath Visual)
          rem Megax missile stays adjacent to player, no movement.
          rem Missile appears when attack starts, stays during attack
          rem phase,
          rem   and vanishes when attack animation completes.
HandleMegaxMissile
          rem Handles Megax stationary fire breath visual (locked to
          rem player position)
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, playerState[] (global
          rem array) = player states (facing direction, animation
          rem state), CharacterMissileEmissionHeights[] (global data
          rem table) = emission heights, MissileSpawnOffsetLeft,
          rem MissileSpawnOffsetRight (global constants) = spawn
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
          dim HMM_playerIndex = temp1
          dim HMM_facing = temp4
          dim HMM_emissionHeight = temp5
          dim HMM_missileX = temp2
          dim HMM_missileY = temp3
          dim HMM_animationState = temp6
          
          let HMM_facing = playerState[HMM_playerIndex] & PlayerStateBitFacing : rem Get facing direction (bit 0: 0=left, 1=right)
          
          let HMM_emissionHeight = CharacterMissileEmissionHeights[UOM_characterType] : rem Get emission height from character data
          
          rem Lock missile position to player position (adjacent, no
          rem movement)
          let HMM_missileX = playerX[HMM_playerIndex] : rem Calculate X position based on player position and facing
          if HMM_facing = 0 then let HMM_missileX = HMM_missileX - MissileSpawnOffsetLeft
          if HMM_facing = 1 then let HMM_missileX = HMM_missileX + MissileSpawnOffsetRight : rem Facing left, spawn left
          rem Facing right, spawn right
          
          let HMM_missileY = playerY[HMM_playerIndex] + HMM_emissionHeight : rem Calculate Y position (player Y + emission height)
          
          let missileX[HMM_playerIndex] = HMM_missileX : rem Update missile position (locked to player)
          let missileY_W[HMM_playerIndex] = HMM_missileY
          
          let missileVelocityX[HMM_playerIndex] = 0 : rem Zero velocities to prevent any movement
          let missileVelocityY[HMM_playerIndex] = 0
          
          rem Check if attack animation is complete
          rem Animation state is in bits 4-7 of playerState
          rem ActionAttackExecute = 14 (0xE)
          let HMM_animationState = playerState[HMM_playerIndex] : rem Extract animation state (bits 4-7)
          rem Extract animation state (bits 4-7) using bit shift
          asm
            lsr HMM_animationState
            lsr HMM_animationState
            lsr HMM_animationState
            lsr HMM_animationState
end
          
          rem If animation state is not ActionAttackExecute (14), attack
          rem is complete
          rem   deactivate
          rem ActionAttackExecute = 14, so if animationState != 14,
          if HMM_animationState = 14 then MegaxMissileActive
          goto DeactivateMissile : rem Attack complete - deactivate missile
          
MegaxMissileActive
          rem Attack still active - missile stays visible
          rem Skip normal movement and collision checks
          return

          rem
          rem HANDLE KNIGHT GUY MISSILE (sword Swing Visual)
          rem Knight Guy missile appears partially overlapping player,
          rem   moves slightly away during attack phase (sword swing),
          rem   returns to start position, and vanishes when attack
          rem   completes.
HandleKnightGuyMissile
          rem Handles Knight Guy sword swing visual (moves away then
          rem returns during attack)
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = player positions, playerState[] (global
          rem array) = player states (facing direction, animation
          rem state), CharacterMissileEmissionHeights[] (global data
          rem table) = emission heights, currentAnimationFrame_R[]
          rem (global SCRAM array) = animation frames,
          rem PlayerStateBitFacing (global constant) = facing bit mask,
          rem ActionAttackExecute (global constant) = attack animation
          rem state (14)
          rem Output: Missile position animated based on animation frame
          rem (swing out frames 0-3, return frames 4-7), missile
          rem deactivated when attack completes
          rem Mutates: temp1-temp6 (used for calculations), missileX[],
          rem missileY_W[] (global arrays) = missile positions,
          rem missileVelocityX[], missileVelocityY[] (global arrays) =
          rem missile velocities (zeroed), missileActive (global) =
          rem missile active flags (via DeactivateMissile)
          rem Called Routines: DeactivateMissile - deactivates missile
          rem when attack completes
          rem Constraints: Knight Guy missile swings out 1-4 pixels
          rem (frames 0-3) then returns (frames 4-7). Deactivates when
          rem animation state != ActionAttackExecute (14)
          dim HKG_playerIndex = temp1
          dim HKG_facing = temp4
          dim HKG_emissionHeight = temp5
          dim HKG_missileX = temp2
          dim HKG_missileY = temp3
          dim HKG_animationState = temp6
          dim HKG_swordOffset = velocityCalculation
          
          let HKG_facing = playerState[HKG_playerIndex] & PlayerStateBitFacing : rem Get facing direction (bit 0: 0=left, 1=right)
          
          let HKG_emissionHeight = CharacterMissileEmissionHeights[UOM_characterType] : rem Get emission height from character data
          
          rem Check if attack animation is complete
          let HKG_animationState = playerState[HKG_playerIndex] : rem Extract animation state (bits 4-7)
          rem Extract animation state (bits 4-7) using bit shift
          asm
            lsr HKG_animationState
            lsr HKG_animationState
            lsr HKG_animationState
            lsr HKG_animationState
end
          
          if HKG_animationState = 14 then KnightGuyAttackActive : rem If animation state is not ActionAttackExecute (14), attack is complete
          goto DeactivateMissile : rem Attack complete - deactivate missile
          
KnightGuyAttackActive
          rem Get current animation frame within Execute sequence (0-7)
          let HKG_swordOffset = currentAnimationFrame_R[HKG_playerIndex] : rem Read from SCRAM and calculate offset immediately
          
          rem Calculate sword swing offset based on animation frame
          rem Frames 0-3: Move away from player (sword swing out)
          rem Frames 4-7: Return to start (sword swing back)
          if HKG_swordOffset < 4 then KnightGuySwingOut : rem Maximum swing distance: 4 pixels
          rem Frames 4-7: Returning to start
          rem Calculate return offset: (7 - frame) pixels
          rem Frame 4: 3 pixels away, Frame 5: 2 pixels, Frame 6: 1
          rem pixel, Frame 7: 0 pixels
          let HKG_swordOffset = 7 - HKG_swordOffset
          goto KnightGuySetPosition
          
KnightGuySwingOut
          rem Frames 0-3: Moving away from player
          rem Calculate swing offset: (frame + 1) pixels
          let HKG_swordOffset = HKG_swordOffset + 1 : rem Frame 0: 1 pixel, Frame 1: 2 pixels, Frame 2: 3 pixels, Frame 3: 4 pixels
          
KnightGuySetPosition
          rem Calculate base X position (partially overlapping player)
          rem Start position: player X + 8 pixels (halfway through
          rem player sprite)
          let HKG_missileX = playerX[HKG_playerIndex] + 8 : rem Then apply swing offset in facing direction
          rem Base position: center of player sprite
          
          if HKG_facing = 0 then KnightGuySwingLeft : rem Apply swing offset in facing direction
          let HKG_missileX = HKG_missileX + HKG_swordOffset : rem Facing right: move right (positive offset)
          goto KnightGuySetY
          
KnightGuySwingLeft
          let HKG_missileX = HKG_missileX - HKG_swordOffset : rem Facing left: move left (negative offset)
          
KnightGuySetY
          let HKG_missileY = playerY[HKG_playerIndex] + HKG_emissionHeight : rem Calculate Y position (player Y + emission height)
          
          let missileX[HKG_playerIndex] = HKG_missileX : rem Update missile position
          let missileY_W[HKG_playerIndex] = HKG_missileY
          
          rem Zero velocities to prevent projectile movement
          rem   frame
          let missileVelocityX[HKG_playerIndex] = 0 : rem Position is updated directly each frame based on animation
          let missileVelocityY[HKG_playerIndex] = 0
          
          rem Skip normal movement and collision checks
          return

CheckMissileBounds
          rem
          rem Check Missile Bounds
          rem Checks if missile is off-screen.
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem OUTPUT:
          rem   temp4 = 1 if off-screen, 0 if on-screen
          return
          rem Checks if missile is off-screen (currently
          rem incomplete/unused)
          rem Input: temp1 = player index (0-3)
          rem Output: temp4 = 1 if off-screen, 0 if on-screen (not
          rem implemented)
          rem Mutates: None (incomplete)
MissileSysPF
          rem Called Routines: None
          rem Constraints: Currently incomplete/unused - bounds checking
          rem handled inline in UpdateOneMissile
          rem Get missile X/Y position (read from _R port)
          rem
          rem Check Missile-playfield Collision
          rem Checks if missile hit the playfield (walls, obstacles).
          rem Uses pfread to check playfield pixel at missile position.
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem OUTPUT:
          rem   temp4 = 1 if hit playfield, 0 if clear
          rem Checks if missile hit the playfield (walls, obstacles)
          rem using pfread
          rem Input: temp1 = player index (0-3), missileX[] (global
          rem array) = missile X positions, missileY_R[] (global SCRAM
          rem array) = missile Y positions
          rem Output: temp4 = 1 if hit playfield, 0 if clear, temp6 =
          rem playfield column (0-31)
          rem Mutates: temp2-temp6 (used for calculations)
          rem Called Routines: Div5Compute - converts X pixel to
          rem playfield column
          rem Constraints: Uses pfread to check playfield pixel at
          rem missile position. X coordinate divided by 5 to get column
          rem (0-31)
          let temp2  = missileX[temp1] : rem Get missile X/Y position (read from _R port)
          let temp3  = missileY_R[temp1]
          
          rem Convert X/Y to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160), 192 pixels
          rem   tall
          rem pfread uses playfield coordinates: column (0-31), row
          gosub Div5Compute : rem   (0-11 or 0-31 depending on pfres)
          rem Convert X pixel to playfield column (160/32 = 5)
          rem temp3 is already in pixel coordinates, pfread will handle
          rem   it
          
          rem Check if playfield pixel is set
          rem pfread(column, row) returns 0 if clear, non-zero if set
          let temp4 = 0 : rem pfread can only be used in if/then conditionals
          if pfread(temp6, temp3) then let temp4 = 1 : rem Default: clear
          rem Hit playfield
          
          return

          rem
          rem DIVIDE HELPERS (no Mul/div Support)
HalfTemp7
          asm
          rem HalfTemp7: integer divide temp7 by 2 using bit shift
          rem Helper: Divides temp7 by 2 using bit shift (integer
          rem division)
          rem Input: temp7 = value to divide
          rem Output: temp7 = value / 2 (integer division)
          rem Mutates: temp7 (divided by 2)
          rem Called Routines: None
          rem Constraints: Internal helper, uses assembly bit shift for
          rem performance
            lsr temp7
end
          return

Div5Compute
          rem Div5Compute: compute floor(temp2/5) into temp6 via
          rem   repeated subtraction
          rem Helper: Computes floor(temp2/5) into temp6 via repeated
          rem subtraction
          rem Input: temp2 = value to divide by 5
          rem Output: temp6 = floor(temp2/5), temp2 = temp2 mod 5
          rem (remainder)
          rem Mutates: temp2 (reduced by multiples of 5), temp6 (result)
          rem Called Routines: None
          rem Constraints: Internal helper for playfield coordinate
          rem conversion, uses repeated subtraction (no division
          rem support)
          let temp6  = 0
          if temp2 < 5 then return
Div5Loop
          let temp2  = temp2 - 5
          let temp6  = temp6 + 1
          if temp2>= 5 then Div5Loop
          return

CheckMissilePlayerCollision
          rem
          rem Check Missile-player Collision
          rem Checks if a missile hit any player (except the owner).
          rem Uses axis-aligned bounding box (AABB) collision detection.
          rem INPUT:
          rem   temp1 = missile owner player index (0-3)
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
          rem Checks if missile hit any player (except owner) using AABB
          rem collision detection
          rem Input: temp1 = missile owner player index (0-3),
          rem missileX[] (global array) = missile X positions,
          rem missileY_R[] (global SCRAM array) = missile Y positions,
          rem playerX[], playerY[] (global arrays) = player positions,
          rem playerHealth[] (global array) = player health,
          rem MissileAABBSize, PlayerSpriteHalfWidth, PlayerSpriteHeight
          rem (global constants) = collision bounds, MissileHitNotFound
          rem (global constant) = no hit value (255)
          rem Output: temp4 = hit player index (0-3), or
          rem MissileHitNotFound (255) if no hit
          rem Mutates: temp2-temp4 (used for calculations)
          rem Called Routines: None
          rem Constraints: Skips owner player and eliminated players
          rem (health = 0). Uses axis-aligned bounding box (AABB)
          rem collision detection
          let temp2  = missileX[temp1] : rem Get missile X/Y position (read from _R port)
          let temp3  = missileY_R[temp1]
          
          rem Missile bounding box
          rem temp2 = missile left, temp2+MissileAABBSize = missile
          rem   right
          rem temp3 = missile top, temp3+MissileAABBSize = missile
          rem   bottom
          
          let temp4 = MissileHitNotFound : rem Check collision with each player (except owner)
          rem Default: no hit
          
          if temp1  = 0 then MissileSkipPlayer0 : rem Check Player 1 (index 0)
          if playerHealth[0] = 0 then MissileSkipPlayer0
          if temp2>= playerX[0] + PlayerSpriteHalfWidth then MissileSkipPlayer0
          if temp2 + MissileAABBSize<= playerX[0] then MissileSkipPlayer0
          if temp3>= playerY[0] + PlayerSpriteHeight then MissileSkipPlayer0
          if temp3 + MissileAABBSize<= playerY[0] then MissileSkipPlayer0
          let temp4  = 0 : return
          rem Hit Player 1
MissileSkipPlayer0
          
          if temp1  = 1 then MissileSkipPlayer1 : rem Check Player 2 (index 1)
          if playerHealth[1] = 0 then MissileSkipPlayer1
          if temp2>= playerX[1] + PlayerSpriteHalfWidth then MissileSkipPlayer1
          if temp2 + MissileAABBSize<= playerX[1] then MissileSkipPlayer1
          if temp3>= playerY[1] + PlayerSpriteHeight then MissileSkipPlayer1
          if temp3 + MissileAABBSize<= playerY[1] then MissileSkipPlayer1
          let temp4  = 1 : return
          rem Hit Player 2
MissileSkipPlayer1
          
          if temp1  = 2 then MissileSkipPlayer2 : rem Check Player 3 (index 2)
          if playerHealth[2] = 0 then MissileSkipPlayer2
          if temp2>= playerX[2] + PlayerSpriteHalfWidth then MissileSkipPlayer2
          if temp2 + MissileAABBSize<= playerX[2] then MissileSkipPlayer2
          if temp3>= playerY[2] + PlayerSpriteHeight then MissileSkipPlayer2
          if temp3 + MissileAABBSize<= playerY[2] then MissileSkipPlayer2
          let temp4  = 2 : return
          rem Hit Player 3
MissileSkipPlayer2
          
          if temp1  = 3 then MissileSkipPlayer3 : rem Check Player 4 (index 3)
          if playerHealth[3] = 0 then MissileSkipPlayer3
          if temp2>= playerX[3] + PlayerSpriteHalfWidth then MissileSkipPlayer3
          if temp2 + MissileAABBSize<= playerX[3] then MissileSkipPlayer3
          if temp3>= playerY[3] + PlayerSpriteHeight then MissileSkipPlayer3
          if temp3 + MissileAABBSize<= playerY[3] then MissileSkipPlayer3
          let temp4  = 3 : return
          rem Hit Player 4
MissileSkipPlayer3
          
          return

HandleMissileHit
          rem
          rem Handle Missile Hit
          rem Processes a missile hitting a player.
          rem Applies damage, knockback, and visual/audio feedback.
          rem INPUT:
          rem   temp1 = attacker player index (0-3, missile owner)
          rem   temp4 = defender player index (0-3, hit player)
          rem Processes missile hitting a player (damage, knockback,
          rem hitstun, sound)
          rem Input: temp1 = attacker player index (0-3, missile owner),
          rem temp4 = defender player index (0-3, hit player),
          rem playerChar[] (global array) = character types,
          rem playerDamage[] (global array) = damage values,
          rem characterStateFlags_R[] (global SCRAM array) = character
          rem state flags (for Harpy dive mode), missileX[] (global
          rem array) = missile X positions, playerX[], playerY[] (global
          rem arrays) = player positions, CharacterWeights[] (global
          rem data table) = character weights, KnockbackImpulse,
          rem HitstunFrames (global constants) = physics constants,
          rem SoundAttackHit (global constant) = sound effect ID
          rem Output: Damage applied, knockback applied (weight-based),
          rem hitstun set, sound played
          rem Mutates: temp1-temp7 (used for calculations),
          rem playerHealth[] (global array) = player health
          rem (decremented), playerVelocityX[], playerVelocityXL[]
          rem (global arrays) = player velocities (knockback applied),
          rem playerRecoveryFrames[] (global array) = recovery frames
          rem (set to HitstunFrames), playerState[] (global array) =
          rem player states (recovery flag set), soundEffectID (global)
          rem = sound effect ID
          rem Called Routines: PlaySoundEffect (bank15) - plays hit
          rem sound
          rem Constraints: Harpy dive mode increases damage by 50%.
          rem Knockback scales with character weight (heavier = less
          rem knockback). Minimum 1 pixel knockback even for heaviest
          rem characters
          let temp5  = playerChar[temp1] : rem Get character type for damage calculation
          
          rem Apply damage from attacker to defender
          let temp6  = playerDamage[temp1] : rem Use playerDamage array for base damage amount
          
          if temp5 = 6 then HarpyCheckDive : rem Apply dive damage bonus for Harpy
          goto DiveCheckDone
HarpyCheckDive
          if !(characterStateFlags_R[temp1] & 4) then DiveCheckDone : rem Check if Harpy is in dive mode
          rem Not diving, skip bonus
          rem Apply 1.5x damage for diving attacks (temp6 + temp6/2 =
          rem   1.5 * temp6)
          dim HMS_temp6Half = temp7 : rem Divide by 2 using bit shift right 1 bit
          let HMS_temp6Half = temp6
          asm
            lsr HMS_temp6Half
end
          let temp6 = temp6 + HMS_temp6Half
DiveCheckDone
          
          rem Guard check is now handled before HandleMissileHit is
          rem   called
          rem This function only handles damage application
          
          let oldHealthValue = playerHealth[temp4] : rem Apply damage
          let playerHealth[temp4] = playerHealth[temp4] - temp6
          if playerHealth[temp4] > oldHealthValue then let playerHealth[temp4] = 0
          
          rem Apply knockback (weight-based scaling - heavier characters
          rem   resist more)
          rem Calculate direction: if missile moving right, push
          let temp2  = missileX[temp1] : rem   defender right
          
          rem Calculate weight-based knockback scaling
          rem Heavier characters resist knockback more (max weight =
          let characterWeight = playerChar[temp4] : rem   100)
          let characterWeight = CharacterWeights[characterWeight] : rem Get character index
          rem Get character weight (5-100) - overwrite with weight value
          rem Calculate scaled knockback: KnockbackImpulse * (100 -
          rem   weight) / 100
          rem Approximate: (KnockbackImpulse * (100 - weight)) / 100
          rem For KnockbackImpulse = 4: scaled = (4 * (100 - weight)) /
          rem   100
          rem Simplify to avoid division: if weight < 50, use full
          if characterWeight >= 50 then WeightBasedKnockbackScale : rem   knockback; else scale down
          let impulseStrength = KnockbackImpulse : rem Light characters (weight < 50): full knockback
          goto WeightBasedKnockbackApply
WeightBasedKnockbackScale
          rem Heavy characters (weight >= 50): reduced knockback
          rem Calculate: KnockbackImpulse * (100 - weight) / 100
          rem KnockbackImpulse = 4, so: 4 * (100 - weight) / 100
          rem Multiply first: 4 * velocityCalculation using bit shift
          let velocityCalculation = 100 - characterWeight : rem   (ASL 2)
          let impulseStrength = velocityCalculation : rem Resistance factor (0-50 for weights 50-100)
          rem Multiply by 4 (KnockbackImpulse = 4) using left shift 2
          rem   bits
          asm
            asl impulseStrength
            asl impulseStrength
end
          rem Divide by 100 - inlined for performance (fast
          let temp2 = impulseStrength : rem   approximation for values 0-255)
          if temp2 > 200 then let impulseStrength = 2
          if temp2 > 100 then if temp2 <= 200 then let impulseStrength = 1
          if temp2 <= 100 then let impulseStrength = 0
          if impulseStrength = 0 then impulseStrength = 1 : rem Scaled knockback (0, 1, or 2)
          rem Minimum 1 pixel knockback even for heaviest characters
WeightBasedKnockbackApply
          if temp2 >= playerX[temp4] then KnockbackRight : rem Apply scaled knockback impulse to velocity (not momentum)
          let playerVelocityX[temp4] = playerVelocityX[temp4] + impulseStrength : rem Missile from left, push right (positive velocity)
          let playerVelocityXL[temp4] = 0
          goto KnockbackDone : rem Zero subpixel when applying knockback impulse
KnockbackRight
          let playerVelocityX[temp4] = playerVelocityX[temp4] - impulseStrength : rem Missile from right, push left (negative velocity)
          let playerVelocityXL[temp4] = 0
          rem Zero subpixel when applying knockback impulse
KnockbackDone
          
          let playerRecoveryFrames[temp4] = HitstunFrames : rem Set recovery/hitstun frames
          rem 10 frames of hitstun
          
          let playerState[temp4] = playerState[temp4] | 8 : rem Synchronize playerState bit 3 with recovery frames
          rem Set bit 3 (recovery flag) when recovery frames are set
          
          let temp1  = SoundAttackHit : rem Play hit sound effect
          gosub PlaySoundEffect bank15
          
          rem Spawn damage indicator visual
          rem NOTE: VisualEffects.bas was phased out - damage indicators
          rem   handled inline
          
          return

HandleMissileBounce
          rem
          rem Handle Missile Bounce
          rem Handles wall bounce for missiles with bounce flag set.
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp5 = missile flags
          rem Handles wall bounce for missiles with bounce flag set
          rem (inverts X velocity, applies friction damping)
          rem Input: temp1 = player index (0-3), temp5 = missile flags,
          rem missileVelocityX[] (global array) = missile X velocities,
          rem MissileFlagFriction (global constant) = friction flag,
          rem MaxByteValue (global constant) = 255
          rem Output: X velocity inverted (bounced), friction damping
          rem applied if flag set
          rem Mutates: temp2, temp6 (used for calculations),
          rem missileVelocityX[] (global array) = missile X velocity
          rem (inverted and dampened)
          rem Called Routines: None
          rem Constraints: Velocity inverted using two’s complement. If
          rem friction flag set, velocity reduced by 50% (half). Missile
          rem continues bouncing (not deactivated)
          let missileVelocityXCalc = missileVelocityX[temp1]
          rem Get current X velocity
          rem Invert velocity (bounce back) using twos complement
          dim HMB_tempCalc = temp6 : rem Split calculation to avoid sbc #256 (256 > 255)
          let HMB_tempCalc = MaxByteValue - missileVelocityXCalc
          let missileVelocityXCalc = HMB_tempCalc + 1 : rem tempCalc = 255 - velocity
          rem velocity = (255 - velocity) + 1 = 256 - velocity (twos
          rem complement)
          
          if !(temp5 & MissileFlagFriction) then BounceDone : rem Apply friction damping if friction flag is set
          rem Reduce velocity by half (bit shift right by 1)
          rem Use bit shift instead of division to avoid complexity
          rem issues
          rem Subtraction works for both positive and negative values:
          rem   Positive: velocity - (velocity >> 1) = 0.5 velocity
          rem   (reduces)
          rem   Negative: velocity - (velocity >> 1) = 0.5 velocity
          rem   (reduces magnitude)
          dim HMB_dampenAmount = temp2
          let HMB_dampenAmount = missileVelocityXCalc
          rem Divide by 2 using bit shift right (LSR) - direct memory
          rem mode
          asm
            lsr HMB_dampenAmount
end
          let missileVelocityXCalc = missileVelocityXCalc - HMB_dampenAmount
BounceDone
          let missileVelocityX[temp1] = missileVelocityXCalc
          
          rem Continue bouncing (do not deactivate)
          return

DeactivateMissile
          rem
          rem Deactivate Missile
          rem Removes a missile from active status.
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem Removes a missile from active status (clears active bit)
          rem Input: temp1 = player index (0-3), BitMask[] (global data
          rem table) = bit masks, MaxByteValue (global constant) = 255,
          rem missileActive (global) = missile active flags
          rem Output: Missile deactivated (active bit cleared)
          rem Mutates: temp6 (used for bit manipulation), missileActive
          rem (global) = missile active flags (bit cleared)
          rem Called Routines: None
          rem Constraints: None
          let temp6 = BitMask[temp1] : rem Clear active bit for this player missile
          let temp6 = MaxByteValue - temp6
          let missileActive  = missileActive & temp6 : rem Invert bits
          return


