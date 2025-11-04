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
          if temp6 = 8 then goto GravityNextPlayer
          rem Dragon of Storms (2): Permanent flight, no gravity (handled below)
          
          rem Check if player is in jumping state (bit 2 set means jumping, skip gravity)
          rem If NOT jumping, skip gravity (player is on ground)
          if !(playerState[temp1] & 4) then goto GravityNextPlayer
          
          rem Initialize or get vertical velocity (using temp variable)
          rem Note: Vertical velocity is not persistent - we'll track it per-frame
          rem For now, we'll apply gravity acceleration directly to position
          rem TODO: Consider implementing persistent vertical velocity tracking
          
          rem Skip gravity for Dragon of Storms (2): Permanent flight, no gravity
          if temp6 = 2 then goto GravityNextPlayer
          
          rem Determine gravity acceleration rate based on character (8.8 fixed-point subpixel)
          rem Uses tunable constants from Constants.bas for easy adjustment
          let temp7 = GravityNormal
          rem Default gravity acceleration (normal rate)
          if temp6 = 6 then let temp7 = GravityReduced
          rem Harpy: reduced gravity rate
          
          rem Apply gravity acceleration to velocity subpixel part (adds to Y velocity, positive = downward)
          rem temp1 already set (player index), temp7 is gravity strength in subpixel (low byte)
          gosub AddVelocitySubpixelY
          
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
          
          rem Calculate row where player's feet are (bottom of sprite)
          rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let temp3 = playerY[temp1] + PlayerSpriteHeight
          let temp4 = temp3 / pfrowheight
          rem temp4 = row where feet are
          
          rem Check if there's a playfield pixel in the row below the feet
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
          rem Loop to add pfrowheight to temp8, temp5 times
          let temp8 = 0
          let temp9 = temp5
          if temp9 = 0 then goto GravityRowCalcDone
GravityRowCalcLoop
          let temp8 = temp8 + pfrowheight
          let temp9 = temp9 - 1
          if temp9 > 0 then goto GravityRowCalcLoop
GravityRowCalcDone
          rem temp8 now contains temp5 * pfrowheight (Y position of top of ground row)
          rem Clamp playerY so feet are at top of ground row
          let playerY[temp1] = temp8 - PlayerSpriteHeight
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
          let temp8 = 0
          let temp9 = pfrows - 1
          if temp9 = 0 then goto GravityBottomCalcDone
GravityBottomCalcLoop
          let temp8 = temp8 + pfrowheight
          let temp9 = temp9 - 1
          if temp9 > 0 then goto GravityBottomCalcLoop
GravityBottomCalcDone
          let playerY[temp1] = temp8 - PlayerSpriteHeight
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
          rem Get player position and character info
          let temp2 = playerX[temp1]
          rem X position (save original)
          let temp3 = playerY[temp1]
          rem Y position
          let temp4 = playerChar[temp1]
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
          let temp7 = temp3 / pfrowheight
          rem temp7 = playfield row
          if temp7 >= pfrows then let temp7 = pfrows - 1
          if temp7 < 0 then let temp7 = 0
          
          rem =================================================================
          rem CHECK LEFT COLLISION
          rem =================================================================
          rem Check if player's left edge (temp6 column) has a playfield pixel
          rem Check at player's head, middle, and feet positions
          if temp6 <= 0 then PFCheckRight
          rem At left edge of screen, skip check
          
          let temp8 = temp6 - 1
          rem Column to the left (temp8)
          if temp8 < 0 then PFCheckRight
          rem Out of bounds, skip
          
          rem Check head position (top of sprite)
          if pfread(temp8, temp7) then PFBlockLeft
          rem Check middle position
          let temp9 = temp7 + (temp5 / 2) / pfrowheight
          if temp9 >= pfrows then PFCheckRight
          if pfread(temp8, temp9) then PFBlockLeft
          rem Check feet position (bottom of sprite)
          let temp9 = temp7 + temp5 / pfrowheight
          if temp9 >= pfrows then PFCheckRight
          if pfread(temp8, temp9) then PFBlockLeft
          
          goto PFCheckRight
          
PFBlockLeft
          rem Block leftward movement: zero X velocity if negative
          if playerVelocityX[temp1] < 0 then let playerVelocityX[temp1] = 0 : let playerVelocityX_lo[temp1] = 0
          rem Also clamp position to prevent overlap
          let temp8 = (temp6 + 1) * 4 + ScreenInsetX
          if playerX[temp1] < temp8 then let playerX[temp1] = temp8 : let playerSubpixelX[temp1] = temp8 : let playerSubpixelX_lo[temp1] = 0
          
          rem =================================================================
          rem CHECK RIGHT COLLISION
          rem =================================================================
