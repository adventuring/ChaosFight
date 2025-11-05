          rem ChaosFight - Source/Routines/FrameBudgeting.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem FRAME BUDGETING SYSTEM
          rem ==========================================================
          rem Manages expensive operations across multiple frames to
          rem   ensure
          rem game logic never exceeds the overscan period.

          rem The Atari 2600 has very limited processing time per frame:
          rem   - Vertical blank: ~37 scanlines (~2400 cycles)
          rem   - Overscan: ~30 scanlines (~1950 cycles)

          rem Expensive operations that must be budgeted:
          rem 1. Health bar rendering (32 pfpixel calls × 4 players =
          rem   128 ops)
          rem 2. Multi-player collision detection (6 pairs in 4-player
          rem   mode)
          rem 3. Missile collision detection (up to 4 missiles × 4
          rem   players)
          rem   4. Character animation updates (sprite data loading)

          rem STRATEGY:
          rem - Spread health bar updates across 4 frames (1 player per
          rem   frame)
          rem   - Check 1-2 collision pairs per frame instead of all 6
          rem   - Update missile collisions for 1-2 missiles per frame
          rem   - Update animations for 1 player per frame

          rem AVAILABLE VARIABLES:
          rem   frame - Global frame counter
          rem   FramePhase - Which phase of multi-frame operation (0-3)
          rem HealthBarUpdatePlayer - Which player health bar to update
          rem CollisionCheckPair - Which collision pair to check this
          rem   frame
          rem ==========================================================

          rem ==========================================================
          rem UPDATE FRAME PHASE
          rem ==========================================================
          rem Updates the frame phase counter (0-3) used to schedule
          rem   operations.
          rem Called once per frame at the start of game loop.
UpdateFramePhase
          let FramePhase = frame & 3 
          rem Cycle 0, 1, 2, 3, 0, 1, 2, 3...
          return

          rem ==========================================================
          rem BUDGET HEALTH BAR RENDERING
          rem ==========================================================
          rem Instead of drawing all 4 health bars every frame, draw
          rem   only one
          rem player health bar per frame. This reduces pfpixel
          rem   operations
          rem from 128 per frame to 32 per frame (4× reduction).

          rem USES: FramePhase (0-3) to determine which player to update
BudgetedHealthBarUpdate
          rem Determine which player to update based on frame phase
          rem tail call
          if FramePhase = 0 then UpdateHealthBarPlayer0
          rem tail call
          if FramePhase = 1 then UpdateHealthBarPlayer1
          if FramePhase = 2 then CheckPlayer2HealthUpdate
          goto DonePlayer2HealthUpdate
CheckPlayer2HealthUpdate
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer2HealthUpdate
          if selectedChar3_R = 255 then DonePlayer2HealthUpdate
          gosub bank8 UpdateHealthBarPlayer2
          return
DonePlayer2HealthUpdate
          if FramePhase = 3 then CheckPlayer3HealthUpdate
          goto DonePlayer3HealthUpdate
CheckPlayer3HealthUpdate
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer3HealthUpdate
          if selectedChar4_R = 255 then DonePlayer3HealthUpdate
          gosub bank8 UpdateHealthBarPlayer3
          return
DonePlayer3HealthUpdate
          return

          rem Update Player 1 health bar
UpdateHealthBarPlayer0
          dim FB_healthBarLength = temp6
          let FB_healthBarLength = playerHealth[0] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColBlue(12)
          gosub bank8 DrawHealthBarRow0
          return

          rem Update Player 2 health bar
UpdateHealthBarPlayer1
          dim FB_healthBarLength = temp6
          let FB_healthBarLength = playerHealth[1] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColRed(12)
          gosub bank8 DrawHealthBarRow1
          return

          rem Update Player 3 health bar
UpdateHealthBarPlayer2
          dim FB_healthBarLength = temp6
          let FB_healthBarLength = playerHealth[2] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColYellow(12)
          gosub bank8 DrawHealthBarRow2
          return

          rem Update Player 4 health bar
