          rem ChaosFight - Source/Routines/MissileCollision.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckAllMissileCollisions
          rem Missile Collision System
          rem Handles all collision detection for missiles and
          rem   area-of-effect attacks.
          rem COLLISION TYPES:
          rem 1. Missile-to-Player: Visible missiles (ranged or melee
          rem   visuals)
          rem 2. AOE-to-Player: Melee attacks with no visible missile
          rem   (0×0 size)
          rem 3. Missile-to-Playfield: For missiles that interact with
          rem   walls
          rem SPECIAL CASES:
          rem   - Bernie: AOE extends both left AND right simultaneously
          rem   - Other melee: AOE only in facing direction
          rem
          rem FACING DIRECTION FORMULA (for AOE attacks):
          rem   Facing right (bit 0 = 1): AOE_X = playerX + offset
          rem   Facing left  (bit 0 = 0): AOE_X = playerX + 7 - offset
          rem Check all missile collisions (visible missiles and AOE) each frame.
          rem Input: temp1 = attacker player index (0-3)
          rem        missileActive (global) = missile active flags
          rem        playerCharacter[] (global) = character types
          rem Output: temp4 = hit player index (0-3) if hit, 0 if no hit
          rem Mutates: temp1-temp6, temp4
          rem
          rem Called Routines: GetMissileWidth (bank6) - gets missile
          rem width to determine if AOE or visible,
          rem CheckVisibleMissileCollision (tail call) - if visible
          rem missile, CheckAOECollision (goto) - if AOE attack
          rem Constraints: None
          rem Optimized: Calculate missile active bit flag with formula
          rem Bit flag: 1 << temp1 (1, 2, 4, 8 for players 0, 1, 2, 3)
          let temp6 = 1
          for temp4 = 0 to temp1 - 1
            let temp6 = temp6 * 2
          next
          let temp4 = missileActive & temp6
          if temp4 = 0 then return 
          rem No active missile
          
          let temp5 = playerCharacter[temp1] : 
          rem Get character type to determine missile properties
          
          rem Check if this is a visible missile or AOE attack
          rem Read missile width from character data (in Bank 6)
          let temp1 = temp5
          gosub GetMissileWidth bank6
          let temp6 = temp2 
          rem Missile width (0 = AOE, >0 = visible missile)

          if temp6 = 0 then goto CheckAOECollision
          goto CheckVisibleMissileCollision : 
          rem tail call
          

CheckVisibleMissileCollision
          rem
          rem Check Visible Missile Collision
          rem Checks collision between a visible missile and all
          rem   players.
          rem Uses axis-aligned bounding box (AABB) collision detection.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3, missile owner)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
          rem Checks collision between a visible missile and all players
          rem using AABB collision detection
          rem
          rem Input: temp1 = attacker player index (0-3, missile owner),
          rem missileX[] (global array) = missile X positions,
          rem missileY_R[] (global SCRAM array) = missile Y positions,
          rem playerCharacter[] (global array) = character types, playerX[],
          rem playerY[] (global arrays) = player positions,
          rem playerHealth[] (global array) = player health
          rem
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no
          rem hit
          rem
          rem Mutates: temp1-temp6 (used for calculations), temp4
          rem (return value)
          rem
          rem Called Routines: GetMissileWidth (bank6) - gets missile
          rem width, GetMissileHeight (bank6) - gets missile height
          rem Constraints: None
          let temp2 = missileX[temp1] : 
          rem Get missile X/Y position
          let temp3 = missileY_R[temp1]
          
          rem Get missile size from character data (in Bank 6)
          let temp5 = playerCharacter[temp1] : 
          rem Get character type from player
          rem Use characterType as index (preserve attackerIndex)
          let temp1 = temp5
          gosub GetMissileWidth bank6
          let temp6 = temp2 
          rem Missile width (temp2 now contains width)
          let temp1 = temp5
          gosub GetMissileHeight bank6
          let temp3 = temp2 
          rem Missile height (temp2 now contains height)
          rem Restore missileX/Y after width/height lookup
          
          rem Missile bounding box:
          rem   Left:   missileX
          rem   Right:  missileX + missileWidth
          rem   Top:    missileY
          rem   Bottom: missileY + missileHeight
          
          rem Optimized: Loop through all players to check collisions instead of individual blocks
          let temp4 = 255 : 
          rem Default: no hit
          for temp5 = 0 to 3
            if temp5 = temp1 then goto NextPlayerCheck : 
          rem Skip owner
            if playerHealth[temp5] = 0 then goto NextPlayerCheck : 
          rem Skip dead players
            if temp2 >= playerX[temp5] + PlayerSpriteHalfWidth then goto NextPlayerCheck
            if temp2 + temp6 <= playerX[temp5] then goto NextPlayerCheck
            if temp3 >= playerY[temp5] + PlayerSpriteHeight then goto NextPlayerCheck
            if temp3 + temp3 <= playerY[temp5] then goto NextPlayerCheck
            let temp4 = temp5 : 
          rem Hit detected!
            return
