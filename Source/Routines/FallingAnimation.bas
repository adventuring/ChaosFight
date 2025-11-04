          rem ChaosFight - Source/Routines/FallingAnimation1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FALLING IN ANIMATION - PER-FRAME LOOP
          rem =================================================================
          rem Per-frame falling animation that moves players from quadrants
          rem to their row 2 starting positions.
          rem Called from MainLoop each frame (gameMode 4).
          rem
          rem FLOW:
          rem   1. Move each active player toward their target position
          rem   2. Check if all players have reached their targets
          rem   3. When complete, transition to Game Mode
          rem
          rem TARGET POSITIONS (row 2, Y=24):
          rem   2-player: P1 at (53, 24), P2 at (107, 24)
          rem   4-player: P1 at (32, 24), P3 at (64, 24), P4 at (96, 24), P2 at (128, 24)
          rem =================================================================

FallingAnimation1
          rem Update animation frame
          let fallFrame = fallFrame + 1
          if fallFrame > 3 then let fallFrame = 0
          
          rem Move Player 1 from quadrant to target (if active)
          if selectedChar1 = NoCharacter then SkipPlayer1Move
          rem temp1 = 0 (player index), temp2 = target X, temp3 = target Y (24)
          let temp1 = 0
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player1Target4P
          rem 2-player mode: target X = 53
          let temp2 = 53
          goto Player1TargetDone
Player1Target4P
          rem 4-player mode: target X = 32
          let temp2 = 32
Player1TargetDone
          let temp3 = 24
          rem Target Y (row 2)
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
          rem temp4 = 1 if reached target
SkipPlayer1Move
          
          rem Move Player 2 from quadrant to target (if active)
          if selectedChar2 = NoCharacter then SkipPlayer2Move
          let temp1 = 1
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player2Target4P
          rem 2-player mode: target X = 107
          let temp2 = 107
          goto Player2TargetDone
Player2Target4P
          rem 4-player mode: target X = 128
          let temp2 = 128
Player2TargetDone
          let temp3 = 24
          rem Target Y (row 2)
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
SkipPlayer2Move
          
          rem Move Player 3 from quadrant to target (if active)
          if !(controllerStatus & SetQuadtariDetected) then SkipPlayer3Move
          if selectedChar3 = NoCharacter then SkipPlayer3Move
          let temp1 = 2
          rem 4-player mode: target X = 64
          let temp2 = 64
          let temp3 = 24
          rem Target Y (row 2)
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
SkipPlayer3Move
          
          rem Move Player 4 from quadrant to target (if active)
          if !(controllerStatus & SetQuadtariDetected) then SkipPlayer4Move
          if selectedChar4 = NoCharacter then SkipPlayer4Move
          let temp1 = 3
          rem 4-player mode: target X = 96
          let temp2 = 96
          let temp3 = 24
          rem Target Y (row 2)
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
SkipPlayer4Move
          
          rem Check if all players have reached their targets
          if fallComplete >= activePlayers then FallingComplete1
          
          rem Draw falling sprites for all active players
          rem TODO: Use dynamic sprite setting instead of player declarations
          
          drawscreen
          goto FallingAnimation1
          
FallingComplete1
          rem All players have reached row 2 positions
          rem Call BeginGameLoop to initialize game state before switching modes
          rem Note: BeginGameLoop will use final positions from falling animation
          gosub bank11 BeginGameLoop
          rem Transition to Game Mode
          let gameMode = ModeGame
          gosub bank13 ChangeGameMode
          return
          
          rem =================================================================
          rem MOVE PLAYER TO TARGET POSITION
          rem =================================================================
          rem Moves a player from their current position toward target (X, Y).
          rem Handles both horizontal and vertical movement.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = target X position
          rem   temp3 = target Y position
          rem
          rem OUTPUT:
          rem   temp4 = 1 if reached target, 0 if still moving
          rem
          rem EFFECTS:
          rem   Updates playerX[temp1] and playerY[temp1] toward target
