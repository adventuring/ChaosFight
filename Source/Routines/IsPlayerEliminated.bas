          rem ChaosFight - Source/Routines/IsPlayerEliminated.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

IsPlayerEliminated
          asm
IsPlayerEliminated
end
          rem
          rem Is Player Eliminated
          rem Input: currentPlayer (0-3), playersEliminated_R, PlayerEliminatedPlayer0-3 masks
          rem Output: temp2 = 1 if eliminated, 0 if alive
          rem Mutates: temp2, temp6
          let temp6 = BitMask[currentPlayer]
          let temp2 = temp6 & playersEliminated_R
          if temp2 then temp2 = 1 : goto IsEliminatedDone
          let temp2 = 0
IsEliminatedDone
          return

