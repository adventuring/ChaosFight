          rem ChaosFight - Source/Routines/AddVelocitySubpixelY.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

AddVelocitySubpixelY
          rem Add fractional gravity to Y velocity (subpixel component).
          rem Input: temp1 = player index (0-3), temp2 = subpixel amount (0-255)
          rem Output: playerVelocityYL[] incremented; playerVelocityY[] increments on carry
          rem Mutates: temp2-temp4, playerVelocityY[], playerVelocityYL[]
          rem Constraints: Uses 16-bit accumulator; carry promotes to integer component
          rem Save subpixel amount before using temp2 for accumulator
          let temp4 = temp2
          rem 16-bit accumulator for proper carry detection
          let subpixelAccumulator = playerVelocityYL[temp1] + temp4
          rem Use saved amount in accumulator
          if temp3 > 0 then VelocityYCarry
          rem No carry: temp3 = 0, use low byte directly
          let playerVelocityYL[temp1] = temp2
          return
VelocityYCarry
          rem Helper: Handles carry from subpixel to integer part
          rem
          rem Input: temp2 = wrapped low byte, temp1 = player
          rem index, playerVelocityY[] (global array) = Y velocities
          rem
          rem Output: Subpixel part set, integer part incremented
          rem
          rem Mutates: playerVelocityYL[] (global array) = Y velocity
          rem subpixel (set), playerVelocityY[] (global array) = Y
          rem velocity integer (incremented)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal helper for AddVelocitySubpixelY,
          rem only called when carry detected
          let playerVelocityYL[temp1] = temp2
          rem Carry detected: temp3 > 0, extract wrapped low byte
          let playerVelocityY[temp1] = playerVelocityY[temp1] + 1
          return

