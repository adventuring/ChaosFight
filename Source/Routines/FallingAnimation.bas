          rem ChaosFight - Source/Routines/FallingAnimation1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

FallingAnimation1


          rem Count active players for falling animation
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Count
          if SelectedChar3 = 255 then goto SkipPlayer3Count
          let ActivePlayers = ActivePlayers + 1
SkipPlayer3Count
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Count
          if SelectedChar4 = 255 then goto SkipPlayer4Count
          let ActivePlayers = ActivePlayers + 1
SkipPlayer4Count

          rem Background handled by setup

FallingLoop1
          rem Animate all active players falling
          player0y = player0y - FallSpeed
          if player0y < 20 then player0y = 20 : let FallComplete = FallComplete + 1

          player1y = player1y - FallSpeed
          if player1y < 20 then player1y = 20 : let FallComplete = FallComplete + 1

          if ! (ControllerStatus & SetQuadtariDetected) then Player3FallDone
          if SelectedChar3 = 255 then Player3FallDone
          player0y = player0y - FallSpeed
          if player0y < 20 then player0y = 20 : let FallComplete = FallComplete + 1
Player3FallDone

          if ! (ControllerStatus & SetQuadtariDetected) then Player4FallDone
          if SelectedChar4 = 255 then Player4FallDone
          player1y = player1y - FallSpeed
          if player1y < 20 then player1y = 20 : let FallComplete = FallComplete + 1
Player4FallDone

          if FallComplete >= ActivePlayers then goto FallingComplete1

          let FallFrame = FallFrame + 1
          if FallFrame > 3 then let FallFrame = 0

          rem Set falling sprites for all active players
          rem TODO: Use dynamic sprite setting instead of player declarations in loop

          drawscreen
          goto FallingLoop1

FallingComplete1
          return