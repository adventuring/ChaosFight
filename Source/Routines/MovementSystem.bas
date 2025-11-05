          rem ChaosFight - Source/Routines/MovementSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem 8.8 fixed-point movement system using batariBASIC built-in
          rem   support

          rem ==========================================================
          rem MOVEMENT SYSTEM ROUTINES
          rem ==========================================================
          rem All integers are 8-bit. Position consists of:
          rem - playerX/Y[0-3] = Integer part (8-bit, already exists in
          rem   var0-var7)
          rem - playerSubpixelX/Y[0-3] = High byte of 8.8 fixed-point
          rem   position (var/w array)
          rem - playerSubpixelX/Y_lo[0-3] = Low byte of 8.8 fixed-point
          rem   position (fractional)
          rem Velocity consists of:
          rem - playerVelocityX[0-3] = High byte of 8.8 fixed-point X
          rem   velocity (var20-var23, ZPRAM)
          rem - playerVelocityX_lo[0-3] = Low byte of 8.8 fixed-point X
          rem   velocity (var24-var27, ZPRAM)
          rem - playerVelocityY[0-3] = High byte of 8.8 fixed-point Y
          rem   velocity (var28-var31, ZPRAM)
          rem - playerVelocityY_lo[0-3] = Low byte of 8.8 fixed-point Y
          rem   velocity (var32-var35, ZPRAM)
          rem
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
UpdatePlayerMovement
          rem Update movement for each active player
          for currentPlayer = 0 to 1
              gosub UpdatePlayerMovementSingle
          next
          rem Players 2-3 only if Quadtari detected
          if QuadtariDetected = 0 then goto UpdatePlayerMovementQuadtariSkip
          for currentPlayer = 2 to 3
              gosub UpdatePlayerMovementSingle
          next
UpdatePlayerMovementQuadtariSkip
          return

          rem Update movement for a specific player
          rem Input: currentPlayer = player index (0-3) (global variable)
          rem Applies velocity to position with subpixel precision
          rem batariBASIC automatically handles carry from fractional to
          rem   integer parts
          rem
          rem MUTATES:
          rem   temp2 = UPS_subpixelSum (internal calculation)
          rem   temp4 = UPS_subpixelXRead (internal SCRAM read-modify-write)
          rem WARNING: temp2 and temp4 are mutated during execution. Do not
          rem   use these temp variables after calling this subroutine.
          rem
          rem EFFECTS:
          rem   Modifies playerX[], playerY[], playerSubpixelX_W[],
          rem   playerSubpixelY_W[]
UpdatePlayerMovementSingle
          dim UPS_subpixelSum = temp2
          rem Skip if player is eliminated
          if playerHealth[currentPlayer] = 0 then return
          
          rem ==========================================================
          rem APPLY X VELOCITY TO X POSITION
          rem ==========================================================
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem For playerVelocityX (declared separately), add high and
          rem   low bytes manually
          rem batariBASIC will handle carry from low byte to high byte
          rem   automatically
          let UPS_subpixelSum = playerSubpixelX_W_lo[currentPlayer] + playerVelocityX_lo[currentPlayer]
          if UPS_subpixelSum > 255 then XCarry
          let playerSubpixelX_W_lo[currentPlayer] = UPS_subpixelSum
          goto XNoCarry
XCarry
          let playerSubpixelX_W_lo[currentPlayer] = UPS_subpixelSum - 256
          rem SCRAM read-modify-write: Read from r049, modify, write to
          rem   w049
          dim UPS_subpixelXRead = temp4
          let UPS_subpixelXRead = playerSubpixelX_R[currentPlayer]
          let UPS_subpixelXRead = UPS_subpixelXRead + 1
          let playerSubpixelX_W[currentPlayer] = UPS_subpixelXRead
