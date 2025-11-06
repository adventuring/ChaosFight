          rem ChaosFight - Source/Routines/MissileSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem MISSILE SYSTEM - 4-PLAYER MISSILE MANAGEMENT
          rem ==========================================================
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
          rem   player
          rem temp5 = scratch for character data lookups / missile flags
          rem   temp6 = scratch for bit manipulation / collision bounds
          rem ==========================================================

          rem ==========================================================
          rem GET PLAYER MISSILE BIT FLAG
          rem ==========================================================
          rem Calculates the bit flag for missile active tracking
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp6 = bit flag (1, 2, 4, or 8)
          rem EFFECTS: Uses temp6 for calculation
GetPlayerMissileBitFlag
          dim GPMBF_playerIndex = temp1
          dim GPMBF_bitFlag = temp6
          rem Calculate bit flag using O(1) array lookup: BitMask[playerIndex] (1, 2, 4, 8)
          let GPMBF_bitFlag = BitMask[GPMBF_playerIndex]
          let temp6 = GPMBF_bitFlag
          return

          rem ==========================================================
          rem SPAWN MISSILE
          rem ==========================================================
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
          
          rem Calculate initial missile position based on player
          rem   position and facing
          rem Facing is stored in playerState bit 0: 0=left, 1=right
          let SM_facing = playerState[SM_playerIndex] & PlayerStateBitFacing
          rem Get facing direction
          
          rem Set missile position using array access (write to _W port)
          let missileX[SM_playerIndex] = playerX[SM_playerIndex]
          let missileY_W[SM_playerIndex] = playerY[SM_playerIndex] + SM_bitFlag
          if SM_facing = 0 then let missileX[SM_playerIndex] = missileX[SM_playerIndex] - MissileSpawnOffsetLeft
          rem Facing left, spawn left
          if SM_facing = 1 then let missileX[SM_playerIndex] = missileX[SM_playerIndex] + MissileSpawnOffsetRight
          rem Facing right, spawn right
          
          rem Set active bit for this player missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          let temp1 = SM_playerIndex
          gosub GetPlayerMissileBitFlag
          let SM_bitFlag = temp6
          let missileActive  = missileActive | SM_bitFlag
          
          rem Initialize lifetime counter from character data table
          let missileLifetimeValue = CharacterMissileLifetime[SM_characterType]
          
          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile
          rem   lifetime
          let missileLifetime[SM_playerIndex] = missileLifetimeValue
          
          rem Initialize velocity from character data for friction
          rem   physics
          let SM_velocityCalc  = CharacterMissileMomentumX[SM_characterType]
          rem Get base X velocity
          if SM_facing = 0 then let SM_velocityCalc  = 0 - SM_velocityCalc
          rem Apply facing direction (left = negative)
          let missileVelocityX[SM_playerIndex] = SM_velocityCalc
          
          rem Initialize NUSIZ tracking from missile width
          rem NUSIZ bits 4-6: 00=1x, 01=2x, 10=4x (multiplied by 16:
          rem   0x00, 0x10, 0x20)
          dim SM_missileWidth = temp2
          let SM_missileWidth = CharacterMissileWidths[SM_characterType]
          rem Convert width to NUSIZ value (width 1=0x00, 2=0x10,
          rem   4=0x20) - inlined for performance
          if SM_missileWidth = 1 then let missileNUSIZ[SM_playerIndex] = 0 : goto SM_NUSIZDone
          rem 1x size (NUSIZ bits 4-6 = 00)
          if SM_missileWidth = 2 then let missileNUSIZ[SM_playerIndex] = 16 : goto SM_NUSIZDone
          rem 2x size (NUSIZ bits 4-6 = 01, value = 0x10 = 16)
          if SM_missileWidth = 4 then let missileNUSIZ[SM_playerIndex] = 32 : goto SM_NUSIZDone
          rem 4x size (NUSIZ bits 4-6 = 10, value = 0x20 = 32)
          rem Default to 1x if width not recognized
          let missileNUSIZ[SM_playerIndex] = 0
