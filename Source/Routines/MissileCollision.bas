          rem ChaosFight - Source/Routines/MissileCollision.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem MISSILE COLLISION SYSTEM
          rem ==========================================================
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

          rem FACING DIRECTION FORMULA (for AOE attacks):
          rem   Facing right (bit 0 = 1): AOE_X = playerX + offset
          rem   Facing left  (bit 0 = 0): AOE_X = playerX + 7 - offset
          rem ==========================================================

          rem ==========================================================
          rem CHECK ALL MISSILE COLLISIONS
          rem ==========================================================
          rem Master routine called each frame to check all active
          rem   missiles.
          rem Checks both visible missiles and AOE attacks.

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem OUTPUT:
          rem   temp4 = 0 if no hit, or player index (0-3) if hit
CheckAllMissileCollisions
          rem Master routine called each frame to check all active missiles (visible and AOE)
          rem Input: temp1 = attacker player index (0-3), missileActive (global) = missile active flags, playerChar[] (global array) = character types
          rem Output: temp4 = hit player index (0-3) if hit, 0 if no hit
          rem Mutates: temp1-temp7 (used for calculations), temp4 (return value)
          rem Called Routines: GetMissileWidth (bank6) - gets missile width to determine if AOE or visible, CheckVisibleMissileCollision (tail call) - if visible missile, CheckAOECollision (goto) - if AOE attack
          rem Constraints: None
          dim CAMC_attackerIndex = temp1
          dim CAMC_missileWidth = temp6
          dim CAMC_isActive = temp4
          dim CAMC_characterType = temp5
          dim CAMC_savedCharType = temp7
          rem First, check if this player has an active missile
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if CAMC_attackerIndex = 0 then let CAMC_missileWidth = 1
          if CAMC_attackerIndex = 1 then let CAMC_missileWidth = 2
          if CAMC_attackerIndex = 2 then let CAMC_missileWidth = 4
          if CAMC_attackerIndex = 3 then let CAMC_missileWidth = 8
          let CAMC_isActive = missileActive & CAMC_missileWidth
          if CAMC_isActive = 0 then return 
          rem No active missile
          
          rem Get character type to determine missile properties
          let CAMC_characterType = playerChar[CAMC_attackerIndex]
          
          rem Check if this is a visible missile or AOE attack
          rem Read missile width from character data (in Bank 6)
          rem attackerIndex needs to be preserved, use temp7 for
          rem   function call
          let CAMC_savedCharType = CAMC_characterType 
          rem Character type as index
          let temp7 = CAMC_savedCharType
          gosub GetMissileWidth bank6
          let CAMC_missileWidth = temp2 
          rem Missile width (0 = AOE, >0 = visible missile)
          
          if CAMC_missileWidth = 0 then goto CheckAOECollision
          let temp1 = CAMC_attackerIndex
          rem tail call
          goto CheckVisibleMissileCollision
          

          rem ==========================================================
          rem CHECK VISIBLE MISSILE COLLISION
          rem ==========================================================
          rem Checks collision between a visible missile and all
          rem   players.
          rem Uses axis-aligned bounding box (AABB) collision detection.

          rem INPUT:
          rem   temp1 = attacker player index (0-3, missile owner)

          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckVisibleMissileCollision
          rem Checks collision between a visible missile and all players using AABB collision detection
          rem Input: temp1 = attacker player index (0-3, missile owner), missileX[] (global array) = missile X positions, missileY_R[] (global SCRAM array) = missile Y positions, playerChar[] (global array) = character types, playerX[], playerY[] (global arrays) = player positions, playerHealth[] (global array) = player health
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no hit
          rem Mutates: temp1-temp7 (used for calculations), temp4 (return value)
          rem Called Routines: GetMissileWidth (bank6) - gets missile width, GetMissileHeight (bank6) - gets missile height
          rem Constraints: None
          dim CVMC_attackerIndex = temp1
          dim CVMC_missileX = temp2
          dim CVMC_missileY = temp3
          dim CVMC_characterType = temp5
          dim CVMC_missileWidth = temp6
          dim CVMC_savedCharType = temp7
          dim CVMC_hitPlayer = temp4
          dim CVMC_missileHeight = temp3
          rem Get missile X/Y position
          let CVMC_missileX = missileX[CVMC_attackerIndex]
          let CVMC_missileY = missileY_R[CVMC_attackerIndex]
          
          rem Get missile size from character data (in Bank 6)
          rem Get character type from player
          let CVMC_characterType = playerChar[CVMC_attackerIndex]
          rem Use characterType as index (preserve attackerIndex)
          rem Save missileX/Y before function calls (functions use
          rem   temp2/temp3)
          let CVMC_savedCharType = CVMC_characterType
          let temp7 = CVMC_savedCharType
          gosub GetMissileWidth bank6
          let CVMC_missileWidth = temp2 
          rem Missile width (temp2 now contains width)
          rem Reload character index
          let temp7 = CVMC_savedCharType
          gosub GetMissileHeight bank6
          let CVMC_missileHeight = temp2 
          rem Missile height (temp2 now contains height)
          rem Restore missileX/Y (they were preserved in CVMC_* aliases)
          
          rem Missile bounding box:
          rem   Left:   missileX
          rem   Right:  missileX + missileWidth
          rem   Top:    missileY
          rem   Bottom: missileY + missileHeight
          
          rem Check collision with each player (except owner)
          let CVMC_hitPlayer = 255 
          rem Default: no hit
          
          rem Check Player 1 (index 0)
          if CVMC_attackerIndex = 0 then DoneSecondPlayer0
          if playerHealth[0] = 0 then DoneSecondPlayer0
          if CVMC_missileX >= playerX[0] + PlayerSpriteHalfWidth then DoneSecondPlayer0
          if CVMC_missileX + CVMC_missileWidth <= playerX[0] then DoneSecondPlayer0
          if CVMC_missileY >= playerY[0] + PlayerSpriteHeight then DoneSecondPlayer0
          if CVMC_missileY + CVMC_missileHeight <= playerY[0] then DoneSecondPlayer0
          let CVMC_hitPlayer = 0
          let temp4 = CVMC_hitPlayer
          return
