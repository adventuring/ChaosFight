          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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
          rem (global) = controller state, playerCharacter[] (global array) = player selections,
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
          rem < PlayerLeftWrapThreshold wraps to PlayerRightEdge, X >
          rem PlayerRightWrapThreshold wraps to PlayerLeftEdge). Vertical
          rem boundaries clamped (Y < 20 clamped to 20, Y > 80 clamped
          rem to 80)
          let temp1 = 0
          rem Loop through all players (0-3)
BoundaryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem Quadtari)
          if temp1 < 2 then BoundaryCheckBounds
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto BoundaryNextPlayer
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto BoundaryNextPlayer
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto BoundaryNextPlayer

BoundaryCheckBounds
          rem All arenas support horizontal wrap-around for players
          rem   (except where walls stop it)
          rem Handle RandomArena by checking selected arena
          let temp3 = selectedArena_R
          rem Handle RandomArena (use proper random number generator)
          if temp3 = RandomArena then temp3 = rand : temp3 = temp3 & 15

          rem All arenas: wrap horizontally (walls may block wrap-around)
          rem Horizontal wrap driven by PlayerLeftWrapThreshold and PlayerRightWrapThreshold
          if playerX[temp1] < PlayerLeftWrapThreshold then goto WrapLeft
          if playerX[temp1] > PlayerRightWrapThreshold then goto WrapRight
          goto BoundaryYCheck

WrapLeft
          let playerX[temp1] = PlayerRightEdge
          let playerSubpixelX_W[temp1] = PlayerRightEdge
          let playerSubpixelX_WL[temp1] = 0
          goto BoundaryYCheck

WrapRight
          let playerX[temp1] = PlayerLeftEdge
          let playerSubpixelX_W[temp1] = PlayerLeftEdge
          let playerSubpixelX_WL[temp1] = 0
          goto BoundaryYCheck

BoundaryYCheck
          rem Y position: clamp to screen boundaries (no vertical wrap)
          rem Top boundary: clamp to prevent going above screen
          if playerY[temp1] < 20 then goto ClampTop
          rem Bottom boundary: clamp to prevent going below screen
          if playerY[temp1] > 80 then goto ClampBottom
          goto BoundaryNextPlayer

ClampTop
          let playerY[temp1] = 20
          let playerSubpixelY_W[temp1] = 20
          let playerSubpixelY_WL[temp1] = 0
          let playerVelocityY[temp1] = 0
          let playerVelocityYL[temp1] = 0
          goto BoundaryNextPlayer

ClampBottom
          let playerY[temp1] = 80
          let playerSubpixelY_W[temp1] = 80
          let playerSubpixelY_WL[temp1] = 0
          let playerVelocityY[temp1] = 0
          let playerVelocityYL[temp1] = 0

BoundaryNextPlayer
          let temp1 = temp1 + 1
          rem Move to next player
          if temp1 < 4 then goto BoundaryLoop

          return          rem ChaosFight - Source/Routines/PlayerPhysicsGravity.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Disable smart branching optimization to prevent label mismatch errors
          rem smartbranching off

PhysicsApplyGravity
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
          rem Called Routines: AddVelocitySubpixelY (bank13) - adds
          rem gravity to vertical velocity,
          rem ConvertPlayerXToPlayfieldColumn (bank13) - converts player
          rem X to playfield column, DivideByPfrowheight - divides Y by
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
          if temp1 < 2 then GravityCheckCharacter
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto GravityNextPlayer
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
          
          if !(playerState[temp1] & PlayerStateBitJumping) then goto GravityNextPlayer
          
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
          let gravityRate_W = GravityNormal
          rem   adjustment
          rem Default gravity acceleration (normal rate)
          if temp6 = CharacterHarpy then let gravityRate_W = GravityReduced
          rem Harpy: reduced gravity rate
          
          rem Apply gravity acceleration to velocity subpixel part
          rem Use optimized inline addition instead of subroutine call
          let temp2.temp3 = playerVelocityYL[temp1] + gravityRate_R
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
          gosub ConvertPlayerXToPlayfieldColumn bank8
          
          rem Calculate row where player feet are (bottom of sprite)
          let temp3 = playerY[temp1] + PlayerSpriteHeight
          rem Feet are at playerY + PlayerSpriteHeight (16 pixels)
          let temp2 = temp3
          rem Divide by pfrowheight using helper
          gosub DivideByPfrowheight bank7
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
          if pfread(temp2, temp5) then temp3 = 1
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
          
          rem If RoboTito, set stretch permission on landing
          
          if temp6 = CharacterRoboTito then PAG_SetRoboTitoStretchPermission
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
          let playerState[temp1] = playerState[temp1] & NOT 4
          
          rem If RoboTito, set stretch permission on landing at bottom
          
          if temp6 = CharacterRoboTito then goto PAG_SetRoboTitoStretchPermission
          
