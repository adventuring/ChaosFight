          rem ChaosFight - Source/Routines/FallingAnimation.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

FallingAnimation
          dim FallFrame = a
          dim FallSpeed = b
          dim FallComplete = c
          dim ActivePlayers = d

          FallFrame = 0
          FallSpeed = 2
          FallComplete = 0
          ActivePlayers = 2

          rem Count active players for falling animation
          if QuadtariDetected && SelectedChar3 != 0 then ActivePlayers = ActivePlayers + 1
          if QuadtariDetected && SelectedChar4 != 0 then ActivePlayers = ActivePlayers + 1

          COLUBK = ColBlue(8)

FallingLoop
          rem Animate all active players falling
          player0y = player0y - FallSpeed
          if player0y < 20 then player0y = 20 : FallComplete = FallComplete + 1

          player1y = player1y - FallSpeed
          if player1y < 20 then player1y = 20 : FallComplete = FallComplete + 1

          if QuadtariDetected && SelectedChar3 != 0 then
                    player0y = player0y - FallSpeed
                    if player0y < 20 then player0y = 20 : FallComplete = FallComplete + 1
          endif

          if QuadtariDetected && SelectedChar4 != 0 then
                    player1y = player1y - FallSpeed
                    if player1y < 20 then player1y = 20 : FallComplete = FallComplete + 1
          endif

          if FallComplete >= ActivePlayers then goto FallingComplete

          FallFrame = FallFrame + 1
          if FallFrame > 3 then FallFrame = 0

          rem Set falling sprites for all active players
          player0:
          %00011000
          %00111100
          %01111110
          %00011000
          %00011000
          %00011000
          %00011000
          %00011000
          end

          player1:
          %00011000
          %00111100
          %01111110
          %00011000
          %00011000
          %00011000
          %00011000
          %00011000
          end

          drawscreen
          goto FallingLoop

FallingComplete
          return