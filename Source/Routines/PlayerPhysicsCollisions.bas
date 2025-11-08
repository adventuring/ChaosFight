CheckBoundaryCollisions
          rem
          rem ChaosFight - Source/Routines/PlayerPhysicsCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
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
          rem < 10 wraps to 150, X > 150 wraps to 10). Vertical
          rem boundaries clamped (Y < 20 clamped to 20, Y > 80 clamped
          rem to 80). Players 3/4 only checked if Quadtari detected and
          rem selected
          rem Loop through all players (0-3) - fully inlined to avoid
          rem labels
          rem Handle RandomArena by checking selected arena (shared for all players)
          let temp3 = selectedArena_R
          if temp3 = RandomArena then let temp3 = rand : let temp3 = temp3 & 15 : rem Handle RandomArena (use proper RNG)
          
          let temp1 = 0 : rem Player 0 - boundaries
          rem Horizontal wrap (player 0): X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[0] < 10 then let playerX[0] = 150 : let playerSubpixelX_W[0] = 150 : let playerSubpixelX_WL[0] = 0
          if playerX[0] > 150 then let playerX[0] = 10 : let playerSubpixelX_W[0] = 10 : let playerSubpixelX_WL[0] = 0
          if playerY[0] < 20 then let playerY[0] = 20 : let playerSubpixelY_W[0] = 20 : let playerSubpixelY_WL[0] = 0 : let playerVelocityY[0] = 0 : let playerVelocityYL[0] = 0 : rem Y clamp: top 20, bottom 80
          if playerY[0] > 80 then let playerY[0] = 80 : let playerSubpixelY_W[0] = 80 : let playerSubpixelY_WL[0] = 0 : let playerVelocityY[0] = 0 : let playerVelocityYL[0] = 0
          
          let temp1 = 1 : rem Player 1 - boundaries
          rem Horizontal wrap (player 1): X < 10 wraps to 150, X > 150 wraps to 10
          if playerX[1] < 10 then let playerX[1] = 150 : let playerSubpixelX_W[1] = 150 : let playerSubpixelX_WL[1] = 0
          if playerX[1] > 150 then let playerX[1] = 10 : let playerSubpixelX_W[1] = 10 : let playerSubpixelX_WL[1] = 0
          if playerY[1] < 20 then let playerY[1] = 20 : let playerSubpixelY_W[1] = 20 : let playerSubpixelY_WL[1] = 0 : let playerVelocityY[1] = 0 : let playerVelocityYL[1] = 0 : rem Y clamp: top 20, bottom 80
          if playerY[1] > 80 then let playerY[1] = 80 : let playerSubpixelY_W[1] = 80 : let playerSubpixelY_WL[1] = 0 : let playerVelocityY[1] = 0 : let playerVelocityYL[1] = 0
          
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then let temp1 = 2 : rem Player 2 - boundaries (if Quadtari and active) - inline nested ifs
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerX[2] < 10 then let playerX[2] = 150 : let playerSubpixelX_W[2] = 150 : let playerSubpixelX_WL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerX[2] > 150 then let playerX[2] = 10 : let playerSubpixelX_W[2] = 10 : let playerSubpixelX_WL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerY[2] < 20 then let playerY[2] = 20 : let playerSubpixelY_W[2] = 20 : let playerSubpixelY_WL[2] = 0 : let playerVelocityY[2] = 0 : let playerVelocityYL[2] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[2] = NoCharacter) then if playerY[2] > 80 then let playerY[2] = 80 : let playerSubpixelY_W[2] = 80 : let playerSubpixelY_WL[2] = 0 : let playerVelocityY[2] = 0 : let playerVelocityYL[2] = 0
          
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then let temp1 = 3 : rem Player 3 - boundaries (if Quadtari and active) - inline nested ifs
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerX[3] < 10 then let playerX[3] = 150 : let playerSubpixelX_W[3] = 150 : let playerSubpixelX_WL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerX[3] > 150 then let playerX[3] = 10 : let playerSubpixelX_W[3] = 10 : let playerSubpixelX_WL[3] = 0
          if controllerStatus & SetQuadtariDetected then if !(playerCharacter[3] = NoCharacter) then if playerY[3] < 20 then let playerY[3] = 20 : let playerSubpixelY_W[3] = 20 : let playerSubpixelY_WL[3] = 0 : let playerVelocityY[3] = 0 : let playerVelocityYL[3] = 0
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
          let temp2 = playerX[currentPlayer] : rem Get player position and character info
          let temp3 = playerY[currentPlayer] : rem X position (save original)
          let temp4 = playerCharacter[currentPlayer] : rem Y position
          let temp5 = CharacterHeights[temp4] : rem Character index
          rem Character height
          
          let temp6 = temp2 : rem Convert X position to playfield column (0-31)
          let temp6 = temp6 - ScreenInsetX : rem Save original X in temp6
          rem Divide by 4 using bit shift (2 right shifts)
          asm
            lsr temp6
            lsr temp6