NextPlayerCheck
          next
          return

CheckAOECollision
          rem
          rem Check Aoe Collision
          rem Checks collision for area-of-effect melee attacks (no
          rem   visible missile).
          rem AOE is relative to player position and facing direction.
          rem SPECIAL CASE: Bernie (character 0) Ground Thump attack
          rem   hits both left AND right simultaneously, shoving enemies
          rem   away rapidly.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
          rem Checks collision for area-of-effect melee attacks (no
          rem visible missile)
          rem
          rem Input: temp1 = attacker player index (0-3), playerCharacter[]
          rem (global array) = character types, playerState[] (global
          rem array) = player states (bit 0 = facing), playerX[],
          rem playerY[] (global arrays) = player positions,
          rem playerHealth[] (global array) = player health,
          rem CharacterAOEOffsets[] (global data table) = AOE offsets
          rem
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no
          rem hit
          rem
          rem Mutates: temp1-temp6 (used for calculations), temp4
          rem (return value)
          rem
          rem Called Routines: CheckAOEDirection_Right - checks AOE
          rem collision facing right, CheckAOEDirection_Left - checks
          rem AOE collision facing left, CheckBernieAOE - special case
          rem for Bernie (hits both directions)
          rem Constraints: Bernie (character 0) hits both left AND right simultaneously
          let temp5 = playerCharacter[temp1] : 
          rem Get attacker character type
          
          rem Check if this is Bernie (character 0)
          rem Bernie attacks both left AND right, so check both
          rem directions
          if temp5 = 0 then CheckBernieAOE
          
          let temp6 = playerState[temp1] & PlayerStateBitFacing : 
          rem Normal character: Check only facing direction
          if temp6 = 0 then CheckAOELeftDirection
          gosub CheckAOEDirection_Right
          return
CheckAOELeftDirection
          gosub CheckAOEDirection_Left
          return
          
CheckBernieAOE
          rem Bernie: Check right direction first
          gosub CheckAOEDirection_Right

          rem If hit found (hitPlayer != 255), return early
          rem Use skip-over pattern: if hitPlayer = 255, skip to left
          rem check
          if temp4 = 255 then CheckBernieAOELeft
          return
          
CheckBernieAOELeft
          rem Check left direction
          gosub CheckAOEDirection_Left

          return

