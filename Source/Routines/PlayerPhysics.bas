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
          rem   selectedCharacter3_R, selectedCharacter4_R - Player 3/4 selections
          rem   playerCharacter[0-3] - Character type indices
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
          rem
          rem Input: playerCharacter[] (global array) = character types,
          rem playerState[] (global array) = player states, playerX[],
          rem playerY[] (global arrays) = player positions,
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity, controllerStatus (global) = controller
          rem state, selectedCharacter3_R, selectedCharacter4_R (global SCRAM) =
          rem player 3/4 selections, characterStateFlags_R[] (global
          rem SCRAM array) = character state flags, gravityRate (global)
          rem = gravity acceleration rate, GravityNormal,
          rem GravityReduced, TerminalVelocity (global constants) =
          rem gravity constants, BitMask[] (global data table) = bit
          rem masks, roboTitoCanStretch_R (global SCRAM) = stretch
          rem permission flags
          rem
          rem Output: Gravity applied to jumping players, ground
          rem detection performed, players clamped to ground on landing
          rem
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
          rem
          rem Called Routines: AddVelocitySubpixelY - adds gravity to
          rem vertical velocity, ConvertPlayerXToPlayfieldColumn -
          rem converts player X to playfield column, DivideByPfrowheight
          rem - divides Y by row height,
          rem PAG_SetRoboTitoStretchPermission - sets RoboTito stretch
          rem permission on landing
          rem
          rem Constraints: Frooty (8) and Dragon of Storms (2) skip
          rem gravity entirely. RoboTito (13) skips gravity when latched
          rem to ceiling
          let temp1 = 0 : rem Loop through all players (0-3)
GravityLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          if temp1 < 2 then GravityCheckCharacter : rem   Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto GravityNextPlayer : rem Players 0-1 always active
          if temp1 = 2 && selectedCharacter3_R = 255 then goto GravityNextPlayer
          if temp1 = 3 && selectedCharacter4_R = 255 then goto GravityNextPlayer
          
GravityCheckCharacter
          let temp6 = playerCharacter[temp1]
          
          rem Skip gravity for characters that do not have it
          if temp6 = CharacterFrooty then goto GravityNextPlayer : rem Frooty (8): Permanent flight, no gravity
          rem Dragon of Storms (2): Permanent flight, no gravity
          if temp6 = CharacterDragonOfStorms then goto GravityNextPlayer : rem   (hovering/flying like Frooty)
          
          if temp6 <> CharacterRoboTito then goto GravityCheckRoboTitoDone : rem RoboTito (13): Skip gravity when latched to ceiling
          if (characterStateFlags_R[temp1] & 1) then goto GravityNextPlayer
GravityCheckRoboTitoDone
          rem Latched to ceiling (bit 0 set), skip gravity
          
          if !(playerState[temp1] & PlayerStateBitJumping) then goto GravityNextPlayer : rem If NOT jumping, skip gravity (player is on ground)
          
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
          let gravityRate_W = GravityNormal : rem   adjustment
          if temp6 = CharacterHarpy then let gravityRate_W = GravityReduced : rem Default gravity acceleration (normal rate)
          rem Harpy: reduced gravity rate
          
          rem Apply gravity acceleration to velocity subpixel part (adds
          rem   to Y velocity, positive = downward)
          rem playerIndex already set, gravityRate is gravity strength
          rem   in subpixel (low byte)
          rem AddVelocitySubpixelY expects temp2, so save temp2 and use
          let playfieldColumn_W = temp2 : rem   it for gravityRate
          let temp2 = gravityRate_R : rem Save playfieldColumn temporarily
          gosub AddVelocitySubpixelY
          let temp2 = temp2
          rem Restore playfieldColumn
          
          rem Apply terminal velocity cap (prevents infinite
          rem   acceleration)
          rem Check if velocity exceeds terminal velocity (positive =
          if playerVelocityY[temp1] > TerminalVelocity then let playerVelocityY[temp1] = TerminalVelocity : let playerVelocityYL[temp1] = 0 : rem downward)
          
          rem Check playfield collision for ground detection (downward)
          rem Convert player X position to playfield column (0-31)
          rem Use shared coordinate conversion subroutine
          gosub ConvertPlayerXToPlayfieldColumn
          let temp2 = temp2
          
          rem Calculate row where player feet are (bottom of sprite)
          let temp3 = playerY[temp1] + PlayerSpriteHeight : rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let temp2 = temp3 : rem Divide by pfrowheight using helper
          gosub DivideByPfrowheight
          let temp4 = temp2
          rem feetRow = row where feet are
          
          rem Check if there is a playfield pixel in the row below the
          rem   feet
          if temp4 >= pfrows then goto GravityNextPlayer : rem If feet are in row N, check row N+1 for ground
          rem Feet are at or below bottom of playfield, continue falling
          
          let temp5 = temp4 + 1
          if temp5 >= pfrows then goto GravityCheckBottom : rem rowBelow = row below feet
          rem Beyond playfield bounds, check if at bottom
          
          if !pfread(temp2, temp5) then goto GravityNextPlayer : rem Check if playfield pixel exists in row below feet
          rem No ground pixel found, continue falling
          
          rem Ground detected! Stop falling and clamp position to ground
          let playerVelocityY[temp1] = 0 : rem Zero Y velocity (stop falling)
          let playerVelocityYL[temp1] = 0
          
          rem Calculate Y position for top of ground row using repeated
          rem   addition
          let rowYPosition_W = 0 : rem Loop to add pfrowheight to rowYPosition, rowBelow times
          let rowCounter_W = temp5
          if rowCounter_R = 0 then goto GravityRowCalcDone
