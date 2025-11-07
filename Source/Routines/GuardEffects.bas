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
          rem
          rem INPUT: temp1 = player index (0-3)
          rem USES: playerState[temp1], frame counter for flashing
          rem Applies guard flashing effect to a guarding player
          rem (flashes light cyan every 4 frames)
          rem
          rem Input: temp1 = player index (0-3), playerState[] (global
          rem array) = player state flags (bit 1 = guarding), frame
          rem (global) = frame counter, ColCyan (global constant) = cyan
          rem color function, TV_SECAM (compile-time constant) = TV
          rem standard
          rem
          rem Output: Player color set to flashing cyan if guarding,
          rem normal color otherwise
          rem
          rem Mutates: temp1-temp4 (used for calculations), COLUP0,
          rem _COLUP1, COLUP2, COLUP3 (TIA registers) = player colors
          rem (set to flashing cyan or normal)
          rem
          rem Called Routines: GuardNormalPhase (tail call via goto) -
          rem restores normal color
          rem
          rem Constraints: Flash every 4 frames (frames 0-1 = flash,
          rem frames 2-3 = normal). SECAM uses ColCyan(6), NTSC/PAL uses
          rem ColCyan(12). Only applies if player is guarding (bit 1
          rem set)
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
          let AGF_colorValue = ColCyan(12) : rem Bright cyan guard flash (SECAM maps to cyan)
          if AGF_playerIndex = 0 then goto ApplyGuardFlashColor0
          rem Apply color to appropriate player register
          if AGF_playerIndex = 1 then goto ApplyGuardFlashColor1
          if AGF_playerIndex = 2 then goto ApplyGuardFlashColor2
          if AGF_playerIndex = 3 then goto ApplyGuardFlashColor3
          return

ApplyGuardFlashColor0
          COLUP0 = AGF_colorValue
          return

ApplyGuardFlashColor1
          _COLUP1 = AGF_colorValue
          return

ApplyGuardFlashColor2
          COLUP2 = AGF_colorValue
          return

ApplyGuardFlashColor3
          COLUP3 = AGF_colorValue
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
          goto RestoreNormalPlayerColor : rem tail call

RestoreNormalPlayerColor
          rem
          rem Restore Normal Player Color
          rem Restores the normal color for a player after guard
          rem   flashing
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Restores the normal color for a player after guard
          rem flashing
          rem
          rem Input: temp1 = player index (0-3)
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
          dim RNPC_playerIndex = temp1 : rem Constraints: None
          dim RNPC_characterType = temp4
          let RNPC_characterType = playerCharacter[RNPC_playerIndex] : rem Get character type for this player
          
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
          rem
          rem INPUT: temp1 = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if guard allowed, 0 if in cooldown
          rem Prevents guard use if still in cooldown period (1 second
          rem after guard ends)
          rem
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
          dim GCBD_guardAllowed = temp2 : rem Constraints: Must be colocated with CheckGuardCooldown
          rem Currently guarding or in cooldown - not allowed to start
          let GCBD_guardAllowed = 0 : rem   new guard
          let temp2 = GCBD_guardAllowed
          return

StartGuard
          rem
          rem Start Guard
          rem Activates guard state with proper timing
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Activates guard state with proper timing
          rem
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
          dim SG_playerIndex = temp1 : rem Constraints: None
          let playerState[SG_playerIndex] = playerState[SG_playerIndex] | 2 : rem Set guard bit in playerState
          
          rem Set guard duration timer (platform-specific: 60 frames
          rem   NTSC, 50 frames PAL/SECAM)
          rem Store guard duration timer in playerTimers array
          rem This timer will be decremented each frame until it reaches
          let playerTimers_W[SG_playerIndex] = GuardTimerMaxFrames : rem   0
          
          return

UpdateGuardTimers
          rem
          rem Update Guard Timers
          rem Updates guard duration and cooldown timers each frame
          rem Should be called from main game loop
          rem Updates guard duration and cooldown timers each frame for
          rem all players
          rem
          rem Input: None
          rem
          rem Output: Guard timers and cooldown timers updated for all
          rem players
          rem
          rem Mutates: temp1 (set to 0-3), playerTimers_W[]
          rem (decremented), playerState[] (guard bit cleared when
          rem expired)
          rem
          rem Called Routines: UpdateSingleGuardTimer - updates guard
          rem timer for one player
          rem
          rem Constraints: Tail call to UpdateSingleGuardTimer for
          rem player 3
          dim UGT_playerIndex = temp1 : rem              Should be called from main game loop
          rem Update guard timers for all players
          rem
          rem INPUT: None
          rem
          rem OUTPUT: None
          rem
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
          dim USGT_playerIndex = temp1
          dim USGT_isGuarding = temp2
          dim USGT_timer = temp3
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
          rem
          rem Input: USGT_playerIndex (from UpdateSingleGuardTimer),
          rem playerTimers_R[] (global SCRAM array)
          rem
          rem Output: playerTimers_W[] decremented, dispatches to
          rem GuardTimerExpired when timer reaches 0
          rem
          rem Mutates: temp3 (timer value), playerTimers_W[]
          rem (decremented)
          rem
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
          rem Guard duration expired - clear guard bit and start
          rem cooldown
          rem
          rem Input: USGT_playerIndex (from UpdateGuardTimerActive),
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
          let playerState[USGT_playerIndex] = playerState[USGT_playerIndex] & MaskClearGuard : rem Constraints: Must be colocated with UpdateSingleGuardTimer, UpdateGuardTimerActive
          let playerTimers_W[USGT_playerIndex] = GuardTimerMaxFrames : rem Start cooldown timer (same duration as guard)
          return
