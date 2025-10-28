          rem ChaosFight - Source/Routines/MissileCollision.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem MISSILE COLLISION SYSTEM
          rem =================================================================
          rem Handles all collision detection for missiles and area-of-effect attacks.
          rem
          rem COLLISION TYPES:
          rem   1. Missile-to-Player: Visible missiles (ranged or melee visuals)
          rem   2. AOE-to-Player: Melee attacks with no visible missile (0×0 size)
          rem   3. Missile-to-Playfield: For missiles that interact with walls
          rem
          rem SPECIAL CASES:
          rem   - Bernie: AOE extends both left AND right simultaneously
          rem   - Other melee: AOE only in facing direction
          rem
          rem FACING DIRECTION FORMULA (for AOE attacks):
          rem   Facing right (bit 0 = 1): AOE_X = PlayerX + offset
          rem   Facing left  (bit 0 = 0): AOE_X = PlayerX + 7 - offset
          rem =================================================================

          rem =================================================================
          rem CHECK ALL MISSILE COLLISIONS
          rem =================================================================
          rem Master routine called each frame to check all active missiles.
          rem Checks both visible missiles and AOE attacks.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = 0 if no hit, or player index (0-3) if hit
CheckAllMissileCollisions
          rem First, check if this player has an active missile
          temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp4 = MissileActive & temp6
          if temp4 = 0 then return  : rem No active missile
          
          rem Get character type to determine missile properties
          temp5 = PlayerChar[temp1]
          
          rem Check if this is a visible missile or AOE attack
          rem Read missile width from character data
          temp1 = temp5  : rem Character type as index
          gosub GetMissileWidth
          temp6 = temp2  : rem Missile width (0 = AOE, >0 = visible missile)
          
          if temp6 = 0 then
                    rem AOE attack (no visible missile)
                    gosub CheckAOECollision
          else
                    rem Visible missile
                    gosub CheckVisibleMissileCollision
          endif
          
          return

          rem =================================================================
          rem CHECK VISIBLE MISSILE COLLISION
          rem =================================================================
          rem Checks collision between a visible missile and all players.
          rem Uses axis-aligned bounding box (AABB) collision detection.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3, missile owner)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckVisibleMissileCollision
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
          
          rem Get missile size from character data
          rem Get character type from player
          temp5 = PlayerChar[temp1]
          temp1 = temp5  : rem Use as index
          gosub GetMissileWidth
          temp6 = temp2  : rem Missile width
          temp1 = temp5  : rem Reload character index
          gosub GetMissileHeight
          temp5 = temp2  : rem Missile height (reusing temp5)
          
          rem Missile bounding box:
          rem   Left:   temp2
          rem   Right:  temp2 + temp6
          rem   Top:    temp3
          rem   Bottom: temp3 + temp5
          
          rem Check collision with each player (except owner)
          temp4 = 255  : rem Default: no hit
          
          rem Check Player 1 (index 0)
          if temp1 <> 0 then
                    if PlayerHealth[0] > 0 then
                              rem Player bounding box (8×16 pixels)
                              rem AABB collision test
                              if temp2 < PlayerX[0] + 8 then
                                        if temp2 + temp6 > PlayerX[0] then
                                                  if temp3 < PlayerY[0] + 16 then
                                                            if temp3 + temp5 > PlayerY[0] then
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
                                        if temp2 + temp6 > PlayerX[1] then
                                                  if temp3 < PlayerY[1] + 16 then
                                                            if temp3 + temp5 > PlayerY[1] then
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
                                        if temp2 + temp6 > PlayerX[2] then
                                                  if temp3 < PlayerY[2] + 16 then
                                                            if temp3 + temp5 > PlayerY[2] then
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
                                        if temp2 + temp6 > PlayerX[3] then
                                                  if temp3 < PlayerY[3] + 16 then
                                                            if temp3 + temp5 > PlayerY[3] then
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
          rem CHECK AOE COLLISION
          rem =================================================================
          rem Checks collision for area-of-effect melee attacks (no visible missile).
          rem AOE is relative to player position and facing direction.
          rem
          rem SPECIAL CASE: Bernie (character 0) attacks both left AND right.
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckAOECollision
          rem Get attacker character type
          temp5 = PlayerChar[temp1]
          
          rem Check if this is Bernie (character 0)
          if temp5 = 0 then
                    rem Bernie: Check both directions
                    gosub CheckAOEDirection_Right
                    if temp4 <> 255 then return  : rem Hit found on right side
                    gosub CheckAOEDirection_Left
                    return  : rem Return with result from left side
          else
                    rem Normal character: Check only facing direction
                    rem Get facing direction from PlayerState bit 0
                    temp6 = PlayerState[temp1] & 1
                    if temp6 = 0 then
                              gosub CheckAOEDirection_Left
                    else
                              gosub CheckAOEDirection_Right
                    endif
                    return
          endif

          rem =================================================================
          rem CHECK AOE DIRECTION - RIGHT
          rem =================================================================
          rem Checks AOE collision when attacking to the right.
          rem Formula: AOE_X = PlayerX + offset
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckAOEDirection_Right
          rem Get attacker position
          if temp1 = 0 then
                    temp2 = PlayerX[0]
                    temp3 = PlayerY[0]
          endif
          if temp1 = 1 then
                    temp2 = PlayerX[1]
                    temp3 = PlayerY[1]
          endif
          if temp1 = 2 then
                    temp2 = PlayerX[2]
                    temp3 = PlayerY[2]
          endif
          if temp1 = 3 then
                    temp2 = PlayerX[3]
                    temp3 = PlayerY[3]
          endif
          
          rem Calculate AOE bounds
          rem Read AOE offset from character data
          rem Get character-specific AOE offset
          temp7 = CharacterAOEOffsets[temp5]
          rem For now, use default: 8 pixels forward, 8 pixels wide, 16 pixels tall
          rem AOE_X = temp2 + 8 (facing right formula)
          temp2 = temp2 + 8
          temp6 = 8  : rem AOE width
          temp5 = 16 : rem AOE height
          
          rem AOE bounding box:
          rem   Left:   temp2
          rem   Right:  temp2 + temp6
          rem   Top:    temp3
          rem   Bottom: temp3 + temp5
          
          rem Check each player (except attacker)
          temp4 = 255
          
          rem Check Player 1
          if temp1 <> 0 then
                    if PlayerHealth[0] > 0 then
                              if temp2 < PlayerX[0] + 8 then
                                        if temp2 + temp6 > PlayerX[0] then
                                                  if temp3 < PlayerY[0] + 16 then
                                                            if temp3 + temp5 > PlayerY[0] then
                                                                      temp4 = 0
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 2
          if temp1 <> 1 then
                    if PlayerHealth[1] > 0 then
                              if temp2 < PlayerX[1] + 8 then
                                        if temp2 + temp6 > PlayerX[1] then
                                                  if temp3 < PlayerY[1] + 16 then
                                                            if temp3 + temp5 > PlayerY[1] then
                                                                      temp4 = 1
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 3
          if temp1 <> 2 then
                    if PlayerHealth[2] > 0 then
                              if temp2 < PlayerX[2] + 8 then
                                        if temp2 + temp6 > PlayerX[2] then
                                                  if temp3 < PlayerY[2] + 16 then
                                                            if temp3 + temp5 > PlayerY[2] then
                                                                      temp4 = 2
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 4
          if temp1 <> 3 then
                    if PlayerHealth[3] > 0 then
                              if temp2 < PlayerX[3] + 8 then
                                        if temp2 + temp6 > PlayerX[3] then
                                                  if temp3 < PlayerY[3] + 16 then
                                                            if temp3 + temp5 > PlayerY[3] then
                                                                      temp4 = 3
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          return

          rem =================================================================
          rem CHECK AOE DIRECTION - LEFT
          rem =================================================================
          rem Checks AOE collision when attacking to the left.
          rem Formula: AOE_X = PlayerX + 7 - offset
          rem
          rem INPUT:
          rem   temp1 = attacker player index (0-3)
          rem
          rem OUTPUT:
          rem   temp4 = hit player index (0-3), or 255 if no hit
