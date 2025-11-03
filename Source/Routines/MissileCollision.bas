          rem ChaosFight - Source/Routines/MissileCollision.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem MISSILE COLLISION SYSTEM
          rem =================================================================
          rem Handles all collision detection for missiles and area-of-effect attacks.

          rem COLLISION TYPES:
          rem   1. Missile-to-Player: Visible missiles (ranged or melee visuals)
          rem   2. AOE-to-Player: Melee attacks with no visible missile (0×0 size)
          rem   3. Missile-to-Playfield: For missiles that interact with walls

          rem SPECIAL CASES:
          rem   - Bernie: AOE extends both left AND right simultaneously
          rem   - Other melee: AOE only in facing direction

          rem FACING DIRECTION FORMULA (for AOE attacks):
          rem   Facing right (bit 0 = 1): AOE_X = PlayerX + offset
          rem   Facing left  (bit 0 = 0): AOE_X = PlayerX + 7 - offset
          rem =================================================================

          rem =================================================================
          rem CHECK ALL MISSILE COLLISIONS
          rem =================================================================
          rem Master routine called each frame to check all active missiles.
          rem Checks both visible missiles and AOE attacks.

          rem INPUT:
          rem   temp1 = attacker player index (0-3)

          rem OUTPUT:
          rem   temp4 = 0 if no hit, or player index (0-3) if hit
CheckAllMissileCollisions
          rem First, check if this player has an active missile
          rem Calculate bit flag: 1, 2, 4, 8 for array indices 0, 1, 2, 3 (participants 1, 2, 3, 4)
          if temp1 = 0 then temp6 = 1
          rem Array [0] = Participant 1 → bit 0
          if temp1 = 1 then temp6 = 2
          rem Array [1] = Participant 2 → bit 1
          if temp1 = 2 then temp6 = 4
          rem Array [2] = Participant 3 → bit 2
          if temp1 = 3 then temp6 = 8
          rem Array [3] = Participant 4 → bit 3
          temp4 = MissileActive & temp6
          if temp4 = 0 then return 
          rem No active missile
          
          rem Get character type to determine missile properties
          temp5 = PlayerChar[temp1]
          
          rem Check if this is a visible missile or AOE attack
          rem Read missile width from character data (in Bank 6)
          temp1 = temp5 
          rem Character type as index
          gosub bank6 GetMissileWidth
          temp6 = temp2 
          rem Missile width (0 = AOE, >0 = visible missile)
          
          if temp6 = 0 then goto CheckAOECollision
          gosub CheckVisibleMissileCollision
          
          return

          rem =================================================================
          rem CHECK VISIBLE MISSILE COLLISION
          rem =================================================================
          rem Checks collision between a visible missile and all players.
          rem Uses axis-aligned bounding box (AABB) collision detection.

          rem INPUT:
          rem   temp1 = attacker participant array index (0-3 maps to participants 1-4, missile owner)

          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckVisibleMissileCollision
          rem Get missile X/Y position
          temp2 = MissileX[temp1]
          temp3 = MissileY[temp1]
          
          rem Get missile size from character data (in Bank 6)
          rem Get character type from player
          temp5 = PlayerChar[temp1]
          temp1 = temp5 
          rem Use as index
          gosub bank6 GetMissileWidth
          temp6 = temp2 
          rem Missile width
          temp1 = temp5 
          rem Reload character index
          gosub bank6 GetMissileHeight
          temp5 = temp2 
          rem Missile height (reusing temp5)
          
          rem Missile bounding box:
          rem   Left:   temp2
          rem   Right:  temp2 + temp6
          rem   Top:    temp3
          rem   Bottom: temp3 + temp5
          
          rem Check collision with each player (except owner)
          temp4 = 255 
          rem Default: no hit
          
          rem Check Participant 1 (array [0])
          if temp1 = 0 then goto SkipSecondParticipant1
          if PlayerHealth[0] = 0 then goto SkipSecondParticipant1
          if temp2 >= PlayerX[0] + 8 then goto SkipSecondParticipant1
          if temp2 + temp6 <= PlayerX[0] then goto SkipSecondParticipant1
          if temp3 >= PlayerY[0] + 16 then goto SkipSecondParticipant1
          if temp3 + temp5 <= PlayerY[0] then goto SkipSecondParticipant1
          temp4 = 0 : return
          rem Hit Participant 1 (array [0])
