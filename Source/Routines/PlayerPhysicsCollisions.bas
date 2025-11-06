          rem ChaosFight - Source/Routines/PlayerPhysicsCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem PLAYER PHYSICS - COLLISIONS
          rem ==========================================================
          rem Handles boundary, playfield, and player-to-player collisions.
          rem Split from PlayerPhysics.bas to reduce bank size.

          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem playerVelocityX[0-3] - Horizontal velocity (8.8
          rem   fixed-point)
          rem playerVelocityY[0-3] - Vertical velocity (8.8 fixed-point)
          rem playerChar[0-3] - Character type indices
          rem QuadtariDetected - Whether 4-player mode active
          rem   selectedChar3_R, selectedChar4_R - Player 3/4 selections
          rem ==========================================================

          rem ==========================================================
          rem CHECK BOUNDARY COLLISIONS
          rem ==========================================================
          rem Prevents players from moving off-screen.
CheckBoundaryCollisions
          dim CBC_playerIndex = temp1
          dim CBC_characterType = temp2
          rem Loop through all players (0-3) - fully inlined to avoid labels
          rem Handle RandomArena by checking selected arena (shared for all players)
          dim CBC_arenaIndex = temp3
          let CBC_arenaIndex = selectedArena_R
          rem Handle RandomArena (use frame-based selection for consistency)
          if CBC_arenaIndex = RandomArena then let CBC_arenaIndex = frame & 15
          
          rem Player 0 - boundaries
          let CBC_playerIndex = 0
          rem Horizontal wrap: X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[0] < 10 then let playerX[0] = 150 : let playerSubpixelX[0] = 150 : let playerSubpixelXL[0] = 0
          if playerX[0] > 150 then let playerX[0] = 10 : let playerSubpixelX[0] = 10 : let playerSubpixelXL[0] = 0
          rem Y clamp: top 20, bottom 80
          if playerY[0] < 20 then let playerY[0] = 20 : let playerSubpixelY[0] = 20 : let playerSubpixelYL[0] = 0 : let playerVelocityY[0] = 0 : let playerVelocityYL[0] = 0
          if playerY[0] > 80 then let playerY[0] = 80 : let playerSubpixelY[0] = 80 : let playerSubpixelYL[0] = 0 : let playerVelocityY[0] = 0 : let playerVelocityYL[0] = 0
          
          rem Player 1 - boundaries
          let CBC_playerIndex = 1
          rem Horizontal wrap: X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[1] < 10 then let playerX[1] = 150 : let playerSubpixelX[1] = 150 : let playerSubpixelXL[1] = 0
          if playerX[1] > 150 then let playerX[1] = 10 : let playerSubpixelX[1] = 10 : let playerSubpixelXL[1] = 0
          rem Y clamp: top 20, bottom 80
          if playerY[1] < 20 then let playerY[1] = 20 : let playerSubpixelY[1] = 20 : let playerSubpixelYL[1] = 0 : let playerVelocityY[1] = 0 : let playerVelocityYL[1] = 0
          if playerY[1] > 80 then let playerY[1] = 80 : let playerSubpixelY[1] = 80 : let playerSubpixelYL[1] = 0 : let playerVelocityY[1] = 0 : let playerVelocityYL[1] = 0
          
          rem Player 2 - boundaries (if Quadtari and active) - inline nested ifs
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then let CBC_playerIndex = 2
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then if playerX[2] < 10 then let playerX[2] = 150 : let playerSubpixelX[2] = 150 : let playerSubpixelXL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then if playerX[2] > 150 then let playerX[2] = 10 : let playerSubpixelX[2] = 10 : let playerSubpixelXL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then if playerY[2] < 20 then let playerY[2] = 20 : let playerSubpixelY[2] = 20 : let playerSubpixelYL[2] = 0 : let playerVelocityY[2] = 0 : let playerVelocityYL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(selectedChar3_R = 255) then if playerY[2] > 80 then let playerY[2] = 80 : let playerSubpixelY[2] = 80 : let playerSubpixelYL[2] = 0 : let playerVelocityY[2] = 0 : let playerVelocityYL[2] = 0
          
          rem Player 3 - boundaries (if Quadtari and active) - inline nested ifs
          if controllerStatus & SetQuadtariDetected then if !(selectedChar4_R = 255) then let CBC_playerIndex = 3
          if controllerStatus & SetQuadtariDetected then if !(selectedChar4_R = 255) then if playerX[3] < 10 then let playerX[3] = 150 : let playerSubpixelX[3] = 150 : let playerSubpixelXL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(selectedChar4_R = 255) then if playerX[3] > 150 then let playerX[3] = 10 : let playerSubpixelX[3] = 10 : let playerSubpixelXL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(selectedChar4_R = 255) then if playerY[3] < 20 then let playerY[3] = 20 : let playerSubpixelY[3] = 20 : let playerSubpixelYL[3] = 0 : let playerVelocityY[3] = 0 : let playerVelocityYL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(selectedChar4_R = 255) then if playerY[3] > 80 then let playerY[3] = 80 : let playerSubpixelY[3] = 80 : let playerSubpixelYL[3] = 0 : let playerVelocityY[3] = 0 : let playerVelocityYL[3] = 0
          
          return

          rem ==========================================================
          rem CHECK PLAYFIELD COLLISION ALL DIRECTIONS
          rem ==========================================================
          rem Checks for playfield pixel collisions in all four
          rem   directions and
          rem blocks movement by zeroing velocity in the collision
          rem   direction.
          rem Uses CharacterHeights table for proper hitbox detection.
          rem
          rem INPUT: currentPlayer = player index (0-3) (global variable)
          rem MODIFIES: playerVelocityX/Y and playerSubpixelX/Y when
          rem   collisions detected