SM_NUSIZDone
          
          let SM_velocityCalc  = CharacterMissileMomentumY[SM_characterType]
          rem Get Y velocity
          
          rem Apply Harpy dive velocity bonus if in dive mode
          if SM_characterType = 6 then HarpyCheckDiveVelocity
          goto VelocityDone
HarpyCheckDiveVelocity
          dim HCDV_velocityCalc = temp6
          let HCDV_velocityCalc = SM_velocityCalc
          if (characterStateFlags_R[SM_playerIndex] & 4) then HarpyBoostDiveVelocity
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
          let missileVelocityY[SM_playerIndex] = SM_velocityCalc
          
          return

          rem ==========================================================
          rem UPDATE ALL MISSILES
          rem ==========================================================
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
          rem tail call
          goto UpdateOneMissile

          rem ==========================================================
          rem UPDATE ONE MISSILE
          rem ==========================================================
          rem Updates a single player missile.
          rem Handles movement, gravity, collisions, and lifetime.

          rem INPUT:
          rem   temp1 = player index (0-3)
UpdateOneMissile
          dim UOM_playerIndex = temp1
          dim UOM_bitFlag = temp6
          dim UOM_isActive = temp4
          dim UOM_savedIndex = temp6
          dim UOM_velocityX = temp2
          dim UOM_velocityY = temp3
          dim UOM_characterType = temp5
          dim UOM_missileFlags = temp5
          rem Check if this missile is active
          let temp1 = UOM_playerIndex
          gosub GetPlayerMissileBitFlag
          let UOM_bitFlag = temp6
          let UOM_isActive  = missileActive & UOM_bitFlag
          if UOM_isActive  = 0 then return
          rem Not active, skip
          
          rem Preserve player index since GetMissileFlags uses temp1
          rem Use temp6 temporarily to save player index (temp6 is used
          rem   for bit flags)
          let UOM_savedIndex  = UOM_playerIndex
          rem Save player index temporarily
          
          rem Get current velocities from stored arrays
          let UOM_velocityX  = missileVelocityX[UOM_playerIndex]
          rem X velocity (already facing-adjusted from spawn)
          let UOM_velocityY  = missileVelocityY[UOM_playerIndex]
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
          
          rem Special handling for Megax (character 5): stationary fire breath visual
          rem Megax missile stays adjacent to player during attack, no movement
          if UOM_characterType = CharMegax then goto HandleMegaxMissile
          
          rem Special handling for Knight Guy (character 7): sword swing visual
          rem Knight Guy missile appears overlapping, moves away, returns, then vanishes
          if UOM_characterType = CharKnightGuy then goto HandleKnightGuyMissile
          
          rem Apply gravity if flag is set
          if !(UOM_missileFlags & MissileFlagGravity) then GravityDone
          let UOM_velocityY = UOM_velocityY + GravityPerFrame
          rem Add gravity (1 pixel/frame down)
          let missileVelocityY[UOM_playerIndex] = UOM_velocityY
          rem Update stored Y velocity
GravityDone
          
          rem Apply friction if flag is set (curling stone deceleration
          rem   with coefficient)
          if !(temp5 & MissileFlagFriction) then FrictionDone
          let missileVelocityXCalc = missileVelocityX[UOM_playerIndex]
          rem Get current X velocity
          
          rem Apply ice-like friction: reduce by
          rem   CurlingFrictionCoefficient/256 per frame
          rem CurlingFrictionCoefficient = 4 (Q8 fixed-point: 4/256 =
          rem   1.56% per frame)
          rem Derived from constant: reduction = velocity / (256 /
          rem   CurlingFrictionCoefficient) = velocity / 64
          if missileVelocityXCalc = 0 then FrictionDone
          rem Zero velocity, no friction to apply
          
          rem Calculate friction reduction (velocity / 64, approximates
          rem   1.56% reduction)
          let velocityCalculation = missileVelocityXCalc
          rem Check if velocity is negative (two’s complement: values >
          rem   127 are negative)
          rem For unsigned bytes, negative values in two’s complement
          rem   are 128-255
          if velocityCalculation > 127 then FrictionNegative
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
          rem Reduce by 1/64 (1.56% - ice-like friction)
          let missileVelocityXCalc = missileVelocityXCalc - velocityCalculation
          goto FrictionApply
