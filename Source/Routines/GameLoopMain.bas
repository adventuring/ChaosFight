GameMainLoop
          rem
          rem ChaosFight - Source/Routines/GameLoopMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Game Loop - Main Loop
          rem Main gameplay loop that orchestrates all game systems.
          rem Called every frame during active gameplay.
          rem SEQUENCE PER FRAME:
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
          rem   systemFlags - Bit 4 (SystemFlagGameStatePaused): 0=normal, 1=paused
          rem Bit 3 (SystemFlagGameStateEnding): 0=normal, 1=ending
          rem   qtcontroller - Quadtari multiplexing state
          rem   All Player arrays (X, Y, State, Health, etc.)
          rem Main gameplay loop that orchestrates all game systems
          rem Input: All player state arrays, controller inputs, system flags
          rem Output: All game systems updated for one frame
          rem Mutates: All game state (players, missiles, animations, physics, etc.), frame counter
          rem Called Routines: ReadEnhancedButtons, HandleConsoleSwitches (bank14),
          rem   InputHandleAllPlayers (bank13), UpdateGuardTimers, UpdateCharacterAnimations (bank11),
          rem   UpdatePlayerMovement (bank13), PhysicsApplyGravity (bank8),
          rem   ApplyMomentumAndRecovery (bank8), ApplySpecialMovement (bank9),
          rem   CheckBoundaryCollisions (bank9), CheckPlayfieldCollisionAllDirections (bank9),
          rem   CheckAllPlayerCollisions (bank9), CheckAllPlayerEliminations,
          rem   UpdateAllMissiles (bank7),
          rem   CheckRoboTitoStretchMissileCollisions, SetPlayerSprites (bank8),
          rem   DisplayHealth (bank8), UpdatePlayer12HealthBars (bank8),
          rem   UpdatePlayer34HealthBars (bank8), UpdateSoundEffect (bank15)
          rem Constraints: Must be colocated with GameMainLoopQuadtariSkip, CheckGameEndTransition,
          rem              TransitionToWinner, GameEndCheckDone (all called via goto)
          rem              Entry point for main gameplay loop (called from MainLoop)
          rem Read enhanced controller buttons (Genesis Button C, Joy2B+
          gosub ReadEnhancedButtons : rem   II/III)
          
          gosub HandleConsoleSwitches bank14 : rem Handle console switches (in Bank 1)

          gosub InputHandleAllPlayers bank13 : rem Handle all player input (with Quadtari multiplexing) (in Bank 13)

          gosub UpdateGuardTimers : rem Update guard timers (duration and cooldown)

          gosub UpdateCharacterAnimations bank11 : rem Update animation system (10fps character animation) (in Bank 11)
          
          gosub UpdatePlayerMovement bank13 : rem Update movement system (full frame rate movement) (in Bank 13)

          gosub PhysicsApplyGravity bank8 : rem Apply gravity and physics (in Bank 8)
          
          gosub ApplyMomentumAndRecovery bank8 : rem Apply momentum and recovery effects (in Bank 8)

          gosub ApplySpecialMovement bank9 : rem Apply special movement physics (Bernie wrap, etc.) (in Bank 9)

          gosub CheckBoundaryCollisions bank9 : rem Check boundary collisions (in Bank 9)

          rem Check playfield collisions (walls, ceilings, ground) for
          for currentPlayer = 0 to 1 : rem   all players (in Bank 9)
              gosub CheckPlayfieldCollisionAllDirections bank9
          next
          if controllerStatus & SetQuadtariDetected = 0 then goto GameMainLoopQuadtariSkip
          for currentPlayer = 2 to 3
              gosub CheckPlayfieldCollisionAllDirections bank9
          next
GameMainLoopQuadtariSkip
          rem Skip 4-player collision checks (not in 4-player mode)
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with GameMainLoop

          gosub CheckAllPlayerCollisions bank9 : rem Check multi-player collisions (in Bank 9)

          gosub CheckAllPlayerEliminations : rem Check for player eliminations
          
          gosub UpdateAllMissiles bank7 : rem Update missiles (in Bank 7)
          
          rem Check if game should end and transition to winner screen
          rem   ending,
          rem systemFlags bit 3 (SystemFlagGameStateEnding) means game is
          if systemFlags & SystemFlagGameStateEnding then CheckGameEndTransition : rem   gameEndTimer counts down
          goto GameEndCheckDone
CheckGameEndTransition
          rem Check if game end timer should transition to winner screen
          rem Input: gameEndTimer (global) = game end countdown timer
          rem        systemFlags (global) = system flags including ending state
          rem Output: Dispatches to TransitionToWinner or GameEndCheckDone
          rem Mutates: gameEndTimer (decremented)
          rem Called Routines: None (dispatcher only)
          rem Constraints: Must be colocated with GameMainLoop, TransitionToWinner, GameEndCheckDone
          if gameEndTimer > 0 then let gameEndTimer = gameEndTimer - 1 : rem Decrement game end timer
          if gameEndTimer = 0 then TransitionToWinner : rem When timer reaches 0, transition to winner announcement
          goto GameEndCheckDone
TransitionToWinner
          rem Transition to winner announcement mode
          rem Input: None (called from CheckGameEndTransition)
          rem Output: gameMode set to ModeWinner, ChangeGameMode called
          rem Mutates: gameMode (global)
          rem Called Routines: ChangeGameMode (bank14) - accesses game mode state
          let gameMode = ModeWinner : rem Constraints: Must be colocated with GameMainLoop, CheckGameEndTransition
          gosub ChangeGameMode bank14
          return
GameEndCheckDone
          rem Game end check complete
          rem Input: None (label only, no execution)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Must be colocated with GameMainLoop

          gosub UpdateAllMissiles bank7 : rem Update missiles (in Bank 7)

          rem Check missile collisions (in Bank 7) - handled internally
          rem   by UpdateAllMissiles
          rem No separate CheckMissileCollisions call needed

          gosub CheckRoboTitoStretchMissileCollisions : rem Check RoboTito stretch missile collisions

          rem Set sprite positions (now handled by movement system)
          rem gosub SetSpritePositions 
          rem Replaced by UpdatePlayerMovement

          gosub SetPlayerSprites bank8 : rem Set sprite graphics (in Bank 8)

          gosub DisplayHealth bank8 : rem Display health information
          
          gosub UpdatePlayer12HealthBars bank8 : rem Update P1/P2 health bars using pfscore system
          
          gosub UpdatePlayer34HealthBars bank8 : rem Update P3/P4 health bars using playfield system
          
          gosub UpdateSoundEffect bank15 : rem Update sound effects (game mode 6 only)
          
          rem Frame counter is automatically incremented by batariBASIC kernel
          
          return

