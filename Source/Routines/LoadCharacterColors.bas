          rem ChaosFight - Source/Routines/LoadCharacterColors.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Player color loading function - colors are player-specific, not character-specific

LoadCharacterColors
          rem Input: currentPlayer (global) = player index (0-3)
          rem        temp2 = hurt state (0 = not hurt, ¬0 = hurt)
          rem        temp3 = guarding (0 = not guarding, ¬0 = guarding)

          rem Output: sets temp6 to the color for the player
          if temp3 then temp6 = ColCyan(12) : return
          if temp2 then temp6 = PlayerColors6[currentPlayer] : return
          temp6 = PlayerColors12[currentPlayer]
          return

