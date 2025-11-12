          rem ChaosFight - Source/Routines/PlayerPhysicsCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckBoundaryCollisions
          rem Player Physics - Collisions
          rem Handles boundary, playfield, and player-to-player
          rem collisions.
          rem Split from PlayerPhysics.bas to reduce bank size.
          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem playerVelocityX[0-3] - Horizontal velocity (8.8
          rem   fixed-point)
          rem playerVelocityY[0-3] - Vertical velocity (8.8 fixed-point)
          rem
          rem playerCharacter[0-3] - Character type indices
          rem QuadtariDetected - Whether 4-player mode active
          rem   playerCharacter[] - Player 3/4 selections
          rem Check Boundary Collisions
          rem Prevents players from moving off-screen.
          rem Prevents players from moving off-screen (horizontal
          rem wrap-around, vertical clamping)
          rem
          rem Input: playerX[], playerY[] (global arrays) = player
          rem positions, playerSubpixelX[], playerSubpixelY[],
          rem playerSubpixelXL[], playerSubpixelYL[] (global arrays) =
          rem subpixel positions, playerVelocityY[], playerVelocityYL[]
          rem (global arrays) = vertical velocity, controllerStatus
          rem (global) = controller state, playerCharacter[] (global array) = player selections,
          rem selectedArena_R (global SCRAM) = selected arena, frame
          rem (global) = frame counter, RandomArena (global constant) =
          rem random arena constant
          rem
          rem Output: Players clamped to screen boundaries, horizontal
          rem wrap-around applied, vertical velocity zeroed at
          rem boundaries
          rem
          rem Mutates: temp1-temp3 (used for calculations), playerX[],
          rem playerY[] (global arrays) = player positions
          rem (wrapped/clamped), playerSubpixelX[], playerSubpixelY[],
          rem playerSubpixelXL[], playerSubpixelYL[] (global arrays) =
          rem subpixel positions (set to clamped values),
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity (zeroed at boundaries)
          rem
          rem Called Routines: None
          rem
          rem Constraints: All arenas support horizontal wrap-around (X
          rem < PlayerLeftWrapThreshold wraps to PlayerRightEdge, X >
          rem PlayerRightWrapThreshold wraps to PlayerLeftEdge). Vertical
          rem boundaries clamped (Y < 20 clamped to 20, Y > 80 clamped
          rem to 80). Players 3/4 only checked if Quadtari detected and
          rem selected
          rem Loop through all players (0-3) - fully inlined to avoid
          rem labels
          rem Handle RandomArena by checking selected arena (shared for all players)
          let temp3 = selectedArena_R
          rem Handle RandomArena (use proper RNG)
          if temp3 = RandomArena then temp3 = rand : temp3 = temp3 & 15
          
          rem Player 0 - boundaries
          let temp1 = 0
          rem Horizontal wrap (player 0): wrap when leaving playable area margins
          if playerX[0] < PlayerLeftWrapThreshold then let playerX[0] = PlayerRightEdge : let playerSubpixelX_W[0] = PlayerRightEdge : let playerSubpixelX_WL[0] = 0
          if playerX[0] > PlayerRightWrapThreshold then let playerX[0] = PlayerLeftEdge : let playerSubpixelX_W[0] = PlayerLeftEdge : let playerSubpixelX_WL[0] = 0
          rem Y clamp: top 20, bottom 80
          if playerY[0] < 20 then let playerY[0] = 20 : let playerSubpixelY_W[0] = 20 : let playerSubpixelY_WL[0] = 0 : let playerVelocityY[0] = 0 : let playerVelocityYL[0] = 0
          if playerY[0] > 80 then if playerCharacter[0] = 0 then if playerVelocityY[0] > 0 then let playerY[0] = 20 : let playerSubpixelY_W[0] = 20 : let playerSubpixelY_WL[0] = 0
          if playerY[0] > 80 then let playerY[0] = 80 : let playerSubpixelY_W[0] = 80 : let playerSubpixelY_WL[0] = 0 : let playerVelocityY[0] = 0 : let playerVelocityYL[0] = 0
          
          rem Player 1 - boundaries
          let temp1 = 1
          rem Horizontal wrap (player 1): wrap when leaving playable area margins
          if playerX[1] < PlayerLeftWrapThreshold then let playerX[1] = PlayerRightEdge : let playerSubpixelX_W[1] = PlayerRightEdge : let playerSubpixelX_WL[1] = 0
          if playerX[1] > PlayerRightWrapThreshold then let playerX[1] = PlayerLeftEdge : let playerSubpixelX_W[1] = PlayerLeftEdge : let playerSubpixelX_WL[1] = 0
          rem Y clamp: top 20, bottom 80
          if playerY[1] < 20 then let playerY[1] = 20 : let playerSubpixelY_W[1] = 20 : let playerSubpixelY_WL[1] = 0 : let playerVelocityY[1] = 0 : let playerVelocityYL[1] = 0
          if playerY[1] > 80 then if playerCharacter[1] = 0 then if playerVelocityY[1] > 0 then let playerY[1] = 20 : let playerSubpixelY_W[1] = 20 : let playerSubpixelY_WL[1] = 0
          if playerY[1] > 80 then let playerY[1] = 80 : let playerSubpixelY_W[1] = 80 : let playerSubpixelY_WL[1] = 0 : let playerVelocityY[1] = 0 : let playerVelocityYL[1] = 0
          
          rem Player 2 - boundaries (if Quadtari and active) - inline nested ifs
          
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then temp1 = 2
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerX[2] < PlayerLeftWrapThreshold then let playerX[2] = PlayerRightEdge : let playerSubpixelX_W[2] = PlayerRightEdge : let playerSubpixelX_WL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerX[2] > PlayerRightWrapThreshold then let playerX[2] = PlayerLeftEdge : let playerSubpixelX_W[2] = PlayerLeftEdge : let playerSubpixelX_WL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerY[2] < 20 then let playerY[2] = 20 : let playerSubpixelY_W[2] = 20 : let playerSubpixelY_WL[2] = 0 : let playerVelocityY[2] = 0 : let playerVelocityYL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerY[2] > 80 then if playerCharacter[2] = 0 then if playerVelocityY[2] > 0 then let playerY[2] = 20 : let playerSubpixelY_W[2] = 20 : let playerSubpixelY_WL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerY[2] > 80 then let playerY[2] = 80 : let playerSubpixelY_W[2] = 80 : let playerSubpixelY_WL[2] = 0 : let playerVelocityY[2] = 0 : let playerVelocityYL[2] = 0
          
          rem Player 3 - boundaries (if Quadtari and active) - inline nested ifs
          
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then temp1 = 3
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerX[3] < PlayerLeftWrapThreshold then let playerX[3] = PlayerRightEdge : let playerSubpixelX_W[3] = PlayerRightEdge : let playerSubpixelX_WL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerX[3] > PlayerRightWrapThreshold then let playerX[3] = PlayerLeftEdge : let playerSubpixelX_W[3] = PlayerLeftEdge : let playerSubpixelX_WL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerY[3] < 20 then let playerY[3] = 20 : let playerSubpixelY_W[3] = 20 : let playerSubpixelY_WL[3] = 0 : let playerVelocityY[3] = 0 : let playerVelocityYL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerY[3] > 80 then if playerCharacter[3] = 0 then if playerVelocityY[3] > 0 then let playerY[3] = 20 : let playerSubpixelY_W[3] = 20 : let playerSubpixelY_WL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerY[3] > 80 then let playerY[3] = 80 : let playerSubpixelY_W[3] = 80 : let playerSubpixelY_WL[3] = 0 : let playerVelocityY[3] = 0 : let playerVelocityYL[3] = 0
          
          return

