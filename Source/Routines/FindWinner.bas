          rem ChaosFight - Source/Routines/FindWinner.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

FindWinner
          asm
FindWinner
end
          rem
          rem Find Winner
          rem Identify the last standing player.
          rem Input: currentPlayer (loop), playerHealth[], eliminationOrder[]
          rem Output: winnerPlayerIndex (0-3, 255 if all eliminated)
          rem Mutates: temp2, currentPlayer, winnerPlayerIndex
          rem Calls: IsPlayerEliminated, FindLastEliminated (if needed)
          let winnerPlayerIndex_W = 255
          rem Find the player who is not eliminated
          rem Invalid initially

          for currentPlayer = 0 to 3
          rem Check each player using FOR loop
          gosub IsPlayerEliminated bank13
          if !temp2 then let winnerPlayerIndex_W = currentPlayer
          next

          rem If no winner found (all eliminated), pick last eliminated
          rem tail call
          if winnerPlayerIndex_R = 255 then goto FindLastEliminated bank14
          return