XNoCarry
          rem SCRAM read-modify-write: Read from r049, modify, write to
          rem   w049
          dim UPS_subpixelXRead = temp4
          let UPS_subpixelXRead = playerSubpixelX_R[currentPlayer]
          let UPS_subpixelXRead = UPS_subpixelXRead + playerVelocityX[currentPlayer]
          let playerSubpixelX_W[currentPlayer] = UPS_subpixelXRead
          
          rem Sync integer position for rendering (high byte is the
          rem   integer part)
          let playerX[currentPlayer] = playerSubpixelX_R[currentPlayer]
          
          rem ==========================================================
          rem APPLY Y VELOCITY TO Y POSITION
          rem ==========================================================
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem playerVelocityY is declared as .8.8 so batariBASIC handles
          rem   arithmetic automatically
          rem But we still need to do it manually since both parts are
          rem   separate arrays
          let UPS_subpixelSum = playerSubpixelY_W_lo[currentPlayer] + playerVelocityY_lo[currentPlayer]
          if UPS_subpixelSum > 255 then YCarry
          let playerSubpixelY_W_lo[currentPlayer] = UPS_subpixelSum
          goto YNoCarry
YCarry
          let playerSubpixelY_W_lo[currentPlayer] = UPS_subpixelSum - 256
          rem SCRAM read-modify-write: Read from r057, modify, write to
          rem   w057
          dim UPS_subpixelYRead = temp4
          let UPS_subpixelYRead = playerSubpixelY_R[currentPlayer]
          let UPS_subpixelYRead = UPS_subpixelYRead + 1
          let playerSubpixelY_W[currentPlayer] = UPS_subpixelYRead
YNoCarry
          rem SCRAM read-modify-write: Read from r057, modify, write to
          rem   w057
          dim UPS_subpixelYRead = temp4
          let UPS_subpixelYRead = playerSubpixelY_R[currentPlayer]
          let UPS_subpixelYRead = UPS_subpixelYRead + playerVelocityY[currentPlayer]
          let playerSubpixelY_W[currentPlayer] = UPS_subpixelYRead
          
          rem Sync integer position for rendering (high byte is the
          rem   integer part)
          let playerY[currentPlayer] = playerSubpixelY_R[currentPlayer]
          
          return

          rem Set player velocity (integer parts only, subpixel parts
          rem   set to 0)
          rem Input: temp1 = player index (0-3), temp2 = X velocity
          rem   (integer), temp3 = Y velocity (integer)
SetPlayerVelocity
          dim SPV_playerIndex = temp1
          dim SPV_velocityX = temp2
          dim SPV_velocityY = temp3
          let playerVelocityX[SPV_playerIndex] = SPV_velocityX
          let playerVelocityX_lo[SPV_playerIndex] = 0
          let playerVelocityY[SPV_playerIndex] = SPV_velocityY
          let playerVelocityY_lo[SPV_playerIndex] = 0
          return

          rem Set player position (integer parts only, subpixel parts
          rem   set to 0)
          rem Input: temp1 = player index (0-3), temp2 = X position
          rem   (integer), temp3 = Y position (integer)
SetPlayerPosition
          dim SPP_playerIndex = temp1
          dim SPP_positionX = temp2
          dim SPP_positionY = temp3
          let playerX[SPP_playerIndex] = SPP_positionX
          rem SCRAM write: Write to w049
          let playerSubpixelX_W[SPP_playerIndex] = SPP_positionX
          let playerSubpixelX_W_lo[SPP_playerIndex] = 0
          let playerY[SPP_playerIndex] = SPP_positionY
          rem SCRAM write: Write to w057
          let playerSubpixelY_W[SPP_playerIndex] = SPP_positionY
          let playerSubpixelY_W_lo[SPP_playerIndex] = 0
          return

          rem Get player position (integer parts only)
          rem Input: currentPlayer = player index (0-3) (global variable)
          rem Output: temp2 = X position, temp3 = Y position →
          rem   GPP_positionX, GPP_positionY
          rem
          rem MUTATES:
          rem   temp2 = GPP_positionX (return value: X position)
          rem   temp3 = GPP_positionY (return value: Y position)
          rem WARNING: Callers should read from GPP_positionX/GPP_positionY
          rem   aliases, not temp2/temp3 directly.
