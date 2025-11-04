          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem PLAYER PHYSICS
          rem =================================================================
          rem Handles gravity, momentum, collisions, and recovery for all players.

          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem   playerVelocityX[0-3] - Horizontal velocity (8.8 fixed-point)
          rem   playerVelocityY[0-3] - Vertical velocity (8.8 fixed-point)
          rem   playerRecoveryFrames[0-3] - Recovery (hitstun) frames remaining
          rem   QuadtariDetected - Whether 4-player mode active
          rem   selectedChar3, selectedChar4 - Player 3/4 selections
          rem   playerChar[0-3] - Character type indices
          rem =================================================================

          rem =================================================================
          rem APPLY GRAVITY
          rem =================================================================
          rem Applies gravity acceleration to jumping players.
          rem Certain characters (Frooty=8, Dragon of Storms=2) are not affected by gravity.
          rem Players land when they are atop a playfield pixel (ground detection).
          rem Gravity accelerates downward using tunable constants (Constants.bas):
          rem   GravityNormal (0.1px/frame²), GravityReduced (0.05px/frame²), TerminalVelocity (8px/frame)
PhysicsApplyGravity
          rem Loop through all players (0-3)
          let temp1 = 0
GravityLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need Quadtari)
          if temp1 < 2 then GravityCheckCharacter
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto GravityNextPlayer
          if temp1 = 2 && selectedChar3 = 255 then goto GravityNextPlayer
          if temp1 = 3 && selectedChar4 = 255 then goto GravityNextPlayer
          
GravityCheckCharacter
          rem Get character type
          let temp6 = playerChar[temp1]
          
          rem Skip gravity for characters that don't have it
          rem Frooty (8): Permanent flight, no gravity
          if temp6 = CharFrooty then goto GravityNextPlayer
          rem Dragon of Storms (2): Permanent flight, no gravity (hovering/flying like Frooty)
          if temp6 = CharDragonOfStorms then goto GravityNextPlayer
          
          rem Check if player is in jumping state (bit 2 set means jumping, skip gravity)
          rem If NOT jumping, skip gravity (player is on ground)
          if !(playerState[temp1] & 4) then goto GravityNextPlayer
          
          rem Initialize or get vertical velocity (using temp variable)
          rem Note: Vertical velocity is not persistent - we'll track it per-frame
          rem For now, we'll apply gravity acceleration directly to position
          rem TODO: Consider implementing persistent vertical velocity tracking
          
          rem Determine gravity acceleration rate based on character (8.8 fixed-point subpixel)
          rem Uses tunable constants from Constants.bas for easy adjustment
          let gravityRate = GravityNormal
          rem Default gravity acceleration (normal rate)
          if temp6 = CharHarpy then let gravityRate = GravityReduced
          rem Harpy: reduced gravity rate
          
          rem Apply gravity acceleration to velocity subpixel part (adds to Y velocity, positive = downward)
          rem temp1 already set (player index), gravityRate is gravity strength in subpixel (low byte)
          rem AddVelocitySubpixelY expects temp2, so save temp2 and use it for gravityRate
          let playfieldColumn = temp2
          rem Save temp2 temporarily
          let temp2 = gravityRate
          gosub AddVelocitySubpixelY
          let temp2 = playfieldColumn
          rem Restore temp2
          
          rem Apply terminal velocity cap (prevents infinite acceleration)
          rem Check if velocity exceeds terminal velocity (positive = downward)
          if playerVelocityY[temp1] > TerminalVelocity then let playerVelocityY[temp1] = TerminalVelocity : let playerVelocityY_lo[temp1] = 0
          
          rem Check playfield collision for ground detection (downward)
          rem Convert player X position to playfield column (0-31)
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem Clamp column to valid range
          if temp2 > 31 then let temp2 = 31
          if temp2 < 0 then let temp2 = 0
          
          rem Calculate row where player’s feet are (bottom of sprite)
          rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let temp3 = playerY[temp1] + PlayerSpriteHeight
          let temp4 = temp3 / pfrowheight
          rem temp4 = row where feet are
          
          rem Check if there’s a playfield pixel in the row below the feet
          rem If feet are in row N, check row N+1 for ground
          if temp4 >= pfrows then goto GravityNextPlayer
          rem Feet are at or below bottom of playfield, continue falling
          
          let temp5 = temp4 + 1
          rem temp5 = row below feet
          if temp5 >= pfrows then goto GravityCheckBottom
          rem Beyond playfield bounds, check if at bottom
          
          rem Check if playfield pixel exists in row below feet
          if !pfread(temp2, temp5) then goto GravityNextPlayer
          rem No ground pixel found, continue falling
          
          rem Ground detected! Stop falling and clamp position to ground
          rem Zero Y velocity (stop falling)
          let playerVelocityY[temp1] = 0
          let playerVelocityY_lo[temp1] = 0
          
          rem Calculate Y position for top of ground row using repeated addition
          rem Loop to add pfrowheight to rowYPosition, temp5 times
          let rowYPosition = 0
          let rowCounter = temp5
          if rowCounter = 0 then goto GravityRowCalcDone
