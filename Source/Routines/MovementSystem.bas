UpdatePlayerMovement
          rem ChaosFight - Source/Routines/MovementSystem.bas
          rem
          rem Copyright © 2025 Interworldly Adventuring, LLC.
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
          rem Update player movement for all active players
          rem Called every frame to update subpixel positions
          rem Update player movement for all active players
          rem
          rem Input: currentPlayer (global) = player index (set inline)
          rem        QuadtariDetected (global) = Quadtari detection flag
          rem        playerHealth[] (global array) = player health
          rem        values
          rem        playerSubpixelX_W[], playerSubpixelX_WL[],
          rem        playerSubpixelY_W[], playerSubpixelY_WL[] (global
          rem        SCRAM arrays) = subpixel positions
          rem        playerVelocityX[], playerVelocityXL[],
          rem        playerVelocityY[], playerVelocityYL[] (global
          rem        arrays) = velocities
          rem        playerX[], playerY[] (global arrays) = integer
          rem        positions
          rem
          rem Output: Player positions updated for all active players
          rem
          rem Mutates: currentPlayer (set to 0-3), player positions and
          rem subpixel positions (via UpdatePlayerMovementSingle)
          rem
          rem Called Routines: UpdatePlayerMovementSingle - updates
          rem movement for one player
          rem
          rem Constraints: Must be colocated with
          rem UpdatePlayerMovementQuadtariSkip (called via goto)
          rem              Called every frame to update subpixel
          rem              positions
          for currentPlayer = 0 to 1 : rem Update movement for each active player
              gosub UpdatePlayerMovementSingle
          next
          if QuadtariDetected = 0 then goto UpdatePlayerMovementQuadtariSkip : rem Players 2-3 only if Quadtari detected
          for currentPlayer = 2 to 3
              gosub UpdatePlayerMovementSingle
          next
UpdatePlayerMovementQuadtariSkip
          return