CheckPlayfieldCollisionAllDirections
          rem
          rem Check Playfield Collision All Directions
          rem
          rem Checks for playfield pixel collisions in all four
          rem   directions and blocks movement by zeroing velocity.
          rem Uses CharacterHeights table for proper hitbox detection.
          rem
          rem INPUT: currentPlayer = player index (0-3) (global
          rem variable)
          rem MODIFIES: playerVelocityX/Y and playerSubpixelX/Y when
          rem   collisions detected
          rem Split into horizontal and vertical checks to avoid bank
          rem   boundary issues with local labels
          rem Checks for playfield pixel collisions in all four
          rem directions and blocks movement by zeroing velocity
          rem
          rem Input: currentPlayer (global) = player index (0-3),
          rem playerX[], playerY[] (global arrays) = player positions,
          rem playerCharacter[] (global array) = character types,
          rem playerVelocityX[], playerVelocityY[], playerVelocityXL[],
          rem playerVelocityYL[] (global arrays) = player velocities,
          rem playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[],
          rem playerSubpixelYL[] (global arrays) = subpixel positions,
          rem CharacterHeights[] (global data table) = character
          rem heights, ScreenInsetX, pfrowheight, pfrows (global
          rem constants) = screen/playfield constants
          rem
          rem Output: Player velocities zeroed when collisions detected
          rem in any direction
          rem
          rem Mutates: temp2-temp6 (used for calculations),
          rem playfieldRow, playfieldColumn, rowCounter (global) =
          rem calculation temporaries, playerVelocityX[],
          rem playerVelocityY[], playerVelocityXL[], playerVelocityYL[]
          rem (global arrays) = player velocities (zeroed on collision),
          rem playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[],
          rem playerSubpixelYL[] (global arrays) = subpixel positions
          rem (zeroed on collision)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Checks collisions at head, middle, and feet
          rem positions. Uses CharacterHeights table for proper hitbox
          rem detection. Inline division by pfrowheight (8 or 16) using
          rem bit shifts
          rem Get player position and character info
          let temp2 = playerX[currentPlayer]
          rem Store player Y position (save original)
          let temp3 = playerY[currentPlayer]
          rem Load character index for current player
          let temp4 = playerCharacter[currentPlayer]
          rem Fetch character height from CharacterHeights table
          let temp5 = CharacterHeights[temp4]
          rem Character height
          
          rem Convert X position to playfield column (0-31)
          let temp6 = temp2
          rem Save original X in temp6 after removing screen inset
          let temp6 = temp6 - ScreenInsetX
          rem Divide by 4 using bit shift (2 right shifts)
          asm
            lsr temp6
            lsr temp6
          end
          rem temp6 = playfield column (0-31)
          rem Clamp column to valid range
          rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp6 & $80 then temp6 = 0
          if temp6 > 31 then temp6 = 31
          
          rem Convert Y position to playfield row (0-pfrows-1)
          rem Divide by pfrowheight using helper
          rem Inline DivideByPfrowheight logic from FallDamage.bas
          let temp2 = temp3
          rem Inline division: pfrowheight is 8 or 16 (powers of 2)
          if pfrowheight = 8 then DBPF_InlineDivideBy8
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          end
          goto DBPF_InlineDivideDone
