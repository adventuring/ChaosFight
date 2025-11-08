          rem ChaosFight - Source/Routines/FallingAnimation.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Falling In Animation - Per-frame Loop
          rem Moves players from quadrant staging positions to arena row 2.

FallingAnimation1
          rem Moves active players from quadrant spawn points to row 2 starting positions
          rem Called each frame while gameMode = ModeFallingAnimation1
          rem Flow:
          rem   1. Move each active player toward their target position
          rem   2. Track completion count
          rem   3. Transition to game mode when all players arrive
          rem Input: playerCharacter[] (global array) = character selections
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
          rem Entry point for falling animation mode (called from MainLoop)
          let fallFrame = fallFrame + 1 : rem Update animation frame
          if fallFrame > 3 then let fallFrame = 0
          
          rem Move Player 1 from quadrant to target (if active)
          
          if playerCharacter[0] = NoCharacter then DonePlayer1Move
          rem playerIndex = 0 (player index), targetX = target X,
          let temp1 = 0 : rem targetY = target Y (24)
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player1Target4P
          let temp2 = 53 : rem 2-player mode: target X = 53
          goto Player1TargetDone
Player1Target4P
          rem Set Player 1 target X for 4-player mode
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: temp2 set to 32
          rem
          rem Mutates: temp2
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1,
          rem Player1TargetDone
          let temp2 = 32 : rem 4-player mode: target X = 32
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
          let temp3 = 24 : rem Constraints: Must be colocated with FallingAnimation1
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
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
          
          rem Move Player 2 from quadrant to target (if active)
          
          if playerCharacter[1] = NoCharacter then DonePlayer2Move
          let temp1 = 1
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player2Target4P
          let temp2 = 107 : rem 2-player mode: target X = 107
          goto Player2TargetDone
Player2Target4P
          rem Set Player 2 target X for 4-player mode
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: temp2 set to 128
          rem
          rem Mutates: temp2
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1,
          rem Player2TargetDone
          let temp2 = 128 : rem 4-player mode: target X = 128
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
          let temp3 = 24 : rem Constraints: Must be colocated with FallingAnimation1
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
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
          
          rem Move Player 3 from quadrant to target (if active)
          
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer3Move
          if playerCharacter[2] = NoCharacter then DonePlayer3Move
          let temp1 = 2
          let temp2 = 64 : rem 4-player mode: target X = 64
          let temp3 = 24
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
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
          
          rem Move Player 4 from quadrant to target (if active)
          
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer4Move
          if playerCharacter[3] = NoCharacter then DonePlayer4Move
          let temp1 = 3
          let temp2 = 96 : rem 4-player mode: target X = 96
          let temp3 = 24
          gosub MovePlayerToTarget
          if temp4 then let fallComplete = fallComplete + 1
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
          
          rem Check if all players have reached their targets
          
          if fallComplete >= activePlayers then FallingComplete1
          
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
          rem Move player toward target (X, Y) using subpixel motion.
          rem Input: temp1 = player index (0-3), temp2 = target X, temp3 = target Y
          rem        playerX[]/playerY[] current positions
          rem Output: temp4 = 1 if target reached, 0 if still moving
          rem Mutates: temp4-6 (temp4 carries result; temp5/temp6 scratch)
          rem Effects: Updates playerX[] and playerY[] to approach target
          rem        playerY[] (global array) = current player Y positions
          rem        fallSpeed (global) = movement speed per frame
          rem
          rem Output: temp4 = 1 if reached target, 0 if still moving
          rem
          rem Mutates: playerX[temp1],
          rem playerY[temp1] (updated toward target),
          rem         temp4 (reached flag), temp5, temp6 (internal
          rem         calculations),
          rem         yDistance (SCRAM, used as yDistance),
          rem         rowYPosition (SCRAM, used as rowYPosition)
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
          rem Do not use these variables after calling this subroutine.
          rem Reuse yDistance SCRAM variable for delta X
          rem Reuse rowYPosition SCRAM variable for delta Y
          
          let temp5 = playerX[temp1] : rem Get current position
          let temp6 = playerY[temp1]
          
          rem Calculate distances to target
          
          if temp5 >= temp2 then CalcDeltaXRight
          let yDistance_W = temp2 - temp5
          goto DeltaXDone
CalcDeltaXRight
          rem Calculate delta X when current X >= target X
          rem
          rem Input: temp5, temp2 (from
          rem MovePlayerToTarget)
          rem
          rem Output: yDistance = absolute distance
          rem
          rem Mutates: yDistance
          rem
          rem Called Routines: None
          let yDistance_W = temp5 - temp2 : rem Constraints: Must be colocated with MovePlayerToTarget, DeltaXDone
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
          
          if temp6 >= temp3 then CalcDeltaYDown
          let rowYPosition_W = temp3 - temp6
          goto DeltaYDone