SkipSecondParticipant1
          
          rem Check Participant 2 (array [1])
          if temp1 = 1 then goto SkipSecondParticipant2
          if PlayerHealth[1] = 0 then goto SkipSecondPlayer1
          if temp2 >= PlayerX[1] + 8 then goto SkipSecondPlayer1
          if temp2 + temp6 <= PlayerX[1] then goto SkipSecondPlayer1
          if temp3 >= PlayerY[1] + 16 then goto SkipSecondPlayer1
          if temp3 + temp5 <= PlayerY[1] then goto SkipSecondPlayer1
          temp4 = 1 : return
SkipSecondPlayer1
          
          rem Check Participant 3 (array [2])
          if temp1 = 2 then goto SkipSecondParticipant3
          if PlayerHealth[2] = 0 then goto SkipSecondParticipant3
          if temp2 >= PlayerX[2] + 8 then goto SkipSecondParticipant3
          if temp2 + temp6 <= PlayerX[2] then goto SkipSecondParticipant3
          if temp3 >= PlayerY[2] + 16 then goto SkipSecondParticipant3
          if temp3 + temp5 <= PlayerY[2] then goto SkipSecondParticipant3
          temp4 = 2 : return
          rem Hit Participant 3 (array [2])
SkipSecondParticipant3
          
          rem Check Participant 4 (array [3])
          if temp1 = 3 then goto SkipSecondParticipant4
          if PlayerHealth[3] = 0 then goto SkipSecondParticipant4
          if temp2 >= PlayerX[3] + 8 then goto SkipSecondParticipant4
          if temp2 + temp6 <= PlayerX[3] then goto SkipSecondParticipant4
          if temp3 >= PlayerY[3] + 16 then goto SkipSecondParticipant4
          if temp3 + temp5 <= PlayerY[3] then goto SkipSecondParticipant4
          temp4 = 3 : return
          rem Hit Participant 4 (array [3])
SkipSecondParticipant4
          
          return

          rem =================================================================
          rem CHECK AOE COLLISION
          rem =================================================================
          rem Checks collision for area-of-effect melee attacks (no visible missile).
          rem AOE is relative to player position and facing direction.

          rem SPECIAL CASE: Bernie (character 0) attacks both left AND right.

          rem INPUT:
          rem   temp1 = attacker participant array index (0-3 maps to participants 1-4)

          rem OUTPUT:
          rem   temp4 = hit participant array index (0-3 maps to participants 1-4), or 255 if no hit
CheckAOECollision
          rem Get attacker character type
          temp5 = PlayerChar[temp1]
          
          rem Check if this is Bernie (character 0)
          rem Bernie attacks both left AND right, so check both directions
          if temp5 = 0 then goto CheckBernieAOE
          
          rem Normal character: Check only facing direction
          temp6 = PlayerState[temp1] & 1
          if temp6 = 0 then gosub CheckAOEDirectionLeft : return
          gosub CheckAOEDirectionRight
          return
          
CheckBernieAOE
          rem Bernie: Check right direction first
          gosub CheckAOEDirection_Right
          rem If hit found (temp4 != 255), return early
          rem Use skip-over pattern: if temp4 = 255, skip to left check
          if temp4 = 255 then goto CheckBernieAOELeft
          return
          
