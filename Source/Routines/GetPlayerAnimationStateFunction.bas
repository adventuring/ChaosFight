          rem ChaosFight - Source/Routines/GetPlayerAnimationStateFunction.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

GetPlayerAnimationStateFunction
          asm
GetPlayerAnimationStateFunction

end
          rem Animation State Helper
          rem
          rem Input: temp1 = player index (0-3), playerState[]
          rem Output: temp2 = animation state (bits 4-7 of playerState)
          rem
          rem Mutates: temp2 (used as return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2 = playerState[temp1] & 240
          let temp2 = temp2 / 16
          rem Mask bits 4-7 (value 240 = %11110000)
          rem Shift right by 4 (divide by 16) to get animation state
          rem   (0-15)
          return

