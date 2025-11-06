          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem PLAYER PHYSICS
          rem ==========================================================
          rem Handles gravity, momentum, collisions, and recovery for
          rem   all players.

          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem playerVelocityX[0-3] - Horizontal velocity (8.8
          rem   fixed-point)
          rem playerVelocityY[0-3] - Vertical velocity (8.8 fixed-point)
          rem playerRecoveryFrames[0-3] - Recovery (hitstun) frames
          rem   remaining
          rem   QuadtariDetected - Whether 4-player mode active
          rem   selectedChar3_R, selectedChar4_R - Player 3/4 selections
          rem   playerChar[0-3] - Character type indices
          rem ==========================================================

          rem ==========================================================
          rem APPLY GRAVITY
          rem ==========================================================
          rem Applies gravity acceleration to jumping players.
          rem Certain characters (Frooty=8, Dragon of Storms=2) are not
          rem   affected by gravity.
          rem Players land when they are atop a playfield pixel (ground
          rem   detection).
          rem Gravity accelerates downward using tunable constants
          rem   (Constants.bas):
          rem GravityNormal (0.1px/frame²), GravityReduced
          rem   (0.05px/frame²), TerminalVelocity (8px/frame)
PhysicsApplyGravity
          dim PAG_playerIndex = temp1
          dim PAG_playfieldColumn = temp2
          dim PAG_feetY = temp3
          dim PAG_feetRow = temp4
          dim PAG_characterType = temp6
          rem Loop through all players (0-3)
          let PAG_playerIndex = 0
GravityLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem   Quadtari)
          if PAG_playerIndex < 2 then GravityCheckCharacter
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto GravityNextPlayer
          if PAG_playerIndex = 2 && selectedChar3_R = 255 then goto GravityNextPlayer
          if PAG_playerIndex = 3 && selectedChar4_R = 255 then goto GravityNextPlayer
          
GravityCheckCharacter
          let PAG_characterType = playerChar[PAG_playerIndex]
          
          rem Skip gravity for characters that do not have it
          rem Frooty (8): Permanent flight, no gravity
          if PAG_characterType = CharFrooty then goto GravityNextPlayer
          rem Dragon of Storms (2): Permanent flight, no gravity
          rem   (hovering/flying like Frooty)
          if PAG_characterType = CharDragonOfStorms then goto GravityNextPlayer
          
          rem RoboTito (13): Skip gravity when latched to ceiling
          if PAG_characterType <> CharRoboTito then goto GravityCheckRoboTitoDone
          if (characterStateFlags_R[PAG_playerIndex] & 1) then goto GravityNextPlayer
          rem Latched to ceiling (bit 0 set), skip gravity