DoneSecondPlayer0
          
          rem Check Player 2 (index 1)
          if CVMC_attackerIndex = 1 then DoneSecondPlayer1
          if playerHealth[1] = 0 then DoneSecondPlayer1
          if CVMC_missileX >= playerX[1] + PlayerSpriteHalfWidth then DoneSecondPlayer1
          if CVMC_missileX + CVMC_missileWidth <= playerX[1] then DoneSecondPlayer1
          if CVMC_missileY >= playerY[1] + PlayerSpriteHeight then DoneSecondPlayer1
          if CVMC_missileY + CVMC_missileHeight <= playerY[1] then DoneSecondPlayer1
          let CVMC_hitPlayer = 1
          let temp4 = CVMC_hitPlayer
          return
DoneSecondPlayer1
          
          rem Check Player 3 (index 2)
          if CVMC_attackerIndex = 2 then DoneSecondPlayer2
          if playerHealth[2] = 0 then DoneSecondPlayer2
          if CVMC_missileX >= playerX[2] + PlayerSpriteHalfWidth then DoneSecondPlayer2
          if CVMC_missileX + CVMC_missileWidth <= playerX[2] then DoneSecondPlayer2
          if CVMC_missileY >= playerY[2] + PlayerSpriteHeight then DoneSecondPlayer2
          if CVMC_missileY + CVMC_missileHeight <= playerY[2] then DoneSecondPlayer2
          let CVMC_hitPlayer = 2
          let temp4 = CVMC_hitPlayer
          return
