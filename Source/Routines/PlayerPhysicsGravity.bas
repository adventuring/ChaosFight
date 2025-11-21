          rem ChaosFight - Source/Routines/PlayerPhysicsGravity.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Disable smart branching optimization to prevent label mismatch errors
          rem smartbranching off

PhysicsApplyGravity
          asm
PhysicsApplyGravity

end
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
          rem   playerCharacter[] - Player 3/4 selections
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
          rem state, playerCharacter[] (global array) =
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
          rem Called Routines: AddVelocitySubpixelY (bank8) - adds
          rem gravity to vertical velocity,
          rem CCJ_ConvertPlayerXToPlayfieldColumn (bank13) - converts player
          rem X to playfield column, Y divided by 16 (pfrowheight is always 16)
          rem row height, PAG_SetRoboTitoStretchPermission - sets
          rem RoboTito stretch permission on landing
          rem
          rem Constraints: Frooty (8) and Dragon of Storms (2) skip
          rem gravity entirely. RoboTito (13) skips gravity when latched
          rem to ceiling
          let temp1 = 0
          rem Loop through all players (0-3)
GravityLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem Quadtari)
          if temp1 >= 2 then goto GravityPlayerCheck
          goto GravityCheckCharacter
GravityPlayerCheck
          rem Players 0-1 always active
          if (controllerStatus & SetQuadtariDetected) = 0 then goto GravityNextPlayer
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto GravityNextPlayer
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto GravityNextPlayer

GravityCheckCharacter
          let temp6 = playerCharacter[temp1]

          rem Skip gravity for characters that do not have it
          rem Frooty (8): Permanent flight, no gravity
          if temp6 = CharacterFrooty then goto GravityNextPlayer
          rem Dragon of Storms (2): Permanent flight, no gravity
          rem (hovering/flying like Frooty)
          if temp6 = CharacterDragonOfStorms then goto GravityNextPlayer

          rem RoboTito (13): Skip gravity when latched to ceiling
          if temp6 = CharacterRoboTito && (characterStateFlags_R[temp1] & 1) then goto GravityNextPlayer

          rem If NOT jumping, skip gravity (player is on ground)

          if (playerState[temp1] & PlayerStateBitJumping) = 0 then goto GravityNextPlayer

          rem Vertical velocity is persistently tracked using playerVelocityY[]
          rem and playerVelocityYL[] arrays (8.8 fixed-point format).
          rem Gravity acceleration is applied to the stored velocity each frame.

          rem Determine gravity acceleration rate based on character
          rem   (8.8 fixed-point subpixel)
          rem Uses tunable constants from Constants.bas for easy
          let gravityRate_W = GravityNormal
          rem   adjustment
          rem Default gravity acceleration (normal rate)
          if temp6 = CharacterHarpy then let gravityRate_W = GravityReduced
          rem Harpy: reduced gravity rate

          rem Apply gravity acceleration to velocity subpixel part
          rem Use optimized inline addition instead of subroutine call
          let subpixelAccumulator = playerVelocityYL[temp1] + gravityRate_R
          let playerVelocityYL[temp1] = temp2
          if temp3 > 0 then let playerVelocityY[temp1] = playerVelocityY[temp1] + 1

          rem Apply terminal velocity cap (prevents infinite
          rem   acceleration)
          rem Check if velocity exceeds terminal velocity (positive =
          rem downward)
          if playerVelocityY[temp1] > TerminalVelocity then let playerVelocityY[temp1] = TerminalVelocity : let playerVelocityYL[temp1] = 0

          rem Check playfield collision for ground detection (downward)
          rem Convert player X position to playfield column (0-31)
          rem Use shared coordinate conversion subroutine
          gosub CCJ_ConvertPlayerXToPlayfieldColumn bank13
          let temp6 = temp2
          rem Save playfield column (temp2 will be overwritten)

          rem Calculate row where player feet are (bottom of sprite)
          let temp3 = playerY[temp1] + PlayerSpriteHeight
          rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let temp2 = temp3
          rem Divide by pfrowheight (16) using 4 right shifts
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp4 = temp2
          rem feetRow = row where feet are

          rem Check if there is a playfield pixel in the row below the
          rem   feet
          rem If feet are in row N, check row N+1 for ground
          if temp4 >= pfrows then goto GravityNextPlayer
          rem Feet are at or below bottom of playfield, continue falling

          let temp5 = temp4 + 1
          rem rowBelow = row below feet
          if temp5 >= pfrows then goto GravityCheckBottom
          rem Beyond playfield bounds, check if at bottom

          rem Check if playfield pixel exists in row below feet
          let temp3 = 0
          rem Track pfread result (1 = ground pixel set)
          let temp4 = temp1
          let temp1 = temp6
          let temp2 = temp5
          gosub PlayfieldRead bank16
          if temp1 then let temp3 = 1
          let temp1 = temp4
          if temp3 = 0 then goto GravityNextPlayer
          rem Ground detected! Stop falling and clamp position to ground
          let playerVelocityY[temp1] = 0
          rem Zero Y velocity (stop falling)
          let playerVelocityYL[temp1] = 0

          rem Calculate Y position for top of ground row using repeated
          rem   addition
          let rowYPosition_W = 0
          rem Loop to add pfrowheight to rowYPosition, rowBelow times
          let rowCounter_W = temp5
          if rowCounter_R = 0 then goto GravityRowCalcDone