CalcDeltaYDown
          rem Calculate delta Y when current Y >= target Y
          rem
          rem Input: temp6, temp3 (from
          rem MovePlayerToTarget)
          rem
          rem Output: rowYPosition = absolute distance
          rem
          rem Mutates: rowYPosition
          rem
          rem Called Routines: None
          let rowYPosition_W = temp6 - temp3 : rem Constraints: Must be colocated with MovePlayerToTarget, DeltaYDone
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
          
          rem Check if already at target (within 1 pixel)
          
          if yDistance_R <= 1 && rowYPosition_R <= 1 then AtTarget
          
          rem Move toward target (horizontal first, then vertical)
          rem Move horizontally if not at target X
          if temp5 < temp2 then MoveRight
          if temp5 > temp2 then MoveLeft
          goto HorizontalDone
MoveRight
          rem Move player right toward target
          rem
          rem Input: temp1, temp2 (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerX[temp1] updated
          rem
          rem Mutates: playerX[temp1]
          rem
          rem Called Routines: None
          let playerX[temp1] = playerX[temp1] + fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, HorizontalDone
          rem Clamp to target if overshot
          if playerX[temp1] > temp2 then let playerX[temp1] = temp2
          goto HorizontalDone
MoveLeft
          rem Move player left toward target
          rem
          rem Input: temp1, temp2 (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerX[temp1] updated
          rem
          rem Mutates: playerX[temp1]
          rem
          rem Called Routines: None
          let playerX[temp1] = playerX[temp1] - fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, HorizontalDone
          rem Clamp to target if overshot
          if playerX[temp1] < temp2 then let playerX[temp1] = temp2
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
          
          rem Move vertically if not at target Y
          
          if temp6 < temp3 then MoveDown
          if temp6 > temp3 then MoveUp
          goto VerticalDone
MoveDown
          rem Move player down toward target
          rem
          rem Input: temp1, temp3 (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerY[temp1] updated
          rem
          rem Mutates: playerY[temp1]
          rem
          rem Called Routines: None
          let playerY[temp1] = playerY[temp1] + fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, VerticalDone
          rem Clamp to target if overshot
          if playerY[temp1] > temp3 then let playerY[temp1] = temp3
          goto VerticalDone
MoveUp
          rem Move player up toward target
          rem
          rem Input: temp1, temp3 (from
          rem MovePlayerToTarget)
          rem        fallSpeed (global) = movement speed
          rem
          rem Output: playerY[temp1] updated
          rem
          rem Mutates: playerY[temp1]
          rem
          rem Called Routines: None
          let playerY[temp1] = playerY[temp1] - fallSpeed : rem Constraints: Must be colocated with MovePlayerToTarget, VerticalDone
          rem Clamp to target if overshot
          if playerY[temp1] < temp3 then let playerY[temp1] = temp3
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
          
          let temp5 = playerX[temp1] : rem Check if reached target after movement
          let temp6 = playerY[temp1]
          if temp5 = temp2 && temp6 = temp3 then AtTarget
          let temp4 = 0
          return
          
AtTarget
          rem Reached target position
          rem
          rem Input: None (called from MovePlayerToTarget)
          rem
          rem Output: temp4 set to 1
          rem
          rem Mutates: temp4 (set to 1)
          rem
          rem Called Routines: None
          let temp4 = 1 : rem Constraints: Must be colocated with MovePlayerToTarget
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
          rem   temp1 (temp1) = player index (0-3)
          rem   playerX[temp1], playerY[temp1] = current position
          rem
          rem MODIFIES:
          rem   playerX[temp1], playerY[temp1] = nudged position if collision
          rem
          rem EFFECTS:
          rem If playfield collision detected, nudges player 1 pixel
          rem   away from obstacle
          rem Checks if player collides with playfield and nudges them away
          rem
          rem Input: temp1 = player index (0-3, from MovePlayerToTarget)
          rem        temp2 = target X position (from MovePlayerToTarget, preserved)
          rem        temp3 = target Y position (from MovePlayerToTarget, preserved)
          rem        playerX[] (global array) = current player X positions
          rem        playerY[] (global array) = current player Y positions
          rem        ScreenInsetX (constant) = screen X offset
          rem        pfrows (global) = number of playfield rows
          rem
          rem Output: playerX[temp1], playerY[temp1]
          rem nudged if collision
          rem
          rem Mutates: playerX[temp1],
          rem playerY[temp1] (nudged 1 pixel if collision),
          rem         temp4-temp6 (internal calculations), playfieldRow_W
          rem
          rem Called Routines: None (uses pfread for playfield collision
          rem check)
          rem
          rem Constraints: Must be colocated with NudgeFromPF,
          rem NudgeRight, NudgeLeft,
          rem              NudgeHorizontalDone, NudgeVertical,
          rem              NudgeDown, NudgeUp (all called via goto)
          rem Called from MovePlayerToTarget
          
          let temp4 = playerX[temp1] : rem Get current position
          let temp5 = playerY[temp1]
          
          let temp6 = temp4 : rem Convert X position to playfield column (0-31)
          let temp6 = temp6 - ScreenInsetX
          asm
            lsr temp6
            lsr temp6
end
          rem Clamp column to valid range
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp6 & $80 then let temp6 = 0
          if temp6 > 31 then let temp6 = 31
          
          rem Convert Y position to playfield row (divide by
          rem   pfrowheight)
          rem pfrowheight is typically 8 or 16 (powers of 2), so use bit
          rem   shifts
          rem If pfrowheight = 8: divide by 8 = 3 right shifts
          rem If pfrowheight = 16: divide by 16 = 4 right shifts
          rem Use 4 shifts for safety (works for both 8 and 16, may be
          let playfieldRow_W = temp5 : rem   off by 1 for 8 but acceptable for simple nudge)
          asm
            lsr playfieldRow_W
            lsr playfieldRow_W
            lsr playfieldRow_W
            lsr playfieldRow_W
end
          if playfieldRow_R >= pfrows then let playfieldRow_W = pfrows - 1
          rem Check for wraparound: if division resulted in value ≥ 128
          rem (negative), clamp to 0
          rem   check
          rem Note: This is unlikely for row calculation but safe to
          if playfieldRow_R & $80 then let playfieldRow_W = 0
          
          rem Check collision at player position (simple single-point
          rem check)
          if pfread(temp6, playfieldRow_R) then NudgeFromPF
          
          return
          rem No collision, return
          
NudgeFromPF
          rem Collision detected - nudge player 1 pixel in direction
          rem toward target
          rem
          rem Input: temp4, temp5, temp1 (from
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
          if temp4 < temp2 then NudgeRight
          if temp4 > temp2 then NudgeLeft
          goto NudgeHorizontalDone
NudgeRight
          rem Nudge player right 1 pixel
          rem
          rem Input: temp1 (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerX[temp1] incremented
          rem
          rem Mutates: playerX[temp1]
          rem
          rem Called Routines: None
          let playerX[temp1] = playerX[temp1] + 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield, NudgeHorizontalDone
          goto NudgeHorizontalDone
NudgeLeft
          rem Nudge player left 1 pixel
          rem
          rem Input: temp1 (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerX[temp1] decremented
          rem
          rem Mutates: playerX[temp1]
          rem
          rem Called Routines: None
          let playerX[temp1] = playerX[temp1] - 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield, NudgeHorizontalDone
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
          
          let temp4 = playerX[temp1] : rem If still colliding, nudge vertically toward target
          let temp6 = temp4
          let temp6 = temp6 - ScreenInsetX
          asm
            lsr temp6
            lsr temp6
end
          rem   result ≥ 128
          rem Check for wraparound: if subtraction wrapped negative,
          if temp6 & $80 then let temp6 = 0
          if temp6 > 31 then let temp6 = 31
          
          if pfread(temp6, playfieldRow_R) then NudgeVertical
          return
          
NudgeVertical
          rem Still colliding, nudge vertically
          rem
          rem Input: temp5, temp3, temp1 (from
          rem NudgePlayerFromPlayfield)
          rem
          rem Output: Dispatches to NudgeDown or NudgeUp
          rem
          rem Mutates: None (dispatcher only)
          rem
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with NudgePlayerFromPlayfield
          if temp5 < temp3 then NudgeDown
          if temp5 > temp3 then NudgeUp
          return
NudgeDown
          rem Nudge player down 1 pixel
          rem
          rem Input: temp1 (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerY[temp1] incremented
          rem
          rem Mutates: playerY[temp1]
          rem
          rem Called Routines: None
          let playerY[temp1] = playerY[temp1] + 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield
          return
NudgeUp
          rem Nudge player up 1 pixel
          rem
          rem Input: temp1 (from NudgePlayerFromPlayfield)
          rem
          rem Output: playerY[temp1] decremented
          rem
          rem Mutates: playerY[temp1]
          rem
          rem Called Routines: None
          let playerY[temp1] = playerY[temp1] - 1 : rem Constraints: Must be colocated with NudgePlayerFromPlayfield
          return
