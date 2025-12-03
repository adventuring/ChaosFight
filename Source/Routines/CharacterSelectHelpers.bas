          rem ChaosFight - Source/Routines/CharacterSelectHelpers.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

SelectStickLeft
          rem Handle stick-left navigation for the active player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerCharacter[] (global) = browsing selections
          rem Output: playerCharacter[currentPlayer] decremented with wrap
          rem        to MaxCharacter, lock state cleared on wrap
          rem Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          rem        SetPlayerLocked)
          rem Called Routines: SetPlayerLocked (bank6)
          rem Constraints: currentPlayer must be set by caller
          let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] - 1
          if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = MaxCharacter

          if playerCharacter[currentPlayer] > MaxCharacter then let temp1 = currentPlayer : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank6

          return thisbank

SelectStickRight
          rem Handle stick-right navigation for the active player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerCharacter[] (global) = browsing selections
          rem Output: playerCharacter[currentPlayer] incremented with wrap
          rem        to 0, lock state cleared on wrap
          rem Mutates: playerCharacter[], temp1, temp2, playerLocked (via
          rem        SetPlayerLocked)
          rem Called Routines: SetPlayerLocked (bank6)
          rem Constraints: currentPlayer must be set by caller
          let playerCharacter[currentPlayer] = playerCharacter[currentPlayer] + 1
          if playerCharacter[currentPlayer] > MaxCharacter then let playerCharacter[currentPlayer] = 0

          if playerCharacter[currentPlayer] > MaxCharacter then let temp1 = currentPlayer : temp2 = PlayerLockedUnlocked : gosub SetPlayerLocked bank6

          return thisbank