GravityRowCalcLoop
          let rowYPosition_W = rowYPosition_R + pfrowheight
          let rowCounter_W = rowCounter_R - 1
          if rowCounter_R > 0 then goto GravityRowCalcLoop
GravityRowCalcDone
          rem rowYPosition now contains rowBelow * pfrowheight (Y
          rem   position of top of ground row)
          let playerY[temp1] = rowYPosition_R - PlayerSpriteHeight
          rem Clamp playerY so feet are at top of ground row
          let playerSubpixelY_W[temp1] = playerY[temp1]
          rem Also sync subpixel position
          let playerSubpixelY_WL[temp1] = 0

          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitJumping)
          rem Clear jumping flag (bit 2, not bit 4 - fix bit number)
          rem Clear bit 2 (jumping flag)

          rem Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
          if temp6 = 3 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 8)

          rem If RoboTito, set stretch permission on landing

          if temp6 = CharacterRoboTito then goto PAG_SetRoboTitoStretchPermission
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
          let temp2 = roboTitoCanStretch_R
          rem Set stretch permission bit for this player using BitMask array lookup
          let temp3 = BitMask[temp1]
          rem Load current flags
          let temp2 = temp2 | temp3
          rem Get bit mask: 1, 2, 4, 8 for players 0, 1, 2, 3
          let roboTitoCanStretch_W = temp2
          rem Set bit for this player
          rem Store updated permission flags
          let missileStretchHeight_W[temp1] = 0
          rem Clear stretch missile height on landing (not stretching)
          return

GravityCheckBottom
          rem At bottom of playfield - treat as ground if feet are at
          rem bottom row
          if temp4 < pfrows - 1 then goto GravityNextPlayer
          rem Not at bottom row yet

          rem Bottom row is always ground - clamp to bottom
          rem Calculate (pfrows - 1) * pfrowheight using repeated
          let rowYPosition_W = 0
          rem   addition
          let rowCounter_W = pfrows - 1
          if rowCounter_R = 0 then goto GravityBottomCalcDone
GravityBottomCalcLoop
          let rowYPosition_W = rowYPosition_R + pfrowheight
          let rowCounter_W = rowCounter_R - 1
          if rowCounter_R > 0 then goto GravityBottomCalcLoop
GravityBottomCalcDone
          let playerY[temp1] = rowYPosition_R - PlayerSpriteHeight
          let playerState[temp1] = playerState[temp1] & ($FF ^ 4)
          rem Clear Zoe’s double-jump used flag on landing (bit 3 in characterStateFlags for this player)
          if temp6 = 3 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 8)

          rem If RoboTito, set stretch permission on landing at bottom

          if temp6 = CharacterRoboTito then goto PAG_SetRoboTitoStretchPermission

GravityNextPlayer
          let temp1 = temp1 + 1
          rem Move to next player
          if temp1 < 4 then goto GravityLoop

          return

