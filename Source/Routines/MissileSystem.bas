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
          rem   MissileX[0-3] (a-d) - X positions
          rem   MissileY[0-3] (w-z) - Y positions
          rem   MissileActive (i) - Bit flags for which missiles are active
          rem   MissileLifetime (e,f) - Packed nybble counters
          rem     e{7:4} = Player 1 lifetime, e{3:0} = Player 2 lifetime
          rem     f{7:4} = Player 3 lifetime, f{3:0} = Player 4 lifetime
          rem     Values: 0-13 = frame count, 14 = until collision, 15 = until off-screen

          rem TEMP VARIABLE USAGE:
          rem   temp1 = player index (0-3) being processed
          rem   temp2 = MissileX delta (momentum/velocity)
          rem   temp3 = MissileY delta (momentum/velocity)
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
          rem   temp1 = participant array index (0-3 maps to participants 1-4)

          rem PROCESS:
          rem   1. Look up character type for this player
          rem   2. Read missile properties from character data
          rem   3. Set missile X/Y based on player position, facing, and emission height
          rem   4. Set active bit for this player missile
          rem   5. Initialize lifetime counter from character data
SpawnMissile
          rem Get character type for this player
          temp5 = PlayerChar[temp1]
          
          rem Read missile emission height from character data table
          temp6 = CharacterMissileEmissionHeights[temp5]
          
          rem Calculate initial missile position based on player position and facing
          rem Facing is stored in PlayerState bit 0: 0=left, 1=right
          temp4 = PlayerState[temp1] & 1 
          rem Get facing direction
          
          rem Set missile position using array access
          MissileX[temp1] = PlayerX[temp1]
          MissileY[temp1] = PlayerY[temp1] + temp6
          if temp4 = 0 then MissileX[temp1] = MissileX[temp1] - MissileSpawnOffsetLeft 
          rem Facing left, spawn left
          if temp4 = 1 then MissileX[temp1] = MissileX[temp1] + MissileSpawnOffsetRight 
          rem Facing right, spawn right
          
          rem Set active bit for this participant's missile
          rem Bit 0 = Participant 1 (array [0]), Bit 1 = Participant 2 (array [1]), Bit 2 = Participant 3 (array [2]), Bit 3 = Participant 4 (array [3])
          rem Calculate bit flag: 1, 2, 4, 8 for array indices 0, 1, 2, 3 (mapping to participants 1, 2, 3, 4)
          if temp1 = 0 then temp6 = 1
          rem Array [0] = Participant 1 → bit 0
          if temp1 = 1 then temp6 = 2
          rem Array [1] = Participant 2 → bit 1
          if temp1 = 2 then temp6 = 4
          rem Array [2] = Participant 3 → bit 2
          if temp1 = 3 then temp6 = 8
          rem Array [3] = Participant 4 → bit 3
          MissileActive = MissileActive | temp6
          
          rem Initialize lifetime counter from character data table
          temp7 = CharacterMissileLifetime[temp5]
          
          rem Store lifetime in player-specific variable
          rem Using individual variables for each player missile lifetime
          MissileLifetime[temp1] = temp7
          
          return

          rem =================================================================
          rem UPDATE ALL MISSILES
          rem =================================================================
          rem Called once per frame to update all active missiles.
          rem Updates position, checks collisions, handles lifetime.
UpdateAllMissiles
          rem Check each player missile
          temp1 = 0
          gosub UpdateOneMissile
          temp1 = 1
          gosub UpdateOneMissile
          temp1 = 2
          gosub UpdateOneMissile
          temp1 = 3
          gosub UpdateOneMissile
          return

          rem =================================================================
          rem UPDATE ONE MISSILE
          rem =================================================================
          rem Updates a single player missile.
          rem Handles movement, gravity, collisions, and lifetime.

          rem INPUT:
          rem   temp1 = participant array index (0-3 maps to participants 1-4)
UpdateOneMissile
          rem Check if this missile is active
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp4 = MissileActive & temp6
          if temp4 = 0 then return 
          rem Not active, skip
          
          rem Get character type to look up missile properties
          temp5 = PlayerChar[temp1]
          
          rem Read missile momentum from character data (in Bank 6)
          temp1 = temp5 
          rem Character index for data lookup
          gosub bank6 GetMissileMomentumX
          temp6 = temp2 
          rem Store base X momentum
          temp1 = temp5 
          rem Restore for Y lookup
          gosub bank6 GetMissileMomentumY
          temp3 = temp2 
          rem Y momentum (already in correct form)
          
          rem Apply facing direction to X momentum
          temp4 = PlayerState[temp1] & 1 
          rem Get facing direction
          if temp4 = 0 then temp2 = 0 - temp6 : goto FacingSet
          temp2 = temp6