GravityCheckRoboTitoDone
          
          rem If NOT jumping, skip gravity (player is on ground)
          if !(playerState[PAG_playerIndex] & PlayerStateBitJumping) then goto GravityNextPlayer
          
          rem Initialize or get vertical velocity (using temp variable)
          rem Note: Vertical velocity is not persistent - we will track it
          rem   per-frame
          rem For now, we will apply gravity acceleration directly to
          rem   position
          rem TODO: Consider implementing persistent vertical velocity
          rem   tracking (Issue #599)
          
          rem Determine gravity acceleration rate based on character
          rem   (8.8 fixed-point subpixel)
          rem Uses tunable constants from Constants.bas for easy
          rem   adjustment
          let gravityRate = GravityNormal
          rem Default gravity acceleration (normal rate)
          if PAG_characterType = CharHarpy then let gravityRate = GravityReduced
          rem Harpy: reduced gravity rate
          
          rem Apply gravity acceleration to velocity subpixel part (adds
          rem   to Y velocity, positive = downward)
          rem playerIndex already set, gravityRate is gravity strength
          rem   in subpixel (low byte)
          rem AddVelocitySubpixelY expects temp2, so save temp2 and use
          rem   it for gravityRate
          let playfieldColumn = PAG_playfieldColumn
          rem Save playfieldColumn temporarily
          let temp2 = gravityRate
          gosub AddVelocitySubpixelY
          let PAG_playfieldColumn = temp2
          rem Restore playfieldColumn
          
          rem Apply terminal velocity cap (prevents infinite
          rem   acceleration)
          rem Check if velocity exceeds terminal velocity (positive =
          rem   downward)
          if playerVelocityY[PAG_playerIndex] > TerminalVelocity then let playerVelocityY[PAG_playerIndex] = TerminalVelocity : let playerVelocityYL[PAG_playerIndex] = 0
          
          rem Check playfield collision for ground detection (downward)
          rem Convert player X position to playfield column (0-31)
          rem Use shared coordinate conversion subroutine
          let temp1 = PAG_playerIndex
          gosub ConvertPlayerXToPlayfieldColumn
          let PAG_playfieldColumn = temp2
          
          rem Calculate row where player feet are (bottom of sprite)
          rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let PAG_feetY = playerY[PAG_playerIndex] + PlayerSpriteHeight
          rem Divide by pfrowheight using helper
          let temp2 = PAG_feetY
          gosub DivideByPfrowheight
          let PAG_feetRow = temp2
          rem feetRow = row where feet are
          
          dim PAG_rowBelow = temp5
          rem Check if there is a playfield pixel in the row below the
          rem   feet
          rem If feet are in row N, check row N+1 for ground
          if PAG_feetRow >= pfrows then goto GravityNextPlayer
          rem Feet are at or below bottom of playfield, continue falling
          
          let PAG_rowBelow = PAG_feetRow + 1
          rem rowBelow = row below feet
          if PAG_rowBelow >= pfrows then goto GravityCheckBottom
          rem Beyond playfield bounds, check if at bottom
          
          rem Check if playfield pixel exists in row below feet
          if !pfread(PAG_playfieldColumn, PAG_rowBelow) then goto GravityNextPlayer
          rem No ground pixel found, continue falling
          
          rem Ground detected! Stop falling and clamp position to ground
          rem Zero Y velocity (stop falling)
          let playerVelocityY[PAG_playerIndex] = 0
          let playerVelocityYL[PAG_playerIndex] = 0
          
          rem Calculate Y position for top of ground row using repeated
          rem   addition
          rem Loop to add pfrowheight to rowYPosition, rowBelow times
          let rowYPosition = 0
          let rowCounter = PAG_rowBelow
          if rowCounter = 0 then goto GravityRowCalcDone
GravityRowCalcLoop
          let rowYPosition = rowYPosition + pfrowheight
          let rowCounter = rowCounter - 1
          if rowCounter > 0 then goto GravityRowCalcLoop
GravityRowCalcDone
          rem rowYPosition now contains rowBelow * pfrowheight (Y
          rem   position of top of ground row)
          rem Clamp playerY so feet are at top of ground row
          let playerY[PAG_playerIndex] = rowYPosition - PlayerSpriteHeight
          rem Also sync subpixel position
          let playerSubpixelY[PAG_playerIndex] = playerY[PAG_playerIndex]
          let playerSubpixelYL[PAG_playerIndex] = 0
          
          rem Clear jumping flag (bit 2, not bit 4 - fix bit number)
          let playerState[PAG_playerIndex] = playerState[PAG_playerIndex] & (255 - PlayerStateBitJumping)
          rem Clear bit 2 (jumping flag)
          
          rem If RoboTito, set stretch permission on landing
          if PAG_characterType = CharRoboTito then PAG_SetRoboTitoStretchPermission
          goto GravityNextPlayer
          
PAG_SetRoboTitoStretchPermission
          dim PAGSRTSP_playerIndex = temp1
          dim PAGSRTSP_flags = temp2
          dim PAGSRTSP_bitMask = temp3
          rem Set stretch permission bit for this player using BitMask array lookup
          let PAGSRTSP_flags = roboTitoCanStretch_R
          rem Load current flags
          let PAGSRTSP_bitMask = BitMask[PAGSRTSP_playerIndex]
          rem Get bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          let PAGSRTSP_flags = PAGSRTSP_flags | PAGSRTSP_bitMask
          rem Set bit for this player
          let roboTitoCanStretch_W = PAGSRTSP_flags
          rem Store updated permission flags
          rem Clear stretch missile height on landing (not stretching)
          let missileStretchHeight_W[PAGSRTSP_playerIndex] = 0
          return
          
GravityCheckBottom
          rem At bottom of playfield - treat as ground if feet are at
          rem   bottom row
          if PAG_feetRow < pfrows - 1 then goto GravityNextPlayer
          rem Not at bottom row yet
          
          rem Bottom row is always ground - clamp to bottom
          rem Calculate (pfrows - 1) * pfrowheight using repeated
          rem   addition
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
          
          rem If RoboTito, set stretch permission on landing at bottom
          if PAG_characterType = CharRoboTito then PAG_SetRoboTitoStretchPermission
          
GravityNextPlayer
          rem Move to next player
          let temp1 = temp1 + 1
          if temp1 < 4 then goto GravityLoop
          
          return

          rem ==========================================================
          rem APPLY MOMENTUM AND RECOVERY
          rem ==========================================================
          rem Updates recovery frames and applies velocity during
          rem   hitstun.
          rem Velocity gradually decays over time.
          rem Refactored to loop through all players (0-3)
ApplyMomentumAndRecovery
          dim AMAR_playerIndex = temp1
          rem Loop through all players (0-3)
          let AMAR_playerIndex = 0
MomentumRecoveryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem   Quadtari)
          if AMAR_playerIndex < 2 then MomentumRecoveryProcess
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto MomentumRecoveryNext
          if AMAR_playerIndex = 2 && selectedChar3_R = 255 then goto MomentumRecoveryNext
          if AMAR_playerIndex = 3 && selectedChar4_R = 255 then goto MomentumRecoveryNext
          
