PhysicsApplyGravity
          rem
          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Player Physics
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
          rem
          rem   QuadtariDetected - Whether 4-player mode active
          rem   selectedChar3_R, selectedChar4_R - Player 3/4 selections
          rem   playerChar[0-3] - Character type indices
          rem Apply Gravity
          rem Applies gravity acceleration to jumping players.
          rem Certain characters (Frooty=8, Dragon of Storms=2) are not
          rem   affected by gravity.
          rem Players land when they are atop a playfield pixel (ground
          rem   detection).
          rem Gravity accelerates downward using tunable constants
          rem   (Constants.bas):
          rem GravityNormal (0.1px/frame²), GravityReduced
          rem   (0.05px/frame²), TerminalVelocity (8px/frame)
          rem Applies gravity acceleration to jumping players and
          rem handles ground detection
          rem Input: playerChar[] (global array) = character types,
          rem playerState[] (global array) = player states, playerX[],
          rem playerY[] (global arrays) = player positions,
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, controllerStatus (global) = controller
          rem state, selectedChar3_R, selectedChar4_R (global SCRAM) =
          rem player 3/4 selections, characterStateFlags_R[] (global
          rem SCRAM array) = character state flags, gravityRate (global)
          rem = gravity acceleration rate, GravityNormal,
          rem GravityReduced, TerminalVelocity (global constants) =
          rem gravity constants, BitMask[] (global data table) = bit
          rem masks, roboTitoCanStretch_R (global SCRAM) = stretch
          rem permission flags
          rem Output: Gravity applied to jumping players, ground
          rem detection performed, players clamped to ground on landing
          rem Mutates: temp1-temp6 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, playerY[] (global array) = player Y
          rem positions, playerSubpixelY[], playerSubpixelYL[] (global
          rem arrays) = subpixel Y positions, playerState[] (global
          rem array) = player states (jumping flag cleared on landing),
          rem roboTitoCanStretch_W (global SCRAM) = stretch permission
          rem flags (via PAG_SetRoboTitoStretchPermission),
          rem missileStretchHeight_W[] (global SCRAM array) = stretch
          rem missile heights (via PAG_SetRoboTitoStretchPermission),
          rem rowYPosition, rowCounter (global) = calculation
          rem temporaries
          rem Called Routines: AddVelocitySubpixelY - adds gravity to
          rem vertical velocity, ConvertPlayerXToPlayfieldColumn -
          rem converts player X to playfield column, DivideByPfrowheight
          rem - divides Y by row height,
          rem PAG_SetRoboTitoStretchPermission - sets RoboTito stretch
          rem permission on landing
          rem Constraints: Frooty (8) and Dragon of Storms (2) skip
          rem gravity entirely. RoboTito (13) skips gravity when latched
          rem to ceiling
          dim PAG_playerIndex = temp1
          dim PAG_playfieldColumn = temp2
          dim PAG_feetY = temp3
          dim PAG_feetRow = temp4
          dim PAG_characterType = temp6
          let PAG_playerIndex = 0 : rem Loop through all players (0-3)
GravityLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          if PAG_playerIndex < 2 then GravityCheckCharacter : rem   Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto GravityNextPlayer : rem Players 0-1 always active
          if PAG_playerIndex = 2 && selectedChar3_R = 255 then goto GravityNextPlayer
          if PAG_playerIndex = 3 && selectedChar4_R = 255 then goto GravityNextPlayer
          
GravityCheckCharacter
          let PAG_characterType = playerChar[PAG_playerIndex]
          
          rem Skip gravity for characters that do not have it
          if PAG_characterType = CharFrooty then goto GravityNextPlayer : rem Frooty (8): Permanent flight, no gravity
          rem Dragon of Storms (2): Permanent flight, no gravity
          if PAG_characterType = CharDragonOfStorms then goto GravityNextPlayer : rem   (hovering/flying like Frooty)
          
          if PAG_characterType <> CharRoboTito then goto GravityCheckRoboTitoDone : rem RoboTito (13): Skip gravity when latched to ceiling
          if (characterStateFlags_R[PAG_playerIndex] & 1) then goto GravityNextPlayer
          rem Latched to ceiling (bit 0 set), skip gravity
