          rem ChaosFight - Source/Routines/MovementApplyGravity.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

MovementApplyGravity
          rem Apply gravity to player velocity (integer component only).
          rem Input: temp1 = player index (0-3), temp2 = gravity strength (integer, positive downward)
          rem Output: playerVelocityY[] incremented by gravity strength
          rem Mutates: playerVelocityY[]
          rem Constraints: For subpixel gravity, call AddVelocitySubpixelY separately
          let playerVelocityY[temp1] = playerVelocityY[temp1] + temp2
          return thisbank
