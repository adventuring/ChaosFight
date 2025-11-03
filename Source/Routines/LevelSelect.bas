          rem ChaosFight - Source/Routines/LevelSelect.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem LEVEL SELECT LOOP - Called from MainLoop each frame
          rem =================================================================
          rem This is the main loop that runs each frame during Level Select mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginLevelSelect (called from ChangeGameMode).

LevelSelect1
          rem Handle Game Select switch - return to character select
          if switchselect then goto LevelSelectReturnToCharacterSelect
          
          rem Handle input for arena selection
          if joy0left then selectedArena = selectedArena - 1 : if selectedArena > MaxArenaID then selectedArena = MaxArenaID
          if joy0right then selectedArena = selectedArena + 1 : if selectedArena > MaxArenaID then selectedArena = 0
          
          rem Handle 1-second Fire button hold - return to character select
          if joy0fire then goto LevelSelectCheckHoldTimer
          LevelSelectHoldTimer = 0
          goto LevelSelectHoldTimerDone
LevelSelectCheckHoldTimer
          LevelSelectHoldTimer = LevelSelectHoldTimer + 1
          if LevelSelectHoldTimer >= 60 then goto LevelSelectReturnToCharacterSelect
LevelSelectHoldTimerDone
          
          rem Display arena number (01-16) or '??' for random
          gosub DisplayArenaNumber
          
          rem TODO: Load player character sprites (#414, #415)
          
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
          
          rem Check for Fire button to start game (quick press, not hold)
          if joy0fire && LevelSelectHoldTimer < 60 then goto StartGame1
          
          rem Return to MainLoop for next frame
          rem MainLoop will call drawscreen after this returns
          return

StartGame1
          rem Transition to Game mode after arena selection
          let GameMode = ModeGame : gosub bank13 ChangeGameMode
          return

LevelSelectReturnToCharacterSelect
          rem Return to character select (Game Select switch or 1-second Fire hold)
          GameMode = ModeCharacterSelect : gosub bank13 ChangeGameMode
          return

          rem =================================================================
          rem DISPLAY ARENA NUMBER
          rem =================================================================
          rem Displays arena number as two digits (01-16) or '??' for random.
          rem Uses DrawDigit function to render digits side-by-side.
          rem
          rem INPUT: selectedArena (0-15 for arenas, 255 for random)
          rem OUTPUT: Renders digits using player0 and player1 sprites
          
DisplayArenaNumber
          rem Check for random arena (255 = RandomArena)
          if selectedArena = RandomArena then goto DisplayRandomArena
          
          rem Format arena number as two-digit decimal (01-16)
          rem Arena 0 = "01", Arena 1 = "02", ..., Arena 15 = "16"
          rem Calculate display value: selectedArena + 1
          temp6 = selectedArena + 1
          
          rem Calculate tens digit (0 or 1)
          rem Using division: tens = value / 10
          temp1 = temp6 / 10
          
          rem Calculate ones digit (0-9)
          rem Using modulo: ones = value - (tens * 10)
          temp2 = temp1 * 10
          temp3 = temp6 - temp2
          
          rem Draw tens digit using player0 sprite
          rem Position at X=60, Y=40 (center-left of screen)
          rem Save original values
          temp4 = temp2
          temp5 = temp3
          rem Set up DrawDigit call
          rem temp1 = digit value, temp2 = X pos, temp3 = Y pos, temp4 = color, temp5 = sprite select
          temp2 = 60 : temp3 = 40 : temp4 = $0E : temp5 = 0
          gosub DrawDigit
          
          rem Restore ones digit to temp1 for second DrawDigit call
          temp1 = temp5 : temp2 = 68 : temp3 = 40 : temp4 = $0E : temp5 = 1
          gosub DrawDigit
          
          return

DisplayRandomArena
          rem Display '??' for random arena selection
          rem Note: Question mark not in font yet, using 'F' (15) as placeholder
          rem Position player0 and player1 side-by-side
          
          rem Draw first '?' placeholder (using F=15 as temporary)
          temp1 = 15 : temp2 = 60 : temp3 = 40 : temp4 = $0E : temp5 = 0
          gosub DrawDigit
          
          rem Draw second '?' placeholder (using F=15 as temporary)
          temp1 = 15 : temp2 = 68 : temp3 = 40 : temp4 = $0E : temp5 = 1
          gosub DrawDigit
          
          rem Note: Displays "FF" as placeholder until question mark added to font system
          
          return