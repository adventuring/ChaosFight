          rem ChaosFight - Source/Routines/LevelSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

LevelSelect1
LevelSelect1Loop
          if joy0left then SelectedLevel = SelectedLevel - 1 : if SelectedLevel > NumLevels then SelectedLevel = NumLevels
          if joy0right then SelectedLevel = SelectedLevel + 1 : if SelectedLevel > NumLevels then SelectedLevel = 0
          
          if SelectedLevel = 0 then goto Level0Sprites
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
          
          if joy0fire then goto StartGame1
          
          drawscreen
          goto LevelSelect1Loop

StartGame1
          GameMode = ModeGame : gosub ChangeGameMode
          return