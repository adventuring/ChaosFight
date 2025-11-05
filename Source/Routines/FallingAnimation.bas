          rem ChaosFight - Source/Routines/FallingAnimation1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem FALLING IN ANIMATION - PER-FRAME LOOP
          rem ==========================================================
          rem Per-frame falling animation that moves players from
          rem   quadrants
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
          rem 4-player: P1 at (32, 24), P3 at (64, 24), P4 at (96, 24),
          rem   P2 at (128, 24)
          rem ==========================================================

FallingAnimation1
          dim FA1_playerIndex = temp1
          dim FA1_targetX = temp2
          dim FA1_targetY = temp3
          dim FA1_reached = temp4
          rem Update animation frame
          let fallFrame = fallFrame + 1
          if fallFrame > 3 then let fallFrame = 0
          
          rem Move Player 1 from quadrant to target (if active)
          if selectedChar1 = NoCharacter then DonePlayer1Move
          rem playerIndex = 0 (player index), targetX = target X,
          rem   targetY = target Y (24)
          let FA1_playerIndex = 0
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player1Target4P
          rem 2-player mode: target X = 53
          let FA1_targetX = 53
          goto Player1TargetDone
Player1Target4P
          rem 4-player mode: target X = 32
          let FA1_targetX = 32
Player1TargetDone
          let FA1_targetY = 24
          rem Target Y (row 2)
          let MPTT_playerIndex = FA1_playerIndex
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
          rem reached = 1 if reached target
DonePlayer1Move
          
          rem Move Player 2 from quadrant to target (if active)
          if selectedChar2_R = NoCharacter then DonePlayer2Move
          let FA1_playerIndex = 1
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player2Target4P
          rem 2-player mode: target X = 107
          let FA1_targetX = 107
          goto Player2TargetDone
Player2Target4P
          rem 4-player mode: target X = 128
          let FA1_targetX = 128
Player2TargetDone
          let FA1_targetY = 24
          rem Target Y (row 2)
          let MPTT_playerIndex = FA1_playerIndex
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
DonePlayer2Move
          
          rem Move Player 3 from quadrant to target (if active)
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer3Move
          if selectedChar3_R = NoCharacter then DonePlayer3Move
          let FA1_playerIndex = 2
          rem 4-player mode: target X = 64
          let FA1_targetX = 64
          let FA1_targetY = 24
          rem Target Y (row 2)
          let MPTT_playerIndex = FA1_playerIndex
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
DonePlayer3Move
          
          rem Move Player 4 from quadrant to target (if active)
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer4Move
          if selectedChar4_R = NoCharacter then DonePlayer4Move
          let FA1_playerIndex = 3
          rem 4-player mode: target X = 96
          let FA1_targetX = 96
          let FA1_targetY = 24
          rem Target Y (row 2)
          let MPTT_playerIndex = FA1_playerIndex
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
DonePlayer4Move
          
          rem Check if all players have reached their targets
          if fallComplete >= activePlayers then FallingComplete1
          
          rem Set sprite positions and load character sprites
          rem   dynamically
          rem Use dynamic sprite setting instead of relying on player
          rem   declarations
          gosub bank11 SetSpritePositions
          gosub bank11 SetPlayerSprites
          
          drawscreen
          goto FallingAnimation1
          
