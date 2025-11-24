          rem ChaosFight - Source/Routines/DeactivatePlayerMissiles.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

DeactivatePlayerMissiles
          asm
DeactivatePlayerMissiles
end
          rem
          rem Deactivate Player Missiles
          rem Input: currentPlayer (0-3), missileActive flags
          rem Output: Clears this player’s missile bit
          rem Mutates: missileActive
          rem Clear missile active bit for this player
          let missileActive = missileActive & PlayerANDMask[currentPlayer]
          return

          rem AND masks to clear player missile bits (inverted BitMask values)
          data PlayerANDMask
            $FE, $FD, $FB, $F7
end

