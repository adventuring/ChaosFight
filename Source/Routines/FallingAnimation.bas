          rem ChaosFight - Source/Routines/FallingAnimation.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FALLING ANIMATION LOOP - Called from MainLoop each frame
          rem =================================================================
          rem This is the main loop that runs each frame during Falling Animation mode.
          rem Called repeatedly from MainLoop dispatcher.
          rem Setup is handled by BeginFallingAnimation (called from ChangeGameMode).

FallingAnimation1
          rem Count active players for falling animation (only on first frame)
          rem This check happens each frame but ActivePlayers is set in BeginFallingAnimation
          rem We recalculate here in case players change (shouldn't happen, but safety check)
          rem Note: ActivePlayers counting is now handled in BeginFallingAnimation
          
          rem Animate all active players falling using dynamic sprite setting
          rem Use PlayerY[] array and map to correct sprite registers
          
          rem Participant 1 (array [0]) → P0 sprite (player0x/player0y)
          if PlayerChar[0] = 255 then goto SkipPlayer1Fall
          
          rem Phase 1: Fall from top (Y movement down)
          rem Phase 2: Move from quadrant toward center (both X and Y)
          rem Check if still falling (Y > target Y)
          if PlayerY[0] > 80 then goto Player1FallPhase
          
          rem Phase 2: Move toward center position (both X and Y simultaneously)
          rem Target center X = 80, current X from quadrant = 40
          rem Move X toward center
          if PlayerX[0] < 80 then PlayerX[0] = PlayerX[0] + 2
          if PlayerX[0] > 80 then PlayerX[0] = PlayerX[0] - 2
          
          rem Move Y toward target row (80)
          if PlayerY[0] < 80 then PlayerY[0] = PlayerY[0] + 2
          if PlayerY[0] > 80 then PlayerY[0] = PlayerY[0] - 2
          
          rem Check if reached center position
          if PlayerX[0] = 80 && PlayerY[0] = 80 then let FallComplete = FallComplete + 1
          goto Player1SetPos
          
Player1FallPhase
          rem Phase 1: Fall down from top
          PlayerY[0] = PlayerY[0] - FallSpeed
          if PlayerY[0] < 80 then PlayerY[0] = 80
          
Player1SetPos
          player0y = PlayerY[0]
          player0x = PlayerX[0]
SkipPlayer1Fall

          rem Participant 2 (array [1]) → P1 sprite (player1x/player1y, virtual _P1)
          if PlayerChar[1] = 255 then goto SkipPlayer2Fall
          
          rem Phase 1: Fall from top, Phase 2: Move toward center
          if PlayerY[1] > 80 then goto Player2FallPhase
          
          rem Phase 2: Move toward center (X=80, Y=80)
          if PlayerX[1] < 80 then PlayerX[1] = PlayerX[1] + 2
          if PlayerX[1] > 80 then PlayerX[1] = PlayerX[1] - 2
          if PlayerY[1] < 80 then PlayerY[1] = PlayerY[1] + 2
          if PlayerY[1] > 80 then PlayerY[1] = PlayerY[1] - 2
          
          if PlayerX[1] = 80 && PlayerY[1] = 80 then let FallComplete = FallComplete + 1
          goto Player2SetPos
          
Player2FallPhase
          PlayerY[1] = PlayerY[1] - FallSpeed
          if PlayerY[1] < 80 then PlayerY[1] = 80
          
Player2SetPos
          player1y = PlayerY[1]
          player1x = PlayerX[1]
SkipPlayer2Fall

          rem Participant 3 (array [2]) → P2 sprite (player2x/player2y) - 4-player mode only
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer3Fall
          if selectedChar3 = 255 then goto SkipPlayer3Fall
          if PlayerChar[2] = 255 then goto SkipPlayer3Fall
          
          rem Phase 1: Fall from top, Phase 2: Move toward center
          if PlayerY[2] > 80 then goto Player3FallPhase
          
          rem Phase 2: Move toward center (X=80, Y=80)
          if PlayerX[2] < 80 then PlayerX[2] = PlayerX[2] + 2
          if PlayerX[2] > 80 then PlayerX[2] = PlayerX[2] - 2
          if PlayerY[2] < 80 then PlayerY[2] = PlayerY[2] + 2
          if PlayerY[2] > 80 then PlayerY[2] = PlayerY[2] - 2
          
          if PlayerX[2] = 80 && PlayerY[2] = 80 then let FallComplete = FallComplete + 1
          goto Player3SetPos
          
Player3FallPhase
          PlayerY[2] = PlayerY[2] - FallSpeed
          if PlayerY[2] < 80 then PlayerY[2] = 80
          
Player3SetPos
          player2y = PlayerY[2]
          player2x = PlayerX[2]
SkipPlayer3Fall

          rem Participant 4 (array [3]) → P3 sprite (player3x/player3y) - 4-player mode only
          if ! (ControllerStatus & SetQuadtariDetected) then goto SkipPlayer4Fall
          if selectedChar4 = 255 then goto SkipPlayer4Fall
          if PlayerChar[3] = 255 then goto SkipPlayer4Fall
          
          rem Phase 1: Fall from top, Phase 2: Move toward center
          if PlayerY[3] > 80 then goto Player4FallPhase
          
          rem Phase 2: Move toward center (X=80, Y=80)
          if PlayerX[3] < 80 then PlayerX[3] = PlayerX[3] + 2
          if PlayerX[3] > 80 then PlayerX[3] = PlayerX[3] - 2
          if PlayerY[3] < 80 then PlayerY[3] = PlayerY[3] + 2
          if PlayerY[3] > 80 then PlayerY[3] = PlayerY[3] - 2
          
          if PlayerX[3] = 80 && PlayerY[3] = 80 then let FallComplete = FallComplete + 1
          goto Player4SetPos
          
Player4FallPhase
          PlayerY[3] = PlayerY[3] - FallSpeed
          if PlayerY[3] < 80 then PlayerY[3] = 80
          
Player4SetPos
          player3y = PlayerY[3]
          player3x = PlayerX[3]
SkipPlayer4Fall

          rem Check if all players have finished falling
          if FallComplete >= ActivePlayers then goto FallingComplete1

          rem Update animation frame
          let FallFrame = FallFrame + 1
          if FallFrame > 3 then let FallFrame = 0

          rem Set falling sprites for all active players using dynamic sprite setting
          rem Sprites are now set above using PlayerX[]/PlayerY[] arrays mapped to correct registers

          rem Return to MainLoop for next frame
          return

FallingComplete1
          rem All players have reached center - now position at row 2 using playfield collision
          rem Scan playfield to find first clear row and position players there
          rem For each active player, find suitable row 2 position
          
          rem Participant 1: Find row 2 position
          if PlayerChar[0] <> 255 then
                    temp1 = 0
                    gosub FindRow2Position
                    PlayerY[0] = temp3
                    PlayerX[0] = temp2
          end
          
          rem Participant 2: Find row 2 position
          if PlayerChar[1] <> 255 then
                    temp1 = 1
                    gosub FindRow2Position
                    PlayerY[1] = temp3
                    PlayerX[1] = temp2
          end
          
          rem Participant 3: Find row 2 position (4-player mode only)
          if ControllerStatus & SetQuadtariDetected then goto FallingCompletePlayer3
          goto FallingCompletePlayer3Done
FallingCompletePlayer3
          if selectedChar3 <> 255 && PlayerChar[2] <> 255 then
                    temp1 = 2
                    gosub FindRow2Position
                    PlayerY[2] = temp3
                    PlayerX[2] = temp2
          end
FallingCompletePlayer3Done
          
          rem Participant 4: Find row 2 position (4-player mode only)
          if ControllerStatus & SetQuadtariDetected then goto FallingCompletePlayer4
          goto FallingCompletePlayer4Done
FallingCompletePlayer4
          if selectedChar4 <> 255 && PlayerChar[3] <> 255 then
                    temp1 = 3
                    gosub FindRow2Position
                    PlayerY[3] = temp3
                    PlayerX[3] = temp2
          end
FallingCompletePlayer4Done
          
          rem After positioning, check for collisions and nudge if needed
          rem Participant 1 nudging
          if PlayerChar[0] <> 255 then
                    temp1 = 0
                    gosub NudgeIfCollision
          end
          
          rem Participant 2 nudging
          if PlayerChar[1] <> 255 then
                    temp1 = 1
                    gosub NudgeIfCollision
          end
          
          rem Participant 3 nudging
          if ControllerStatus & SetQuadtariDetected then goto FallingNudgePlayer3
          goto FallingNudgePlayer3Done
FallingNudgePlayer3
          if selectedChar3 <> 255 && PlayerChar[2] <> 255 then
                    temp1 = 2
                    gosub NudgeIfCollision
          end
FallingNudgePlayer3Done
          
          rem Participant 4 nudging
          if ControllerStatus & SetQuadtariDetected then goto FallingNudgePlayer4
          goto FallingNudgePlayer4Done
FallingNudgePlayer4
          if selectedChar4 <> 255 && PlayerChar[3] <> 255 then
                    temp1 = 3
                    gosub NudgeIfCollision
          end
FallingNudgePlayer4Done
          
          rem Initialize game state before transitioning to Game mode
          rem BeginGameLoop sets up player positions, health, missiles, etc.
          gosub BeginGameLoop
          
          rem Transition to Game mode after initialization
          rem Note: BeginGameLoop returns here, then we change mode
          rem MainLoop will dispatch to GameMainLoop each frame
          let GameMode = ModeGame : gosub bank13 ChangeGameMode
          return

          rem =================================================================
          rem PLAYFIELD COLLISION DETECTION HELPERS
          rem =================================================================
          
          rem =================================================================
          rem CHECK PLAYFIELD COLLISION
          rem =================================================================
          rem Checks if playfield pixel is set at specified position.
          rem
          rem INPUT:
          rem   temp2 = X position (screen pixel, 0-159)
          rem   temp3 = Y position (screen pixel, 0-191)
          rem
          rem OUTPUT:
          rem   temp4 = 1 if collision (playfield pixel set), 0 if clear
          
CheckPlayfieldCollision
          rem INPUT: temp2 = X position, temp3 = Y position
          rem OUTPUT: temp4 = collision result (1=collision, 0=clear)
          rem NOTE: temp2 and temp3 are preserved, temp5 and temp6 used as scratch
          
          rem Convert X pixel to playfield column (0-31)
          rem Playfield is 160 pixels wide, divided into 32 columns (160/32 = 5 pixels per column)
          rem Use division by 5 to get column
          temp6 = temp2
          rem Save X in temp6 for division
          gosub FallingDiv5Compute
          rem temp6 now contains playfield column (0-31)
          
          rem Convert Y pixel to playfield row
          rem pfread uses row directly, but we need to account for playfield resolution
          rem For multisprite kernel with pfres=8, rows are 0-7 (each row is 24 pixels tall)
          rem Convert Y to row: Y / 24 (simplified - using division)
          temp5 = temp3 / 24
          rem temp5 = playfield row (0-7 for pfres=8)
          
          rem Check if playfield pixel is set at this position
          rem pfread(column, row) returns 0 if clear, non-zero if set
          temp4 = 0
          rem Default: clear
          if pfread(temp6, temp5) then temp4 = 1
          rem Collision if pixel is set
          
          rem Note: temp2 and temp3 are preserved for caller
          return
          
          rem =================================================================
          rem DIVIDE BY 5 HELPER
          rem =================================================================
          rem Computes floor(temp6/5) into temp6 via repeated subtraction.
          rem Used for converting X pixel to playfield column.
          
FallingDiv5Compute
          temp7 = temp6
          rem Save original
          temp6 = 0
          if temp7 < 5 then return
FallingDiv5Loop
          temp7 = temp7 - 5
          temp6 = temp6 + 1
          if temp7 >= 5 then goto FallingDiv5Loop
          return
          
          rem =================================================================
          rem FIND ROW 2 POSITION
          rem =================================================================
          rem Scans playfield from top to find first clear row with 16-pixel clear width.
          rem Implements row-by-row scanning (rows 0-64, increment by 8).
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem OUTPUT:
          rem   temp2 = X position (center X, typically 80)
          rem   temp3 = Y position of first clear row (row 2 equivalent)
          
FindRow2Position
          rem Start with player's current X position (should be center = 80)
          temp2 = PlayerX[temp1]
          
          rem Scan rows from top (Y=0) to Y=64, increment by 8
          rem Each row check verifies 16-pixel clear width (center, left-8, right+8)
          temp3 = 0
          rem Start at top of screen
          
FindRow2ScanLoop
          rem Check if current row has 16-pixel clear width
          rem Check center, left, and right positions for 16-pixel clear width
          rem temp2 = center X (constant), temp3 = scan Y (changes)
          rem temp4 used for collision result, temp5/temp6 used as scratch
          
          rem Check center position (temp2, temp3)
          rem CheckPlayfieldCollision uses temp2/temp3 as input, preserves them
          gosub CheckPlayfieldCollision
          if temp4 then goto FindRow2NextRow
          rem Center blocked, try next row
          
          rem Check left position (temp2 - 8, temp3)
          rem Save temp2 temporarily in temp5
          temp5 = temp2
          temp2 = temp2 - 8
          if temp2 < 0 then temp2 = 0
          rem Clamp to screen
          gosub CheckPlayfieldCollision
          rem Restore temp2
          temp2 = temp5
          if temp4 then goto FindRow2NextRow
          rem Left blocked, try next row
          
          rem Check right position (temp2 + 8, temp3)
          rem Save temp2 temporarily in temp5
          temp5 = temp2
          temp2 = temp2 + 8
          if temp2 > 159 then temp2 = 159
          rem Clamp to screen
          gosub CheckPlayfieldCollision
          rem Restore temp2
          temp2 = temp5
          if temp4 then goto FindRow2NextRow
          rem Right blocked, try next row
          
          rem Found clear row with 16-pixel width - this is row 2 position
          return
          
FindRow2NextRow
          rem Move to next row (increment by 8 pixels)
          temp3 = temp3 + 8
          
          rem Check if we've scanned all rows (0-64)
          if temp3 <= 64 then goto FindRow2ScanLoop
          
          rem No clear row found - use default position (bottom of scan range)
          temp3 = 64
          return
          
          rem =================================================================
          rem NUDGE IF COLLISION
          rem =================================================================
          rem Nudges player down if playfield collision detected at starting position.
          rem Called after row 2 positioning to ensure player isn't embedded in playfield.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem OUTPUT:
          rem   PlayerY[temp1] updated if nudge needed
          
NudgeIfCollision
          rem Check if playfield pixel exists at player's current position
          temp2 = PlayerX[temp1]
          temp3 = PlayerY[temp1]
          gosub CheckPlayfieldCollision
          
          rem If collision detected, nudge player down by 8 pixels
          if !temp4 then return
          rem No collision, return
          
          rem Collision detected - nudge down
          PlayerY[temp1] = PlayerY[temp1] + 8
          
          rem Clamp to screen bounds
          if PlayerY[temp1] > 184 then PlayerY[temp1] = 184
          
          return