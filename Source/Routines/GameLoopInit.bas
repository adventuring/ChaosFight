          rem ChaosFight - Source/Routines/GameLoopInit.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem GAME LOOP INITIALIZATION
          rem =================================================================
          rem Initializes all game state for the main gameplay loop.
          rem Called once when entering gameplay from character select.

          rem INITIALIZES:
          rem   - Player positions, states, health, momentum
          rem   - Character types from selections
          rem   - Missiles and projectiles
          rem   - Frame counter and game state
          rem   - Level data

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
          rem =================================================================

BeginGameLoop
          rem Set screen layout for gameplay (32×8 game layout)
          gosub bank8 SetGameScreenLayout
          rem SuperChip variables var0-var15 available in gameplay
          
          rem Initialize player positions
          rem Note: If coming from Falling Animation, positions are already set at top of screen
          rem Only set default positions if not already initialized (check if Y is 0, which shouldn't happen)
          rem For now, preserve existing positions set by falling animation
          rem Falling animation sets players at Y=10 at quadrant X positions (40 or 120)
          rem Game mode gravity will handle falling from this position
          
          rem Initialize player states (facing direction)
          let PlayerState[0] = 1
          rem Player 1 facing right
          let PlayerState[1] = 0
          rem Player 2 facing left
          let PlayerState[2] = 1
          rem Player 3 facing right
          let PlayerState[3] = 0
          rem Player 4 facing left
          
          rem Initialize player health (apply handicap if selected)
          rem PlayerLocked value: 0=unlocked, 1=normal (100% health), 2=handicap (75% health)
          if PlayerLocked[0] = 2 then PlayerHealth[0] = 75 : goto Player0HealthSet
          let PlayerHealth[0] = 100
Player0HealthSet
          
          if PlayerLocked[1] = 2 then PlayerHealth[1] = 75 : goto Player1HealthSet
          let PlayerHealth[1] = 100
Player1HealthSet
          
          if PlayerLocked[2] = 2 then PlayerHealth[2] = 75 : goto Player2HealthSet
          let PlayerHealth[2] = 100
Player2HealthSet
          
          if PlayerLocked[3] = 2 then PlayerHealth[3] = 75 : goto Player3HealthSet
          let PlayerHealth[3] = 100
Player3HealthSet
          
          rem Initialize player timers
          let PlayerTimers[0] = 0
          let PlayerTimers[1] = 0
          let PlayerTimers[2] = 0
          let PlayerTimers[3] = 0
          
          rem Initialize player momentum
          let PlayerMomentumX[0] = 0
          let PlayerMomentumX[1] = 0
          let PlayerMomentumX[2] = 0
          let PlayerMomentumX[3] = 0
          
          rem Initialize player damage values
          let PlayerDamage[0] = 22
          let PlayerDamage[1] = 22
          let PlayerDamage[2] = 22
          let PlayerDamage[3] = 22
          
          rem Set character types from character select
          let PlayerChar[0] = selectedChar1
          let PlayerChar[1] = selectedChar2
          let PlayerChar[2] = selectedChar3
          let PlayerChar[3] = selectedChar4

          rem Update Players34Active flag based on character selections
          rem Flag is used for missile multiplexing (only multiplex when players 3 or 4 are active)
          let ControllerStatus = ControllerStatus & ClearPlayers34Active
          rem Clear flag first
          if selectedChar3 <> 255 then ControllerStatus = ControllerStatus | SetPlayers34Active
          rem Set if Player 3 selected
          if selectedChar4 <> 255 then ControllerStatus = ControllerStatus | SetPlayers34Active
          rem Set if Player 4 selected

          rem Initialize missiles
          rem MissileActive uses bit flags: bit 0 = Participant 1 (array [0]), bit 1 = Participant 2 (array [1]), bit 2 = Participant 3 (array [2]), bit 3 = Participant 4 (array [3])
          let MissileActive = 0

          rem Initialize elimination system
          let PlayersEliminated = 0  
          rem No players eliminated at start
          let PlayersRemaining = 0   
          rem Will be calculated
          let GameEndTimer = 0       
          rem No game end countdown
          let EliminationCounter = 0 
          rem Reset elimination order counter
          
          rem Initialize elimination order tracking
          let EliminationOrder[0] = 0
          let EliminationOrder[1] = 0  
          let EliminationOrder[2] = 0
          let EliminationOrder[3] = 0
          
          rem Initialize win screen variables
          let WinnerPlayerIndex = 255 
          rem No winner yet
          let DisplayRank = 0         
          rem No rank being displayed  
          let WinScreenTimer = 0      
          rem Reset win screen timer

          rem Count initial players
          if selectedChar1 <> 255 then PlayersRemaining = PlayersRemaining + 1
          if selectedChar2 <> 255 then PlayersRemaining = PlayersRemaining + 1  
          if selectedChar3 <> 255 then PlayersRemaining = PlayersRemaining + 1
          if selectedChar4 <> 255 then PlayersRemaining = PlayersRemaining + 1

          rem Initialize frame counter
          frame = 0

          rem Initialize game state
          let GameState = 0
          rem 0 = normal play, 1 = paused, 2 = game ending
          
          rem Initialize health bars
          gosub bank8 InitializeHealthBars

          rem Load level data
          gosub LoadLevel

          rem TODO: Replace def statements with regular subroutines
          rem batariBASIC may not support def statements with parameters

          rem Setup complete - return to ChangeGameMode
          rem MainLoop will dispatch to GameMainLoop each frame
          return