GravityNextPlayer
          let temp1 = temp1 + 1
          rem Move to next player
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
          rem = controller state, playerCharacter[] selections
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
          let temp1 = 0
          rem Loop through all players (0-3)
MomentumRecoveryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem Quadtari)
          if temp1 < 2 then MomentumRecoveryProcess
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto MomentumRecoveryNext
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto MomentumRecoveryNext
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto MomentumRecoveryNext
          
MomentumRecoveryProcess
          rem Decrement recovery frames (velocity is applied by
          rem UpdatePlayerMovement)
          if playerRecoveryFrames[temp1] > 0 then let playerRecoveryFrames[temp1] = playerRecoveryFrames[temp1] - 1
          
          rem Synchronize playerState bit 3 with recovery frames
          
          if playerRecoveryFrames[temp1] > 0 then let playerState[temp1] = playerState[temp1] | PlayerStateBitRecovery
          rem Set bit 3 (recovery flag) when recovery frames > 0
          if ! playerRecoveryFrames[temp1] then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitRecovery)
          rem Clear bit 3 (recovery flag) when recovery frames = 0
          
          rem Decay velocity if recovery frames active
          
          if ! playerRecoveryFrames[temp1] then goto MomentumRecoveryNext
          rem Velocity decay during recovery (knockback slows down over
          rem time)
          if playerVelocityX[temp1] <= 0 then MomentumRecoveryDecayNegative
          let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          rem Positive velocity: decay by 1
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          goto MomentumRecoveryNext
MomentumRecoveryDecayNegative
          if playerVelocityX[temp1] >= 0 then goto MomentumRecoveryNext
          rem Negative velocity: decay by 1 (add 1 to make less
          let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          rem   negative)
          rem Also decay subpixel if integer velocity is zero
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          
MomentumRecoveryNext
          let temp1 = temp1 + 1
          rem Next player
          if temp1 < 4 then goto MomentumRecoveryLoop

          rem Re-enable smart branching optimization
          rem smartbranching on

          return

          rem ChaosFight - Source/Routines/MovementSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdatePlayerMovement
          rem 8.8 fixed-point movement system using batariBASIC built-in
          rem   support
          rem Movement System Routines
          rem All integers are 8-bit. Position consists of:
          rem - playerX/Y[0-3] = Integer part (8-bit, already exists in
          rem   var0-var7)
          rem - playerSubpixelX/Y[0-3] = High byte of 8.8 fixed-point
          rem   position (var/w array)
          rem - playerSubpixelX/YL[0-3] = Low byte of 8.8 fixed-point
          rem   position (fractional)
          rem Velocity consists of:
          rem - playerVelocityX[0-3] = High byte of 8.8 fixed-point X
          rem   velocity (var20-var23, ZPRAM)
          rem - playerVelocityXL[0-3] = Low byte of 8.8 fixed-point X
          rem
          rem   velocity (var24-var27, ZPRAM)
          rem - playerVelocityY[0-3] = High byte of 8.8 fixed-point Y
          rem   velocity (var28-var31, ZPRAM)
          rem - playerVelocityYL[0-3] = Low byte of 8.8 fixed-point Y
          rem   velocity (var32-var35, ZPRAM)
          rem NOTE: batariBASIC automatically handles carry operations
          rem   for 8.8 fixed-point arithmetic.
          rem When you add two 8.8 values, the compiler generates code
          rem   that:
          rem   1. Adds the low bytes (with carry)
          rem 2. Adds the high bytes (plus carry from low byte addition)
          rem This eliminates the need for manual carry checking and
          rem   propagation.
          rem Update all active players each frame (integer + subpixel positions).
          rem Input: currentPlayer (global scratch), QuadtariDetected,
          rem        playerHealth[], playerSubpixelX/Y (SCRAM arrays),
          rem        playerVelocityX/Y, playerX[], playerY[]
          rem Output: Player positions updated for every active player
          rem Mutates: currentPlayer, player positions (via UpdatePlayerMovementSingle)
          rem Called Routines: UpdatePlayerMovementSingle
          rem Constraints: Must be colocated with UpdatePlayerMovementQuadtariSkip (goto target)
          for currentPlayer = 0 to 1
          rem Update movement for each active player
              gosub UpdatePlayerMovementSingle
          next
          rem Players 2-3 only if Quadtari detected
          if QuadtariDetected = 0 then goto UpdatePlayerMovementQuadtariSkip
          for currentPlayer = 2 to 3
              gosub UpdatePlayerMovementSingle
          next