FrictionNegative
          rem Negative velocity - convert to positive for division
          let velocityCalculation = 0 - velocityCalculation
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
          rem Reduce by 1/64 (1.56% - ice-like friction)
          let missileVelocityXCalc = missileVelocityXCalc + velocityCalculation
          rem Add back (since missileVelocityXCalc was negative)
FrictionApply
          let missileVelocityX[UOM_playerIndex] = missileVelocityXCalc
          let temp2  = missileVelocityXCalc
          rem Update temp2 for position calculation
          rem Check if velocity dropped below threshold
          rem tail call
          if missileVelocityXCalc < MinimumVelocityThreshold && missileVelocityXCalc > -MinimumVelocityThreshold then goto DeactivateMissile
          rem Update stored X velocity with friction applied
          let missileVelocityX[UOM_playerIndex] = missileVelocityXCalc
FrictionDone
          
          rem Update missile position
          rem Read-Modify-Write: Read from _R, modify, write to _W
          let missileX[UOM_playerIndex] = missileX[UOM_playerIndex] + temp2
          dim UOM_missileY = temp4
          let UOM_missileY = missileY_R[UOM_playerIndex]
          let UOM_missileY = UOM_missileY + temp3
          let missileY_W[UOM_playerIndex] = UOM_missileY
          
          rem Check screen bounds and wrap around horizontally
          rem Missiles wrap around horizontally like players (all arenas)
          rem Get missile X/Y position (read from _R port)
          let temp2  = missileX[temp1]
          let temp3  = missileY_R[temp1]
          
          rem Wrap around horizontally: X < 10 wraps to 150, X > 150 wraps
          rem   to 10
          rem Match player wrap-around behavior (same boundaries: 10-150)
          if temp2 < 10 then let temp2 = 150 : let missileX[temp1] = 150
          rem Off left edge, wrap to right
          if temp2 > 150 then let temp2 = 10 : let missileX[temp1] = 10
          rem Off right edge, wrap to left
          
          rem Check vertical bounds (deactivate if off top/bottom, like
          rem   players are clamped)
          let temp4  = 0
          if temp3 > ScreenBottom then temp4  = 1
          rem Off bottom, deactivate
          rem Byte-safe top bound: if wrapped past 0 due to subtract,
          rem   temp3 will be > original
          let temp5  = temp3
          rem Assuming prior update may have subtracted from temp3
          rem   earlier in loop
          if temp3 > ScreenTopWrapThreshold then temp4  = 1
          rem Off top, deactivate
          if temp4 then goto DeactivateMissile 
          rem Off-screen vertically, deactivate
          
          rem Check collision with playfield if flag is set
          rem Reload missile flags (temp5 was overwritten with Y
          rem   position above)
          let temp5 = playerChar[UOM_playerIndex]
          let temp1 = temp5
          gosub bank6 GetMissileFlags
          let temp5 = temp2
          rem temp5 now contains missile flags again
          let temp1 = UOM_playerIndex
          rem Restore player index for MissileCollPF
          if !(temp5 & MissileFlagHitBackground) then PlayfieldCollisionDone
          gosub bank7 MissileCollPF
          if !temp4 then PlayfieldCollisionDone
          rem Collision detected - check if should bounce or deactivate
          if temp5 & MissileFlagBounce then gosub HandleMissileBounce : return
          rem Bounced - continue moving (HandleMissileBounce returns)
          gosub DeactivateMissile : return
          rem No bounce - deactivate on background hit
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
          
          rem Bounce the missile: invert X velocity and apply friction
          rem   damping
          let temp6  = missileVelocityX[UOM_playerIndex]
          let temp6  = 0 - temp6
          rem Invert X velocity (bounce back)
          rem Apply friction damping on bounce (reduce by 25% for guard
          rem   bounce)
          rem Divide by 4 using bit shift (2 right shifts)
          rem Copy to velocityCalculation first, then shift in-place
          let velocityCalculation = temp6
          asm
            lsr velocityCalculation
            lsr velocityCalculation
