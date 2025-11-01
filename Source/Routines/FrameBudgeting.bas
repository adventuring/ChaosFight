          rem ChaosFight - Source/Routines/FrameBudgeting.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FRAME BUDGETING SYSTEM
          rem =================================================================
          rem Manages expensive operations across multiple frames to ensure
          rem game logic never exceeds the overscan period.

          rem The Atari 2600 has very limited processing time per frame:
          rem   - Vertical blank: ~37 scanlines (~2400 cycles)
          rem   - Overscan: ~30 scanlines (~1950 cycles)

          rem Expensive operations that must be budgeted:
          rem   1. Health bar rendering (32 pfpixel calls × 4 players = 128 ops)
          rem   2. Multi-player collision detection (6 pairs in 4-player mode)
          rem   3. Missile collision detection (up to 4 missiles × 4 players)
          rem   4. Character animation updates (sprite data loading)

          rem STRATEGY:
          rem   - Spread health bar updates across 4 frames (1 player per frame)
          rem   - Check 1-2 collision pairs per frame instead of all 6
          rem   - Update missile collisions for 1-2 missiles per frame
          rem   - Update animations for 1 player per frame

          rem AVAILABLE VARIABLES:
          rem   frame - Global frame counter
          rem   FramePhase - Which phase of multi-frame operation (0-3)
          rem   HealthBarUpdatePlayer - Which player health bar to update
          rem   CollisionCheckPair - Which collision pair to check this frame
          rem =================================================================

          rem =================================================================
          rem UPDATE FRAME PHASE
          rem =================================================================
          rem Updates the frame phase counter (0-3) used to schedule operations.
          rem Called once per frame at the start of game loop.
UpdateFramePhase
          FramePhase = frame & 3 
          rem Cycle 0, 1, 2, 3, 0, 1, 2, 3...
          return

          rem =================================================================
          rem BUDGET HEALTH BAR RENDERING
          rem =================================================================
          rem Instead of drawing all 4 health bars every frame, draw only one
          rem player health bar per frame. This reduces pfpixel operations
          rem from 128 per frame to 32 per frame (4× reduction).

          rem USES: FramePhase (0-3) to determine which player to update
BudgetedHealthBarUpdate
          rem Determine which player to update based on frame phase
          rem tail call
          if FramePhase = 0 then goto UpdateHealthBarPlayer0
          rem tail call
          if FramePhase = 1 then goto UpdateHealthBarPlayer1
          if FramePhase = 2 then goto CheckPlayer2HealthUpdate
          goto SkipPlayer2HealthUpdate
CheckPlayer2HealthUpdate
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer2HealthUpdate
          if SelectedChar3 = 255 then goto SkipPlayer2HealthUpdate
          gosub bank8 UpdateHealthBarPlayer2
          return
SkipPlayer2HealthUpdate
          if FramePhase = 3 then goto CheckPlayer3HealthUpdate
          goto SkipPlayer3HealthUpdate
