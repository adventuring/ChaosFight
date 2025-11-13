          rem ChaosFight - Source/Routines/SetPlayerVelocity.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

SetPlayerVelocity
          rem Set player velocity (integer component, reset subpixels).
          rem Input: temp1 = player index (0-3), temp2 = X velocity, temp3 = Y velocity
          rem Output: playerVelocityX/Y updated (low bytes cleared)
          rem Mutates: playerVelocityX[], playerVelocityXL[], playerVelocityY[], playerVelocityYL[]
          rem Constraints: None
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          let playerVelocityY[temp1] = temp3
          let playerVelocityYL[temp1] = 0
          return

