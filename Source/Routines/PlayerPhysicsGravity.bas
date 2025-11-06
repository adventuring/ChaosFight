PhysicsApplyGravity
          rem
          rem ChaosFight - Source/Routines/PlayerPhysicsGravity.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Player Physics - Gravity And Momentum
          rem Handles gravity, momentum, and recovery for all players.
          rem Split from PlayerPhysics.bas to reduce bank size.
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
          rem Applies gravity acceleration to jumping players and handles ground detection
          rem Input: playerChar[] (global array) = character types, playerState[] (global array) = player states, playerX[], playerY[] (global arrays) = player positions, playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, controllerStatus (global) = controller state, selectedChar3_R, selectedChar4_R (global SCRAM) = player 3/4 selections, characterStateFlags_R[] (global SCRAM array) = character state flags, gravityRate (global) = gravity acceleration rate, GravityNormal, GravityReduced, TerminalVelocity (global constants) = gravity constants, BitMask[] (global data table) = bit masks, roboTitoCanStretch_R (global SCRAM) = stretch permission flags
          rem Output: Gravity applied to jumping players, ground detection performed, players clamped to ground on landing
          rem Mutates: temp1-temp6 (used for calculations), playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity, playerY[] (global array) = player Y positions, playerSubpixelY[], playerSubpixelYL[] (global arrays) = subpixel Y positions, playerState[] (global array) = player states (jumping flag cleared on landing), roboTitoCanStretch_W (global SCRAM) = stretch permission flags (via PAG_SetRoboTitoStretchPermission), missileStretchHeight_W[] (global SCRAM array) = stretch missile heights (via PAG_SetRoboTitoStretchPermission), rowYPosition, rowCounter (global) = calculation temporaries
          rem Called Routines: AddVelocitySubpixelY (bank13) - adds gravity to vertical velocity, ConvertPlayerXToPlayfieldColumn (bank13) - converts player X to playfield column, DivideByPfrowheight - divides Y by row height, PAG_SetRoboTitoStretchPermission - sets RoboTito stretch permission on landing
          rem Constraints: Frooty (8) and Dragon of Storms (2) skip gravity entirely. RoboTito (13) skips gravity when latched to ceiling
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
          rem Note: Vertical velocity is not persistent - we will track it
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
          gosub AddVelocitySubpixelY bank13
          let PAG_playfieldColumn = temp2
          rem Restore playfieldColumn
          
          rem Apply terminal velocity cap (prevents infinite
          rem   acceleration)
          rem Check if velocity exceeds terminal velocity (positive =
          if playerVelocityY[PAG_playerIndex] > TerminalVelocity then let playerVelocityY[PAG_playerIndex] = TerminalVelocity : let playerVelocityYL[PAG_playerIndex] = 0 : rem downward)
          
          rem Check playfield collision for ground detection (downward)
          rem Convert player X position to playfield column (0-31)
          let temp1 = PAG_playerIndex : rem Use shared coordinate conversion subroutine
          gosub ConvertPlayerXToPlayfieldColumn bank13
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
          rem Set RoboTito stretch permission on landing (allows stretching again)
          rem Input: PAGSRTSP_playerIndex (temp1) = player index (0-3), roboTitoCanStretch_R (global SCRAM) = stretch permission flags, BitMask[] (global data table) = bit masks
          rem Output: roboTitoCanStretch_W (global SCRAM) = stretch permission flags updated, missileStretchHeight_W[] (global SCRAM array) = stretch missile height cleared
          rem Mutates: temp1-temp3 (used for calculations), roboTitoCanStretch_W (global SCRAM) = stretch permission flags, missileStretchHeight_W[] (global SCRAM array) = stretch missile heights
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
          rem Updates recovery frames and applies velocity decay during hitstun for all players
          rem Input: playerRecoveryFrames[] (global array) = recovery frame counts, playerVelocityX[], playerVelocityXL[] (global arrays) = horizontal velocity, playerState[] (global array) = player states, controllerStatus (global) = controller state, selectedChar3_R, selectedChar4_R (global SCRAM) = player 3/4 selections, PlayerStateBitRecovery (global constant) = recovery flag bit
          rem Output: Recovery frames decremented, recovery flag synchronized, velocity decayed during recovery
          rem Mutates: temp1 (used for player index), playerRecoveryFrames[] (global array) = recovery frame counts, playerState[] (global array) = player states (recovery flag bit 3), playerVelocityX[], playerVelocityXL[] (global arrays) = horizontal velocity (decayed)
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