end
          rem temp6 = playfield column (0-31)
          rem Clamp column to valid range
          if temp6 & $80 then let temp6 = 0 : rem Check for wraparound: if subtraction wrapped negative, result ≥ 128
          if temp6 > 31 then let temp6 = 31
          
          rem Convert Y position to playfield row (0-pfrows-1)
          rem Divide by pfrowheight using helper
          let temp2 = temp3 : rem DivideByPfrowheight is in FallDamage.bas, need to find which bank
          if pfrowheight = 8 then DBPF_InlineDivideBy8 : rem Inline division: pfrowheight is 8 or 16 (powers of 2)
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
          if playfieldRow >= pfrows then let playfieldRow = pfrows - 1 : rem playfieldRow = playfield row
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
          if playfieldColumn_R & $80 then goto PFCheckRight : rem Check for wraparound: if temp6 was 0, playfieldColumn wraps to 255 (≥ 128)
          rem Out of bounds, skip
          
          if pfread(playfieldColumn_R, playfieldRow) then goto PFBlockLeft : rem Check head position (top of sprite)
          rem Check middle position
          rem Calculate (temp5 / 2) / pfrowheight
          asm
            lda temp5
            lsr a
            sta temp2
end
          rem temp2 = temp5 / 2
          if pfrowheight = 8 then DBPF_InlineDivideBy8_1 : rem Inline division: pfrowheight is 8 or 16 (powers of 2)
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
          let rowCounter_W = playfieldRow + temp2 : rem temp2 = (temp5 / 2) / pfrowheight
          if rowCounter_R >= pfrows then goto PFCheckRight
          if pfread(playfieldColumn_R, rowCounter_R) then goto PFBlockLeft
          let temp2 = temp5 : rem Check feet position (bottom of sprite)
          if pfrowheight = 8 then DBPF_InlineDivideBy8_2 : rem Inline division: pfrowheight is 8 or 16 (powers of 2)
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
          let rowCounter_W = playfieldRow + temp2 : rem temp2 = temp5 / pfrowheight
          if rowCounter_R >= pfrows then goto PFCheckRight
          if pfread(playfieldColumn_R, rowCounter_R) then goto PFBlockLeft
          
          goto PFCheckRight
          
PFBlockLeft
          rem Block leftward movement: zero X velocity if negative
          rem Check for negative velocity using twos complement (values
          rem ≥ 128 are negative)
          if playerVelocityX[currentPlayer] & $80 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          let rowYPosition_W = temp6 + 1 : rem Multiply (temp6 + 1) by 4 using bit shift (2 left shifts)
          asm
            lda rowYPosition_W
            asl a
            asl a
            clc
            adc #ScreenInsetX
            sta rowYPosition_W
end
          rem Reuse rowYPosition for X position clamp (not actually Y,
          if playerX[currentPlayer] < rowYPosition_R then let playerX[currentPlayer] = rowYPosition_R : rem   but same pattern)
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
          if playfieldColumn_R > 31 then goto PFCheckUp : rem Column to the right of player right edge (playfieldColumn)
          rem Out of bounds, skip
          
          if pfread(playfieldColumn_R, playfieldRow) then goto PFBlockRight : rem Check head, middle, and feet positions
          rem Calculate (temp5 / 2) / pfrowheight
          asm
            lda temp5
            lsr a
            sta temp2