GravityRowCalcLoop
          let rowYPosition = rowYPosition + pfrowheight
          let rowCounter = rowCounter - 1
          if rowCounter > 0 then goto GravityRowCalcLoop
GravityRowCalcDone
          rem rowYPosition now contains temp5 * pfrowheight (Y position of top of ground row)
          rem Clamp playerY so feet are at top of ground row
          let playerY[temp1] = rowYPosition - PlayerSpriteHeight
          rem Also sync subpixel position
          let playerSubpixelY[temp1] = playerY[temp1]
          let playerSubpixelY_lo[temp1] = 0
          
          rem Clear jumping flag (bit 2, not bit 4 - fix bit number)
          let playerState[temp1] = playerState[temp1] & 251
          rem Clear bit 2 (jumping flag)
          goto GravityNextPlayer
          
GravityCheckBottom
          rem At bottom of playfield - treat as ground if feet are at bottom row
          if temp4 < pfrows - 1 then goto GravityNextPlayer
          rem Not at bottom row yet
          
          rem Bottom row is always ground - clamp to bottom
          rem Calculate (pfrows - 1) * pfrowheight using repeated addition
          let rowYPosition = 0
          let rowCounter = pfrows - 1
          if rowCounter = 0 then goto GravityBottomCalcDone
GravityBottomCalcLoop
          let rowYPosition = rowYPosition + pfrowheight
          let rowCounter = rowCounter - 1
          if rowCounter > 0 then goto GravityBottomCalcLoop
GravityBottomCalcDone
          let playerY[temp1] = rowYPosition - PlayerSpriteHeight
          let playerState[temp1] = playerState[temp1] & NOT 4
          
GravityNextPlayer
          rem Move to next player
          let temp1 = temp1 + 1
          if temp1 < 4 then goto GravityLoop
          
          return

          rem =================================================================
          rem APPLY MOMENTUM AND RECOVERY
          rem =================================================================
          rem Updates recovery frames and applies velocity during hitstun.
          rem Velocity gradually decays over time.
          rem Refactored to loop through all players (0-3)
ApplyMomentumAndRecovery
          rem Loop through all players (0-3)
          let temp1 = 0
MomentumRecoveryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need Quadtari)
          if temp1 < 2 then MomentumRecoveryProcess
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto MomentumRecoveryNext
          if temp1 = 2 && selectedChar3 = 255 then goto MomentumRecoveryNext
          if temp1 = 3 && selectedChar4 = 255 then goto MomentumRecoveryNext
          
MomentumRecoveryProcess
          rem Decrement recovery frames (velocity is applied by UpdatePlayerMovement)
          if playerRecoveryFrames[temp1] > 0 then let playerRecoveryFrames[temp1] = playerRecoveryFrames[temp1] - 1
          
          rem Synchronize playerState bit 3 with recovery frames
          if playerRecoveryFrames[temp1] > 0 then let playerState[temp1] = playerState[temp1] | 8
          rem Set bit 3 (recovery flag) when recovery frames > 0
          if ! playerRecoveryFrames[temp1] then let playerState[temp1] = playerState[temp1] & 247
          rem Clear bit 3 (recovery flag) when recovery frames = 0
          
          rem Decay velocity if recovery frames active
          if ! playerRecoveryFrames[temp1] then goto MomentumRecoveryNext
          rem Velocity decay during recovery (knockback slows down over time)
          if playerVelocityX[temp1] <= 0 then MomentumRecoveryDecayNegative
          rem Positive velocity: decay by 1
          let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[temp1] = 0 then let playerVelocityX_lo[temp1] = 0
          goto MomentumRecoveryNext
