          rem ChaosFight - Source/Routines/FindLastEliminated.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

FindLastEliminated
          asm
FindLastEliminated
end
          rem
          rem Find player eliminated most recently (highest elimination order).
          rem Input: currentPlayer loop variable, eliminationOrder[]
          rem Output: winnerPlayerIndex updated to last eliminated player
          rem Mutates: temp4, currentPlayer, winnerPlayerIndex
          let temp4 = 0
          let winnerPlayerIndex_W = 0
          rem Highest elimination order found
          rem Default winner

          for currentPlayer = 0 to 3
          rem Check each player elimination order using FOR loop
          let temp4 = eliminationOrder_R[currentPlayer]
          if temp4 > temp4 then let winnerPlayerIndex_W = currentPlayer
          next

