UpdateFramePhase
          rem
          rem ChaosFight - Source/Routines/FrameBudgeting.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Frame Budgeting System
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
          rem
          rem HealthBarUpdatePlayer - Which player health bar to update
          rem CollisionCheckPair - Which collision pair to check this
          rem   frame
          rem Update Frame Phase
          rem Updates the frame phase counter (0-3) used to schedule
          rem   operations.
          rem Called once per frame at the start of game loop.
          rem Updates the frame phase counter (0-3) used to schedule
          rem operations
          rem Input: frame (global) = global frame counter
          rem Output: FramePhase set to frame & 3 (cycles 0, 1, 2, 3, 0,
          rem 1, 2, 3...)
          rem Mutates: FramePhase (set to frame & 3)
          rem Called Routines: None
          let FramePhase = frame & 3 : rem Constraints: Called once per frame at the start of game loop
          rem Cycle 0, 1, 2, 3, 0, 1, 2, 3...
          return

          rem
          rem Budget Health Bar Rendering
          rem Instead of drawing all 4 health bars every frame, draw
          rem   only one
          rem player health bar per frame. This reduces pfpixel
          rem   operations
          rem from 128 per frame to 32 per frame (4× reduction).

          rem USES: FramePhase (0-3) to determine which player to update
BudgetedHealthBarUpdate
          rem Instead of drawing all 4 health bars every frame, draw
          rem only one player health bar per frame
          rem Input: FramePhase (global) = frame phase counter (0-3)
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        selectedChar3_R, selectedChar4_R (global SCRAM) =
          rem        character selections
          rem        playerHealth[] (global array) = player health
          rem        values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem Output: One player health bar updated per frame, COLUPF
          rem set, health bar drawn
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow*)
          rem Called Routines: UpdateHealthBarPlayer0-3 - update
          rem individual player health bars,
          rem   DrawHealthBarRow0-3 (bank8) - draw health bar rows
          rem Constraints: Must be colocated with
          rem CheckPlayer2HealthUpdate, DonePlayer2HealthUpdate,
          rem              CheckPlayer3HealthUpdate,
          rem              DonePlayer3HealthUpdate,
          rem              UpdateHealthBarPlayer0-3
          rem              (all called via goto or gosub)
          rem Determine which player to update based on frame phase
          if FramePhase = 0 then UpdateHealthBarPlayer0 : rem tail call
          if FramePhase = 1 then UpdateHealthBarPlayer1 : rem tail call
          if FramePhase = 2 then CheckPlayer2HealthUpdate
          goto DonePlayer2HealthUpdate
CheckPlayer2HealthUpdate
          rem Check if Player 3 health bar should be updated (4-player
          rem mode, active player)
          rem Input: controllerStatus (global), selectedChar3_R (global
          rem SCRAM)
          rem Output: Player 3 health bar updated if conditions met
          rem Mutates: temp6, COLUPF, playfield data (via
          rem UpdateHealthBarPlayer2)
          rem Called Routines: UpdateHealthBarPlayer2 (bank8) - updates
          rem Player 3 health bar
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer2HealthUpdate : rem Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer2HealthUpdate
          if selectedChar3_R = 255 then DonePlayer2HealthUpdate
          gosub UpdateHealthBarPlayer2 bank8
          return
DonePlayer2HealthUpdate
          rem Player 2 health update check complete (label only)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          if FramePhase = 3 then CheckPlayer3HealthUpdate : rem Constraints: Must be colocated with BudgetedHealthBarUpdate
          goto DonePlayer3HealthUpdate
CheckPlayer3HealthUpdate
          rem Check if Player 4 health bar should be updated (4-player
          rem mode, active player)
          rem Input: controllerStatus (global), selectedChar4_R (global
          rem SCRAM)
          rem Output: Player 4 health bar updated if conditions met
          rem Mutates: temp6, COLUPF, playfield data (via
          rem UpdateHealthBarPlayer3)
          rem Called Routines: UpdateHealthBarPlayer3 (bank8) - updates
          rem Player 4 health bar
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer3HealthUpdate : rem Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer3HealthUpdate
          if selectedChar4_R = 255 then DonePlayer3HealthUpdate
          gosub UpdateHealthBarPlayer3 bank8
          return