end
          rem temp2 = temp5 / 2
          if pfrowheight = 8 then DBPF_InlineDivideBy8_6 : rem Inline division: pfrowheight is 8 or 16 (powers of 2)
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
          let rowCounter_W = playfieldRow + temp2 : rem temp2 = (temp5 / 2) / pfrowheight
          if rowCounter_R >= pfrows then goto PFCheckUp
          if pfread(playfieldColumn_R, rowCounter_R) then goto PFBlockRight
          let temp2 = temp5
          if pfrowheight = 8 then DBPF_InlineDivideBy8_7 : rem Inline division: pfrowheight is 8 or 16 (powers of 2)
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
          let rowCounter_W = playfieldRow + temp2 : rem temp2 = temp5 / pfrowheight
          if rowCounter_R >= pfrows then goto PFCheckUp
          if pfread(playfieldColumn_R, rowCounter_R) then goto PFBlockRight
          
          goto PFCheckUp
          
PFBlockRight
          rem Block rightward movement: zero X velocity if positive
          if playerVelocityX[currentPlayer] > 0 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          let rowYPosition_W = temp6 - 1 : rem Multiply (temp6 - 1) by 4 using bit shift (2 left shifts)
          asm
            lda rowYPosition_W
            asl a
            asl a
            clc
            adc #ScreenInsetX
            sta rowYPosition_W
end
          rem Reuse rowYPosition for X position clamp (not actually Y,
          if playerX[currentPlayer] > rowYPosition_R then let playerX[currentPlayer] = rowYPosition_R : rem   but same pattern)
          if playerX[currentPlayer] > rowYPosition_R then let playerSubpixelX_W[currentPlayer] = rowYPosition_R
          if playerX[currentPlayer] > rowYPosition_R then let playerSubpixelX_WL[currentPlayer] = 0
          
PFCheckUp
          rem
          rem Check Up Collision
          if playfieldRow = 0 then goto PFCheckDown : rem Check if player head has a playfield pixel above
          rem At top of screen, skip check
          
          let rowCounter_W = playfieldRow - 1
          rem Row above player head (rowCounter)
          rem Check for wraparound: if playfieldRow was 0, rowCounter
          rem wraps to 255 (≥ 128)
          if rowCounter_R & $80 then goto PFCheckDown
          
          if pfread(temp6, rowCounter_R) then goto PFBlockUp : rem Check center column (temp6)
          if temp6 = 0 then goto PFCheckUp_CheckRight : rem Check left edge column
          let playfieldColumn_W = temp6 - 1
          if pfread(playfieldColumn_R, rowCounter_R) then goto PFBlockUp
PFCheckUp_CheckRight
          if temp6 >= 31 then goto PFCheckDown : rem Check right edge column
          let playfieldColumn_W = temp6 + 1
          if pfread(playfieldColumn_R, rowCounter_R) then goto PFBlockUp
          
          goto PFCheckDown
          
PFBlockUp
          rem Block upward movement: zero Y velocity if negative
          rem Check for negative velocity using twos complement (values
          rem ≥ 128 are negative)
          if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          rem Also clamp position to prevent overlap
          let rowYPosition_W = playfieldRow + 1 : rem Multiply (playfieldRow + 1) by pfrowheight (8 or 16)
          if pfrowheight = 8 then goto DBPF_MultiplyBy8 : rem Check if pfrowheight is 8 or 16
          rem pfrowheight is 16, multiply by 16 (4 left shifts)
          asm
            lda rowYPosition_W
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
            lda rowYPosition_W
            asl a
            asl a
            asl a
            sta rowYPosition_W
end
DBPF_MultiplyDone
          if playerY[currentPlayer] < rowYPosition_R then let playerY[currentPlayer] = rowYPosition_R
          if playerY[currentPlayer] < rowYPosition_R then let playerSubpixelY_W[currentPlayer] = rowYPosition_R
          if playerY[currentPlayer] < rowYPosition_R then let playerSubpixelY_WL[currentPlayer] = 0
          