GravityRowCalcLoop
          let rowYPosition_W = rowYPosition_R + pfrowheight
          let rowCounter_W = rowCounter_R - 1
          if rowCounter_R > 0 then goto GravityRowCalcLoop
GravityRowCalcDone
          rem rowYPosition now contains rowBelow * pfrowheight (Y
          rem   position of top of ground row)
          let playerY[temp1] = rowYPosition_R - PlayerSpriteHeight : rem Clamp playerY so feet are at top of ground row
          let playerSubpixelY_W[temp1] = playerY[temp1] : rem Also sync subpixel position
          let playerSubpixelY_WL[temp1] = 0
          
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitJumping) : rem Clear jumping flag (bit 2, not bit 4 - fix bit number)
          rem Clear bit 2 (jumping flag)
          
          if temp6 = CharacterRoboTito then PAG_SetRoboTitoStretchPermission : rem If RoboTito, set stretch permission on landing
          goto GravityNextPlayer
          
PAG_SetRoboTitoStretchPermission
          rem Set RoboTito stretch permission on landing (allows
          rem stretching again)
          rem
          rem Input: temp1 (temp1) = player index (0-3),
          rem roboTitoCanStretch_R (global SCRAM) = stretch permission
          rem flags, BitMask[] (global data table) = bit masks
          rem
          rem Output: roboTitoCanStretch_W (global SCRAM) = stretch
          rem permission flags updated, missileStretchHeight_W[] (global
          rem SCRAM array) = stretch missile height cleared
          rem
          rem Mutates: temp1-temp3 (used for calculations),
          rem roboTitoCanStretch_W (global SCRAM) = stretch permission
          rem flags, missileStretchHeight_W[] (global SCRAM array) =
          rem stretch missile heights
          rem
          rem Called Routines: None
          rem Constraints: Only called for RoboTito character on landing
          let temp2 = roboTitoCanStretch_R : rem Set stretch permission bit for this player using BitMask array lookup
          let temp3 = BitMask[temp1] : rem Load current flags
          let temp2 = temp2 | temp3 : rem Get bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          let roboTitoCanStretch_W = temp2 : rem Set bit for this player
          rem Store updated permission flags
          let missileStretchHeight_W[temp1] = 0 : rem Clear stretch missile height on landing (not stretching)
          return
          
GravityCheckBottom
          rem At bottom of playfield - treat as ground if feet are at
          if temp4 < pfrows - 1 then goto GravityNextPlayer : rem   bottom row
          rem Not at bottom row yet
          
          rem Bottom row is always ground - clamp to bottom
          rem Calculate (pfrows - 1) * pfrowheight using repeated
          let rowYPosition_W = 0 : rem   addition
          let rowCounter_W = pfrows - 1
          if rowCounter_R = 0 then goto GravityBottomCalcDone