GetPlayerPosition
          dim GPP_positionX = temp2
          dim GPP_positionY = temp3
          let GPP_positionX = playerX[currentPlayer]
          let GPP_positionY = playerY[currentPlayer]
          let temp2 = GPP_positionX
          let temp3 = GPP_positionY
          return

          rem Get player velocity (integer parts only)
          rem Input: currentPlayer = player index (0-3) (global variable)
          rem Output: temp2 = X velocity, temp3 = Y velocity →
          rem   GPV_velocityX, GPV_velocityY
          rem
          rem MUTATES:
          rem   temp2 = GPV_velocityX (return value: X velocity)
          rem   temp3 = GPV_velocityY (return value: Y velocity)
          rem WARNING: Callers should read from GPV_velocityX/GPV_velocityY
          rem   aliases, not temp2/temp3 directly.
GetPlayerVelocity
          dim GPV_velocityX = temp2
          dim GPV_velocityY = temp3
          let GPV_velocityX = playerVelocityX[currentPlayer]
          let GPV_velocityY = playerVelocityY[currentPlayer]
          let temp2 = GPV_velocityX
          let temp3 = GPV_velocityY
          return

          rem Apply gravity to player velocity (adds to Y velocity)
          rem Input: temp1 = player index (0-3), temp2 = gravity
          rem   strength (integer, positive = downward)
          rem NOTE: For subpixel gravity, call AddVelocitySubpixelY
          rem   separately
MovementApplyGravity
          dim MAG_playerIndex = temp1
          dim MAG_gravityStrength = temp2
          let playerVelocityY[MAG_playerIndex] = playerVelocityY[MAG_playerIndex] + MAG_gravityStrength
          return

          rem Add to Y velocity subpixel part (for fractional gravity)
          rem Input: temp1 = player index (0-3), temp2 = subpixel amount
          rem   to add (0-255)
          rem If overflow occurs (>255), carry to integer part
AddVelocitySubpixelY
          dim AVSY_playerIndex = temp1
          dim AVSY_subpixelAmount = temp2
          dim AVSY_sum = temp3
          let AVSY_sum = playerVelocityY_lo[AVSY_playerIndex] + AVSY_subpixelAmount
          if AVSY_sum > 255 then VelocityYCarry
          let playerVelocityY_lo[AVSY_playerIndex] = AVSY_sum
          return
VelocityYCarry
          let playerVelocityY_lo[AVSY_playerIndex] = AVSY_sum - 256
          let playerVelocityY[AVSY_playerIndex] = playerVelocityY[AVSY_playerIndex] + 1
          return

          rem Apply friction to player X velocity (simple approximation)
          rem Input: temp1 = player index (0-3)
          rem NOTE: Simple decrement approach for 8-bit CPU
ApplyFriction
          dim AF_playerIndex = temp1
          if playerVelocityX[AF_playerIndex] > 0 && !(playerVelocityX[AF_playerIndex] & $80) then let playerVelocityX[AF_playerIndex] = playerVelocityX[AF_playerIndex] - 1
          rem Check for negative velocity using two's complement (values ≥ 128 are negative)
          if playerVelocityX[AF_playerIndex] & $80 then let playerVelocityX[AF_playerIndex] = playerVelocityX[AF_playerIndex] + 1
          rem Also zero subpixel if velocity reaches zero
          if playerVelocityX[AF_playerIndex] = 0 then let playerVelocityX_lo[AF_playerIndex] = 0
          return

          rem ==========================================================
          rem COLLISION DETECTION WITH SUBPIXEL PRECISION
          rem ==========================================================

          rem Check collision between two players using integer
          rem   positions
          rem Input: temp1 = player 1 index → CPC_player1Index
          rem        temp2 = player 2 index → CPC_player2Index
          rem Output: temp3 = 1 if collision, 0 if not → CPC_collisionResult
          rem NOTE: Uses integer positions only (subpixel ignored for
          rem   collision)
          rem
          rem MUTATES:
          rem   temp3 = CPC_collisionResult (return value: 1 if collision, 0 if not)
          rem   temp4-temp13 = Used internally for calculations
          rem WARNING: Callers should read from CPC_collisionResult alias, not
          rem   temp3 directly. All temp4-temp13 are mutated during execution.
