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
          rem   currentPlayer = player index (0-3) being processed
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
          rem   currentPlayer = participant array index (0-3 maps to participants 1-4)

          rem PROCESS:
          rem   1. Look up character type for this player
          rem   2. Read missile properties from character data
          rem   3. Set missile X/Y based on player position, facing, and emission height
          rem   4. Set active bit for this player missile
          rem   5. Initialize lifetime counter from character data
SpawnMissile
          rem Get character type for this player
          temp5 = playerChar[currentPlayer]
          
          rem Read missile emission height from character data table
          temp6 = CharacterMissileEmissionHeights[temp5]
          
          rem Calculate initial missile position based on player position and facing
          rem Facing is stored in playerState bit 0: 0=left, 1=right
          temp4 = playerState[currentPlayer] & 1 
          rem Get facing direction
          
          rem Set missile position using array access
          let missileX[currentPlayer] = playerX[currentPlayer]
          let missileY[currentPlayer] = playerY[currentPlayer] + temp6
          if temp4 = 0 then missileX[currentPlayer] = missileX[currentPlayer] - MissileSpawnOffsetLeft 
          rem Facing left, spawn left
          if temp4 = 1 then missileX[currentPlayer] = missileX[currentPlayer] + MissileSpawnOffsetRight 
          rem Facing right, spawn right
          
          rem Set active bit for this participant's missile
          rem Bit 0 = Participant 1 (array [0]), Bit 1 = Participant 2 (array [1]), Bit 2 = Participant 3 (array [2]), Bit 3 = Participant 4 (array [3])
          rem Calculate bit flag: 1, 2, 4, 8 for array indices 0, 1, 2, 3 (mapping to participants 1, 2, 3, 4)
          if currentPlayer = 0 then temp6 = 1
          rem Array [0] = Participant 1 → bit 0
          if currentPlayer = 1 then temp6 = 2
          rem Array [1] = Participant 2 → bit 1
          if currentPlayer = 2 then temp6 = 4
          rem Array [2] = Participant 3 → bit 2
          if currentPlayer = 3 then temp6 = 8
          rem Array [3] = Participant 4 → bit 3
          let missileActive = missileActive | temp6
          
          rem Initialize lifetime counter from character data table
          let temp7 = CharacterMissileLifetime[temp5]
          
          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile lifetime
          let missileLifetime[currentPlayer] = temp7
          
          return

          rem =================================================================
          rem UPDATE ALL MISSILES
          rem =================================================================
          rem Called once per frame to update all active missiles.
          rem Updates position, checks collisions, handles lifetime.
UpdateAllMissiles
          rem Check each player missile
          currentPlayer = 0
          gosub UpdateOneMissile
          currentPlayer = 1
          gosub UpdateOneMissile
          currentPlayer = 2
          gosub UpdateOneMissile
          currentPlayer = 3
          gosub UpdateOneMissile
          return

          rem =================================================================
          rem UPDATE ONE MISSILE
          rem =================================================================
          rem Updates a single player missile.
          rem Handles movement, gravity, collisions, and lifetime.

          rem INPUT:
          rem   currentPlayer = participant array index (0-3 maps to participants 1-4)
UpdateOneMissile
          rem Check if this missile is active
          temp6 = 1
          if currentPlayer = 1 then temp6 = 2
          if currentPlayer = 2 then temp6 = 4
          if currentPlayer = 3 then temp6 = 8
          temp4 = missileActive & temp6
          if temp4 = 0 then return 
          rem Not active, skip
          
          rem Get character type to look up missile properties
          temp5 = playerChar[currentPlayer]
          
          rem Read missile momentum from character data (in Bank 6)
          currentPlayer = temp5 
          rem Character index for data lookup
          gosub bank6 GetMissileMomentumX
          temp6 = temp2 
          rem Store base X momentum
          currentPlayer = temp5 
          rem Restore for Y lookup
          gosub bank6 GetMissileMomentumY
          temp3 = temp2 
          rem Y momentum (already in correct form)
          
          rem Apply facing direction to X momentum
          temp4 = playerState[currentPlayer] & 1 
          rem Get facing direction
          if temp4 = 0 then temp2 = 0 - temp6 : goto FacingSet
          temp2 = temp6
FacingSet
          
          rem Read missile flags from character data (in Bank 6)
          currentPlayer = temp5
          gosub bank6 GetMissileFlags
          temp5 = temp2 
          rem Store flags for later use
          
          rem Apply gravity if flag is set
          if temp5 & 4 then temp3 = temp3 + GravityPerFrame 
          rem Add gravity (1 pixel/frame down)
          
          rem Update missile position
          let missileX[currentPlayer] = missileX[currentPlayer] + temp2
          let missileY[currentPlayer] = missileY[currentPlayer] + temp3
          
          rem Check screen bounds
          gosub CheckMissileBounds
          if temp4 then gosub DeactivateMissile : return 
          rem Off-screen, deactivate
          
          rem Check collision with playfield if flag is set
          if !(temp5 & 1) then PlayfieldCollisionDone
          gosub bank7 MissileCollPF
          if !temp4 then PlayfieldCollisionDone
          if temp5 & 8 then temp7 = missileVelX[currentPlayer] : temp7 = $FF - temp7 + 1 : asm lsr temp7 end : missileVelX[currentPlayer] = temp7 : gosub DeactivateMissile : return
          gosub DeactivateMissile : return