MomentumRecoveryProcess
          rem Decrement recovery frames (velocity is applied by
          rem   UpdatePlayerMovement)
          if playerRecoveryFrames[AMAR_playerIndex] > 0 then let playerRecoveryFrames[AMAR_playerIndex] = playerRecoveryFrames[AMAR_playerIndex] - 1
          
          rem Synchronize playerState bit 3 with recovery frames
          if playerRecoveryFrames[AMAR_playerIndex] > 0 then let playerState[AMAR_playerIndex] = playerState[AMAR_playerIndex] | PlayerStateBitRecovery
          rem Set bit 3 (recovery flag) when recovery frames > 0
          if ! playerRecoveryFrames[AMAR_playerIndex] then let playerState[AMAR_playerIndex] = playerState[AMAR_playerIndex] & (255 - PlayerStateBitRecovery)
          rem Clear bit 3 (recovery flag) when recovery frames = 0
          
          rem Decay velocity if recovery frames active
          if ! playerRecoveryFrames[AMAR_playerIndex] then goto MomentumRecoveryNext
          rem Velocity decay during recovery (knockback slows down over
          rem   time)
          if playerVelocityX[AMAR_playerIndex] <= 0 then MomentumRecoveryDecayNegative
          rem Positive velocity: decay by 1
          let playerVelocityX[AMAR_playerIndex] = playerVelocityX[AMAR_playerIndex] - 1
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[AMAR_playerIndex] = 0 then let playerVelocityXL[AMAR_playerIndex] = 0
          goto MomentumRecoveryNext
MomentumRecoveryDecayNegative
          if playerVelocityX[AMAR_playerIndex] >= 0 then goto MomentumRecoveryNext
          rem Negative velocity: decay by 1 (add 1 to make less
          rem   negative)
          let playerVelocityX[AMAR_playerIndex] = playerVelocityX[AMAR_playerIndex] + 1
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[AMAR_playerIndex] = 0 then let playerVelocityXL[AMAR_playerIndex] = 0
          
