;;; ChaosFight - Source/Routines/BeginFallingAnimation.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Begin Falling Animation

BeginFallingAnimation:
          ;; Returns: Far (return otherbank)
          ;; Setup routine for Falling In animation.
          ;; Sets players in quadrant starting positions and
          ;; initializes sta

          ;;
          ;; Quadrant positions:
          ;; - Top-left: Player 1 (playerCharacter[0])
          ;; - Top-right: Player 2 (playerCharacter[1])
          ;; - Bottom-left: Player 3 (playerCharacter[2], if active)
          ;; - Bottom-right: Player 4 (playerCharacter[3], if active)
          ;; After animation completes, players will be at row 2
          ;; positions
          ;; and transition to Game Mode.
          ;; Setup routine for Falling In animation - sets players in
          ;; quadrant starting positions
          ;;
          ;; Input: playerCharacter[] (global array) = character selections
          ;; controllerStatus (global) = controller detection
          ;; sta

          ;;
          ;; Output: fallFrame, fallSpeed, fallComplete, activePlayers
          ;; initialized,
          ;; screen layout set, COLUBK set, playerX[],
          ;; playerY[] set for active players
          ;;
          ;; Mutates: fallFrame (set to 0), fallSpeed (set to 2),
          ;; fallComplete (set to 0),
          ;; activePlayers (incremented per active player),
          ;; pfrowheight, pfrows (set via SetGameScreenLayout),
          ;; COLUBK (TIA register), playerX[0-3], playerY[0-3]
          ;; (set for active players)
          ;;
          ;; Called Routines: SetGameScreenLayout (bank7) - sets screen
          ;; layout
          ;;
          ;; Constraints: Must be colocated with DonePlayer1Init,
          ;; DonePlayer2Init,
          ;; DonePlayer3Init, DonePlayer4Init (all called
          ;; via goto)
          ;; Called from ChangeGameMode when entering
          ;; falling animation mode
          ;; Initialize animation sta

          lda # 0
          sta fallFrame
          lda # 2
          sta fallSpeed
          lda # 0
          sta fallComplete
          lda # 0
          sta activePlayers

          ;; Set game screen layout (32×8 for playfield scanning) - inlined
          lda # ScreenPfRowHeight
          sta pfrowheight
          lda # ScreenPfRows
          sta pfrows

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Initialize player positions in quadrants
          ;; Player 1: Top-left quadrant (unless NO)
          if playerCharacter[0] = NoCharacter then DonePlayer1Init
          lda # 0
          asl
          tax
          lda # 16
          sta playerX,x
          ;; Top-left X position
          lda # 0
          asl
          tax
          lda 8
          sta playerY,x
          ;; Top-left Y position (near top)
          inc activePlayers

DonePlayer1Init
          ;; Player 1 initialization complete (skipped if not active)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with BeginFallingAnimation

          ;; Player 2: Top-right quadrant (unless NO)
                    if playerCharacter[1] = NoCharacter then DonePlayer2Init
          lda 1
          asl
          tax
          lda 144
          sta playerX,x
          ;; Top-right X position
          lda 1
          asl
          tax
          lda 8
          sta playerY,x
          ;; Top-right Y position (near top)
          inc activePlayers

DonePlayer2Init
          ;; Player 2 initialization complete (skipped if not active)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with BeginFallingAnimation

          ;; Player 3: Bottom-left quadrant (if Quadtari and not NO)
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer3Character

          jmp DonePlayer3Init
CheckPlayer3Character:


                    if playerCharacter[2] = NoCharacter then DonePlayer3Init
          lda 2
          asl
          tax
          lda 16
          sta playerX,x
          ;; Bottom-left X position
          lda 2
          asl
          tax
          lda 80
          sta playerY,x
          ;; Bottom-left Y position (near bottom)
          inc activePlayers

DonePlayer3Init
          ;; Player 3 initialization complete (skipped if not in
          ;; Returns: Far (return otherbank)
          ;; 4-player mode or not active)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with BeginFallingAnimation

          ;; Player 4: Bottom-right quadrant (if Quadtari and not NO)
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer4Character

          jmp DonePlayer4Init
CheckPlayer4Character:


                    if playerCharacter[3] = NoCharacter then DonePlayer4Init
          lda 3
          asl
          tax
          lda 144
          sta playerX,x
          ;; Bottom-right X position
          lda 3
          asl
          tax
          lda 80
          sta playerY,x
          ;; Bottom-right Y position (near bottom)
          inc activePlayers

DonePlayer4Init
          ;; Player 4 initialization complete (skipped if not in
          ;; Returns: Far (return otherbank)
          ;; 4-player mode or not active)
          ;;
          ;; Input: None (label only, no execution)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with BeginFallingAnimation
          jsr BS_return