PFCheckDown
          rem CHECK DOWN COLLISION (GROUND - already handled in gravity,
          rem   but verify)
          rem Check if player feet have a playfield pixel below
          rem This is primarily handled in PhysicsApplyGravity, but we
          let temp2 = temp5 : rem   verify here
          if pfrowheight = 8 then DBPF_InlineDivideBy8_5 : rem Inline division: pfrowheight is 8 or 16 (powers of 2)
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
          if rowCounter_R >= pfrows then return : rem Row at player feet (rowCounter)
          
          let playfieldRow = rowCounter_R + 1
          rem Row below feet (playfieldRow - temporarily reuse for this
          if playfieldRow >= pfrows then return : rem   check)
          
          if pfread(temp6, playfieldRow) then goto PFBlockDown : rem Check center, left, and right columns below feet
          if temp6 = 0 then goto PFCheckDown_CheckRight
          let playfieldColumn_W = temp6 - 1
          if pfread(playfieldColumn_R, playfieldRow) then goto PFBlockDown
PFCheckDown_CheckRight
          if temp6 >= 31 then return
          let playfieldColumn_W = temp6 + 1
          if pfread(playfieldColumn_R, playfieldRow) then goto PFBlockDown
          
          return
          
PFBlockDown
          rem Block downward movement: zero Y velocity if positive
          rem This should already be handled in PhysicsApplyGravity, but
          if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0 : rem enforce here too
          return

CheckAllPlayerCollisions
          rem
          rem Check Multi-player Collisions
          rem Checks collisions between players (for pushing, not
          rem   damage).
          rem Uses weight-based momentum transfer: heavier characters
          rem   push lighter ones.
          rem Applies impulses to velocity instead of directly modifying
          rem   position.
          rem Checks all player-to-player collisions and applies
          rem momentum transfer based on weight
          rem
          rem Input: playerX[], playerY[] (global arrays) = player
          rem positions, playerCharacter[] (global array) = character types,
          rem playerHealth[] (global array) = player health,
          rem playerVelocityX[] (global array) = player X velocities,
          rem controllerStatus (global) = controller state,
          rem playerCharacter[] (global array) = player
          rem 3/4 selections, CharacterHeights[], CharacterWeights[]
          rem (global data tables) = character properties,
          rem PlayerCollisionDistance (global constant) = collision
          rem distance threshold
          rem
          rem Output: Player velocities adjusted based on weight-based
          rem momentum transfer when collisions detected
          rem
          rem Mutates: temp1-temp6 (used for calculations),
          rem characterHeight, halfHeight1, halfHeight2, totalHeight,
          rem characterWeight, totalWeight, weightDifference,
          rem impulseStrength, yDistance (global) = calculation
          rem temporaries, playerVelocityX[] (global array) = player X
          rem velocities (adjusted for separation)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only checks pairs (i, j) where i < j to avoid
          rem duplicate checks. Skips eliminated players (health = 0).
          rem Players 3/4 only checked if Quadtari detected and
          rem selected. Uses weight-based momentum transfer (heavier
          rem characters push lighter ones more). Approximates division
          rem using bit shifts
          rem Loop through all player pairs to check collisions
          let temp1 = 0 : rem Pair (i, j) where i < j to avoid checking same pair twice
          rem Player 1 index
          
CollisionOuterLoop
          if temp1 >= 2 then CollisionCheckP1Active : rem Check if player 1 is active
          goto CollisionInnerLoop : rem Players 0-1 always active
          
CollisionCheckP1Active
          if !(controllerStatus & SetQuadtariDetected) then goto CollisionNextOuter
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto CollisionNextOuter
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto CollisionNextOuter
          
CollisionInnerLoop
          let temp2 = temp1 + 1
          rem Player 2 index (always greater than player 1)
          
CollisionCheckPair
          if temp2 >= 4 then goto CollisionNextOuter
          
          if temp2 >= 2 then CollisionCheckP2Active : rem Check if player 2 is active
          goto CollisionCheckDistance : rem Players 0-1 always active
          
CollisionCheckP2Active
          if !(controllerStatus & SetQuadtariDetected) then goto CollisionNextInner
          if temp2 = 2 && playerCharacter[2] = NoCharacter then goto CollisionNextInner
          if temp2 = 3 && playerCharacter[3] = NoCharacter then goto CollisionNextInner
          
CollisionCheckDistance
          if playerHealth[temp1] = 0 then goto CollisionNextInner : rem Skip if either player is eliminated
          if playerHealth[temp2] = 0 then goto CollisionNextInner
          
          if playerX[temp1] >= playerX[temp2] then CalcCollisionDistanceRight : rem Calculate X distance between players
          let temp3 = playerX[temp2] - playerX[temp1]
          goto CollisionDistanceDone
          
