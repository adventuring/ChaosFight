ApplyGuardFlashing
          rem
          rem ChaosFight - Source/Routines/GuardEffects.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Guard Visual Effects System
          rem Implements guard flashing visual feedback as specified in
          rem   manual:
          rem - Character flashes light cyan ColCyan(12) in NTSC/PAL
          rem - Character flashes Cyan in SECAM
          rem
          rem - Guard lasts maximum 1 second (60 frames)
          rem - Guard cannot be used again for 1 second after previous
          rem   use
          rem Apply guard flashing effect (light cyan for NTSC/PAL, cyan for SECAM).
          rem Input: temp1 = player index (0-3) for color restoration
          rem        playerState[] (global) = player state flags (bit 1 = guarding)
          rem        frame (global) = frame counter
          rem Output: Player color alternates between cyan flash and normal palette
          rem Mutates: temp1-temp4, COLUP0, COLUP1, COLUP2, COLUP3
          rem
          rem Called Routines: GuardNormalPhase (tail call via goto) -
          rem restores normal color
          rem
          rem Constraints: Flash every 4 frames (frames 0-1 = flash,
          rem frames 2-3 = normal). SECAM uses ColCyan(6), NTSC/PAL uses
          rem ColCyan(12). Only applies if player is guarding (bit 1
          rem set)
          let temp2 = playerState[temp1] & 2
          rem Check if player is guarding
          if !temp2 then return 
          rem Not guarding
          
          let temp3 = frame & 3
          rem Flash every 4 frames for visible effect
          if temp3 >= 2 then goto GuardNormalPhase
          rem Flash phase - set light cyan color
          rem Optimized: Apply guard flash color with computed assignment
          let temp4 = ColCyan(12)
          rem Bright cyan guard flash (SECAM maps to cyan)
          on temp1 goto GuardFlash0 GuardFlash1 GuardFlash2 GuardFlash3
          return
GuardFlash0
          COLUP0 = temp4
          return
GuardFlash1
          _COLUP1 = temp4
          return
GuardFlash2
          COLUP2 = temp4
          return
GuardFlash3
          COLUP3 = temp4
          return

GuardNormalPhase
          rem Helper: Normal phase - restore normal player colors
          rem
          rem Input: temp1 = player index (0-3), playerCharacter[] (global
          rem array) = player character selections
          rem
          rem Output: Normal player colors restored
          rem
          rem Mutates: None (colors restored by
          rem RestoreNormalPlayerColor)
          rem
          rem Called Routines: RestoreNormalPlayerColor (tail call via
          rem goto) - restores normal colors
          rem
          rem Constraints: Internal helper for ApplyGuardFlashing, only
          rem called during normal phase (frames 2-3)
          rem Normal phase - restore normal player colors
          goto RestoreNormalPlayerColor
          rem tail call

RestoreNormalPlayerColor
          rem
          rem Restore Normal Player Color
          rem Reset player palette after guard flashing.
          rem Input: temp1 = player index (0-3) requesting guard
          rem        playerCharacter[] (global array) = player character
          rem        selections
          rem
          rem Output: None (colors restored by LoadCharacterColors in
          rem PlayerRendering.bas)
          rem
          rem Mutates: None (colors already set by LoadCharacterColors)
          rem
          rem Called Routines: None (colors handled by
          rem LoadCharacterColors)
          rem Constraints: None
          let temp4 = playerCharacter[temp1]
          rem Get character type for this player
          
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
          
          rem Set guard duration timer (platform-specific: 60 frames
          rem   NTSC, 50 frames PAL/SECAM)
          rem Store guard duration timer in playerTimers array
          rem This timer will be decremented each frame until it reaches 0
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          
          return

UpdateGuardTimers
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
