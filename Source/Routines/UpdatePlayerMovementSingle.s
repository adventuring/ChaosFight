;;; ChaosFight - Source/Routines/UpdatePlayerMovementSingle.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


UpdatePlayerMovementSingle .proc
          ;; Move one player using 8.8 fixed-point velocity integration.
          ;; Returns: Far (return otherbank)
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; playerHealth[], playerSubpixelX/Y (SCRAM),
          ;; playerVelocityX/Y, playerX[], playerY[]
          ;; Output: playerX[]/playerY[] updated (integer + subpixel)
          ;; Mutates: temp2-temp4, playerSubpixelX/Y, playerX[], playerY[]
          ;; Constraints: Must be colocated with XCarry/XNoCarry/YCarry/YNoCarry
          ;; Notes: temp2-temp4 are clobbered; caller must not reuse them afterward.
          ;; 16-bit accumulator for proper carry detection
          ;; Skip if player is eliminated - TODO: implement elimination check
          ;; Apply X Velocity To X Position (8.8 fixed-point)
          ;; Use batariBASIC’s built-in 16-bit addition for carry detection
          ;; Set subpixelAccumulator = playerSubpixelX_RL[currentPlayer] + playerVelocityXL[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerSubpixelX_RL,x
          sta subpixelAccumulator
          lda currentPlayer
          asl
          tax
          lda temp2
          sta playerSubpixelX_WL,x
          lda temp3
          cmp # 1
          bcc NoXCarry

          ;; Set playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + 1
          lda currentPlayer
          asl
          tax
          lda playerSubpixelX_R,x
          clc
          adc # 1
          sta playerSubpixelX_W,x

NoXCarry:

          ;; Apply integer velocity component
          ;; Set playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + playerVelocityX[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerSubpixelX_R,x
          sta temp6
          lda currentPlayer
          asl
          tax
          lda playerVelocityX,x
          clc
          adc temp6
          lda currentPlayer
          asl
          tax
          sta playerSubpixelX_W,x
          ;; Position already synced above
          ;; Apply Y Velocity To Y Position (8.8 fixed-point)
          ;; Use batariBASIC’s built-in 16-bit addition for carry detection
          ;; Set subpixelAccumulator = playerSubpixelY_RL[currentPlayer] + playerVelocityYL[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerSubpixelY_RL,x
          sta subpixelAccumulator
          lda currentPlayer
          asl
          tax
          lda temp2
          sta playerSubpixelY_WL,x
          lda temp3
          cmp # 1
          bcc NoYCarry

          let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + 1

NoYCarry:

          ;; Apply integer velocity component
          let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + playerVelocityY[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerSubpixelY_R,x
          sta temp6
          lda currentPlayer
          asl
          tax
          lda playerVelocityY,x
          clc
          adc temp6
          lda currentPlayer
          asl
          tax
          sta playerSubpixelY_W,x
          ;; Sync integer position for rendering
          ;; Set playerY[currentPlayer] = playerSubpixelY_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerSubpixelY_R,x
          lda currentPlayer
          asl
          tax
          sta playerY,x
          jmp BS_return

.pend