end
          let temp6  = temp6 - velocityCalculation
          rem Reduce bounce velocity by 25%
          let missileVelocityX[UOM_playerIndex] = temp6
          
          rem Continue without deactivating - missile bounces and
          rem   continues
          goto MissileSystemNoHit
          
HandleMissileDamage
          gosub HandleMissileHit
          rem HandleMissileHit applies damage and effects
          rem tail call
          goto DeactivateMissile
          rem Missile disappears after hitting player
MissileSystemNoHit
          
          rem Decrement lifetime counter and check expiration
          rem Retrieve current lifetime for this missile
          let missileLifetimeValue = missileLifetime[UOM_playerIndex]
          
          rem Decrement if not set to infinite (infinite until
          rem   collision)
          if missileLifetimeValue = MissileLifetimeInfinite then MissileUpdateComplete
          let missileLifetimeValue = missileLifetimeValue - 1
          rem tail call
          if missileLifetimeValue = 0 then goto DeactivateMissile
          let missileLifetime[UOM_playerIndex] = missileLifetimeValue
MissileUpdateComplete
          
          return

          rem ==========================================================
          rem HANDLE MEGAX MISSILE (Stationary Fire Breath Visual)
          rem ==========================================================
          rem Megax missile stays adjacent to player, no movement.
          rem Missile appears when attack starts, stays during attack phase,
          rem   and vanishes when attack animation completes.
HandleMegaxMissile
          dim HMM_playerIndex = temp1
          dim HMM_facing = temp4
          dim HMM_emissionHeight = temp5
          dim HMM_missileX = temp2
          dim HMM_missileY = temp3
          dim HMM_animationState = temp6
          
          rem Get facing direction (bit 0: 0=left, 1=right)
          let HMM_facing = playerState[HMM_playerIndex] & PlayerStateBitFacing
          
          rem Get emission height from character data
          let HMM_emissionHeight = CharacterMissileEmissionHeights[UOM_characterType]
          
          rem Lock missile position to player position (adjacent, no movement)
          rem Calculate X position based on player position and facing
          let HMM_missileX = playerX[HMM_playerIndex]
          if HMM_facing = 0 then let HMM_missileX = HMM_missileX - MissileSpawnOffsetLeft
          rem Facing left, spawn left
          if HMM_facing = 1 then let HMM_missileX = HMM_missileX + MissileSpawnOffsetRight
          rem Facing right, spawn right
          
          rem Calculate Y position (player Y + emission height)
          let HMM_missileY = playerY[HMM_playerIndex] + HMM_emissionHeight
          
          rem Update missile position (locked to player)
          let missileX[HMM_playerIndex] = HMM_missileX
          let missileY_W[HMM_playerIndex] = HMM_missileY
          
          rem Zero velocities to prevent any movement
          let missileVelocityX[HMM_playerIndex] = 0
          let missileVelocityY[HMM_playerIndex] = 0
          
          rem Check if attack animation is complete
          rem Animation state is in bits 4-7 of playerState
          rem ActionAttackExecute = 14 (0xE)
          rem Extract animation state (bits 4-7)
          let HMM_animationState = playerState[HMM_playerIndex]
          rem Extract animation state (bits 4-7) using bit shift
          asm
            lsr HMM_animationState
            lsr HMM_animationState
            lsr HMM_animationState
            lsr HMM_animationState
end
          
          rem If animation state is not ActionAttackExecute (14), attack is complete
          rem   deactivate
          rem ActionAttackExecute = 14, so if animationState != 14,
          if HMM_animationState = 14 then MegaxMissileActive
          rem Attack complete - deactivate missile
          goto DeactivateMissile
          
MegaxMissileActive
          rem Attack still active - missile stays visible
          rem Skip normal movement and collision checks
          return

          rem ==========================================================
          rem HANDLE KNIGHT GUY MISSILE (Sword Swing Visual)
          rem ==========================================================
          rem Knight Guy missile appears partially overlapping player,
          rem   moves slightly away during attack phase (sword swing),
          rem   returns to start position, and vanishes when attack
          rem   completes.
