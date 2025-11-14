          rem ChaosFight - Source/Routines/CheckGuardCooldown.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

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
          let temp3 = playerState[temp1] & 2
          rem Check if player is currently guarding
          if temp3 then GuardCooldownBlocked

          rem Check cooldown timer (stored in playerTimers array)
          let temp3 = playerTimers_R[temp1]
          rem playerTimers stores frames remaining in cooldown

          if temp3 > 0 then GuardCooldownBlocked

          let temp2 = 1
          rem Cooldown expired, guard allowed
          return

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
          let temp2 = 0
          rem   new guard
          return

