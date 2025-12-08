;;; ChaosFight - Source/Routines/BeginFallingAnimation.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Begin Falling Animation

BeginFallingAnimation
          ;; Returns: Far (return otherbank)
;; BeginFallingAnimation (duplicate)

          ;; Setup routine for Falling In animation.
          ;; Returns: Far (return otherbank)
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
          ;; lda # 2 (duplicate)
          ;; sta fallSpeed (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta fallComplete (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta activePlayers (duplicate)

          ;; Set game screen layout (32×8 for playfield scanning) - inlined
          ;; lda ScreenPfRowHeight (duplicate)
          ;; sta pfrowheight (duplicate)
          ;; lda ScreenPfRows (duplicate)
          ;; sta pfrows (duplicate)

          ;; Background: black (COLUBK starts black, no need to set)

          ;; Initialize player positions in quadrants
          ;; Player 1: Top-left quadrant (unless NO)
                    ;; if playerCharacter[0] = NoCharacter then DonePlayer1Init
          ;; lda 0 (duplicate)
          asl
          tax
          ;; lda 16 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; Top-left X position
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 8 (duplicate)
          ;; sta playerY,x (duplicate)
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
                    ;; if playerCharacter[1] = NoCharacter then DonePlayer2Init
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 144 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; Top-right X position
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 8 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Top-right Y position (near top)
          ;; inc activePlayers (duplicate)

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
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          cmp # 0
          bne skip_1841
skip_1841:


                    ;; if playerCharacter[2] = NoCharacter then DonePlayer3Init
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 16 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; Bottom-left X position
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 80 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Bottom-left Y position (near bottom)
          ;; inc activePlayers (duplicate)

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
          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1337 (duplicate)
skip_1337:


                    ;; if playerCharacter[3] = NoCharacter then DonePlayer4Init
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 144 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; Bottom-right X position
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 80 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Bottom-right Y position (near bottom)
          ;; inc activePlayers (duplicate)

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


