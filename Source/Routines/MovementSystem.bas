          rem ChaosFight - Source/Routines/MovementSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem 8.8 fixed-point movement system for smooth 60fps/50fps movement

          rem =================================================================
          rem MOVEMENT SYSTEM ROUTINES
          rem =================================================================

          rem Update player movement for all active players
          rem Called every frame to update subpixel positions
UpdatePlayerMovement
          rem Update movement for each active player
          currentPlayer = 0  : gosub UpdatePlayerMovementSingle 
          rem Player 1
          currentPlayer = 1  : gosub UpdatePlayerMovementSingle 
          rem Player 2
          if QuadtariDetected then currentPlayer = 2  : gosub UpdatePlayerMovementSingle  : currentPlayer = 3  : gosub UpdatePlayerMovementSingle
          return

          rem Update movement for a specific player
          rem Input: currentPlayer = player index (0-3)
UpdatePlayerMovementSingle
          rem Skip if player is eliminated
          if playerHealth[currentPlayer] = 0 then return
          
          rem Update subpixel positions with velocity
          let playerSubpixelX[currentPlayer] = playerSubpixelX[currentPlayer] + playerVelocityX[currentPlayer]
          let playerSubpixelY[currentPlayer] = playerSubpixelY[currentPlayer] + playerVelocityY[currentPlayer]
          
          rem Convert subpixel positions to sprite positions
          gosub UpdateSpritePositions
          
          return

          rem Convert subpixel positions to sprite positions
          rem Input: currentPlayer = player index (0-3)
UpdateSpritePositions
          rem Convert 8.8 fixed-point to 8-bit sprite X
          temp2 = playerSubpixelX[currentPlayer] >> 8 
          rem Upper 8 bits (integer part)
          temp3 = playerSubpixelY[currentPlayer] >> 8 
          rem Upper 8 bits (integer part)
          
          rem Set sprite positions based on player index
          if currentPlayer = 0 then player0x = temp2 : player0y = temp3
          if currentPlayer = 1 then player1x = temp2 : player1y = temp3
          if currentPlayer = 2 then player2x = temp2 : player2y = temp3
          if currentPlayer = 3 then player3x = temp2 : player3y = temp3
          
          return

          rem Set player velocity
          rem Input: currentPlayer = player index (0-3), temp2 = X velocity, temp3 = Y velocity
SetPlayerVelocity
          rem Set 8.8 fixed-point velocities (input already in 8.8 format)
          let playerVelocityX[currentPlayer] = temp2
          let playerVelocityY[currentPlayer] = temp3
          return

          rem Set player position
          rem Input: currentPlayer = player index (0-3), temp2 = X position, temp3 = Y position
SetPlayerPosition
          rem Set 8.8 fixed-point positions (input already in 8.8 format)
          let playerSubpixelX[currentPlayer] = temp2
          let playerSubpixelY[currentPlayer] = temp3
          
          rem Update sprite positions immediately
          gosub UpdateSpritePositions
          return

          rem Get player position
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = X position, temp3 = Y position
GetPlayerPosition
          temp2 = playerSubpixelX[currentPlayer] >> 8 
          rem Upper 8 bits (integer part)
          temp3 = playerSubpixelY[currentPlayer] >> 8 
          rem Upper 8 bits (integer part)
          return

          rem Get player velocity
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = X velocity, temp3 = Y velocity
GetPlayerVelocity
          temp2 = playerVelocityX[currentPlayer] >> 8 
          rem Upper 8 bits (integer part)
          temp3 = playerVelocityY[currentPlayer] >> 8 
          rem Upper 8 bits (integer part)
          return

          rem Apply gravity to player
          rem Input: currentPlayer = player index (0-3), temp2 = gravity strength
MovementApplyGravity
          rem Add gravity to Y velocity
          let playerVelocityY[currentPlayer] = playerVelocityY[currentPlayer] + temp2
          return

          rem Apply friction to player
          rem Input: currentPlayer = player index (0-3), temp2 = friction strength (0-255)
ApplyFriction
          rem Apply friction to X velocity
          temp3 = playerVelocityX[currentPlayer] * temp2 / 256 
          rem Scale by friction
          let playerVelocityX[currentPlayer] = temp3
          return

          rem =================================================================
          rem COLLISION DETECTION WITH SUBPIXEL PRECISION
          rem =================================================================

          rem Check collision between two players with subpixel precision
          rem Input: temp1 = player 1 index, temp2 = player 2 index
          rem Output: temp3 = 1 if collision, 0 if not
CheckPlayerCollision
          temp3 = 0
          
          rem Get positions
          currentPlayer = temp1  : gosub GetPlayerPosition 
          rem temp2=player1 X, temp3=player1 Y
          temp5 = temp2  : temp6 = temp3 
          rem Store player1 position
          currentPlayer = temp2  : gosub GetPlayerPosition 
          rem temp2=player2 X, temp3=player2 Y
          
          rem Check X collision (8 pixel width)
          if temp2 + 8 <= temp5 then goto NoCollision
          if temp2 >= temp5 + 8 then goto NoCollision
          
          rem Check Y collision (16 pixel height)
          if temp3 + 16 <= temp6 then goto NoCollision
          if temp3 >= temp6 + 16 then goto NoCollision
          
          rem Collision detected
          temp3 = 1
          return
          
NoCollision
          temp3 = 0
          return

          rem Check wall collision with subpixel precision
          rem Input: currentPlayer = player index, temp2 = wall X position
          rem Output: temp3 = 1 if collision, 0 if not
CheckWallCollision
          temp3 = 0
          
          rem Get player position
          gosub GetPlayerPosition 
          rem temp2=X, temp3=Y
          
          rem Check X collision with wall
          if temp2 + 8 <= temp2 then goto NoWallCollision
          if temp2 >= temp2 + 8 then goto NoWallCollision
          
          rem Wall collision detected
          temp3 = 1
          return
          
NoWallCollision
          temp3 = 0
          return

          rem =================================================================
          rem MOVEMENT CONSTRAINTS
          rem =================================================================

          rem Constrain player to screen bounds
          rem Input: currentPlayer = player index (0-3)
ConstrainToScreen
          rem Get current position
          gosub GetPlayerPosition 
          rem temp2=X, temp3=Y
          
          rem Constrain X position (0 to 152 for 8-pixel wide sprite)
          if temp2 > playerSubpixelX[currentPlayer] then temp2 = 0 : playerSubpixelX[currentPlayer] = 0
          if temp2 > 152 then temp2 = 152 : playerSubpixelX[currentPlayer] = 152 << 8
          
          rem Constrain Y position (0 to 184 for 16-pixel tall sprite)
          if temp3 > playerSubpixelY[currentPlayer] then temp3 = 0 : playerSubpixelY[currentPlayer] = 0
          if temp3 > 184 then temp3 = 184 : playerSubpixelY[currentPlayer] = 184 << 8
          
          rem Update sprite positions
          gosub UpdateSpritePositions
          return

          rem =================================================================
          rem INITIALIZATION
          rem =================================================================

          rem Initialize movement system for all players
          rem Called at game start to set up initial positions
InitializeMovementSystem
          rem Initialize all players to center of screen
          currentPlayer = 0  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          currentPlayer = 1  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          currentPlayer = 2  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          currentPlayer = 3  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          
          rem Initialize velocities to zero
          currentPlayer = 0  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          currentPlayer = 1  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          currentPlayer = 2  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          currentPlayer = 3  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          return