FacingSet
          
          rem Read missile flags from character data (in Bank 6)
          temp1 = temp5
          gosub bank6 GetMissileFlags
          temp5 = temp2 
          rem Store flags for later use
          
          rem Apply gravity if flag is set
          if temp5 & 4 then temp3 = temp3 + GravityPerFrame 
          rem Add gravity (1 pixel/frame down)
          
          rem Update missile position
          MissileX[temp1] = MissileX[temp1] + temp2
          MissileY[temp1] = MissileY[temp1] + temp3
          
          rem Check screen bounds
          gosub CheckMissileBounds
          if temp4 then gosub DeactivateMissile : return 
          rem Off-screen, deactivate
          
          rem Check collision with playfield if flag is set
          if !(temp5 & 1) then PlayfieldCollisionDone
          gosub bank7 MissileCollPF
          if !temp4 then PlayfieldCollisionDone
          if temp5 & 8 then temp7 = MissileVelX[temp1] : temp7 = $FF - temp7 + 1 : gosub HalfTemp7 : MissileVelX[temp1] = temp7 : gosub DeactivateMissile : return
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
          temp8 = MissileLifetime[temp1]
          
          rem Decrement if not set to 255 (infinite until collision)
          if temp8 = 255 then MissileUpdateComplete
          temp8 = temp8 - 1
          if temp8 = 0 then gosub DeactivateMissile : return
          MissileLifetime[temp1] = temp8
MissileUpdateComplete
          
          return

          rem =================================================================
          rem CHECK MISSILE BOUNDS
          rem =================================================================
          rem Checks if missile is off-screen.

          rem INPUT:
          rem   temp1 = participant array index (0-3 maps to participants 1-4)

          rem OUTPUT:
          rem   temp4 = 1 if off-screen, 0 if on-screen
CheckMissileBounds
          rem Get missile X/Y position
          temp2 = MissileX[temp1]
          temp3 = MissileY[temp1]
          
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
          rem CHECK MISSILE-PLAYFIELD COLLISION
          rem =================================================================
          rem Checks if missile hit the playfield (walls, obstacles).
          rem Uses pfread to check playfield pixel at missile position.

          rem INPUT:
          rem   temp1 = participant array index (0-3 maps to participants 1-4)

          rem OUTPUT:
          rem   temp4 = 1 if hit playfield, 0 if clear
MissileSysPF
          rem Get missile X/Y position
          temp2 = MissileX[temp1]
          temp3 = MissileY[temp1]
          
          rem Convert X/Y to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160), 192 pixels tall
          rem pfread uses playfield coordinates: column (0-31), row (0-11 or 0-31 depending on pfres)
          gosub Div5Compute 
          rem Convert X pixel to playfield column (160/32 = 5)
          rem temp3 is already in pixel coordinates, pfread will handle it
          
          rem Check if playfield pixel is set
          rem pfread(column, row) returns 0 if clear, non-zero if set
          temp4 = 0 
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
          temp6 = 0
          if temp2 < 5 then return
Div5Loop
          temp2 = temp2 - 5
          temp6 = temp6 + 1
          if temp2 >= 5 then goto Div5Loop
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
          temp2 = MissileX[temp1]
          temp3 = MissileY[temp1]
          
          rem Missile bounding box
          rem temp2 = missile left, temp2+MissileAABBSize = missile right
          rem temp3 = missile top, temp3+MissileAABBSize = missile bottom
          
          rem Check collision with each player (except owner)
          temp4 = 255 
          rem Default: no hit
          
          rem Check Participant 1 (array [0])
          if temp1 = 0 then goto MissileSkipParticipant1
          if PlayerHealth[0] = 0 then goto MissileSkipParticipant1
          if temp2 >= PlayerX[0] + PlayerSpriteHalfWidth then goto MissileSkipParticipant1
          if temp2 + MissileAABBSize <= PlayerX[0] then goto MissileSkipParticipant1
          if temp3 >= PlayerY[0] + PlayerSpriteHeight then goto MissileSkipParticipant1
          if temp3 + MissileAABBSize <= PlayerY[0] then goto MissileSkipParticipant1
          temp4 = 0 : return 
          rem Hit Participant 1 (array [0])
MissileSkipParticipant1
          
          rem Check Participant 2 (array [1])
          if temp1 = 1 then goto MissileSkipParticipant2
          if PlayerHealth[1] = 0 then goto MissileSkipParticipant2
          if temp2 >= PlayerX[1] + PlayerSpriteHalfWidth then goto MissileSkipParticipant2
          if temp2 + MissileAABBSize <= PlayerX[1] then goto MissileSkipParticipant2
          if temp3 >= PlayerY[1] + PlayerSpriteHeight then goto MissileSkipParticipant2
          if temp3 + MissileAABBSize <= PlayerY[1] then goto MissileSkipParticipant2
          temp4 = 1 : return 
          rem Hit Player 2