MomentumRecoveryDecayNegative
          if playerVelocityX[temp1] >= 0 then goto MomentumRecoveryNext
          rem Negative velocity: decay by 1 (add 1 to make less negative)
          let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[temp1] = 0 then let playerVelocityX_lo[temp1] = 0
          
MomentumRecoveryNext
          rem Next player
          let temp1 = temp1 + 1
          if temp1 < 4 then goto MomentumRecoveryLoop
          
          return

          rem =================================================================
          rem CHECK BOUNDARY COLLISIONS
          rem =================================================================
          rem Prevents players from moving off-screen.
CheckBoundaryCollisions
          rem Loop through all players (0-3)
          let temp1 = 0
BoundaryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need Quadtari)
          if temp1 < 2 then BoundaryCheckBounds
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto BoundaryNextPlayer
          if temp1 = 2 && selectedChar3 = 255 then goto BoundaryNextPlayer
          if temp1 = 3 && selectedChar4 = 255 then goto BoundaryNextPlayer
          
BoundaryCheckBounds
          rem Bernie (0) - screen wrap: falling off bottom respawns at top
          temp2 = playerChar[temp1]
          if temp2 = 0 then BoundaryBernieWrap
          
          rem Other characters - clamp to screen boundaries
          rem Clamp X position to screen boundaries (10-150)
          if playerX[temp1] < 10 then let playerX[temp1] = 10 : let playerSubpixelX[temp1] = 10 : let playerSubpixelX_lo[temp1] = 0 : let playerVelocityX[temp1] = 0 : let playerVelocityX_lo[temp1] = 0
          if playerX[temp1] > 150 then let playerX[temp1] = 150 : let playerSubpixelX[temp1] = 150 : let playerSubpixelX_lo[temp1] = 0 : let playerVelocityX[temp1] = 0 : let playerVelocityX_lo[temp1] = 0
          
          rem Clamp Y position to screen boundaries (20-80)
          rem Bernie can fall off bottom and wrap, so skip Y clamp for Bernie
          if playerY[temp1] < 20 then let playerY[temp1] = 20 : let playerSubpixelY[temp1] = 20 : let playerSubpixelY_lo[temp1] = 0 : let playerVelocityY[temp1] = 0 : let playerVelocityY_lo[temp1] = 0
          if playerY[temp1] > 80 then let playerY[temp1] = 80 : let playerSubpixelY[temp1] = 80 : let playerSubpixelY_lo[temp1] = 0 : let playerVelocityY[temp1] = 0 : let playerVelocityY_lo[temp1] = 0
          goto BoundaryNextPlayer
          
BoundaryBernieWrap
          rem Bernie wraps horizontally and vertically
          rem Horizontal wrap: X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[temp1] < 10 then let playerX[temp1] = 150 : let playerSubpixelX[temp1] = 150 : let playerSubpixelX_lo[temp1] = 0
          if playerX[temp1] > 150 then let playerX[temp1] = 10 : let playerSubpixelX[temp1] = 10 : let playerSubpixelX_lo[temp1] = 0
          
          rem Vertical wrap: falling off bottom (Y > 80) respawns at top (Y = 20)
          if playerY[temp1] > 80 then let playerY[temp1] = 20 : let playerSubpixelY[temp1] = 20 : let playerSubpixelY_lo[temp1] = 0 : let playerVelocityY[temp1] = 0 : let playerVelocityY_lo[temp1] = 0
          
          rem Top boundary: still clamp to prevent going above screen
          if playerY[temp1] < 20 then let playerY[temp1] = 20 : let playerSubpixelY[temp1] = 20 : let playerSubpixelY_lo[temp1] = 0 : let playerVelocityY[temp1] = 0 : let playerVelocityY_lo[temp1] = 0

BoundaryNextPlayer
          rem Move to next player
          let temp1 = temp1 + 1
          if temp1 < 4 then goto BoundaryLoop
          
          return

          rem =================================================================
          rem CHECK PLAYFIELD COLLISION ALL DIRECTIONS
          rem =================================================================
          rem Checks for playfield pixel collisions in all four directions and
          rem blocks movement by zeroing velocity in the collision direction.
          rem Uses CharacterHeights table for proper hitbox detection.
          rem
          rem INPUT: temp1 = player index (0-3)
          rem MODIFIES: playerVelocityX/Y and playerSubpixelX/Y when collisions detected
