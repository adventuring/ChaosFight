          rem ChaosFight - Source/Routines/MissileSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem MISSILE SYSTEM - 4-PLAYER MISSILE MANAGEMENT
          rem =================================================================
          rem Manages up to 4 simultaneous missiles/attack visuals (one per player).
          rem Each player can have ONE active missile at a time, which can be:
          rem   - Ranged projectile (bullet, arrow, magic spell)
          rem   - Melee attack visual (sword, fist, kick sprite)
          rem
          rem MISSILE VARIABLES (from Variables.bas):
          rem   MissileX[0-3] (a-d) - X positions
          rem   MissileY[0-3] (w-z) - Y positions
          rem   MissileActive (i) - Bit flags for which missiles are active
          rem   MissileLifetime (e,f) - Packed nybble counters
          rem     e{7:4} = Player 1 lifetime, e{3:0} = Player 2 lifetime
          rem     f{7:4} = Player 3 lifetime, f{3:0} = Player 4 lifetime
          rem     Values: 0-13 = frame count, 14 = until collision, 15 = until off-screen
          rem
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
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem PROCESS:
          rem   1. Look up character type for this player
          rem   2. Read missile properties from character data
          rem   3. Set missile X/Y based on player position, facing, and emission height
          rem   4. Set active bit for this player''s missile
          rem   5. Initialize lifetime counter from character data
SpawnMissile
          rem Get character type for this player
          temp5 = PlayerChar[temp1]
          
          rem Read missile emission height from character data
          rem TODO: Implement data table read for CharacterMissileEmissionHeights
          rem For now, use default emission height of 8 pixels (mid-sprite)
          temp6 = 8
          
          rem Calculate initial missile position based on player position and facing
          rem Facing is stored in PlayerState bit 0: 0=left, 1=right
          temp4 = PlayerState[temp1] & 1  : rem Get facing direction
          
          rem Set missile position using array access
          if temp1 = 0 then
                    rem Start at player position
                    MissileX[0] = PlayerX[0]
                    MissileY[0] = PlayerY[0] + temp6
                    rem Offset X based on facing direction
                    if temp4 = 0 then MissileX[0] = MissileX[0] - 4  : rem Facing left, spawn left
                    if temp4 = 1 then MissileX[0] = MissileX[0] + 12  : rem Facing right, spawn right
          endif
          if temp1 = 1 then
                    MissileX[1] = PlayerX[1]
                    MissileY[1] = PlayerY[1] + temp6
                    if temp4 = 0 then MissileX[1] = MissileX[1] - 4
                    if temp4 = 1 then MissileX[1] = MissileX[1] + 12
          endif
          if temp1 = 2 then
                    MissileX[2] = PlayerX[2]
                    MissileY[2] = PlayerY[2] + temp6
                    if temp4 = 0 then MissileX[2] = MissileX[2] - 4
                    if temp4 = 1 then MissileX[2] = MissileX[2] + 12
          endif
          if temp1 = 3 then
                    MissileX[3] = PlayerX[3]
                    MissileY[3] = PlayerY[3] + temp6
                    if temp4 = 0 then MissileX[3] = MissileX[3] - 4
                    if temp4 = 1 then MissileX[3] = MissileX[3] + 12
          endif
          
          rem Set active bit for this player''s missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          MissileActive = MissileActive | temp6
          
          rem Initialize lifetime counter from character data
          rem TODO: Read CharacterMissileLifetime[temp5] from data table
          rem For now, use default: melee=5 frames, ranged=15 (until collision)
          rem Store in packed nybbles: e{7:4}=P1, e{3:0}=P2, f{7:4}=P3, f{3:0}=P4
          rem Simplified for now - just set to 15 (until collision)
          rem TODO: Implement proper nybble packing/unpacking
          
          return

          rem =================================================================
          rem UPDATE ALL MISSILES
          rem =================================================================
          rem Called once per frame to update all active missiles.
          rem Updates position, checks collisions, handles lifetime.
UpdateAllMissiles
          rem Check each player''s missile
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
          rem Updates a single player''s missile.
          rem Handles movement, gravity, collisions, and lifetime.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
