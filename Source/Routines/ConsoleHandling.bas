          rem ChaosFight - Source/Routines/ConsoleHandling.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem CONSOLE SWITCH HANDLING
          rem =================================================================
          rem Handles Atari 2600 console switches during gameplay.
          rem
          rem SWITCHES:
          rem   switchreset - Game Reset → return to character select
          rem   switchselect - Game Select → toggle pause
          rem   switchbw - Color/B&W → handled in rendering
          rem
          rem AVAILABLE VARIABLES:
          rem   GameState - 0=normal play, 1=paused
          rem =================================================================

          rem Main console switch handler
HandleConsoleSwitches
          rem Game Reset switch - return to character selection
          if switchreset then goto CharacterSelect

          rem Game Select switch - toggle pause mode
          if switchselect then
                    if GameState = 0 then
                              GameState = 1
                    else
                              GameState = 0
                    endif
          endif

          rem Color/B&W switch is handled in PlayerRendering.bas
          rem via switchbw checks in SetPlayerSprites

          return

          rem Display paused screen
DisplayPausedScreen
          rem Display "PAUSED" message or keep characters visible
          rem For now, just keep characters visible on black background
          rem TODO: Add "PAUSED" text using font system
          return