CheckPlayfieldCollisionAllDirections
          dim CPF_playerIndex = temp1
          rem Get player position and character info
          let temp2 = playerX[CPF_playerIndex]
          rem X position (save original)
          let temp3 = playerY[CPF_playerIndex]
          rem Y position
          let temp4 = playerChar[CPF_playerIndex]
          rem Character index
          let temp5 = CharacterHeights[temp4]
          rem Character height
          
          rem Convert X position to playfield column (0-31)
          let temp6 = temp2
          rem Save original X in temp6
          let temp6 = temp6 - ScreenInsetX
          let temp6 = temp6 / 4
          rem temp6 = playfield column (0-31)
          rem Clamp column to valid range
          if temp6 > 31 then let temp6 = 31
          if temp6 < 0 then let temp6 = 0
          
          rem Convert Y position to playfield row (0-pfrows-1)
          let playfieldRow = temp3 / pfrowheight
          rem playfieldRow = playfield row
          if playfieldRow >= pfrows then let playfieldRow = pfrows - 1
          if playfieldRow < 0 then let playfieldRow = 0
          
          rem =================================================================
          rem CHECK LEFT COLLISION
          rem =================================================================
          rem Check if player’s left edge (temp6 column) has a playfield pixel
          rem Check at player’s head, middle, and feet positions
          if temp6 <= 0 then PFCheckRight
          rem At left edge of screen, skip check
          
          let playfieldColumn = temp6 - 1
          rem Column to the left (playfieldColumn)
          if playfieldColumn < 0 then PFCheckRight
          rem Out of bounds, skip
          
          rem Check head position (top of sprite)
          if pfread(playfieldColumn, playfieldRow) then PFBlockLeft
          rem Check middle position
          let rowCounter = playfieldRow + (temp5 / 2) / pfrowheight
          if rowCounter >= pfrows then PFCheckRight
          if pfread(playfieldColumn, rowCounter) then PFBlockLeft
          rem Check feet position (bottom of sprite)
          let rowCounter = playfieldRow + temp5 / pfrowheight
          if rowCounter >= pfrows then PFCheckRight
          if pfread(playfieldColumn, rowCounter) then PFBlockLeft
          
          goto PFCheckRight
          
PFBlockLeft
          rem Block leftward movement: zero X velocity if negative
          if playerVelocityX[CPF_playerIndex] < 0 then let playerVelocityX[CPF_playerIndex] = 0 : let playerVelocityX_lo[CPF_playerIndex] = 0
          rem Also clamp position to prevent overlap
          let rowYPosition = (temp6 + 1) * 4 + ScreenInsetX
          rem Reuse rowYPosition for X position clamp (not actually Y, but same pattern)
          if playerX[CPF_playerIndex] < rowYPosition then let playerX[CPF_playerIndex] = rowYPosition : let playerSubpixelX[CPF_playerIndex] = rowYPosition : let playerSubpixelX_lo[CPF_playerIndex] = 0
          
          rem =================================================================
          rem CHECK RIGHT COLLISION
          rem =================================================================
PFCheckRight
          rem Check if player’s right edge has a playfield pixel
          rem Player width is 16 pixels (double-width NUSIZ), so right edge is at temp6 + 4 columns (16px / 4px per column = 4)
          if temp6 >= 31 then PFCheckUp
          rem At right edge of screen, skip check
          
          let playfieldColumn = temp6 + 4
          rem Column to the right of player's right edge (playfieldColumn)
          if playfieldColumn > 31 then PFCheckUp
          rem Out of bounds, skip
          
          rem Check head, middle, and feet positions
          if pfread(playfieldColumn, playfieldRow) then PFBlockRight
          let rowCounter = playfieldRow + (temp5 / 2) / pfrowheight
          if rowCounter >= pfrows then PFCheckUp
          if pfread(playfieldColumn, rowCounter) then PFBlockRight
          let rowCounter = playfieldRow + temp5 / pfrowheight
          if rowCounter >= pfrows then PFCheckUp
          if pfread(playfieldColumn, rowCounter) then PFBlockRight
          
          goto PFCheckUp
          