DoneSecondPlayer2
          
          rem Check Player 4 (index 3)
          if CVMC_attackerIndex = 3 then DoneSecondPlayer3
          if playerHealth[3] = 0 then DoneSecondPlayer3
          if CVMC_missileX >= playerX[3] + PlayerSpriteHalfWidth then DoneSecondPlayer3
          if CVMC_missileX + CVMC_missileWidth <= playerX[3] then DoneSecondPlayer3
          if CVMC_missileY >= playerY[3] + PlayerSpriteHeight then DoneSecondPlayer3
          if CVMC_missileY + CVMC_missileHeight <= playerY[3] then DoneSecondPlayer3
          let CVMC_hitPlayer = 3
          let temp4 = CVMC_hitPlayer
          return
DoneSecondPlayer3
          
          return

          rem ==========================================================
          rem CHECK AOE COLLISION
          rem ==========================================================
          rem Checks collision for area-of-effect melee attacks (no
          rem   visible missile).
          rem AOE is relative to player position and facing direction.

          rem SPECIAL CASE: Bernie (character 0) Ground Thump attack
          rem   hits both left AND right simultaneously, shoving enemies
          rem   away rapidly.

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckAOECollision
          rem Checks collision for area-of-effect melee attacks (no visible missile)
          rem Input: temp1 = attacker player index (0-3), playerChar[] (global array) = character types, playerState[] (global array) = player states (bit 0 = facing), playerX[], playerY[] (global arrays) = player positions, playerHealth[] (global array) = player health, CharacterAOEOffsets[] (global data table) = AOE offsets
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no hit
          rem Mutates: temp1-temp7 (used for calculations), temp4 (return value)
          rem Called Routines: CheckAOEDirection_Right - checks AOE collision facing right, CheckAOEDirection_Left - checks AOE collision facing left, CheckBernieAOE - special case for Bernie (hits both directions)
          rem Constraints: Bernie (character 0) hits both left AND right simultaneously
          dim CAOC_attackerIndex = temp1
          dim CAOC_characterType = temp5
          dim CAOC_facing = temp6
          dim CAOC_hitPlayer = temp4
          rem Get attacker character type
          let CAOC_characterType = playerChar[CAOC_attackerIndex]
          
          rem Check if this is Bernie (character 0)
          rem Bernie attacks both left AND right, so check both
          rem   directions
          if CAOC_characterType = 0 then CheckBernieAOE
          
          rem Normal character: Check only facing direction
          let CAOC_facing = playerState[CAOC_attackerIndex] & PlayerStateBitFacing
          if CAOC_facing = 0 then CheckAOELeftDirection
          let temp1 = CAOC_attackerIndex
          gosub CheckAOEDirection_Right
          let CAOC_hitPlayer = temp4
          return
CheckAOELeftDirection
          let temp1 = CAOC_attackerIndex
          gosub CheckAOEDirection_Left
          let CAOC_hitPlayer = temp4
          return
          
CheckBernieAOE
          dim CBA_hitPlayer = temp4
          rem Bernie: Check right direction first
          let temp1 = CAOC_attackerIndex
          gosub CheckAOEDirection_Right
          let CBA_hitPlayer = temp4
          rem If hit found (hitPlayer != 255), return early
          rem Use skip-over pattern: if hitPlayer = 255, skip to left
          rem   check
          if CBA_hitPlayer = 255 then CheckBernieAOELeft
          let temp4 = CBA_hitPlayer
          return
          