PlayfieldCollisionDone
          
          rem Check collision with players
          rem This handles both visible missiles and AOE attacks
          gosub bank7 CheckAllMissileCollisions
          rem Check if hit was found (temp4 != 255)
          if temp4 = 255 then goto MissileSystemNoHit
          gosub HandleMissileHit
          gosub DeactivateMissile
          return
MissileSystemNoHit
          
          rem Decrement lifetime counter and check expiration
          rem Retrieve current lifetime for this missile
          let temp8 = missileLifetime[currentPlayer]
          
          rem Decrement if not set to 255 (infinite until collision)
          if temp8 = 255 then MissileUpdateComplete
          let temp8 = temp8 - 1
          if temp8 = 0 then gosub DeactivateMissile : return
          let missileLifetime[currentPlayer] = temp8
MissileUpdateComplete
          
          return

          rem =================================================================
          rem CHECK MISSILE BOUNDS
          rem =================================================================
          rem Checks if missile is off-screen.

          rem INPUT:
          rem   currentPlayer = participant array index (0-3 maps to participants 1-4)

          rem OUTPUT:
          rem   temp4 = 1 if off-screen, 0 if on-screen
CheckMissileBounds
          rem Get missile X/Y position
          temp2 = missileX[currentPlayer]
          temp3 = missileY[currentPlayer]
          
          rem Check bounds (usable sprite area is 128px wide, 16px inset from each side)
          temp4 = 0
          if temp2 > ScreenInsetX + ScreenUsableWidth then temp4 = 1 
          rem Off right edge (16 + 128)
          if temp2 < ScreenInsetX then temp4 = 1  
          rem Off left edge
          if temp3 > ScreenBottom then temp4 = 1 
          rem Off bottom
          rem Byte-safe top bound: if wrapped past 0 due to subtract, temp3 will be > original
          temp5 = temp3
          rem Assuming prior update may have subtracted from temp3 earlier in loop
          if temp3 > ScreenTopWrapThreshold then temp4 = 1
          rem Off top
          
          return

          rem =================================================================
          rem HANDLE MISSILE HIT
          rem =================================================================
          rem Processes a missile hitting a player.
          rem Applies damage, knockback, and visual/audio feedback.

          rem INPUT:
          rem   currentPlayer = attacker player index (0-3, missile owner)
          rem   temp4 = defender player index (0-3, hit player)
HandleMissileHit
          rem Get character type for damage calculation
          temp5 = playerChar[currentPlayer]
          
          rem Apply damage from attacker to defender
          rem Use playerDamage array for base damage amount
          temp6 = playerDamage[currentPlayer]
          
          rem Check if defender is guarding (bit 1 of playerState)
          temp2 = playerState[temp4] & 2
          if temp2 then currentPlayer = SoundGuard : gosub bank15 PlaySoundEffect : return 
          rem Guarding - no damage, play guard sound
          
          rem Apply damage
          let temp7 = playerHealth[temp4]
          let playerHealth[temp4] = playerHealth[temp4] - temp6
          if playerHealth[temp4] > temp7 then playerHealth[temp4] = 0
          
          rem Apply knockback (simple version - push defender away from attacker)
          rem Calculate direction: if missile moving right, push defender right
          temp2 = missileX[currentPlayer]
          
          if temp2 < playerX[temp4] then playerMomentumX[temp4] = playerMomentumX[temp4] + KnockbackImpulse : goto KnockbackDone 
          rem Missile from left, push right
          let playerMomentumX[temp4] = playerMomentumX[temp4] - KnockbackImpulse 
          rem Missile from right, push left
KnockbackDone
          
          rem Set recovery/hitstun frames
          let playerRecoveryFrames[temp4] = HitstunFrames 
          rem 10 frames of hitstun
          
          rem Play hit sound effect
          currentPlayer = SoundHit
          gosub bank15 PlaySoundEffect
          
          rem Spawn damage indicator visual
          gosub bank11 VisualShowDamageIndicator
          
          return

          rem =================================================================
          rem DEACTIVATE MISSILE
          rem =================================================================
          rem Removes a missile from active status.

          rem INPUT:
          rem   currentPlayer = participant array index (0-3 maps to participants 1-4)
DeactivateMissile
          rem Clear active bit for this player missile
          temp6 = 1
          if currentPlayer = 1 then temp6 = 2
          if currentPlayer = 2 then temp6 = 4
          if currentPlayer = 3 then temp6 = 8
          temp6 = 255 - temp6 
          rem Invert bits
          let missileActive = missileActive & temp6
          return