CheckBernieAOELeft
          rem Check left direction
          gosub CheckAOEDirectionLeft
          return

          rem =================================================================
          rem CHECK AOE DIRECTION - RIGHT
          rem =================================================================
          rem Checks AOE collision when attacking to the right.
          rem Formula: AOE_X = PlayerX + offset

          rem INPUT:
          rem   temp1 = attacker participant array index (0-3 maps to participants 1-4)

          rem OUTPUT:
          rem   temp4 = hit participant array index (0-3 maps to participants 1-4), or 255 if no hit
CheckAOEDirectionRight
          rem Get attacker position
          temp2 = PlayerX[temp1]
          temp3 = PlayerY[temp1]
          
          rem Calculate AOE bounds
          rem Read AOE offset from character data
          rem Get character-specific AOE offset
          temp7 = CharacterAOEOffsets[temp5]
          rem For now, use default: 8 pixels forward, 8 pixels wide, 16 pixels tall
          rem AOE_X = temp2 + 8 (facing right formula)
          temp2 = temp2 + 8
          temp6 = 8 
          rem AOE width
          temp5 = 16
          rem AOE height
          
          rem AOE bounding box:
          rem   Left:   temp2
          rem   Right:  temp2 + temp6
          rem   Top:    temp3
          rem   Bottom: temp3 + temp5
          
          rem Check each player (except attacker)
          temp4 = 255
          
          rem Check Player 1
          if temp1 = 0 then goto SkipAOEPlayer0
          if PlayerHealth[0] = 0 then goto SkipAOEPlayer0
          if temp2 >= PlayerX[0] + 8 then goto SkipAOEPlayer0
          if temp2 + temp6 <= PlayerX[0] then goto SkipAOEPlayer0
          if temp3 >= PlayerY[0] + 16 then goto SkipAOEPlayer0
          if temp3 + temp5 <= PlayerY[0] then goto SkipAOEPlayer0
          temp4 = 0 : return
SkipAOEPlayer0
          
          rem Check Player 2
          if temp1 = 1 then goto SkipAOEPlayer1
          if PlayerHealth[1] = 0 then goto SkipAOEPlayer1
          if temp2 >= PlayerX[1] + 8 then goto SkipAOEPlayer1
          if temp2 + temp6 <= PlayerX[1] then goto SkipAOEPlayer1
          if temp3 >= PlayerY[1] + 16 then goto SkipAOEPlayer1
          if temp3 + temp5 <= PlayerY[1] then goto SkipAOEPlayer1
          temp4 = 1 : return
SkipAOEPlayer1
          
          rem Check Player 3
          if temp1 = 2 then goto SkipAOEPlayer2
          if PlayerHealth[2] = 0 then goto SkipAOEPlayer2
          if temp2 >= PlayerX[2] + 8 then goto SkipAOEPlayer2
          if temp2 + temp6 <= PlayerX[2] then goto SkipAOEPlayer2
          if temp3 >= PlayerY[2] + 16 then goto SkipAOEPlayer2
          if temp3 + temp5 <= PlayerY[2] then goto SkipAOEPlayer2
          temp4 = 2 : return
SkipAOEPlayer2
          
          rem Check Player 4
          if temp1 = 3 then goto SkipAOEPlayer3
          if PlayerHealth[3] = 0 then goto SkipAOEPlayer3
          if temp2 >= PlayerX[3] + 8 then goto SkipAOEPlayer3
          if temp2 + temp6 <= PlayerX[3] then goto SkipAOEPlayer3
          if temp3 >= PlayerY[3] + 16 then goto SkipAOEPlayer3
          if temp3 + temp5 <= PlayerY[3] then goto SkipAOEPlayer3
          temp4 = 3 : return
SkipAOEPlayer3
          
          return

          rem =================================================================
          rem CHECK AOE DIRECTION - LEFT
          rem =================================================================
          rem Checks AOE collision when attacking to the left.
          rem Formula: AOE_X = PlayerX + 7 - offset

          rem INPUT:
          rem   temp1 = attacker participant array index (0-3 maps to participants 1-4)

          rem OUTPUT:
          rem   temp4 = hit participant array index (0-3 maps to participants 1-4), or 255 if no hit
