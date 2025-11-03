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
          
          rem Load and position player character sprites in quadrants
          gosub LoadLevelSelectPlayerSprites
          
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
          
          rem Calculate tens digit using cascading > comparisons
          rem Current max is 16 (arenas 0-15), but support up to 39 for future expansion
          if temp6 > 30 then goto DisplayArenaTens3
          if temp6 > 20 then goto DisplayArenaTens2
          if temp6 > 10 then goto DisplayArenaTens1
          
          rem Single-digit number (1-9): tens = 0
          temp1 = 0
          temp3 = temp6
          goto DisplayArenaDrawTens
          
DisplayArenaTens3
          temp1 = 3
          temp3 = temp6 - 30
          goto DisplayArenaDrawTens
          
DisplayArenaTens2
          temp1 = 2
          temp3 = temp6 - 20
          goto DisplayArenaDrawTens
          
DisplayArenaTens1
          temp1 = 1
          temp3 = temp6 - 10
          
DisplayArenaDrawTens
          rem Draw tens digit using player0 sprite
          rem Position at X=60, Y=40 (center-left of screen)
          rem temp1 = tens digit (0 or 1), temp2 = X pos, temp3 = Y pos, temp4 = color, temp5 = sprite select
          rem Save ones digit (in temp3) to temp6 before overwriting temp3
          temp6 = temp3
          temp2 = 60 : temp3 = 40 : temp4 = $0E : temp5 = 0
          gosub DrawDigit
          
          rem Draw ones digit using player1 sprite
          rem Position at X=68, Y=40 (8 pixels to right of tens digit)
          rem temp1 = ones digit, temp2 = X pos, temp3 = Y pos, temp4 = color, temp5 = sprite select
          temp1 = temp6 : temp2 = 68 : temp3 = 40 : temp4 = $0E : temp5 = 1
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

          rem =================================================================
          rem LOAD LEVEL SELECT PLAYER SPRITES
          rem =================================================================
          rem Loads player character sprites from SelectedChar variables and
          rem positions them in screen quadrants for visual confirmation.
          rem
          rem Quadrant layout:
          rem   Top-left (Player 1): player0 sprite at (40, 30)
          rem   Top-right (Player 2): player1 sprite at (120, 30)
          rem   Bottom-left (Player 3): player2 sprite at (40, 100) - 4-player only
          rem   Bottom-right (Player 4): player3 sprite at (120, 100) - 4-player only
          
LoadLevelSelectPlayerSprites
          rem Load Player 1 sprite (top-left quadrant)
          rem Check if player 1 has selected character
          if selectedChar1 = 255 then goto LoadLevelSelectSkipPlayer1
          rem Load sprite: temp1 = character index, temp2 = animation frame, temp3 = player number
          temp1 = selectedChar1 : temp2 = 0 : temp3 = 0
          gosub bank10 LoadCharacterSprite
          rem Position in top-left quadrant
          player0x = 40 : player0y = 30
          goto LoadLevelSelectPlayer1Done
LoadLevelSelectSkipPlayer1
          rem Hide sprite if no character selected
          player0x = 200 : player0y = 200
LoadLevelSelectPlayer1Done
          
          rem Load Player 2 sprite (top-right quadrant)
          if selectedChar2 = 255 then goto LoadLevelSelectSkipPlayer2
          temp1 = selectedChar2 : temp2 = 0 : temp3 = 1
          gosub bank10 LoadCharacterSprite
          rem Position in top-right quadrant
          player1x = 120 : player1y = 30
          goto LoadLevelSelectPlayer2Done
LoadLevelSelectSkipPlayer2
          rem Hide sprite if no character selected
          player1x = 200 : player1y = 200
LoadLevelSelectPlayer2Done
          
          rem Load Player 3 sprite (bottom-left quadrant) - 4-player mode only
          if !(ControllerStatus & SetQuadtariDetected) then goto LoadLevelSelectSkipPlayer3
          if selectedChar3 = 255 then goto LoadLevelSelectSkipPlayer3
          temp1 = selectedChar3 : temp2 = 0 : temp3 = 2
          gosub bank10 LoadCharacterSprite
          rem Position in bottom-left quadrant
          player2x = 40 : player2y = 100
          goto LoadLevelSelectPlayer3Done
LoadLevelSelectSkipPlayer3
          rem Hide sprite if not 4-player mode or no character selected
          player2x = 200 : player2y = 200
LoadLevelSelectPlayer3Done
          
          rem Load Player 4 sprite (bottom-right quadrant) - 4-player mode only
          if !(ControllerStatus & SetQuadtariDetected) then goto LoadLevelSelectSkipPlayer4
          if selectedChar4 = 255 then goto LoadLevelSelectSkipPlayer4
          temp1 = selectedChar4 : temp2 = 0 : temp3 = 3
          gosub bank10 LoadCharacterSprite
          rem Position in bottom-right quadrant
          player3x = 120 : player3y = 100
          goto LoadLevelSelectPlayer4Done
LoadLevelSelectSkipPlayer4
          rem Hide sprite if not 4-player mode or no character selected
          player3x = 200 : player3y = 200
LoadLevelSelectPlayer4Done
          
          rem Set sprite colors for all players
          rem Use player index colors for visibility
          COLUP0 = ColIndigo(14)  : rem Player 1 - Indigo
          COLUP1 = ColRed(14)      : rem Player 2 - Red
          COLUP2 = ColYellow(14)   : rem Player 3 - Yellow
          COLUP3 = ColGreen(14)    : rem Player 4 - Green
          
          return