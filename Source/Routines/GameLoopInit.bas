          rem ChaosFight - Source/Routines/GameLoopInit.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
#include "Source/Routines/PlayerLockedHelpers.bas"
          
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

          rem STATE FLAG DEFINITIONS (in PlayerState):
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
          rem Initialize all game state for the main gameplay loop
          rem
          rem Input: ControllerStatus (global) = controller detection
          rem state
          rem        SelectedCharacter1, SelectedCharacter2, selectedCharacter3_R,
          rem        selectedCharacter4_R (global) = character selections
          rem        PlayerLocked[] (global array) = lock states for
          rem        handicap calculation
          rem
          rem Output: All game state initialized for gameplay
          rem
          rem Mutates: PlayerX[], PlayerY[], PlayerState[],
          rem PlayerHealth[], PlayerCharacter[],
          rem         PlayerTimers[], playerVelocityX[],
          rem         playerVelocitySubpixelX[],
          rem         playerVelocitySubpixelY[], playerSubpixelX[],
          rem         playerSubpixelY[],
          rem         PlayerDamage[], ControllerStatus, MissileActive,
          rem         PlayersEliminated,
          rem         PlayersRemaining, GameEndTimer,
          rem         EliminationCounter, EliminationOrder[],
          rem         WinnerPlayerIndex, DisplayRank, WinScreenTimer,
          rem         GameState,
          rem         NUSIZ0, _NUSIZ1, NUSIZ2, NUSIZ3, frame, sprite
          rem         pointers, screen layout
          rem
          rem Called Routines: InitializeSpritePointers (bank10) - sets
          rem sprite pointer addresses,
          rem   SetGameScreenLayout (bank8) - sets screen layout,
          rem   GetPlayerLocked (bank14) - accesses player lock state,
          rem   InitializeHealthBars (bank8) - initializes health bar
          rem   state,
          rem   LoadArena (bank1) - loads arena data
          rem
          rem Constraints: Must be colocated with Init4PlayerPositions,
          rem InitPositionsDone,
          rem              PlayerHealthSet (all called via goto)
          rem              Entry point for game loop initialization
          rem Initialize sprite pointers to RAM addresses
          gosub InitializeSpritePointers bank10 : rem Ensure pointers are set before loading any sprite data
          
          gosub SetGameScreenLayout bank8 : rem Set screen layout for gameplay (32×8 game layout)
          rem SuperChip variables var0-var15 available in gameplay
          
          rem Initialize player positions
          rem 2-Player Game: P1 at 1/3 width (53), P2 at 2/3 width (107)
          rem 4-Player Game: P1 at 1/5 (32), P3 at 2/5 (64), P4 at 3/5
          rem   (96), P2 at 4/5 (128)
          rem All players start at second row from top (Y=24, center of
          rem   row 1)
          if ControllerStatus & SetQuadtariDetected then Init4PlayerPositions : rem Check if 4-player mode (Quadtari detected)
          
          let PlayerX[0] = 53 : PlayerY[0] = 24 : rem 2-player mode positions
          let PlayerX[1] = 107 : PlayerY[1] = 24
          let PlayerX[2] = 53 : PlayerY[2] = 24
          rem Players 3 & 4 use same as P1/P2 if not in 4-player mode
          let PlayerX[3] = 107 : PlayerY[3] = 24
          goto InitPositionsDone
          
Init4PlayerPositions
          rem Initialize player positions for 4-player mode
          rem
          rem Input: None (called from BeginGameLoop)
          rem
          rem Output: PlayerX[], PlayerY[] set for 4-player layout
          rem
          rem Mutates: PlayerX[], PlayerY[]
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with BeginGameLoop,
          rem InitPositionsDone
          let PlayerX[0] = 32 : PlayerY[0] = 24 : rem 4-player mode positions
          let PlayerX[2] = 64 : PlayerY[2] = 24 : rem Player 1: 1/5 width
          let PlayerX[3] = 96 : PlayerY[3] = 24 : rem Player 3: 2/5 width
          let PlayerX[1] = 128 : PlayerY[1] = 24 : rem Player 4: 3/5 width
          rem Player 2: 4/5 width
          
