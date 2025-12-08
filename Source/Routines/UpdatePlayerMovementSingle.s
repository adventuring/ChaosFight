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
          ;; Skip if player is eliminated
          jsr BS_return
          ;; Apply X Velocity To X Position (8.8 fixed-point)
          ;; Use batariBASIC’s built-in 16-bit addition for carry detection
                    ;; let subpixelAccumulator = playerSubpixelX_RL[currentPlayer] + playerVelocityXL[currentPlayer]         
          lda currentPlayer
          asl
          tax
          ;; lda playerSubpixelX_RL,x (duplicate)
          sta subpixelAccumulator
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerSubpixelX_WL,x (duplicate)
          ;; lda temp3 (duplicate)
          cmp # 1
          bcc skip_6578
                    ;; let playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + 1
skip_6578:

          ;; Apply integer velocity component
                    ;; let playerSubpixelX_W[currentPlayer] = playerSubpixelX_R[currentPlayer] + playerVelocityX[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerSubpixelX_R,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          clc
          adc temp6
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerSubpixelX_W,x (duplicate)
          ;; Sync integer position for rendering
                    ;; let playerX[currentPlayer] = playerSubpixelX_R[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerSubpixelX_R,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerX,x (duplicate)
          ;; Apply Y Velocity To Y Position (8.8 fixed-point)
          ;; Use batariBASIC’s built-in 16-bit addition for carry detection
                    ;; let subpixelAccumulator = playerSubpixelY_RL[currentPlayer] + playerVelocityYL[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerSubpixelY_RL,x (duplicate)
          ;; sta subpixelAccumulator (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerSubpixelY_WL,x (duplicate)
          ;; lda temp3 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bcc skip_2398 (duplicate)
                    ;; let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + 1
skip_2398:

          ;; Apply integer velocity component
                    ;; let playerSubpixelY_W[currentPlayer] = playerSubpixelY_R[currentPlayer] + playerVelocityY[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerSubpixelY_R,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityY,x (duplicate)
          ;; clc (duplicate)
          ;; adc temp6 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerSubpixelY_W,x (duplicate)
          ;; Sync integer position for rendering
                    ;; let playerY[currentPlayer] = playerSubpixelY_R[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerSubpixelY_R,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerY,x (duplicate)
          ;; jsr BS_return (duplicate)

.pend