UpdateHealthBarPlayer3
          dim FB_healthBarLength = temp6
          let FB_healthBarLength = playerHealth[3] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColGreen(12)
          gosub bank8 DrawHealthBarRow3
          return

          rem ==========================================================
          rem BUDGET COLLISION DETECTION
          rem ==========================================================
          rem Instead of checking all 6 collision pairs every frame in
          rem   4-player
          rem mode, check 2 pairs per frame. This spreads the work
          rem   across 3 frames.

          rem COLLISION PAIRS (4-player mode):
          rem   Pair 0: P1 vs P2 (always checked, most important)
          rem   Pair 1: P1 vs P3
          rem   Pair 2: P1 vs P4
          rem   Pair 3: P2 vs P3
          rem   Pair 4: P2 vs P4
          rem   Pair 5: P3 vs P4

          rem SCHEDULE:
          rem   Frame 0: Pairs 0, 1 (P1 vs P2, P1 vs P3)
          rem   Frame 1: Pairs 2, 3 (P1 vs P4, P2 vs P3)
          rem   Frame 2: Pairs 4, 5 (P2 vs P4, P3 vs P4)
          rem   Frame 3: Pairs 0, 1 (repeat)
BudgetedCollisionCheck
          rem Always check P1 vs P2 (most important)
          gosub CheckCollisionP1vsP2
          
          rem Skip other checks if not Quadtari
          if !(controllerStatus & SetQuadtariDetected) then return
          
          rem Check additional pairs based on frame phase
          if FramePhase = 0 then CheckPhase0Collisions
          if FramePhase = 1 then CheckPhase1Collisions
          goto DonePhase0And1Collisions
CheckPhase0Collisions
          if selectedChar3_R = 255 then DoneFramePhaseChecks
          gosub CheckCollisionP1vsP3
          goto DoneFramePhaseChecks
CheckPhase1Collisions
          if selectedChar4_R = 255 then CheckPhase1P3
          gosub CheckCollisionP1vsP4
CheckPhase1P3
          if selectedChar3_R = 255 then DoneFramePhaseChecks
          gosub CheckCollisionP2vsP3
          goto DoneFramePhaseChecks
DonePhase0And1Collisions
          if FramePhase = 2 then CheckPhase2Collisions
          goto DonePhase2Collisions
CheckPhase2Collisions
          if selectedChar4_R = 255 then DoneCheckP2vsP4
          gosub CheckCollisionP2vsP4
DoneCheckP2vsP4
          if selectedChar3_R = 255 then DoneCheckP3vsP4
          if selectedChar4_R = 255 then DoneCheckP3vsP4
          gosub CheckCollisionP3vsP4
DoneCheckP3vsP4
DonePhase2Collisions
DoneFramePhaseChecks
          return

          rem Individual collision check routines
CheckCollisionP1vsP2
          if playerX[0] >= playerX[1] then CalcP1vsP2AbsDiff
          let temp2 = playerX[1] - playerX[0]
          goto DoneCalcP1vsP2Diff
CalcP1vsP2AbsDiff
          let temp2 = playerX[0] - playerX[1]
DoneCalcP1vsP2Diff
          if temp2 >= CollisionSeparationDistance then DonePlayerSeparation
          
          rem Separate players based on their relative positions
          rem If P0 is left of P1, move P0 left and P1 right
          if playerX[0] < playerX[1] then SeparateP0Left
          
          rem Else P0 is right of P1, move P0 right and P1 left
          let playerX[0] = playerX[0] + 1
          let playerX[1] = playerX[1] - 1
          goto DonePlayerSeparation

SeparateP0Left
          let playerX[0] = playerX[0] - 1
          let playerX[1] = playerX[1] + 1
DonePlayerSeparation
          
          return

CheckCollisionP1vsP3
          if playerX[0] >= playerX[2] then CalcP1vsP3AbsDiff
          let temp2 = playerX[2] - playerX[0]
          goto DoneCalcP1vsP3Diff
CalcP1vsP3AbsDiff
          let temp2 = playerX[0] - playerX[2]
DoneCalcP1vsP3Diff
          if temp2 < 16 then CheckCollisionP1vsP3Aux
          return

CheckCollisionP1vsP3Aux
          if playerX[0] < playerX[2] then let playerX[0] = playerX[0] - 1
          if playerX[0] < playerX[2] then let playerX[2] = playerX[2] + 1
          if playerX[0] < playerX[2] then return
          let playerX[0] = playerX[0] + 1
          let playerX[2] = playerX[2] - 1
          return

CheckCollisionP1vsP4
          if playerX[0] >= playerX[3] then CalcP1vsP4AbsDiff
          let temp2 = playerX[3] - playerX[0]
          goto DoneCalcP1vsP4Diff
CalcP1vsP4AbsDiff
          let temp2 = playerX[0] - playerX[3]
DoneCalcP1vsP4Diff
          if temp2 < 16 then CheckCollisionP1vsP4Aux
          return

