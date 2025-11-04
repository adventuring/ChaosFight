          rem ChaosFight - Source/Routines/MovementSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem 8.8 fixed-point movement system using batariBASIC built-in support

          rem =================================================================
          rem MOVEMENT SYSTEM ROUTINES
          rem =================================================================
          rem All integers are 8-bit. Position consists of:
          rem   - playerX/Y[0-3] = Integer part (8-bit, already exists in var0-var7)
          rem   - playerSubpixelX/Y[0-3] = High byte of 8.8 fixed-point position (var/w array)
          rem   - playerSubpixelX/Y_lo[0-3] = Low byte of 8.8 fixed-point position (fractional)
          rem Velocity consists of:
          rem   - playerVelocityX[0-3] = High byte of 8.8 fixed-point X velocity (var20-var23, ZPRAM)
          rem   - playerVelocityX_lo[0-3] = Low byte of 8.8 fixed-point X velocity (var24-var27, ZPRAM)
          rem   - playerVelocityY[0-3] = High byte of 8.8 fixed-point Y velocity (var28-var31, ZPRAM)
          rem   - playerVelocityY_lo[0-3] = Low byte of 8.8 fixed-point Y velocity (var32-var35, ZPRAM)
          rem
          rem NOTE: batariBASIC automatically handles carry operations for 8.8 fixed-point arithmetic.
          rem When you add two 8.8 values, the compiler generates code that:
          rem   1. Adds the low bytes (with carry)
          rem   2. Adds the high bytes (plus carry from low byte addition)
          rem This eliminates the need for manual carry checking and propagation.

          rem Update player movement for all active players
          rem Called every frame to update subpixel positions
UpdatePlayerMovement
          rem Update movement for each active player
          let temp1 = 0 : gosub UpdatePlayerMovementSingle : rem Player 1
          let temp1 = 1 : gosub UpdatePlayerMovementSingle : rem Player 2
          if QuadtariDetected then temp1 = 2 : gosub UpdatePlayerMovementSingle : temp1 = 3 : gosub UpdatePlayerMovementSingle
          return

          rem Update movement for a specific player
          rem Input: temp1 = player index (0-3)
          rem Applies velocity to position with subpixel precision
          rem batariBASIC automatically handles carry from fractional to integer parts
UpdatePlayerMovementSingle
          dim UPS_playerIndex = temp1
          dim UPS_subpixelSum = temp2
          rem Skip if player is eliminated
          if playerHealth[UPS_playerIndex] = 0 then return
          
          rem =================================================================
          rem APPLY X VELOCITY TO X POSITION
          rem =================================================================
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem For playerVelocityX (declared separately), add high and low bytes manually
          rem batariBASIC will handle carry from low byte to high byte automatically
          let UPS_subpixelSum = playerSubpixelX_lo[UPS_playerIndex] + playerVelocityX_lo[UPS_playerIndex]
          if UPS_subpixelSum > 255 then XCarry
          let playerSubpixelX_lo[UPS_playerIndex] = UPS_subpixelSum
          goto XNoCarry
XCarry
          let playerSubpixelX_lo[UPS_playerIndex] = UPS_subpixelSum - 256
          let playerSubpixelX[UPS_playerIndex] = playerSubpixelX[UPS_playerIndex] + 1
XNoCarry
          let playerSubpixelX[UPS_playerIndex] = playerSubpixelX[UPS_playerIndex] + playerVelocityX[UPS_playerIndex]
          
          rem Sync integer position for rendering (high byte is the integer part)
          let playerX[UPS_playerIndex] = playerSubpixelX[UPS_playerIndex]
          
          rem =================================================================
          rem APPLY Y VELOCITY TO Y POSITION
          rem =================================================================
          rem Add 8.8 fixed-point velocity to 8.8 fixed-point position
          rem playerVelocityY is declared as .8.8 so batariBASIC handles arithmetic automatically
          rem But we still need to do it manually since both parts are separate arrays
          let UPS_subpixelSum = playerSubpixelY_lo[UPS_playerIndex] + playerVelocityY_lo[UPS_playerIndex]
          if UPS_subpixelSum > 255 then YCarry
          let playerSubpixelY_lo[UPS_playerIndex] = UPS_subpixelSum
          goto YNoCarry
