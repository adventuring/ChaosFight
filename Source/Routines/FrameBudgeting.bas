          rem ChaosFight - Source/Routines/FrameBudgeting.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

UpdateFramePhase
          rem Frame Budgeting System
          rem Manages expensive operations across multiple frames to
          rem ensure game logic never exceeds the overscan period.
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
          rem Updates FramePhase (0-3) once per frame to schedule multi-frame operations.
          rem
          rem Input: frame (global) = global frame counter
          rem
          rem Output: FramePhase set to frame & 3 (cycles 0, 1, 2, 3, 0,
          rem 1, 2, 3...)
          rem
          rem Mutates: FramePhase (set to frame & 3)
          rem
          rem Called Routines: None
          rem Constraints: Called once per frame at the start of game loop
          let FramePhase = frame & 3
          rem Cycle 0, 1, 2, 3, 0, 1, 2, 3...
          return

          rem
          rem Budget Health Bar Rendering
          rem Draw only one player health bar per frame (down from four) to cut pfpixel work by 75%.

BudgetedHealthBarUpdate
          rem Uses FramePhase (0-3) to determine which player health bar to refresh each frame.
          rem
          rem Input: FramePhase (global) = frame phase counter (0-3)
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        playerCharacter[] (global array) = character selections
          rem        playerHealth[] (global array) = player health
          rem        values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem
          rem Output: One player health bar updated per frame, COLUPF
          rem set, health bar drawn
          rem
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow*)
          rem
          rem Called Routines: UpdateHealthBarPlayer0-3 - update
          rem individual player health bars,
          rem   DrawHealthBarRow0-3 (bank8) - draw health bar rows
          rem
          rem Constraints: Must be colocated with
          rem CheckPlayer2HealthUpdate, DonePlayer2HealthUpdate,
          rem              CheckPlayer3HealthUpdate,
          rem              DonePlayer3HealthUpdate,
          rem              UpdateHealthBarPlayer0-3
          rem              (all called via goto or gosub)
          rem Determine which player to update based on frame phase
          rem tail call
          if FramePhase = 0 then UpdateHealthBarPlayer0
          rem tail call
          if FramePhase = 1 then UpdateHealthBarPlayer1
          if FramePhase = 2 then CheckPlayer2HealthUpdate
          goto DonePlayer2HealthUpdate
CheckPlayer2HealthUpdate
          rem Check if Player 3 health bar should be updated (4-player
          rem mode, active player)
          rem
          rem Input: controllerStatus (global), playerCharacter[] (global array)
          rem
          rem Output: Player 3 health bar updated if conditions met
          rem
          rem Mutates: temp6, COLUPF, playfield data (via
          rem UpdateHealthBarPlayer2)
          rem
          rem Called Routines: UpdateHealthBarPlayer2 (bank8) - updates
          rem Player 3 health bar
          rem Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer2HealthUpdate
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer2HealthUpdate
          if playerCharacter[2] = NoCharacter then DonePlayer2HealthUpdate
          gosub UpdateHealthBarPlayer2
          return
DonePlayer2HealthUpdate
          rem Player 2 health update check complete (label only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with BudgetedHealthBarUpdate
          if FramePhase = 3 then CheckPlayer3HealthUpdate
          goto DonePlayer3HealthUpdate
CheckPlayer3HealthUpdate
          rem Check if Player 4 health bar should be updated (4-player
          rem mode, active player)
          rem
          rem Input: controllerStatus (global), playerCharacter[] (global array)
          rem
          rem Output: Player 4 health bar updated if conditions met
          rem
          rem Mutates: temp6, COLUPF, playfield data (via
          rem UpdateHealthBarPlayer3)
          rem
          rem Called Routines: UpdateHealthBarPlayer3 (bank8) - updates
          rem Player 4 health bar
          rem Constraints: Must be colocated with BudgetedHealthBarUpdate, DonePlayer3HealthUpdate
          if !(controllerStatus & SetQuadtariDetected) then DonePlayer3HealthUpdate
          if playerCharacter[3] = NoCharacter then DonePlayer3HealthUpdate
          gosub UpdateHealthBarPlayer3
          return
DonePlayer3HealthUpdate
          return
UpdateHealthBarPlayer0
          rem Player 3 health update check complete (label only)
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
          rem BudgetedHealthBarUpdate
          rem Update Player 1 health bar
          rem Update Player 1 health bar (FramePhase 0)
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem
          rem Output: COLUPF set to Player 1 color, health bar drawn
          rem
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow0)
          rem
          rem Called Routines: DrawHealthBarRow0 (bank8) - draws Player
          rem 1 health bar row
          rem Constraints: None
          let temp6 = playerHealth[0] / 3
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
          COLUPF = ColBlue(12)
          gosub DrawHealthBarRow0 bank8
          return

UpdateHealthBarPlayer1
          rem Update Player 2 health bar
          rem Update Player 2 health bar (FramePhase 1)
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem
          rem Output: COLUPF set to Player 2 color, health bar drawn
          rem
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow1)
          rem
          rem Called Routines: DrawHealthBarRow1 (bank8) - draws Player
          rem 2 health bar row
          rem Constraints: None
          let temp6 = playerHealth[1] / 3
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
          COLUPF = ColRed(12)
          gosub DrawHealthBarRow1 bank8
          return

