;;; ChaosFight - Source/Routines/GameLoopInit.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
          ;;
;;; Game Loop Initialization
;;; Initializes all game state for the main gameplay loop.
          ;; Called once when entering gameplay from character select.
          ;; INITIALIZES:
          ;; - Player positions, states, health, momentum
          ;; - Character types from selections
          ;; - Missiles and projectiles
          ;; - Frame counter and game sta

          ;; - Arena data
          ;; STATE FLAG DEFINITIONS (in playerState):
          ;; bit 0: Facing (1 = right, 0 = left)
          ;; bit 1: Guarding
          ;; bit 2: Jumping
          ;; bit 3: Recovery (hitstun)
          ;; Bits 4-7: Animation state (0-15)
          ;; ANIMATION STATES:
          ;; 0=Standing right, 1=Idle, 2=Guarding, 3=Walking/running,
          ;; 4=Coming to stop, 5=Taking hit, 6=Falling backwards,
          ;; 7=Falling down, 8=Fallen down, 9=Recovering,
          ;; 10=Jumping, 11=Falling, 12=Landing, 13-15=Reserved


BeginGameLoop .proc



          ;; Initialize all game state for the main gameplay loop
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: controllerStatus (global) = controller detection
          ;; sta

          ;; playerCharacter[] (global array) = character selections
          ;; PlayerLocked[] (global array) = lock states for
          ;; handicap calculation
          ;;
          ;; Output: All game state initialized for gameplay
          ;;
          ;; Mutates: playerX[], playerY[], playerState[],
          ;; PlayerHealth[], playerCharacter[],
          ;; PlayerTimers[], playerVelocityX[],
          ;; playerVelocityXL[],
          ;; playerVelocityYL[], playerSubpixelX[],
          ;; playerSubpixelY[],
          ;; PlayerDamage[], controllerStatus, missileActive,
          ;; PlayersEliminated,
          ;; PlayersRemaining, GameEndTimer,
          ;; EliminationCounter, EliminationOrder[],
          ;; WinnerPlayerIndex, DisplayRank,
          ;; GameState,
          ;; NUSIZ0, _NUSIZ1, NUSIZ2, NUSIZ3, frame, sprite
          ;; pointers, screen layout
          ;;
          ;; Called Routines: InitializeSpritePointers (bank14) - sets
          ;; sprite pointer addresses,
          ;; SetGameScreenLayout (bank7) - sets screen layout,
          ;; GetPlayerLocked (bank6) - accesses player lock sta

          ;; InitializeHealthBars (bank6) - initializes health bar
          ;; sta

          ;; LoadArena (bank16) - loads arena data
          ;;
          ;; Constraints: Must be colocated with Init4PlayerPositions,
          ;; InitPositionsDone,
          ;; PlayerHealthSet (all called via goto)
          ;; Entry point for game loop initialization
          ;; Initialize sprite pointers to RAM addresses
          ;; Ensure pointers are set before loading any sprite data
          ;; Cross-bank call to InitializeSpritePointers in bank 14
          lda # >(return_point-1)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(InitializeSpritePointers-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(InitializeSpritePointers-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 13
          jmp BS_jsr
return_point:


          ;; Set screen layout for gameplay (32×8 game layout) - inlined
          ;; TODO: pfrowheight = ScreenPfRowHeight
          ;; SuperChip variables var0-var15 available in gameplay
          ;; TODO: pfrows = ScreenPfRows

          ;; Initialize player positions
          ;; 2-Player Game: P1 at 1/3 width (53), P2 at 2/3 width (107)
          ;; 4-Player Game: P1 at 1/5 (32), P3 at 2/5 (64), P4 at 3/5
          ;; (96), P2 at 4 ÷ 5 (128)
          ;; All players start at second row from top (Y=24, center of
          ;; row 1)
          ;; Check if 4-player mode (Quadtari detected)
                    ;; if controllerStatus & SetQuadtariDetected then Init4PlayerPositions

          ;; 2-player mode positions
                    ;; let playerX[0] = 53 : playerY[0] = 24
          ;; lda # 0 (duplicate)
          asl
          tax
          ;; lda # 53 (duplicate)
          sta playerX,x
          ;; lda # 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta playerY,x (duplicate)
                    ;; let playerX[1] = 107 : playerY[1] = 24
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 107 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Players 3 & 4 use same as P1/P2 if not in 4-player mode
                    ;; let playerX[2] = 53 : playerY[2] = 24
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 53 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta playerY,x (duplicate)
                    ;; let playerX[3] = 107 : playerY[3] = 24
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 107 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; jmp InitPositionsDone (duplicate)

Init4PlayerPositions
          ;; Initialize player positions for 4-player mode
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: None (called from BeginGameLoop)
          ;;
          ;; Output: playerX[], playerY[] set for 4-player layout
          ;;
          ;; Mutates: playerX[], playerY[]
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with BeginGameLoop,
          ;; InitPositionsDone
          ;; 4-player mode positions
                    ;; let playerX[0] = 32 : playerY[0] = 24
          ;; Player 1: 1/5 width
                    ;; let playerX[2] = 64 : playerY[2] = 24
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 64 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda # 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Player 3: 2/5 width
                    ;; let playerX[3] = 96 : playerY[3] = 24
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 96 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda # 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Player 4: 3/5 width
                    ;; let playerX[1] = 128 : playerY[1] = 24
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 128 (duplicate)
          ;; sta playerX,x (duplicate)
          ;; lda # 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 24 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; Player 2: 4/5 width

