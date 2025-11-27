          rem ChaosFight - Source/Routines/GetPlayerAnimationStateFunction.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

GetPlayerAnimationStateFunction
          rem Returns: Far (return otherbank)
          asm
GetPlayerAnimationStateFunction

end
          rem Animation State Helper
          rem
          rem Input: temp1 = player index (0-3), playerState[]
          rem Output: temp2 = animation state (bits 4-7 of playerState)
          rem
          rem Mutates: temp2 (used as return otherbank value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          rem Shift right by 4 (divide by 16) to get animation state
          let temp2 = playerState[temp1] / 16
          rem   (0-15)
          return otherbank