UpdatePlayerMovementSingle
          rem Skip Players 2-3 movement update (2-player mode only,
          rem label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with UpdatePlayerMovement
          rem
          rem Update movement for a specific player
          rem
          rem Input: currentPlayer = player index (0-3) (global
          rem variable)
          rem Applies velocity to position with subpixel precision
          rem batariBASIC automatically handles carry from fractional to
          rem   integer parts
          rem
          rem MUTATES:
          rem
          rem   temp2 = UPS_sum16 low byte (16-bit accumulator)
          rem   temp3 = UPS_sum16 high byte (16-bit accumulator)
          rem   temp4 = UPS_subpixelXRead (internal SCRAM
          rem   read-modify-write)
          rem WARNING: temp2, temp3, and temp4 are mutated during
          rem execution.
          rem   Do not use these temp variables after calling this
          rem   subroutine.
          rem
          rem EFFECTS:
          rem   Modifies playerX[], playerY[], playerSubpixelX_W[],
          rem   playerSubpixelY_W[]
          rem Update movement for a specific player (applies velocity to
          rem position with subpixel precision)
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerHealth[] (global array) = player health
          rem        values
          rem        playerSubpixelX_W[], playerSubpixelX_WL[],
          rem        playerSubpixelY_W[], playerSubpixelY_WL[] (global
          rem        SCRAM arrays) = subpixel positions
          rem        playerVelocityX[], playerVelocityXL[],
          rem        playerVelocityY[], playerVelocityYL[] (global
          rem        arrays) = velocities
          rem        playerX[], playerY[] (global arrays) = integer
          rem        positions
          rem
          rem Output: Player positions updated (integer and subpixel)
          rem
          rem Mutates: temp2, temp3, temp4 (used for calculations),
          rem playerSubpixelX_W[], playerSubpixelX_WL[],
          rem         playerSubpixelY_W[], playerSubpixelY_WL[],
          rem         playerX[], playerY[]
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with XCarry, XNoCarry,
          rem YCarry, YNoCarry (called via goto)
          rem              WARNING: temp2, temp3, and temp4 are mutated
          rem              during execution. Do not use these temp
          rem              variables after calling this subroutine.
          dim UPS_sum16 = temp2.temp3 : rem 16-bit accumulator for proper carry detection
          if playerHealth[currentPlayer] = 0 then return : rem Skip if player is eliminated
          
          rem
          rem Apply X Velocity To X Position
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem Use 16-bit accumulator to detect carry properly
          rem temp2 = low byte, temp3 = high byte (carry flag)
          let UPS_sum16 = playerSubpixelX_RL[currentPlayer] + playerVelocityXL[currentPlayer]
          if temp3 > 0 then XCarry
          rem No carry: temp3 = 0, use low byte directly
          let playerSubpixelX_WL[currentPlayer] = temp2
          goto XNoCarry
XCarry
          let playerSubpixelX_WL[currentPlayer] = temp2 : rem Carry detected: temp3 > 0, extract wrapped low byte
          rem SCRAM read-modify-write: Read from r049, modify, write to
          dim UPS_subpixelXRead = temp4 : rem   w049
          let UPS_subpixelXRead = playerSubpixelX_R[currentPlayer]
          let UPS_subpixelXRead = UPS_subpixelXRead + 1
          let playerSubpixelX_W[currentPlayer] = UPS_subpixelXRead
XNoCarry
          rem SCRAM read-modify-write: Read from r049, modify, write to
          dim UPS_subpixelXRead = temp4 : rem   w049
          let UPS_subpixelXRead = playerSubpixelX_R[currentPlayer]
          let UPS_subpixelXRead = UPS_subpixelXRead + playerVelocityX[currentPlayer]
          let playerSubpixelX_W[currentPlayer] = UPS_subpixelXRead
          
          rem Sync integer position for rendering (high byte is the
          let playerX[currentPlayer] = playerSubpixelX_R[currentPlayer] : rem   integer part)
          
          rem
          rem Apply Y Velocity To Y Position
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem Use 16-bit accumulator to detect carry properly
          rem temp2 = low byte, temp3 = high byte (carry flag)
          let UPS_sum16 = playerSubpixelY_RL[currentPlayer] + playerVelocityYL[currentPlayer]
          if temp3 > 0 then YCarry
          rem No carry: temp3 = 0, use low byte directly
          let playerSubpixelY_WL[currentPlayer] = temp2
          goto YNoCarry
YCarry
          let playerSubpixelY_WL[currentPlayer] = temp2 : rem Carry detected: temp3 > 0, extract wrapped low byte
          rem SCRAM read-modify-write: Read from r057, modify, write to
          dim UPS_subpixelYRead = temp4 : rem   w057
          let UPS_subpixelYRead = playerSubpixelY_R[currentPlayer]
          let UPS_subpixelYRead = UPS_subpixelYRead + 1
          let playerSubpixelY_W[currentPlayer] = UPS_subpixelYRead
YNoCarry
          rem SCRAM read-modify-write: Read from r057, modify, write to
          dim UPS_subpixelYRead = temp4 : rem   w057
          let UPS_subpixelYRead = playerSubpixelY_R[currentPlayer]
          let UPS_subpixelYRead = UPS_subpixelYRead + playerVelocityY[currentPlayer]
          let playerSubpixelY_W[currentPlayer] = UPS_subpixelYRead
          
          rem Sync integer position for rendering (high byte is the
          let playerY[currentPlayer] = playerSubpixelY_R[currentPlayer] : rem   integer part)
          
          return

SetPlayerVelocity
          rem Set player velocity (integer parts only, subpixel parts
          rem   set to 0)
          rem
          rem Input: temp1 = player index (0-3), temp2 = X velocity
          rem   (integer), temp3 = Y velocity (integer)
          rem Set player velocity (integer parts only, subpixel parts
          rem set to 0)
          rem
          rem Input: temp1 = player index (0-3), temp2 = X velocity
          rem (integer), temp3 = Y velocity (integer)
          rem        playerVelocityX[], playerVelocityXL[],
          rem        playerVelocityY[], playerVelocityYL[] (global
          rem        arrays) = velocities
          rem
          rem Output: Player velocities set (integer parts only,
          rem subpixel parts set to 0)
          rem
          rem Mutates: playerVelocityX[], playerVelocityXL[],
          rem playerVelocityY[], playerVelocityYL[]
          rem
          rem Called Routines: None
          dim SPV_playerIndex = temp1 : rem Constraints: None
          dim SPV_velocityX = temp2
          dim SPV_velocityY = temp3
          let playerVelocityX[SPV_playerIndex] = SPV_velocityX
          let playerVelocityXL[SPV_playerIndex] = 0
          let playerVelocityY[SPV_playerIndex] = SPV_velocityY
          let playerVelocityYL[SPV_playerIndex] = 0
          return

SetPlayerPosition
          rem Set player position (integer parts only, subpixel parts
          rem   set to 0)
          rem
          rem Input: temp1 = player index (0-3), temp2 = X position
          rem   (integer), temp3 = Y position (integer)
          rem Set player position (integer parts only, subpixel parts
          rem set to 0)
          rem
          rem Input: temp1 = player index (0-3), temp2 = X position
          rem (integer), temp3 = Y position (integer)
          rem        playerX[], playerY[] (global arrays) = integer
          rem        positions
          rem        playerSubpixelX_W[], playerSubpixelX_WL[],
          rem        playerSubpixelY_W[], playerSubpixelY_WL[] (global
          rem        SCRAM arrays) = subpixel positions
          rem
          rem Output: Player positions set (integer and subpixel parts
          rem set)
          rem
          rem Mutates: playerX[], playerY[], playerSubpixelX_W[],
          rem playerSubpixelX_WL[],
          rem         playerSubpixelY_W[], playerSubpixelY_WL[]
          rem
          rem Called Routines: None
          dim SPP_playerIndex = temp1 : rem Constraints: None
          dim SPP_positionX = temp2
          dim SPP_positionY = temp3
          let playerX[SPP_playerIndex] = SPP_positionX
          let playerSubpixelX_W[SPP_playerIndex] = SPP_positionX : rem SCRAM write: Write to w049
          let playerSubpixelX_WL[SPP_playerIndex] = 0
          let playerY[SPP_playerIndex] = SPP_positionY
          let playerSubpixelY_W[SPP_playerIndex] = SPP_positionY : rem SCRAM write: Write to w057
          let playerSubpixelY_WL[SPP_playerIndex] = 0
          return

GetPlayerPosition
          rem
          rem Get player position (integer parts only)
          rem
          rem Input: currentPlayer = player index (0-3) (global
          rem variable)
          rem
          rem Output: temp2 = X position, temp3 = Y position →
          rem   GPP_positionX, GPP_positionY
          rem
          rem MUTATES:
          rem   temp2 = GPP_positionX (return value: X position)
          rem   temp3 = GPP_positionY (return value: Y position)
          rem WARNING: Callers should read from
          rem GPP_positionX/GPP_positionY
          rem   aliases, not temp2/temp3 directly.
          rem Get player position (integer parts only)
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerX[], playerY[] (global arrays) = integer
          rem        positions
          rem
          rem Output: temp2 = X position, temp3 = Y position
          rem
          rem Mutates: temp2, temp3 (set to position values)
          rem
          rem Called Routines: None
          rem
          rem Constraints: WARNING: Callers should read from
          rem GPP_positionX/GPP_positionY aliases, not temp2/temp3
          rem directly.
          dim GPP_positionX = temp2
          dim GPP_positionY = temp3
          let GPP_positionX = playerX[currentPlayer]
          let GPP_positionY = playerY[currentPlayer]
          let temp2 = GPP_positionX
          let temp3 = GPP_positionY
          return

GetPlayerVelocity
          rem
          rem Get player velocity (integer parts only)
          rem
          rem Input: currentPlayer = player index (0-3) (global
          rem variable)
          rem
          rem Output: temp2 = X velocity, temp3 = Y velocity →
          rem   GPV_velocityX, GPV_velocityY
          rem
          rem MUTATES:
          rem   temp2 = GPV_velocityX (return value: X velocity)
          rem   temp3 = GPV_velocityY (return value: Y velocity)
          rem WARNING: Callers should read from
          rem GPV_velocityX/GPV_velocityY
          rem   aliases, not temp2/temp3 directly.
          rem Get player velocity (integer parts only)
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerVelocityX[], playerVelocityY[] (global
          rem        arrays) = velocities
          rem
          rem Output: temp2 = X velocity, temp3 = Y velocity
          rem
          rem Mutates: temp2, temp3 (set to velocity values)
          rem
          rem Called Routines: None
          rem
          rem Constraints: WARNING: Callers should read from
          rem GPV_velocityX/GPV_velocityY aliases, not temp2/temp3
          rem directly.
          dim GPV_velocityX = temp2
          dim GPV_velocityY = temp3
          let GPV_velocityX = playerVelocityX[currentPlayer]
          let GPV_velocityY = playerVelocityY[currentPlayer]
          let temp2 = GPV_velocityX
          let temp3 = GPV_velocityY
          return

MovementApplyGravity
          rem Apply gravity to player velocity (adds to Y velocity)
          rem
          rem Input: temp1 = player index (0-3), temp2 = gravity
          rem   strength (integer, positive = downward)
          rem NOTE: For subpixel gravity, call AddVelocitySubpixelY
          rem   separately
          rem Apply gravity to player velocity (adds to Y velocity,
          rem integer part only)
          rem
          rem Input: temp1 = player index (0-3), temp2 = gravity
          rem strength (integer, positive = downward), playerVelocityY[]
          rem (global array) = Y velocities
          rem
          rem Output: Y velocity increased by gravity strength
          rem
          rem Mutates: playerVelocityY[] (global array) = Y velocity
          rem (incremented)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Integer gravity only. For subpixel gravity,
          rem call AddVelocitySubpixelY separately
          dim MAG_playerIndex = temp1
          dim MAG_gravityStrength = temp2
          let playerVelocityY[MAG_playerIndex] = playerVelocityY[MAG_playerIndex] + MAG_gravityStrength
          return

AddVelocitySubpixelY
          rem Add to Y velocity subpixel part (for fractional gravity)
          rem
          rem Input: temp1 = player index (0-3), temp2 = subpixel amount
          rem   to add (0-255)
          rem If overflow occurs (>255), carry to integer part
          rem Add to Y velocity subpixel part (for fractional gravity)
          rem
          rem Input: temp1 = player index (0-3), temp2 = subpixel amount
          rem to add (0-255), playerVelocityY[], playerVelocityYL[]
          rem (global arrays) = Y velocities
          rem
          rem Output: Y velocity subpixel part incremented, integer part
          rem incremented if overflow occurs
          rem
          rem Mutates: temp2-temp4 (used for calculations),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) = Y
          rem velocities (subpixel incremented, integer incremented on
          rem carry)
          rem
          rem Called Routines: None
          rem
          rem Constraints: If overflow occurs (>255), carry to integer
          rem part. Uses 16-bit accumulator for proper carry detection
          dim AVSY_playerIndex = temp1
          dim AVSY_subpixelAmount = temp2
          dim AVSY_subpixelAmountSaved = temp4 : rem Save subpixel amount before using temp2 for accumulator
          let AVSY_subpixelAmountSaved = AVSY_subpixelAmount
          dim AVSY_sum16 = temp2.temp3 : rem 16-bit accumulator for proper carry detection
          let AVSY_sum16 = playerVelocityYL[AVSY_playerIndex] + AVSY_subpixelAmountSaved : rem Use saved amount in accumulator
          if temp3 > 0 then VelocityYCarry
          rem No carry: temp3 = 0, use low byte directly
          let playerVelocityYL[AVSY_playerIndex] = temp2
          return