InitPositionsDone
          rem Player positions initialization complete
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
          let PlayerState[0] = 0 : rem Player 1 facing right
          let PlayerState[1] = 1 : rem Player 2 facing left
          let PlayerState[2] = 0 : rem Player 3 facing right
          let PlayerState[3] = 1 : rem Player 4 facing left
          
          rem Initialize player health (apply handicap if selected)
          rem PlayerLocked value: 0=unlocked, 1=normal (100% health),
          for currentPlayer = 0 to 3 : rem 2=handicap (75% health)
              let GPL_playerIndex = currentPlayer
              gosub GetPlayerLocked bank14
              if GPL_lockedState = PlayerHandicapped then let PlayerHealth[currentPlayer] = PlayerHealthHandicap
              if GPL_lockedState = PlayerHandicapped then goto PlayerHealthSet
              let PlayerHealth[currentPlayer] = PlayerHealthMax
PlayerHealthSet
          next
          rem Skip to next player after setting health
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
          
          for currentPlayer = 0 to 3 : rem Initialize player timers
              let playerTimers_W[currentPlayer] = 0
          next
          
          for currentPlayer = 0 to 3 : rem Initialize player velocity
              let playerVelocityX[currentPlayer] = 0
              let playerVelocitySubpixelX[currentPlayer] = 0
              let playerVelocitySubpixelY[currentPlayer] = 0
              let playerSubpixelX_W[currentPlayer] = 0
              let playerSubpixelY_W[currentPlayer] = 0
          next
          
          for currentPlayer = 0 to 3 : rem Initialize player damage values
              let playerDamage_W[currentPlayer] = 22
          next
          
          let PlayerCharacter[0] = SelectedCharacter1 : rem Set character types from character select
          let PlayerCharacter[1] = SelectedCharacter2
          let PlayerCharacter[2] = selectedCharacter3_R
          let PlayerCharacter[3] = selectedCharacter4_R

          rem Update Players34Active flag based on character selections
          rem Flag is used for missile multiplexing (only multiplex when
          let ControllerStatus  = ControllerStatus & ClearPlayers34Active : rem   players 3 or 4 are active)
          if !(SelectedCharacter3 = 255) then let ControllerStatus = ControllerStatus | SetPlayers34Active : rem Clear flag first
          if !(SelectedCharacter4 = 255) then let ControllerStatus = ControllerStatus | SetPlayers34Active : rem Set if Player 3 selected
          rem Set if Player 4 selected

          rem Initialize missiles
          rem MissileActive uses bit flags: bit 0 = Player 0, bit 1 =
          rem   Player 1, bit 2 = Player 2, bit 3 = Player 3
          let MissileActive  = 0

          let playersEliminated_W = 0 : rem Initialize elimination system
          let playersRemaining_W = 0 : rem No players eliminated at start
          let gameEndTimer_W = 0 : rem Will be calculated
          let eliminationCounter_W = 0 : rem No game end countdown
          rem Reset elimination order counter
          
          let eliminationOrder_W[0] = 0 : rem Initialize elimination order tracking
          let eliminationOrder_W[1] = 0
          let eliminationOrder_W[2] = 0
          let eliminationOrder_W[3] = 0
          
          let winnerPlayerIndex_W = 255 : rem Initialize win screen variables
          let displayRank_W = 0 : rem No winner yet
          let winScreenTimer_W = 0 : rem No rank being displayed
          rem Reset win screen timer

          if !(SelectedCharacter1 = 255) then let playersRemaining_W = playersRemaining_R + 1 : rem Count initial players
          if !(SelectedCharacter2 = 255) then let playersRemaining_W = playersRemaining_R + 1
          if !(selectedCharacter3_R = 255) then let playersRemaining_W = playersRemaining_R + 1
          if !(selectedCharacter4_R = 255) then let playersRemaining_W = playersRemaining_R + 1

          rem Frame counter is automatically initialized and incremented
          rem by batariBASIC kernel

          let GameState  = 0 : rem Initialize game state
          rem 0 = normal play, 1 = paused, 2 = game ending
          
          rem Initialize player sprite NUSIZ registers (double width)
          rem NUSIZ = 5: double width, single copy
          NUSIZ0 = 5
          rem Player 0 (Player 1)
          _NUSIZ1 = 5
          rem Player 1 (Player 2) - multisprite kernel uses _NUSIZ1
          NUSIZ2 = 5
          rem Player 2 (Player 3) - multisprite kernel
          NUSIZ3 = 5
          rem Player 3 (Player 4) - multisprite kernel

          gosub InitializeHealthBars bank8 : rem Initialize health bars

          gosub LoadArena bank1 : rem Load arena data

          return
          rem Gameplay state initialized - return to ChangeGameMode
          rem MainLoop will dispatch to GameMainLoop based on gameMode =
          rem   ModeGame

