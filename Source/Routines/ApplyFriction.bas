          rem ChaosFight - Source/Routines/ApplyFriction.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ApplyFriction
          rem Apply friction to player X velocity (simple decrement/increment).
          rem Input: temp1 = player index (0-3), playerVelocityX[], playerVelocityXL[]
          rem Output: X velocity reduced by 1 toward zero; subpixel cleared when velocity hits zero
          rem Mutates: playerVelocityX[], playerVelocityXL[]
          rem
          rem Constraints: Simple decrement approach for 8-bit CPU.
          rem Positive velocities (>0 and not negative) decremented,
          rem negative velocities (≥128 in two’s complement) incremented
          rem Check for negative velocity using twos complement (values
          if playerVelocityX[temp1] > 0 then let playerVelocityX[temp1] = playerVelocityX[temp1] - 1
          rem ≥ 128 are negative)
          rem Also zero subpixel if velocity reaches zero
          if playerVelocityX[temp1] & $80 then let playerVelocityX[temp1] = playerVelocityX[temp1] + 1
          if playerVelocityX[temp1] = 0 then let playerVelocityXL[temp1] = 0
          return thisbank
