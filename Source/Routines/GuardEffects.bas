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
          rem Apply Guard Visual Effects
          rem Applies guard flashing effect to a guarding player
          rem INPUT: temp1 = player index (0-3)
          rem USES: playerState[temp1], frame counter for flashing
          rem Applies guard flashing effect to a guarding player (flashes light cyan every 4 frames)
          rem Input: temp1 = player index (0-3), playerState[] (global array) = player state flags (bit 1 = guarding), frame (global) = frame counter, ColCyan (global constant) = cyan color function, TV_SECAM (compile-time constant) = TV standard
          rem Output: Player color set to flashing cyan if guarding, normal color otherwise
          rem Mutates: temp1-temp4 (used for calculations), COLUP0, _COLUP1, COLUP2, COLUP3 (TIA registers) = player colors (set to flashing cyan or normal)
          rem Called Routines: GuardNormalPhase (tail call via goto) - restores normal color
          rem Constraints: Flash every 4 frames (frames 0-1 = flash, frames 2-3 = normal). SECAM uses ColCyan(6), NTSC/PAL uses ColCyan(12). Only applies if player is guarding (bit 1 set)
          dim AGF_playerIndex = temp1
          dim AGF_isGuarding = temp2
          dim AGF_flashPhase = temp3
          let AGF_isGuarding = playerState[AGF_playerIndex] & 2 : rem Check if player is guarding
          if !AGF_isGuarding then return 
          rem Not guarding
          
          let AGF_flashPhase = frame & 3 : rem Flash every 4 frames for visible effect
          if AGF_flashPhase >= 2 then goto GuardNormalPhase
          rem Flash phase - set light cyan color
          dim AGF_colorValue = temp4 : rem Set color based on player index (COLUP0/1/2/3)
#ifdef TV_SECAM
          let AGF_colorValue = ColCyan(6) : rem SECAM uses player-based colors (always cyan for guard)
#else
          let AGF_colorValue = ColCyan(12) : rem NTSC/PAL - light cyan ColCyan(12)
#endif
          if AGF_playerIndex = 0 then COLUP0 = AGF_colorValue : return : rem Apply color to appropriate player register
          if AGF_playerIndex = 1 then _COLUP1 = AGF_colorValue : return
          if AGF_playerIndex = 2 then COLUP2 = AGF_colorValue : return
          if AGF_playerIndex = 3 then COLUP3 = AGF_colorValue : return
          return

GuardNormalPhase
          rem Helper: Normal phase - restore normal player colors
          rem Input: temp1 = player index (0-3), playerChar[] (global array) = player character selections
          rem Output: Normal player colors restored
          rem Mutates: None (colors restored by RestoreNormalPlayerColor)
          rem Called Routines: RestoreNormalPlayerColor (tail call via goto) - restores normal colors
          rem Constraints: Internal helper for ApplyGuardFlashing, only called during normal phase (frames 2-3)
          rem Normal phase - restore normal player colors
          goto RestoreNormalPlayerColor : rem tail call

RestoreNormalPlayerColor
          rem
          rem Restore Normal Player Color
          rem Restores the normal color for a player after guard
          rem   flashing
          rem INPUT: temp1 = player index (0-3)
          rem Restores the normal color for a player after guard flashing
          rem Input: temp1 = player index (0-3)
          rem        playerChar[] (global array) = player character selections
          rem Output: None (colors restored by LoadCharacterColors in PlayerRendering.bas)
          rem Mutates: None (colors already set by LoadCharacterColors)
          rem Called Routines: None (colors handled by LoadCharacterColors)
          dim RNPC_playerIndex = temp1 : rem Constraints: None
          dim RNPC_characterType = temp4
          let RNPC_characterType = playerChar[RNPC_playerIndex] : rem Get character type for this player
          
          return
          rem Restore normal player colors based on player index
          rem Colors are restored by LoadCharacterColors in
          rem   PlayerRendering.bas
          rem This function is called after LoadCharacterColors, so
          rem   colors are already set
          rem Guard flashing will override these colors during flash
          rem   phase
          rem Normal phase colors are already handled by
          rem   LoadCharacterColors

CheckGuardCooldown
          rem
          rem Check Guard Cooldown
          rem Prevents guard use if still in cooldown period (1 second
          rem   after guard ends)
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if guard allowed, 0 if in cooldown
          rem Prevents guard use if still in cooldown period (1 second after guard ends)
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global array) = player state flags (bit 1 = guarding)
          rem        playerTimers_R[] (global SCRAM array) = guard cooldown timers
          rem Output: temp2 = 1 if guard allowed, 0 if in cooldown
          rem Mutates: temp2 (set to 0 or 1)
          rem Called Routines: None
          dim CGC_playerIndex = temp1 : rem Constraints: Must be colocated with GuardCooldownBlocked (called via goto)
          dim CGC_guardAllowed = temp2
          dim CGC_isGuarding = temp3
          dim CGC_cooldownTimer = temp3
          let CGC_isGuarding = playerState[CGC_playerIndex] & 2 : rem Check if player is currently guarding
          if CGC_isGuarding then GuardCooldownBlocked
          
          rem Check cooldown timer (stored in playerTimers array)
          let CGC_cooldownTimer = playerTimers_R[CGC_playerIndex] : rem playerTimers stores frames remaining in cooldown
          
          if CGC_cooldownTimer > 0 then GuardCooldownBlocked
          
          let CGC_guardAllowed = 1 : rem Cooldown expired, guard allowed
          let temp2 = CGC_guardAllowed
          return