CalcCollisionDistanceRight
          let temp3 = playerX[temp1] - playerX[temp2]
          
CollisionDistanceDone
          if temp3 >= PlayerCollisionDistance then goto CollisionNextInner
          
          let temp4 = playerCharacter[temp1] : rem Calculate Y distance using CharacterHeights table
          let temp5 = playerCharacter[temp2]
          let characterHeight = CharacterHeights[temp4]
          rem Player1 height (temporarily store in characterHeight, will
          let halfHeight1 = CharacterHeights[temp5] : rem   be overwritten)
          rem Player2 height (temporarily store, will calculate half)
          
          if playerY[temp1] >= playerY[temp2] then CalcCollisionYDistanceDown : rem Calculate Y distance
          let yDistance = playerY[temp2] - playerY[temp1]
          goto CollisionYDistanceDone
          
CalcCollisionYDistanceDown
          let yDistance = playerY[temp1] - playerY[temp2]
          
CollisionYDistanceDone
          rem Check if Y overlap (sum of half-heights)
          rem Calculate half-heights
          rem Divide by 2 using bit shift
          asm
            lda characterHeight
            lsr a
            sta halfHeight1
            lda CharacterHeights
            clc
            adc temp5
            tax
            lda CharacterHeights,x
            lsr a
            sta halfHeight2
end
          rem Player1 half height
          let totalHeight = halfHeight1 + halfHeight2 : rem Player2 half height (re-read from table)
          if yDistance >= totalHeight then goto CollisionNextInner
          
          rem
          rem Momentum Transfer Based On Weight
          let characterWeight = CharacterWeights[temp4] : rem Get character weights from CharacterWeights table
          let halfHeight2 = CharacterWeights[temp5] : rem Player1 weight (temporarily store, will be overwritten)
          rem Player2 weight (temporarily store)
          
          if playerX[temp1] < playerX[temp2] then CollisionSepLeft : rem Calculate separation direction (left/right)
          
          rem Player1 is right of Player2 - push Player1 right, Player2
          rem   left
          rem Apply impulse based on weight difference
          rem Heavier character pushes lighter one more
          rem Formula: impulse = (weight_difference / total_weight) *
          let totalWeight = characterWeight + halfHeight2 : rem   separation_speed
          if totalWeight = 0 then goto CollisionNextInner : rem Total weight (halfHeight2 contains Player2 weight here)
          rem Avoid division by zero
          
          if characterWeight >= halfHeight2 then CalcWeightDiff1Heavier : rem Calculate weight difference
          let weightDifference = halfHeight2 - characterWeight
          let impulseStrength = weightDifference : rem Player2 is heavier
          goto ApplyImpulseRight : rem Impulse strength (proportional to weight difference)
          
CalcWeightDiff1Heavier
          let weightDifference = characterWeight - halfHeight2
          let impulseStrength = weightDifference : rem Player1 is heavier
          rem Impulse strength
          
ApplyImpulseRight
          rem Apply impulses: heavier player pushes lighter one
          if characterWeight >= halfHeight2 then ApplyImpulse1Heavier : rem Separation speed: 1 pixel/frame minimum
          
          rem Player2 is heavier - push Player1 left (negative X),
          rem   Player2 right (positive X)
          rem Impulse proportional to weight difference
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            lda impulseStrength
            asl a
            sta impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          rem   approximation
          rem totalWeight ranges 10-200, use closest power-of-2
          if totalWeight >= 128 then goto ApproxDivBy128_1 : rem   approximation
          if totalWeight >= 64 then goto ApproxDivBy64_1
          if totalWeight >= 32 then goto ApproxDivBy32_1
          rem Default: divide by 16 (approximation for 10-31)
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy32_1
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy64_1
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy128_1
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_1
          if impulseStrength = 0 then impulseStrength = 1 : rem Scale impulse by weight ratio (0-2 pixels/frame)
          rem Minimum 1 pixel/frame
          
          rem Apply to Player1 velocity (push left)
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252 : rem Cap at -4 pixels/frame (252 in twos complement)
          
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength : rem Apply to Player2 velocity (push right)
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4 : rem Cap at 4 pixels/frame
          
          let playerVelocityXL[temp1] = 0 : rem Also zero subpixel velocities when applying impulse
          let playerVelocityXL[temp2] = 0
          
          goto CollisionNextInner
          
