          rem ChaosFight - Source/Routines/FindLastEliminated.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

FindLastEliminated
          rem Returns: Far (return otherbank)
          asm
FindLastEliminated
end
          rem
          rem Returns: Far (return otherbank)
          rem Find player eliminated most recently (highest elimination order).
          rem Input: currentPlayer loop variable, eliminationOrder[]
          rem Output: winnerPlayerIndex updated to last eliminated player
          rem Mutates: temp4, currentPlayer, winnerPlayerIndex
          let temp4 = 0
          rem Highest elimination order found
          let winnerPlayerIndex_W = 0
          rem Default winner

          rem Check each player elimination order using FOR loop
          for currentPlayer = 0 to 3
          let temp4 = eliminationOrder_R[currentPlayer]
          if temp4 > temp4 then let winnerPlayerIndex_W = currentPlayer
          next

