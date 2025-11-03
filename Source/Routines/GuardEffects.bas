          rem ChaosFight - Source/Routines/GuardEffects.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem GUARD VISUAL EFFECTS SYSTEM
          rem =================================================================
          rem Implements guard flashing visual feedback as specified in manual:
          rem - Character flashes light cyan ColCyan(12) in NTSC/PAL
          rem - Character flashes Cyan in SECAM
          rem - Guard lasts maximum 1 second (60 frames)
          rem - Guard cannot be used again for 1 second after previous use
          rem =================================================================

          rem =================================================================
          rem APPLY GUARD VISUAL EFFECTS
          rem =================================================================
          rem Applies guard flashing effect to a guarding player
          rem INPUT: temp1 = player index (0-3)
          rem USES: playerState[temp1], frame counter for flashing
ApplyGuardFlashing
          rem Check if player is guarding
          let temp2  = playerState[temp1] & 2
          if !temp2 then return 
          rem Not guarding
          
          rem Flash every 4 frames for visible effect
          let temp3  = frame & 3
          if temp3 >= 2 then goto GuardNormalPhase
          rem Flash phase - set light cyan color
#ifdef TV_SECAM
          rem SECAM uses player-based colors (always cyan for guard)
          if temp1 = 0 then COLUP0 = ColorSECAMCyan
          rem Player 1 - Cyan
          if temp1 = 1 then _COLUP1 = ColorSECAMCyan
          rem Player 2 - Cyan
          if temp1 = 2 then COLUP2 = ColorSECAMCyan
          rem Player 3 - Cyan (multisprite kernel)
          if temp1 = 3 then COLUP3 = ColorSECAMCyan
          rem Player 4 - Cyan (multisprite kernel)
#else
          rem NTSC/PAL - light cyan ColCyan(12)
          if temp1 = 0 then COLUP0 = ColCyan(12)
          rem Player 1
          if temp1 = 1 then _COLUP1 = ColCyan(12)
          rem Player 2
          if temp1 = 2 then COLUP2 = ColCyan(12)
          rem Player 3 (multisprite kernel)
          if temp1 = 3 then COLUP3 = ColCyan(12)
          rem Player 4 (multisprite kernel)
#endif
          return

GuardNormalPhase
          rem Normal phase - restore normal player colors
          rem tail call
          goto RestoreNormalPlayerColor

          rem =================================================================
          rem RESTORE NORMAL PLAYER COLOR
          rem =================================================================
          rem Restores the normal color for a player after guard flashing
          rem INPUT: temp1 = player index (0-3)
RestoreNormalPlayerColor
          rem Get character type for this player
          let temp4  = playerChar[temp1]
          
          rem Restore normal player colors based on player index
          rem Colors are restored by LoadCharacterColors in PlayerRendering.bas
          rem This function is called after LoadCharacterColors, so colors are already set
          rem Guard flashing will override these colors during flash phase
          rem Normal phase colors are already handled by LoadCharacterColors
          return

          rem =================================================================
          rem CHECK GUARD COOLDOWN
          rem =================================================================
          rem Prevents guard use if still in cooldown period (1 second after guard ends)
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if guard allowed, 0 if in cooldown
CheckGuardCooldown
          rem Check if player is currently guarding
          let temp3 = playerState[temp1] & 2
          if temp3 then GuardCooldownBlocked
          
          rem Check cooldown timer (stored in playerTimers array)
          rem playerTimers[temp1] stores frames remaining in cooldown
          let temp3 = playerTimers[temp1]
          
          if temp3 > 0 then GuardCooldownBlocked
          
          rem Cooldown expired, guard allowed
          let temp2 = 1
          return

GuardCooldownBlocked
          rem Currently guarding or in cooldown - not allowed to start new guard
          let temp2 = 0
          return

          rem =================================================================
          rem START GUARD
          rem =================================================================
          rem Activates guard state with proper timing
          rem INPUT: temp1 = player index (0-3)
StartGuard
          rem Set guard bit in playerState
          let playerState[temp1] = playerState[temp1] | 2
          
          rem Set guard duration timer (platform-specific: 60 frames NTSC, 50 frames PAL/SECAM)
          rem Store guard duration timer in playerTimers array
          rem This timer will be decremented each frame until it reaches 0
          let playerTimers[temp1] = GuardTimerMaxFrames
          
          return

          rem =================================================================
          rem UPDATE GUARD TIMERS
          rem =================================================================
          rem Updates guard duration and cooldown timers each frame
          rem Should be called from main game loop
UpdateGuardTimers
          let temp1  = 0 : gosub UpdateSingleGuardTimer
          let temp1  = 1 : gosub UpdateSingleGuardTimer
          let temp1  = 2 : gosub UpdateSingleGuardTimer
          let temp1  = 3 : gosub UpdateSingleGuardTimer
          return

UpdateSingleGuardTimer
          rem Check if player is guarding
          let temp2 = playerState[temp1] & 2
          if temp2 then UpdateGuardTimerActive
          
          rem Player not guarding - decrement cooldown timer
          let temp3 = playerTimers[temp1]
          if temp3 = 0 then return
          rem No cooldown active
          let temp3 = temp3 - 1
          let playerTimers[temp1] = temp3
          return

UpdateGuardTimerActive
          rem Player is guarding - decrement guard duration timer
          let temp3 = playerTimers[temp1]
          if temp3 = 0 then GuardTimerExpired
          rem Guard timer already expired (shouldn’t happen, but safety check)
          
          rem Decrement guard duration timer
          let temp3 = temp3 - 1
          let playerTimers[temp1] = temp3
          if temp3 = 0 then GuardTimerExpired
          return

GuardTimerExpired
          rem Guard duration expired - clear guard bit and start cooldown
          let playerState[temp1] = playerState[temp1] & MaskClearGuard
          rem Clear guard bit (bit 1)
          rem Start cooldown timer (same duration as guard)
          let playerTimers[temp1] = GuardTimerMaxFrames
          return
