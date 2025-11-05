          rem ChaosFight - Source/Routines/GuardEffects.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem ==========================================================
          rem GUARD VISUAL EFFECTS SYSTEM
          rem ==========================================================
          rem Implements guard flashing visual feedback as specified in
          rem   manual:
          rem - Character flashes light cyan ColCyan(12) in NTSC/PAL
          rem - Character flashes Cyan in SECAM
          rem - Guard lasts maximum 1 second (60 frames)
          rem - Guard cannot be used again for 1 second after previous
          rem   use
          rem ==========================================================

          rem ==========================================================
          rem APPLY GUARD VISUAL EFFECTS
          rem ==========================================================
          rem Applies guard flashing effect to a guarding player
          rem INPUT: temp1 = player index (0-3)
          rem USES: playerState[temp1], frame counter for flashing
ApplyGuardFlashing
          dim AGF_playerIndex = temp1
          dim AGF_isGuarding = temp2
          dim AGF_flashPhase = temp3
          rem Check if player is guarding
          let AGF_isGuarding = playerState[AGF_playerIndex] & 2
          if !AGF_isGuarding then return 
          rem Not guarding
          
          rem Flash every 4 frames for visible effect
          let AGF_flashPhase = frame & 3
          if AGF_flashPhase >= 2 then goto GuardNormalPhase
          rem Flash phase - set light cyan color
          rem Set color based on player index (COLUP0/1/2/3)
          dim AGF_colorValue = temp4
#ifdef TV_SECAM
          rem SECAM uses player-based colors (always cyan for guard)
          let AGF_colorValue = ColCyan(6)
#else
          rem NTSC/PAL - light cyan ColCyan(12)
          let AGF_colorValue = ColCyan(12)
#endif
          rem Apply color to appropriate player register
          if AGF_playerIndex = 0 then COLUP0 = AGF_colorValue : return
          if AGF_playerIndex = 1 then _COLUP1 = AGF_colorValue : return
          if AGF_playerIndex = 2 then COLUP2 = AGF_colorValue : return
          if AGF_playerIndex = 3 then COLUP3 = AGF_colorValue : return
          return

GuardNormalPhase
          rem Normal phase - restore normal player colors
          rem tail call
          goto RestoreNormalPlayerColor

          rem ==========================================================
          rem RESTORE NORMAL PLAYER COLOR
          rem ==========================================================
          rem Restores the normal color for a player after guard
          rem   flashing
          rem INPUT: temp1 = player index (0-3)
RestoreNormalPlayerColor
          dim RNPC_playerIndex = temp1
          dim RNPC_characterType = temp4
          rem Get character type for this player
          let RNPC_characterType = playerChar[RNPC_playerIndex]
          
          rem Restore normal player colors based on player index
          rem Colors are restored by LoadCharacterColors in
          rem   PlayerRendering.bas
          rem This function is called after LoadCharacterColors, so
          rem   colors are already set
          rem Guard flashing will override these colors during flash
          rem   phase
          rem Normal phase colors are already handled by
          rem   LoadCharacterColors
          return

          rem ==========================================================
          rem CHECK GUARD COOLDOWN
          rem ==========================================================
          rem Prevents guard use if still in cooldown period (1 second
          rem   after guard ends)
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if guard allowed, 0 if in cooldown
CheckGuardCooldown
          dim CGC_playerIndex = temp1
          dim CGC_guardAllowed = temp2
          dim CGC_isGuarding = temp3
          dim CGC_cooldownTimer = temp3
          rem Check if player is currently guarding
          let CGC_isGuarding = playerState[CGC_playerIndex] & 2
          if CGC_isGuarding then GuardCooldownBlocked
          
          rem Check cooldown timer (stored in playerTimers array)
          rem playerTimers stores frames remaining in cooldown
          let CGC_cooldownTimer = playerTimers_R[CGC_playerIndex]
          
          if CGC_cooldownTimer > 0 then GuardCooldownBlocked
          
          rem Cooldown expired, guard allowed
          let CGC_guardAllowed = 1
          let temp2 = CGC_guardAllowed
          return

