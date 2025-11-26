          rem ChaosFight - Source/Routines/CheckGuardCooldown.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

CheckGuardCooldown
          asm
CheckGuardCooldown

end
          rem
          rem Check guard cooldown (1 second lockout after guard ends).
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        (bit 1 = guarding)
          rem        playerTimers_R[] (global SCRAM array) = guard
          rem        cooldown timers
          rem
          rem Output: temp2 = 1 if guard allowed, 0 if in cooldown
          rem
          rem Mutates: temp2 (set to 0 or 1)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with GuardCooldownBlocked (called via goto)
          rem Check if player is currently guarding
          let temp3 = playerState[temp1] & 2
          if temp3 then GuardCooldownBlocked

          rem Check cooldown timer (stored in playerTimers array)
          rem playerTimers stores frames remaining in cooldown
          let temp3 = playerTimers_R[temp1]

          if temp3 > 0 then GuardCooldownBlocked

          rem Cooldown expired, guard allowed
          let temp2 = 1
          return otherbank

GuardCooldownBlocked
          rem Currently guarding or in cooldown - not allowed to start
          rem new guard
          rem
          rem Input: None (called from CheckGuardCooldown)
          rem
          rem Output: temp2 set to 0
          rem
          rem Mutates: temp2 (set to 0)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with CheckGuardCooldown
          rem Currently guarding or in cooldown - not allowed to start
          rem   new guard
          let temp2 = 0
          return otherbank
