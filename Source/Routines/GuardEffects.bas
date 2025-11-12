          rem ChaosFight - Source/Routines/GuardEffects.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Guard Visual Effects System


ApplyGuardColor
          rem Apply guard color effect (light cyan for NTSC/PAL, cyan for SECAM)
          rem while a player is actively guarding.
          rem
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global) = player state flags (bit 1 = guarding)
          rem
          rem Output: Player color forced to ColCyan(12) while guarding
          rem Mutates: temp1-temp2, COLUP0, _COLUP1, COLUP2, COLUP3
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must remain colocated with GuardColor0-GuardColor3 jump table
          let temp2 = playerState[temp1] & 2
          rem Check if player is guarding
          if !temp2 then return 
          rem Not guarding
          
          rem set light cyan color
          rem Optimized: Apply guard color with computed assignment
          on temp1 goto GuardColor0 GuardColor1 GuardColor2 GuardColor3
GuardColor0
          COLUP0 = ColCyan(12)
          return
GuardColor1
          _COLUP1 = ColCyan(12)
          return
GuardColor2
          COLUP2 = ColCyan(12)
          return
GuardColor3
          COLUP3 = ColCyan(12)
          return

RestoreNormalPlayerColor
          rem Provide shared entry point for restoring normal player colors
          rem after guard tinting. Color reload executed by rendering code.
          rem
          rem Input: temp1 = player index (0-3)
          rem
          rem Output: None
          rem
          rem Mutates: temp4 (loads character index for downstream routines)
          let temp4 = playerCharacter[temp1]
          return


CheckGuardCooldown
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

StartGuard
          rem
          rem Start Guard
          rem Activate guard state for the specified player.
          rem Input: temp1 = player index (0-3)
          rem        GuardTimerMaxFrames (constant) = guard duration in
          rem        frames
          rem
          rem Output: playerState[] guard bit set, playerTimers_W[] set
          rem to guard duration
          rem
          rem Mutates: playerState[] (guard bit set), playerTimers_W[]
          rem (set to GuardTimerMaxFrames)
          rem
          rem Called Routines: None
          rem Constraints: None
          let playerState[temp1] = playerState[temp1] | 2
          rem Set guard bit in playerState
          
          rem Set guard duration timer using GuardTimerMaxFrames (TV-standard aware)
          rem Store guard duration timer in playerTimers array
          rem This timer will be decremented each frame until it reaches 0
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          
          return

UpdateGuardTimers
          asm
          UpdateGuardTimers = .UpdateGuardTimers
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
            gosub UpdateSingleGuardTimer
          next
          return

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

          asm
StartGuard = .StartGuard
end
