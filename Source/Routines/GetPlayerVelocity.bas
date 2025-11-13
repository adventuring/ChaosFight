          rem ChaosFight - Source/Routines/GetPlayerVelocity.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

GetPlayerVelocity
          rem Get player velocity (integer components only).
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerVelocityX[], playerVelocityY[] (global arrays)
          rem Output: temp2 = X velocity, temp3 = Y velocity
          rem Mutates: temp2, temp3
          rem Constraints: Callers should use the values immediately; temps are volatile.
          let temp2 = playerVelocityX[currentPlayer]
          let temp3 = playerVelocityY[currentPlayer]
          return

