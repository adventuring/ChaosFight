          rem ChaosFight - Source/Routines/PlayerPhysics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckBoundaryCollisions
          rem
          rem Check Boundary Collisions
          rem Prevents players from moving off-screen.
          rem Prevents players from moving off-screen, handles
          rem horizontal wrap-around and vertical clamping
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
          rem wrap-around applied
          rem
          rem Mutates: temp1-temp3 (used for calculations), playerX[],
          rem playerY[] (global arrays) = player positions,
          rem playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[],
          rem playerSubpixelYL[] (global arrays) = subpixel positions,
          rem playerVelocityY[], playerVelocityYL[] (global arrays) =
          rem vertical velocity (zeroed at boundaries)
          rem
          rem Called Routines: None
          rem
          rem Constraints: All arenas support horizontal wrap-around (X
          rem < PlayerLeftWrapThreshold wraps to PlayerRightEdge, X >
          rem PlayerRightWrapThreshold wraps to PlayerLeftEdge). Vertical
          rem boundaries clamped (Y < 20 clamped to 20, Y > 80 clamped
          rem to 80)
          let temp1 = 0
          rem Loop through all players (0-3)
BoundaryLoop
          rem Check if player is active (P1/P2 always active, P3/P4 need
          rem Quadtari)
          if temp1 < 2 then BoundaryCheckBounds
          rem Players 0-1 always active
          if !(controllerStatus & SetQuadtariDetected) then goto BoundaryNextPlayer
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto BoundaryNextPlayer
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto BoundaryNextPlayer

BoundaryCheckBounds
          rem All arenas support horizontal wrap-around for players
          rem   (except where walls stop it)
          rem Handle RandomArena by checking selected arena
          let temp3 = selectedArena_R
          rem Handle RandomArena (use proper random number generator)
          if temp3 = RandomArena then temp3 = rand : temp3 = temp3 & 15

          rem All arenas: wrap horizontally (walls may block
          rem wrap-around)
          rem Horizontal wrap driven by PlayerLeftWrapThreshold and PlayerRightWrapThreshold
          if playerX[temp1] < PlayerLeftWrapThreshold then let playerX[temp1] = PlayerRightEdge
          if playerX[temp1] < PlayerLeftWrapThreshold then let playerSubpixelX_W[temp1] = PlayerRightEdge
          if playerX[temp1] < PlayerLeftWrapThreshold then let playerSubpixelX_WL[temp1] = 0
          if playerX[temp1] > PlayerRightWrapThreshold then let playerX[temp1] = PlayerLeftEdge
          if playerX[temp1] > PlayerRightWrapThreshold then let playerSubpixelX_W[temp1] = PlayerLeftEdge
          if playerX[temp1] > PlayerRightWrapThreshold then let playerSubpixelX_WL[temp1] = 0

          rem Y position: clamp to screen boundaries (no vertical wrap)
          rem Top boundary: clamp to prevent going above screen
          if playerY[temp1] < 20 then let playerY[temp1] = 20
          if playerY[temp1] < 20 then let playerSubpixelY_W[temp1] = 20
          if playerY[temp1] < 20 then let playerSubpixelY_WL[temp1] = 0
          if playerY[temp1] < 20 then let playerVelocityY[temp1] = 0
          if playerY[temp1] < 20 then let playerVelocityYL[temp1] = 0
          rem Bottom boundary: clamp to prevent going below screen
          if playerY[temp1] > 80 then let playerY[temp1] = 80
          if playerY[temp1] > 80 then let playerSubpixelY_W[temp1] = 80
          if playerY[temp1] > 80 then let playerSubpixelY_WL[temp1] = 0
          if playerY[temp1] > 80 then let playerVelocityY[temp1] = 0
          if playerY[temp1] > 80 then let playerVelocityYL[temp1] = 0

BoundaryNextPlayer
          let temp1 = temp1 + 1
          rem Move to next player
          if temp1 < 4 then goto BoundaryLoop

          return