PFBlockRight
          rem Block rightward movement: zero X velocity if positive
          if playerVelocityX[CPF_playerIndex] > 0 then let playerVelocityX[CPF_playerIndex] = 0 : let playerVelocityX_lo[CPF_playerIndex] = 0
          rem Also clamp position to prevent overlap
          let rowYPosition = (temp6 - 1) * 4 + ScreenInsetX
          rem Reuse rowYPosition for X position clamp (not actually Y, but same pattern)
          if playerX[CPF_playerIndex] > rowYPosition then let playerX[CPF_playerIndex] = rowYPosition : let playerSubpixelX[CPF_playerIndex] = rowYPosition : let playerSubpixelX_lo[CPF_playerIndex] = 0
          
          rem =================================================================
          rem CHECK UP COLLISION
          rem =================================================================
PFCheckUp
          rem Check if player's head has a playfield pixel above
          if playfieldRow <= 0 then PFCheckDown
          rem At top of screen, skip check
          
          let rowCounter = playfieldRow - 1
          rem Row above player's head (rowCounter)
          if rowCounter < 0 then PFCheckDown
          
          rem Check center column (temp6)
          if pfread(temp6, rowCounter) then PFBlockUp
          rem Check left edge column
          if temp6 > 0 then if pfread(temp6 - 1, rowCounter) then PFBlockUp
          rem Check right edge column
          if temp6 < 31 then if pfread(temp6 + 1, rowCounter) then PFBlockUp
          
          goto PFCheckDown
          
PFBlockUp
          rem Block upward movement: zero Y velocity if negative
          if playerVelocityY[CPF_playerIndex] < 0 then let playerVelocityY[CPF_playerIndex] = 0 : let playerVelocityY_lo[CPF_playerIndex] = 0
          rem Also clamp position to prevent overlap
          let rowYPosition = (playfieldRow + 1) * pfrowheight
          if playerY[CPF_playerIndex] < rowYPosition then let playerY[CPF_playerIndex] = rowYPosition : let playerSubpixelY[CPF_playerIndex] = rowYPosition : let playerSubpixelY_lo[CPF_playerIndex] = 0
          
          rem =================================================================
          rem CHECK DOWN COLLISION (GROUND - already handled in gravity, but verify)
          rem =================================================================
PFCheckDown
          rem Check if player's feet have a playfield pixel below
          rem This is primarily handled in PhysicsApplyGravity, but we verify here
          let rowCounter = playfieldRow + temp5 / pfrowheight
          rem Row at player's feet (rowCounter)
          if rowCounter >= pfrows then PFCheckDone
          
          let playfieldRow = rowCounter + 1
          rem Row below feet (playfieldRow - temporarily reuse for this check)
          if playfieldRow >= pfrows then PFCheckDone
          
          rem Check center, left, and right columns below feet
          if pfread(temp6, playfieldRow) then PFBlockDown
          if temp6 > 0 then if pfread(temp6 - 1, playfieldRow) then PFBlockDown
          if temp6 < 31 then if pfread(temp6 + 1, playfieldRow) then PFBlockDown
          
          goto PFCheckDone
          
PFBlockDown
          rem Block downward movement: zero Y velocity if positive
          rem This should already be handled in PhysicsApplyGravity, but enforce here too
          if playerVelocityY[CPF_playerIndex] > 0 then let playerVelocityY[CPF_playerIndex] = 0 : let playerVelocityY_lo[CPF_playerIndex] = 0
          