CheckPlayer3HealthUpdate
          if !(ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3HealthUpdate
          if SelectedChar4 = 255 then goto SkipPlayer3HealthUpdate
          gosub bank8 UpdateHealthBarPlayer3
          return
SkipPlayer3HealthUpdate
          return

          rem Update Player 1 health bar
UpdateHealthBarPlayer0
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[0] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColBlue(12)
          gosub bank8 DrawHealthBarRow0
          return

          rem Update Player 2 health bar
UpdateHealthBarPlayer1
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[1] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColRed(12)
          gosub bank8 DrawHealthBarRow1
          return

          rem Update Player 3 health bar
UpdateHealthBarPlayer2
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[2] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColYellow(12)
          gosub bank8 DrawHealthBarRow2
          return

          rem Update Player 4 health bar
UpdateHealthBarPlayer3
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[3] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColGreen(12)
          gosub bank8 DrawHealthBarRow3
          return

          rem =================================================================
          rem BUDGET COLLISION DETECTION
          rem =================================================================
          rem Instead of checking all 6 collision pairs every frame in 4-player
          rem mode, check 2 pairs per frame. This spreads the work across 3 frames.

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
          if !(ControllerStatus & SetQuadtariDetected) then return
          
          rem Check additional pairs based on frame phase
          if FramePhase = 0 then if SelectedChar3 <> 255 then gosub CheckCollisionP1vsP3 : goto SkipFramePhaseChecks
          if FramePhase = 1 then if SelectedChar4 <> 255 then gosub CheckCollisionP1vsP4 : if SelectedChar3 <> 255 then gosub CheckCollisionP2vsP3 : goto SkipFramePhaseChecks
          if FramePhase <> 2 then goto SkipPhase2Collisions
          if SelectedChar4 <> 255 then gosub CheckCollisionP2vsP4
          if SelectedChar3 <> 255 && SelectedChar4 <> 255 then gosub CheckCollisionP3vsP4
SkipPhase2Collisions
SkipFramePhaseChecks
          return

          rem Individual collision check routines
CheckCollisionP1vsP2
          dim Distance = temp2
          if PlayerX[0] >= PlayerX[1] then Distance = PlayerX[0] - PlayerX[1] else Distance = PlayerX[1] - PlayerX[0]
          if Distance < 16 then if PlayerX[0] < PlayerX[1] then PlayerX[0] = PlayerX[0] - 1 : PlayerX[1] = PlayerX[1] + 1 : goto SkipPlayerSeparation
          if Distance < 16 then PlayerX[0] = PlayerX[0] + 1 : PlayerX[1] = PlayerX[1] - 1
SkipPlayerSeparation
          
          return

CheckCollisionP1vsP3
          dim Distance = temp2
          if PlayerX[0] >= PlayerX[2] then Distance = PlayerX[0] - PlayerX[2] else Distance = PlayerX[2] - PlayerX[0]
if Distance < 16 then 
if PlayerX[0] < PlayerX[2] then 
          PlayerX[0] = PlayerX[0] - 1
          PlayerX[2] = PlayerX[2] + 1

          PlayerX[0] = PlayerX[0] + 1
          PlayerX[2] = PlayerX[2] - 1
          
          
          return

CheckCollisionP1vsP4
          dim Distance = temp2
          if PlayerX[0] >= PlayerX[3] then Distance = PlayerX[0] - PlayerX[3] else Distance = PlayerX[3] - PlayerX[0]
if Distance < 16 then 
if PlayerX[0] < PlayerX[3] then 
          PlayerX[0] = PlayerX[0] - 1
          PlayerX[3] = PlayerX[3] + 1

          PlayerX[0] = PlayerX[0] + 1
          PlayerX[3] = PlayerX[3] - 1
          
          
          return

CheckCollisionP2vsP3
          dim Distance = temp2
          if PlayerX[1] >= PlayerX[2] then Distance = PlayerX[1] - PlayerX[2] else Distance = PlayerX[2] - PlayerX[1]
if Distance < 16 then 
if PlayerX[1] < PlayerX[2] then 
          PlayerX[1] = PlayerX[1] - 1
          PlayerX[2] = PlayerX[2] + 1

          PlayerX[1] = PlayerX[1] + 1
          PlayerX[2] = PlayerX[2] - 1
          
          
          return

CheckCollisionP2vsP4
          dim Distance = temp2
          if PlayerX[1] >= PlayerX[3] then Distance = PlayerX[1] - PlayerX[3] else Distance = PlayerX[3] - PlayerX[1]
if Distance < 16 then 
if PlayerX[1] < PlayerX[3] then 
          PlayerX[1] = PlayerX[1] - 1
          PlayerX[3] = PlayerX[3] + 1

          PlayerX[1] = PlayerX[1] + 1
          PlayerX[3] = PlayerX[3] - 1
          
          
          return

CheckCollisionP3vsP4
          dim Distance = temp2
          if PlayerX[2] >= PlayerX[3] then Distance = PlayerX[2] - PlayerX[3] else Distance = PlayerX[3] - PlayerX[2]
if Distance < 16 then 
if PlayerX[2] < PlayerX[3] then 
          PlayerX[2] = PlayerX[2] - 1
          PlayerX[3] = PlayerX[3] + 1

          PlayerX[2] = PlayerX[2] + 1
          PlayerX[3] = PlayerX[3] - 1
          
          
          return

          rem =================================================================
          rem BUDGET MISSILE COLLISION DETECTION
          rem =================================================================
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
          rem Use MissileActive bit flags: bit 0 = Player 0, bit 1 = Player 1, bit 2 = Player 2, bit 3 = Player 3
          rem Use CheckAllMissileCollisions from MissileCollision.bas which checks one player's missile
          
if !(ControllerStatus & SetQuadtariDetected) then 
          rem Simple 2-player mode: alternate missiles
          temp1 = frame & 1
          rem Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp1 = 0 then temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp4 = MissileActive & temp6
          if temp4 then gosub bank15 CheckAllMissileCollisions
          return
          
          rem 4-player mode: check one missile per frame
          temp1 = FramePhase
          rem FramePhase 0-3 maps to Game Players 0-3
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp1 = 0 then temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp4 = MissileActive & temp6
          if temp4 then gosub bank15 CheckAllMissileCollisions
          return

