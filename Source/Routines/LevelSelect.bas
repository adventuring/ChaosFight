          rem ChaosFight - Source/Routines/LevelSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem LEVEL SELECT LOOP - Called from MainLoop each frame
          rem =================================================================
          rem This is the main loop that runs each frame during Level Select mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginLevelSelect (called from ChangeGameMode).

LevelSelect1
          rem Handle input for arena selection
          if joy0left then selectedArena = selectedArena - 1 : if selectedArena > MaxArenaID then selectedArena = MaxArenaID
          if joy0right then selectedArena = selectedArena + 1 : if selectedArena > MaxArenaID then selectedArena = 0
          
          rem Display arena number (01-16) or '??' for random
          gosub DisplayArenaNumber
          
          rem TODO: Load player character sprites (#414, #415)
          rem TODO: Handle Game Select switch (#393)
          rem TODO: Handle 1-second Fire button hold (#392)
          
          rem Placeholder sprite positioning (to be replaced with player sprites)
          if selectedArena = 0 then goto Level0Sprites
          goto Level1Sprites

Level0Sprites
          player0x = 80 : player0y = 80
          player1x = 90 : player1y = 80
          rem TODO: Use dynamic sprite setting for level 0 sprites
          goto SpritesSet

Level1Sprites
          player0x = 80 : player0y = 80
          player1x = 90 : player1y = 80

SpritesSet
          
          rem Check for Fire button to start game
          if joy0fire then goto StartGame1
          
          rem Return to MainLoop for next frame
          rem MainLoop will call drawscreen after this returns
          return

StartGame1
          rem Transition to Game mode after arena selection
          let GameMode = ModeGame : gosub bank13 ChangeGameMode
          return