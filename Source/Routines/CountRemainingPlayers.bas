          rem ChaosFight - Source/Routines/CountRemainingPlayers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CountRemainingPlayers
          asm
CountRemainingPlayers
end
          rem
          rem Count Remaining Players
          rem Input: playerHealth[] (global array)
          rem Output: playersRemaining (global) and temp1 updated with alive player count
          rem Mutates: temp1, playersRemaining
          let temp1 = 0
          rem Counter

          rem Check each player
          if playerHealth[0] > 0 then let temp1 = 1
          if playerHealth[1] > 0 then let temp1 = 1 + temp1
          if playerHealth[2] > 0 then let temp1 = 1 + temp1
          if playerHealth[3] > 0 then let temp1 = 1 + temp1

          let playersRemaining_W = temp1
          return otherbank

