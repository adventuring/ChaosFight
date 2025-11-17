          rem ChaosFight - Source/Routines/HandleGuardInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

HandleGuardInput
          asm
HandleGuardInput

end
          rem
          rem Shared Guard Input Handling
          rem Handles down/guard input for both ports
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0down for players 0,2; joy1down for players 1,3
          rem Determine which joy port to use based on player index
          rem Frooty (8) cannot guard
          if playerCharacter[temp1] = 8 then return
          rem Players 0,2 use joy0; Players 1,3 use joy1
          if temp1 = 0 then HGI_CheckJoy0
          if temp1 = 2 then HGI_CheckJoy0
          rem Players 1,3 use joy1
          if !joy1down then goto HGI_CheckGuardRelease
          goto HGI_HandleDownPressed
HGI_CheckJoy0
          rem Players 0,2 use joy0
          if !joy0down then goto HGI_CheckGuardRelease
HGI_HandleDownPressed
          let temp4 = playerCharacter[temp1]
          rem DOWN pressed - dispatch to character-specific down handler
          gosub DispatchCharacterDown bank13
          return
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

