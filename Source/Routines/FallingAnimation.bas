FallingAnimation1
          rem
          rem ChaosFight - Source/Routines/FallingAnimation1.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Falling In Animation - Per-frame Loop
          rem
          rem Per-frame falling animation that moves players from
          rem   quadrants
          rem to their row 2 starting positions.
          rem Called from MainLoop each frame (gameMode 4).
          rem
          rem FLOW:
          rem   1. Move each active player toward their target position
          rem   2. Check if all players have reached their targets
          rem   3. When complete, transition to Game Mode
          rem TARGET POSITIONS (row 2, Y=24):
          rem   2-player: P1 at (53, 24), P2 at (107, 24)
          rem 4-player: P1 at (32, 24), P3 at (64, 24), P4 at (96, 24),
          rem   P2 at (128, 24)
          rem Per-frame falling animation that moves players from
          rem quadrants to row 2 positions
          rem
          rem Input: selectedChar1, selectedChar2, selectedChar3_R,
          rem selectedChar4_R (global) = character selections
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        fallFrame (global) = animation frame counter
          rem        fallComplete (global) = count of players who
          rem        reached target
          rem        activePlayers (global) = number of active players
          rem
          rem Output: Dispatches to FallingComplete1 or returns
          rem
          rem Mutates: fallFrame (incremented, wraps at 4), fallComplete
          rem (incremented per player),
          rem         playerX[], playerY[] (updated via
          rem         MovePlayerToTarget)
          rem
          rem Called Routines: MovePlayerToTarget - accesses player
          rem positions, target positions,
          rem   SetSpritePositions (bank11) - accesses player positions,
          rem   SetPlayerSprites (bank11) - accesses character sprites,
          rem   BeginGameLoop (bank11) - initializes game state,
          rem   ChangeGameMode (bank14) - accesses game mode state
          rem
          rem Constraints: Must be colocated with Player1Target4P,
          rem Player1TargetDone, DonePlayer1Move,
          rem              Player2Target4P, Player2TargetDone,
          rem              DonePlayer2Move, DonePlayer3Move,
          rem              DonePlayer4Move, FallingComplete1 (all called
          rem              via goto)
          dim FA1_playerIndex = temp1 : rem              Entry point for falling animation mode (called from MainLoop)
          dim FA1_targetX = temp2
          dim FA1_targetY = temp3
          dim FA1_reached = temp4
          let fallFrame = fallFrame + 1 : rem Update animation frame
          if fallFrame > 3 then let fallFrame = 0
          
          if selectedChar1 = NoCharacter then DonePlayer1Move : rem Move Player 1 from quadrant to target (if active)
          rem playerIndex = 0 (player index), targetX = target X,
          let FA1_playerIndex = 0 : rem targetY = target Y (24)
          if controllerStatus & SetQuadtariDetected then Player1Target4P : rem Check if 4-player mode for target X
          let FA1_targetX = 53 : rem 2-player mode: target X = 53
          goto Player1TargetDone
Player1Target4P
          rem Set Player 1 target X for 4-player mode
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: FA1_targetX set to 32
          rem
          rem Mutates: FA1_targetX
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1,
          rem Player1TargetDone
          let FA1_targetX = 32 : rem 4-player mode: target X = 32