UpdateOneMissile
          rem Check if this missile is active
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp4 = MissileActive & temp6
          if temp4 = 0 then return  : rem Not active, skip
          
          rem Get character type to look up missile properties
          temp5 = PlayerChar[temp1]
          
          rem Read missile momentum from character data
          rem TODO: Implement data table read for CharacterMissileMomentumX/Y
          rem For now, use placeholder momentum based on player facing
          temp4 = PlayerState[temp1] & 1  : rem Get facing direction
          if temp4 = 0 then
                    temp2 = -3  : rem X velocity (negative = left)
          else
                    temp2 = 3   : rem X velocity (positive = right)
          endif
          temp3 = 0  : rem Y velocity (0 = horizontal, negative = up, positive = down)
          
          rem TODO: Read missile flags from character data
          rem Bit 0: Hit background (playfield)
          rem Bit 1: Hit player
          rem Bit 2: Apply gravity
          rem Bit 3: Bounce off walls
          temp5 = %00000011  : rem Default: hit bg and players
          
          rem Apply gravity if flag is set
          if temp5 & 4 then temp3 = temp3 + 1  : rem Add gravity (1 pixel/frame down)
          
          rem Update missile position
          if temp1 = 0 then
                    MissileX[0] = MissileX[0] + temp2
                    MissileY[0] = MissileY[0] + temp3
          endif
          if temp1 = 1 then
                    MissileX[1] = MissileX[1] + temp2
                    MissileY[1] = MissileY[1] + temp3
          endif
          if temp1 = 2 then
                    MissileX[2] = MissileX[2] + temp2
                    MissileY[2] = MissileY[2] + temp3
          endif
          if temp1 = 3 then
                    MissileX[3] = MissileX[3] + temp2
                    MissileY[3] = MissileY[3] + temp3
          endif
          
          rem Check screen bounds
          gosub CheckMissileBounds
          if temp4 then gosub DeactivateMissile : return  : rem Off-screen, deactivate
          
          rem Check collision with playfield if flag is set
          if temp5 & 1 then
                    gosub CheckMissilePlayfieldCollision
                    if temp4 then
                              rem Hit playfield
                              if temp5 & 8 then
                                        rem Bounce off wall (TODO: implement bounce physics)
                                        gosub DeactivateMissile : return
                              else
                                        rem Stop on wall
                                        gosub DeactivateMissile : return
                              endif
                    endif
          endif
          
          rem Check collision with players
          rem This handles both visible missiles and AOE attacks
          gosub CheckAllMissileCollisions
          if temp4 <> 255 then
                    rem Hit a player (temp4 = target player index)
                    gosub HandleMissileHit
                    gosub DeactivateMissile : return
          endif
          
          rem TODO: Decrement lifetime counter and check expiration
          rem For now, missiles persist until collision or off-screen
          
          return

          rem =================================================================
          rem CHECK MISSILE BOUNDS
          rem =================================================================
          rem Checks if missile is off-screen.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = 1 if off-screen, 0 if on-screen
CheckMissileBounds
          rem Get missile X/Y position
          if temp1 = 0 then
                    temp2 = MissileX[0]
                    temp3 = MissileY[0]
          endif
          if temp1 = 1 then
                    temp2 = MissileX[1]
                    temp3 = MissileY[1]
          endif
          if temp1 = 2 then
                    temp2 = MissileX[2]
                    temp3 = MissileY[2]
          endif
          if temp1 = 3 then
                    temp2 = MissileX[3]
                    temp3 = MissileY[3]
          endif
          
          rem Check bounds (screen is ~160x192 visible area)
          temp4 = 0
          if temp2 > 160 then temp4 = 1  : rem Off right edge
          if temp2 < 0 then temp4 = 1    : rem Off left edge
          if temp3 > 192 then temp4 = 1  : rem Off bottom
          if temp3 < 0 then temp4 = 1    : rem Off top
          
          return

          rem =================================================================
          rem CHECK MISSILE-PLAYFIELD COLLISION
          rem =================================================================
          rem Checks if missile hit the playfield (walls, obstacles).
          rem Uses pfread to check playfield pixel at missile position.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = 1 if hit playfield, 0 if clear