HandleKnightGuyMissile
          dim HKG_playerIndex = temp1
          dim HKG_facing = temp4
          dim HKG_emissionHeight = temp5
          dim HKG_missileX = temp2
          dim HKG_missileY = temp3
          dim HKG_animationState = temp6
          dim HKG_swordOffset = velocityCalculation
          
          rem Get facing direction (bit 0: 0=left, 1=right)
          let HKG_facing = playerState[HKG_playerIndex] & PlayerStateBitFacing
          
          rem Get emission height from character data
          let HKG_emissionHeight = CharacterMissileEmissionHeights[UOM_characterType]
          
          rem Check if attack animation is complete
          rem Extract animation state (bits 4-7)
          let HKG_animationState = playerState[HKG_playerIndex]
          rem Extract animation state (bits 4-7) using bit shift
          asm
            lsr HKG_animationState
            lsr HKG_animationState
            lsr HKG_animationState
            lsr HKG_animationState
end
          
          rem If animation state is not ActionAttackExecute (14), attack is complete
          if HKG_animationState = 14 then KnightGuyAttackActive
          rem Attack complete - deactivate missile
          goto DeactivateMissile
          
KnightGuyAttackActive
          rem Get current animation frame within Execute sequence (0-7)
          rem Read from SCRAM and calculate offset immediately
          let HKG_swordOffset = currentAnimationFrame_R[HKG_playerIndex]
          
          rem Calculate sword swing offset based on animation frame
          rem Frames 0-3: Move away from player (sword swing out)
          rem Frames 4-7: Return to start (sword swing back)
          rem Maximum swing distance: 4 pixels
          if HKG_swordOffset < 4 then KnightGuySwingOut
          rem Frames 4-7: Returning to start
          rem Calculate return offset: (7 - frame) pixels
          rem Frame 4: 3 pixels away, Frame 5: 2 pixels, Frame 6: 1 pixel, Frame 7: 0 pixels
          let HKG_swordOffset = 7 - HKG_swordOffset
          goto KnightGuySetPosition
          
KnightGuySwingOut
          rem Frames 0-3: Moving away from player
          rem Calculate swing offset: (frame + 1) pixels
          rem Frame 0: 1 pixel, Frame 1: 2 pixels, Frame 2: 3 pixels, Frame 3: 4 pixels
          let HKG_swordOffset = HKG_swordOffset + 1
          
KnightGuySetPosition
          rem Calculate base X position (partially overlapping player)
          rem Start position: player X + 8 pixels (halfway through player sprite)
          rem Then apply swing offset in facing direction
          let HKG_missileX = playerX[HKG_playerIndex] + 8
          rem Base position: center of player sprite
          
          rem Apply swing offset in facing direction
          if HKG_facing = 0 then KnightGuySwingLeft
          rem Facing right: move right (positive offset)
          let HKG_missileX = HKG_missileX + HKG_swordOffset
          goto KnightGuySetY
          
KnightGuySwingLeft
          rem Facing left: move left (negative offset)
          let HKG_missileX = HKG_missileX - HKG_swordOffset
          
KnightGuySetY
          rem Calculate Y position (player Y + emission height)
          let HKG_missileY = playerY[HKG_playerIndex] + HKG_emissionHeight
          
          rem Update missile position
          let missileX[HKG_playerIndex] = HKG_missileX
          let missileY_W[HKG_playerIndex] = HKG_missileY
          
          rem Zero velocities to prevent projectile movement
          rem   frame
          rem Position is updated directly each frame based on animation
          let missileVelocityX[HKG_playerIndex] = 0
          let missileVelocityY[HKG_playerIndex] = 0
          
          rem Skip normal movement and collision checks
          return

          rem ==========================================================
          rem CHECK MISSILE BOUNDS
          rem ==========================================================
          rem Checks if missile is off-screen.

          rem INPUT:
          rem   temp1 = player index (0-3)

          rem OUTPUT:
          rem   temp4 = 1 if off-screen, 0 if on-screen