CheckAOEDirectionLeft
          rem Get attacker position
          temp2 = PlayerX[temp1]
          temp3 = PlayerY[temp1]
          
          rem Calculate AOE bounds for facing left
          rem Read AOE offset from character data
          rem Get character-specific AOE offset
          temp7 = CharacterAOEOffsets[temp5]
          rem For now, use default offset of 8 pixels
          rem AOE_X = temp2 + 7 - 8 = temp2 - 1 (facing left formula)
          temp2 = temp2 - 1
          temp6 = 8 
          rem AOE width
          temp5 = 16
          rem AOE height
          
          rem AOE extends to the left, so AOE goes from (temp2 - temp6) to temp2
          temp2 = temp2 - temp6
          
          rem AOE bounding box:
          rem   Left:   temp2
          rem   Right:  temp2 + temp6
          rem   Top:    temp3
          rem   Bottom: temp3 + temp5
          
          rem Check each player (except attacker)
          temp4 = 255
          
          rem Check Player 1
          if temp1 = 0 then goto CheckPlayer2
          if PlayerHealth[0] = 0 then goto CheckPlayer2
          if temp2 >= PlayerX[0] + 8 then goto CheckPlayer2
          if temp2 + temp6 <= PlayerX[0] then goto CheckPlayer2
          if temp3 >= PlayerY[0] + 16 then goto CheckPlayer2
          if temp3 + temp5 <= PlayerY[0] then goto CheckPlayer2
          temp4 = 0
          return
CheckPlayer2
          
          
          
          
          
          
          
          rem Check Player 2
          if temp1 = 1 then goto SkipThirdPlayer1
          if PlayerHealth[1] = 0 then goto SkipThirdPlayer1
          if temp2 >= PlayerX[1] + 8 then goto SkipThirdPlayer1
          if temp2 + temp6 <= PlayerX[1] then goto SkipThirdPlayer1
          if temp3 >= PlayerY[1] + 16 then goto SkipThirdPlayer1
          if temp3 + temp5 <= PlayerY[1] then goto SkipThirdPlayer1
          temp4 = 1 : return
SkipThirdPlayer1
          
          rem Check Player 3
          if temp1 = 2 then goto SkipThirdPlayer2
          if PlayerHealth[2] = 0 then goto SkipThirdPlayer2
          if temp2 >= PlayerX[2] + 8 then goto SkipThirdPlayer2
          if temp2 + temp6 <= PlayerX[2] then goto SkipThirdPlayer2
          if temp3 >= PlayerY[2] + 16 then goto SkipThirdPlayer2
          if temp3 + temp5 <= PlayerY[2] then goto SkipThirdPlayer2
          temp4 = 2 : return
SkipThirdPlayer2
          
          rem Check Player 4
          if temp1 = 3 then goto SkipThirdPlayer3
          if PlayerHealth[3] = 0 then goto SkipThirdPlayer3
          if temp2 >= PlayerX[3] + 8 then goto SkipThirdPlayer3
          if temp2 + temp6 <= PlayerX[3] then goto SkipThirdPlayer3
          if temp3 >= PlayerY[3] + 16 then goto SkipThirdPlayer3
          if temp3 + temp5 <= PlayerY[3] then goto SkipThirdPlayer3
          temp4 = 3 : return
SkipThirdPlayer3
          
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
MissileCollPF
          rem Get missile X/Y position
          temp2 = MissileX[temp1]
          temp3 = MissileY[temp1]
          
          rem Convert X to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160 screen pixels)
          temp6 = temp2 / 5 
          rem Convert X pixel to playfield column (160/32 ≈ 5)
          
          rem Check if playfield pixel is set at missile position
          rem pfread(column, row) returns 0 if clear, non-zero if set
          if pfread(temp6, temp3) then temp4 = 1 : return
          rem Hit playfield

          temp4 = 0 
          rem Clear
          
          
          return

