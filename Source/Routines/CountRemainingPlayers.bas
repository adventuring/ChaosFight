          rem ChaosFight - Source/Routines/CountRemainingPlayers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CountRemainingPlayers
          asm
CountRemainingPlayers
end
          rem
          rem Count Remaining Players
          rem Input: playersEliminated_R (SCRAM flags), PlayerEliminatedPlayer0-3 masks
          rem Output: playersRemaining (global) and temp1 updated with alive player count
          rem Mutates: temp1, playersRemaining
          let temp1 = 0
          rem Counter

          rem Check each player
          if (PlayerEliminatedPlayer0 & playersEliminated_R) = 0 then temp1 = 1 + temp1
          if (PlayerEliminatedPlayer1 & playersEliminated_R) = 0 then temp1 = 1 + temp1
          if (PlayerEliminatedPlayer2 & playersEliminated_R) = 0 then temp1 = 1 + temp1
          if (PlayerEliminatedPlayer3 & playersEliminated_R) = 0 then temp1 = 1 + temp1

          let playersRemaining_W = temp1
          return

