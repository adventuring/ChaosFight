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
          rem This check happens each frame but activePlayers is set in BeginFallingAnimation
          rem We recalculate here in case players change (shouldn't happen, but safety check)
          rem Note: activePlayers counting is now handled in BeginFallingAnimation
          
          rem Animate all active players falling using dynamic sprite setting
          rem Use playerY[] array and map to correct sprite registers
          
          rem Participant 1 (array [0]) → P0 sprite (player0x/player0y)
          if playerChar[0] = 255 then goto SkipPlayer1Fall
          
          rem Move from quadrant position toward top of screen
          rem Target: Y = 10 (top of screen), X stays at quadrant position
          rem Move Y upward (decrease Y value)
          if playerY[0] > 10 then playerY[0] = playerY[0] - fallSpeed
          if playerY[0] < 10 then playerY[0] = 10
          
          rem Check if reached top of screen
          if playerY[0] = 10 then let fallComplete = fallComplete + 1
          
          player0y = playerY[0]
          player0x = playerX[0]
SkipPlayer1Fall

          rem Participant 2 (array [1]) → P1 sprite (player1x/player1y, virtual _P1)
          if playerChar[1] = 255 then goto SkipPlayer2Fall
          
          rem Move from quadrant position toward top of screen
          rem Target: Y = 10 (top of screen), X stays at quadrant position
          if playerY[1] > 10 then playerY[1] = playerY[1] - fallSpeed
          if playerY[1] < 10 then playerY[1] = 10
          
          if playerY[1] = 10 then let fallComplete = fallComplete + 1
          
          player1y = playerY[1]
          player1x = playerX[1]
SkipPlayer2Fall

          rem Participant 3 (array [2]) → P2 sprite (player2x/player2y) - 4-player mode only
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer3Fall
          if selectedChar3 = 255 then goto SkipPlayer3Fall
          if playerChar[2] = 255 then goto SkipPlayer3Fall
          
          rem Move from quadrant position toward top of screen
          rem Target: Y = 10 (top of screen), X stays at quadrant position
          if playerY[2] > 10 then playerY[2] = playerY[2] - fallSpeed
          if playerY[2] < 10 then playerY[2] = 10
          
          if playerY[2] = 10 then let fallComplete = fallComplete + 1
          
          let player2y = playerY[2]
          let player2x = playerX[2]
SkipPlayer3Fall

          rem Participant 4 (array [3]) → P3 sprite (player3x/player3y) - 4-player mode only
          if ! (controllerStatus & SetQuadtariDetected) then goto SkipPlayer4Fall
          if selectedChar4 = 255 then goto SkipPlayer4Fall
          if playerChar[3] = 255 then goto SkipPlayer4Fall
          
          rem Move from quadrant position toward top of screen
          rem Target: Y = 10 (top of screen), X stays at quadrant position
          if playerY[3] > 10 then playerY[3] = playerY[3] - fallSpeed
          if playerY[3] < 10 then playerY[3] = 10
          
          if playerY[3] = 10 then let fallComplete = fallComplete + 1
          
          let player3y = playerY[3]
          let player3x = playerX[3]
SkipPlayer4Fall

          rem Check if all players have finished falling
          if fallComplete >= activePlayers then goto FallingComplete1

          rem Update animation frame
          let fallFrame = fallFrame + 1
          if fallFrame > 3 then let fallFrame = 0

          rem Set falling sprites for all active players using dynamic sprite setting
          rem Sprites are now set above using playerX[]/playerY[] arrays mapped to correct registers

          rem Return to MainLoop for next frame
          return

FallingComplete1
          rem All players have reached top of screen - transition to Game mode
          rem Players are now positioned at top (Y=10) at their quadrant X positions
          rem Game mode will start with gravity, causing players to fall naturally
          
          rem Initialize game state before transitioning to Game mode
          rem BeginGameLoop sets up player positions, health, missiles, etc.
          rem Note: Player positions are already set at top of screen (Y=10)
          rem with quadrant X positions, so BeginGameLoop should preserve these
          gosub BeginGameLoop
          
          rem Transition to Game mode after initialization
          rem Note: BeginGameLoop returns here, then we change mode
          rem MainLoop will dispatch to GameMainLoop each frame
          rem Gravity in game mode will cause players to fall from top position
          let gameMode = ModeGame : gosub bank13 ChangeGameMode
          return