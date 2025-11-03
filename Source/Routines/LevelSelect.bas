          rem ChaosFight - Source/Routines/LevelSelect1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

LevelSelect1
LevelSelect1Loop
          if joy0left then LevelSelectLeft
          goto LevelSelectSkipLeft
LevelSelectLeft
          selectedArena = selectedArena - 1 : if selectedArena > MaxArenaID then selectedArena = MaxArenaID
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
LevelSelectSkipLeft
          if joy0right then LevelSelectRight
          goto LevelSelectSkipRight
LevelSelectRight
          selectedArena = selectedArena + 1 : if selectedArena > MaxArenaID then selectedArena = 0
          rem Play navigation sound
          temp1 = SoundMenuNavigate
          gosub bank15 PlaySoundEffect
LevelSelectSkipRight
          
          if selectedArena = 0 then Level0Sprites
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
          
          if joy0fire then LevelSelectConfirm
          goto LevelSelectSkipConfirm
LevelSelectConfirm
          rem Play selection sound
          temp1 = SoundMenuSelect
          gosub bank15 PlaySoundEffect
          gosub StartGame1
          return
LevelSelectSkipConfirm
          drawscreen
          goto LevelSelect1Loop

StartGame1
          let gameMode = ModeGame : gosub bank13 ChangeGameMode
          return