CheckBernieAOELeft
          rem Check left direction
          let temp1 = CAOC_attackerIndex
          gosub CheckAOEDirection_Left
          let temp4 = temp4
          return

          rem ==========================================================
          rem CHECK AOE DIRECTION - RIGHT
          rem ==========================================================
          rem Checks AOE collision when attacking to the right.
          rem Formula: AOE_X = playerX + offset

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckAOEDirection_Right
          rem Checks AOE collision when attacking to the right (AOE_X = playerX + offset)
          rem Input: temp1 = attacker player index (0-3), playerX[], playerY[] (global arrays) = player positions, playerChar[] (global array) = character types, playerHealth[] (global array) = player health, CharacterAOEOffsets[] (global data table) = AOE offsets
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no hit
          rem Mutates: temp1-temp7 (used for calculations), temp4 (return value)
          rem Called Routines: None
          rem Constraints: None
          dim CAOER_attackerIndex = temp1
          dim CAOER_playerX = temp2
          dim CAOER_playerY = temp3
          dim CAOER_characterType = temp5
          dim CAOER_aoeOffset = temp7
          dim CAOER_aoeX = temp2
          dim CAOER_aoeWidth = temp6
          dim CAOER_aoeHeight = temp3
          dim CAOER_hitPlayer = temp4
          rem Get attacker position
          let CAOER_playerX = playerX[CAOER_attackerIndex]
          let CAOER_playerY = playerY[CAOER_attackerIndex]
          
          rem Calculate AOE bounds
          rem Read AOE offset from character data
          rem Get character-specific AOE offset
          let CAOER_characterType = playerChar[CAOER_attackerIndex]
          let CAOER_aoeOffset = CharacterAOEOffsets[CAOER_characterType]
          rem For now, use default: 8 pixels forward, 8 pixels wide, 16
          rem   pixels tall
          rem AOE_X = playerX + 8 (facing right formula)
          let CAOER_aoeX = CAOER_playerX + 8
          let CAOER_aoeWidth = 8 
          rem AOE width
          let CAOER_aoeHeight = 16
          rem AOE height
          
          rem AOE bounding box:
          rem   Left:   aoeX
          rem   Right:  aoeX + aoeWidth
          rem   Top:    playerY
          rem   Bottom: playerY + aoeHeight
          
          rem Check each player (except attacker)
          let CAOER_hitPlayer = 255
          
          rem Check Player 1 (players are 16px wide - double-width
          rem   NUSIZ)
          if CAOER_attackerIndex = 0 then DoneAOEPlayer0
          if playerHealth[0] = 0 then DoneAOEPlayer0
          if CAOER_aoeX >= playerX[0] + 16 then DoneAOEPlayer0
          rem AOE left edge past player right edge
          if CAOER_aoeX + CAOER_aoeWidth <= playerX[0] then DoneAOEPlayer0
          rem AOE right edge before player left edge
          if CAOER_playerY >= playerY[0] + 16 then DoneAOEPlayer0
          rem AOE top edge past player bottom edge
          if CAOER_playerY + CAOER_aoeHeight <= playerY[0] then DoneAOEPlayer0
          rem AOE bottom edge before player top edge
          let CAOER_hitPlayer = 0
          let temp4 = CAOER_hitPlayer
          return
DoneAOEPlayer0
          
          rem Check Player 2
          if CAOER_attackerIndex = 1 then DoneAOEPlayer1
          if playerHealth[1] = 0 then DoneAOEPlayer1
          if CAOER_aoeX >= playerX[1] + 16 then DoneAOEPlayer1
          if CAOER_aoeX + CAOER_aoeWidth <= playerX[1] then DoneAOEPlayer1
          if CAOER_playerY >= playerY[1] + 16 then DoneAOEPlayer1
          if CAOER_playerY + CAOER_aoeHeight <= playerY[1] then DoneAOEPlayer1
          let CAOER_hitPlayer = 1
          let temp4 = CAOER_hitPlayer
          return
DoneAOEPlayer1
          
          rem Check Player 3
          if CAOER_attackerIndex = 2 then DoneAOEPlayer2
          if playerHealth[2] = 0 then DoneAOEPlayer2
          if CAOER_aoeX >= playerX[2] + 16 then DoneAOEPlayer2
          if CAOER_aoeX + CAOER_aoeWidth <= playerX[2] then DoneAOEPlayer2
          if CAOER_playerY >= playerY[2] + 16 then DoneAOEPlayer2
          if CAOER_playerY + CAOER_aoeHeight <= playerY[2] then DoneAOEPlayer2
          let CAOER_hitPlayer = 2
          let temp4 = CAOER_hitPlayer
          return
