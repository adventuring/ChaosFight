          rem ChaosFight - Source/Routines/UpdateGuardTimers.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateGuardTimers
          asm
UpdateGuardTimers
end
          rem
          rem Update guard duration and cooldown timers each frame (invoked from main loop).
          rem Input: None
          rem Output: Guard timers refreshed for all players
          rem Mutates: temp1 (0-3), playerTimers_W[] (decremented), playerState[] (guard bit cleared)
          rem
          rem Called Routines: UpdateSingleGuardTimer - updates guard
          rem timer for one player
          rem
          rem Constraints: Tail call to UpdateSingleGuardTimer for
          rem player 3
          rem Optimized: Loop through all players instead of individual calls
          for temp1 = 0 to 3
          gosub UpdateSingleGuardTimer bank10
          next
          return