UpdatePlayerMovementQuadtariSkip
          return
UpdatePlayerMovementSingle
          rem Move one player using 8.8 fixed-point velocity integration.
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerHealth[], playerSubpixelX/Y (SCRAM),
          rem        playerVelocityX/Y, playerX[], playerY[]
          rem Output: playerX[]/playerY[] updated (integer + subpixel)
          rem Mutates: temp2-temp4, playerSubpixelX/Y, playerX[], playerY[]
          rem Constraints: Must be colocated with XCarry/XNoCarry/YCarry/YNoCarry
          rem Notes: temp2-temp4 are clobbered; caller must not reuse them afterward.
          rem 16-bit accumulator for proper carry detection
          rem Skip if player is eliminated
          if playerHealth[currentPlayer] = 0 then return
          
          rem Apply X Velocity To X Position (8.8 fixed-point)
          rem Use batariBASIC’s built-in 16-bit addition for carry detection
          let temp2.temp3 = playerSubpixelX_RL[currentPlayer] + playerVelocityXL[currentPlayer]
          let playerSubpixelX_WL[currentPlayer] = temp2
          if temp3 > 0 then let playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + 1

          rem Apply integer velocity component
          let playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + playerVelocityX[currentPlayer]

          rem Sync integer position for rendering
          let playerX[currentPlayer] = playerSubpixelX_R[currentPlayer]
          
          rem Apply Y Velocity To Y Position (8.8 fixed-point)
          rem Use batariBASIC’s built-in 16-bit addition for carry detection
          let temp2.temp3 = playerSubpixelY_RL[currentPlayer] + playerVelocityYL[currentPlayer]
          let playerSubpixelY_WL[currentPlayer] = temp2
          if temp3 > 0 then let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + 1

          rem Apply integer velocity component
          let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + playerVelocityY[currentPlayer]

          rem Sync integer position for rendering
          let playerY[currentPlayer] = playerSubpixelY_R[currentPlayer]
          
          return

SetPlayerVelocity
          rem Set player velocity (integer component, reset subpixels).
          rem Input: temp1 = player index (0-3), temp2 = X velocity, temp3 = Y velocity
          rem Output: playerVelocityX/Y updated (low bytes cleared)
          rem Mutates: playerVelocityX[], playerVelocityXL[], playerVelocityY[], playerVelocityYL[]
          rem Constraints: None
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          let playerVelocityY[temp1] = temp3
          let playerVelocityYL[temp1] = 0
          return