PFCheckRight
          rem Check if player's right edge has a playfield pixel
          rem Player width is 16 pixels (double-width NUSIZ), so right edge is at temp6 + 4 columns (16px / 4px per column = 4)
          if temp6 >= 31 then PFCheckUp
          rem At right edge of screen, skip check
          
          let temp8 = temp6 + 4
          rem Column to the right of player's right edge (temp8)
          if temp8 > 31 then PFCheckUp
          rem Out of bounds, skip
          
          rem Check head, middle, and feet positions
          if pfread(temp8, temp7) then PFBlockRight
          let temp9 = temp7 + (temp5 / 2) / pfrowheight
          if temp9 >= pfrows then PFCheckUp
          if pfread(temp8, temp9) then PFBlockRight
          let temp9 = temp7 + temp5 / pfrowheight
          if temp9 >= pfrows then PFCheckUp
          if pfread(temp8, temp9) then PFBlockRight
          
          goto PFCheckUp
          
PFBlockRight
          rem Block rightward movement: zero X velocity if positive
          if playerVelocityX[temp1] > 0 then let playerVelocityX[temp1] = 0 : let playerVelocityX_lo[temp1] = 0
          rem Also clamp position to prevent overlap
          let temp8 = (temp6 - 1) * 4 + ScreenInsetX
          if playerX[temp1] > temp8 then let playerX[temp1] = temp8 : let playerSubpixelX[temp1] = temp8 : let playerSubpixelX_lo[temp1] = 0
          
          rem =================================================================
          rem CHECK UP COLLISION
          rem =================================================================
PFCheckUp
          rem Check if player's head has a playfield pixel above
          if temp7 <= 0 then PFCheckDown
          rem At top of screen, skip check
          
          let temp8 = temp7 - 1
          rem Row above player's head (temp8)
          if temp8 < 0 then PFCheckDown
          
          rem Check center column (temp6)
          if pfread(temp6, temp8) then PFBlockUp
          rem Check left edge column
          if temp6 > 0 then if pfread(temp6 - 1, temp8) then PFBlockUp
          rem Check right edge column
          if temp6 < 31 then if pfread(temp6 + 1, temp8) then PFBlockUp
          
          goto PFCheckDown
          
PFBlockUp
          rem Block upward movement: zero Y velocity if negative
          if playerVelocityY[temp1] < 0 then let playerVelocityY[temp1] = 0 : let playerVelocityY_lo[temp1] = 0
          rem Also clamp position to prevent overlap
          let temp8 = (temp7 + 1) * pfrowheight
          if playerY[temp1] < temp8 then let playerY[temp1] = temp8 : let playerSubpixelY[temp1] = temp8 : let playerSubpixelY_lo[temp1] = 0
          
          rem =================================================================
          rem CHECK DOWN COLLISION (GROUND - already handled in gravity, but verify)
          rem =================================================================
PFCheckDown
          rem Check if player's feet have a playfield pixel below
          rem This is primarily handled in PhysicsApplyGravity, but we verify here
          let temp8 = temp7 + temp5 / pfrowheight
          rem Row at player's feet (temp8)
          if temp8 >= pfrows then PFCheckDone
          
          let temp9 = temp8 + 1
          rem Row below feet (temp9)
          if temp9 >= pfrows then PFCheckDone
          
          rem Check center, left, and right columns below feet
          if pfread(temp6, temp9) then PFBlockDown
          if temp6 > 0 then if pfread(temp6 - 1, temp9) then PFBlockDown
          if temp6 < 31 then if pfread(temp6 + 1, temp9) then PFBlockDown
          
          goto PFCheckDone
          
PFBlockDown
          rem Block downward movement: zero Y velocity if positive
          rem This should already be handled in PhysicsApplyGravity, but enforce here too
          if playerVelocityY[temp1] > 0 then let playerVelocityY[temp1] = 0 : let playerVelocityY_lo[temp1] = 0
          
PFCheckDone
          return

          rem =================================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem =================================================================
          rem Checks collisions between players (for pushing, not damage).
          rem Players can walk through each other but are slightly pushed apart.