VelocityYCarry
          rem Helper: Handles carry from subpixel to integer part
          rem
          rem Input: temp2 = wrapped low byte, AVSY_playerIndex = player
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
          let playerVelocityYL[AVSY_playerIndex] = temp2 : rem Carry detected: temp3 > 0, extract wrapped low byte
          let playerVelocityY[AVSY_playerIndex] = playerVelocityY[AVSY_playerIndex] + 1
          return

ApplyFriction
          rem Apply friction to player X velocity (simple approximation)
          rem
          rem Input: temp1 = player index (0-3)
          rem NOTE: Simple decrement approach for 8-bit CPU
          rem Apply friction to player X velocity (simple approximation
          rem using decrement/increment)
          rem
          rem Input: temp1 = player index (0-3), playerVelocityX[],
          rem playerVelocityXL[] (global arrays) = X velocities
          rem
          rem Output: X velocity reduced by 1 (positive velocities
          rem decremented, negative velocities incremented), subpixel
          rem zeroed if velocity reaches zero
          rem
          rem Mutates: playerVelocityX[], playerVelocityXL[] (global
          rem arrays) = X velocities (reduced by 1, subpixel zeroed if
          rem zero)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Simple decrement approach for 8-bit CPU.
          rem Positive velocities (>0 and not negative) decremented,
          rem negative velocities (≥128 in two’s complement) incremented
          dim AF_playerIndex = temp1
          if playerVelocityX[AF_playerIndex] > 0 && !(playerVelocityX[AF_playerIndex] & $80) then let playerVelocityX[AF_playerIndex] = playerVelocityX[AF_playerIndex] - 1
          rem Check for negative velocity using twos complement (values
          rem ≥ 128 are negative)
          if playerVelocityX[AF_playerIndex] & $80 then let playerVelocityX[AF_playerIndex] = playerVelocityX[AF_playerIndex] + 1
          if playerVelocityX[AF_playerIndex] = 0 then let playerVelocityXL[AF_playerIndex] = 0 : rem Also zero subpixel if velocity reaches zero
          return

