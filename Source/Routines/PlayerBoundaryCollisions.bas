          rem ChaosFight - Source/Routines/PlayerBoundaryCollisions.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

CheckBoundaryCollisions
          asm
CheckBoundaryCollisions
end
          rem Player Physics - Boundary Collisions
          rem Handles horizontal wraparound and vertical clamps for all players.
          rem Split from PlayerPhysicsCollisions.bas to reduce bank size.
          rem AVAILABLE VARIABLES:
          rem   playerX[0-3], playerY[0-3] - Positions
          rem   playerState[0-3] - State flags
          rem   playerVelocityX[0-3] - Horizontal velocity (8.8 fixed-point)
          rem   playerVelocityY[0-3] - Vertical velocity (8.8 fixed-point)
          rem
          rem   playerCharacter[0-3] - Character type indices
          rem   QuadtariDetected - Whether 4-player mode active
          rem
          rem Input: playerX[], playerY[], playerSubpixelX[], playerSubpixelY[],
          rem playerSubpixelXL[], playerSubpixelYL[], playerVelocityY[],
          rem playerVelocityYL[], controllerStatus, playerCharacter[],
          rem selectedArena_R, frame, RandomArena
          rem
          rem Output: Players clamped to screen boundaries, horizontal wraparound applied,
          rem vertical velocity zeroed at boundaries
          rem
          rem Mutates: temp1-temp3, playerX[], playerY[], playerSubpixelX[],
          rem playerSubpixelY[], playerSubpixelXL[], playerSubpixelYL[],
          rem playerVelocityY[], playerVelocityYL[]
          rem
          rem Called Routines: CheckPlayerBoundary
          rem
          rem Constraints: All arenas support horizontal wraparound
          rem (X < PlayerLeftWrapThreshold wraps to PlayerRightEdge, X > PlayerRightWrapThreshold
          rem wraps to PlayerLeftEdge). Vertical boundaries clamp (Y < 20 clamped to 20,
          rem Y > ScreenBottom triggers elimination). Players 3/4 only checked if Quadtari detected.
          let temp3 = selectedArena_R
          if temp3 = RandomArena then temp3 = rand : temp3 = temp3 & 15

          for temp1 = 0 to 3
              if temp1 < 2 then goto PBC_ProcessPlayer
              if controllerStatus & SetQuadtariDetected then goto PBC_CheckActivePlayer
              goto PBC_NextPlayer
PBC_CheckActivePlayer
              if playerCharacter[temp1] = NoCharacter then goto PBC_NextPlayer
PBC_ProcessPlayer
              gosub CheckPlayerBoundary
PBC_NextPlayer
          next
          return otherbank
CheckPlayerBoundary
          asm
CheckPlayerBoundary
end
          rem Check Player Boundary
          rem Shared function to check boundary collisions for a single player
          rem Reduces code duplication from 4x to 1x implementation
          rem
          rem Input: temp1 = player index (0-3)
          rem        playerX[], playerY[]
          rem        playerCharacter[]
          rem        playerSubpixelX[], playerSubpixelY[]
          rem        playerVelocityY[]
          rem
          rem Output: Player clamped to screen boundaries, horizontal wraparound applied
          rem
          rem Mutates: playerX[], playerY[], playerSubpixelX[], playerSubpixelY[],
          rem          playerVelocityY[], playerHealth[], currentPlayer
          rem
          rem Called Routines: CheckPlayerElimination (bank14)
          rem
          rem Constraints: Uses temp1 as player index, temp2 as scratch.
          if playerX[temp1] < PlayerLeftWrapThreshold then let playerX[temp1] = PlayerRightEdge : let playerSubpixelX_W[temp1] = PlayerRightEdge : let playerSubpixelX_WL[temp1] = 0
          if playerX[temp1] > PlayerRightWrapThreshold then let playerX[temp1] = PlayerLeftEdge : let playerSubpixelX_W[temp1] = PlayerLeftEdge : let playerSubpixelX_WL[temp1] = 0
          if playerY[temp1] < 20 then let playerY[temp1] = 20 : let playerSubpixelY_W[temp1] = 20 : let playerSubpixelY_WL[temp1] = 0 : let playerVelocityY[temp1] = 0 : let playerVelocityYL[temp1] = 0
          if playerY[temp1] <= ScreenBottom then return thisbank
          if playerCharacter[temp1] = CharacterBernie then goto CheckPlayerBoundary_BernieWrap
          let playerHealth[temp1] = 0 : let currentPlayer = temp1 : gosub CheckPlayerElimination bank14
          return thisbank
CheckPlayerBoundary_BernieWrap
          let playerY[temp1] = 0 : let playerSubpixelY_W[temp1] = 0 : let playerSubpixelY_WL[temp1] = 0
          return thisbank

