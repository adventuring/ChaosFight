          rem ChaosFight - Source/Routines/UpdatePlayerMovementSingle.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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
          rem Use batariBASIC's built-in 16-bit addition for carry detection
          let subpixelAccumulator = playerSubpixelX_RL[currentPlayer] + playerVelocityXL[currentPlayer]
          let playerSubpixelX_WL[currentPlayer] = temp2
          if temp3 > 0 then let playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + 1

          rem Apply integer velocity component
          let playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + playerVelocityX[currentPlayer]

          rem Sync integer position for rendering
          let playerX[currentPlayer] = playerSubpixelX_R[currentPlayer]

          rem Apply Y Velocity To Y Position (8.8 fixed-point)
          rem Use batariBASIC's built-in 16-bit addition for carry detection
          let subpixelAccumulator = playerSubpixelY_RL[currentPlayer] + playerVelocityYL[currentPlayer]
          let playerSubpixelY_WL[currentPlayer] = temp2
          if temp3 > 0 then let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + 1

          rem Apply integer velocity component
          let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + playerVelocityY[currentPlayer]

          rem Sync integer position for rendering
          let playerY[currentPlayer] = playerSubpixelY_R[currentPlayer]

          return

