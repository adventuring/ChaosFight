;;; ChaosFight - Source/Routines/InitializeMovementSystem.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


InitializeMovementSystem .proc
;;; Initialize movement system for all players
          ;; Called at game start to set up initial positions and
          ;; velocities
          ;; Initialize movement system for all players (called at game
          ;; start to set up initial positions and velocities)
          ;;
          ;; Input: None (initializes all players 0-3)
          ;;
          ;; Output: All players initialized to center of screen (X=80,
          ;; Y=100) with zero velocities
          ;;
          ;; Mutates: temp1-temp3 (used for calculations), playerX[],
          ;; playerY[] (global arrays) = integer positions (set to 80,
          ;; 100), playerSubpixelX_W[], playerSubpixelX_WL[],
          ;; playerSubpixelY_W[], playerSubpixelY_WL[] (global SCRAM
          ;; arrays) = subpixel positions (set to 80, 100, low bytes
          ;; zeroed), playerVelocityX[], playerVelocityXL[],
          ;; playerVelocityY[], playerVelocityYL[] (global arrays) =
          ;; velocities (all set to 0)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Initializes all 4 players to same position
          ;; (center of screen). All velocities set to zero
          ;; Initialize all players to center of screen - inlined for
          ;; performance
          lda # 80
          sta temp2
          lda # 100
          sta temp3
          ;; Player 0
          lda # 0
          asl
          tax
          lda temp2
          sta playerX,x
          lda # 0
          asl
          tax
          lda temp2
          sta playerSubpixelX_W,x
          lda # 0
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
          lda # 0
          asl
          tax
          lda temp3
          sta playerY,x
          lda # 0
          asl
          tax
          lda temp3
          sta playerSubpixelY_W,x
          lda # 0
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x
          ;; Player 1
          lda # 1
          asl
          tax
          lda temp2
          sta playerX,x
          lda # 1
          asl
          tax
          lda temp2
          sta playerSubpixelX_W,x
          lda # 1
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
          lda # 1
          asl
          tax
          lda temp3
          sta playerY,x
          lda # 1
          asl
          tax
          lda temp3
          sta playerSubpixelY_W,x
          lda # 1
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x
          ;; Player 2
          lda # 2
          asl
          tax
          lda temp2
          sta playerX,x
          lda # 2
          asl
          tax
          lda temp2
          sta playerSubpixelX_W,x
          lda # 2
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
          lda # 2
          asl
          tax
          lda temp3
          sta playerY,x
          lda # 2
          asl
          tax
          lda temp3
          sta playerSubpixelY_W,x
          lda # 2
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x
          ;; Player 3
          lda # 3
          asl
          tax
          lda temp2
          sta playerX,x
          lda # 3
          asl
          tax
          lda temp2
          sta playerSubpixelX_W,x
          lda # 3
          asl
          tax
          lda # 0
          sta playerSubpixelX_WL,x
          lda # 3
          asl
          tax
          lda temp3
          sta playerY,x
          lda # 3
          asl
          tax
          lda temp3
          sta playerSubpixelY_W,x
          lda # 3
          asl
          tax
          lda # 0
          sta playerSubpixelY_WL,x

          ;; Initialize velocities to zero - inlined for performance
          ;; Player 0
          lda # 0
          asl
          tax
          lda # 0
          sta playerVelocityX,x
          lda # 0
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          lda # 0
          asl
          tax
          lda # 0
          sta playerVelocityY,x
          lda # 0
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; Player 1
          lda # 1
          asl
          tax
          lda # 0
          sta playerVelocityX,x
          lda # 1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          lda # 1
          asl
          tax
          lda # 0
          sta playerVelocityY,x
          lda # 1
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; Player 2
          lda # 2
          asl
          tax
          lda # 0
          sta playerVelocityX,x
          lda # 2
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          lda # 2
          asl
          tax
          lda # 0
          sta playerVelocityY,x
          lda # 2
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; Player 3
          lda # 3
          asl
          tax
          lda # 0
          sta playerVelocityX,x
          lda # 3
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          lda # 3
          asl
          tax
          lda # 0
          sta playerVelocityY,x
          lda # 3
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          rts

.pend

