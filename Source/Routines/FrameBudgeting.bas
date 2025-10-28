          rem ChaosFight - Source/Routines/FrameBudgeting.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FRAME BUDGETING SYSTEM
          rem =================================================================
          rem Manages expensive operations across multiple frames to ensure
          rem game logic never exceeds the overscan period.
          rem
          rem The Atari 2600 has very limited processing time per frame:
          rem   - Vertical blank: ~37 scanlines (~2400 cycles)
          rem   - Overscan: ~30 scanlines (~1950 cycles)
          rem
          rem Expensive operations that must be budgeted:
          rem   1. Health bar rendering (32 pfpixel calls × 4 players = 128 ops)
          rem   2. Multi-player collision detection (6 pairs in 4-player mode)
          rem   3. Missile collision detection (up to 4 missiles × 4 players)
          rem   4. Character animation updates (sprite data loading)
          rem
          rem STRATEGY:
          rem   - Spread health bar updates across 4 frames (1 player per frame)
          rem   - Check 1-2 collision pairs per frame instead of all 6
          rem   - Update missile collisions for 1-2 missiles per frame
          rem   - Update animations for 1 player per frame
          rem
          rem AVAILABLE VARIABLES:
          rem   frame - Global frame counter
          rem   FramePhase - Which phase of multi-frame operation (0-3)
          rem   HealthBarUpdatePlayer - Which player''s health bar to update
          rem   CollisionCheckPair - Which collision pair to check this frame
          rem =================================================================

          rem =================================================================
          rem UPDATE FRAME PHASE
          rem =================================================================
          rem Updates the frame phase counter (0-3) used to schedule operations.
          rem Called once per frame at the start of game loop.
UpdateFramePhase
          FramePhase = frame & 3  : rem Cycle 0, 1, 2, 3, 0, 1, 2, 3...
          return

          rem =================================================================
          rem BUDGET HEALTH BAR RENDERING
          rem =================================================================
          rem Instead of drawing all 4 health bars every frame, draw only one
          rem player''s health bar per frame. This reduces pfpixel operations
          rem from 128 per frame to 32 per frame (4× reduction).
          rem
          rem USES: FramePhase (0-3) to determine which player to update
BudgetedHealthBarUpdate
          rem Determine which player to update based on frame phase
          if FramePhase = 0 then
                    gosub UpdateHealthBarPlayer0
          else
                    if FramePhase = 1 then
                              gosub UpdateHealthBarPlayer1
                    else
                              if FramePhase = 2 && QuadtariDetected && SelectedChar3 != 0 then
                                        gosub UpdateHealthBarPlayer2
                              else
                                        if FramePhase = 3 && QuadtariDetected && SelectedChar4 != 0 then
                                                  gosub UpdateHealthBarPlayer3
                                        endif
                              endif
                    endif
          endif
          return

          rem Update Player 1''s health bar
UpdateHealthBarPlayer0
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[0] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColBlue(12)
          gosub DrawHealthBarRow0
          return

          rem Update Player 2''s health bar
UpdateHealthBarPlayer1
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[1] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColRed(12)
          gosub DrawHealthBarRow1
          return

          rem Update Player 3''s health bar
UpdateHealthBarPlayer2
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[2] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColYellow(12)
          gosub DrawHealthBarRow2
          return

          rem Update Player 4''s health bar
UpdateHealthBarPlayer3
          dim HealthBarLength = temp6
          HealthBarLength = PlayerHealth[3] / 3
          if HealthBarLength > 32 then HealthBarLength = 32
          COLUPF = ColGreen(12)
          gosub DrawHealthBarRow3
          return

          rem =================================================================
          rem BUDGET COLLISION DETECTION
          rem =================================================================
          rem Instead of checking all 6 collision pairs every frame in 4-player
          rem mode, check 2 pairs per frame. This spreads the work across 3 frames.
          rem
          rem COLLISION PAIRS (4-player mode):
          rem   Pair 0: P1 vs P2 (always checked, most important)
          rem   Pair 1: P1 vs P3
          rem   Pair 2: P1 vs P4
          rem   Pair 3: P2 vs P3
          rem   Pair 4: P2 vs P4
          rem   Pair 5: P3 vs P4
          rem
          rem SCHEDULE:
          rem   Frame 0: Pairs 0, 1 (P1 vs P2, P1 vs P3)
          rem   Frame 1: Pairs 2, 3 (P1 vs P4, P2 vs P3)
          rem   Frame 2: Pairs 4, 5 (P2 vs P4, P3 vs P4)
          rem   Frame 3: Pairs 0, 1 (repeat)
BudgetedCollisionCheck
          rem Always check P1 vs P2 (most important)
          gosub CheckCollisionP1vsP2
          
          rem Skip other checks if not Quadtari
          if !QuadtariDetected then return
          
          rem Check additional pairs based on frame phase
          if FramePhase = 0 then
                    if SelectedChar3 != 0 then gosub CheckCollisionP1vsP3
          else
                    if FramePhase = 1 then
                              if SelectedChar4 != 0 then gosub CheckCollisionP1vsP4
                              if SelectedChar3 != 0 then gosub CheckCollisionP2vsP3
                    else
                              if FramePhase = 2 then
                                        if SelectedChar4 != 0 then gosub CheckCollisionP2vsP4
                                        if SelectedChar3 != 0 && SelectedChar4 != 0 then gosub CheckCollisionP3vsP4
                              endif
                    endif
          endif
          return

          rem Individual collision check routines
