          rem ChaosFight - Source/Routines/BeginFallingAnimation.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem BEGIN FALLING ANIMATION
          rem ==========================================================
          rem Setup routine for Falling In animation.
          rem Sets players in quadrant starting positions and
          rem   initializes state.
          rem
          rem Quadrant positions:
          rem   - Top-left: Player 1 (selectedChar1)
          rem   - Top-right: Player 2 (selectedChar2_R)
          rem   - Bottom-left: Player 3 (selectedChar3_R, if active)
          rem   - Bottom-right: Player 4 (selectedChar4_R, if active)
          rem
          rem After animation completes, players will be at row 2
          rem   positions
          rem and transition to Game Mode.
          rem ==========================================================

BeginFallingAnimation
          rem Initialize animation state
          let fallFrame = 0
          let fallSpeed = 2
          let fallComplete = 0
          let activePlayers = 0
          
          rem Set game screen layout (32×8 for playfield scanning)
          gosub bank8 SetGameScreenLayout
          
          rem Set background color
          let COLUBK = ColGray(0)
          
          rem Initialize player positions in quadrants
          rem Player 1: Top-left quadrant (unless NO)
          if selectedChar1 = NoCharacter then DonePlayer1Init
          let playerX[0] = 16
          rem Top-left X position
          let playerY[0] = 8
          rem Top-left Y position (near top)
          let activePlayers = activePlayers + 1
DonePlayer1Init
          
          rem Player 2: Top-right quadrant (unless NO)
          if selectedChar2_R = NoCharacter then DonePlayer2Init
          let playerX[1] = 144
          rem Top-right X position
          let playerY[1] = 8
          rem Top-right Y position (near top)
          let activePlayers = activePlayers + 1
DonePlayer2Init
          
          rem Player 3: Bottom-left quadrant (if Quadtari and not NO)
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer3Init
          if selectedChar3_R = NoCharacter then DonePlayer3Init
          let playerX[2] = 16
          rem Bottom-left X position
          let playerY[2] = 80
          rem Bottom-left Y position (near bottom)
          let activePlayers = activePlayers + 1
DonePlayer3Init
          
          rem Player 4: Bottom-right quadrant (if Quadtari and not NO)
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer4Init
          if selectedChar4_R = NoCharacter then DonePlayer4Init
          let playerX[3] = 144
          rem Bottom-right X position
          let playerY[3] = 80
          rem Bottom-right Y position (near bottom)
          let activePlayers = activePlayers + 1
DonePlayer4Init
          
          return