CheckAllPlayerCollisions
          rem Check Player 1 vs Player 2
          if playerX[0] >= playerX[1] then goto CalcP1P2DistanceRight
          temp2 = playerX[1] - playerX[0]
          goto P1P2DistanceDone
CalcP1P2DistanceRight
          temp2 = playerX[0] - playerX[1]
P1P2DistanceDone
          if temp2 < 16 then if playerX[0] < playerX[1] then playerX[0] = playerX[0] - 1 : playerX[1] = playerX[1] + 1 : goto SkipP1P2Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[1] = playerX[1] - 1
SkipP1P2Sep
          
          
          
          rem Check other player combinations if Quadtari active
          if ! (controllerStatus & SetQuadtariDetected) then return
          
          rem Check Player 1 vs Player 3
          if selectedChar3 = 255 then goto SkipP1P3Check
DoP1P3Check
          if playerX[0] >= playerX[2] then goto CalcP1P3DistanceRight
          temp2 = playerX[2] - playerX[0]
          goto P1P3DistanceDone
CalcP1P3DistanceRight
          temp2 = playerX[0] - playerX[2]
P1P3DistanceDone
          if temp2 < 16 then if playerX[0] < playerX[2] then playerX[0] = playerX[0] - 1 : playerX[2] = playerX[2] + 1 : goto SkipP1P3Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[2] = playerX[2] - 1
SkipP1P3Sep
SkipP1P3Check
          
          
          
          
          rem Check Player 1 vs Player 4
          if selectedChar4 = 255 then goto SkipP1P4Check
DoP1P4Check
          if playerX[0] >= playerX[3] then goto CalcP1P4DistanceRight
          temp2 = playerX[3] - playerX[0]
          goto P1P4DistanceDone
CalcP1P4DistanceRight
          temp2 = playerX[0] - playerX[3]
P1P4DistanceDone
          if temp2 < 16 then if playerX[0] < playerX[3] then playerX[0] = playerX[0] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP1P4Sep
          if temp2 < 16 then playerX[0] = playerX[0] + 1 : playerX[3] = playerX[3] - 1
SkipP1P4Sep
SkipP1P4Check
          
          
          
          
          rem Check Player 2 vs Player 3
          if selectedChar3 = 255 then goto SkipP2P3Check
DoP2P3Check
          if playerX[1] >= playerX[2] then goto CalcP2P3DistanceRight
          temp2 = playerX[2] - playerX[1]
          goto P2P3DistanceDone
CalcP2P3DistanceRight
          temp2 = playerX[1] - playerX[2]
P2P3DistanceDone
          if temp2 < 16 then if playerX[1] < playerX[2] then playerX[1] = playerX[1] - 1 : playerX[2] = playerX[2] + 1 : goto SkipP2P3Sep
          if temp2 < 16 then playerX[1] = playerX[1] + 1 : playerX[2] = playerX[2] - 1
SkipP2P3Sep
SkipP2P3Check
          
          
          
          
          rem Check Player 2 vs Player 4
          if selectedChar4 = 255 then goto SkipP2P4Check
DoP2P4Check
          if playerX[1] >= playerX[3] then goto CalcP2P4DistanceRight
          temp2 = playerX[3] - playerX[1]
          goto P2P4DistanceDone
CalcP2P4DistanceRight
          temp2 = playerX[1] - playerX[3]
P2P4DistanceDone
          if temp2 < 16 then if playerX[1] < playerX[3] then playerX[1] = playerX[1] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP2P4Sep
          if temp2 < 16 then playerX[1] = playerX[1] + 1 : playerX[3] = playerX[3] - 1
SkipP2P4Sep
SkipP2P4Check
          
          
          
          
          rem Check Player 3 vs Player 4
          if selectedChar3 = 255 then goto SkipP3vsP4
          if selectedChar4 = 255 then goto SkipP3vsP4
          if playerX[2] >= playerX[3] then goto CalcP3P4DistanceRight
          temp2 = playerX[3] - playerX[2]
          goto P3P4DistanceDone
CalcP3P4DistanceRight
          temp2 = playerX[2] - playerX[3]
P3P4DistanceDone
          if temp2 < 16 then if playerX[2] < playerX[3] then playerX[2] = playerX[2] - 1 : playerX[3] = playerX[3] + 1 : goto SkipP3P4Sep
          if temp2 < 16 then playerX[2] = playerX[2] + 1 : playerX[3] = playerX[3] - 1
SkipP3P4Sep
          
          
          
          
          return

