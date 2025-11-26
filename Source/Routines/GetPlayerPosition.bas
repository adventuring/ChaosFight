          rem ChaosFight - Source/Routines/GetPlayerPosition.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

GetPlayerPosition
          rem Get player position (integer components only).
          rem Input: currentPlayer (global) = player index (0-3)
          rem Output: temp2 = X position, temp3 = Y position
          rem Mutates: temp2, temp3
          rem Constraints: Callers should consume the values immediately; temps are volatile.
          let temp2 = playerX[currentPlayer]
          let temp3 = playerY[currentPlayer]
          return thisbank
