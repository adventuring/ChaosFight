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
          rem Get character type for this player
          let temp5  = playerChar[temp1]
          
          rem Read missile emission height from character data table
          let temp6  = CharacterMissileEmissionHeights[temp5]
          
          rem Calculate initial missile position based on player position and facing
          rem Facing is stored in playerState bit 0: 0=left, 1=right
          let temp4  = playerState[temp1] & 1
          rem Get facing direction
          
          rem Set missile position using array access
          let missileX[temp1] = playerX[temp1]
          let missileY[temp1] = playerY[temp1] + temp6
          let if temp4 = 0 then missileX[temp1] = missileX[temp1] - MissileSpawnOffsetLeft
          rem Facing left, spawn left
          let if temp4 = 1 then missileX[temp1] = missileX[temp1] + MissileSpawnOffsetRight
          rem Facing right, spawn right
          
          rem Set active bit for this player missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          let if temp1 = 0 then temp6  = 1
          let if temp1 = 1 then temp6  = 2
          let if temp1 = 2 then temp6  = 4
          let if temp1 = 3 then temp6  = 8
          let missileActive  = missileActive | temp6
          
          rem Initialize lifetime counter from character data table
          let temp7  = CharacterMissileLifetime[temp5]
          
          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile lifetime
          let missileLifetime[temp1] = temp7
          
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
          rem Check if this missile is active
          let temp6  = 1
          let if temp1 = 1 then temp6  = 2
          let if temp1 = 2 then temp6  = 4
          let if temp1 = 3 then temp6  = 8
          let temp4  = missileActive & temp6
          let if temp4  = 0 then return
          rem Not active, skip
          
          rem Get character type to look up missile properties
          let temp5  = playerChar[temp1]
          
          rem Read missile momentum from character data (in Bank 6)
          let temp1  = temp5
          rem Character index for data lookup
          gosub bank6 GetMissileMomentumX
          let temp6  = temp2
          rem Store base X momentum
          let temp1  = temp5
          rem Restore for Y lookup
          gosub bank6 GetMissileMomentumY
          let temp3  = temp2
          rem Y momentum (already in correct form)
          
          rem Apply facing direction to X momentum
          let temp4  = playerState[temp1] & 1
          rem Get facing direction
          let if temp4 = 0 then temp2  = 0 - temp6 : goto FacingSet
          let temp2  = temp6
FacingSet
          
          rem Read missile flags from character data (in Bank 6)
          let temp1  = temp5
          gosub bank6 GetMissileFlags
          let temp5  = temp2
          rem Store flags for later use
          
          rem Apply gravity if flag is set
          let if temp5 & 4 then temp3  = temp3 + GravityPerFrame
          rem Add gravity (1 pixel/frame down)
          
          rem Update missile position
          let missileX[temp1] = missileX[temp1] + temp2
          let missileY[temp1] = missileY[temp1] + temp3
          
          rem Check screen bounds
          gosub CheckMissileBounds
          if temp4 then gosub DeactivateMissile : return 
          rem Off-screen, deactivate
          
          rem Check collision with playfield if flag is set
          if !(temp5 & 1) then PlayfieldCollisionDone
          gosub bank7 MissileCollPF
          if !temp4 then PlayfieldCollisionDone
          let if temp5 & 8 then temp7  = missileVelX[temp1] : temp7 = $FF - temp7 + 1 : gosub HalfTemp7 : missileVelX[temp1] = temp7 : gosub DeactivateMissile : return
          gosub DeactivateMissile : return
PlayfieldCollisionDone
          
          rem Check collision with players
          rem This handles both visible missiles and AOE attacks
          gosub bank7 CheckAllMissileCollisions
          rem Check if hit was found (temp4 != 255)
          let if temp4  = 255 then goto MissileSystemNoHit
          gosub HandleMissileHit
          gosub DeactivateMissile
          return