ApplyImpulse1Heavier
          rem Player1 is heavier - push Player1 right (positive X),
          rem   Player2 left (negative X)
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            lda impulseStrength
            asl a
            sta impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          if totalWeight >= 128 then goto ApproxDivBy128_2 : rem   approximation
          if totalWeight >= 64 then goto ApproxDivBy64_2
          if totalWeight >= 32 then goto ApproxDivBy32_2
          rem Default: divide by 16
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy32_2
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy64_2
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy128_2
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_2
          if impulseStrength = 0 then impulseStrength = 1 : rem Scale impulse by weight ratio
          
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength : rem Apply to Player1 velocity (push right)
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          
          rem Apply to Player2 velocity (push left)
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252 : rem Cap at -4 pixels/frame (252 in twos complement)
          
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          
          goto CollisionNextInner
          
CollisionSepLeft
          rem Player1 is left of Player2 - push Player1 left, Player2
          rem   right
          rem Same logic but reversed directions
          rem Re-read weights (characterWeight and halfHeight2 were used
          let characterWeight = CharacterWeights[temp4] : rem   for heights)
          let halfHeight2 = CharacterWeights[temp5] : rem Player1 weight
          let totalWeight = characterWeight + halfHeight2 : rem Player2 weight
          if totalWeight = 0 then goto CollisionNextInner
          
          if characterWeight >= halfHeight2 then CalcWeightDiff1HeavierLeft
          let weightDifference = halfHeight2 - characterWeight
          let impulseStrength = weightDifference
          goto ApplyImpulseLeft
          
CalcWeightDiff1HeavierLeft
          let weightDifference = characterWeight - halfHeight2
          let impulseStrength = weightDifference
          
ApplyImpulseLeft
          if characterWeight >= halfHeight2 then ApplyImpulse1HeavierLeft
          
          rem Player2 is heavier - push Player1 left, Player2 right
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            lda impulseStrength
            asl a
            sta impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          if totalWeight >= 128 then goto ApproxDivBy128_3 : rem   approximation
          if totalWeight >= 64 then goto ApproxDivBy64_3
          if totalWeight >= 32 then goto ApproxDivBy32_3
          rem Default: divide by 16
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy32_3
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy64_3
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy128_3
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_3
          if impulseStrength = 0 then impulseStrength = 1
          
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252 : rem Cap at -4 pixels/frame (252 in twos complement)
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          
          goto CollisionNextInner
          
ApplyImpulse1HeavierLeft
          rem Player1 is heavier - push Player1 right, Player2 left
          rem Multiply by 2 using bit shift, then approximate division
          rem   by totalWeight
          asm
            asl impulseStrength
end
          rem Approximate division by totalWeight using bit-shift
          rem   approximation
          rem totalWeight ranges 10-200, use closest power-of-2
          if totalWeight >= 128 then goto ApproxDivBy128_1Heavier : rem   approximation
          if totalWeight >= 64 then goto ApproxDivBy64_1Heavier
          if totalWeight >= 32 then goto ApproxDivBy32_1Heavier
          if totalWeight >= 16 then goto ApproxDivBy16_1Heavier
          if totalWeight >= 8 then goto ApproxDivBy8_1Heavier
          goto ApproxDivDone_1Heavier
ApproxDivBy128_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy64_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy32_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy16_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
          goto ApproxDivDone_1Heavier
ApproxDivBy8_1Heavier
          asm
            lsr impulseStrength
            lsr impulseStrength
            lsr impulseStrength
end
ApproxDivDone_1Heavier
          if impulseStrength = 0 then impulseStrength = 1
          
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          rem Check if velocity > -4 (in twos complement: values <= 252
          rem   are >= -4)
          rem -4 in twos complement = 256 - 4 = 252
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252 : rem Cap at -4 pixels/frame (252 in twos complement)
          
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          
CollisionNextInner
          let temp2 = temp2 + 1
          goto CollisionCheckPair
          
CollisionNextOuter
          let temp1 = temp1 + 1
          if temp1 < 3 then goto CollisionOuterLoop
          rem Only check pairs where i < j, so i only goes up to 2 (to
          rem   check pair with j=3)
          
          return