CheckPlayfieldCollisionAllDirections
          rem Get player position and character info
          let temp2 = playerX[currentPlayer]
          rem X position (save original)
          let temp3 = playerY[currentPlayer]
          rem Y position
          let temp4 = playerChar[currentPlayer]
          rem Character index
          let temp5 = CharacterHeights[temp4]
          rem Character height
          
          rem Convert X position to playfield column (0-31)
          let temp6 = temp2
          rem Save original X in temp6
          let temp6 = temp6 - ScreenInsetX
          rem Divide by 4 using bit shift (2 right shifts)
          asm
            lsr temp6
            lsr temp6
end
          rem temp6 = playfield column (0-31)
          rem Clamp column to valid range
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp6 & $80 then let temp6 = 0
          if temp6 > 31 then let temp6 = 31
          
          rem Convert Y position to playfield row (0-pfrows-1)
          rem Divide by pfrowheight using helper
          let temp2 = temp3
          gosub DivideByPfrowheight
          let playfieldRow = temp2
          rem playfieldRow = playfield row
          if playfieldRow >= pfrows then let playfieldRow = pfrows - 1
          rem Check for wraparound: if division resulted in value ≥ 128 (negative), clamp to 0
          if playfieldRow & $80 then let playfieldRow = 0
          
          rem ==========================================================
          rem CHECK LEFT COLLISION
          rem ==========================================================
          rem Check if player left edge (temp6 column) has a playfield pixel
          rem Check at player head, middle, and feet positions
          rem Skip if at left edge (temp6 is 0-31, so <= 0 means exactly 0)
          if temp6 = 0 then goto PFCheckRight
          rem At left edge of screen, skip check
          
          let playfieldColumn = temp6 - 1
          rem Column to the left (playfieldColumn)
          rem Check for wraparound: if temp6 was 0, playfieldColumn wraps to 255 (≥ 128)
          if playfieldColumn & $80 then goto PFCheckRight
          rem Out of bounds, skip
          
          rem Check head position (top of sprite)
          if pfread(playfieldColumn, playfieldRow) then goto PFBlockLeft
          rem Check middle position
          rem Calculate (temp5 / 2) / pfrowheight
          asm
            lda temp5
            lsr a
            sta temp2
end
          rem temp2 = temp5 / 2
          gosub DivideByPfrowheight
          rem temp2 = (temp5 / 2) / pfrowheight
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckRight
          if pfread(playfieldColumn, rowCounter) then goto PFBlockLeft
          rem Check feet position (bottom of sprite)
          let temp2 = temp5
          gosub DivideByPfrowheight
          rem temp2 = temp5 / pfrowheight
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckRight
          if pfread(playfieldColumn, rowCounter) then goto PFBlockLeft
          
          goto PFCheckRight
          
