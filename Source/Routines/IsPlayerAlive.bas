          rem ChaosFight - Source/Routines/IsPlayerAlive.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

IsPlayerAlive
          asm
IsPlayerAlive
end
          rem
          rem Is Player Alive
          rem Check if specified player is alive (not eliminated AND
          rem   health > 0).
          rem
          rem Input: currentPlayer (0-3), playerHealth[], playersEliminated_R
          rem Output: temp2 = 1 if alive, 0 if eliminated/dead
          rem Mutates: temp2, temp3
          rem Calls: IsPlayerEliminated
          gosub IsPlayerEliminated bank12
          rem Check elimination flag first
          if temp2 then return
          rem Already eliminated

          let temp3 = playerHealth[currentPlayer]
          rem Check health

          let temp2 = 0
          rem Default: not alive
          if temp3 > 0 then temp2 = 1
          rem Alive if health > 0
          return

