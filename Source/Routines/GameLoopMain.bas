          rem ChaosFight - Source/Routines/GameLoopMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Game Loop - Main Loop
          rem Main gameplay loop that orchestrates all game systems.
          rem Called every frame during active gameplay.
          rem SEQUENCE PER FRAME:
GameMainLoop
          rem   1. Handle console switches (pause, reset, color)
          rem   2. Handle player input via PlayerInput.bas
          rem   3. Apply physics (gravity, momentum, collisions)
          rem   4. Apply special movement (character-specific)
          rem   5. Update attacks and check collisions
          rem   6. Update missiles
          rem   7. Set sprite positions
          rem   8. Render sprites
          rem   9. Display health
          rem   10. Draw screen
          rem AVAILABLE VARIABLES:
          rem   frame - Frame counter
          rem   systemFlags - Bit 4 (SystemFlagGameStatePaused):
          rem   0=normal, 1=paused
          rem Bit 3 (SystemFlagGameStateEnding): 0=normal, 1=ending
          rem   qtcontroller - Quadtari multiplexing state
          rem   All Player arrays (X, Y, State, Health, etc.)
          rem Main gameplay loop that orchestrates all game systems
          rem
          rem Input: All player state arrays, controller inputs, system
          rem flags
          rem
          rem Output: All game systems updated for one frame
          rem
          rem Mutates: All game state (players, missiles, animations,
          rem physics, etc.), frame counter
          rem
          rem Called Routines: ReadEnhancedButtons,
          rem HandleConsoleSwitches (bank14),
          rem   InputHandleAllPlayers (bank13), UpdateGuardTimers (bank14),
          rem   UpdateCharacterAnimations (bank11),
          rem   UpdatePlayerMovement (bank13), PhysicsApplyGravity (bank8),
          rem   ApplyMomentumAndRecovery (bank8), ApplySpecialMovement (bank8),
          rem   CheckBoundaryCollisions (bank8),
          rem   CheckPlayfieldCollisionAllDirections (bank8),
          rem   CheckAllPlayerCollisions (bank8),
          rem   CheckAllPlayerEliminations,
          rem   UpdateAllMissiles (bank7),
          rem   CheckRoboTitoStretchMissileCollisions, SetPlayerSprites (bank10),
          rem   DisplayHealth (bank8), UpdatePlayer12HealthBars (bank8),
          rem   UpdatePlayer34HealthBars (bank8), UpdateSoundEffect
          rem   (bank15)
          rem
          rem Constraints: Must be colocated with
          rem GameMainLoopQuadtariSkip, CheckGameEndTransition,
          rem              TransitionToWinner, GameEndCheckDone (all
          rem              called via goto)
          rem              Entry point for main gameplay loop (called
          rem              from MainLoop)
          rem Read enhanced controller buttons (Genesis Button C, Joy2B+
          gosub ReadEnhancedButtons : 
          rem   II/III)
          
          gosub HandleConsoleSwitches bank14 :
          rem Handle console switches (in Bank 14)

          rem Check if game is paused - skip movement/physics/animation if so
          if systemFlags & SystemFlagGameStatePaused then goto GameMainLoopPaused

          gosub InputHandleAllPlayers bank13 :
          rem Handle all player input (with Quadtari multiplexing) (in Bank 13)

          gosub UpdateGuardTimers bank14 : 
          rem Update guard timers (duration and cooldown)

          gosub UpdateCharacterAnimations bank11 : 
          rem Update animation system (10fps character animation) (in Bank 11)
          
          gosub UpdatePlayerMovement bank10 :
          rem Update movement system (full frame rate movement) (moved to Bank 10)

          gosub PhysicsApplyGravity bank8 : 
          rem Apply gravity and physics (in Bank 8)
          
          gosub ApplyMomentumAndRecovery bank8 : 
          rem Apply momentum and recovery effects (in Bank 8)

          gosub ApplySpecialMovement bank8 : 
          rem Apply special movement physics (Bernie wrap, etc.) (in Bank 8)

          gosub CheckBoundaryCollisions bank8 : 
          rem Check boundary collisions (in Bank 8)

          rem Optimized: Single loop for playfield collisions (walls, ceilings, ground)
          for currentPlayer = 0 to 3
              if currentPlayer >= 2 && !(controllerStatus & SetQuadtariDetected) then goto GameMainLoopQuadtariSkip
              gosub CheckPlayfieldCollisionAllDirections bank8
          next
