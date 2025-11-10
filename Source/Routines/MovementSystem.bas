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
          
          rem
          rem Apply X Velocity To X Position
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem Use 16-bit accumulator to detect carry properly
          rem temp2 = low byte, temp3 = high byte (carry flag)
          let temp2.temp3 = playerSubpixelX_RL[currentPlayer] + playerVelocityXL[currentPlayer]
          if temp3 > 0 then XCarry
          rem No carry: temp3 = 0, use low byte directly
          let playerSubpixelX_WL[currentPlayer] = temp2
          goto XNoCarry
XCarry
          let playerSubpixelX_WL[currentPlayer] = temp2
          rem Carry detected: temp3 > 0, extract wrapped low byte
          rem SCRAM RMW: playerSubpixelX_R → playerSubpixelX_W
          let temp4 = playerSubpixelX_R[currentPlayer]
          let temp4 = temp4 + 1
          let playerSubpixelX_W[currentPlayer] = temp4
XNoCarry
          rem SCRAM RMW: playerSubpixelX_R → playerSubpixelX_W (apply integer velocity)
          let temp4 = playerSubpixelX_R[currentPlayer]
          let temp4 = temp4 + playerVelocityX[currentPlayer]
          let playerSubpixelX_W[currentPlayer] = temp4
          
          rem Sync integer position for rendering (high byte is the integer part)
          let playerX[currentPlayer] = playerSubpixelX_R[currentPlayer]
          
          rem
          rem Apply Y Velocity To Y Position
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem Use 16-bit accumulator to detect carry properly
          rem temp2 = low byte, temp3 = high byte (carry flag)
          let temp2.temp3 = playerSubpixelY_RL[currentPlayer] + playerVelocityYL[currentPlayer]
          if temp3 > 0 then YCarry
          rem No carry: temp3 = 0, use low byte directly
          let playerSubpixelY_WL[currentPlayer] = temp2
          goto YNoCarry
YCarry
          let playerSubpixelY_WL[currentPlayer] = temp2
          rem Carry detected: temp3 > 0, extract wrapped low byte
          rem SCRAM RMW: playerSubpixelY_R → playerSubpixelY_W
          let temp4 = playerSubpixelY_R[currentPlayer]
          let temp4 = temp4 + 1
          let playerSubpixelY_W[currentPlayer] = temp4
YNoCarry
          rem SCRAM RMW: playerSubpixelY_R → playerSubpixelY_W (apply integer velocity)
          let temp4 = playerSubpixelY_R[currentPlayer]
          let temp4 = temp4 + playerVelocityY[currentPlayer]
          let playerSubpixelY_W[currentPlayer] = temp4
          
          rem Sync integer position for rendering (high byte is the integer part)
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
          