SetPlayerPosition
          rem Set player position (integer coordinates, subpixels cleared).
          rem Input: temp1 = player index (0-3), temp2 = X position, temp3 = Y position
          rem Output: playerX/Y and subpixel buffers updated
          rem Mutates: playerX[], playerY[], playerSubpixelX_W/WL[], playerSubpixelY_W/WL[]
          rem Constraints: None
          let playerX[temp1] = temp2
          let playerSubpixelX_W[temp1] = temp2
          rem SCRAM write to playerSubpixelX_W
          let playerSubpixelX_WL[temp1] = 0
          let playerY[temp1] = temp3
          let playerSubpixelY_W[temp1] = temp3
          rem SCRAM write to playerSubpixelY_W
          let playerSubpixelY_WL[temp1] = 0
          return

GetPlayerPosition
          rem Get player position (integer components only).
          rem Input: currentPlayer (global) = player index (0-3)
          rem Output: temp2 = X position, temp3 = Y position
          rem Mutates: temp2, temp3
          rem Constraints: Callers should consume the values immediately; temps are volatile.
          let temp2 = playerX[currentPlayer]
          let temp3 = playerY[currentPlayer]
          return

GetPlayerVelocity
          rem Get player velocity (integer components only).
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerVelocityX[], playerVelocityY[] (global arrays)
          rem Output: temp2 = X velocity, temp3 = Y velocity
          rem Mutates: temp2, temp3
          rem Constraints: Callers should use the values immediately; temps are volatile.
          let temp2 = playerVelocityX[currentPlayer]
          let temp3 = playerVelocityY[currentPlayer]
          return

MovementApplyGravity
          rem Apply gravity to player velocity (integer component only).
          rem Input: temp1 = player index (0-3), temp2 = gravity strength (integer, positive downward)
          rem Output: playerVelocityY[] incremented by gravity strength
          rem Mutates: playerVelocityY[]
          rem Constraints: For subpixel gravity, call AddVelocitySubpixelY separately
          let playerVelocityY[temp1] = playerVelocityY[temp1] + temp2
          return

AddVelocitySubpixelY
          rem Add fractional gravity to Y velocity (subpixel component).
          rem Input: temp1 = player index (0-3), temp2 = subpixel amount (0-255)
          rem Output: playerVelocityYL[] incremented; playerVelocityY[] increments on carry
          rem Mutates: temp2-temp4, playerVelocityY[], playerVelocityYL[]
          rem Constraints: Uses 16-bit accumulator; carry promotes to integer component
          rem Save subpixel amount before using temp2 for accumulator
          let temp4 = temp2
          rem 16-bit accumulator for proper carry detection
          let temp2.temp3 = playerVelocityYL[temp1] + temp4
          rem Use saved amount in accumulator
          if temp3 > 0 then VelocityYCarry
          rem No carry: temp3 = 0, use low byte directly
          let playerVelocityYL[temp1] = temp2
          return
VelocityYCarry
          rem Helper: Handles carry from subpixel to integer part
          rem
          rem Input: temp2 = wrapped low byte, temp1 = player
          rem index, playerVelocityY[] (global array) = Y velocities
          rem
          rem Output: Subpixel part set, integer part incremented
          rem
          rem Mutates: playerVelocityYL[] (global array) = Y velocity
          rem subpixel (set), playerVelocityY[] (global array) = Y
          rem velocity integer (incremented)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for AddVelocitySubpixelY,
          rem only called when carry detected
          let playerVelocityYL[temp1] = temp2
          rem Carry detected: temp3 > 0, extract wrapped low byte
          let playerVelocityY[temp1] = playerVelocityY[temp1] + 1
          return

ApplyFriction
          rem Apply friction to player X velocity (simple decrement/increment).
          rem Input: temp1 = player index (0-3), playerVelocityX[], playerVelocityXL[]
          rem Output: X velocity reduced by 1 toward zero; subpixel cleared when velocity hits zero
          rem Mutates: playerVelocityX[], playerVelocityXL[]
          rem
          rem Constraints: Simple decrement approach for 8-bit CPU.
          rem Positive velocities (>0 and not negative) decremented,
          rem negative velocities (≥128 in two’s complement) incremented
          if playerVelocityX[temp1] > 0 && !(playerVelocityX[temp1] & $80) then let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          rem Check for negative velocity using twos complement (values
          rem ≥ 128 are negative)
          if playerVelocityX[temp1] & $80 then let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          rem Also zero subpixel if velocity reaches zero
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          return