CheckAOEDirection_Right
          rem
          rem Check Aoe Direction - Right
          rem Checks AOE collision when attacking to the right.
          rem Formula: AOE_X = playerX + offset
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
          rem Checks AOE collision when attacking to the right (AOE_X =
          rem playerX + offset)
          rem
          rem Input: temp1 = attacker player index (0-3), playerX[],
          rem playerY[] (global arrays) = player positions, playerCharacter[]
          rem (global array) = character types, playerHealth[] (global
          rem array) = player health, CharacterAOEOffsets[] (global data
          rem table) = AOE offsets
          rem
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no
          rem hit
          rem
          rem Mutates: temp1-temp6 (used for calculations), temp4
          rem (return value)
          rem
          rem Called Routines: None
          rem Constraints: None
          let temp2 = playerX[temp1] : 
          rem Get attacker position
          let temp3 = playerY[temp1]
          
          rem Calculate AOE bounds
          rem Read AOE offset from character data
          let temp5 = playerCharacter[temp1] : 
          rem Get character-specific AOE offset
          let aoeOffset_W = CharacterAOEOffsets[temp5]
          rem AOE_X = playerX + offset (facing right formula)
          let temp2 = temp2 + aoeOffset_R
          let temp6 = 8 
          let temp3 = 16 : 
          rem AOE width
          rem AOE height
          
          rem AOE bounding box:
          rem   Left:   aoeX
          rem   Right:  aoeX + aoeWidth
          rem   Top:    playerY
          rem   Bottom: playerY + aoeHeight
          
          let temp4 = 255 : 
          rem Check each player (except attacker)
          
          rem Check Player 1 (players are 16px wide - double-width
          rem NUSIZ)
          if temp1 = 0 then DoneAOEPlayer0
          if playerHealth[0] = 0 then DoneAOEPlayer0
          if temp2 >= playerX[0] + 16 then DoneAOEPlayer0
          rem AOE left edge past player right edge
          if temp2 + temp6 <= playerX[0] then DoneAOEPlayer0
          rem AOE right edge before player left edge
          if temp3 >= playerY[0] + 16 then DoneAOEPlayer0
          rem AOE top edge past player bottom edge
          if temp3 + temp3 <= playerY[0] then DoneAOEPlayer0
          let temp4 = 0 : 
          rem AOE bottom edge before player top edge
          return
DoneAOEPlayer0
          
          rem Check Player 2
          
          if temp1 = 1 then DoneAOEPlayer1
          if playerHealth[1] = 0 then DoneAOEPlayer1
          if temp2 >= playerX[1] + 16 then DoneAOEPlayer1
          if temp2 + temp6 <= playerX[1] then DoneAOEPlayer1
          if temp3 >= playerY[1] + 16 then DoneAOEPlayer1
          if temp3 + temp3 <= playerY[1] then DoneAOEPlayer1
          let temp4 = 1
          return
DoneAOEPlayer1
          
          rem Check Player 3
          
          if temp1 = 2 then DoneAOEPlayer2
          if playerHealth[2] = 0 then DoneAOEPlayer2
          if temp2 >= playerX[2] + 16 then DoneAOEPlayer2
          if temp2 + temp6 <= playerX[2] then DoneAOEPlayer2
          if temp3 >= playerY[2] + 16 then DoneAOEPlayer2
          if temp3 + temp3 <= playerY[2] then DoneAOEPlayer2
          let temp4 = 2
          return
DoneAOEPlayer2
          
          rem Check Player 4
          
          if temp1 = 3 then DoneAOEPlayer3
          if playerHealth[3] = 0 then DoneAOEPlayer3
          if temp2 >= playerX[3] + 16 then DoneAOEPlayer3
          if temp2 + temp6 <= playerX[3] then DoneAOEPlayer3
          if temp3 >= playerY[3] + 16 then DoneAOEPlayer3
          if temp3 + temp3 <= playerY[3] then DoneAOEPlayer3
          let temp4 = 3
          return
DoneAOEPlayer3
          
          return

