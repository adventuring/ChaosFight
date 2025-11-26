          rem ChaosFight - Source/Routines/InitializeMovementSystem.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

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
          rem   performance
          let temp2 = 80
          let temp3 = 100
          rem Player 0
          let playerX[0] = temp2
          let playerSubpixelX_W[0] = temp2
          let playerSubpixelX_WL[0] = 0
          let playerY[0] = temp3
          let playerSubpixelY_W[0] = temp3
          let playerSubpixelY_WL[0] = 0
          rem Player 1
          let playerX[1] = temp2
          let playerSubpixelX_W[1] = temp2
          let playerSubpixelX_WL[1] = 0
          let playerY[1] = temp3
          let playerSubpixelY_W[1] = temp3
          let playerSubpixelY_WL[1] = 0
          rem Player 2
          let playerX[2] = temp2
          let playerSubpixelX_W[2] = temp2
          let playerSubpixelX_WL[2] = 0
          let playerY[2] = temp3
          let playerSubpixelY_W[2] = temp3
          let playerSubpixelY_WL[2] = 0
          rem Player 3
          let playerX[3] = temp2
          let playerSubpixelX_W[3] = temp2
          let playerSubpixelX_WL[3] = 0
          let playerY[3] = temp3
          let playerSubpixelY_W[3] = temp3
          let playerSubpixelY_WL[3] = 0

          rem Initialize velocities to zero - inlined for performance
          rem Player 0
          let playerVelocityX[0] = 0
          let playerVelocityXL[0] = 0
          let playerVelocityY[0] = 0
          let playerVelocityYL[0] = 0
          rem Player 1
          let playerVelocityX[1] = 0
          let playerVelocityXL[1] = 0
          let playerVelocityY[1] = 0
          let playerVelocityYL[1] = 0
          rem Player 2
          let playerVelocityX[2] = 0
          let playerVelocityXL[2] = 0
          let playerVelocityY[2] = 0
          let playerVelocityYL[2] = 0
          rem Player 3
          let playerVelocityX[3] = 0
          let playerVelocityXL[3] = 0
          let playerVelocityY[3] = 0
          let playerVelocityYL[3] = 0
          return thisbank