CheckAOEDirection_Left
          rem Get attacker position
          if temp1 = 0 then
                    temp2 = PlayerX[0]
                    temp3 = PlayerY[0]
          endif
          if temp1 = 1 then
                    temp2 = PlayerX[1]
                    temp3 = PlayerY[1]
          endif
          if temp1 = 2 then
                    temp2 = PlayerX[2]
                    temp3 = PlayerY[2]
          endif
          if temp1 = 3 then
                    temp2 = PlayerX[3]
                    temp3 = PlayerY[3]
          endif
          
          rem Calculate AOE bounds for facing left
          rem Read AOE offset from character data
          rem Get character-specific AOE offset
          temp7 = CharacterAOEOffsets[temp5]
          rem For now, use default offset of 8 pixels
          rem AOE_X = temp2 + 7 - 8 = temp2 - 1 (facing left formula)
          temp2 = temp2 - 1
          temp6 = 8  : rem AOE width
          temp5 = 16 : rem AOE height
          
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
          if temp1 <> 0 then
                    if PlayerHealth[0] > 0 then
                              if temp2 < PlayerX[0] + 8 then
                                        if temp2 + temp6 > PlayerX[0] then
                                                  if temp3 < PlayerY[0] + 16 then
                                                            if temp3 + temp5 > PlayerY[0] then
                                                                      temp4 = 0
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 2
          if temp1 <> 1 then
                    if PlayerHealth[1] > 0 then
                              if temp2 < PlayerX[1] + 8 then
                                        if temp2 + temp6 > PlayerX[1] then
                                                  if temp3 < PlayerY[1] + 16 then
                                                            if temp3 + temp5 > PlayerY[1] then
                                                                      temp4 = 1
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 3
          if temp1 <> 2 then
                    if PlayerHealth[2] > 0 then
                              if temp2 < PlayerX[2] + 8 then
                                        if temp2 + temp6 > PlayerX[2] then
                                                  if temp3 < PlayerY[2] + 16 then
                                                            if temp3 + temp5 > PlayerY[2] then
                                                                      temp4 = 2
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
          rem Check Player 4
          if temp1 <> 3 then
                    if PlayerHealth[3] > 0 then
                              if temp2 < PlayerX[3] + 8 then
                                        if temp2 + temp6 > PlayerX[3] then
                                                  if temp3 < PlayerY[3] + 16 then
                                                            if temp3 + temp5 > PlayerY[3] then
                                                                      temp4 = 3
                                                                      return
                                                            endif
                                                  endif
                                        endif
                              endif
                    endif
          endif
          
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
          
          rem Convert X to playfield coordinates
          rem Playfield is 32 pixels wide (doubled to 160 screen pixels)
          temp6 = temp2 / 5  : rem Convert X pixel to playfield column (160/32 ≈ 5)
          
          rem Check if playfield pixel is set at missile position
          rem pfread(column, row) returns 0 if clear, non-zero if set
          if pfread(temp6, temp3) then
                    temp4 = 1  : rem Hit playfield
          else
                    temp4 = 0  : rem Clear
          endif
          
          return