FallingComplete1
          rem All players have reached row 2 positions
          rem Call BeginGameLoop to initialize game state before
          rem   switching modes
          rem Note: BeginGameLoop will use final positions from falling
          rem   animation
          gosub bank11 BeginGameLoop
          rem Transition to Game Mode
          let gameMode = ModeGame
          gosub bank13 ChangeGameMode
          return
          
          rem ==========================================================
          rem MOVE PLAYER TO TARGET POSITION
          rem ==========================================================
          rem Moves a player from their current position toward target
          rem   (X, Y).
          rem Handles both horizontal and vertical movement.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3) → MPTT_playerIndex
          rem   temp2 = target X position → MPTT_targetX
          rem   temp3 = target Y position → MPTT_targetY
          rem
          rem OUTPUT:
          rem   temp4 = 1 if reached target, 0 if still moving → MPTT_reached
          rem
          rem MUTATES:
          rem   moving)
          rem temp4 = MPTT_reached (return value: 1 if reached, 0 if
          rem   temp5, temp6 = Internal calculations (do not use after call)
          rem   temp4
          rem WARNING: Callers should read from MPTT_reached alias, not
          rem   directly. Do not use temp5 or temp6 after calling this
          rem   subroutine.
          rem
          rem EFFECTS:
          rem   Updates playerX[MPTT_playerIndex] and playerY[MPTT_playerIndex]
          rem   toward target
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
          
          rem Check playfield collision and nudge if needed
          gosub NudgePlayerFromPlayfield
          
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
          
          rem ==========================================================
          rem NUDGE PLAYER FROM PLAYFIELD COLLISION
          rem ==========================================================
          rem Checks if player collides with playfield and nudges them
          rem   away.
          rem Prevents players from getting stuck in playfield obstacles
          rem   during animation.
          rem
          rem INPUT:
          rem   MPTT_playerIndex (temp1) = player index (0-3)
          rem playerX[MPTT_playerIndex], playerY[MPTT_playerIndex] =
          rem   current position
          rem
          rem MODIFIES:
          rem playerX[MPTT_playerIndex], playerY[MPTT_playerIndex] =
          rem   nudged position if collision
          rem
          rem EFFECTS:
          rem If playfield collision detected, nudges player 1 pixel
          rem   away from obstacle
NudgePlayerFromPlayfield
          dim NPF_playerIndex = temp1
          dim NPF_playerX = temp7
          dim NPF_playerY = temp8
          dim NPF_pfColumn = temp9
          dim NPF_pfRow = tempA
          dim NPF_targetX = temp2
          dim NPF_targetY = temp3
          
          rem Get current position
          let NPF_playerX = playerX[NPF_playerIndex]
          let NPF_playerY = playerY[NPF_playerIndex]
          
          rem Convert X position to playfield column (0-31)
          let NPF_pfColumn = NPF_playerX
          let NPF_pfColumn = NPF_pfColumn - ScreenInsetX
          asm
            lsr NPF_pfColumn
            lsr NPF_pfColumn
end
          rem Clamp column to valid range
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if NPF_pfColumn & $80 then let NPF_pfColumn = 0
          if NPF_pfColumn > 31 then let NPF_pfColumn = 31
          
          rem Convert Y position to playfield row (divide by
          rem   pfrowheight)
          rem pfrowheight is typically 8 or 16 (powers of 2), so use bit
          rem   shifts
          rem If pfrowheight = 8: divide by 8 = 3 right shifts
          rem If pfrowheight = 16: divide by 16 = 4 right shifts
          rem Use 4 shifts for safety (works for both 8 and 16, may be
          rem   off by 1 for 8 but acceptable for simple nudge)
          let NPF_pfRow = NPF_playerY
          asm
            lsr NPF_pfRow
            lsr NPF_pfRow
            lsr NPF_pfRow
            lsr NPF_pfRow
end
          if NPF_pfRow >= pfrows then let NPF_pfRow = pfrows - 1
          rem Check for wraparound: if division resulted in value ≥ 128 (negative), clamp to 0
          rem   check
          rem Note: This is unlikely for row calculation but safe to
          if NPF_pfRow & $80 then let NPF_pfRow = 0
          
          rem Check collision at player position (simple single-point
          rem   check)
          if pfread(NPF_pfColumn, NPF_pfRow) then NudgeFromPF
          
          rem No collision, return
          return
          
NudgeFromPF
          rem Collision detected - nudge player 1 pixel in direction
          rem   toward target
          rem Nudge horizontally toward target first
          rem Get targetX from parent function (preserved in temp2)
          let NPF_targetX = temp2
          let NPF_targetY = temp3
          if NPF_playerX < NPF_targetX then NudgeRight
          if NPF_playerX > NPF_targetX then NudgeLeft
          goto NudgeHorizontalDone
NudgeRight
          let playerX[NPF_playerIndex] = playerX[NPF_playerIndex] + 1
          goto NudgeHorizontalDone
NudgeLeft
          let playerX[NPF_playerIndex] = playerX[NPF_playerIndex] - 1
NudgeHorizontalDone
          
          rem If still colliding, nudge vertically toward target
          let NPF_playerX = playerX[NPF_playerIndex]
          let NPF_pfColumn = NPF_playerX
          let NPF_pfColumn = NPF_pfColumn - ScreenInsetX
          asm
            lsr NPF_pfColumn
            lsr NPF_pfColumn
end
          rem   result ≥ 128
          rem Check for wraparound: if subtraction wrapped negative,
          if NPF_pfColumn & $80 then let NPF_pfColumn = 0
          if NPF_pfColumn > 31 then let NPF_pfColumn = 31
          
          if pfread(NPF_pfColumn, NPF_pfRow) then NudgeVertical
          return
          
NudgeVertical
          rem Still colliding, nudge vertically
          if NPF_playerY < NPF_targetY then NudgeDown
          if NPF_playerY > NPF_targetY then NudgeUp
          return
NudgeDown
          let playerY[NPF_playerIndex] = playerY[NPF_playerIndex] + 1
          return
NudgeUp
          let playerY[NPF_playerIndex] = playerY[NPF_playerIndex] - 1
          return
