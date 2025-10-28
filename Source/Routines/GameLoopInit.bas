          rem ChaosFight - Source/Routines/GameLoopInit.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem GAME LOOP INITIALIZATION
          rem =================================================================
          rem Initializes all game state for the main gameplay loop.
          rem Called once when entering gameplay from character select.
          rem
          rem INITIALIZES:
          rem   - Player positions, states, health, momentum
          rem   - Character types from selections
          rem   - Missiles and projectiles
          rem   - Frame counter and game state
          rem   - Level data
          rem
          rem STATE FLAG DEFINITIONS (in PlayerState):
          rem   Bit 0: Facing (1 = right, 0 = left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (hitstun)
          rem   Bits 4-7: Animation state (0-15)
          rem
          rem ANIMATION STATES:
          rem   0=Standing right, 1=Idle, 2=Guarding, 3=Walking/running,
          rem   4=Coming to stop, 5=Taking hit, 6=Falling backwards,
          rem   7=Falling down, 8=Fallen down, 9=Recovering,
          rem   10=Jumping, 11=Falling, 12=Landing, 13-15=Reserved
          rem =================================================================

GameLoop
          const pfres = 8
          rem SuperChip variables var0-var15 available in gameplay
          
          rem Initialize player positions
          PlayerX[0] = 40 : PlayerY[0] = 80
          PlayerX[1] = 120 : PlayerY[1] = 80
          PlayerX[2] = 80 : PlayerY[2] = 80
          PlayerX[3] = 100 : PlayerY[3] = 80
          
          rem Initialize player states (facing direction)
          PlayerState[0] = 1 : rem Player 1 facing right
          PlayerState[1] = 0 : rem Player 2 facing left
          PlayerState[2] = 1 : rem Player 3 facing right
          PlayerState[3] = 0 : rem Player 4 facing left
          
          rem Initialize player health (apply handicap if selected)
          rem PlayerLocked value: 0=unlocked, 1=normal (100% health), 2=handicap (75% health)
          if PlayerLocked[0] = 2 then
                    PlayerHealth[0] = 75  : rem 25% handicap
          else
                    PlayerHealth[0] = 100
          endif
          
          if PlayerLocked[1] = 2 then
                    PlayerHealth[1] = 75  : rem 25% handicap
          else
                    PlayerHealth[1] = 100
          endif
          
          if PlayerLocked[2] = 2 then
                    PlayerHealth[2] = 75  : rem 25% handicap
          else
                    PlayerHealth[2] = 100
          endif
          
          if PlayerLocked[3] = 2 then
                    PlayerHealth[3] = 75  : rem 25% handicap
          else
                    PlayerHealth[3] = 100
          endif
          
          rem Initialize player timers
          PlayerTimers[0] = 0
          PlayerTimers[1] = 0
          PlayerTimers[2] = 0
          PlayerTimers[3] = 0
          
          rem Initialize player momentum
          PlayerMomentumX[0] = 0
          PlayerMomentumX[1] = 0
          PlayerMomentumX[2] = 0
          PlayerMomentumX[3] = 0
          
          rem Initialize player damage values
          PlayerDamage[0] = 22
          PlayerDamage[1] = 22
          PlayerDamage[2] = 22
          PlayerDamage[3] = 22
          
          rem Set character types from character select
          PlayerChar[0] = SelectedChar1
          PlayerChar[1] = SelectedChar2
          PlayerChar[2] = SelectedChar3
          PlayerChar[3] = SelectedChar4

          rem Initialize missiles
          Missile1Active = 0
          Missile2Active = 0

          rem Initialize elimination system
          PlayersEliminated = 0   : rem No players eliminated at start
          PlayersRemaining = 0    : rem Will be calculated
          GameEndTimer = 0        : rem No game end countdown

          rem Count initial players
          if SelectedChar1 != 0 then PlayersRemaining = PlayersRemaining + 1
          if SelectedChar2 != 0 then PlayersRemaining = PlayersRemaining + 1  
          if SelectedChar3 != 0 then PlayersRemaining = PlayersRemaining + 1
          if SelectedChar4 != 0 then PlayersRemaining = PlayersRemaining + 1

          rem Initialize frame counter
          frame = 0

          rem Initialize game state
          GameState = 0 : rem 0 = normal play, 1 = paused, 2 = game ending

          rem Load level data
          gosub LoadLevel

          rem Define bit flag helper functions
          def SetPlayerAttacking(playerState) = playerState | 1
          def SetPlayerGuarding(playerState) = playerState | 2
          def SetPlayerJumping(playerState) = playerState | 4
          def SetPlayerRecovery(playerState) = playerState | 8

          def ClearPlayerAttacking(playerState) = playerState & ~1
          def ClearPlayerGuarding(playerState) = playerState & ~2
          def ClearPlayerJumping(playerState) = playerState & ~4
          def ClearPlayerRecovery(playerState) = playerState & ~8

          def IsPlayerAttacking(playerState) = playerState & 1
          def IsPlayerGuarding(playerState) = playerState & 2
          def IsPlayerJumping(playerState) = playerState & 4
          def IsPlayerRecovery(playerState) = playerState & 8

          def GetPlayerAnimState(playerState) = (playerState >> 4) & 15
          def SetPlayerAnimState(playerState, animState) = (playerState & ~240) | (animState << 4)

          rem Fall through to main loop
          goto GameMainLoop

