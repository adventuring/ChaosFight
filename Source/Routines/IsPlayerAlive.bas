          rem ChaosFight - Source/Routines/IsPlayerAlive.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

IsPlayerAlive
          asm
IsPlayerAlive
end
          rem
          rem Is Player Alive
          rem Check if specified player is alive (health > 0).
          rem
          rem FIXME: Inline and remove calls to this routine.
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        playerHealth[] (global array) = player health values
          rem
          rem Output: temp2 = player health value (0 if dead, >0 if alive)
          rem         Caller should check if temp2 = 0 for dead, temp2 > 0 for alive
          rem
          rem Mutates: temp2 (set to health value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: None
          let temp2 = playerHealth[currentPlayer]
          return otherbank

