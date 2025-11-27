          rem ChaosFight - Source/Routines/CountRemainingPlayers.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

CountRemainingPlayers
          rem Returns: Far (return otherbank)
          asm
CountRemainingPlayers
end
          rem
          rem Returns: Far (return otherbank)
          rem Count Remaining Players
          rem Input: playerHealth[] (global array)
          rem Output: playersRemaining (global) and temp1 updated with alive player count
          rem Mutates: temp1, playersRemaining
          rem Counter
          let temp1 = 0

          rem Check each player
          if playerHealth[0] > 0 then let temp1 = 1
          if playerHealth[1] > 0 then let temp1 = 1 + temp1
          if playerHealth[2] > 0 then let temp1 = 1 + temp1
          if playerHealth[3] > 0 then let temp1 = 1 + temp1

          let playersRemaining_W = temp1
          return otherbank