DBPF_InlineDivideBy8
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
          end
DBPF_InlineDivideDone
          let playfieldRow = temp2
          rem playfieldRow = playfield row
          if playfieldRow >= pfrows then let playfieldRow = pfrows - 1
          rem Check for wraparound: if division resulted in value ≥ 128
          rem (negative), clamp to 0
          if playfieldRow & $80 then let playfieldRow = 0
          
          rem
          rem Check Left Collision
          rem Check if player left edge (temp6 column) has a playfield
          rem pixel
          rem Check at player head, middle, and feet positions
          rem Skip if at left edge (temp6 is 0-31, so = 0 means exactly
          rem 0)
          if temp6 = 0 then goto PFCheckRight
          rem At left edge of screen, skip check
          
          let playfieldColumn_W = temp6 - 1
          rem Column to the left (playfieldColumn)
          rem Check for wraparound: if temp6 was 0, playfieldColumn wraps to 255 (≥ 128)
          if playfieldColumn_R & $80 then goto PFCheckRight
          rem Out of bounds, skip
          
          rem Check head position (top of sprite)
          let temp4 = 0
          rem Reset left-collision flag
          if pfread(playfieldColumn_R, playfieldRow_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockLeft
          rem Check middle position
          rem Calculate (temp5 / 2) / pfrowheight
          asm
            lda temp5
            lsr
            sta temp2
          end
          rem temp2 = temp5 / 2
          rem Inline division: pfrowheight is 8 or 16 (powers of 2)
          if pfrowheight = 8 then DBPF_InlineDivideBy8_1
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          end
          goto DBPF_InlineDivideDone_1
DBPF_InlineDivideBy8_1
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
          end
DBPF_InlineDivideDone_1
          rem temp2 now contains (temp5 / 2) / pfrowheight
          let rowCounter_W = playfieldRow_R + temp2
          if rowCounter_R >= pfrows then goto PFCheckRight
          if pfread(playfieldColumn_R, rowCounter_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockLeft
          rem Check feet position (bottom of sprite)
          let temp2 = temp5
          rem Inline division: pfrowheight is 8 or 16 (powers of 2)
          if pfrowheight = 8 then DBPF_InlineDivideBy8_2
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          end
          goto DBPF_InlineDivideDone_2
DBPF_InlineDivideBy8_2
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
          end
DBPF_InlineDivideDone_2
          rem temp2 now contains temp5 / pfrowheight
          let rowCounter_W = playfieldRow_R + temp2
          if rowCounter_R >= pfrows then goto PFCheckRight
          if pfread(playfieldColumn_R, rowCounter_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockLeft
          
          goto PFCheckRight
          
PFBlockLeft
          rem Block leftward movement: zero X velocity if negative
          rem Check for negative velocity using twos complement (values
          rem ≥ 128 are negative)
          if playerVelocityX[currentPlayer] & $80 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          rem Multiply (temp6 + 1) by 4 using bit shift (2 left shifts)
          let rowYPosition_W = temp6 + 1
          asm
            lda rowYPosition_R
            asl
            asl
            clc
            adc #ScreenInsetX
            sta rowYPosition_W
          end
          rem Reuse rowYPosition for X position clamp (not actually Y,
          rem but same pattern)
          if playerX[currentPlayer] < rowYPosition_R then let playerX[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] < rowYPosition_R then let playerSubpixelX_W[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] < rowYPosition_R then let playerSubpixelX_WL[currentPlayer] = 0
          
PFCheckRight
          rem
          rem Check Right Collision
          rem Check if player right edge has a playfield pixel
          rem Player width is 16 pixels (double-width NUSIZ), so right
          rem   edge is at temp6 + 4 columns (16px / 4px per column = 4)
          if temp6 >= 31 then goto PFCheckUp
          rem At right edge of screen, skip check
          
          let playfieldColumn_W = temp6 + 4
          rem Column to the right of player right edge (playfieldColumn)
          if playfieldColumn_R > 31 then goto PFCheckUp
          rem Out of bounds, skip
          
          rem Check head, middle, and feet positions
          let temp4 = 0
          rem Reset right-collision flag
          if pfread(playfieldColumn_R, playfieldRow) then temp4 = 1
          if temp4 = 1 then goto PFBlockRight
          rem Calculate (temp5 / 2) / pfrowheight
          asm
            lda temp5
            lsr a
            sta temp2
          end
          rem temp2 = temp5 / 2
          rem Inline division: pfrowheight is 8 or 16 (powers of 2)
          if pfrowheight = 8 then DBPF_InlineDivideBy8_6
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          end
          goto DBPF_InlineDivideDone_6
DBPF_InlineDivideBy8_6
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
          end
DBPF_InlineDivideDone_6
          rem temp2 now contains (temp5 / 2) / pfrowheight
          let rowCounter_W = playfieldRow + temp2
          if rowCounter_R >= pfrows then goto PFCheckUp
          if pfread(playfieldColumn_R, rowCounter_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockRight
          rem Reset temp2 to character height for feet check
          let temp2 = temp5
          rem Inline division: pfrowheight is 8 or 16 (powers of 2)
          if pfrowheight = 8 then DBPF_InlineDivideBy8_7
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          end
          goto DBPF_InlineDivideDone_7
DBPF_InlineDivideBy8_7
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
          end
DBPF_InlineDivideDone_7
          rem temp2 now contains temp5 / pfrowheight
          let rowCounter_W = playfieldRow + temp2
          if rowCounter_R >= pfrows then goto PFCheckUp
          if pfread(playfieldColumn_R, rowCounter_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockRight
          
          goto PFCheckUp
          
PFBlockRight
          rem Block rightward movement: zero X velocity if positive
          if playerVelocityX[currentPlayer] > 0 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          rem Multiply (temp6 - 1) by 4 using bit shift (2 left shifts)
          let rowYPosition_W = temp6 - 1
          asm
            lda rowYPosition_R
            asl a
            asl a
            clc
            adc #ScreenInsetX
            sta rowYPosition_W
          end
          rem Reuse rowYPosition for X position clamp (not actually Y,
          rem but same pattern)
          if playerX[currentPlayer] > rowYPosition_R then let playerX[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] > rowYPosition_R then let playerSubpixelX_W[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] > rowYPosition_R then let playerSubpixelX_WL[currentPlayer] = 0
          
PFCheckUp
          rem
          rem Check Up Collision
          rem Check if player head has a playfield pixel above
          if playfieldRow = 0 then goto PFCheckDown_Body
          rem At top of screen, skip check
          
          let rowCounter_W = playfieldRow - 1
          rem Row above player head (rowCounter)
          rem Check for wraparound: if playfieldRow was 0, rowCounter
          rem wraps to 255 (≥ 128)
          if rowCounter_R & $80 then goto PFCheckDown_Body
          
          rem Check center column (temp6)
          let temp4 = 0
          rem Reset upward-collision flag
          if pfread(temp6, rowCounter_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockUp
          rem Check left edge column
          if temp6 = 0 then goto PFCheckUp_CheckRight
          let playfieldColumn_W = temp6 - 1
          if pfread(playfieldColumn_R, rowCounter_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockUp
PFCheckUp_CheckRight
          rem Check right edge column
          if temp6 >= 31 then goto PFCheckDown_Body
          let playfieldColumn_W = temp6 + 1
          if pfread(playfieldColumn_R, rowCounter_R) then temp4 = 1
          if temp4 = 1 then goto PFBlockUp
          
          goto PFCheckDown_Body
          
PFBlockUp
          rem Block upward movement: zero Y velocity if negative
          rem Check for negative velocity using twos complement (values
          rem ≥ 128 are negative)
          if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          rem Multiply (playfieldRow + 1) by pfrowheight (8 or 16)
          let rowYPosition_W = playfieldRow + 1
          rem Check if pfrowheight is 8 or 16
          if pfrowheight = 8 then goto DBPF_MultiplyBy8
          rem pfrowheight is 16, multiply by 16 (4 left shifts)
          asm
            lda rowYPosition_R
            asl a
            asl a
            asl a
            asl a
            sta rowYPosition_W
          end
          goto DBPF_MultiplyDone
DBPF_MultiplyBy8
          rem pfrowheight is 8, multiply by 8 (3 left shifts)
          asm
            lda rowYPosition_R
            asl a
            asl a
            asl a
            sta rowYPosition_W
          end
DBPF_MultiplyDone
          if playerY[currentPlayer] < rowYPosition_R then let playerY[currentPlayer] = rowYPosition_R
          if playerY[currentPlayer] < rowYPosition_R then let playerSubpixelY_W[currentPlayer] = rowYPosition_R
          if playerY[currentPlayer] < rowYPosition_R then let playerSubpixelY_WL[currentPlayer] = 0
PFBlockDown
          rem Block downward movement: zero Y velocity if positive
          rem This should already be handled in PhysicsApplyGravity, but
          rem enforce here too
          if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          return

PFCheckDown_Body
          rem CHECK DOWN COLLISION (GROUND - already handled in gravity,
          rem   but verify)
          rem Check if player feet have a playfield pixel below
          rem This is primarily handled in PhysicsApplyGravity, but we
          rem Verify feet position using character height
          let temp2 = temp5
          rem Inline division: pfrowheight is 8 or 16 (powers of 2)
          if pfrowheight = 8 then DBPF_InlineDivideBy8_5
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          end
          goto DBPF_InlineDivideDone_5
DBPF_InlineDivideBy8_5
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
          end
DBPF_InlineDivideDone_5
          let rowCounter_W = playfieldRow + temp2
          rem Row at player feet (rowCounter)
          if rowCounter_R >= pfrows then return
          
          let playfieldRow = rowCounter_R + 1
          rem Row below feet (playfieldRow - temporarily reuse for this
          rem check)
          if playfieldRow >= pfrows then return
          
          rem Check center, left, and right columns below feet
          let temp4 = 0
          rem Reset downward-collision flag
          if pfread(temp6, playfieldRow) then temp4 = 1
          if temp4 = 1 then goto PFBlockDown
          if temp6 = 0 then goto PFCheckDown_CheckRight
          let playfieldColumn_W = temp6 - 1
          if pfread(playfieldColumn_R, playfieldRow) then temp4 = 1
          if temp4 = 1 then goto PFBlockDown
PFCheckDown_CheckRight
          if temp6 >= 31 then return
          let playfieldColumn_W = temp6 + 1
          if pfread(playfieldColumn_R, playfieldRow) then temp4 = 1
          if temp4 = 1 then goto PFBlockDown
          
          return

CheckPlayfieldCollisionUpDone
          return

          asm
          CheckBoundaryCollisions = .CheckBoundaryCollisions
          CheckPlayfieldCollisionAllDirections = .CheckPlayfieldCollisionAllDirections
          ConvertPlayerXToPlayfieldColumn = .ConvertPlayerXToPlayfieldColumn
          DivideByPfrowheight = .DivideByPfrowheight
          end