InitPositionsDone
          ;; Player positions initialization complete
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
          ;; Constraints: Must be colocated with BeginGameLoop
          ;; Initialize player states (facing direction)
          ;; Player 1 facing right
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerState,x (duplicate)
          ;; Player 2 facing left
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerState,x (duplicate)
          ;; Player 3 facing right
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerState,x (duplicate)
          ;; Player 4 facing left
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerState,x (duplicate)

          ;; Initialize player health (apply handicap if selected)
          ;; PlayerLocked value: 0=unlocked, 1=normal (100% health),
          ;; Optimized: Simplified player health initialization
          ;; TODO: for currentPlayer = 0 to 3
          ;; lda currentPlayer (duplicate)
          ;; sta GPL_playerIndex (duplicate)
          ;; Cross-bank call to GetPlayerLocked in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerLocked-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; lda GPL_lockedState (duplicate)
          cmp PlayerHandicapped
          bne skip_9953
                    ;; let playerHealth[currentPlayer] = PlayerHealthHandicap : goto PlayerHealthInitDone
skip_9953:

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda PlayerHealthMax (duplicate)
          ;; sta playerHealth,x (duplicate)

PlayerHealthInitDone
.pend

next_label_1_L278:.proc

          ;; Initialize player timers
          ;; TODO: for currentPlayer = 0 to 3
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerTimers_W,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelX_W,x (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerSubpixelY_W,x (duplicate)
.pend

next_label_2_1_L314:.proc

          ;; Optimized: Set Players34Active flag based on character selections
          ;; lda controllerStatus (duplicate)
          and ClearPlayers34Active
          ;; sta controllerStatus (duplicate)
                    ;; if playerCharacter[2] = NoCharacter then goto skip_activation2
          ;; lda controllerStatus (duplicate)
          ora SetPlayers34Active
          ;; sta controllerStatus (duplicate)

skip_activation2:
                    ;; if playerCharacter[3] = NoCharacter then goto skip_activation3
          ;; lda controllerStatus (duplicate)
          ;; ora SetPlayers34Active (duplicate)
          ;; sta controllerStatus (duplicate)

skip_activation3:
          ;; Initialize missiles
          ;; missileActive uses bit flags: bit 0 = Player 0, bit 1 =
          ;; Player 1, bit 2 = Player 2, bit 3 = Player 3
          ;; lda # 0 (duplicate)
          ;; sta missileActive (duplicate)

          ;; Initialize remaining players count
          ;; lda # 1 (duplicate)
          ;; sta playersRemaining_W (duplicate)
          ;; CharacterSelectCheckReady guarantees Player 1 is active; seed count with P1
          ;; Will be calculated
          ;; lda # 0 (duplicate)
          ;; sta gameEndTimer_W (duplicate)
          ;; No game end countdown
          ;; lda # 0 (duplicate)
          ;; sta eliminationCounter_W (duplicate)
          ;; Reset elimination order counter

          ;; Initialize elimination order tracking
          ;; lda 0 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta eliminationOrder_W,x (duplicate)
          ;; lda 1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta eliminationOrder_W,x (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta eliminationOrder_W,x (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta eliminationOrder_W,x (duplicate)

          ;; Initialize win screen variables
          ;; lda # 255 (duplicate)
          ;; sta winnerPlayerIndex_W (duplicate)
          ;; No winner yet
          ;; lda # 0 (duplicate)
          ;; sta displayRank_W (duplicate)
          ;; No rank being displayed
          ;; lda # 0 (duplicate)
          ;; sta winScreenTimer_W (duplicate)
          ;; Reset win screen timer

          ;; Count additional human/CPU players beyond Player 1
                    ;; if playerCharacter[1] = NoCharacter then goto GLI_SkipPlayer2
          ;; lda playersRemaining_R (duplicate)
          clc
          adc # 1
          ;; sta playersRemaining_W (duplicate)

.pend

GLI_SkipPlayer2 .proc
                    ;; if playerCharacter[2] = NoCharacter then goto GLI_SkipPlayer3
          ;; lda playersRemaining_R (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta playersRemaining_W (duplicate)

.pend

GLI_SkipPlayer3 .proc
                    ;; if playerCharacter[3] = NoCharacter then goto SkipPlayer4
          ;; lda playersRemaining_R (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta playersRemaining_W (duplicate)

.pend

SkipPlayer4 .proc
          ;; Frame counter is automatically initialized and incremented
          ;; by batariBASIC kernel

          ;; Clear paused flag in systemFlags (initialize to normal play)
          ;; lda systemFlags (duplicate)
          ;; and ClearSystemFlagGameStatePaused (duplicate)
          ;; sta systemFlags (duplicate)

          ;; Initialize player sprite NUSIZ registers (double width)
          ;; NUSIZ = 5: double width, single copy
          ;; Player 0 (Player 1)
          NUSIZ0 = 5
          ;; Player 1 (Player 2) - multisprite kernel uses _NUSIZ1
          _NUSIZ1 = 5
          ;; Player 2 (Player 3) - multisprite kernel
          NUSIZ2 = 5
          ;; Player 3 (Player 4) - multisprite kernel
          NUSIZ3 = 5

          ;; Initialize health bars
          ;; Cross-bank call to InitializeHealthBars in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(InitializeHealthBars-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(InitializeHealthBars-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Load arena data
          ;; Cross-bank call to LoadArena in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadArena-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadArena-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          jsr BS_return
          ;; MainLoop will dispatch to GameMainLoop based on gameMode =
          ;; ModeGame

.pend

