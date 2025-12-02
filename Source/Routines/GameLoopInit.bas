          rem ChaosFight - Source/Routines/GameLoopInit.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem Game Loop Initialization
          rem Initializes all game state for the main gameplay loop.
          rem Called once when entering gameplay from character select.
          rem INITIALIZES:
          rem   - Player positions, states, health, momentum
          rem   - Character types from selections
          rem   - Missiles and projectiles
          rem   - Frame counter and game state
          rem   - Arena data
          rem STATE FLAG DEFINITIONS (in playerState):
          rem   Bit 0: Facing (1 = right, 0 = left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (hitstun)
          rem   Bits 4-7: Animation state (0-15)
          rem ANIMATION STATES:
          rem   0=Standing right, 1=Idle, 2=Guarding, 3=Walking/running,
          rem   4=Coming to stop, 5=Taking hit, 6=Falling backwards,
          rem   7=Falling down, 8=Fallen down, 9=Recovering,
          rem   10=Jumping, 11=Falling, 12=Landing, 13-15=Reserved

BeginGameLoop
          rem Returns: Far (return otherbank)
          asm

BeginGameLoop



end
          rem Initialize all game state for the main gameplay loop
          rem Returns: Far (return otherbank)
          rem
          rem Input: controllerStatus (global) = controller detection
          rem state
          rem        playerCharacter[] (global array) = character selections
          rem        PlayerLocked[] (global array) = lock states for
          rem        handicap calculation
          rem
          rem Output: All game state initialized for gameplay
          rem
          rem Mutates: playerX[], playerY[], playerState[],
          rem PlayerHealth[], playerCharacter[],
          rem         PlayerTimers[], playerVelocityX[],
          rem         playerVelocityXL[],
          rem         playerVelocityYL[], playerSubpixelX[],
          rem         playerSubpixelY[],
          rem         PlayerDamage[], controllerStatus, missileActive,
          rem         PlayersEliminated,
          rem         PlayersRemaining, GameEndTimer,
          rem         EliminationCounter, EliminationOrder[],
          rem         WinnerPlayerIndex, DisplayRank,
          rem         GameState,
          rem         NUSIZ0, _NUSIZ1, NUSIZ2, NUSIZ3, frame, sprite
          rem         pointers, screen layout
          rem
          rem Called Routines: InitializeSpritePointers (bank14) - sets
          rem sprite pointer addresses,
          rem   SetGameScreenLayout (bank7) - sets screen layout,
          rem   GetPlayerLocked (bank6) - accesses player lock state,
          rem   InitializeHealthBars (bank6) - initializes health bar
          rem   state,
          rem   LoadArena (bank16) - loads arena data
          rem
          rem Constraints: Must be colocated with Init4PlayerPositions,
          rem InitPositionsDone,
          rem              PlayerHealthSet (all called via goto)
          rem              Entry point for game loop initialization
          rem Initialize sprite pointers to RAM addresses
          rem Ensure pointers are set before loading any sprite data
          gosub InitializeSpritePointers bank14

          rem Set screen layout for gameplay (32×8 game layout) - inlined
          pfrowheight = ScreenPfRowHeight
          rem SuperChip variables var0-var15 available in gameplay
          pfrows = ScreenPfRows

          rem Initialize player positions
          rem 2-Player Game: P1 at 1/3 width (53), P2 at 2/3 width (107)
          rem 4-Player Game: P1 at 1/5 (32), P3 at 2/5 (64), P4 at 3/5
          rem   (96), P2 at 4 ÷ 5 (128)
          rem All players start at second row from top (Y=24, center of
          rem   row 1)
          rem Check if 4-player mode (Quadtari detected)
          if controllerStatus & SetQuadtariDetected then Init4PlayerPositions

          rem 2-player mode positions
          let playerX[0] = 53 : playerY[0] = 24
          let playerX[1] = 107 : playerY[1] = 24
          rem Players 3 & 4 use same as P1/P2 if not in 4-player mode
          let playerX[2] = 53 : playerY[2] = 24
          let playerX[3] = 107 : playerY[3] = 24
          goto InitPositionsDone

Init4PlayerPositions
          rem Initialize player positions for 4-player mode
          rem Returns: Far (return otherbank)
          rem
          rem Input: None (called from BeginGameLoop)
          rem
          rem Output: playerX[], playerY[] set for 4-player layout
          rem
          rem Mutates: playerX[], playerY[]
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with BeginGameLoop,
          rem InitPositionsDone
          rem 4-player mode positions
          let playerX[0] = 32 : playerY[0] = 24
          rem Player 1: 1/5 width
          let playerX[2] = 64 : playerY[2] = 24
          rem Player 3: 2/5 width
          let playerX[3] = 96 : playerY[3] = 24
          rem Player 4: 3/5 width
          let playerX[1] = 128 : playerY[1] = 24
          rem Player 2: 4/5 width

InitPositionsDone
          rem Player positions initialization complete
          rem Returns: Far (return otherbank)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with BeginGameLoop
          rem Initialize player states (facing direction)
          rem Player 1 facing right
          let playerState[0] = 0
          rem Player 2 facing left
          let playerState[1] = 1
          rem Player 3 facing right
          let playerState[2] = 0
          rem Player 4 facing left
          let playerState[3] = 1

          rem Initialize player health (apply handicap if selected)
          rem PlayerLocked value: 0=unlocked, 1=normal (100% health),
          rem Optimized: Simplified player health initialization
          for currentPlayer = 0 to 3
          let GPL_playerIndex = currentPlayer
          gosub GetPlayerLocked bank6

          if GPL_lockedState = PlayerHandicapped then let playerHealth[currentPlayer] = PlayerHealthHandicap : goto PlayerHealthInitDone

          let playerHealth[currentPlayer] = PlayerHealthMax

PlayerHealthInitDone
          next

          rem Initialize player timers
          for currentPlayer = 0 to 3
          let playerTimers_W[currentPlayer] = 0
          let playerVelocityX[currentPlayer] = 0
          let playerVelocityXL[currentPlayer] = 0
          let playerVelocityYL[currentPlayer] = 0
          let playerSubpixelX_W[currentPlayer] = 0
          let playerSubpixelY_W[currentPlayer] = 0
          next

          rem Optimized: Set Players34Active flag based on character selections
          let controllerStatus = controllerStatus & ClearPlayers34Active
          if playerCharacter[2] = NoCharacter then goto skip_activation2

          let controllerStatus = controllerStatus | SetPlayers34Active

skip_activation2
          if playerCharacter[3] = NoCharacter then goto skip_activation3

          let controllerStatus = controllerStatus | SetPlayers34Active

skip_activation3
          rem Initialize missiles
          rem missileActive uses bit flags: bit 0 = Player 0, bit 1 =
          rem   Player 1, bit 2 = Player 2, bit 3 = Player 3
          let missileActive  = 0

          rem Initialize remaining players count
          let playersRemaining_W = 1
          rem CharacterSelectCheckReady guarantees Player 1 is active; seed count with P1
          rem Will be calculated
          let gameEndTimer_W = 0
          rem No game end countdown
          let eliminationCounter_W = 0
          rem Reset elimination order counter

          rem Initialize elimination order tracking
          let eliminationOrder_W[0] = 0
          let eliminationOrder_W[1] = 0
          let eliminationOrder_W[2] = 0
          let eliminationOrder_W[3] = 0

          rem Initialize win screen variables
          let winnerPlayerIndex_W = 255
          rem No winner yet
          let displayRank_W = 0
          rem No rank being displayed
          let winScreenTimer_W = 0
          rem Reset win screen timer

          rem Count additional human/CPU players beyond Player 1
          if playerCharacter[1] = NoCharacter then goto GLI_SkipPlayer2

          let playersRemaining_W = playersRemaining_R + 1

GLI_SkipPlayer2
          if playerCharacter[2] = NoCharacter then goto GLI_SkipPlayer3

          let playersRemaining_W = playersRemaining_R + 1

GLI_SkipPlayer3
          if playerCharacter[3] = NoCharacter then goto SkipPlayer4

          let playersRemaining_W = playersRemaining_R + 1

SkipPlayer4
          rem Frame counter is automatically initialized and incremented
          rem by batariBASIC kernel

          rem Clear paused flag in systemFlags (initialize to normal play)
          let systemFlags = systemFlags & ClearSystemFlagGameStatePaused

          rem Initialize player sprite NUSIZ registers (double width)
          rem NUSIZ = 5: double width, single copy
          rem Player 0 (Player 1)
          NUSIZ0 = 5
          rem Player 1 (Player 2) - multisprite kernel uses _NUSIZ1
          _NUSIZ1 = 5
          rem Player 2 (Player 3) - multisprite kernel
          NUSIZ2 = 5
          rem Player 3 (Player 4) - multisprite kernel
          NUSIZ3 = 5

          rem Initialize health bars
          gosub InitializeHealthBars bank6

          rem Load arena data
          gosub LoadArena bank16

          return otherbank          rem Gameplay state initialized - return to ChangeGameMode
          rem MainLoop will dispatch to GameMainLoop based on gameMode =
          rem   ModeGame