CheckPlayerCollision
          rem
          rem Collision Detection With Subpixel Precision
          rem Check collision between two players using integer
          rem   positions
          rem
          rem Input: temp1 = player 1 index → CPC_player1Index
          rem        temp2 = player 2 index → CPC_player2Index
          rem
          rem Output: temp3 = 1 if collision, 0 if not →
          rem CPC_collisionResult
          rem NOTE: Uses integer positions only (subpixel ignored for
          rem   collision)
          rem
          rem MUTATES:
          rem   temp3 = CPC_collisionResult (return value: 1 if
          rem   collision, 0 if not)
          rem   temp4-temp13 = Used internally for calculations
          rem   alias, not
          rem WARNING: Callers should read from CPC_collisionResult
          rem   execution.
          rem temp3 directly. All temp4-temp13 are mutated during
          rem Check collision between two players using integer
          rem positions (subpixel ignored)
          rem
          rem Input: temp1 = player 1 index (0-3), temp2 = player 2
          rem index (0-3), playerX[], playerY[] (global arrays) = player
          rem positions, playerCharacter[] (global array) = character types,
          rem CharacterHeights[] (global data table) = character heights
          rem
          rem Output: temp3 = 1 if collision, 0 if not
          rem
          rem Mutates: temp3-temp9 (used for calculations, temp4-7
          rem reused after X/Y checks)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Uses integer positions only (subpixel ignored
          rem for collision). Checks X collision (16 pixel width) and Y
          rem collision (using CharacterHeights table). WARNING: Callers
          rem should read from CPC_collisionResult alias, not temp3
          rem directly. Uses temp1-temp9 (temp4-7 reused after X/Y
          rem checks)
          dim CPC_player1Index = temp1
          dim CPC_player2Index = temp2
          dim CPC_collisionResult = temp3
          dim CPC_player1X = temp4
          dim CPC_player1Y = temp5
          dim CPC_player2X = temp6
          dim CPC_player2Y = temp7
          dim CPC_distance = temp8
          dim CPC_char1Type = temp9
          
          let CPC_player1X = playerX[CPC_player1Index] : rem Get positions
          let CPC_player1Y = playerY[CPC_player1Index] : rem Player1 X
          let CPC_player2X = playerX[CPC_player2Index] : rem Player1 Y
          let CPC_player2Y = playerY[CPC_player2Index] : rem Player2 X
          rem Player2 Y
          
          rem Check X collision (16 pixel width - double-width NUSIZ
          rem   sprites)
          if CPC_player1X >= CPC_player2X then CalcXDistanceRight : rem Calculate distance
          let CPC_distance = CPC_player2X - CPC_player1X
          goto XDistanceDone