YCarry
          let playerSubpixelY_lo[UPS_playerIndex] = UPS_subpixelSum - 256
          let playerSubpixelY[UPS_playerIndex] = playerSubpixelY[UPS_playerIndex] + 1
YNoCarry
          let playerSubpixelY[UPS_playerIndex] = playerSubpixelY[UPS_playerIndex] + playerVelocityY[UPS_playerIndex]
          
          rem Sync integer position for rendering (high byte is the integer part)
          let playerY[UPS_playerIndex] = playerSubpixelY[UPS_playerIndex]
          
          return

          rem Set player velocity (integer parts only, subpixel parts set to 0)
          rem Input: temp1 = player index (0-3), temp2 = X velocity (integer), temp3 = Y velocity (integer)
SetPlayerVelocity
          dim SPV_playerIndex = temp1
          dim SPV_velocityX = temp2
          dim SPV_velocityY = temp3
          let playerVelocityX[SPV_playerIndex] = SPV_velocityX
          let playerVelocityX_lo[SPV_playerIndex] = 0
          let playerVelocityY[SPV_playerIndex] = SPV_velocityY
          let playerVelocityY_lo[SPV_playerIndex] = 0
          return

          rem Set player position (integer parts only, subpixel parts set to 0)
          rem Input: temp1 = player index (0-3), temp2 = X position (integer), temp3 = Y position (integer)
SetPlayerPosition
          dim SPP_playerIndex = temp1
          dim SPP_positionX = temp2
          dim SPP_positionY = temp3
          let playerX[SPP_playerIndex] = SPP_positionX
          let playerSubpixelX[SPP_playerIndex] = SPP_positionX
          let playerSubpixelX_lo[SPP_playerIndex] = 0
          let playerY[SPP_playerIndex] = SPP_positionY
          let playerSubpixelY[SPP_playerIndex] = SPP_positionY
          let playerSubpixelY_lo[SPP_playerIndex] = 0
          return

          rem Get player position (integer parts only)
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = X position, temp3 = Y position
GetPlayerPosition
          dim GPP_playerIndex = temp1
          dim GPP_positionX = temp2
          dim GPP_positionY = temp3
          let GPP_positionX = playerX[GPP_playerIndex]
          let GPP_positionY = playerY[GPP_playerIndex]
          return

          rem Get player velocity (integer parts only)
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = X velocity, temp3 = Y velocity
GetPlayerVelocity
          dim GPV_playerIndex = temp1
          dim GPV_velocityX = temp2
          dim GPV_velocityY = temp3
          let GPV_velocityX = playerVelocityX[GPV_playerIndex]
          let GPV_velocityY = playerVelocityY[GPV_playerIndex]
          return

          rem Apply gravity to player velocity (adds to Y velocity)
          rem Input: temp1 = player index (0-3), temp2 = gravity strength (integer, positive = downward)
          rem NOTE: For subpixel gravity, call AddVelocitySubpixelY separately
MovementApplyGravity
          dim MAG_playerIndex = temp1
          dim MAG_gravityStrength = temp2
          let playerVelocityY[MAG_playerIndex] = playerVelocityY[MAG_playerIndex] + MAG_gravityStrength
          return

          rem Add to Y velocity subpixel part (for fractional gravity)
          rem Input: temp1 = player index (0-3), temp2 = subpixel amount to add (0-255)
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
          if playerVelocityX[AF_playerIndex] > 0 then let playerVelocityX[AF_playerIndex] = playerVelocityX[AF_playerIndex] - 1
          if playerVelocityX[AF_playerIndex] < 0 then let playerVelocityX[AF_playerIndex] = playerVelocityX[AF_playerIndex] + 1
          rem Also zero subpixel if velocity reaches zero
          if playerVelocityX[AF_playerIndex] = 0 then let playerVelocityX_lo[AF_playerIndex] = 0
          return

          rem =================================================================
          rem COLLISION DETECTION WITH SUBPIXEL PRECISION
          rem =================================================================

          rem Check collision between two players using integer positions
          rem Input: temp1 = player 1 index, temp2 = player 2 index
          rem Output: temp3 = 1 if collision, 0 if not
          rem NOTE: Uses integer positions only (subpixel ignored for collision)