GravityBottomCalcLoop
          let rowYPosition_W = rowYPosition_R + pfrowheight
          let rowCounter_W = rowCounter_R - 1
          if rowCounter_R > 0 then goto GravityBottomCalcLoop
GravityBottomCalcDone
          let playerY[temp1] = rowYPosition_R - PlayerSpriteHeight
          let playerState[temp1] = playerState[temp1] & NOT 4
          
          if temp6 = CharacterRoboTito then PAG_SetRoboTitoStretchPermission : rem If RoboTito, set stretch permission on landing at bottom
          
GravityNextPlayer
          let temp1 = temp1 + 1 : rem Move to next player
          if temp1 < 4 then goto GravityLoop
          
          return

ApplyMomentumAndRecovery
          rem
          rem Apply Momentum And Recovery
          rem Updates recovery frames and applies velocity during
          rem   hitstun.
          rem Velocity gradually decays over time.
          rem Refactored to loop through all players (0-3)
          rem Updates recovery frames and applies velocity decay during
          rem hitstun for all players
          rem
          rem Input: playerRecoveryFrames[] (global array) = recovery
          rem frame counts, playerVelocityX[], playerVelocityXL[]
          rem (global arrays) = horizontal velocity, playerState[]
          rem (global array) = player states, controllerStatus (global)
          rem = controller state, selectedCharacter3_R, selectedCharacter4_R
          rem (global SCRAM) = player 3/4 selections,
          rem PlayerStateBitRecovery (global constant) = recovery flag
          rem bit
          rem
          rem Output: Recovery frames decremented, recovery flag
          rem synchronized, velocity decayed during recovery
          rem
          rem Mutates: temp1 (used for player index),
          rem playerRecoveryFrames[] (global array) = recovery frame
          rem counts, playerState[] (global array) = player states
          rem (recovery flag bit 3), playerVelocityX[],
          rem playerVelocityXL[] (global arrays) = horizontal velocity
          rem (decayed)
          rem
          rem Called Routines: None
          rem Constraints: None
          let temp1 = 0 : rem Loop through all players (0-3)
MomentumRecoveryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          if temp1 < 2 then MomentumRecoveryProcess : rem   Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto MomentumRecoveryNext : rem Players 0-1 always active
          if temp1 = 2 && selectedCharacter3_R = 255 then goto MomentumRecoveryNext
          if temp1 = 3 && selectedCharacter4_R = 255 then goto MomentumRecoveryNext
          
MomentumRecoveryProcess
          rem Decrement recovery frames (velocity is applied by
          if playerRecoveryFrames[temp1] > 0 then let playerRecoveryFrames[temp1] = playerRecoveryFrames[temp1] - 1 : rem   UpdatePlayerMovement)
          
          if playerRecoveryFrames[temp1] > 0 then let playerState[temp1] = playerState[temp1] | PlayerStateBitRecovery : rem Synchronize playerState bit 3 with recovery frames
          if ! playerRecoveryFrames[temp1] then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitRecovery) : rem Set bit 3 (recovery flag) when recovery frames > 0
          rem Clear bit 3 (recovery flag) when recovery frames = 0
          
          if ! playerRecoveryFrames[temp1] then goto MomentumRecoveryNext : rem Decay velocity if recovery frames active
          rem Velocity decay during recovery (knockback slows down over
          if playerVelocityX[temp1] <= 0 then MomentumRecoveryDecayNegative : rem   time)
          let playerVelocityX[temp1] = playerVelocityX[temp1] - 1 : rem Positive velocity: decay by 1
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0 : rem Also decay subpixel if integer velocity is zero
          goto MomentumRecoveryNext
MomentumRecoveryDecayNegative
          if playerVelocityX[temp1] >= 0 then goto MomentumRecoveryNext
          rem Negative velocity: decay by 1 (add 1 to make less
          let playerVelocityX[temp1] = playerVelocityX[temp1] + 1 : rem   negative)
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0 : rem Also decay subpixel if integer velocity is zero
          
MomentumRecoveryNext
          let temp1 = temp1 + 1 : rem Next player
          if temp1 < 4 then goto MomentumRecoveryLoop
          
          return

