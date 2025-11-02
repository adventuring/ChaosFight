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
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer2HealthUpdate
          if selectedChar3 = 255 then goto SkipPlayer2HealthUpdate
          gosub bank8 UpdateHealthBarPlayer2
          return
SkipPlayer2HealthUpdate
          if FramePhase = 3 then goto CheckPlayer3HealthUpdate
          goto SkipPlayer3HealthUpdate
CheckPlayer3HealthUpdate
          if !(controllerStatus & SetQuadtariDetected) then goto SkipPlayer3HealthUpdate
          if selectedChar4 = 255 then goto SkipPlayer3HealthUpdate
          gosub bank8 UpdateHealthBarPlayer3
          return
SkipPlayer3HealthUpdate
          return

          rem Update Player 1 health bar
UpdateHealthBarPlayer0
          dim FB_healthBarLength = temp6
          FB_healthBarLength = playerHealth[0] / 3
          if FB_healthBarLength > 32 then FB_healthBarLength = 32
          COLUPF = ColBlue(12)
          gosub bank8 DrawHealthBarRow0
          return

          rem Update Player 2 health bar
UpdateHealthBarPlayer1
          dim FB_healthBarLength = temp6
          FB_healthBarLength = playerHealth[1] / 3
          if FB_healthBarLength > 32 then FB_healthBarLength = 32
          COLUPF = ColRed(12)
          gosub bank8 DrawHealthBarRow1
          return

          rem Update Player 3 health bar
UpdateHealthBarPlayer2
          dim FB_healthBarLength = temp6
          FB_healthBarLength = playerHealth[2] / 3
          if FB_healthBarLength > 32 then FB_healthBarLength = 32
          COLUPF = ColYellow(12)
          gosub bank8 DrawHealthBarRow2
          return

          rem Update Player 4 health bar
UpdateHealthBarPlayer3
          dim FB_healthBarLength = temp6
          FB_healthBarLength = playerHealth[3] / 3
          if FB_healthBarLength > 32 then FB_healthBarLength = 32
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
          if !(controllerStatus & SetQuadtariDetected) then return
          
          rem Check additional pairs based on frame phase
          if FramePhase = 0 then if selectedChar3 <> 255 then gosub CheckCollisionP1vsP3 : goto SkipFramePhaseChecks
          if FramePhase = 1 then if selectedChar4 <> 255 then gosub CheckCollisionP1vsP4 : if selectedChar3 <> 255 then gosub CheckCollisionP2vsP3 : goto SkipFramePhaseChecks
          if FramePhase <> 2 then goto SkipPhase2Collisions
          if selectedChar4 <> 255 then gosub CheckCollisionP2vsP4
          if selectedChar3 <> 255 && selectedChar4 <> 255 then gosub CheckCollisionP3vsP4
SkipPhase2Collisions
SkipFramePhaseChecks
          return

          rem Individual collision check routines
CheckCollisionP1vsP2
          if playerX[0] >= playerX[1] then temp2 = playerX[0] - playerX[1] else temp2 = playerX[1] - playerX[0]
          if temp2 >= 16 then goto SkipPlayerSeparation
          
          rem Separate players based on their relative positions
          rem If P0 is left of P1, move P0 left and P1 right
          if playerX[0] < playerX[1] then goto SeparateP0Left
          
          rem Else P0 is right of P1, move P0 right and P1 left
          playerX[0] = playerX[0] + 1
          playerX[1] = playerX[1] - 1
          goto SkipPlayerSeparation

SeparateP0Left
          playerX[0] = playerX[0] - 1
          playerX[1] = playerX[1] + 1
SkipPlayerSeparation
          
          return

CheckCollisionP1vsP3
          if playerX[0] >= playerX[2] then temp2 = playerX[0] - playerX[2] else temp2 = playerX[2] - playerX[0]
          if temp2 < 16 then gosub CheckCollisionP1vsP3Aux : return
          
CheckCollisionP1vsP3Aux
          if playerX[0] < playerX[2] then playerX[0] = playerX[0] - 1 : playerX[2] = playerX[2] + 1 : return
          playerX[0] = playerX[0] + 1
          playerX[2] = playerX[2] - 1
          return

CheckCollisionP1vsP4
          if playerX[0] >= playerX[3] then temp2 = playerX[0] - playerX[3] else temp2 = playerX[3] - playerX[0]
          if temp2 < 16 then gosub CheckCollisionP1vsP4Aux : return
          
CheckCollisionP1vsP4Aux
          if playerX[0] < playerX[3] then playerX[0] = playerX[0] - 1 : playerX[3] = playerX[3] + 1 : return
          playerX[0] = playerX[0] + 1
          playerX[3] = playerX[3] - 1
          return

CheckCollisionP2vsP3
          if playerX[1] >= playerX[2] then temp2 = playerX[1] - playerX[2] else temp2 = playerX[2] - playerX[1]
          if temp2 < 16 then gosub CheckCollisionP2vsP3Aux : return
          
CheckCollisionP2vsP3Aux
          if playerX[1] < playerX[2] then playerX[1] = playerX[1] - 1 : playerX[2] = playerX[2] + 1 : return
          playerX[1] = playerX[1] + 1
          playerX[2] = playerX[2] - 1
          return

CheckCollisionP2vsP4
          if playerX[1] >= playerX[3] then temp2 = playerX[1] - playerX[3] else temp2 = playerX[3] - playerX[1]
          if temp2 < 16 then gosub CheckCollisionP2vsP4Aux : return
          
CheckCollisionP2vsP4Aux
          if playerX[1] < playerX[3] then playerX[1] = playerX[1] - 1 : playerX[3] = playerX[3] + 1 : return
          playerX[1] = playerX[1] + 1
          playerX[3] = playerX[3] - 1
          return

CheckCollisionP3vsP4
          if playerX[2] >= playerX[3] then temp2 = playerX[2] - playerX[3] else temp2 = playerX[3] - playerX[2]
          if temp2 < 16 then gosub CheckCollisionP3vsP4Aux : return
          
CheckCollisionP3vsP4Aux
          if playerX[2] < playerX[3] then playerX[2] = playerX[2] - 1 : playerX[3] = playerX[3] + 1 : return
          playerX[2] = playerX[2] + 1
          playerX[3] = playerX[3] - 1
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
          rem Use missileActive bit flags: bit 0 = Player 0, bit 1 = Player 1, bit 2 = Player 2, bit 3 = Player 3
          rem Use CheckAllMissileCollisions from MissileCollision.bas which checks one player missile
          
          if !(controllerStatus & SetQuadtariDetected) then goto BudgetedMissileCollisionCheck2P
          
          rem 4-player mode: check one missile per frame
          temp1 = FramePhase
          rem FramePhase 0-3 maps to Game Players 0-3
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp1 = 0 then temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp4 = missileActive & temp6
          if temp4 then gosub bank15 CheckAllMissileCollisions
          return
          
BudgetedMissileCollisionCheck2P
          rem Simple 2-player mode: alternate missiles
          temp1 = frame & 1
          rem Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          rem Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          if temp1 = 0 then temp6 = 1
          if temp1 = 1 then temp6 = 2
          if temp1 = 2 then temp6 = 4
          if temp1 = 3 then temp6 = 8
          temp4 = missileActive & temp6
          if temp4 then gosub bank15 CheckAllMissileCollisions
          return