CheckMissileBounds
          rem Get missile X/Y position (read from _R port)
          
          return

          rem ==========================================================
          rem CHECK MISSILE-PLAYFIELD COLLISION
          rem ==========================================================
          rem Checks if missile hit the playfield (walls, obstacles).
          rem Uses pfread to check playfield pixel at missile position.

          rem INPUT:
          rem   temp1 = player index (0-3)

          rem OUTPUT:
          rem   temp4 = 1 if hit playfield, 0 if clear
MissileSysPF
          rem Get missile X/Y position (read from _R port)
          let temp2  = missileX[temp1]
          let temp3  = missileY_R[temp1]
          
          rem Convert X/Y to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160), 192 pixels
          rem   tall
          rem pfread uses playfield coordinates: column (0-31), row
          rem   (0-11 or 0-31 depending on pfres)
          gosub Div5Compute 
          rem Convert X pixel to playfield column (160/32 = 5)
          rem temp3 is already in pixel coordinates, pfread will handle
          rem   it
          
          rem Check if playfield pixel is set
          rem pfread(column, row) returns 0 if clear, non-zero if set
          rem pfread can only be used in if/then conditionals
          let temp4 = 0
          rem Default: clear
          if pfread(temp6, temp3) then let temp4 = 1
          rem Hit playfield
          
          return

          rem ==========================================================
          rem DIVIDE HELPERS (NO MUL/DIV SUPPORT)
          rem ==========================================================
          rem HalfTemp7: integer divide temp7 by 2 using bit shift
HalfTemp7
          asm
            lsr temp7
end
          return

          rem Div5Compute: compute floor(temp2/5) into temp6 via
          rem   repeated subtraction
Div5Compute
          let temp6  = 0
          if temp2 < 5 then return
Div5Loop
          let temp2  = temp2 - 5
          let temp6  = temp6 + 1
          if temp2>= 5 then Div5Loop
          return

          rem ==========================================================
          rem CHECK MISSILE-PLAYER COLLISION
          rem ==========================================================
          rem Checks if a missile hit any player (except the owner).
          rem Uses axis-aligned bounding box (AABB) collision detection.

          rem INPUT:
          rem   temp1 = missile owner player index (0-3)

          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckMissilePlayerCollision
          rem Get missile X/Y position (read from _R port)
          let temp2  = missileX[temp1]
          let temp3  = missileY_R[temp1]
          
          rem Missile bounding box
          rem temp2 = missile left, temp2+MissileAABBSize = missile
          rem   right
          rem temp3 = missile top, temp3+MissileAABBSize = missile
          rem   bottom
          
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

          rem ==========================================================
          rem HANDLE MISSILE HIT
          rem ==========================================================
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
          if !(characterStateFlags_R[temp1] & 4) then DiveCheckDone
          rem Not diving, skip bonus
          rem Apply 1.5x damage for diving attacks (temp6 + temp6/2 =
          rem   1.5 * temp6)
          rem Divide by 2 using bit shift right 1 bit
          dim HMS_temp6Half = temp7
          let HMS_temp6Half = temp6
          asm
            lsr HMS_temp6Half
end
          let temp6 = temp6 + HMS_temp6Half
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
          let temp2  = missileX[temp1]
          
          rem Calculate weight-based knockback scaling
          rem Heavier characters resist knockback more (max weight =
          rem   100)
          let characterWeight = playerChar[temp4]
          rem Get character index
          let characterWeight = CharacterWeights[characterWeight]
          rem Get character weight (5-100) - overwrite with weight value
          rem Calculate scaled knockback: KnockbackImpulse * (100 -
          rem   weight) / 100
          rem Approximate: (KnockbackImpulse * (100 - weight)) / 100
          rem For KnockbackImpulse = 4: scaled = (4 * (100 - weight)) /
          rem   100
          rem Simplify to avoid division: if weight < 50, use full
          rem   knockback; else scale down
          if characterWeight >= 50 then WeightBasedKnockbackScale
          rem Light characters (weight < 50): full knockback
          let impulseStrength = KnockbackImpulse
          goto WeightBasedKnockbackApply