PFBlockLeft
          rem Block leftward movement: zero X velocity if negative
          rem Check for negative velocity using twos complement (values ≥ 128 are negative)
          if playerVelocityX[currentPlayer] & $80 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          rem Multiply (temp6 + 1) by 4 using bit shift (2 left shifts)
          let rowYPosition = temp6 + 1
          asm
            lda rowYPosition
            asl a
            asl a
            clc
            adc #ScreenInsetX
            sta rowYPosition
end
          rem Reuse rowYPosition for X position clamp (not actually Y,
          rem   but same pattern)
          if playerX[currentPlayer] < rowYPosition then let playerX[currentPlayer] = rowYPosition
          if playerX[currentPlayer] < rowYPosition then let playerSubpixelX[currentPlayer] = rowYPosition
          if playerX[currentPlayer] < rowYPosition then let playerSubpixelXL[currentPlayer] = 0
          
          rem ==========================================================
          rem CHECK RIGHT COLLISION
          rem ==========================================================
PFCheckRight
          rem Check if player right edge has a playfield pixel
          rem Player width is 16 pixels (double-width NUSIZ), so right
          rem   edge is at temp6 + 4 columns (16px / 4px per column = 4)
          if temp6 >= 31 then goto PFCheckUp
          rem At right edge of screen, skip check
          
          let playfieldColumn = temp6 + 4
          rem Column to the right of player right edge (playfieldColumn)
          if playfieldColumn > 31 then goto PFCheckUp
          rem Out of bounds, skip
          
          rem Check head, middle, and feet positions
          if pfread(playfieldColumn, playfieldRow) then goto PFBlockRight
          rem Calculate (temp5 / 2) / pfrowheight
          asm
            lda temp5
            lsr a
            sta temp2
end
          rem temp2 = temp5 / 2
          gosub DivideByPfrowheight
          rem temp2 = (temp5 / 2) / pfrowheight
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckUp
          if pfread(playfieldColumn, rowCounter) then goto PFBlockRight
          let temp2 = temp5
          gosub DivideByPfrowheight
          rem temp2 = temp5 / pfrowheight
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckUp
          if pfread(playfieldColumn, rowCounter) then goto PFBlockRight
          
          goto PFCheckUp
          
PFBlockRight
          rem Block rightward movement: zero X velocity if positive
          if playerVelocityX[currentPlayer] > 0 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          rem Multiply (temp6 - 1) by 4 using bit shift (2 left shifts)
          let rowYPosition = temp6 - 1
          asm
            lda rowYPosition
            asl a
            asl a
            clc
            adc #ScreenInsetX
            sta rowYPosition
end
          rem Reuse rowYPosition for X position clamp (not actually Y,
          rem   but same pattern)
          if playerX[currentPlayer] > rowYPosition then let playerX[currentPlayer] = rowYPosition
          if playerX[currentPlayer] > rowYPosition then let playerSubpixelX[currentPlayer] = rowYPosition
          if playerX[currentPlayer] > rowYPosition then let playerSubpixelXL[currentPlayer] = 0
          
          rem ==========================================================
          rem CHECK UP COLLISION
          rem ==========================================================
PFCheckUp
          rem Check if player head has a playfield pixel above
          if playfieldRow = 0 then goto PFCheckDown
          rem At top of screen, skip check
          
          let rowCounter = playfieldRow - 1
          rem Row above player head (rowCounter)
          rem Check for wraparound: if playfieldRow was 0, rowCounter wraps to 255 (≥ 128)
          if rowCounter & $80 then goto PFCheckDown
          
          rem Check center column (temp6)
          if pfread(temp6, rowCounter) then goto PFBlockUp
          rem Check left edge column
          if temp6 = 0 then PFCheckUp_CheckRight
          if pfread(temp6 - 1, rowCounter) then goto PFBlockUp
PFCheckUp_CheckRight
          rem Check right edge column
          if temp6 >= 31 then goto PFCheckDown
          if pfread(temp6 + 1, rowCounter) then goto PFBlockUp
          
          goto PFCheckDown
          
