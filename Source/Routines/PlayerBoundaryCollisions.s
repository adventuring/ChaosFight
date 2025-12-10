;;; ChaosFight - Source/Routines/PlayerBoundaryCollisions.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CheckBoundaryCollisions
;;; Returns: Far (return otherbank)
CheckBoundaryCollisions
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
          cmp RandomArena
          bne skip_7276
                    let temp3 = rand : temp3 = temp3 & 15
skip_7276:


          ;; TODO: for temp1 = 0 to 3
          ;; if temp1 < 2 then goto PBC_ProcessPlayer          lda temp1          cmp 2          bcs .skip_8159          jmp
          lda temp1
          cmp # 2
          bcs skip_2435
          goto_label:

          jmp goto_label
skip_2435:

          lda temp1
          cmp # 2
          bcs skip_2705
          jmp goto_label
skip_2705:

          
                    if controllerStatus & SetQuadtariDetected then goto PBC_CheckActivePlayer
          jmp PBC_NextPlayer

PBC_CheckActivePlayer .proc
                    if playerCharacter[temp1] = NoCharacter then goto PBC_NextPlayer
.pend

PBC_ProcessPlayer .proc
          jsr CheckPlayerBoundary
.pend

PBC_NextPlayer .proc
.pend

next_label_1_L78:.proc
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
                    if playerX[temp1] < PlayerLeftWrapThreshold then let playerX[temp1] = PlayerRightEdge : let playerSubpixelX_W[temp1] = PlayerRightEdge : let playerSubpixelX_WL[temp1] = 0

                    if playerX[temp1] > PlayerRightWrapThreshold then let playerX[temp1] = PlayerLeftEdge : let playerSubpixelX_W[temp1] = PlayerLeftEdge
          lda temp1
          asl
          tax
          lda playerX,x
          sec
          sbc PlayerRightWrapThreshold
          bcc skip_141
          beq skip_141
          lda PlayerLeftEdge
          sta playerX,x
          lda PlayerLeftEdge
          sta playerSubpixelX_W,x
skip_141: : let playerSubpixelX_WL[temp1] = 0

                    if playerY[temp1] < 20 then let playerY[temp1] = 20 : let playerSubpixelY_W[temp1] = 20 : let playerSubpixelY_WL[temp1] = 0
          lda temp1
          asl
          tax
          lda playerY,x
          cmp 20
          bcs skip_8639
          lda 20
          sta playerY,x
          lda 20
          sta playerSubpixelY_W,x
          lda # 0
          sta playerSubpixelY_WL,x
skip_8639: : let playerVelocityY[temp1] = 0 : let playerVelocityYL[temp1] = 0

          rts

                    if playerCharacter[temp1] = CharacterBernie then goto CheckPlayerBoundary_BernieWrap
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp CharacterBernie
          bne skip_8254
          jmp CheckPlayerBoundary_BernieWrap
skip_8254:

                    let playerHealth[temp1] = 0 : let currentPlayer = temp1 : gosub CheckPlayerElimination bank14
          lda temp1
          asl
          tax
          lda # 0
          sta playerHealth,x
          lda temp1
          sta currentPlayer
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckPlayerElimination-1)
          pha
          lda # <(CheckPlayerElimination-1)
          pha
          ldx # 13
          jmp BS_jsr
return_point:

          rts

.pend

CheckPlayerBoundary_BernieWrap .proc
          lda temp1
          asl
          tax
          lda 0
          sta playerSubpixelY_WL,x
          rts


.pend