MissileSkipPlayer1
          
          rem Check Player 3 (index 2)
          if temp1 = 2 then goto MissileSkipPlayer2
          if PlayerHealth[2] = 0 then goto MissileSkipPlayer2
          if temp2 >= PlayerX[2] + PlayerSpriteHalfWidth then goto MissileSkipPlayer2
          if temp2 + MissileAABBSize <= PlayerX[2] then goto MissileSkipPlayer2
          if temp3 >= PlayerY[2] + PlayerSpriteHeight then goto MissileSkipPlayer2
          if temp3 + MissileAABBSize <= PlayerY[2] then goto MissileSkipPlayer2
          temp4 = 2 : return 
          rem Hit Player 3
MissileSkipPlayer2
          
          rem Check Player 4 (index 3)
          if temp1 = 3 then goto MissileSkipPlayer3
          if PlayerHealth[3] = 0 then goto MissileSkipPlayer3
          if temp2 >= PlayerX[3] + PlayerSpriteHalfWidth then goto MissileSkipPlayer3
          if temp2 + MissileAABBSize <= PlayerX[3] then goto MissileSkipPlayer3
          if temp3 >= PlayerY[3] + PlayerSpriteHeight then goto MissileSkipPlayer3
          if temp3 + MissileAABBSize <= PlayerY[3] then goto MissileSkipPlayer3
          temp4 = 3 : return 
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
          temp5 = PlayerChar[temp1]
          
          rem Apply damage from attacker to defender
          rem Use PlayerDamage array for base damage amount
          temp6 = PlayerDamage[temp1]
          
          rem Check if defender is guarding (bit 1 of PlayerState)
          temp2 = PlayerState[temp4] & 2
          if temp2 then temp1 = SoundGuard : gosub bank15 PlaySoundEffect : return 
          rem Guarding - no damage, play guard sound
          
          rem Apply damage
          temp7 = PlayerHealth[temp4]
          PlayerHealth[temp4] = PlayerHealth[temp4] - temp6
          if PlayerHealth[temp4] > temp7 then PlayerHealth[temp4] = 0
          
          rem Apply knockback (simple version - push defender away from attacker)
          rem Calculate direction: if missile moving right, push defender right
          temp2 = MissileX[temp1]
          
          if temp2 < PlayerX[temp4] then PlayerMomentumX[temp4] = PlayerMomentumX[temp4] + KnockbackImpulse : goto KnockbackDone 
          rem Missile from left, push right
          PlayerMomentumX[temp4] = PlayerMomentumX[temp4] - KnockbackImpulse 
          rem Missile from right, push left
KnockbackDone
          
          rem Set recovery/hitstun frames
          PlayerRecoveryFrames[temp4] = HitstunFrames 
          rem 10 frames of hitstun
          
          rem Play hit sound effect
          temp1 = SoundHit
          gosub bank15 PlaySoundEffect
          
          rem Spawn damage indicator visual
          gosub bank8 VisualShowDamageIndicator
          
          return

          rem =================================================================
          rem DEACTIVATE MISSILE
          rem =================================================================
          rem Removes a missile from active status.

          rem INPUT:
          rem   temp1 = participant array index (0-3 maps to participants 1-4)
DeactivateMissile
          rem Clear active bit for this player missile
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp6 = 255 - temp6 
          rem Invert bits
          MissileActive = MissileActive & temp6
          return

          rem =================================================================
          rem RENDER ALL MISSILES
          rem =================================================================
          rem NOTE: Missile rendering is now handled in SetSpritePositions (PlayerRendering.bas)
          rem This function is kept for compatibility but does nothing
          rem The multisprite kernel only provides 2 hardware missiles (missile0, missile1)
          rem In 2-player mode: missile0 = Participant 1 (array [0]), missile1 = Participant 2 (array [1]) (no multiplexing)
          rem In 4-player mode: Frame multiplexing handles 4 logical missiles:
          rem   Even frames: missile0 = Participant 1 (array [0]), missile1 = Participant 2 (array [1])
          rem   Odd frames:  missile0 = Participant 3 (array [2]), missile1 = Participant 4 (array [3])
RenderAllMissiles
          rem Missile positions are set in SetSpritePositions (PlayerRendering.bas)
          rem which handles 2-player vs 4-player mode automatically
          rem No additional rendering needed here
          return