CalcXDistanceRight
          let CPC_distance = CPC_player1X - CPC_player2X
XDistanceDone
          if CPC_distance >= 16 then NoCollision
          
          rem Check Y collision using CharacterHeights table
          rem Reuse temp4 and temp6 (player1X and player2X no longer
          rem needed after X check)
          dim CPC_char2Type = temp4
          dim CPC_char1Height = temp6
          let CPC_char1Type = playerCharacter[CPC_player1Index] : rem Get character types for height lookup
          let CPC_char2Type = playerCharacter[CPC_player2Index] : rem Player1 character type
          rem Player2 character type
          let CPC_char1Height = CharacterHeights[CPC_char1Type] : rem Get heights from table
          dim CPC_char2Height = temp4
          let CPC_char2Height = CharacterHeights[CPC_char2Type] : rem Player1 height
          rem Player2 height
          rem Calculate Y distance using center points
          rem Player centers: player1Y + char1Height/2 and player2Y +
          rem   char2Height/2
          rem Store half-heights in temp4 and temp6 (char2Type no longer
          rem needed)
          let CPC_char1Height = CPC_char1Height / 2 : rem For collision check, use half-height sum
          let CPC_char2Height = CPC_char2Height / 2 : rem Player1 half-height
          rem Store char2Height half in temp4 for later use
          let temp4 = CPC_char2Height
          if CPC_player1Y >= CPC_player2Y then CalcYDistanceDown : rem Player2 half-height
          let CPC_distance = CPC_player2Y - CPC_player1Y
          goto YDistanceDone