GameMainLoopQuadtariSkip
          rem Skip 4-player collision checks (not in 4-player mode)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with GameMainLoop

          gosub CheckAllPlayerCollisions bank11 : 
          rem Check multi-player collisions (in Bank 11)

          gosub CheckAllPlayerEliminations : 
          rem Check for player eliminations
          
          gosub UpdateAllMissiles bank7 : 
          rem Update missiles (in Bank 7)
          
          rem Check if game should end and transition to winner screen
          rem   ending,
          rem systemFlags bit 3 (SystemFlagGameStateEnding) means game
          rem is
          rem gameEndTimer counts down
          if systemFlags & SystemFlagGameStateEnding then CheckGameEndTransition
          goto GameEndCheckDone
CheckGameEndTransition
          rem Check if game end timer should transition to winner screen
          rem
          rem Input: gameEndTimer (global) = game end countdown timer
          rem        systemFlags (global) = system flags including
          rem        ending state
          rem
          rem Output: Dispatches to TransitionToWinner or
          rem GameEndCheckDone
          rem
          rem Mutates: gameEndTimer (decremented)
          rem
          rem Called Routines: None (dispatcher only)
          rem
          rem Constraints: Must be colocated with GameMainLoop,
          rem TransitionToWinner, GameEndCheckDone
          rem When timer reaches 0, transition to winner announcement
          if gameEndTimer_R = 0 then TransitionToWinner
          let gameEndTimer_W = gameEndTimer_R - 1 : 
          rem Decrement game end timer
          goto GameEndCheckDone
TransitionToWinner
          rem Transition to winner announcement mode
          rem
          rem Input: None (called from CheckGameEndTransition)
          rem
          rem Output: gameMode set to ModeWinner, ChangeGameMode called
          rem
          rem Mutates: gameMode (global)
          rem
          rem Called Routines: ChangeGameMode (bank14) - accesses game
          rem mode state
          rem Constraints: Must be colocated with GameMainLoop, CheckGameEndTransition
          let gameMode = ModeWinner
          gosub ChangeGameMode bank14
          return
GameEndCheckDone
          rem Game end check complete
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with GameMainLoop

          gosub UpdateAllMissiles bank7 : 
          rem Update missiles (in Bank 7)

          rem Check missile collisions (in Bank 7) - handled internally
          rem   by UpdateAllMissiles
          rem No separate CheckMissileCollisions call needed

          gosub CheckRoboTitoStretchMissileCollisions : 
          rem Check RoboTito stretch missile collisions

          rem Set sprite positions (now handled by movement system)
          rem gosub SetSpritePositions 
          rem Replaced by UpdatePlayerMovement

          gosub SetPlayerSprites bank10 : 
          rem Set sprite graphics (in Bank 10)

          gosub DisplayHealth bank8 : 
          rem Display health information
          
          gosub UpdatePlayer12HealthBars bank8 : 
          rem Update P1/P2 health bars using pfscore system
          
          gosub UpdatePlayer34HealthBars bank8 : 
          rem Update P3/P4 health bars using playfield system
          
          gosub UpdateSoundEffect bank15 : 
          rem Update sound effects (game mode 6 only)
          
          rem Frame counter is automatically incremented by batariBASIC
          rem kernel

GameMainLoopPaused
          rem Game is paused - skip all movement/physics/animation updates
          rem but still allow console switch handling for unpause
          return