CheckPlayerCollision
          rem
          rem Collision Detection With Subpixel Precision
          rem Check collision between two players using integer
          rem   positions
          rem
          rem Input: temp1 = player 1 index → temp1
          rem        temp2 = player 2 index → temp2
          rem
          rem Output: temp3 = 1 if collision, 0 if not →
          rem temp3
          rem NOTE: Uses integer positions only (subpixel ignored for
          rem   collision)
          rem
          rem MUTATES:
          rem   temp3 = temp3 (return value: 1 if collision, 0 if not)
          rem   temp4-temp13 = Used internally for calculations
          rem WARNING: Callers should read temp3 immediately; helper mutates temps for calculations.
          rem
          rem Input: temp1 = player 1 index (0-3), temp2 = player 2
          rem index (0-3), playerX[], playerY[] (global arrays) = player
          rem positions, playerCharacter[] (global array) = character types,
          rem CharacterHeights[] (global data table) = character heights
          rem
          rem Output: temp3 = 1 if collision, 0 if not
          rem
          rem Mutates: temp3-temp6 (used for calculations, temp4-5
          rem reused after X/Y checks)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Uses integer positions only (subpixel ignored
          rem for collision). Checks X collision (16 pixel width) and Y
          rem collision (using CharacterHeights table). WARNING: temp3 is mutated during the routine; callers must read it immediately.
          rem Uses temp1-temp6 (temp4-5 reused after X/Y checks)

          rem Load player X positions into temporaries
          let temp4 = playerX[temp1]
          let temp5 = playerX[temp2]

          rem Calculate absolute X distance between players
          rem Primary holds player1 X initially
          if temp4 >= temp5 then CalcXDistanceRight
          let temp6 = temp5 - temp4
          goto XDistanceDone
CalcXDistanceRight
          let temp6 = temp4 - temp5
XDistanceDone
          if temp6 >= PlayerSpriteWidth then NoCollision

          rem Load player Y positions (reuse temporaries)
          let temp4 = playerY[temp1]
          let temp5 = playerY[temp2]

          rem Fetch character half-height values using shared SCRAM scratch variables
          let characterIndex_W = playerCharacter[temp1]
          let characterHeight_W = CharacterHeights[characterIndex_R]
          let halfHeight1_W = characterHeight_R / 2

          let characterIndex_W = playerCharacter[temp2]
          let characterHeight_W = CharacterHeights[characterIndex_R]
          let halfHeight2_W = characterHeight_R / 2

          rem Compute absolute Y distance between player centers
          if temp4 >= temp5 then CalcYDistanceDown
          let temp6 = temp5 - temp4
          goto YDistanceDone
CalcYDistanceDown
          let temp6 = temp4 - temp5
YDistanceDone
          let totalHeight_W = halfHeight1_R + halfHeight2_R
          if temp6 >= totalHeight_R then NoCollision

          let temp3 = 1
          rem Collision detected
          return

NoCollision
          let temp3 = 0
          return
ConstrainToScreen
          rem Clamp player position to on-screen bounds and clear subpixels at edges.
          rem Input: temp1 = player index (0-3)
          rem Output: playerX/Y constrained to PlayerLeftEdge..PlayerRightEdge (X) and 20-80 (Y); subpixels zeroed at clamps
          rem Mutates: playerX[], playerY[], playerSubpixelX_W/WL[], playerSubpixelY_W/WL[]
          rem Constraints: X bounds PlayerLeftEdge..PlayerRightEdge, Y bounds 20-80
          rem Constrain X position using screen boundary constants
          rem SCRAM write to playerSubpixelX_W
          if playerX[temp1] < PlayerLeftEdge then let playerX[temp1] = PlayerLeftEdge
          if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_W[temp1] = PlayerLeftEdge
          if playerX[temp1] < PlayerLeftEdge then let playerSubpixelX_WL[temp1] = 0
          if playerX[temp1] > PlayerRightEdge then let playerX[temp1] = PlayerRightEdge
          if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_W[temp1] = PlayerRightEdge
          if playerX[temp1] > PlayerRightEdge then let playerSubpixelX_WL[temp1] = 0
          
          rem Constrain Y position (20 to 80 for screen bounds)
          rem SCRAM write to playerSubpixelY_W
          if playerY[temp1] < 20 then let playerY[temp1] = 20
          if playerY[temp1] < 20 then let playerSubpixelY_W[temp1] = 20
          if playerY[temp1] < 20 then let playerSubpixelY_WL[temp1] = 0
          if playerY[temp1] > 80 then let playerY[temp1] = 80
          if playerY[temp1] > 80 then let playerSubpixelY_W[temp1] = 80
          if playerY[temp1] > 80 then let playerSubpixelY_WL[temp1] = 0
          
          return

          rem
          rem Initialization

