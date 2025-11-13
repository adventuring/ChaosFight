          rem ChaosFight - Source/Routines/UpdateSingleGuardTimer.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateSingleGuardTimer
          rem Update guard timer or cooldown for a single player
          rem
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global array) = player state flags
          rem        (bit 1 = guarding)
          rem        playerTimers_R[] (global SCRAM array) = guard
          rem        duration or cooldown timer
          rem        GuardTimerMaxFrames (constant) = guard duration in
          rem        frames
          rem        MaskClearGuard (constant) = bitmask to clear guard
          rem        bit
          rem
          rem Output: playerTimers_W[] decremented, playerState[] guard
          rem bit cleared when expired,
          rem         cooldown started when guard expires
          rem
          rem Mutates: temp1-temp3 (used for calculations),
          rem playerTimers_W[] (decremented),
          rem         playerState[] (guard bit cleared when expired)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem UpdateGuardTimerActive, GuardTimerExpired (called via
          rem goto)
          rem Update guard timer or cooldown for a single player
          rem
          rem INPUT: temp1 = player index (0-3)
          rem        playerState = player state flags (bit 1 = guarding)
          rem        playerTimers = guard duration or cooldown timer
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: If guarding: decrements guard duration timer,
          rem   clears guard and starts cooldown when expired
          rem If not guarding: decrements cooldown timer (if active)
          let temp2 = playerState[temp1] & 2
          rem Check if player is guarding
          if temp2 then UpdateGuardTimerActive

          rem Player not guarding - decrement cooldown timer
          let temp3 = playerTimers_R[temp1]
          rem Fix RMW: Read from _R, modify, write to _W
          if temp3 = 0 then return
          let temp3 = temp3 - 1
          rem No cooldown active
          let playerTimers_W[temp1] = temp3
          return

UpdateGuardTimerActive
          rem Player is guarding - decrement guard duration timer
          rem
          rem Input: temp1 (from UpdateSingleGuardTimer),
          rem playerTimers_R[] (global SCRAM array)
          rem
          rem Output: playerTimers_W[] decremented, dispatches to
          rem GuardTimerExpired when timer reaches 0
          rem
          rem Mutates: temp3 (timer value), playerTimers_W[]
          rem (decremented)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with UpdateSingleGuardTimer, GuardTimerExpired
          let temp3 = playerTimers_R[temp1]
          rem Player is guarding - decrement guard duration timer
          if temp3 = 0 then GuardTimerExpired
          rem Guard timer already expired (shouldn’t happen, but safety
          rem   check)

          let temp3 = temp3 - 1
          rem Decrement guard duration timer
          let playerTimers_W[temp1] = temp3
          if temp3 = 0 then GuardTimerExpired
          return

GuardTimerExpired
          rem Guard duration expired - clear guard bit and start
          rem cooldown
          rem
          rem Input: temp1 (from UpdateGuardTimerActive),
          rem playerState[] (global array),
          rem        GuardTimerMaxFrames (constant)
          rem
          rem Output: playerState[] guard bit cleared, playerTimers_W[]
          rem set to cooldown duration
          rem
          rem Mutates: playerState[] (guard bit cleared),
          rem playerTimers_W[] (set to GuardTimerMaxFrames)
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with UpdateSingleGuardTimer, UpdateGuardTimerActive
          let playerState[temp1] = playerState[temp1] & MaskClearGuard
          rem Start cooldown timer (same duration as guard)
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          return

