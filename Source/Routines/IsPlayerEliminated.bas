          rem ChaosFight - Source/Routines/IsPlayerEliminated.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

IsPlayerEliminated
          asm
IsPlayerEliminated
end
          rem
          rem Is Player Eliminated
          rem Input: currentPlayer (0-3), playerHealth[]
          rem Output: temp2 = 1 if eliminated, 0 if alive
          rem Mutates: temp2
          let temp2 = playerHealth[currentPlayer]
          if temp2 = 0 then temp2 = 1 : goto IsEliminatedDone
          let temp2 = 0
IsEliminatedDone
          return otherbank