MovePlayerToTarget
          dim MPTT_playerIndex = temp1
          dim MPTT_targetX = temp2
          dim MPTT_targetY = temp3
          dim MPTT_reached = temp4
          dim MPTT_currentX = temp5
          dim MPTT_currentY = temp6
          dim MPTT_deltaX = yDistance
          rem Reuse yDistance SCRAM variable for delta X
          dim MPTT_deltaY = rowYPosition
          rem Reuse rowYPosition SCRAM variable for delta Y
          
          rem Get current position
          let MPTT_currentX = playerX[MPTT_playerIndex]
          let MPTT_currentY = playerY[MPTT_playerIndex]
          
          rem Calculate distances to target
          if MPTT_currentX >= MPTT_targetX then CalcDeltaXRight
          let MPTT_deltaX = MPTT_targetX - MPTT_currentX
          goto DeltaXDone
CalcDeltaXRight
          let MPTT_deltaX = MPTT_currentX - MPTT_targetX
DeltaXDone
          
          if MPTT_currentY >= MPTT_targetY then CalcDeltaYDown
          let MPTT_deltaY = MPTT_targetY - MPTT_currentY
          goto DeltaYDone
CalcDeltaYDown
          let MPTT_deltaY = MPTT_currentY - MPTT_targetY
DeltaYDone
          
          rem Check if already at target (within 1 pixel)
          if MPTT_deltaX <= 1 && MPTT_deltaY <= 1 then AtTarget
          
          rem Move toward target (horizontal first, then vertical)
          rem Move horizontally if not at target X
          if MPTT_currentX < MPTT_targetX then MoveRight
          if MPTT_currentX > MPTT_targetX then MoveLeft
          goto HorizontalDone
MoveRight
          let playerX[MPTT_playerIndex] = playerX[MPTT_playerIndex] + fallSpeed
          rem Clamp to target if overshot
          if playerX[MPTT_playerIndex] > MPTT_targetX then let playerX[MPTT_playerIndex] = MPTT_targetX
          goto HorizontalDone
MoveLeft
          let playerX[MPTT_playerIndex] = playerX[MPTT_playerIndex] - fallSpeed
          rem Clamp to target if overshot
          if playerX[MPTT_playerIndex] < MPTT_targetX then let playerX[MPTT_playerIndex] = MPTT_targetX
HorizontalDone
          
          rem Move vertically if not at target Y
          if MPTT_currentY < MPTT_targetY then MoveDown
          if MPTT_currentY > MPTT_targetY then MoveUp
          goto VerticalDone
MoveDown
          let playerY[MPTT_playerIndex] = playerY[MPTT_playerIndex] + fallSpeed
          rem Clamp to target if overshot
          if playerY[MPTT_playerIndex] > MPTT_targetY then let playerY[MPTT_playerIndex] = MPTT_targetY
          goto VerticalDone
MoveUp
          let playerY[MPTT_playerIndex] = playerY[MPTT_playerIndex] - fallSpeed
          rem Clamp to target if overshot
          if playerY[MPTT_playerIndex] < MPTT_targetY then let playerY[MPTT_playerIndex] = MPTT_targetY
VerticalDone
          
          rem Check if reached target after movement
          let MPTT_currentX = playerX[MPTT_playerIndex]
          let MPTT_currentY = playerY[MPTT_playerIndex]
          if MPTT_currentX = MPTT_targetX && MPTT_currentY = MPTT_targetY then AtTarget
          let MPTT_reached = 0
          return
          
AtTarget
          rem Reached target position
          let MPTT_reached = 1
          return
          
          rem =================================================================
          rem MOVE PLAYER TO ROW 2 (legacy function name, now calls MovePlayerToTarget)
          rem =================================================================
MovePlayerToRow2
          rem This is a placeholder - actual movement handled by MovePlayerToTarget
          rem Kept for compatibility if referenced elsewhere
          return