CheckCollisionP1vsP4Aux
          if playerX[0] < playerX[3] then let playerX[0] = playerX[0] - 1
          if playerX[0] < playerX[3] then let playerX[3] = playerX[3] + 1
          if playerX[0] < playerX[3] then return
          let playerX[0] = playerX[0] + 1
          let playerX[3] = playerX[3] - 1
          return

CheckCollisionP2vsP3
          if playerX[1] >= playerX[2] then CalcP2vsP3AbsDiff
          let temp2 = playerX[2] - playerX[1]
          goto DoneCalcP2vsP3Diff
CalcP2vsP3AbsDiff
          let temp2 = playerX[1] - playerX[2]
DoneCalcP2vsP3Diff
          if temp2 < 16 then CheckCollisionP2vsP3Aux
          return

CheckCollisionP2vsP3Aux
          if playerX[1] < playerX[2] then let playerX[1] = playerX[1] - 1
          if playerX[1] < playerX[2] then let playerX[2] = playerX[2] + 1
          if playerX[1] < playerX[2] then return
          let playerX[1] = playerX[1] + 1
          let playerX[2] = playerX[2] - 1
          return

CheckCollisionP2vsP4
          if playerX[1] >= playerX[3] then CalcP2vsP4AbsDiff
          let temp2 = playerX[3] - playerX[1]
          goto DoneCalcP2vsP4Diff
CalcP2vsP4AbsDiff
          let temp2 = playerX[1] - playerX[3]
DoneCalcP2vsP4Diff
          if temp2 < 16 then CheckCollisionP2vsP4Aux
          return

CheckCollisionP2vsP4Aux
          if playerX[1] < playerX[3] then let playerX[1] = playerX[1] - 1
          if playerX[1] < playerX[3] then let playerX[3] = playerX[3] + 1
          if playerX[1] < playerX[3] then return
          let playerX[1] = playerX[1] + 1
          let playerX[3] = playerX[3] - 1
          return

CheckCollisionP3vsP4
          if playerX[2] >= playerX[3] then CalcP3vsP4AbsDiff
          let temp2 = playerX[3] - playerX[2]
          goto DoneCalcP3vsP4Diff
CalcP3vsP4AbsDiff
          let temp2 = playerX[2] - playerX[3]
DoneCalcP3vsP4Diff
          if temp2 < 16 then CheckCollisionP3vsP4Aux
          return

CheckCollisionP3vsP4Aux
          if playerX[2] < playerX[3] then let playerX[2] = playerX[2] - 1
          if playerX[2] < playerX[3] then let playerX[3] = playerX[3] + 1
          if playerX[2] < playerX[3] then return
          let playerX[2] = playerX[2] + 1
          let playerX[3] = playerX[3] - 1
          return

          rem ==========================================================
          rem BUDGET MISSILE COLLISION DETECTION
          rem ==========================================================
          rem Check missile collisions for at most 2 missiles per frame.

          rem SCHEDULE (2-player mode):
          rem   Even frames: Check Game Player 0 missile collisions
          rem   Odd frames: Check Game Player 1 missile collisions

          rem SCHEDULE (4-player mode):
          rem   Frame 0: Check Game Player 0 missile vs all players
          rem   Frame 1: Check Game Player 1 missile vs all players
          rem   Frame 2: Check Game Player 2 missile vs all players
          rem   Frame 3: Check Game Player 3 missile vs all players
BudgetedMissileCollisionCheck
          rem Use missileActive bit flags: bit 0 = Player 0, bit 1 =
          rem   Player 1, bit 2 = Player 2, bit 3 = Player 3
          rem Use CheckAllMissileCollisions from MissileCollision.bas
          rem   which checks one player missile
          
          if !(controllerStatus & SetQuadtariDetected) then BudgetedMissileCollisionCheck2P
          
          rem 4-player mode: check one missile per frame
          let temp1 = FramePhase
          rem FramePhase 0-3 maps to Game Players 0-3
          rem Calculate bit flag using O(1) array lookup: BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1]
          let temp4 = missileActive & temp6
          if temp4 then gosub bank7 CheckAllMissileCollisions
          return
          
BudgetedMissileCollisionCheck2P
          rem Simple 2-player mode: alternate missiles
          let temp1 = frame & 1
          rem Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          rem   BitMask[playerIndex] (1, 2, 4, 8)
          rem Calculate bit flag using O(1) array lookup:
          let temp6 = BitMask[temp1]
          let temp4 = missileActive & temp6
          if temp4 then gosub bank7 CheckAllMissileCollisions
          return

