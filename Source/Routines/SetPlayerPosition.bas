          rem ChaosFight - Source/Routines/SetPlayerPosition.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

SetPlayerPosition
          rem Set player position (integer coordinates, subpixels cleared).
          rem Input: temp1 = player index (0-3), temp2 = X position, temp3 = Y position
          rem Output: playerX/Y and subpixel buffers updated
          rem Mutates: playerX[], playerY[], playerSubpixelX_W/WL[], playerSubpixelY_W/WL[]
          rem Constraints: None
          let playerX[temp1] = temp2
          rem SCRAM write to playerSubpixelX_W
          let playerSubpixelX_W[temp1] = temp2
          let playerSubpixelX_WL[temp1] = 0
          let playerY[temp1] = temp3
          rem SCRAM write to playerSubpixelY_W
          let playerSubpixelY_W[temp1] = temp3
          let playerSubpixelY_WL[temp1] = 0
          return thisbank