CheckPlayerCollision
          dim CPC_player1Index = temp1
          dim CPC_player2Index = temp2
          dim CPC_collisionResult = temp3
          dim CPC_player1X = temp4
          dim CPC_player1Y = temp5
          dim CPC_player2X = temp6
          dim CPC_player2Y = temp7
          dim CPC_distance = temp8
          dim CPC_char1Type = temp9
          dim CPC_char2Type = temp10
          dim CPC_char1Height = temp11
          dim CPC_char2Height = temp12
          dim CPC_halfHeightSum = temp13
          
          rem Get positions
          let CPC_player1X = playerX[CPC_player1Index]
          rem Player1 X
          let CPC_player1Y = playerY[CPC_player1Index]
          rem Player1 Y
          let CPC_player2X = playerX[CPC_player2Index]
          rem Player2 X
          let CPC_player2Y = playerY[CPC_player2Index]
          rem Player2 Y
          
          rem Check X collision (16 pixel width - double-width NUSIZ
          rem   sprites)
          rem Calculate distance
          if CPC_player1X >= CPC_player2X then CalcXDistanceRight
          let CPC_distance = CPC_player2X - CPC_player1X
          goto XDistanceDone
CalcXDistanceRight
          let CPC_distance = CPC_player1X - CPC_player2X
XDistanceDone
          if CPC_distance >= 16 then NoCollision
          
          rem Check Y collision using CharacterHeights table
          rem Get character types for height lookup
          let CPC_char1Type = playerChar[CPC_player1Index]
          rem Player1 character type
          let CPC_char2Type = playerChar[CPC_player2Index]
          rem Player2 character type
          rem Get heights from table
          let CPC_char1Height = CharacterHeights[CPC_char1Type]
          rem Player1 height
          let CPC_char2Height = CharacterHeights[CPC_char2Type]
          rem Player2 height
          rem Calculate Y distance using center points
          rem Player centers: player1Y + char1Height/2 and player2Y +
          rem   char2Height/2
          rem For collision check, use half-height sum
          let CPC_char1Height = CPC_char1Height / 2
          rem Player1 half-height
          let CPC_char2Height = CPC_char2Height / 2
          rem Player2 half-height
          if CPC_player1Y >= CPC_player2Y then CalcYDistanceDown
          let CPC_distance = CPC_player2Y - CPC_player1Y
          goto YDistanceDone
CalcYDistanceDown
          let CPC_distance = CPC_player1Y - CPC_player2Y
YDistanceDone
          rem Check if Y distance is less than sum of half-heights
          let CPC_halfHeightSum = CPC_char1Height + CPC_char2Height
          if CPC_distance >= CPC_halfHeightSum then NoCollision
          
          rem Collision detected
          let CPC_collisionResult = 1
          rem Return value set in alias (temp3 is set but use alias instead)
          return
          
NoCollision
          let CPC_collisionResult = 0
          rem Return value set in alias (temp3 is set but use alias instead)
          return

          rem ==========================================================
          rem MOVEMENT CONSTRAINTS
          rem ==========================================================

          rem Constrain player to screen bounds
          rem Input: temp1 = player index (0-3)
          rem Clamps integer positions and zeros subpixel parts at
          rem   boundaries
