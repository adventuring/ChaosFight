          rem ChaosFight - Source/Routines/HandleGuardInput.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

HandleGuardInput
          asm
HandleGuardInput
end
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
          rem DOWN pressed - dispatch to character-specific down handler (inlined for performance)
          let temp4 = playerCharacter[temp1]
          if temp4 >= 32 then return otherbank
          if temp4 = 2 then goto DragonOfStormsDown bank13
          if temp4 = 6 then goto HarpyDown bank13
          if temp4 = 8 then goto FrootyDown bank13
          if temp4 = 13 then goto DCD_HandleRoboTitoDown_HGI
          goto StandardGuard bank13
DCD_HandleRoboTitoDown_HGI
          gosub RoboTitoDown bank13
          if temp2 = 1 then return otherbank
          goto StandardGuard bank13
HGI_CheckGuardRelease
          rem DOWN released - check for early guard release
          let temp2 = playerState[temp1] & 2
          rem Not guarding, nothing to do
          if !temp2 then return otherbank
          rem Stop guard early and start cooldown
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitGuarding)
          rem Start cooldown timer
          let playerTimers_W[temp1] = GuardTimerMaxFrames
          return otherbank