CheckPlayerCollision
          dim CPC_player1Index = temp1
          dim CPC_player2Index = temp2
          dim CPC_collisionResult = temp3
          
          rem Get positions
          let temp4 = playerX[CPC_player1Index] : rem Player1 X
          let temp5 = playerY[CPC_player1Index] : rem Player1 Y
          let temp6 = playerX[CPC_player2Index] : rem Player2 X
          let temp7 = playerY[CPC_player2Index] : rem Player2 Y
          
          rem Check X collision (16 pixel width - double-width NUSIZ sprites)
          rem Calculate distance
          if temp4 >= temp6 then CalcXDistanceRight
          let temp8 = temp6 - temp4
          goto XDistanceDone
CalcXDistanceRight
          let temp8 = temp4 - temp6
XDistanceDone
          if temp8 >= 16 then NoCollision
          
          rem Check Y collision using CharacterHeights table
          rem Get character types for height lookup
          temp9 = playerChar[CPC_player1Index]
          rem Player1 character type
          temp10 = playerChar[CPC_player2Index]
          rem Player2 character type
          rem Get heights from table
          temp11 = CharacterHeights[temp9]
          rem Player1 height
          temp12 = CharacterHeights[temp10]
          rem Player2 height
          rem Calculate Y distance using center points
          rem Player centers: temp5 + temp11/2 and temp7 + temp12/2
          rem For collision check, use half-height sum
          temp11 = temp11 / 2
          rem Player1 half-height
          temp12 = temp12 / 2
          rem Player2 half-height
          if temp5 >= temp7 then CalcYDistanceDown
          let temp8 = temp7 - temp5
          goto YDistanceDone
CalcYDistanceDown
          let temp8 = temp5 - temp7
YDistanceDone
          rem Check if Y distance is less than sum of half-heights
          temp13 = temp11 + temp12
          if temp8 >= temp13 then NoCollision
          
          rem Collision detected
          let temp3  = 1
          return
          
NoCollision
          let temp3  = 0
          return

          rem =================================================================
          rem MOVEMENT CONSTRAINTS
          rem =================================================================

          rem Constrain player to screen bounds
          rem Input: temp1 = player index (0-3)
          rem Clamps integer positions and zeros subpixel parts at boundaries
ConstrainToScreen
          rem Constrain X position (10 to 150 for screen bounds)
          if playerX[temp1] < 10 then let playerX[temp1] = 10 : let playerSubpixelX[temp1] = 10 : let playerSubpixelX_lo[temp1] = 0
          if playerX[temp1] > 150 then let playerX[temp1] = 150 : let playerSubpixelX[temp1] = 150 : let playerSubpixelX_lo[temp1] = 0
          
          rem Constrain Y position (20 to 80 for screen bounds)
          if playerY[temp1] < 20 then let playerY[temp1] = 20 : let playerSubpixelY[temp1] = 20 : let playerSubpixelY_lo[temp1] = 0
          if playerY[temp1] > 80 then let playerY[temp1] = 80 : let playerSubpixelY[temp1] = 80 : let playerSubpixelY_lo[temp1] = 0
          
          return

          rem =================================================================
          rem INITIALIZATION
          rem =================================================================

          rem Initialize movement system for all players
          rem Called at game start to set up initial positions and velocities
InitializeMovementSystem
          rem Initialize all players to center of screen
          let temp1 = 0 : temp2 = 80 : temp3 = 100 : gosub SetPlayerPosition
          let temp1 = 1 : temp2 = 80 : temp3 = 100 : gosub SetPlayerPosition
          let temp1 = 2 : temp2 = 80 : temp3 = 100 : gosub SetPlayerPosition
          let temp1 = 3 : temp2 = 80 : temp3 = 100 : gosub SetPlayerPosition
          
          rem Initialize velocities to zero
          let temp1 = 0 : temp2 = 0 : temp3 = 0 : gosub SetPlayerVelocity
          let temp1 = 1 : temp2 = 0 : temp3 = 0 : gosub SetPlayerVelocity
          let temp1 = 2 : temp2 = 0 : temp3 = 0 : gosub SetPlayerVelocity
          let temp1 = 3 : temp2 = 0 : temp3 = 0 : gosub SetPlayerVelocity
          
          return