CheckBoundaryCollisions
          rem
          rem Check Boundary Collisions
          rem Prevents players from moving off-screen.
          rem Prevents players from moving off-screen, handles
          rem horizontal wrap-around and vertical clamping
          rem
          rem Input: playerX[], playerY[] (global arrays) = player
          rem positions, playerSubpixelX[], playerSubpixelY[],
          rem playerSubpixelXL[], playerSubpixelYL[] (global arrays) =
          rem subpixel positions, playerVelocityY[], playerVelocityYL[]
          rem (global arrays) = vertical velocity, controllerStatus
          rem (global) = controller state, selectedCharacter3_R,
          rem selectedCharacter4_R (global SCRAM) = player 3/4 selections,
          rem selectedArena_R (global SCRAM) = selected arena, frame
          rem (global) = frame counter, RandomArena (global constant) =
          rem random arena constant
          rem
          rem Output: Players clamped to screen boundaries, horizontal
          rem wrap-around applied
          rem
          rem Mutates: temp1-temp3 (used for calculations), playerX[],
          rem playerY[] (global arrays) = player positions,
          rem playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[],
          rem playerSubpixelYL[] (global arrays) = subpixel positions,
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity (zeroed at boundaries)
          rem
          rem Called Routines: None
          rem
          rem Constraints: All arenas support horizontal wrap-around (X
          rem < 10 wraps to 150, X > 150 wraps to 10). Vertical
          rem boundaries clamped (Y < 20 clamped to 20, Y > 80 clamped
          rem to 80)
          let temp1 = 0 : rem Loop through all players (0-3)
BoundaryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          if temp1 < 2 then BoundaryCheckBounds : rem   Quadtari)
          if !(controllerStatus & SetQuadtariDetected) then goto BoundaryNextPlayer : rem Players 0-1 always active
          if temp1 = 2 && selectedCharacter3_R = 255 then goto BoundaryNextPlayer
          if temp1 = 3 && selectedCharacter4_R = 255 then goto BoundaryNextPlayer
          
BoundaryCheckBounds
          rem All arenas support horizontal wrap-around for players
          rem   (except where walls stop it)
          rem Handle RandomArena by checking selected arena
          let temp3 = selectedArena_R
          rem Handle RandomArena (use proper random number generator)
          if temp3 = RandomArena then let temp3 = rand : let temp3 = temp3 & 15
          
          rem All arenas: wrap horizontally (walls may block
          rem wrap-around)
          if playerX[temp1] < 10 then let playerX[temp1] = 150 : rem Horizontal wrap: X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[temp1] < 10 then let playerSubpixelX_W[temp1] = 150
          if playerX[temp1] < 10 then let playerSubpixelX_WL[temp1] = 0
          if playerX[temp1] > 150 then let playerX[temp1] = 10
          if playerX[temp1] > 150 then let playerSubpixelX_W[temp1] = 10
          if playerX[temp1] > 150 then let playerSubpixelX_WL[temp1] = 0
          
          rem Y position: clamp to screen boundaries (no vertical wrap)
          if playerY[temp1] < 20 then let playerY[temp1] = 20 : rem Top boundary: clamp to prevent going above screen
          if playerY[temp1] < 20 then let playerSubpixelY_W[temp1] = 20
          if playerY[temp1] < 20 then let playerSubpixelY_WL[temp1] = 0
          if playerY[temp1] < 20 then let playerVelocityY[temp1] = 0
          if playerY[temp1] < 20 then let playerVelocityYL[temp1] = 0
          if playerY[temp1] > 80 then let playerY[temp1] = 80 : rem Bottom boundary: clamp to prevent going below screen
          if playerY[temp1] > 80 then let playerSubpixelY_W[temp1] = 80
          if playerY[temp1] > 80 then let playerSubpixelY_WL[temp1] = 0
          if playerY[temp1] > 80 then let playerVelocityY[temp1] = 0
          if playerY[temp1] > 80 then let playerVelocityYL[temp1] = 0

BoundaryNextPlayer
          let temp1 = temp1 + 1 : rem Move to next player
          if temp1 < 4 then goto BoundaryLoop
          
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

