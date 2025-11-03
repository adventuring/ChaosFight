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
          rem Note: Uses selectedLevel variable (to be renamed to selectedArena per #390)
          if joy0left then selectedLevel = selectedLevel - 1 : if selectedLevel > MaxArenaID then selectedLevel = MaxArenaID
          if joy0right then selectedLevel = selectedLevel + 1 : if selectedLevel > MaxArenaID then selectedLevel = 0
          
          rem TODO: Implement arena number display (#391, #408, #409, #410)
          rem TODO: Load player character sprites (#414, #415)
          rem TODO: Handle Game Select switch (#393)
          rem TODO: Handle 1-second Fire button hold (#392)
          
          rem Placeholder sprite positioning (to be replaced with player sprites)
          if selectedLevel = 0 then goto Level0Sprites
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