CheckMissilePlayfieldCollision
          rem Get missile X/Y position
          if temp1 = 0 then
                    temp2 = MissileX[0]
                    temp3 = MissileY[0]
          endif
          if temp1 = 1 then
                    temp2 = MissileX[1]
                    temp3 = MissileY[1]
          endif
          if temp1 = 2 then
                    temp2 = MissileX[2]
                    temp3 = MissileY[2]
          endif
          if temp1 = 3 then
                    temp2 = MissileX[3]
                    temp3 = MissileY[3]
          endif
          
          rem Convert X/Y to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160), 192 pixels tall
          rem pfread uses playfield coordinates: column (0-31), row (0-11 or 0-31 depending on pfres)
          temp6 = temp2 / 5  : rem Convert X pixel to playfield column (160/32 = 5)
          rem temp3 is already in pixel coordinates, pfread will handle it
          
          rem Check if playfield pixel is set
          rem pfread(column, row) returns 0 if clear, non-zero if set
          if pfread(temp6, temp3) then
                    temp4 = 1  : rem Hit playfield
          else
                    temp4 = 0  : rem Clear
          endif
          
          return

          rem =================================================================
          rem CHECK MISSILE-PLAYER COLLISION
          rem =================================================================
          rem Checks if a missile hit any player (except the owner).
          rem Uses axis-aligned bounding box (AABB) collision detection.
          rem
          rem INPUT:
          rem   temp1 = missile owner player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckMissilePlayerCollision
          rem Get missile X/Y position
          if temp1 = 0 then
                    temp2 = MissileX[0]
                    temp3 = MissileY[0]
          endif
          if temp1 = 1 then
                    temp2 = MissileX[1]
                    temp3 = MissileY[1]
          endif
          if temp1 = 2 then
                    temp2 = MissileX[2]
                    temp3 = MissileY[2]
          endif
          if temp1 = 3 then
                    temp2 = MissileX[3]
                    temp3 = MissileY[3]
          endif
          
          rem Missile bounding box (assume 4x4 pixels for now)
          rem temp2 = missile left, temp2+4 = missile right
          rem temp3 = missile top, temp3+4 = missile bottom
          
          rem Check collision with each player (except owner)
          temp4 = 255  : rem Default: no hit
          
          rem Check Player 1 (index 0)
          if temp1 <> 0 then
                    if PlayerHealth[0] > 0 then
                              rem Player bounding box (assume 8x16 pixels)
                              rem Check AABB collision
                              if temp2 < PlayerX[0] + 8 then
                                        if temp2 + 4 > PlayerX[0] then
                                                  if temp3 < PlayerY[0] + 16 then
                                                            if temp3 + 4 > PlayerY[0] then
                                                                      temp4 = 0  : rem Hit Player 1
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 2 (index 1)
          if temp1 <> 1 then
                    if PlayerHealth[1] > 0 then
                              if temp2 < PlayerX[1] + 8 then
                                        if temp2 + 4 > PlayerX[1] then
                                                  if temp3 < PlayerY[1] + 16 then
                                                            if temp3 + 4 > PlayerY[1] then
                                                                      temp4 = 1  : rem Hit Player 2
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 3 (index 2)
          if temp1 <> 2 then
                    if PlayerHealth[2] > 0 then
                              if temp2 < PlayerX[2] + 8 then
                                        if temp2 + 4 > PlayerX[2] then
                                                  if temp3 < PlayerY[2] + 16 then
                                                            if temp3 + 4 > PlayerY[2] then
                                                                      temp4 = 2  : rem Hit Player 3
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 4 (index 3)
          if temp1 <> 3 then
                    if PlayerHealth[3] > 0 then
                              if temp2 < PlayerX[3] + 8 then
                                        if temp2 + 4 > PlayerX[3] then
                                                  if temp3 < PlayerY[3] + 16 then
                                                            if temp3 + 4 > PlayerY[3] then
                                                                      temp4 = 3  : rem Hit Player 4
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          return

          rem =================================================================
          rem HANDLE MISSILE HIT
          rem =================================================================
          rem Processes a missile hitting a player.
          rem Applies damage, knockback, and visual/audio feedback.
          rem
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
          if temp2 then
                    rem Guarding - no damage
                    rem TODO: Play guard sound effect
                    return
          endif
          
          rem Apply damage
          PlayerHealth[temp4] = PlayerHealth[temp4] - temp6
          if PlayerHealth[temp4] < 0 then PlayerHealth[temp4] = 0
          
          rem Apply knockback (simple version - push defender away from attacker)
          rem Calculate direction: if missile moving right, push defender right
          if temp1 = 0 then temp2 = MissileX[0]
          if temp1 = 1 then temp2 = MissileX[1]
          if temp1 = 2 then temp2 = MissileX[2]
          if temp1 = 3 then temp2 = MissileX[3]
          
          if temp2 < PlayerX[temp4] then
                    rem Missile from left, push right
                    PlayerMomentumX[temp4] = PlayerMomentumX[temp4] + 4
          else
                    rem Missile from right, push left
                    PlayerMomentumX[temp4] = PlayerMomentumX[temp4] - 4
          endif
          
          rem Set recovery/hitstun frames
          PlayerRecoveryFrames[temp4] = 10  : rem 10 frames of hitstun
          
          rem TODO: Play hit sound effect
          rem TODO: Spawn damage indicator visual
          
          return

          rem =================================================================
          rem DEACTIVATE MISSILE
          rem =================================================================
          rem Removes a missile from active status.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
DeactivateMissile
          rem Clear active bit for this player''s missile
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp6 = 255 - temp6  : rem Invert bits
          MissileActive = MissileActive & temp6
          return

          rem =================================================================
          rem RENDER ALL MISSILES
          rem =================================================================
          rem Draws all active missiles to the screen.
          rem Uses missile0 and missile1 TIA hardware.
          rem With 4 logical missiles and 2 hardware missiles, we need to multiplex.
RenderAllMissiles
          rem Strategy: Prioritize missiles closest to each other to minimize flicker
          rem For now, simple approach: render P1/P2 missiles to missile0/1
          rem and P3/P4 missiles also to missile0/1 (will flicker if overlapping)
          
          rem Check if P1 missile is active
          temp4 = MissileActive & 1
          if temp4 then
                    rem Render P1 missile to missile0
                    missile0x = MissileX[0]
                    missile0y = MissileY[0]
                    missile0height = 1  : rem 1 pixel tall (can be 1, 2, 4, or 8)
                    COLUP0 = $0E  : rem White (missiles share player colors)
          endif
          
          rem Check if P2 missile is active
          temp4 = MissileActive & 2
          if temp4 then
                    rem Render P2 missile to missile1
                    missile1x = MissileX[1]
                    missile1y = MissileY[1]
                    missile1height = 1
                    COLUP1 = $0E  : rem White
          endif
          
          rem TODO: Handle P3/P4 missiles with multiplexing or alternate frames
          rem For now, they won''t render (need kernel support for flicker-free 4 missiles)
          
          return
