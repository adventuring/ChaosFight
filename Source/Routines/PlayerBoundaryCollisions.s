;;; ChaosFight - Source/Routines/PlayerBoundaryCollisions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CheckBoundaryCollisions:
          ;; Returns: Far (return otherbank)
          ;; Player Physics - Boundary Collisions
          ;; Returns: Far (return otherbank)
          ;; Handles horizontal wraparound and vertical clamps for all players.
          ;; Split from PlayerPhysicsCollisions.bas to reduce bank size.
          ;; AVAILABLE VARIABLES:
          ;; playerX[0-3], playerY[0-3] - Positions
          ;; playerState[0-3] - State flags
          ;; playerVelocityX[0-3] - Horizontal velocity (8.8 fixed-point)
          ;; playerVelocityY[0-3] - Vertical velocity (8.8 fixed-point)
          ;;
          ;; playerCharacter[0-3] - Character type indices
          ;; QuadtariDetected - Whether 4-player mode active
          ;;
          ;; Input: playerX[], playerY[], playerSubpixelX[], playerSubpixelY[],
          ;; playerSubpixelXL[], playerSubpixelYL[], playerVelocityY[],
          ;; playerVelocityYL[], controllerStatus, playerCharacter[],
          ;; selectedArena_R, frame, RandomArena
          ;;
          ;; Output: Players clamped to screen boundaries, horizontal wraparound applied,
          ;; vertical velocity zeroed at boundaries
          ;;
          ;; Mutates: temp1-temp3, playerX[], playerY[], playerSubpixelX[],
          ;; playerSubpixelY[], playerSubpixelXL[], playerSubpixelYL[],
          ;; playerVelocityY[], playerVelocityYL[]
          ;;
          ;; Called Routines: CheckPlayerBoundary
          ;;
          ;; Constraints: All arenas support horizontal wraparound
          ;; (X < PlayerLeftWrapThreshold wraps to PlayerRightEdge, × > PlayerRightWrapThreshold
          ;; wraps to PlayerLeftEdge). Vertical boundaries clamp (Y < 20 clamped to 20,
          ;; Y > ScreenBottom triggers elimination). Players 3/4 only checked if Quadtari detected.
          lda selectedArena_R
          sta temp3
          lda temp3
          cmp # RandomArena
          bne SkipRandomArena

          ;; Set temp3 = rand temp3 = temp3 & 15

SkipRandomArena:

          ;; Issue #1254: Loop through temp1 = 0 to 3
          lda # 0
          sta temp1
PBC_Loop:
          ;; if temp1 < 2 then jmp PBC_ProcessPlayer
          lda temp1
          cmp # 2
          bcs CheckQuadtari

          jmp PBC_ProcessPlayer

CheckQuadtari:

          lda temp1
          cmp # 2
          bcs Skip2PlayerCheck

          jmp PBC_ProcessPlayer

Skip2PlayerCheck:

          ;; if controllerStatus & SetQuadtariDetected then jmp PBC_CheckActivePlayer
          jmp PBC_NextPlayer

PBC_CheckActivePlayer .proc
          ;; if playerCharacter[temp1] = NoCharacter then jmp PBC_NextPlayer

.pend

PBC_ProcessPlayer .proc
          jsr CheckPlayerBoundary

.pend

PBC_NextPlayer .proc
          ;; Issue #1254: Loop increment and check
          inc temp1
          lda temp1
          cmp # 4
          bcs PBC_LoopDone
          jmp PBC_Loop
PBC_LoopDone:
          rts
.pend

CheckPlayerBoundary .proc
          ;; Check Player Boundary
          ;; Returns: Near (return thisbank)
          ;; Shared function to check boundary collisions for a single player
          ;; Reduces code duplication from 4x to 1x implementation
          ;;
          ;; Input: temp1 = player index (0-3)
          ;; playerX[], playerY[]
          ;; playerCharacter[]
          ;; playerSubpixelX[], playerSubpixelY[]
          ;; playerVelocityY[]
          ;;
          ;; Output: Player clamped to screen boundaries, horizontal wraparound applied
          ;;
          ;; Mutates: playerX[], playerY[], playerSubpixelX[], playerSubpixelY[],
          ;; playerVelocityY[], playerHealth[], currentPlayer
          ;;
          ;; Called Routines: CheckPlayerElimination (bank14)
          ;;
          ;; Constraints: Uses temp1 as player index, temp2 as scratch.
          ;; Check left wrap threshold
          lda temp1
          asl
          tax
          lda playerX,x
          cmp # PlayerLeftWrapThreshold
          bcs CheckRightWrap

          ;; Left wrap: set to PlayerRightEdge
          lda # PlayerRightEdge
          sta playerX,x
          sta playerSubpixelX_W,x
          lda # 0
          sta playerSubpixelX_WL,x
          jmp CheckTopClamp

CheckRightWrap:
          lda playerX,x
          sec
          sbc # PlayerRightWrapThreshold
          bcc SkipRightWrap

          beq SkipRightWrap

          lda # PlayerLeftEdge
          sta playerX,x
          lda # PlayerLeftEdge
          sta playerSubpixelX_W,x

SkipRightWrap:
          lda # 0
          sta playerSubpixelX_WL,x

CheckTopClamp:
          ;; Check top clamp (Y < 20, clamp to 20)
          lda temp1
          asl
          tax
          lda playerY,x
          cmp # 20
          bcs SkipTopClamp

          lda # 20
          sta playerY,x
          lda # 20
          sta playerSubpixelY_W,x
          lda # 0
          sta playerSubpixelY_WL,x

SkipTopClamp:
          ;; Zero vertical velocity at boundaries (prevent upward movement)
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityY,x
          sta playerVelocityYL,x

          rts

          ;; if playerCharacter[temp1] = CharacterBernie then jmp CheckPlayerBoundary_BernieWrap
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterBernie
          bne SkipBernieWrap

          jmp CheckPlayerBoundary_BernieWrap

SkipBernieWrap:
          ;; Set player health to 0 and eliminate
          lda temp1
          asl
          tax
          lda # 0
          sta playerHealth,x
          lda temp1
          sta currentPlayer
          lda # >(AfterCheckPlayerEliminationBoundary-1)
          pha
          lda # <(AfterCheckPlayerEliminationBoundary-1)
          pha
          lda # >(CheckPlayerElimination-1)
          pha
          lda # <(CheckPlayerElimination-1)
          pha
          ldx # 13
          jmp BS_jsr

AfterCheckPlayerEliminationBoundary:

          rts

.pend

CheckPlayerBoundary_BernieWrap .proc
          lda temp1
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x
          rts

.pend