GuardCooldownBlocked
          rem Currently guarding or in cooldown - not allowed to start new guard
          rem Input: None (called from CheckGuardCooldown)
          rem Output: temp2 set to 0
          rem Mutates: temp2 (set to 0)
          rem Called Routines: None
          dim GCBD_guardAllowed = temp2 : rem Constraints: Must be colocated with CheckGuardCooldown
          rem Currently guarding or in cooldown - not allowed to start
          let GCBD_guardAllowed = 0 : rem   new guard
          let temp2 = GCBD_guardAllowed
          return

StartGuard
          rem
          rem Start Guard
          rem Activates guard state with proper timing
          rem INPUT: temp1 = player index (0-3)
          rem Activates guard state with proper timing
          rem Input: temp1 = player index (0-3)
          rem        GuardTimerMaxFrames (constant) = guard duration in frames
          rem Output: playerState[] guard bit set, playerTimers_W[] set to guard duration
          rem Mutates: playerState[] (guard bit set), playerTimers_W[] (set to GuardTimerMaxFrames)
          rem Called Routines: None
          dim SG_playerIndex = temp1 : rem Constraints: None
          let playerState[SG_playerIndex] = playerState[SG_playerIndex] | 2 : rem Set guard bit in playerState
          
          rem Set guard duration timer (platform-specific: 60 frames
          rem   NTSC, 50 frames PAL/SECAM)
          rem Store guard duration timer in playerTimers array
          rem This timer will be decremented each frame until it reaches
          let playerTimers_W[SG_playerIndex] = GuardTimerMaxFrames : rem   0
          
          return

          rem
          rem Update Guard Timers
          rem Updates guard duration and cooldown timers each frame
          rem Should be called from main game loop
UpdateGuardTimers
          rem Updates guard duration and cooldown timers each frame for all players
          rem Input: None
          rem Output: Guard timers and cooldown timers updated for all players
          rem Mutates: temp1 (set to 0-3), playerTimers_W[] (decremented), playerState[] (guard bit cleared when expired)
          rem Called Routines: UpdateSingleGuardTimer - updates guard timer for one player
          rem Constraints: Tail call to UpdateSingleGuardTimer for player 3
          dim UGT_playerIndex = temp1 : rem              Should be called from main game loop
          rem Update guard timers for all players
          rem INPUT: None
          rem OUTPUT: None
          rem EFFECTS: Decrements guard duration timers for guarding
          rem   players,
          rem decrements cooldown timers for non-guarding players,
          let UGT_playerIndex = 0 : rem clears guard state and starts cooldown when guard expires
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
          goto UpdateSingleGuardTimer : rem tail call

UpdateSingleGuardTimer
          rem Update guard timer or cooldown for a single player
          rem Input: temp1 = player index (0-3)
          rem        playerState[] (global array) = player state flags (bit 1 = guarding)
          rem        playerTimers_R[] (global SCRAM array) = guard duration or cooldown timer
          rem        GuardTimerMaxFrames (constant) = guard duration in frames
          rem        MaskClearGuard (constant) = bitmask to clear guard bit
          rem Output: playerTimers_W[] decremented, playerState[] guard bit cleared when expired,
          rem         cooldown started when guard expires
          rem Mutates: temp1-temp3 (used for calculations), playerTimers_W[] (decremented),
          rem         playerState[] (guard bit cleared when expired)
          rem Called Routines: None
          rem Constraints: Must be colocated with UpdateGuardTimerActive, GuardTimerExpired (called via goto)
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
          let USGT_isGuarding = playerState[USGT_playerIndex] & 2 : rem Check if player is guarding
          if USGT_isGuarding then UpdateGuardTimerActive
          
          rem Player not guarding - decrement cooldown timer
          let USGT_timer = playerTimers_R[USGT_playerIndex] : rem Fix RMW: Read from _R, modify, write to _W
          if USGT_timer = 0 then return
          let USGT_timer = USGT_timer - 1 : rem No cooldown active
          let playerTimers_W[USGT_playerIndex] = USGT_timer
          return

UpdateGuardTimerActive
          rem Player is guarding - decrement guard duration timer
          rem Input: USGT_playerIndex (from UpdateSingleGuardTimer), playerTimers_R[] (global SCRAM array)
          rem Output: playerTimers_W[] decremented, dispatches to GuardTimerExpired when timer reaches 0
          rem Mutates: temp3 (timer value), playerTimers_W[] (decremented)
          rem Called Routines: None
          dim UGTA_timer = temp3 : rem Constraints: Must be colocated with UpdateSingleGuardTimer, GuardTimerExpired
          let UGTA_timer = playerTimers_R[USGT_playerIndex] : rem Player is guarding - decrement guard duration timer
          if UGTA_timer = 0 then GuardTimerExpired
          rem Guard timer already expired (shouldn’t happen, but safety
          rem   check)
          
          let UGTA_timer = UGTA_timer - 1 : rem Decrement guard duration timer
          let playerTimers_W[USGT_playerIndex] = UGTA_timer
          if UGTA_timer = 0 then GuardTimerExpired
          return

GuardTimerExpired
          rem Guard duration expired - clear guard bit and start cooldown
          rem Input: USGT_playerIndex (from UpdateGuardTimerActive), playerState[] (global array),
          rem        GuardTimerMaxFrames (constant)
          rem Output: playerState[] guard bit cleared, playerTimers_W[] set to cooldown duration
          rem Mutates: playerState[] (guard bit cleared), playerTimers_W[] (set to GuardTimerMaxFrames)
          rem Called Routines: None
          let playerState[USGT_playerIndex] = playerState[USGT_playerIndex] & MaskClearGuard : rem Constraints: Must be colocated with UpdateSingleGuardTimer, UpdateGuardTimerActive
          let playerTimers_W[USGT_playerIndex] = GuardTimerMaxFrames : rem Start cooldown timer (same duration as guard)
          return
