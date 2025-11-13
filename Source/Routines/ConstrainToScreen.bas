          rem ChaosFight - Source/Routines/ConstrainToScreen.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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

