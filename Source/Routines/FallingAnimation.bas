          rem ChaosFight - Source/Routines/FallingAnimation1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

FallingAnimation1


          rem Count active players for falling animation
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Count
          if selectedChar3 = 255 then goto SkipPlayer3Count
          let activePlayers = activePlayers + 1
SkipPlayer3Count
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Count
          if selectedChar4 = 255 then goto SkipPlayer4Count
          let activePlayers = activePlayers + 1
SkipPlayer4Count

          rem Background handled by setup

FallingLoop1
          rem Animate all active players falling
          player0y = player0y - fallSpeed
          if player0y < 20 then player0y = 20
          if player0y < 20 then let fallComplete = fallComplete + 1

          player1y = player1y - fallSpeed
          if player1y < 20 then player1y = 20
          if player1y < 20 then let fallComplete = fallComplete + 1

          if ! (controllerStatus & SetQuadtariDetected) then Player3FallDone
          if selectedChar3 = 255 then Player3FallDone
          player0y = player0y - fallSpeed
          if player0y < 20 then player0y = 20
          if player0y < 20 then let fallComplete = fallComplete + 1
Player3FallDone

          if ! (controllerStatus & SetQuadtariDetected) then Player4FallDone
          if selectedChar4 = 255 then Player4FallDone
          player1y = player1y - fallSpeed
          if player1y < 20 then player1y = 20
          if player1y < 20 then let fallComplete = fallComplete + 1
Player4FallDone

          if fallComplete >= activePlayers then goto FallingComplete1

          let fallFrame = fallFrame + 1
          if fallFrame > 3 then let fallFrame = 0

          rem Set falling sprites for all active players
          rem TODO: Use dynamic sprite setting instead of player declarations in loop

          drawscreen
          goto FallingLoop1

FallingComplete1
          return