InitializeMovementSystem
          rem Initialize movement system for all players
          rem Called at game start to set up initial positions and
          rem   velocities
          rem Initialize movement system for all players (called at game
          rem start to set up initial positions and velocities)
          rem
          rem Input: None (initializes all players 0-3)
          rem
          rem Output: All players initialized to center of screen (X=80,
          rem Y=100) with zero velocities
          rem
          rem Mutates: temp1-temp3 (used for calculations), playerX[],
          rem playerY[] (global arrays) = integer positions (set to 80,
          rem 100), playerSubpixelX_W[], playerSubpixelX_WL[],
          rem playerSubpixelY_W[], playerSubpixelY_WL[] (global SCRAM
          rem arrays) = subpixel positions (set to 80, 100, low bytes
          rem zeroed), playerVelocityX[], playerVelocityXL[],
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem velocities (all set to 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Initializes all 4 players to same position
          rem (center of screen). All velocities set to zero
          rem Initialize all players to center of screen - inlined for
          let temp2 = 80
          rem   performance
          let temp3 = 100
          let playerX[0] = temp2
          rem Player 0
          let playerSubpixelX_W[0] = temp2
          let playerSubpixelX_WL[0] = 0
          let playerY[0] = temp3
          let playerSubpixelY_W[0] = temp3
          let playerSubpixelY_WL[0] = 0
          let playerX[1] = temp2
          rem Player 1
          let playerSubpixelX_W[1] = temp2
          let playerSubpixelX_WL[1] = 0
          let playerY[1] = temp3
          let playerSubpixelY_W[1] = temp3
          let playerSubpixelY_WL[1] = 0
          let playerX[2] = temp2
          rem Player 2
          let playerSubpixelX_W[2] = temp2
          let playerSubpixelX_WL[2] = 0
          let playerY[2] = temp3
          let playerSubpixelY_W[2] = temp3
          let playerSubpixelY_WL[2] = 0
          let playerX[3] = temp2
          rem Player 3
          let playerSubpixelX_W[3] = temp2
          let playerSubpixelX_WL[3] = 0
          let playerY[3] = temp3
          let playerSubpixelY_W[3] = temp3
          let playerSubpixelY_WL[3] = 0
          
          rem Initialize velocities to zero - inlined for performance
          let playerVelocityX[0] = 0
          rem Player 0
          let playerVelocityXL[0] = 0
          let playerVelocityY[0] = 0
          let playerVelocityYL[0] = 0
          let playerVelocityX[1] = 0
          rem Player 1
          let playerVelocityXL[1] = 0
          let playerVelocityY[1] = 0
          let playerVelocityYL[1] = 0
          let playerVelocityX[2] = 0
          rem Player 2
          let playerVelocityXL[2] = 0
          let playerVelocityY[2] = 0
          let playerVelocityYL[2] = 0
          let playerVelocityX[3] = 0
          rem Player 3
          let playerVelocityXL[3] = 0
          let playerVelocityY[3] = 0
          let playerVelocityYL[3] = 0
          return
          

          let playerVelocityYL[2] = 0
          let playerVelocityX[3] = 0
          rem Player 3
          let playerVelocityXL[3] = 0
          let playerVelocityY[3] = 0
          let playerVelocityYL[3] = 0
          return
          