DoneAOEPlayer2
          
          rem Check Player 4
          if CAOER_attackerIndex = 3 then DoneAOEPlayer3
          if playerHealth[3] = 0 then DoneAOEPlayer3
          if CAOER_aoeX >= playerX[3] + 16 then DoneAOEPlayer3
          if CAOER_aoeX + CAOER_aoeWidth <= playerX[3] then DoneAOEPlayer3
          if CAOER_playerY >= playerY[3] + 16 then DoneAOEPlayer3
          if CAOER_playerY + CAOER_aoeHeight <= playerY[3] then DoneAOEPlayer3
          let CAOER_hitPlayer = 3
          let temp4 = CAOER_hitPlayer
          return
DoneAOEPlayer3
          
          return

          rem ==========================================================
          rem CHECK AOE DIRECTION - LEFT
          rem ==========================================================
          rem Checks AOE collision when attacking to the left.
          rem Formula: AOE_X = playerX + 7 - offset

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckAOEDirection_Left
          rem Checks AOE collision when attacking to the left (AOE_X = playerX + 7 - offset)
          rem Input: temp1 = attacker player index (0-3), playerX[], playerY[] (global arrays) = player positions, playerChar[] (global array) = character types, playerHealth[] (global array) = player health, CharacterAOEOffsets[] (global data table) = AOE offsets
          rem Output: temp4 = hit player index (0-3) if hit, 255 if no hit
          rem Mutates: temp1-temp7 (used for calculations), temp4 (return value)
          rem Called Routines: None
          rem Constraints: None
          dim CAOEL_attackerIndex = temp1
          dim CAOEL_playerX = temp2
          dim CAOEL_playerY = temp3
          dim CAOEL_characterType = temp5
          dim CAOEL_aoeOffset = temp7
          dim CAOEL_aoeX = temp2
          dim CAOEL_aoeWidth = temp6
          dim CAOEL_aoeHeight = temp3
          dim CAOEL_hitPlayer = temp4
          rem Get attacker position
          let CAOEL_playerX = playerX[CAOEL_attackerIndex]
          let CAOEL_playerY = playerY[CAOEL_attackerIndex]
          
          rem Calculate AOE bounds for facing left
          rem Read AOE offset from character data
          rem Get character-specific AOE offset
          let CAOEL_characterType = playerChar[CAOEL_attackerIndex]
          let CAOEL_aoeOffset = CharacterAOEOffsets[CAOEL_characterType]
          rem For now, use default offset of 8 pixels
          rem AOE_X = playerX + 7 - 8 = playerX - 1 (facing left
          rem   formula)
          let CAOEL_aoeX = CAOEL_playerX - 1
          let CAOEL_aoeWidth = 8 
          rem AOE width
          let CAOEL_aoeHeight = 16
          rem AOE height
          
          rem AOE extends to the left, so AOE goes from (aoeX -
          rem   aoeWidth) to aoeX
          let CAOEL_aoeX = CAOEL_aoeX - CAOEL_aoeWidth
          
          rem AOE bounding box:
          rem   Left:   aoeX
          rem   Right:  aoeX + aoeWidth
          rem   Top:    playerY
          rem   Bottom: playerY + aoeHeight
          
          rem Check each player (except attacker)
          let CAOEL_hitPlayer = 255
          
          rem Check Player 1 (players are 16px wide - double-width
          rem   NUSIZ)
          if CAOEL_attackerIndex = 0 then CheckPlayer2
          if playerHealth[0] = 0 then CheckPlayer2
          if CAOEL_aoeX >= playerX[0] + 16 then CheckPlayer2
          rem AOE left edge past player right edge
          if CAOEL_aoeX + CAOEL_aoeWidth <= playerX[0] then CheckPlayer2
          rem AOE right edge before player left edge
          if CAOEL_playerY >= playerY[0] + 16 then CheckPlayer2
          rem AOE top edge past player bottom edge
          if CAOEL_playerY + CAOEL_aoeHeight <= playerY[0] then CheckPlayer2
          rem AOE bottom edge before player top edge
          let CAOEL_hitPlayer = 0
          let temp4 = CAOEL_hitPlayer
          return