CalcYDistanceDown
          let CPC_distance = CPC_player1Y - CPC_player2Y
YDistanceDone
          rem Reuse temp5 and temp7 (player1Y and player2Y no longer
          rem needed after Y distance calculated)
          dim CPC_halfHeightSum = temp5
          let CPC_halfHeightSum = CPC_char1Height + temp4 : rem Check if Y distance is less than sum of half-heights
          if CPC_distance >= CPC_halfHeightSum then NoCollision
          
          let CPC_collisionResult = 1 : rem Collision detected
          return
          rem Return value set in alias (temp3 is set but use alias
          rem instead)
          
NoCollision
          let CPC_collisionResult = 0
          rem   instead)
          return
ConstrainToScreen
          rem Return value set in alias (temp3 is set but use alias
          rem
          rem Movement Constraints
          rem Constrain player to screen bounds
          rem
          rem Input: temp1 = player index (0-3)
          rem Clamps integer positions and zeros subpixel parts at
          rem   boundaries
          rem Constrain player to screen bounds (clamps integer
          rem positions and zeros subpixel parts at boundaries)
          rem
          rem Input: temp1 = player index (0-3), playerX[], playerY[]
          rem (global arrays) = integer positions, playerSubpixelX_W[],
          rem playerSubpixelX_WL[], playerSubpixelY_W[],
          rem playerSubpixelY_WL[] (global SCRAM arrays) = subpixel
          rem positions
          rem
          rem Output: Player positions clamped to screen bounds (X:
          rem 10-150, Y: 20-80), subpixel parts zeroed at boundaries
          rem
          rem Mutates: playerX[], playerY[] (global arrays) = integer
          rem positions (clamped), playerSubpixelX_W[],
          rem playerSubpixelX_WL[], playerSubpixelY_W[],
          rem playerSubpixelY_WL[] (global SCRAM arrays) = subpixel
          rem positions (set to clamped values, low bytes zeroed)
          rem
          rem Called Routines: None
          dim CTS_playerIndex = temp1 : rem Constraints: X bounds: 10-150, Y bounds: 20-80
          rem Constrain X position (10 to 150 for screen bounds)
          if playerX[CTS_playerIndex] < 10 then let playerX[CTS_playerIndex] = 10 : rem SCRAM write: Write to w049
          if playerX[CTS_playerIndex] < 10 then let playerSubpixelX_W[CTS_playerIndex] = 10
          if playerX[CTS_playerIndex] < 10 then let playerSubpixelX_WL[CTS_playerIndex] = 0
          if playerX[CTS_playerIndex] > 150 then let playerX[CTS_playerIndex] = 150
          if playerX[CTS_playerIndex] > 150 then let playerSubpixelX_W[CTS_playerIndex] = 150
          if playerX[CTS_playerIndex] > 150 then let playerSubpixelX_WL[CTS_playerIndex] = 0
          
          rem Constrain Y position (20 to 80 for screen bounds)
          if playerY[CTS_playerIndex] < 20 then let playerY[CTS_playerIndex] = 20 : rem SCRAM write: Write to w057
          if playerY[CTS_playerIndex] < 20 then let playerSubpixelY_W[CTS_playerIndex] = 20
          if playerY[CTS_playerIndex] < 20 then let playerSubpixelY_WL[CTS_playerIndex] = 0
          if playerY[CTS_playerIndex] > 80 then let playerY[CTS_playerIndex] = 80
          if playerY[CTS_playerIndex] > 80 then let playerSubpixelY_W[CTS_playerIndex] = 80
          if playerY[CTS_playerIndex] > 80 then let playerSubpixelY_WL[CTS_playerIndex] = 0
          
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
          dim IMS_playerIndex = temp1
          dim IMS_positionX = temp2
          dim IMS_positionY = temp3
          dim IMS_velocityX = temp2
          dim IMS_velocityY = temp3
          rem Initialize all players to center of screen - inlined for
          let IMS_positionX = 80 : rem   performance
          let IMS_positionY = 100
          let playerX[0] = IMS_positionX : rem Player 0
          let playerSubpixelX_W[0] = IMS_positionX
          let playerSubpixelX_WL[0] = 0
          let playerY[0] = IMS_positionY
          let playerSubpixelY_W[0] = IMS_positionY
          let playerSubpixelY_WL[0] = 0
          let playerX[1] = IMS_positionX : rem Player 1
          let playerSubpixelX_W[1] = IMS_positionX
          let playerSubpixelX_WL[1] = 0
          let playerY[1] = IMS_positionY
          let playerSubpixelY_W[1] = IMS_positionY
          let playerSubpixelY_WL[1] = 0
          let playerX[2] = IMS_positionX : rem Player 2
          let playerSubpixelX_W[2] = IMS_positionX
          let playerSubpixelX_WL[2] = 0
          let playerY[2] = IMS_positionY
          let playerSubpixelY_W[2] = IMS_positionY
          let playerSubpixelY_WL[2] = 0
          let playerX[3] = IMS_positionX : rem Player 3
          let playerSubpixelX_W[3] = IMS_positionX
          let playerSubpixelX_WL[3] = 0
          let playerY[3] = IMS_positionY
          let playerSubpixelY_W[3] = IMS_positionY
          let playerSubpixelY_WL[3] = 0
          
          rem Initialize velocities to zero - inlined for performance
          let playerVelocityX[0] = 0 : rem Player 0
          let playerVelocityXL[0] = 0
          let playerVelocityY[0] = 0
          let playerVelocityYL[0] = 0
          let playerVelocityX[1] = 0 : rem Player 1
          let playerVelocityXL[1] = 0
          let playerVelocityY[1] = 0
          let playerVelocityYL[1] = 0
          let playerVelocityX[2] = 0 : rem Player 2
          let playerVelocityXL[2] = 0
          let playerVelocityY[2] = 0
          let playerVelocityYL[2] = 0
          let playerVelocityX[3] = 0 : rem Player 3
          let playerVelocityXL[3] = 0
          let playerVelocityY[3] = 0
          let playerVelocityYL[3] = 0
          return
          

          let playerVelocityYL[2] = 0
          let playerVelocityX[3] = 0 : rem Player 3
          let playerVelocityXL[3] = 0
          let playerVelocityY[3] = 0
          let playerVelocityYL[3] = 0
          return
          