MissileSystemNoHit
          
          rem Decrement lifetime counter and check expiration
          rem Retrieve current lifetime for this missile
          let temp8  = missileLifetime[temp1]
          
          rem Decrement if not set to 255 (infinite until collision)
          let if temp8  = 255 then MissileUpdateComplete
          let temp8  = temp8 - 1
          let if temp8  = 0 then gosub DeactivateMissile : return
          let missileLifetime[temp1] = temp8
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
          let if temp2 > ScreenInsetX + ScreenUsableWidth then temp4  = 1
          rem Off right edge (16 + 128)
          let if temp2 < ScreenInsetX then temp4  = 1
          rem Off left edge
          let if temp3 > ScreenBottom then temp4  = 1
          rem Off bottom
          rem Byte-safe top bound: if wrapped past 0 due to subtract, temp3 will be > original
          let temp5  = temp3
          rem Assuming prior update may have subtracted from temp3 earlier in loop
          let if temp3 > ScreenTopWrapThreshold then temp4  = 1
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
          let temp4  = 0
          rem Default: clear
          let if pfread(temp6, temp3) then temp4  = 1
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
          let if temp2 > = 5 then goto Div5Loop
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
          let temp4  = 255
          rem Default: no hit
          
          rem Check Player 1 (index 0)
          let if temp1  = 0 then goto MissileSkipPlayer0
          let if playerHealth[0] = 0 then goto MissileSkipPlayer0
          let if temp2 > = playerX[0] + PlayerSpriteHalfWidth then goto MissileSkipPlayer0
          let if temp2 + MissileAABBSize < = playerX[0] then goto MissileSkipPlayer0
          let if temp3 > = playerY[0] + PlayerSpriteHeight then goto MissileSkipPlayer0
          let if temp3 + MissileAABBSize < = playerY[0] then goto MissileSkipPlayer0
          let temp4  = 0 : return
          rem Hit Player 1
MissileSkipPlayer0
          
          rem Check Player 2 (index 1)
          let if temp1  = 1 then goto MissileSkipPlayer1
          let if playerHealth[1] = 0 then goto MissileSkipPlayer1
          let if temp2 > = playerX[1] + PlayerSpriteHalfWidth then goto MissileSkipPlayer1
          let if temp2 + MissileAABBSize < = playerX[1] then goto MissileSkipPlayer1
          let if temp3 > = playerY[1] + PlayerSpriteHeight then goto MissileSkipPlayer1
          let if temp3 + MissileAABBSize < = playerY[1] then goto MissileSkipPlayer1
          let temp4  = 1 : return
          rem Hit Player 2
MissileSkipPlayer1
          
          rem Check Player 3 (index 2)
          let if temp1  = 2 then goto MissileSkipPlayer2
          let if playerHealth[2] = 0 then goto MissileSkipPlayer2
          let if temp2 > = playerX[2] + PlayerSpriteHalfWidth then goto MissileSkipPlayer2
          let if temp2 + MissileAABBSize < = playerX[2] then goto MissileSkipPlayer2
          let if temp3 > = playerY[2] + PlayerSpriteHeight then goto MissileSkipPlayer2
          let if temp3 + MissileAABBSize < = playerY[2] then goto MissileSkipPlayer2
          let temp4  = 2 : return
          rem Hit Player 3
MissileSkipPlayer2
          
          rem Check Player 4 (index 3)
          let if temp1  = 3 then goto MissileSkipPlayer3
          let if playerHealth[3] = 0 then goto MissileSkipPlayer3
          let if temp2 > = playerX[3] + PlayerSpriteHalfWidth then goto MissileSkipPlayer3
          let if temp2 + MissileAABBSize < = playerX[3] then goto MissileSkipPlayer3
          let if temp3 > = playerY[3] + PlayerSpriteHeight then goto MissileSkipPlayer3
          let if temp3 + MissileAABBSize < = playerY[3] then goto MissileSkipPlayer3
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
          
          rem Check if defender is guarding (bit 1 of playerState)
          let temp2  = playerState[temp4] & 2
          let if temp2 then temp1  = SoundGuard : gosub bank15 PlaySoundEffect : return
          rem Guarding - no damage, play guard sound
          
          rem Apply damage
          let temp7  = playerHealth[temp4]
          let playerHealth[temp4] = playerHealth[temp4] - temp6
          if playerHealth[temp4] > temp7 then playerHealth[temp4] = 0
          
          rem Apply knockback (simple version - push defender away from attacker)
          rem Calculate direction: if missile moving right, push defender right
          let temp2  = missileX[temp1]
          
          if temp2 < playerX[temp4] then playerMomentumX[temp4] = playerMomentumX[temp4] + KnockbackImpulse : goto KnockbackDone 
          rem Missile from left, push right
          let playerMomentumX[temp4] = playerMomentumX[temp4] - KnockbackImpulse
          rem Missile from right, push left
KnockbackDone
          
          rem Set recovery/hitstun frames
          let playerRecoveryFrames[temp4] = HitstunFrames
          rem 10 frames of hitstun
          
          rem Play hit sound effect
          let temp1  = SoundHit
          gosub bank15 PlaySoundEffect
          
          rem Spawn damage indicator visual
          gosub bank8 VisualShowDamageIndicator
          
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
          let if temp1 = 1 then temp6  = 2
          let if temp1 = 2 then temp6  = 4
          let if temp1 = 3 then temp6  = 8
          let temp6  = 255 - temp6
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