MomentumRecoveryNext
          rem Next player
          let AMAR_playerIndex = AMAR_playerIndex + 1
          if AMAR_playerIndex < 4 then goto MomentumRecoveryLoop
          
          return

          rem ==========================================================
          rem CHECK BOUNDARY COLLISIONS
          rem ==========================================================
          rem Prevents players from moving off-screen.
CheckBoundaryCollisions
          dim CBC_playerIndex = temp1
          dim CBC_characterType = temp2
          rem Loop through all players (0-3)
          let CBC_playerIndex = 0
BoundaryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem   Quadtari)
          if CBC_playerIndex < 2 then BoundaryCheckBounds
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto BoundaryNextPlayer
          if CBC_playerIndex = 2 && selectedChar3_R = 255 then goto BoundaryNextPlayer
          if CBC_playerIndex = 3 && selectedChar4_R = 255 then goto BoundaryNextPlayer
          
BoundaryCheckBounds
          rem All arenas support horizontal wrap-around for players
          rem   (except where walls stop it)
          rem Handle RandomArena by checking selected arena
          dim CBC_arenaIndex = temp3
          let CBC_arenaIndex = selectedArena_R
          rem Handle RandomArena (use frame-based selection for
          rem   consistency)
          if CBC_arenaIndex = RandomArena then let CBC_arenaIndex = frame & 15
          
          rem All arenas: wrap horizontally (walls may block wrap-around)
          rem Horizontal wrap: X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[CBC_playerIndex] < 10 then let playerX[CBC_playerIndex] = 150
          if playerX[CBC_playerIndex] < 10 then let playerSubpixelX[CBC_playerIndex] = 150
          if playerX[CBC_playerIndex] < 10 then let playerSubpixelXL[CBC_playerIndex] = 0
          if playerX[CBC_playerIndex] > 150 then let playerX[CBC_playerIndex] = 10
          if playerX[CBC_playerIndex] > 150 then let playerSubpixelX[CBC_playerIndex] = 10
          if playerX[CBC_playerIndex] > 150 then let playerSubpixelXL[CBC_playerIndex] = 0
          
          rem Y position: clamp to screen boundaries (no vertical wrap)
          rem Top boundary: clamp to prevent going above screen
          if playerY[CBC_playerIndex] < 20 then let playerY[CBC_playerIndex] = 20
          if playerY[CBC_playerIndex] < 20 then let playerSubpixelY[CBC_playerIndex] = 20
          if playerY[CBC_playerIndex] < 20 then let playerSubpixelYL[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] < 20 then let playerVelocityY[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] < 20 then let playerVelocityYL[CBC_playerIndex] = 0
          rem Bottom boundary: clamp to prevent going below screen
          if playerY[CBC_playerIndex] > 80 then let playerY[CBC_playerIndex] = 80
          if playerY[CBC_playerIndex] > 80 then let playerSubpixelY[CBC_playerIndex] = 80
          if playerY[CBC_playerIndex] > 80 then let playerSubpixelYL[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] > 80 then let playerVelocityY[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] > 80 then let playerVelocityYL[CBC_playerIndex] = 0

BoundaryNextPlayer
          rem Move to next player
          let CBC_playerIndex = CBC_playerIndex + 1
          if CBC_playerIndex < 4 then goto BoundaryLoop
          
          return

          rem ==========================================================
          rem CHECK PLAYFIELD COLLISION ALL DIRECTIONS
          rem ==========================================================
          rem This function has been moved to PlayerPhysicsCollisions.bas
          rem to reduce bank size. Use gosub CheckPlayfieldCollisionAllDirections bank9
          rem to call it from this bank.

          rem ==========================================================
          rem CHECK MULTI-PLAYER COLLISIONS
          rem ==========================================================
          rem This function has been moved to PlayerPhysicsCollisions.bas
          rem to reduce bank size. Use gosub CheckAllPlayerCollisions bank9
          rem to call it from this bank.

          rem ==========================================================
          rem DIVIDE BY PFROWHEIGHT HELPER
          rem ==========================================================

