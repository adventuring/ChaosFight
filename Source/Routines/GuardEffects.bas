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
if temp3 < 2 then 
          rem Flash phase - set light cyan color
#ifdef TV_SECAM
          rem SECAM uses player-based colors (always cyan for guard)
          let if temp1 = 0 then COLUP0  = $C0
          rem Player 1 - Cyan
          let if temp1 = 1 then COLUP1  = $C0
          rem Player 2 - Cyan
          rem Players 3 & 4: Missiles inherit colors from COLUP0/COLUP1
          rem Cannot set missile colors independently - see Issue #73
#else
          rem NTSC/PAL - light cyan ColCyan(12)
          let if temp1 = 0 then COLUP0  = ColCyan(12)
          rem Player 1
          let if temp1 = 1 then COLUP1  = ColCyan(12)
          rem Player 2
          rem Players 3 & 4: Missiles inherit colors from COLUP0/COLUP1
          rem Cannot set missile colors independently - see Issue #73

          rem Normal phase - restore normal player colors
          gosub RestoreNormalPlayerColor
          
          
          return

          rem =================================================================
          rem RESTORE NORMAL PLAYER COLOR
          rem =================================================================
          rem Restores the normal color for a player after guard flashing
          rem INPUT: temp1 = player index (0-3)
RestoreNormalPlayerColor
          rem Get character type for this player
          let temp4  = playerChar[temp1]
          
          rem Restore normal player colors based on player index
          let if temp1 = 0 then COLUP0  = $0E
          rem Player 1 - Blue
          let if temp1 = 1 then COLUP1  = $32
          rem Player 2 - Red  
          rem Players 3 & 4: Missiles inherit colors from COLUP0/COLUP1
          rem Cannot restore missile colors independently - see Issue #73
          
          return

          rem =================================================================
          rem CHECK GUARD COOLDOWN
          rem =================================================================
          rem Prevents guard use if still in cooldown period (1 second after guard ends)
          rem INPUT: temp1 = player index (0-3)
          rem OUTPUT: temp2 = 1 if guard allowed, 0 if in cooldown
CheckGuardCooldown
          rem Check if player is currently guarding
          let temp3  = playerState[temp1] & 2
if temp3 then 
          rem Currently guarding - not allowed to start new guard
          let temp2  = 0
          return
          
          
          rem Check cooldown timer (stored in playerTimers array)
          rem playerTimers[temp1] stores frames remaining in cooldown
          let temp3  = playerTimers[temp1]
          
if temp3 > 0 then 
          rem Still in cooldown
          let temp2  = 0

          rem Cooldown expired, guard allowed
          let temp2  = 1
          
          
          return

          rem =================================================================
          rem START GUARD
          rem =================================================================
          rem Activates guard state with proper timing
          rem INPUT: temp1 = player index (0-3)
StartGuard
          rem Set guard bit in playerState
          let playerState[temp1] = playerState[temp1] | 2
          
          rem Set guard duration timer (60 frames = 1 second)
          rem Use upper bits of playerState for guard timer
          rem Bits 5-7 can store timer (0-7 * 8 frames = 0-56 frames)
          rem We will use a separate guard timer approach
          let temp2  = playerState[temp1] & %11100000
          rem Clear timer bits
          let temp2  = temp2 | %01110000
          rem Set 7*8 = 56 frames (~1 second)
          let playerState[temp1] = temp2 | 2
          rem Restore guard bit
          
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
          let temp2  = playerState[temp1] & 2
if temp2 then 
          rem Player is guarding - decrement guard duration
          let temp3  = playerState[temp1] & %11100000
          rem Get timer bits
          let temp3  = temp3 - %00100000
          rem Decrement by 8 frames
if temp3 <= 0 then 
          rem Guard duration expired
          let playerState[temp1] = playerState[temp1] & %11111101
          rem Clear guard bit
          rem Start cooldown timer (60 frames)
          let playerTimers[temp1] = 60

          rem Update guard timer
          let temp4  = playerState[temp1] & %00011111
          rem Keep lower bits
          let playerState[temp1] = temp4 | temp3
          rem Combine with new timer
          

          rem Player not guarding - decrement cooldown timer
          let temp3  = playerTimers[temp1]
          
if temp3 > 0 then 
          let temp3  = temp3 - 1
          let playerTimers[temp1] = temp3
          
          
          
          return

          return
          
          
          rem Check cooldown timer (stored in playerTimers array)
          rem playerTimers[temp1] stores frames remaining in cooldown
          let temp3  = playerTimers[temp1]
          
if temp3 > 0 then 
          rem Still in cooldown
          let temp2  = 0

          rem Cooldown expired, guard allowed
          let temp2  = 1
          
          
          return

          rem =================================================================
          rem START GUARD
          rem =================================================================
          rem Activates guard state with proper timing
          rem INPUT: temp1 = player index (0-3)