GuardCooldownBlocked
          dim GCBD_guardAllowed = temp2
          rem Currently guarding or in cooldown - not allowed to start
          rem   new guard
          let GCBD_guardAllowed = 0
          let temp2 = GCBD_guardAllowed
          return

          rem ==========================================================
          rem START GUARD
          rem ==========================================================
          rem Activates guard state with proper timing
          rem INPUT: temp1 = player index (0-3)
StartGuard
          dim SG_playerIndex = temp1
          rem Set guard bit in playerState
          let playerState[SG_playerIndex] = playerState[SG_playerIndex] | 2
          
          rem Set guard duration timer (platform-specific: 60 frames
          rem   NTSC, 50 frames PAL/SECAM)
          rem Store guard duration timer in playerTimers array
          rem This timer will be decremented each frame until it reaches
          rem   0
          let playerTimers_W[SG_playerIndex] = GuardTimerMaxFrames
          
          return

          rem ==========================================================
          rem UPDATE GUARD TIMERS
          rem ==========================================================
          rem Updates guard duration and cooldown timers each frame
          rem Should be called from main game loop
UpdateGuardTimers
          dim UGT_playerIndex = temp1
          rem Update guard timers for all players
          rem INPUT: None
          rem OUTPUT: None
          rem EFFECTS: Decrements guard duration timers for guarding
          rem   players,
          rem decrements cooldown timers for non-guarding players,
          rem clears guard state and starts cooldown when guard expires
          let UGT_playerIndex = 0
          let temp1 = UGT_playerIndex
          gosub UpdateSingleGuardTimer
          let UGT_playerIndex = 1
          let temp1 = UGT_playerIndex
          gosub UpdateSingleGuardTimer
          let UGT_playerIndex = 2
          let temp1 = UGT_playerIndex
          gosub UpdateSingleGuardTimer
          let UGT_playerIndex = 3
          let temp1 = UGT_playerIndex
          rem tail call
          goto UpdateSingleGuardTimer

UpdateSingleGuardTimer
          dim USGT_playerIndex = temp1
          dim USGT_isGuarding = temp2
          dim USGT_timer = temp3
          rem Update guard timer or cooldown for a single player
          rem INPUT: temp1 = player index (0-3)
          rem        playerState = player state flags (bit 1 = guarding)
          rem        playerTimers = guard duration or cooldown timer
          rem OUTPUT: None
          rem EFFECTS: If guarding: decrements guard duration timer,
          rem   clears guard and starts cooldown when expired
          rem If not guarding: decrements cooldown timer (if active)
          rem Check if player is guarding
          let USGT_isGuarding = playerState[USGT_playerIndex] & 2
          if USGT_isGuarding then UpdateGuardTimerActive
          
          rem Player not guarding - decrement cooldown timer
          rem Fix RMW: Read from _R, modify, write to _W
          let USGT_timer = playerTimers_R[USGT_playerIndex]
          if USGT_timer = 0 then return
          rem No cooldown active
          let USGT_timer = USGT_timer - 1
          let playerTimers_W[USGT_playerIndex] = USGT_timer
          return

UpdateGuardTimerActive
          dim UGTA_timer = temp3
          rem Player is guarding - decrement guard duration timer
          let UGTA_timer = playerTimers_R[USGT_playerIndex]
          if UGTA_timer = 0 then GuardTimerExpired
          rem Guard timer already expired (shouldn’t happen, but safety
          rem   check)
          
          rem Decrement guard duration timer
          let UGTA_timer = UGTA_timer - 1
          let playerTimers_W[USGT_playerIndex] = UGTA_timer
          if UGTA_timer = 0 then GuardTimerExpired
          return

GuardTimerExpired
          rem Guard duration expired - clear guard bit and start
          rem   cooldown
          let playerState[USGT_playerIndex] = playerState[USGT_playerIndex] & MaskClearGuard
          rem Start cooldown timer (same duration as guard)
          let playerTimers_W[USGT_playerIndex] = GuardTimerMaxFrames
          return