PFCheckDone
          return

          rem =================================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem =================================================================
          rem Checks collisions between players (for pushing, not damage).
          rem Uses weight-based momentum transfer: heavier characters push lighter ones.
          rem Applies impulses to velocity instead of directly modifying position.
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
          if temp1 = 2 && selectedChar3 = 255 then goto CollisionNextOuter
          if temp1 = 3 && selectedChar4 = 255 then goto CollisionNextOuter
          
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
          if temp2 = 2 && selectedChar3 = 255 then goto CollisionNextInner
          if temp2 = 3 && selectedChar4 = 255 then goto CollisionNextInner
          
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
          rem Check if players are within collision distance (16 pixels = double-width sprite)
          if temp3 >= 16 then goto CollisionNextInner
          
          rem Calculate Y distance using CharacterHeights table
          let temp4 = playerChar[temp1]
          let temp5 = playerChar[temp2]
          let characterHeight = CharacterHeights[temp4]
          rem Player1 height (temporarily store in characterHeight, will be overwritten)
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
          let halfHeight1 = characterHeight / 2
          rem Player1 half height
          let halfHeight2 = CharacterHeights[temp5] / 2
          rem Player2 half height (re-read from table)
          let totalHeight = halfHeight1 + halfHeight2
          if yDistance >= totalHeight then goto CollisionNextInner
          
          rem =================================================================
          rem MOMENTUM TRANSFER BASED ON WEIGHT
          rem =================================================================
          rem Get character weights from CharacterWeights table
          let characterWeight = CharacterWeights[temp4]
          rem Player1 weight (temporarily store, will be overwritten)
          let halfHeight2 = CharacterWeights[temp5]
          rem Player2 weight (temporarily store)
          
          rem Calculate separation direction (left/right)
          if playerX[temp1] < playerX[temp2] then CollisionSepLeft
          
          rem Player1 is right of Player2 - push Player1 right, Player2 left
          rem Apply impulse based on weight difference
          rem Heavier character pushes lighter one more
          rem Formula: impulse = (weight_difference / total_weight) * separation_speed
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
          
          rem Player2 is heavier - push Player1 left (negative X), Player2 right (positive X)
          rem Impulse proportional to weight difference
          let impulseStrength = impulseStrength * 2 / totalWeight
          rem Scale impulse by weight ratio (0-2 pixels/frame)
          if impulseStrength = 0 then impulseStrength = 1
          rem Minimum 1 pixel/frame
          
          rem Apply to Player1 velocity (push left)
          if playerVelocityX[temp1] > -4 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          rem Cap at -4 pixels/frame
          if playerVelocityX[temp1] < -4 then let playerVelocityX[temp1] = -4
          
          rem Apply to Player2 velocity (push right)
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          rem Cap at 4 pixels/frame
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          
          rem Also zero subpixel velocities when applying impulse
          let playerVelocityX_lo[temp1] = 0
          let playerVelocityX_lo[temp2] = 0
          
          goto CollisionNextInner
          
ApplyImpulse1Heavier
          rem Player1 is heavier - push Player1 right (positive X), Player2 left (negative X)
          let impulseStrength = impulseStrength * 2 / totalWeight
          rem Scale impulse by weight ratio
          if impulseStrength = 0 then impulseStrength = 1
          
          rem Apply to Player1 velocity (push right)
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          
          rem Apply to Player2 velocity (push left)
          if playerVelocityX[temp2] > -4 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          if playerVelocityX[temp2] < -4 then let playerVelocityX[temp2] = -4
          
          let playerVelocityX_lo[temp1] = 0
          let playerVelocityX_lo[temp2] = 0
          
          goto CollisionNextInner
          
CollisionSepLeft
          rem Player1 is left of Player2 - push Player1 left, Player2 right
          rem Same logic but reversed directions
          rem Re-read weights (characterWeight and halfHeight2 were used for heights)
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
          let impulseStrength = impulseStrength * 2 / totalWeight
          if impulseStrength = 0 then impulseStrength = 1
          
          if playerVelocityX[temp1] > -4 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          if playerVelocityX[temp1] < -4 then let playerVelocityX[temp1] = -4
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          
          let playerVelocityX_lo[temp1] = 0
          let playerVelocityX_lo[temp2] = 0
          
          goto CollisionNextInner
          
ApplyImpulse1HeavierLeft
          rem Player1 is heavier - push Player1 right, Player2 left
          let impulseStrength = impulseStrength * 2 / totalWeight
          if impulseStrength = 0 then impulseStrength = 1
          
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          if playerVelocityX[temp2] > -4 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          if playerVelocityX[temp2] < -4 then let playerVelocityX[temp2] = -4
          
          let playerVelocityX_lo[temp1] = 0
          let playerVelocityX_lo[temp2] = 0
          
CollisionNextInner
          let temp2 = temp2 + 1
          goto CollisionCheckPair
          
CollisionNextOuter
          let temp1 = temp1 + 1
          if temp1 < 3 then goto CollisionOuterLoop
          rem Only check pairs where i < j, so i only goes up to 2 (to check pair with j=3)
          
          return