CheckAOEDirection_Left
          rem
          rem Check Aoe Direction - Left
          rem Checks AOE collision when attacking to the left.
          rem Formula: AOE_X = playerX + 7 - offset
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
          rem Checks AOE collision when attacking to the left (AOE_X =
          rem playerX + 7 - offset)
          rem
          rem Input: temp1 = attacker player index (0-3), playerX[],
          rem playerY[] (global arrays) = player positions, playerCharacter[]
          rem (global array) = character types, playerHealth[] (global
          rem array) = player health, CharacterAOEOffsets[] (global data
          rem table) = AOE offsets
          rem
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no
          rem hit
          rem
          rem Mutates: temp1-temp6 (used for calculations), temp4
          rem (return value)
          rem
          rem Called Routines: None
          rem Constraints: None
          let temp2 = playerX[temp1] : 
          rem Get attacker position
          let temp3 = playerY[temp1]
          
          rem Calculate AOE bounds for facing left
          rem Read AOE offset from character data
          let temp5 = playerCharacter[temp1] : 
          rem Get character-specific AOE offset
          let aoeOffset_W = CharacterAOEOffsets[temp5]
          rem AOE_X = playerX + 7 - offset (facing left formula)
          let temp2 = temp2 + PlayerSpriteWidth - 1 - aoeOffset_R
          let temp6 = 8 
          let temp3 = 16 : 
          rem AOE width
          rem AOE height
          
          rem AOE extends to the left, so AOE goes from (aoeX -
          let temp2 = temp2 - temp6 : 
          rem   aoeWidth) to aoeX
          
          rem AOE bounding box:
          rem   Left:   aoeX
          rem   Right:  aoeX + aoeWidth
          rem   Top:    playerY
          rem   Bottom: playerY + aoeHeight
          
          let temp4 = 255 : 
          rem Check each player (except attacker)
          
          rem Check Player 1 (players are 16px wide - double-width
          rem NUSIZ)
          if temp1 = 0 then CheckPlayer2
          if playerHealth[0] = 0 then CheckPlayer2
          if temp2 >= playerX[0] + 16 then CheckPlayer2
          rem AOE left edge past player right edge
          if temp2 + temp6 <= playerX[0] then CheckPlayer2
          rem AOE right edge before player left edge
          if temp3 >= playerY[0] + 16 then CheckPlayer2
          rem AOE top edge past player bottom edge
          if temp3 + temp3 <= playerY[0] then CheckPlayer2
          let temp4 = 0 : 
          rem AOE bottom edge before player top edge
          return
CheckPlayer2
          
          rem Check Player 2
          
          if temp1 = 1 then DoneThirdPlayer1
          if playerHealth[1] = 0 then DoneThirdPlayer1
          if temp2 >= playerX[1] + 16 then DoneThirdPlayer1
          if temp2 + temp6 <= playerX[1] then DoneThirdPlayer1
          if temp3 >= playerY[1] + 16 then DoneThirdPlayer1
          if temp3 + temp3 <= playerY[1] then DoneThirdPlayer1
          let temp4 = 1
          return
DoneThirdPlayer1
          
          rem Check Player 3
          
          if temp1 = 2 then DoneThirdPlayer2
          if playerHealth[2] = 0 then DoneThirdPlayer2
          if temp2 >= playerX[2] + 16 then DoneThirdPlayer2
          if temp2 + temp6 <= playerX[2] then DoneThirdPlayer2
          if temp3 >= playerY[2] + 16 then DoneThirdPlayer2
          if temp3 + temp3 <= playerY[2] then DoneThirdPlayer2
          let temp4 = 2
          return
DoneThirdPlayer2
          
          rem Check Player 4
          
          if temp1 = 3 then DoneThirdPlayer3
          if playerHealth[3] = 0 then DoneThirdPlayer3
          if temp2 >= playerX[3] + 16 then DoneThirdPlayer3
          if temp2 + temp6 <= playerX[3] then DoneThirdPlayer3
          if temp3 >= playerY[3] + 16 then DoneThirdPlayer3
          if temp3 + temp3 <= playerY[3] then DoneThirdPlayer3
          let temp4 = 3
          return
DoneThirdPlayer3
          
          return

MissileCollPF
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
          rem Output: temp4 = 1 if hit playfield, 0 if clear
          rem
          rem Mutates: temp2 (used for missile X), temp3 (used for
          rem missile Y), temp4 (return value), temp6 (used for
          rem playfield column calculation)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2 = missileX[temp1] : 
          rem Get missile X/Y position
          let temp3 = missileY_R[temp1]
          
          rem Convert X to playfield coordinates
          let temp6 = temp2 / 5 : 
          rem Playfield is 32 pixels wide (doubled to 160 screen pixels)
          rem Convert X pixel to playfield column (160/32 ≈ 5)
          
          rem Check if playfield pixel is set at missile position
          let temp4 = 0 : 
          rem Assume clear until pfread says otherwise
          if pfread(temp6, temp3) then let temp4 = 1 : return
          rem pfread(column, row) returns 0 if clear, non-zero if set
          rem Clear
          return