GravityCheckRoboTitoDone
          
          if !(playerState[PAG_playerIndex] & PlayerStateBitJumping) then goto GravityNextPlayer : rem If NOT jumping, skip gravity (player is on ground)
          
          rem Initialize or get vertical velocity (using temp variable)
          rem Note: Vertical velocity is not persistent - we will track
          rem it
          rem   per-frame
          rem For now, we will apply gravity acceleration directly to
          rem   position
          rem TODO: Consider implementing persistent vertical velocity
          rem   tracking (Issue #599)
          
          rem Determine gravity acceleration rate based on character
          rem   (8.8 fixed-point subpixel)
          rem Uses tunable constants from Constants.bas for easy
          let gravityRate = GravityNormal : rem   adjustment
          if PAG_characterType = CharHarpy then let gravityRate = GravityReduced : rem Default gravity acceleration (normal rate)
          rem Harpy: reduced gravity rate
          
          rem Apply gravity acceleration to velocity subpixel part (adds
          rem   to Y velocity, positive = downward)
          rem playerIndex already set, gravityRate is gravity strength
          rem   in subpixel (low byte)
          rem AddVelocitySubpixelY expects temp2, so save temp2 and use
          let playfieldColumn = PAG_playfieldColumn : rem   it for gravityRate
          let temp2 = gravityRate : rem Save playfieldColumn temporarily
          gosub AddVelocitySubpixelY
          let PAG_playfieldColumn = temp2
          rem Restore playfieldColumn
          
          rem Apply terminal velocity cap (prevents infinite
          rem   acceleration)
          rem Check if velocity exceeds terminal velocity (positive =
          if playerVelocityY[PAG_playerIndex] > TerminalVelocity then let playerVelocityY[PAG_playerIndex] = TerminalVelocity : let playerVelocityYL[PAG_playerIndex] = 0 : rem downward)
          
          rem Check playfield collision for ground detection (downward)
          rem Convert player X position to playfield column (0-31)
          let temp1 = PAG_playerIndex : rem Use shared coordinate conversion subroutine
          gosub ConvertPlayerXToPlayfieldColumn
          let PAG_playfieldColumn = temp2
          
          rem Calculate row where player feet are (bottom of sprite)
          let PAG_feetY = playerY[PAG_playerIndex] + PlayerSpriteHeight : rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let temp2 = PAG_feetY : rem Divide by pfrowheight using helper
          gosub DivideByPfrowheight
          let PAG_feetRow = temp2
          rem feetRow = row where feet are
          
          dim PAG_rowBelow = temp5
          rem Check if there is a playfield pixel in the row below the
          rem   feet
          if PAG_feetRow >= pfrows then goto GravityNextPlayer : rem If feet are in row N, check row N+1 for ground
          rem Feet are at or below bottom of playfield, continue falling
          
          let PAG_rowBelow = PAG_feetRow + 1
          if PAG_rowBelow >= pfrows then goto GravityCheckBottom : rem rowBelow = row below feet
          rem Beyond playfield bounds, check if at bottom
          
          if !pfread(PAG_playfieldColumn, PAG_rowBelow) then goto GravityNextPlayer : rem Check if playfield pixel exists in row below feet
          rem No ground pixel found, continue falling
          
          rem Ground detected! Stop falling and clamp position to ground
          let playerVelocityY[PAG_playerIndex] = 0 : rem Zero Y velocity (stop falling)
          let playerVelocityYL[PAG_playerIndex] = 0
          
          rem Calculate Y position for top of ground row using repeated
          rem   addition
          let rowYPosition = 0 : rem Loop to add pfrowheight to rowYPosition, rowBelow times
          let rowCounter = PAG_rowBelow
          if rowCounter = 0 then goto GravityRowCalcDone
GravityRowCalcLoop
          let rowYPosition = rowYPosition + pfrowheight
          let rowCounter = rowCounter - 1
          if rowCounter > 0 then goto GravityRowCalcLoop
GravityRowCalcDone
          rem rowYPosition now contains rowBelow * pfrowheight (Y
          rem   position of top of ground row)
          let playerY[PAG_playerIndex] = rowYPosition - PlayerSpriteHeight : rem Clamp playerY so feet are at top of ground row
          let playerSubpixelY[PAG_playerIndex] = playerY[PAG_playerIndex] : rem Also sync subpixel position
          let playerSubpixelYL[PAG_playerIndex] = 0
          
          let playerState[PAG_playerIndex] = playerState[PAG_playerIndex] & (255 - PlayerStateBitJumping) : rem Clear jumping flag (bit 2, not bit 4 - fix bit number)
          rem Clear bit 2 (jumping flag)
          
          if PAG_characterType = CharRoboTito then PAG_SetRoboTitoStretchPermission : rem If RoboTito, set stretch permission on landing
          goto GravityNextPlayer
          
PAG_SetRoboTitoStretchPermission
          rem Set RoboTito stretch permission on landing (allows
          rem stretching again)
          rem Input: PAGSRTSP_playerIndex (temp1) = player index (0-3),
          rem roboTitoCanStretch_R (global SCRAM) = stretch permission
          rem flags, BitMask[] (global data table) = bit masks
          rem Output: roboTitoCanStretch_W (global SCRAM) = stretch
          rem permission flags updated, missileStretchHeight_W[] (global
          rem SCRAM array) = stretch missile height cleared
          rem Mutates: temp1-temp3 (used for calculations),
          rem roboTitoCanStretch_W (global SCRAM) = stretch permission
          rem flags, missileStretchHeight_W[] (global SCRAM array) =
          rem stretch missile heights
          rem Called Routines: None
          dim PAGSRTSP_playerIndex = temp1 : rem Constraints: Only called for RoboTito character on landing
          dim PAGSRTSP_flags = temp2
          dim PAGSRTSP_bitMask = temp3
          let PAGSRTSP_flags = roboTitoCanStretch_R : rem Set stretch permission bit for this player using BitMask array lookup
          let PAGSRTSP_bitMask = BitMask[PAGSRTSP_playerIndex] : rem Load current flags
          let PAGSRTSP_flags = PAGSRTSP_flags | PAGSRTSP_bitMask : rem Get bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          let roboTitoCanStretch_W = PAGSRTSP_flags : rem Set bit for this player
          rem Store updated permission flags
          let missileStretchHeight_W[PAGSRTSP_playerIndex] = 0 : rem Clear stretch missile height on landing (not stretching)
          return
          
GravityCheckBottom
          rem At bottom of playfield - treat as ground if feet are at
          if PAG_feetRow < pfrows - 1 then goto GravityNextPlayer : rem   bottom row
          rem Not at bottom row yet
          
          rem Bottom row is always ground - clamp to bottom
          rem Calculate (pfrows - 1) * pfrowheight using repeated
          let rowYPosition = 0 : rem   addition
          let rowCounter = pfrows - 1
          if rowCounter = 0 then goto GravityBottomCalcDone
GravityBottomCalcLoop
          let rowYPosition = rowYPosition + pfrowheight
          let rowCounter = rowCounter - 1
          if rowCounter > 0 then goto GravityBottomCalcLoop
GravityBottomCalcDone
          let playerY[temp1] = rowYPosition - PlayerSpriteHeight
          let playerState[temp1] = playerState[temp1] & NOT 4
          
          if PAG_characterType = CharRoboTito then PAG_SetRoboTitoStretchPermission : rem If RoboTito, set stretch permission on landing at bottom
          
GravityNextPlayer
          let temp1 = temp1 + 1 : rem Move to next player
          if temp1 < 4 then goto GravityLoop
          
          return

          rem
          rem Apply Momentum And Recovery
          rem Updates recovery frames and applies velocity during
          rem   hitstun.
          rem Velocity gradually decays over time.
          rem Refactored to loop through all players (0-3)
ApplyMomentumAndRecovery
          rem Updates recovery frames and applies velocity decay during
          rem hitstun for all players
          rem Input: playerRecoveryFrames[] (global array) = recovery
          rem frame counts, playerVelocityX[], playerVelocityXL[]
          rem (global arrays) = horizontal velocity, playerState[]
          rem (global array) = player states, controllerStatus (global)
          rem = controller state, selectedChar3_R, selectedChar4_R
          rem (global SCRAM) = player 3/4 selections,
          rem PlayerStateBitRecovery (global constant) = recovery flag
          rem bit
          rem Output: Recovery frames decremented, recovery flag
          rem synchronized, velocity decayed during recovery
          rem Mutates: temp1 (used for player index),
          rem playerRecoveryFrames[] (global array) = recovery frame
          rem counts, playerState[] (global array) = player states
          rem (recovery flag bit 3), playerVelocityX[],
          rem playerVelocityXL[] (global arrays) = horizontal velocity
          rem (decayed)
          rem Called Routines: None
          dim AMAR_playerIndex = temp1 : rem Constraints: None
          let AMAR_playerIndex = 0 : rem Loop through all players (0-3)
MomentumRecoveryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          if AMAR_playerIndex < 2 then MomentumRecoveryProcess : rem   Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto MomentumRecoveryNext : rem Players 0-1 always active
          if AMAR_playerIndex = 2 && selectedChar3_R = 255 then goto MomentumRecoveryNext
          if AMAR_playerIndex = 3 && selectedChar4_R = 255 then goto MomentumRecoveryNext
          
MomentumRecoveryProcess
          rem Decrement recovery frames (velocity is applied by
          if playerRecoveryFrames[AMAR_playerIndex] > 0 then let playerRecoveryFrames[AMAR_playerIndex] = playerRecoveryFrames[AMAR_playerIndex] - 1 : rem   UpdatePlayerMovement)
          
          if playerRecoveryFrames[AMAR_playerIndex] > 0 then let playerState[AMAR_playerIndex] = playerState[AMAR_playerIndex] | PlayerStateBitRecovery : rem Synchronize playerState bit 3 with recovery frames
          if ! playerRecoveryFrames[AMAR_playerIndex] then let playerState[AMAR_playerIndex] = playerState[AMAR_playerIndex] & (255 - PlayerStateBitRecovery) : rem Set bit 3 (recovery flag) when recovery frames > 0
          rem Clear bit 3 (recovery flag) when recovery frames = 0
          
          if ! playerRecoveryFrames[AMAR_playerIndex] then goto MomentumRecoveryNext : rem Decay velocity if recovery frames active
          rem Velocity decay during recovery (knockback slows down over
          if playerVelocityX[AMAR_playerIndex] <= 0 then MomentumRecoveryDecayNegative : rem   time)
          let playerVelocityX[AMAR_playerIndex] = playerVelocityX[AMAR_playerIndex] - 1 : rem Positive velocity: decay by 1
          if playerVelocityX[AMAR_playerIndex] = 0 then let playerVelocityXL[AMAR_playerIndex] = 0 : rem Also decay subpixel if integer velocity is zero
          goto MomentumRecoveryNext
MomentumRecoveryDecayNegative
          if playerVelocityX[AMAR_playerIndex] >= 0 then goto MomentumRecoveryNext
          rem Negative velocity: decay by 1 (add 1 to make less
          let playerVelocityX[AMAR_playerIndex] = playerVelocityX[AMAR_playerIndex] + 1 : rem   negative)
          if playerVelocityX[AMAR_playerIndex] = 0 then let playerVelocityXL[AMAR_playerIndex] = 0 : rem Also decay subpixel if integer velocity is zero
          
MomentumRecoveryNext
          let AMAR_playerIndex = AMAR_playerIndex + 1 : rem Next player
          if AMAR_playerIndex < 4 then goto MomentumRecoveryLoop
          
          return

          rem
          rem Check Boundary Collisions
          rem Prevents players from moving off-screen.
CheckBoundaryCollisions
          rem Prevents players from moving off-screen, handles
          rem horizontal wrap-around and vertical clamping
          rem Input: playerX[], playerY[] (global arrays) = player
          rem positions, playerSubpixelX[], playerSubpixelY[],
          rem playerSubpixelXL[], playerSubpixelYL[] (global arrays) =
          rem subpixel positions, playerVelocityY[], playerVelocityYL[]
          rem (global arrays) = vertical velocity, controllerStatus
          rem (global) = controller state, selectedChar3_R,
          rem selectedChar4_R (global SCRAM) = player 3/4 selections,
          rem selectedArena_R (global SCRAM) = selected arena, frame
          rem (global) = frame counter, RandomArena (global constant) =
          rem random arena constant
          rem Output: Players clamped to screen boundaries, horizontal
          rem wrap-around applied
          rem Mutates: temp1-temp3 (used for calculations), playerX[],
          rem playerY[] (global arrays) = player positions,
          rem playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[],
          rem playerSubpixelYL[] (global arrays) = subpixel positions,
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity (zeroed at boundaries)
          rem Called Routines: None
          rem Constraints: All arenas support horizontal wrap-around (X
          rem < 10 wraps to 150, X > 150 wraps to 10). Vertical
          rem boundaries clamped (Y < 20 clamped to 20, Y > 80 clamped
          rem to 80)
          dim CBC_playerIndex = temp1
          dim CBC_characterType = temp2
          let CBC_playerIndex = 0 : rem Loop through all players (0-3)
BoundaryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          if CBC_playerIndex < 2 then BoundaryCheckBounds : rem   Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto BoundaryNextPlayer : rem Players 0-1 always active
          if CBC_playerIndex = 2 && selectedChar3_R = 255 then goto BoundaryNextPlayer
          if CBC_playerIndex = 3 && selectedChar4_R = 255 then goto BoundaryNextPlayer
          
BoundaryCheckBounds
          rem All arenas support horizontal wrap-around for players
          rem   (except where walls stop it)
          dim CBC_arenaIndex = temp3 : rem Handle RandomArena by checking selected arena
          let CBC_arenaIndex = selectedArena_R
          rem Handle RandomArena (use proper random number generator)
          if CBC_arenaIndex = RandomArena then let CBC_arenaIndex = rand : let CBC_arenaIndex = CBC_arenaIndex & 15
          
          rem All arenas: wrap horizontally (walls may block
          rem wrap-around)
          if playerX[CBC_playerIndex] < 10 then let playerX[CBC_playerIndex] = 150 : rem Horizontal wrap: X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[CBC_playerIndex] < 10 then let playerSubpixelX[CBC_playerIndex] = 150
          if playerX[CBC_playerIndex] < 10 then let playerSubpixelXL[CBC_playerIndex] = 0
          if playerX[CBC_playerIndex] > 150 then let playerX[CBC_playerIndex] = 10
          if playerX[CBC_playerIndex] > 150 then let playerSubpixelX[CBC_playerIndex] = 10
          if playerX[CBC_playerIndex] > 150 then let playerSubpixelXL[CBC_playerIndex] = 0
          
          rem Y position: clamp to screen boundaries (no vertical wrap)
          if playerY[CBC_playerIndex] < 20 then let playerY[CBC_playerIndex] = 20 : rem Top boundary: clamp to prevent going above screen
          if playerY[CBC_playerIndex] < 20 then let playerSubpixelY[CBC_playerIndex] = 20
          if playerY[CBC_playerIndex] < 20 then let playerSubpixelYL[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] < 20 then let playerVelocityY[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] < 20 then let playerVelocityYL[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] > 80 then let playerY[CBC_playerIndex] = 80 : rem Bottom boundary: clamp to prevent going below screen
          if playerY[CBC_playerIndex] > 80 then let playerSubpixelY[CBC_playerIndex] = 80
          if playerY[CBC_playerIndex] > 80 then let playerSubpixelYL[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] > 80 then let playerVelocityY[CBC_playerIndex] = 0
          if playerY[CBC_playerIndex] > 80 then let playerVelocityYL[CBC_playerIndex] = 0

BoundaryNextPlayer
          let CBC_playerIndex = CBC_playerIndex + 1 : rem Move to next player
          if CBC_playerIndex < 4 then goto BoundaryLoop
          
          return

          rem
          rem Check Playfield Collision All Directions
          rem
          rem This function has been moved to
          rem PlayerPhysicsCollisions.bas
          rem to reduce bank size. Use gosub
          rem CheckPlayfieldCollisionAllDirections bank9
          rem to call it from this bank.

          rem Check Multi-player Collisions
          rem
          rem This function has been moved to
          rem PlayerPhysicsCollisions.bas
          rem to reduce bank size. Use gosub CheckAllPlayerCollisions
          rem bank9
          rem to call it from this bank.

          rem Divide By Pfrowheight Helper

