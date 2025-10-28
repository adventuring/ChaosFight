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
          rem   MissileLifetime (e) - Packed nibble counters (not used yet, simplified)
          rem
          rem TEMP VARIABLE USAGE:
          rem   temp1 = player index (0-3) being processed
          rem   temp2 = MissileX delta (momentum/velocity)
          rem   temp3 = MissileY delta (momentum/velocity)
          rem   temp4 = scratch for collision checks / flags
          rem   temp5 = scratch for character data lookups
          rem   temp6 = scratch for bit manipulation
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
          rem   3. Set missile X/Y based on player position and emission height
          rem   4. Set active bit for this player''s missile
          rem   5. Initialize lifetime counter
SpawnMissile
          rem Get character type for this player
          temp5 = PlayerChar[temp1]
          
          rem Calculate initial missile position based on player position
          rem X position: player X + offset for facing direction
          rem Y position: player Y + emission height from character data
          
          rem For now, simplified: place missile at player position
          rem TODO: Read CharacterMissileEmissionHeights data
          if temp1 = 0 then
                    MissileX[0] = PlayerX[0]
                    MissileY[0] = PlayerY[0]
          endif
          if temp1 = 1 then
                    MissileX[1] = PlayerX[1]
                    MissileY[1] = PlayerY[1]
          endif
          if temp1 = 2 then
                    MissileX[2] = PlayerX[2]
                    MissileY[2] = PlayerY[2]
          endif
          if temp1 = 3 then
                    MissileX[3] = PlayerX[3]
                    MissileY[3] = PlayerY[3]
          endif
          
          rem Set active bit for this player''s missile
          rem Bit 0 = P1, Bit 1 = P2, Bit 2 = P3, Bit 3 = P4
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          MissileActive = MissileActive | temp6
          
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
          
          rem TODO: Read CharacterMissileMomentumX/Y from data tables
          rem For now, use placeholder momentum
          temp2 = 2  : rem X velocity (positive = right)
          temp3 = 0  : rem Y velocity (0 = horizontal)
          
          rem Update missile position
          if temp1 = 0 then
                    MissileX[0] = MissileX[0] + temp2
                    MissileY[0] = MissileY[0] + temp3
                    rem Check bounds
                    if MissileX[0] > 160 then gosub DeactivateMissile
                    if MissileX[0] < 0 then gosub DeactivateMissile
          endif
          if temp1 = 1 then
                    MissileX[1] = MissileX[1] + temp2
                    MissileY[1] = MissileY[1] + temp3
                    if MissileX[1] > 160 then gosub DeactivateMissile
                    if MissileX[1] < 0 then gosub DeactivateMissile
          endif
          if temp1 = 2 then
                    MissileX[2] = MissileX[2] + temp2
                    MissileY[2] = MissileY[2] + temp3
                    if MissileX[2] > 160 then gosub DeactivateMissile
                    if MissileX[2] < 0 then gosub DeactivateMissile
          endif
          if temp1 = 3 then
                    MissileX[3] = MissileX[3] + temp2
                    MissileY[3] = MissileY[3] + temp3
                    if MissileX[3] > 160 then gosub DeactivateMissile
                    if MissileX[3] < 0 then gosub DeactivateMissile
          endif
          
          rem TODO: Check collision with players
          rem TODO: Check collision with walls/background
          rem TODO: Decrement lifetime counter and deactivate if expired
          
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
RenderAllMissiles
          rem TODO: Implement missile rendering
          rem Will need to multiplex between 4 missiles using 2 hardware missiles
          rem Strategy: Draw highest-priority 2 missiles per scanline
          rem Priority: closest to camera (lowest Y value)
          return

          rem =================================================================
          rem CHECK MISSILE-PLAYER COLLISION
          rem =================================================================
          rem Checks if a missile hit any player (except the owner).
          rem
          rem INPUT:
          rem   temp1 = missile owner player index (0-3)
          rem   temp2 = missile X position
          rem   temp3 = missile Y position
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckMissilePlayerCollision
          rem TODO: Implement collision detection
          rem Check each player except owner
          rem Use bounding box collision (missile X/Y/W/H vs player X/Y/W/H)
          temp4 = 255  : rem No hit
          return