Player1TargetDone
          rem Player 1 target calculation complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          let FA1_targetY = 24 : rem Constraints: Must be colocated with FallingAnimation1
          let MPTT_playerIndex = FA1_playerIndex : rem Target Y (row 2)
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
DonePlayer1Move
          rem reached = 1 if reached target
          rem Player 1 movement complete (skipped if not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1
          
          if selectedChar2_R = NoCharacter then DonePlayer2Move : rem Move Player 2 from quadrant to target (if active)
          let FA1_playerIndex = 1
          if controllerStatus & SetQuadtariDetected then Player2Target4P : rem Check if 4-player mode for target X
          let FA1_targetX = 107 : rem 2-player mode: target X = 107
          goto Player2TargetDone
Player2Target4P
          rem Set Player 2 target X for 4-player mode
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: FA1_targetX set to 128
          rem
          rem Mutates: FA1_targetX
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1,
          rem Player2TargetDone
          let FA1_targetX = 128 : rem 4-player mode: target X = 128
Player2TargetDone
          rem Player 2 target calculation complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          let FA1_targetY = 24 : rem Constraints: Must be colocated with FallingAnimation1
          let MPTT_playerIndex = FA1_playerIndex : rem Target Y (row 2)
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
DonePlayer2Move
          rem Player 2 movement complete (skipped if not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1
          
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer3Move : rem Move Player 3 from quadrant to target (if active)
          if selectedChar3_R = NoCharacter then DonePlayer3Move
          let FA1_playerIndex = 2
          let FA1_targetX = 64 : rem 4-player mode: target X = 64
          let FA1_targetY = 24
          let MPTT_playerIndex = FA1_playerIndex : rem Target Y (row 2)
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
DonePlayer3Move
          rem Player 3 movement complete (skipped if not in 4-player
          rem mode or not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1
          
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer4Move : rem Move Player 4 from quadrant to target (if active)
          if selectedChar4_R = NoCharacter then DonePlayer4Move
          let FA1_playerIndex = 3
          let FA1_targetX = 96 : rem 4-player mode: target X = 96
          let FA1_targetY = 24
          let MPTT_playerIndex = FA1_playerIndex : rem Target Y (row 2)
          let MPTT_targetX = FA1_targetX
          let MPTT_targetY = FA1_targetY
          gosub MovePlayerToTarget
          let FA1_reached = MPTT_reached
          if FA1_reached then let fallComplete = fallComplete + 1
DonePlayer4Move
          rem Player 4 movement complete (skipped if not in 4-player
          rem mode or not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1
          
          if fallComplete >= activePlayers then FallingComplete1 : rem Check if all players have reached their targets
          
          rem Set sprite positions and load character sprites
          rem   dynamically
          rem Use dynamic sprite setting instead of relying on player
          gosub SetSpritePositions bank11 : rem   declarations
          gosub SetPlayerSprites bank11
          
          rem drawscreen called by MainLoop
          return
          goto FallingAnimation1
          
FallingComplete1
          rem All players have reached row 2 positions
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: gameMode set to ModeGame, BeginGameLoop and
          rem ChangeGameMode called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: BeginGameLoop (bank11) - accesses game
          rem state,
          rem   ChangeGameMode (bank14) - accesses game mode state
          rem
          rem Constraints: Must be colocated with FallingAnimation1
          rem All players have reached row 2 positions
          rem Call BeginGameLoop to initialize game state before
          rem   switching modes
          rem Note: BeginGameLoop will use final positions from falling
          gosub BeginGameLoop bank11 : rem   animation
          let gameMode = ModeGame : rem Transition to Game Mode
          gosub ChangeGameMode bank14
          return
          
MovePlayerToTarget
          rem
          rem Move Player To Target Position
          rem
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
          rem   temp4 = 1 if reached target, 0 if still moving →
          rem   MPTT_reached
          rem
          rem MUTATES:
          rem   moving)
          rem temp4 = MPTT_reached (return value: 1 if reached, 0 if
          rem
          rem   temp5, temp6 = Internal calculations (do not use after
          rem   call)
          rem   temp4
          rem WARNING: Callers should read from MPTT_reached alias, not
          rem   directly. Do not use temp5 or temp6 after calling this
          rem   subroutine.
          rem
          rem EFFECTS:
          rem   Updates playerX[MPTT_playerIndex] and
          rem   playerY[MPTT_playerIndex]
          rem   toward target
          rem Moves a player from their current position toward target
          rem (X, Y)
          rem
          rem Input: temp1 = player index (0-3)
          rem        temp2 = target X position
          rem        temp3 = target Y position
          rem        playerX[] (global array) = current player X
          rem        positions
          rem        playerY[] (global array) = current player Y
          rem        positions
          rem        fallSpeed (global) = movement speed per frame
          rem
          rem Output: temp4 = 1 if reached target, 0 if still moving
          rem
          rem Mutates: playerX[MPTT_playerIndex],
          rem playerY[MPTT_playerIndex] (updated toward target),
          rem         temp4 (reached flag), temp5, temp6 (internal
          rem         calculations),
          rem         yDistance (SCRAM, used as MPTT_deltaX),
          rem         rowYPosition (SCRAM, used as MPTT_deltaY)
          rem
          rem Called Routines: NudgePlayerFromPlayfield - accesses
          rem player positions, playfield data
          rem
          rem Constraints: Must be colocated with CalcDeltaXRight,
          rem DeltaXDone, CalcDeltaYDown,
          rem              DeltaYDone, MoveRight, MoveLeft,
          rem              HorizontalDone, MoveDown, MoveUp,
          rem              VerticalDone, AtTarget (all called via goto)
          rem WARNING: temp5, temp6, yDistance, rowYPosition are mutated
          rem during execution.
          dim MPTT_playerIndex = temp1 : rem         Do not use these variables after calling this subroutine.
          dim MPTT_targetX = temp2
          dim MPTT_targetY = temp3
          dim MPTT_reached = temp4
          dim MPTT_currentX = temp5
          dim MPTT_currentY = temp6
          dim MPTT_deltaX = yDistance
          dim MPTT_deltaY = rowYPosition : rem Reuse yDistance SCRAM variable for delta X
          rem Reuse rowYPosition SCRAM variable for delta Y
          
          let MPTT_currentX = playerX[MPTT_playerIndex] : rem Get current position
          let MPTT_currentY = playerY[MPTT_playerIndex]
          
          if MPTT_currentX >= MPTT_targetX then CalcDeltaXRight : rem Calculate distances to target
          let MPTT_deltaX = MPTT_targetX - MPTT_currentX
          goto DeltaXDone
CalcDeltaXRight
          rem Calculate delta X when current X >= target X
          rem
          rem Input: MPTT_currentX, MPTT_targetX (from
          rem MovePlayerToTarget)
          rem
          rem Output: MPTT_deltaX = absolute distance
          rem
          rem Mutates: MPTT_deltaX
          rem
          rem Called Routines: None
          let MPTT_deltaX = MPTT_currentX - MPTT_targetX : rem Constraints: Must be colocated with MovePlayerToTarget, DeltaXDone
DeltaXDone
          rem Delta X calculation complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with MovePlayerToTarget
          
          if MPTT_currentY >= MPTT_targetY then CalcDeltaYDown
          let MPTT_deltaY = MPTT_targetY - MPTT_currentY
          goto DeltaYDone
CalcDeltaYDown
          rem Calculate delta Y when current Y >= target Y
          rem
          rem Input: MPTT_currentY, MPTT_targetY (from
          rem MovePlayerToTarget)
          rem
          rem Output: MPTT_deltaY = absolute distance
          rem
          rem Mutates: MPTT_deltaY
          rem
          rem Called Routines: None
          let MPTT_deltaY = MPTT_currentY - MPTT_targetY : rem Constraints: Must be colocated with MovePlayerToTarget, DeltaYDone
DeltaYDone
          rem Delta Y calculation complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with MovePlayerToTarget
          
          if MPTT_deltaX <= 1 && MPTT_deltaY <= 1 then AtTarget : rem Check if already at target (within 1 pixel)
          
          rem Move toward target (horizontal first, then vertical)
          if MPTT_currentX < MPTT_targetX then MoveRight : rem Move horizontally if not at target X
          if MPTT_currentX > MPTT_targetX then MoveLeft
          goto HorizontalDone
MoveRight
          rem Move player right toward target
          rem
          rem Input: MPTT_playerIndex, MPTT_targetX (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerX[MPTT_playerIndex] updated
          rem
          rem Mutates: playerX[MPTT_playerIndex]
          rem
          rem Called Routines: None
          let playerX[MPTT_playerIndex] = playerX[MPTT_playerIndex] + fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, HorizontalDone
          if playerX[MPTT_playerIndex] > MPTT_targetX then let playerX[MPTT_playerIndex] = MPTT_targetX : rem Clamp to target if overshot
          goto HorizontalDone
MoveLeft
          rem Move player left toward target
          rem
          rem Input: MPTT_playerIndex, MPTT_targetX (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerX[MPTT_playerIndex] updated
          rem
          rem Mutates: playerX[MPTT_playerIndex]
          rem
          rem Called Routines: None
          let playerX[MPTT_playerIndex] = playerX[MPTT_playerIndex] - fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, HorizontalDone
          if playerX[MPTT_playerIndex] < MPTT_targetX then let playerX[MPTT_playerIndex] = MPTT_targetX : rem Clamp to target if overshot
HorizontalDone
          rem Horizontal movement complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with MovePlayerToTarget
          
          if MPTT_currentY < MPTT_targetY then MoveDown : rem Move vertically if not at target Y
          if MPTT_currentY > MPTT_targetY then MoveUp
          goto VerticalDone
MoveDown
          rem Move player down toward target
          rem
          rem Input: MPTT_playerIndex, MPTT_targetY (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerY[MPTT_playerIndex] updated
          rem
          rem Mutates: playerY[MPTT_playerIndex]
          rem
          rem Called Routines: None
          let playerY[MPTT_playerIndex] = playerY[MPTT_playerIndex] + fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, VerticalDone
          if playerY[MPTT_playerIndex] > MPTT_targetY then let playerY[MPTT_playerIndex] = MPTT_targetY : rem Clamp to target if overshot
          goto VerticalDone
MoveUp
          rem Move player up toward target
          rem
          rem Input: MPTT_playerIndex, MPTT_targetY (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerY[MPTT_playerIndex] updated
          rem
          rem Mutates: playerY[MPTT_playerIndex]
          rem
          rem Called Routines: None
          let playerY[MPTT_playerIndex] = playerY[MPTT_playerIndex] - fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, VerticalDone
          if playerY[MPTT_playerIndex] < MPTT_targetY then let playerY[MPTT_playerIndex] = MPTT_targetY : rem Clamp to target if overshot
VerticalDone
          rem Vertical movement complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with MovePlayerToTarget
          
          gosub NudgePlayerFromPlayfield : rem Check playfield collision and nudge if needed
          
          let MPTT_currentX = playerX[MPTT_playerIndex] : rem Check if reached target after movement
          let MPTT_currentY = playerY[MPTT_playerIndex]
          if MPTT_currentX = MPTT_targetX && MPTT_currentY = MPTT_targetY then AtTarget
          let MPTT_reached = 0
          return
          
AtTarget
          rem Reached target position
          rem
          rem Input: None (called from MovePlayerToTarget)
          rem
          rem Output: MPTT_reached set to 1
          rem
          rem Mutates: MPTT_reached (set to 1)
          rem
          rem Called Routines: None
          let MPTT_reached = 1 : rem Constraints: Must be colocated with MovePlayerToTarget
          return
          
NudgePlayerFromPlayfield
          rem
          rem Nudge Player From Playfield Collision
          rem
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
          rem Checks if player collides with playfield and nudges them
          rem away
          rem
          rem Input: temp1 = player index (0-3, from MovePlayerToTarget)
          rem        temp2 = target X position (from MovePlayerToTarget,
          rem        preserved)
          rem        temp3 = target Y position (from MovePlayerToTarget,
          rem        preserved)
          rem        playerX[] (global array) = current player X
          rem        positions
          rem        playerY[] (global array) = current player Y
          rem        positions
          rem        ScreenInsetX (constant) = screen X offset
          rem        pfrows (global) = number of playfield rows
          rem
          rem Output: playerX[NPF_playerIndex], playerY[NPF_playerIndex]
          rem nudged if collision
          rem
          rem Mutates: playerX[NPF_playerIndex],
          rem playerY[NPF_playerIndex] (nudged 1 pixel if collision),
          rem         temp7, temp8, temp9, tempA (internal calculations)
          rem
          rem Called Routines: None (uses pfread for playfield collision
          rem check)
          rem
          rem Constraints: Must be colocated with NudgeFromPF,
          rem NudgeRight, NudgeLeft,
          rem              NudgeHorizontalDone, NudgeVertical,
          rem              NudgeDown, NudgeUp (all called via goto)
          dim NPF_playerIndex = temp1 : rem              Called from MovePlayerToTarget
          dim NPF_playerX = temp7
          dim NPF_playerY = temp8
          dim NPF_pfColumn = temp9
          dim NPF_pfRow = tempA
          dim NPF_targetX = temp2
          dim NPF_targetY = temp3
          
          let NPF_playerX = playerX[NPF_playerIndex] : rem Get current position
          let NPF_playerY = playerY[NPF_playerIndex]
          
          let NPF_pfColumn = NPF_playerX : rem Convert X position to playfield column (0-31)
          let NPF_pfColumn = NPF_pfColumn - ScreenInsetX
          asm
            lsr NPF_pfColumn
            lsr NPF_pfColumn
end
          rem Clamp column to valid range
          if NPF_pfColumn & $80 then let NPF_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if NPF_pfColumn > 31 then let NPF_pfColumn = 31
          
          rem Convert Y position to playfield row (divide by
          rem   pfrowheight)
          rem pfrowheight is typically 8 or 16 (powers of 2), so use bit
          rem   shifts
          rem If pfrowheight = 8: divide by 8 = 3 right shifts
          rem If pfrowheight = 16: divide by 16 = 4 right shifts
          rem Use 4 shifts for safety (works for both 8 and 16, may be
          let NPF_pfRow = NPF_playerY : rem   off by 1 for 8 but acceptable for simple nudge)
          asm
            lsr NPF_pfRow
            lsr NPF_pfRow
            lsr NPF_pfRow
            lsr NPF_pfRow
end
          if NPF_pfRow >= pfrows then let NPF_pfRow = pfrows - 1
          rem Check for wraparound: if division resulted in value ≥ 128
          rem (negative), clamp to 0
          rem   check
          rem Note: This is unlikely for row calculation but safe to
          if NPF_pfRow & $80 then let NPF_pfRow = 0
          
          rem Check collision at player position (simple single-point
          if pfread(NPF_pfColumn, NPF_pfRow) then NudgeFromPF : rem   check)
          
          return
          rem No collision, return
          
NudgeFromPF
          rem Collision detected - nudge player 1 pixel in direction
          rem toward target
          rem
          rem Input: NPF_playerX, NPF_playerY, NPF_playerIndex (from
          rem NudgePlayerFromPlayfield)
          rem        temp2, temp3 (target positions, preserved from
          rem        MovePlayerToTarget)
          rem
          rem Output: Dispatches to NudgeRight, NudgeLeft, or
          rem NudgeHorizontalDone
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with
          rem NudgePlayerFromPlayfield
          rem Nudge horizontally toward target first
          let NPF_targetX = temp2 : rem Get targetX from parent function (preserved in temp2)
          let NPF_targetY = temp3
          if NPF_playerX < NPF_targetX then NudgeRight
          if NPF_playerX > NPF_targetX then NudgeLeft
          goto NudgeHorizontalDone
NudgeRight
          rem Nudge player right 1 pixel
          rem
          rem Input: NPF_playerIndex (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerX[NPF_playerIndex] incremented
          rem
          rem Mutates: playerX[NPF_playerIndex]
          rem
          rem Called Routines: None
          let playerX[NPF_playerIndex] = playerX[NPF_playerIndex] + 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield, NudgeHorizontalDone
          goto NudgeHorizontalDone
NudgeLeft
          rem Nudge player left 1 pixel
          rem
          rem Input: NPF_playerIndex (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerX[NPF_playerIndex] decremented
          rem
          rem Mutates: playerX[NPF_playerIndex]
          rem
          rem Called Routines: None
          let playerX[NPF_playerIndex] = playerX[NPF_playerIndex] - 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield, NudgeHorizontalDone
NudgeHorizontalDone
          rem Horizontal nudge complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem NudgePlayerFromPlayfield
          
          let NPF_playerX = playerX[NPF_playerIndex] : rem If still colliding, nudge vertically toward target
          let NPF_pfColumn = NPF_playerX
          let NPF_pfColumn = NPF_pfColumn - ScreenInsetX
          asm
            lsr NPF_pfColumn
            lsr NPF_pfColumn
end
          rem   result ≥ 128
          if NPF_pfColumn & $80 then let NPF_pfColumn = 0 : rem Check for wraparound: if subtraction wrapped negative,
          if NPF_pfColumn > 31 then let NPF_pfColumn = 31
          
          if pfread(NPF_pfColumn, NPF_pfRow) then NudgeVertical
          return
          
NudgeVertical
          rem Still colliding, nudge vertically
          rem
          rem Input: NPF_playerY, NPF_targetY, NPF_playerIndex (from
          rem NudgePlayerFromPlayfield)
          rem
          rem Output: Dispatches to NudgeDown or NudgeUp
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          if NPF_playerY < NPF_targetY then NudgeDown : rem Constraints: Must be colocated with NudgePlayerFromPlayfield
          if NPF_playerY > NPF_targetY then NudgeUp
          return
NudgeDown
          rem Nudge player down 1 pixel
          rem
          rem Input: NPF_playerIndex (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerY[NPF_playerIndex] incremented
          rem
          rem Mutates: playerY[NPF_playerIndex]
          rem
          rem Called Routines: None
          let playerY[NPF_playerIndex] = playerY[NPF_playerIndex] + 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield
          return
NudgeUp
          rem Nudge player up 1 pixel
          rem
          rem Input: NPF_playerIndex (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerY[NPF_playerIndex] decremented
          rem
          rem Mutates: playerY[NPF_playerIndex]
          rem
          rem Called Routines: None
          let playerY[NPF_playerIndex] = playerY[NPF_playerIndex] - 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield
          return
