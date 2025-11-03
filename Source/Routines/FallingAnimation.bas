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
          
          rem Phase 1: Fall from top (Y movement down)
          rem Phase 2: Move from quadrant toward center (both X and Y)
          rem Check if still falling (Y > target Y)
          if PlayerY[0] > 80 then goto Player1FallPhase
          
          rem Phase 2: Move toward center position (both X and Y simultaneously)
          rem Target center X = 80, current X from quadrant = 40
          rem Move X toward center
          if PlayerX[0] < 80 then PlayerX[0] = PlayerX[0] + 2
          if PlayerX[0] > 80 then PlayerX[0] = PlayerX[0] - 2
          
          rem Move Y toward target row (80)
          if PlayerY[0] < 80 then PlayerY[0] = PlayerY[0] + 2
          if PlayerY[0] > 80 then PlayerY[0] = PlayerY[0] - 2
          
          rem Check if reached center position
          if PlayerX[0] = 80 && PlayerY[0] = 80 then let FallComplete = FallComplete + 1
          goto Player1SetPos
          
Player1FallPhase
          rem Phase 1: Fall down from top
          PlayerY[0] = PlayerY[0] - FallSpeed
          if PlayerY[0] < 80 then PlayerY[0] = 80
          
Player1SetPos
          player0y = PlayerY[0]
          player0x = PlayerX[0]
SkipPlayer1Fall

          rem Participant 2 (array [1]) → P1 sprite (player1x/player1y, virtual _P1)
          if PlayerChar[1] = 255 then goto SkipPlayer2Fall
          
          rem Phase 1: Fall from top, Phase 2: Move toward center
          if PlayerY[1] > 80 then goto Player2FallPhase
          
          rem Phase 2: Move toward center (X=80, Y=80)
          if PlayerX[1] < 80 then PlayerX[1] = PlayerX[1] + 2
          if PlayerX[1] > 80 then PlayerX[1] = PlayerX[1] - 2
          if PlayerY[1] < 80 then PlayerY[1] = PlayerY[1] + 2
          if PlayerY[1] > 80 then PlayerY[1] = PlayerY[1] - 2
          
          if PlayerX[1] = 80 && PlayerY[1] = 80 then let FallComplete = FallComplete + 1
          goto Player2SetPos
          
Player2FallPhase
          PlayerY[1] = PlayerY[1] - FallSpeed
          if PlayerY[1] < 80 then PlayerY[1] = 80
          
Player2SetPos
          player1y = PlayerY[1]
          player1x = PlayerX[1]
SkipPlayer2Fall

          rem Participant 3 (array [2]) → P2 sprite (player2x/player2y) - 4-player mode only
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Fall
          if selectedChar3 = 255 then goto SkipPlayer3Fall
          if PlayerChar[2] = 255 then goto SkipPlayer3Fall
          
          rem Phase 1: Fall from top, Phase 2: Move toward center
          if PlayerY[2] > 80 then goto Player3FallPhase
          
          rem Phase 2: Move toward center (X=80, Y=80)
          if PlayerX[2] < 80 then PlayerX[2] = PlayerX[2] + 2
          if PlayerX[2] > 80 then PlayerX[2] = PlayerX[2] - 2
          if PlayerY[2] < 80 then PlayerY[2] = PlayerY[2] + 2
          if PlayerY[2] > 80 then PlayerY[2] = PlayerY[2] - 2
          
          if PlayerX[2] = 80 && PlayerY[2] = 80 then let FallComplete = FallComplete + 1
          goto Player3SetPos
          
Player3FallPhase
          PlayerY[2] = PlayerY[2] - FallSpeed
          if PlayerY[2] < 80 then PlayerY[2] = 80
          
Player3SetPos
          player2y = PlayerY[2]
          player2x = PlayerX[2]
SkipPlayer3Fall

          rem Participant 4 (array [3]) → P3 sprite (player3x/player3y) - 4-player mode only
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Fall
          if selectedChar4 = 255 then goto SkipPlayer4Fall
          if PlayerChar[3] = 255 then goto SkipPlayer4Fall
          
          rem Phase 1: Fall from top, Phase 2: Move toward center
          if PlayerY[3] > 80 then goto Player4FallPhase
          
          rem Phase 2: Move toward center (X=80, Y=80)
          if PlayerX[3] < 80 then PlayerX[3] = PlayerX[3] + 2
          if PlayerX[3] > 80 then PlayerX[3] = PlayerX[3] - 2
          if PlayerY[3] < 80 then PlayerY[3] = PlayerY[3] + 2
          if PlayerY[3] > 80 then PlayerY[3] = PlayerY[3] - 2
          
          if PlayerX[3] = 80 && PlayerY[3] = 80 then let FallComplete = FallComplete + 1
          goto Player4SetPos
          
Player4FallPhase
          PlayerY[3] = PlayerY[3] - FallSpeed
          if PlayerY[3] < 80 then PlayerY[3] = 80
          
Player4SetPos
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