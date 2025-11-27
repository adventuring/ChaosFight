          rem ChaosFight - Source/Routines/UpdateAttackCooldowns.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

UpdateAttackCooldowns
          rem Returns: Far (return otherbank)
          asm
UpdateAttackCooldowns
end
          rem
          rem Returns: Far (return otherbank)
          rem Update attack cooldown timers each frame (invoked from main loop).
          rem Decrements playerAttackCooldown_W[0-3] timers if > 0.
          rem Input: None
          rem Output: Attack cooldown timers decremented for all players
          rem Mutates: temp1 (0-3), playerAttackCooldown_W[] (decremented if > 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be in same bank as GameLoopMain (Bank 11)
          rem Optimized: Loop through all players instead of individual calls
          for temp1 = 0 to 3
          let temp2 = playerAttackCooldown_R[temp1]
          if temp2 = 0 then UpdateAttackCooldownSkip
          let temp2 = temp2 - 1
          let playerAttackCooldown_W[temp1] = temp2
UpdateAttackCooldownSkip
          next
          return thisbank