UpdateHealthBarPlayer2
          rem Update Player 3 health bar
          rem Update Player 3 health bar (FramePhase 2, 4-player mode
          rem only)
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem
          rem Output: COLUPF set to Player 3 color, health bar drawn
          rem
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow2)
          rem
          rem Called Routines: DrawHealthBarRow2 (bank8) - draws Player
          rem 3 health bar row
          rem Constraints: None
          let temp6 = playerHealth[2] / 3
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
          COLUPF = ColYellow(12)
          gosub DrawHealthBarRow2 bank8
          return

UpdateHealthBarPlayer3
          rem Update Player 4 health bar
          rem Update Player 4 health bar (FramePhase 3, 4-player mode
          rem only)
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values
          rem        HealthBarMaxLength (constant) = maximum health bar
          rem        length
          rem
          rem Output: COLUPF set to Player 4 color, health bar drawn
          rem
          rem Mutates: temp6 (health bar length), COLUPF (TIA register),
          rem playfield data (via DrawHealthBarRow3)
          rem
          rem Called Routines: DrawHealthBarRow3 (bank8) - draws Player
          rem 4 health bar row
          rem Constraints: None
          let temp6 = playerHealth[3] / 3
          if temp6 > HealthBarMaxLength then temp6 = HealthBarMaxLength
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

BudgetedCollisionCheck
          rem SCHEDULE:
          rem   Frame 0: Pairs 0, 1 (P1 vs P2, P1 vs P3)
          rem   Frame 1: Pairs 2, 3 (P1 vs P4, P2 vs P3)
          rem   Frame 2: Pairs 4, 5 (P2 vs P4, P3 vs P4)
          rem   Frame 3: Pairs 0, 1 (repeat)
          gosub CheckCollisionP1vsP2
          rem Always check P1 vs P2 (most important)
          
          rem Skip other checks if not Quadtari
          
          if !(controllerStatus & SetQuadtariDetected) then return
          
          rem Check additional pairs based on frame phase
          
          if FramePhase = 0 then CheckPhase0Collisions
          if FramePhase = 1 then CheckPhase1Collisions
          goto DonePhase0And1Collisions
CheckPhase0Collisions
          if playerCharacter[2] = NoCharacter then DoneFramePhaseChecks
          gosub CheckCollisionP1vsP3
          goto DoneFramePhaseChecks
CheckPhase1Collisions
          if playerCharacter[3] = NoCharacter then CheckPhase1P3
          gosub CheckCollisionP1vsP4
CheckPhase1P3
          if playerCharacter[2] = NoCharacter then DoneFramePhaseChecks
          gosub CheckCollisionP2vsP3
          goto DoneFramePhaseChecks
DonePhase0And1Collisions
          if FramePhase = 2 then CheckPhase2Collisions
          goto DonePhase2Collisions
CheckPhase2Collisions
          if playerCharacter[3] = NoCharacter then DoneCheckP2vsP4
          gosub CheckCollisionP2vsP4
DoneCheckP2vsP4
          if playerCharacter[2] = NoCharacter then DoneCheckP3vsP4
          if playerCharacter[3] = NoCharacter then DoneCheckP3vsP4
          gosub CheckCollisionP3vsP4
DoneCheckP3vsP4
DonePhase2Collisions
DoneFramePhaseChecks
          return

CheckCollisionP1vsP2
          rem Individual collision check routines
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
          
          let playerX[0] = playerX[0] + 1
          rem Else P0 is right of P1, move P0 right and P1 left
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

BudgetedMissileCollisionCheck
          rem SCHEDULE (4-player mode):
          rem   Frame 0: Check Game Player 0 missile vs all players
          rem   Frame 1: Check Game Player 1 missile vs all players
          rem   Frame 2: Check Game Player 2 missile vs all players
          rem   Frame 3: Check Game Player 3 missile vs all players
          rem Use missileActive bit flags: bit 0 = Player 0, bit 1 =
          rem   Player 1, bit 2 = Player 2, bit 3 = Player 3
          rem Use CheckAllMissileCollisions from MissileCollision.bas
          rem   which checks one player missile
          
          if !(controllerStatus & SetQuadtariDetected) then BudgetedMissileCollisionCheck2P
          
          let temp1 = FramePhase
          rem 4-player mode: check one missile per frame
          rem FramePhase 0-3 maps to Game Players 0-3
          rem Calculate bit flag using O(1) array lookup:
          rem BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1]
          let temp4 = missileActive & temp6
          if temp4 then gosub CheckAllMissileCollisions bank7
          return
          
BudgetedMissileCollisionCheck2P
          let temp1 = frame & 1
          rem Simple 2-player mode: alternate missiles
          rem Use frame bit to alternate: 0 = Player 0, 1 = Player 1
          rem   BitMask[playerIndex] (1, 2, 4, 8)
          let temp6 = BitMask[temp1]
          rem Calculate bit flag using O(1) array lookup:
          let temp4 = missileActive & temp6
          if temp4 then gosub CheckAllMissileCollisions bank7
          return