WeightBasedKnockbackScale
          rem Heavy characters (weight >= 50): reduced knockback
          rem Calculate: KnockbackImpulse * (100 - weight) / 100
          rem KnockbackImpulse = 4, so: 4 * (100 - weight) / 100
          rem Multiply first: 4 * velocityCalculation using bit shift
          rem   (ASL 2)
          let velocityCalculation = 100 - characterWeight
          rem Resistance factor (0-50 for weights 50-100)
          let impulseStrength = velocityCalculation
          rem Multiply by 4 (KnockbackImpulse = 4) using left shift 2
          rem   bits
          asm
            asl impulseStrength
            asl impulseStrength
end
          rem Divide by 100 - inlined for performance (fast
          rem   approximation for values 0-255)
          let temp2 = impulseStrength
          if temp2 > 200 then let impulseStrength = 2
          if temp2 > 100 then if temp2 <= 200 then let impulseStrength = 1
          if temp2 <= 100 then let impulseStrength = 0
          rem Scaled knockback (0, 1, or 2)
          if impulseStrength = 0 then impulseStrength = 1
          rem Minimum 1 pixel knockback even for heaviest characters
WeightBasedKnockbackApply
          rem Apply scaled knockback impulse to velocity (not momentum)
          if temp2 >= playerX[temp4] then KnockbackRight
          rem Missile from left, push right (positive velocity)
          let playerVelocityX[temp4] = playerVelocityX[temp4] + impulseStrength
          let playerVelocityXL[temp4] = 0
          rem Zero subpixel when applying knockback impulse
          goto KnockbackDone
KnockbackRight
          rem Missile from right, push left (negative velocity)
          let playerVelocityX[temp4] = playerVelocityX[temp4] - impulseStrength
          let playerVelocityXL[temp4] = 0
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
          rem NOTE: VisualEffects.bas was phased out - damage indicators
          rem   handled inline
          
          return

          rem ==========================================================
          rem HANDLE MISSILE BOUNCE
          rem ==========================================================
          rem Handles wall bounce for missiles with bounce flag set.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp5 = missile flags
HandleMissileBounce
          let missileVelocityXCalc = missileVelocityX[temp1]
          rem Get current X velocity
          rem Invert velocity (bounce back) using twos complement
          rem Split calculation to avoid sbc #256 (256 > 255)
          dim HMB_tempCalc = temp6
          let HMB_tempCalc = MaxByteValue - missileVelocityXCalc
          rem tempCalc = 255 - velocity
          let missileVelocityXCalc = HMB_tempCalc + 1
          rem velocity = (255 - velocity) + 1 = 256 - velocity (twos complement)
          
          rem Apply friction damping if friction flag is set
          if !(temp5 & MissileFlagFriction) then BounceDone
          rem Reduce velocity by half (bit shift right by 1)
          rem Use bit shift instead of division to avoid complexity issues
          rem Subtraction works for both positive and negative values:
          rem   Positive: velocity - (velocity >> 1) = 0.5 velocity (reduces)
          rem   Negative: velocity - (velocity >> 1) = 0.5 velocity (reduces magnitude)
          dim HMB_dampenAmount = temp2
          let HMB_dampenAmount = missileVelocityXCalc
          rem Divide by 2 using bit shift right (LSR) - direct memory mode
          asm
            lsr HMB_dampenAmount
end
          let missileVelocityXCalc = missileVelocityXCalc - HMB_dampenAmount
BounceDone
          let missileVelocityX[temp1] = missileVelocityXCalc
          
          rem Continue bouncing (don’t deactivate)
          return

          rem ==========================================================
          rem DEACTIVATE MISSILE
          rem ==========================================================
          rem Removes a missile from active status.

          rem INPUT:
          rem   temp1 = player index (0-3)
DeactivateMissile
          rem Clear active bit for this player missile
          let temp6 = BitMask[temp1]
          let temp6 = MaxByteValue - temp6
          rem Invert bits
          let missileActive  = missileActive & temp6
          return


