          rem ChaosFight - Source/Routines/HandleGuardInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

rem HandleGuardInput - INLINED
rem This function has been inlined at all call sites for performance.
rem See PlayerInput.bas for inlined implementation.
rem
rem Shared Guard Input Handling (inlined version)
rem Handles down/guard input for both ports
rem
rem INPUT: temp1 = player index (0-3)
rem Uses: joy0down for players 0,2; joy1down for players 1,3
rem Determine which joy port to use based on player index
rem Frooty (8) cannot guard
rem Players 0,2 use joy0; Players 1,3 use joy1
HGI_CheckJoy0
          rem Players 0,2 use joy0
          if !joy0down then goto HGI_CheckGuardRelease
HGI_HandleDownPressed
          let temp4 = playerCharacter[temp1]
          rem DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          if temp4 >= 32 then return
          if temp4 = 2 then goto DragonOfStormsDown
          if temp4 = 6 then goto HarpyDown
          if temp4 = 8 then goto FrootyDown
          if temp4 = 13 then goto DCD_HandleRoboTitoDown_HGI
          goto StandardGuard
DCD_HandleRoboTitoDown_HGI
          gosub RoboTitoDown
          if temp2 = 1 then return
          goto StandardGuard
HGI_CheckGuardRelease
          let temp2 = playerState[temp1] & 2
          rem DOWN released - check for early guard release
          if !temp2 then return
          rem Not guarding, nothing to do
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          rem Stop guard early and start cooldown
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          rem Start cooldown timer
          return