CheckCollisionP1vsP2
          dim Distance = temp2
          Distance = PlayerX[0] - PlayerX[1]
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if PlayerX[0] < PlayerX[1] then
                              PlayerX[0] = PlayerX[0] - 1
                              PlayerX[1] = PlayerX[1] + 1
                    else
                              PlayerX[0] = PlayerX[0] + 1
                              PlayerX[1] = PlayerX[1] - 1
                    endif
          endif
          return

CheckCollisionP1vsP3
          dim Distance = temp2
          Distance = PlayerX[0] - PlayerX[2]
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if PlayerX[0] < PlayerX[2] then
                              PlayerX[0] = PlayerX[0] - 1
                              PlayerX[2] = PlayerX[2] + 1
                    else
                              PlayerX[0] = PlayerX[0] + 1
                              PlayerX[2] = PlayerX[2] - 1
                    endif
          endif
          return

CheckCollisionP1vsP4
          dim Distance = temp2
          Distance = PlayerX[0] - PlayerX[3]
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if PlayerX[0] < PlayerX[3] then
                              PlayerX[0] = PlayerX[0] - 1
                              PlayerX[3] = PlayerX[3] + 1
                    else
                              PlayerX[0] = PlayerX[0] + 1
                              PlayerX[3] = PlayerX[3] - 1
                    endif
          endif
          return

CheckCollisionP2vsP3
          dim Distance = temp2
          Distance = PlayerX[1] - PlayerX[2]
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if PlayerX[1] < PlayerX[2] then
                              PlayerX[1] = PlayerX[1] - 1
                              PlayerX[2] = PlayerX[2] + 1
                    else
                              PlayerX[1] = PlayerX[1] + 1
                              PlayerX[2] = PlayerX[2] - 1
                    endif
          endif
          return

CheckCollisionP2vsP4
          dim Distance = temp2
          Distance = PlayerX[1] - PlayerX[3]
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if PlayerX[1] < PlayerX[3] then
                              PlayerX[1] = PlayerX[1] - 1
                              PlayerX[3] = PlayerX[3] + 1
                    else
                              PlayerX[1] = PlayerX[1] + 1
                              PlayerX[3] = PlayerX[3] - 1
                    endif
          endif
          return

CheckCollisionP3vsP4
          dim Distance = temp2
          Distance = PlayerX[2] - PlayerX[3]
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if PlayerX[2] < PlayerX[3] then
                              PlayerX[2] = PlayerX[2] - 1
                              PlayerX[3] = PlayerX[3] + 1
                    else
                              PlayerX[2] = PlayerX[2] + 1
                              PlayerX[3] = PlayerX[3] - 1
                    endif
          endif
          return

          rem =================================================================
          rem BUDGET MISSILE COLLISION DETECTION
          rem =================================================================
          rem Check missile collisions for at most 2 missiles per frame.
          rem
          rem SCHEDULE (2-player mode):
          rem   Even frames: Check Missile1 collisions
          rem   Odd frames: Check Missile2 collisions
          rem
          rem SCHEDULE (4-player mode):
          rem   Frame 0: Check Missile1 vs P1, P2
          rem   Frame 1: Check Missile1 vs P3, P4
          rem   Frame 2: Check Missile2 vs P1, P2
          rem   Frame 3: Check Missile2 vs P3, P4
BudgetedMissileCollisionCheck
          if !QuadtariDetected then
                    rem Simple 2-player mode: alternate missiles
                    if frame & 1 then
                              if Missile2Active then gosub CheckMissile2Collisions
                    else
                              if Missile1Active then gosub CheckMissile1Collisions
                    endif
                    return
          endif
          
          rem 4-player mode: spread across 4 frames
          if FramePhase = 0 then
                    if Missile1Active then gosub CheckMissile1vsP1P2
          else
                    if FramePhase = 1 then
                              if Missile1Active then gosub CheckMissile1vsP3P4
                    else
                              if FramePhase = 2 then
                                        if Missile2Active then gosub CheckMissile2vsP1P2
                              else
                                        if Missile2Active then gosub CheckMissile2vsP3P4
                              endif
                    endif
          endif
          return

          rem Missile collision check routines (to be implemented in Combat.bas)
CheckMissile1Collisions
          rem Check Missile1 vs all active players
          return

CheckMissile2Collisions
          rem Check Missile2 vs all active players
          return

CheckMissile1vsP1P2
          rem Check Missile1 vs Players 1 and 2 only
          return

CheckMissile1vsP3P4
          rem Check Missile1 vs Players 3 and 4 only
          return

CheckMissile2vsP1P2
          rem Check Missile2 vs Players 1 and 2 only
          return

CheckMissile2vsP3P4
          rem Check Missile2 vs Players 3 and 4 only
          return

