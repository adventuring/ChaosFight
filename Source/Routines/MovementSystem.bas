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
          temp1 = 0  : gosub UpdatePlayerMovementSingle 
          rem Player 1
          temp1 = 1  : gosub UpdatePlayerMovementSingle 
          rem Player 2
          if QuadtariDetected then temp1 = 2  : gosub UpdatePlayerMovementSingle  : temp1 = 3  : gosub UpdatePlayerMovementSingle
          return

          rem Update movement for a specific player
          rem Input: temp1 = player index (0-3)
UpdatePlayerMovementSingle
          rem Skip if player is eliminated
          if PlayerHealth[temp1] = 0 then return
          
          rem Update subpixel positions with velocity
          PlayerSubpixelX[temp1] = PlayerSubpixelX[temp1] + PlayerVelocityX[temp1]
          PlayerSubpixelY[temp1] = PlayerSubpixelY[temp1] + PlayerVelocityY[temp1]
          
          rem Convert subpixel positions to sprite positions
          gosub UpdateSpritePositions
          
          return

          rem Convert subpixel positions to sprite positions
          rem Input: temp1 = player index (0-3)
UpdateSpritePositions
          rem Convert 8.8 fixed-point to 8-bit sprite X
          temp2 = PlayerSubpixelX[temp1] >> 8 
          rem Upper 8 bits (integer part)
          temp3 = PlayerSubpixelY[temp1] >> 8 
          rem Upper 8 bits (integer part)
          
          rem Set sprite positions based on player index
          if temp1 = 0 then player0x = temp2 : player0y = temp3
          if temp1 = 1 then player1x = temp2 : player1y = temp3
          if temp1 = 2 then player2x = temp2 : player2y = temp3
          if temp1 = 3 then player3x = temp2 : player3y = temp3
          
          return

          rem Set player velocity
          rem Input: temp1 = player index (0-3), temp2 = X velocity, temp3 = Y velocity
SetPlayerVelocity
          rem Set 8.8 fixed-point velocities (input already in 8.8 format)
          PlayerVelocityX[temp1] = temp2
          PlayerVelocityY[temp1] = temp3
          return

          rem Set player position
          rem Input: temp1 = player index (0-3), temp2 = X position, temp3 = Y position
SetPlayerPosition
          rem Set 8.8 fixed-point positions (input already in 8.8 format)
          PlayerSubpixelX[temp1] = temp2
          PlayerSubpixelY[temp1] = temp3
          
          rem Update sprite positions immediately
          gosub UpdateSpritePositions
          return

          rem Get player position
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = X position, temp3 = Y position
GetPlayerPosition
          temp2 = PlayerSubpixelX[temp1] >> 8 
          rem Upper 8 bits (integer part)
          temp3 = PlayerSubpixelY[temp1] >> 8 
          rem Upper 8 bits (integer part)
          return

          rem Get player velocity
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = X velocity, temp3 = Y velocity
GetPlayerVelocity
          temp2 = PlayerVelocityX[temp1] >> 8 
          rem Upper 8 bits (integer part)
          temp3 = PlayerVelocityY[temp1] >> 8 
          rem Upper 8 bits (integer part)
          return

          rem Apply gravity to player
          rem Input: temp1 = player index (0-3), temp2 = gravity strength
MovementApplyGravity
          rem Add gravity to Y velocity
          PlayerVelocityY[temp1] = PlayerVelocityY[temp1] + temp2
          return

          rem Apply friction to player
          rem Input: temp1 = player index (0-3), temp2 = friction strength (0-255)
ApplyFriction
          rem Apply friction to X velocity
          temp3 = PlayerVelocityX[temp1] * temp2 / 256 
          rem Scale by friction
          PlayerVelocityX[temp1] = temp3
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
          temp4 = temp1  : gosub GetPlayerPosition 
          rem temp2=player1 X, temp3=player1 Y
          temp5 = temp2  : temp6 = temp3 
          rem Store player1 position
          temp1 = temp2  : gosub GetPlayerPosition 
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
          rem Input: temp1 = player index, temp2 = wall X position
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
          rem Input: temp1 = player index (0-3)
ConstrainToScreen
          rem Get current position
          gosub GetPlayerPosition 
          rem temp2=X, temp3=Y
          
          rem Constrain X position (0 to 152 for 8-pixel wide sprite)
          if temp2 > PlayerSubpixelX[temp1] then temp2 = 0 : PlayerSubpixelX[temp1] = 0
          if temp2 > 152 then temp2 = 152 : PlayerSubpixelX[temp1] = 152 << 8
          
          rem Constrain Y position (0 to 184 for 16-pixel tall sprite)
          if temp3 > PlayerSubpixelY[temp1] then temp3 = 0 : PlayerSubpixelY[temp1] = 0
          if temp3 > 184 then temp3 = 184 : PlayerSubpixelY[temp1] = 184 << 8
          
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
          temp1 = 0  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          temp1 = 1  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          temp1 = 2  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          temp1 = 3  : temp2 = 80  : temp3 = 100  : gosub SetPlayerPosition
          
          rem Initialize velocities to zero
          temp1 = 0  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          temp1 = 1  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          temp1 = 2  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          temp1 = 3  : temp2 = 0  : temp3 = 0  : gosub SetPlayerVelocity
          return
