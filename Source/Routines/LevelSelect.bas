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

          rem =================================================================
          rem DISPLAY ARENA NUMBER
          rem =================================================================
          rem Displays arena number as two digits (01-16) or '??' for random.
          rem Uses DrawDigit function to render digits side-by-side.
          rem
          rem INPUT: selectedArena (0-15 for arenas, 255 for random)
          rem OUTPUT: Renders digits using player0 and player1 sprites
          
DisplayArenaNumber
          rem Check for random arena (255)
          if selectedArena = RandomArena then goto DisplayRandomArena
          
          rem Format arena number as two-digit decimal (01-16)
          rem Arena 0 = "01", Arena 1 = "02", ..., Arena 15 = "16"
          rem Calculate display value: selectedArena + 1
          temp1 = selectedArena + 1
          
          rem Calculate tens digit (0 or 1)
          temp2 = temp1 / 10
          
          rem Calculate ones digit (0-9)
          temp3 = temp1 - (temp2 * 10)
          
          rem Draw tens digit using player0 sprite
          rem Position at X=60, Y=40 (center-left of screen)
          temp1 = temp2 : temp2 = 60 : temp3 = 40 : temp4 = $0E : temp5 = 0
          gosub DrawDigit
          
          rem Draw ones digit using player1 sprite  
          rem Position at X=68, Y=40 (8 pixels to right of tens digit)
          temp1 = temp3 : temp2 = 68 : temp3 = 40 : temp4 = $0E : temp5 = 1
          gosub DrawDigit
          
          return

DisplayRandomArena
          rem Display '??' for random arena selection
          rem TODO: Add question mark character to font system
          rem For now, use placeholder values (15 = F) to indicate random
          rem Position player0 and player1 side-by-side
          
          rem Draw first '?' placeholder (using F as temporary)
          temp1 = 15 : temp2 = 60 : temp3 = 40 : temp4 = $0E : temp5 = 0
          gosub DrawDigit
          
          rem Draw second '?' placeholder (using F as temporary)
          temp1 = 15 : temp2 = 68 : temp3 = 40 : temp4 = $0E : temp5 = 1
          gosub DrawDigit
          
          rem Note: This displays "FF" temporarily until question mark is added to font
          
          return