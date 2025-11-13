          rem ChaosFight - Source/Routines/FallingAnimation.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Falling In Animation - Per-frame Loop
          rem Moves players from quadrant staging positions to arena row 2.

FallingAnimation1
          rem Moves active players from quadrant spawn points to row 2 starting positions
          rem Called each frame while gameMode = ModeFallingAnimation1
          rem Flow:
          rem   1. Move each active player toward their target position
          rem   2. Track completion count
          rem   3. Transition to game mode when all players arrive
          rem Input: playerCharacter[] (global array) = character selections
          rem        controllerStatus (global) = controller detection
          rem        state
          rem        fallFrame (global) = animation frame counter
          rem        fallComplete (global) = count of players who
          rem        reached target
          rem        activePlayers (global) = number of active players
          rem
          rem Output: Dispatches to FallingComplete1 or returns
          rem
          rem Mutates: fallFrame (incremented, wraps at 4), fallComplete
          rem (incremented per player),
          rem         playerX[], playerY[] (updated via
          rem         MovePlayerToTarget)
          rem
          rem Called Routines: MovePlayerToTarget - accesses player
          rem positions, target positions,
          rem   SetSpritePositions (bank6) - accesses player positions,
          rem   SetPlayerSprites (bank6) - accesses character sprites,
          rem   BeginGameLoop (bank11) - initializes game state,
          rem   ChangeGameMode (bank14) - accesses game mode state
          rem
          rem Constraints: Must be colocated with Player1Target4P,
          rem Player1TargetDone, DonePlayer1Move,
          rem              Player2Target4P, Player2TargetDone,
          rem              DonePlayer2Move, DonePlayer3Move,
          rem              DonePlayer4Move, FallingComplete1 (all called
          rem              via goto)
          rem Entry point for falling animation mode (called from MainLoop)
          let fallFrame = fallFrame + 1
          rem Update animation frame
          if fallFrame > 3 then let fallFrame = 0

          rem Move Player 1 from quadrant to target (if active)

          if playerCharacter[0] = NoCharacter then DonePlayer1Move
          rem playerIndex = 0 (player index), targetX = target X,
          let temp1 = 0
          rem targetY = target Y (24)
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player1Target4P
          let temp2 = 53
          rem 2-player mode: target X = 53
          goto Player1TargetDone
Player1Target4P
          rem Set Player 1 target X for 4-player mode
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: temp2 set to 32
          rem
          rem Mutates: temp2
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1,
          rem Player1TargetDone
          let temp2 = 32
          rem 4-player mode: target X = 32
Player1TargetDone
          rem Player 1 target calculation complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with FallingAnimation1
          let temp3 = 24
          gosub MovePlayerToTarget bank12
          if temp4 then let fallComplete = fallComplete + 1
DonePlayer1Move
          rem reached = 1 if reached target
          rem Player 1 movement complete (skipped if not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1

          rem Move Player 2 from quadrant to target (if active)

          if playerCharacter[1] = NoCharacter then DonePlayer2Move
          let temp1 = 1
          rem Check if 4-player mode for target X
          if controllerStatus & SetQuadtariDetected then Player2Target4P
          let temp2 = 107
          rem 2-player mode: target X = 107
          goto Player2TargetDone
Player2Target4P
          rem Set Player 2 target X for 4-player mode
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: temp2 set to 128
          rem
          rem Mutates: temp2
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1,
          rem Player2TargetDone
          let temp2 = 128
          rem 4-player mode: target X = 128
Player2TargetDone
          rem Player 2 target calculation complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem Constraints: Must be colocated with FallingAnimation1
          let temp3 = 24
          gosub MovePlayerToTarget bank12
          if temp4 then let fallComplete = fallComplete + 1
DonePlayer2Move
          rem Player 2 movement complete (skipped if not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1

          rem Move Player 3 from quadrant to target (if active)

          if (controllerStatus & SetQuadtariDetected) = 0 then DonePlayer3Move
          if playerCharacter[2] = NoCharacter then DonePlayer3Move
          let temp1 = 2
          let temp2 = 64
          rem 4-player mode: target X = 64
          let temp3 = 24
          gosub MovePlayerToTarget bank12
          if temp4 then let fallComplete = fallComplete + 1
DonePlayer3Move
          rem Player 3 movement complete (skipped if not in 4-player
          rem mode or not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1

          rem Move Player 4 from quadrant to target (if active)

          if (controllerStatus & SetQuadtariDetected) = 0 then DonePlayer4Move
          if playerCharacter[3] = NoCharacter then DonePlayer4Move
          let temp1 = 3
          let temp2 = 96
          rem 4-player mode: target X = 96
          let temp3 = 24
          gosub MovePlayerToTarget bank12
          if temp4 then let fallComplete = fallComplete + 1
DonePlayer4Move
          rem Player 4 movement complete (skipped if not in 4-player
          rem mode or not active)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with FallingAnimation1

          rem Check if all players have reached their targets

          if fallComplete >= activePlayers then FallingComplete1

          rem Set sprite positions and load character sprites
          rem   dynamically
          rem Use dynamic sprite setting instead of relying on player
          gosub SetSpritePositions bank6
          rem   declarations
          gosub SetPlayerSprites bank8

          rem drawscreen called by MainLoop
          return
          goto FallingAnimation1

FallingComplete1
          rem All players have reached row 2 positions
          rem
          rem Input: None (called from FallingAnimation1)
          rem
          rem Output: gameMode set to ModeGame, BeginGameLoop and
          rem ChangeGameMode called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: BeginGameLoop (bank11) - accesses game
          rem state,
          rem   ChangeGameMode (bank14) - accesses game mode state
          rem
          rem Constraints: Must be colocated with FallingAnimation1
          rem All players have reached row 2 positions
          rem Call BeginGameLoop to initialize game state before
          rem   switching modes
          rem Note: BeginGameLoop will use final positions from falling
          gosub BeginGameLoop bank11
          rem   animation
          let gameMode = ModeGame
          rem Transition to Game Mode
          gosub ChangeGameMode bank14
          return