DonePlayer3HealthUpdate
          return
          rem Player 3 health update check complete (label only)
UpdateHealthBarPlayer0
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with
          rem BudgetedHealthBarUpdate
          rem Update Player 1 health bar
          rem Update Player 1 health bar (FramePhase 0)
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem Output: COLUPF set to Player 1 color, health bar drawn
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow0)
          rem Called Routines: DrawHealthBarRow0 (bank8) - draws Player
          rem 1 health bar row
          dim FB_healthBarLength = temp6 : rem Constraints: None
          let FB_healthBarLength = playerHealth[0] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColBlue(12)
          gosub DrawHealthBarRow0 bank8
          return

          rem Update Player 2 health bar
UpdateHealthBarPlayer1
          rem Update Player 2 health bar (FramePhase 1)
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem Output: COLUPF set to Player 2 color, health bar drawn
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow1)
          rem Called Routines: DrawHealthBarRow1 (bank8) - draws Player
          rem 2 health bar row
          dim FB_healthBarLength = temp6 : rem Constraints: None
          let FB_healthBarLength = playerHealth[1] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColRed(12)
          gosub DrawHealthBarRow1 bank8
          return

          rem Update Player 3 health bar
UpdateHealthBarPlayer2
          rem Update Player 3 health bar (FramePhase 2, 4-player mode
          rem only)
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem Output: COLUPF set to Player 3 color, health bar drawn
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow2)
          rem Called Routines: DrawHealthBarRow2 (bank8) - draws Player
          rem 3 health bar row
          dim FB_healthBarLength = temp6 : rem Constraints: None
          let FB_healthBarLength = playerHealth[2] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColYellow(12)
          gosub DrawHealthBarRow2 bank8
          return

          rem Update Player 4 health bar
UpdateHealthBarPlayer3
          rem Update Player 4 health bar (FramePhase 3, 4-player mode
          rem only)
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem Output: COLUPF set to Player 4 color, health bar drawn
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow3)
          rem Called Routines: DrawHealthBarRow3 (bank8) - draws Player
          rem 4 health bar row
          dim FB_healthBarLength = temp6 : rem Constraints: None
          let FB_healthBarLength = playerHealth[3] / 3
          if FB_healthBarLength > HealthBarMaxLength then let FB_healthBarLength = HealthBarMaxLength
          COLUPF = ColGreen(12)
          gosub DrawHealthBarRow3 bank8
          return

          rem
          rem Budget Collision Detection
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
          gosub CheckCollisionP1vsP2 : rem Always check P1 vs P2 (most important)
          
          if !(controllerStatus & SetQuadtariDetected) then return : rem Skip other checks if not Quadtari
          
          if FramePhase = 0 then CheckPhase0Collisions : rem Check additional pairs based on frame phase
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

CheckCollisionP1vsP2
          if playerX[0] >= playerX[1] then CalcP1vsP2AbsDiff : rem Individual collision check routines
          let temp2 = playerX[1] - playerX[0]
          goto DoneCalcP1vsP2Diff
CalcP1vsP2AbsDiff
          let temp2 = playerX[0] - playerX[1]
DoneCalcP1vsP2Diff
          if temp2 >= CollisionSeparationDistance then DonePlayerSeparation
          
          rem Separate players based on their relative positions
          if playerX[0] < playerX[1] then SeparateP0Left : rem If P0 is left of P1, move P0 left and P1 right
          
          let playerX[0] = playerX[0] + 1 : rem Else P0 is right of P1, move P0 right and P1 left
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

          rem
          rem Budget Missile Collision Detection
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
          
          let temp1 = FramePhase : rem 4-player mode: check one missile per frame
          rem FramePhase 0-3 maps to Game Players 0-3
          rem Calculate bit flag using O(1) array lookup:
          rem BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1]
          let temp4 = missileActive & temp6
          if temp4 then gosub CheckAllMissileCollisions bank7
          return
          
BudgetedMissileCollisionCheck2P
          let temp1 = frame & 1 : rem Simple 2-player mode: alternate missiles
          rem Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          rem   BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1] : rem Calculate bit flag using O(1) array lookup:
          let temp4 = missileActive & temp6
          if temp4 then gosub CheckAllMissileCollisions bank7
          return