ConstrainToScreen
          dim CTS_playerIndex = temp1
          rem Constrain X position (10 to 150 for screen bounds)
          rem SCRAM write: Write to w049
          if playerX[CTS_playerIndex] < 10 then let playerX[CTS_playerIndex] = 10
          if playerX[CTS_playerIndex] < 10 then let playerSubpixelX_W[CTS_playerIndex] = 10
          if playerX[CTS_playerIndex] < 10 then let playerSubpixelX_W_lo[CTS_playerIndex] = 0
          if playerX[CTS_playerIndex] > 150 then let playerX[CTS_playerIndex] = 150
          if playerX[CTS_playerIndex] > 150 then let playerSubpixelX_W[CTS_playerIndex] = 150
          if playerX[CTS_playerIndex] > 150 then let playerSubpixelX_W_lo[CTS_playerIndex] = 0
          
          rem Constrain Y position (20 to 80 for screen bounds)
          rem SCRAM write: Write to w057
          if playerY[CTS_playerIndex] < 20 then let playerY[CTS_playerIndex] = 20
          if playerY[CTS_playerIndex] < 20 then let playerSubpixelY_W[CTS_playerIndex] = 20
          if playerY[CTS_playerIndex] < 20 then let playerSubpixelY_W_lo[CTS_playerIndex] = 0
          if playerY[CTS_playerIndex] > 80 then let playerY[CTS_playerIndex] = 80
          if playerY[CTS_playerIndex] > 80 then let playerSubpixelY_W[CTS_playerIndex] = 80
          if playerY[CTS_playerIndex] > 80 then let playerSubpixelY_W_lo[CTS_playerIndex] = 0
          
          return

          rem ==========================================================
          rem INITIALIZATION
          rem ==========================================================

          rem Initialize movement system for all players
          rem Called at game start to set up initial positions and
          rem   velocities
InitializeMovementSystem
          dim IMS_playerIndex = temp1
          dim IMS_positionX = temp2
          dim IMS_positionY = temp3
          dim IMS_velocityX = temp2
          dim IMS_velocityY = temp3
          rem Initialize all players to center of screen - inlined for
          rem   performance
          let IMS_positionX = 80
          let IMS_positionY = 100
          rem Player 0
          let playerX[0] = IMS_positionX
          let playerSubpixelX_W[0] = IMS_positionX
          let playerSubpixelX_W_lo[0] = 0
          let playerY[0] = IMS_positionY
          let playerSubpixelY_W[0] = IMS_positionY
          let playerSubpixelY_W_lo[0] = 0
          rem Player 1
          let playerX[1] = IMS_positionX
          let playerSubpixelX_W[1] = IMS_positionX
          let playerSubpixelX_W_lo[1] = 0
          let playerY[1] = IMS_positionY
          let playerSubpixelY_W[1] = IMS_positionY
          let playerSubpixelY_W_lo[1] = 0
          rem Player 2
          let playerX[2] = IMS_positionX
          let playerSubpixelX_W[2] = IMS_positionX
          let playerSubpixelX_W_lo[2] = 0
          let playerY[2] = IMS_positionY
          let playerSubpixelY_W[2] = IMS_positionY
          let playerSubpixelY_W_lo[2] = 0
          rem Player 3
          let playerX[3] = IMS_positionX
          let playerSubpixelX_W[3] = IMS_positionX
          let playerSubpixelX_W_lo[3] = 0
          let playerY[3] = IMS_positionY
          let playerSubpixelY_W[3] = IMS_positionY
          let playerSubpixelY_W_lo[3] = 0
          
          rem Initialize velocities to zero - inlined for performance
          rem Player 0
          let playerVelocityX[0] = 0
          let playerVelocityX_lo[0] = 0
          let playerVelocityY[0] = 0
          let playerVelocityY_lo[0] = 0
          rem Player 1
          let playerVelocityX[1] = 0
          let playerVelocityX_lo[1] = 0
          let playerVelocityY[1] = 0
          let playerVelocityY_lo[1] = 0
          rem Player 2
          let playerVelocityX[2] = 0
          let playerVelocityX_lo[2] = 0
          let playerVelocityY[2] = 0
          let playerVelocityY_lo[2] = 0
          rem Player 3
          let playerVelocityX[3] = 0
          let playerVelocityX_lo[3] = 0
          let playerVelocityY[3] = 0
          let playerVelocityY_lo[3] = 0
          return
          
