          rem ChaosFight - Source/Routines/FallingAnimation.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FALLING ANIMATION LOOP - Called from MainLoop each frame
          rem =================================================================
          rem This is the main loop that runs each frame during Falling Animation mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginFallingAnimation (called from ChangeGameMode).

FallingAnimation1
          rem Count active players for falling animation (only on first frame)
          rem This check happens each frame but ActivePlayers is set in BeginFallingAnimation
          rem We recalculate here in case players change (shouldn't happen, but safety check)
          rem Note: ActivePlayers counting is now handled in BeginFallingAnimation
          
          rem Animate all active players falling using dynamic sprite setting
          rem Use PlayerY[] array and map to correct sprite registers
          
          rem Participant 1 (array [0]) → P0 sprite (player0x/player0y)
          if PlayerChar[0] = 255 then goto SkipPlayer1Fall
          PlayerY[0] = PlayerY[0] - FallSpeed
          if PlayerY[0] < 20 then PlayerY[0] = 20 : let FallComplete = FallComplete + 1
          player0y = PlayerY[0]
          player0x = PlayerX[0]
SkipPlayer1Fall

          rem Participant 2 (array [1]) → P1 sprite (player1x/player1y, virtual _P1)
          if PlayerChar[1] = 255 then goto SkipPlayer2Fall
          PlayerY[1] = PlayerY[1] - FallSpeed
          if PlayerY[1] < 20 then PlayerY[1] = 20 : let FallComplete = FallComplete + 1
          player1y = PlayerY[1]
          player1x = PlayerX[1]
SkipPlayer2Fall

          rem Participant 3 (array [2]) → P2 sprite (player2x/player2y) - 4-player mode only
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Fall
          if selectedChar3 = 255 then goto SkipPlayer3Fall
          if PlayerChar[2] = 255 then goto SkipPlayer3Fall
          PlayerY[2] = PlayerY[2] - FallSpeed
          if PlayerY[2] < 20 then PlayerY[2] = 20 : let FallComplete = FallComplete + 1
          player2y = PlayerY[2]
          player2x = PlayerX[2]
SkipPlayer3Fall

          rem Participant 4 (array [3]) → P3 sprite (player3x/player3y) - 4-player mode only
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Fall
          if selectedChar4 = 255 then goto SkipPlayer4Fall
          if PlayerChar[3] = 255 then goto SkipPlayer4Fall
          PlayerY[3] = PlayerY[3] - FallSpeed
          if PlayerY[3] < 20 then PlayerY[3] = 20 : let FallComplete = FallComplete + 1
          player3y = PlayerY[3]
          player3x = PlayerX[3]
SkipPlayer4Fall

          rem Check if all players have finished falling
          if FallComplete >= ActivePlayers then goto FallingComplete1

          rem Update animation frame
          let FallFrame = FallFrame + 1
          if FallFrame > 3 then let FallFrame = 0

          rem Set falling sprites for all active players using dynamic sprite setting
          rem Sprites are now set above using PlayerX[]/PlayerY[] arrays mapped to correct registers

          rem Return to MainLoop for next frame
          return

FallingComplete1
          rem Initialize game state before transitioning to Game mode
          rem BeginGameLoop sets up player positions, health, missiles, etc.
          gosub BeginGameLoop
          
          rem Transition to Game mode after initialization
          rem Note: BeginGameLoop returns here, then we change mode
          rem MainLoop will dispatch to GameMainLoop each frame
          let GameMode = ModeGame : gosub bank13 ChangeGameMode
          return