PFBlockUp
          rem Block upward movement: zero Y velocity if negative
          rem   ≥ 128 are negative)
          rem Check for negative velocity using twos complement (values
          if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          rem Multiply (playfieldRow + 1) by pfrowheight (8 or 16)
          let rowYPosition = playfieldRow + 1
          rem Check if pfrowheight is 8 or 16
          if pfrowheight = 8 then goto DBPF_MultiplyBy8
          rem pfrowheight is 16, multiply by 16 (4 left shifts)
          asm
            lda rowYPosition
            asl a
            asl a
            asl a
            asl a
            sta rowYPosition
end
          goto DBPF_MultiplyDone
DBPF_MultiplyBy8
          rem pfrowheight is 8, multiply by 8 (3 left shifts)
          asm
            lda rowYPosition
            asl a
            asl a
            asl a
            sta rowYPosition
end
DBPF_MultiplyDone
          if playerY[currentPlayer] < rowYPosition then let playerY[currentPlayer] = rowYPosition
          if playerY[currentPlayer] < rowYPosition then let playerSubpixelY[currentPlayer] = rowYPosition
          if playerY[currentPlayer] < rowYPosition then let playerSubpixelYL[currentPlayer] = 0
          
          rem ==========================================================
          rem CHECK DOWN COLLISION (GROUND - already handled in gravity,
          rem   but verify)
          rem ==========================================================
PFCheckDown
          rem Check if player feet have a playfield pixel below
          rem This is primarily handled in PhysicsApplyGravity, but we
          rem   verify here
          let temp2 = temp5
          gosub DivideByPfrowheight
          let rowCounter = playfieldRow + temp2
          rem Row at player feet (rowCounter)
          if rowCounter >= pfrows then goto PFCheckDone
          
          let playfieldRow = rowCounter + 1
          rem Row below feet (playfieldRow - temporarily reuse for this
          rem   check)
          if playfieldRow >= pfrows then goto PFCheckDone
          
          rem Check center, left, and right columns below feet
          if pfread(temp6, playfieldRow) then goto PFBlockDown
          if temp6 = 0 then PFCheckDown_CheckRight
          if pfread(temp6 - 1, playfieldRow) then goto PFBlockDown
PFCheckDown_CheckRight
          if temp6 >= 31 then goto PFCheckDone
          if pfread(temp6 + 1, playfieldRow) then goto PFBlockDown
          
          goto PFCheckDone
          
PFBlockDown
          rem Block downward movement: zero Y velocity if positive
          rem This should already be handled in PhysicsApplyGravity, but
          rem   enforce here too
          if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          
PFCheckDone
          return

          rem ==========================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem ==========================================================
          rem Checks collisions between players (for pushing, not
          rem   damage).
          rem Uses weight-based momentum transfer: heavier characters
          rem   push lighter ones.
          rem Applies impulses to velocity instead of directly modifying
          rem   position.
CheckAllPlayerCollisions
          rem Loop through all player pairs to check collisions
          rem Pair (i, j) where i < j to avoid checking same pair twice
          let temp1 = 0
          rem Player 1 index
          
CollisionOuterLoop
          rem Check if player 1 is active
          if temp1 >= 2 then CollisionCheckP1Active
          rem Players 0-1 always active
          goto CollisionInnerLoop
          
CollisionCheckP1Active
          if !(controllerStatus & SetQuadtariDetected) then goto CollisionNextOuter
          if temp1 = 2 && selectedChar3_R = 255 then goto CollisionNextOuter
          if temp1 = 3 && selectedChar4_R = 255 then goto CollisionNextOuter
          
CollisionInnerLoop
          let temp2 = temp1 + 1
          rem Player 2 index (always greater than player 1)
          
CollisionCheckPair
          if temp2 >= 4 then goto CollisionNextOuter
          
          rem Check if player 2 is active
          if temp2 >= 2 then CollisionCheckP2Active
          rem Players 0-1 always active
          goto CollisionCheckDistance
          
CollisionCheckP2Active
          if !(controllerStatus & SetQuadtariDetected) then goto CollisionNextInner
          if temp2 = 2 && selectedChar3_R = 255 then goto CollisionNextInner
          if temp2 = 3 && selectedChar4_R = 255 then goto CollisionNextInner
          
CollisionCheckDistance
          rem Skip if either player is eliminated
          if playerHealth[temp1] = 0 then goto CollisionNextInner
          if playerHealth[temp2] = 0 then goto CollisionNextInner
          
          rem Calculate X distance between players
          if playerX[temp1] >= playerX[temp2] then CalcCollisionDistanceRight
          let temp3 = playerX[temp2] - playerX[temp1]
          goto CollisionDistanceDone
          
CalcCollisionDistanceRight
          let temp3 = playerX[temp1] - playerX[temp2]
          
CollisionDistanceDone
          if temp3 >= PlayerCollisionDistance then goto CollisionNextInner
          
          rem Calculate Y distance using CharacterHeights table
          let temp4 = playerChar[temp1]
          let temp5 = playerChar[temp2]
          let characterHeight = CharacterHeights[temp4]
          rem Player1 height (temporarily store in characterHeight, will
          rem   be overwritten)
          let halfHeight1 = CharacterHeights[temp5]
          rem Player2 height (temporarily store, will calculate half)
          
          rem Calculate Y distance
          if playerY[temp1] >= playerY[temp2] then CalcCollisionYDistanceDown
          let yDistance = playerY[temp2] - playerY[temp1]
          goto CollisionYDistanceDone
          
CalcCollisionYDistanceDown
          let yDistance = playerY[temp1] - playerY[temp2]
          
CollisionYDistanceDone
          rem Check if Y overlap (sum of half-heights)
          rem Calculate half-heights
          rem Divide by 2 using bit shift
          asm
            lda characterHeight
            lsr a
            sta halfHeight1
            lda CharacterHeights
            clc
            adc temp5
            tax
            lda CharacterHeights,x
            lsr a
            sta halfHeight2
end
          rem Player1 half height
          rem Player2 half height (re-read from table)
          let totalHeight = halfHeight1 + halfHeight2
          if yDistance >= totalHeight then goto CollisionNextInner
          
          rem ==========================================================
          rem MOMENTUM TRANSFER BASED ON WEIGHT
          rem ==========================================================
          rem Get character weights from CharacterWeights table
          let characterWeight = CharacterWeights[temp4]
          rem Player1 weight (temporarily store, will be overwritten)
          let halfHeight2 = CharacterWeights[temp5]
          rem Player2 weight (temporarily store)
          
          rem Calculate separation direction (left/right)
          if playerX[temp1] < playerX[temp2] then CollisionSepLeft
          
          rem Player1 is right of Player2 - push Player1 right, Player2
          rem   left
          rem Apply impulse based on weight difference
          rem Heavier character pushes lighter one more
          rem Formula: impulse = (weight_difference / total_weight) *
          rem   separation_speed
          let totalWeight = characterWeight + halfHeight2
          rem Total weight (halfHeight2 contains Player2 weight here)
          if totalWeight = 0 then goto CollisionNextInner
          rem Avoid division by zero
          
          rem Calculate weight difference
          if characterWeight >= halfHeight2 then CalcWeightDiff1Heavier
          let weightDifference = halfHeight2 - characterWeight
          rem Player2 is heavier
          let impulseStrength = weightDifference
          rem Impulse strength (proportional to weight difference)
          goto ApplyImpulseRight
          
CalcWeightDiff1Heavier
          let weightDifference = characterWeight - halfHeight2
          rem Player1 is heavier
          let impulseStrength = weightDifference
          rem Impulse strength
          
ApplyImpulseRight
          rem Apply impulses: heavier player pushes lighter one
          rem Separation speed: 1 pixel/frame minimum
          if characterWeight >= halfHeight2 then ApplyImpulse1Heavier
          
          rem Player2 is heavier - push Player1 left (negative X),
          rem   Player2 right (positive X)
          rem Impulse proportional to weight difference
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            lda impulseStrength
            asl a
            sta impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          rem   approximation
          rem totalWeight ranges 10-200, use closest power-of-2
          rem   approximation
          if totalWeight >= 128 then goto ApproxDivBy128_1
          if totalWeight >= 64 then goto ApproxDivBy64_1
          if totalWeight >= 32 then goto ApproxDivBy32_1
          rem Default: divide by 16 (approximation for 10-31)
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy32_1
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy64_1
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy128_1
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_1
          rem Scale impulse by weight ratio (0-2 pixels/frame)
          if impulseStrength = 0 then impulseStrength = 1
          rem Minimum 1 pixel/frame
          
          rem Apply to Player1 velocity (push left)
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          rem Cap at -4 pixels/frame (252 in twos complement)
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          
          rem Apply to Player2 velocity (push right)
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          rem Cap at 4 pixels/frame
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          
          rem Also zero subpixel velocities when applying impulse
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          
          goto CollisionNextInner
          
ApplyImpulse1Heavier
          rem Player1 is heavier - push Player1 right (positive X),
          rem   Player2 left (negative X)
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            lda impulseStrength
            asl a
            sta impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          rem   approximation
          if totalWeight >= 128 then goto ApproxDivBy128_2
          if totalWeight >= 64 then goto ApproxDivBy64_2
          if totalWeight >= 32 then goto ApproxDivBy32_2
          rem Default: divide by 16
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy32_2
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy64_2
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy128_2
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_2
          rem Scale impulse by weight ratio
          if impulseStrength = 0 then impulseStrength = 1
          
          rem Apply to Player1 velocity (push right)
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          
          rem Apply to Player2 velocity (push left)
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          rem Cap at -4 pixels/frame (252 in twos complement)
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          
          goto CollisionNextInner
          
CollisionSepLeft
          rem Player1 is left of Player2 - push Player1 left, Player2
          rem   right
          rem Same logic but reversed directions
          rem Re-read weights (characterWeight and halfHeight2 were used
          rem   for heights)
          let characterWeight = CharacterWeights[temp4]
          rem Player1 weight
          let halfHeight2 = CharacterWeights[temp5]
          rem Player2 weight
          let totalWeight = characterWeight + halfHeight2
          if totalWeight = 0 then goto CollisionNextInner
          
          if characterWeight >= halfHeight2 then CalcWeightDiff1HeavierLeft
          let weightDifference = halfHeight2 - characterWeight
          let impulseStrength = weightDifference
          goto ApplyImpulseLeft
          
CalcWeightDiff1HeavierLeft
          let weightDifference = characterWeight - halfHeight2
          let impulseStrength = weightDifference
          
ApplyImpulseLeft
          if characterWeight >= halfHeight2 then ApplyImpulse1HeavierLeft
          
          rem Player2 is heavier - push Player1 left, Player2 right
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            lda impulseStrength
            asl a
            sta impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          rem   approximation
          if totalWeight >= 128 then goto ApproxDivBy128_3
          if totalWeight >= 64 then goto ApproxDivBy64_3
          if totalWeight >= 32 then goto ApproxDivBy32_3
          rem Default: divide by 16
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy32_3
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy64_3
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy128_3
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_3
          if impulseStrength = 0 then impulseStrength = 1
          
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          rem Cap at -4 pixels/frame (252 in twos complement)
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          
          goto CollisionNextInner
          
ApplyImpulse1HeavierLeft
          rem Player1 is heavier - push Player1 right, Player2 left
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            asl impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          rem   approximation
          rem totalWeight ranges 10-200, use closest power-of-2
          rem   approximation
          if totalWeight >= 128 then goto ApproxDivBy128_1Heavier
          if totalWeight >= 64 then goto ApproxDivBy64_1Heavier
          if totalWeight >= 32 then goto ApproxDivBy32_1Heavier
          if totalWeight >= 16 then goto ApproxDivBy16_1Heavier
          if totalWeight >= 8 then goto ApproxDivBy8_1Heavier
          goto ApproxDivDone_1Heavier
ApproxDivBy128_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy64_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy32_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy16_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy8_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_1Heavier
          if impulseStrength = 0 then impulseStrength = 1
          
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          rem Cap at -4 pixels/frame (252 in twos complement)
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          
CollisionNextInner
          let temp2 = temp2 + 1
          goto CollisionCheckPair
          
CollisionNextOuter
          let temp1 = temp1 + 1
          if temp1 < 3 then goto CollisionOuterLoop
          rem Only check pairs where i < j, so i only goes up to 2 (to
          rem   check pair with j=3)
          
          return

