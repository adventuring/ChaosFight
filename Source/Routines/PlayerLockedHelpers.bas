          rem ChaosFight - Source/Routines/PlayerLockedHelpers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

GetPlayerLocked
          asm
GetPlayerLocked

end
          rem Player Locked Helper Functions
          rem Helper functions to access bit-packed playerLocked
          rem variable
          rem playerLocked is a single byte with 2 bits per player:
          rem   Bits 0-1: Player 0 (0=unlocked, 1=normal, 2=handicap)
          rem
          rem   Bits 2-3: Player 1
          rem   Bits 4-5: Player 2
          rem   Bits 6-7: Player 3
          rem Get Player Locked State
          rem Input: temp1 = player index (0-3), playerLocked (bit-packed)
          rem Output: temp2 = locked state (0=unlocked, 1=normal, 2=handicap)
          rem         GPL_lockedState = same as temp2
          rem Mutates: temp2, GPL_lockedState
          rem
          rem Called Routines: None
          rem Constraints: None

          rem Invalid index check (temp1 should be 0-3)
          rem if temp1 < 0 then temp2 = 0 : return
          if temp1 > 3 then temp2 = 0 : GPL_lockedState = temp2 : return

          rem Extract 2 bits for this player
          rem Optimized: Use on...goto jump table for O(1) dispatch
          rem Use division and masking operations compatible with batariBASIC
          on temp1 goto GetPlayerLockedP0 GetPlayerLockedP1 GetPlayerLockedP2 GetPlayerLockedP3
GetPlayerLockedP0
          temp2 = playerLocked & 3
          GPL_lockedState = temp2
          return otherbank
GetPlayerLockedP1
          temp2 = (playerLocked / 4) & 3
          GPL_lockedState = temp2
          return otherbank
GetPlayerLockedP2
          temp2 = (playerLocked / 16) & 3
          GPL_lockedState = temp2
          return otherbank
GetPlayerLockedP3
          temp2 = (playerLocked / 64) & 3
          GPL_lockedState = temp2
          return otherbank

SetPlayerLocked
          asm
SetPlayerLocked
end
          rem
          rem Set Player Locked State
          rem Sets the locked state for a specific player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        temp1 (fallback) = player index (0-3) when
          rem        currentPlayer is out of range
          rem        temp2 = locked state (0=unlocked, 1=normal,
          rem        2=handicap)
          rem Output: playerLocked (global) updated with new state for
          rem        specified player
          rem Mutates: playerLocked (global), currentPlayer (global)
          rem Called Routines: None
          rem Constraints: currentPlayer preferred; temp1 retained for
          rem        legacy callers

          rem Determine player index from currentPlayer when valid
          let temp3 = currentPlayer
          rem if temp3 > 3 then goto SetPlayerLockedUseTemp
          goto SetPlayerLockedApply

SetPlayerLockedUseTemp
          let temp3 = temp1
          rem if temp3 > 3 then return

SetPlayerLockedApply
          let currentPlayer = temp3

          rem Clear the 2 bits for this player and set the new value
          if temp3 = 0 then playerLocked = (playerLocked & 252) | temp2 : return
          if temp3 = 1 then playerLocked = (playerLocked & 243) | (temp2 * 4) : return
          if temp3 = 2 then playerLocked = (playerLocked & 207) | (temp2 * 16) : return
          if temp3 = 3 then playerLocked = (playerLocked & 63) | (temp2 * 64) : return

          return otherbank