CheckPlayer2
          
          rem Check Player 2
          if CAOEL_attackerIndex = 1 then DoneThirdPlayer1
          if playerHealth[1] = 0 then DoneThirdPlayer1
          if CAOEL_aoeX >= playerX[1] + 16 then DoneThirdPlayer1
          if CAOEL_aoeX + CAOEL_aoeWidth <= playerX[1] then DoneThirdPlayer1
          if CAOEL_playerY >= playerY[1] + 16 then DoneThirdPlayer1
          if CAOEL_playerY + CAOEL_aoeHeight <= playerY[1] then DoneThirdPlayer1
          let CAOEL_hitPlayer = 1
          let temp4 = CAOEL_hitPlayer
          return
DoneThirdPlayer1
          
          rem Check Player 3
          if CAOEL_attackerIndex = 2 then DoneThirdPlayer2
          if playerHealth[2] = 0 then DoneThirdPlayer2
          if CAOEL_aoeX >= playerX[2] + 16 then DoneThirdPlayer2
          if CAOEL_aoeX + CAOEL_aoeWidth <= playerX[2] then DoneThirdPlayer2
          if CAOEL_playerY >= playerY[2] + 16 then DoneThirdPlayer2
          if CAOEL_playerY + CAOEL_aoeHeight <= playerY[2] then DoneThirdPlayer2
          let CAOEL_hitPlayer = 2
          let temp4 = CAOEL_hitPlayer
          return
DoneThirdPlayer2
          
          rem Check Player 4
          if CAOEL_attackerIndex = 3 then DoneThirdPlayer3
          if playerHealth[3] = 0 then DoneThirdPlayer3
          if CAOEL_aoeX >= playerX[3] + 16 then DoneThirdPlayer3
          if CAOEL_aoeX + CAOEL_aoeWidth <= playerX[3] then DoneThirdPlayer3
          if CAOEL_playerY >= playerY[3] + 16 then DoneThirdPlayer3
          if CAOEL_playerY + CAOEL_aoeHeight <= playerY[3] then DoneThirdPlayer3
          let CAOEL_hitPlayer = 3
          let temp4 = CAOEL_hitPlayer
          return
DoneThirdPlayer3
          
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
MissileCollPF
          rem Checks if missile hit the playfield (walls, obstacles) using pfread
          rem Input: temp1 = player index (0-3), missileX[] (global array) = missile X positions, missileY_R[] (global SCRAM array) = missile Y positions
          rem Output: temp4 = 1 if hit playfield, 0 if clear
          rem Mutates: temp2 (used for missile X), temp3 (used for missile Y), temp4 (return value), temp6 (used for playfield column calculation)
          rem Called Routines: None
          rem Constraints: None
          rem Get missile X/Y position
          let temp2 = missileX[temp1]
          let temp3 = missileY_R[temp1]
          
          rem Convert X to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160 screen pixels)
          let temp6 = temp2 / 5 
          rem Convert X pixel to playfield column (160/32 ≈ 5)
          
          rem Check if playfield pixel is set at missile position
          rem pfread(column, row) returns 0 if clear, non-zero if set
          if pfread(temp6, temp3) then let temp4 = 1 : return
          rem Hit playfield

          let temp4 = 0 
          rem Clear
          
          
          return

