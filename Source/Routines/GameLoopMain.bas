          rem ChaosFight - Source/Routines/GameLoopMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem GAME LOOP - MAIN LOOP
          rem ==========================================================
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
          rem ==========================================================

GameMainLoop
          rem Read enhanced controller buttons (Genesis Button C, Joy2B+
          rem   II/III)
          gosub ReadEnhancedButtons
          
          rem Handle console switches (in Bank 14)
          gosub bank14 HandleConsoleSwitches

          rem Handle all player input (with Quadtari multiplexing) (in Bank 13)
          gosub bank13 InputHandleAllPlayers

          rem Update guard timers (duration and cooldown)
          gosub UpdateGuardTimers

          rem Update animation system (10fps character animation) (in Bank 11)
          gosub bank11 UpdateCharacterAnimations
          
          rem Update movement system (full frame rate movement) (in Bank 13)
          gosub bank13 UpdatePlayerMovement

          rem Apply gravity and physics (in Bank 8)
          gosub bank8 PhysicsApplyGravity
          
          rem Apply momentum and recovery effects (in Bank 8)
          gosub bank8 ApplyMomentumAndRecovery

          rem Apply special movement physics (Bernie wrap, etc.) (in Bank 9)
          gosub bank9 ApplySpecialMovement

          rem Check boundary collisions (in Bank 9)
          gosub bank9 CheckBoundaryCollisions

          rem Check playfield collisions (walls, ceilings, ground) for
          rem   all players (in Bank 9)
          for currentPlayer = 0 to 1
              gosub bank9 CheckPlayfieldCollisionAllDirections
          next
          if controllerStatus & SetQuadtariDetected = 0 then goto GameMainLoopQuadtariSkip
          for currentPlayer = 2 to 3
              gosub bank9 CheckPlayfieldCollisionAllDirections
          next
GameMainLoopQuadtariSkip

          rem Check multi-player collisions (in Bank 9)
          gosub bank9 CheckAllPlayerCollisions

          rem Check for player eliminations
          gosub CheckAllPlayerEliminations
          
          rem Check if game should end and transition to winner screen
          rem   ending,
          rem systemFlags bit 3 (SystemFlagGameStateEnding) means game is
          rem   gameEndTimer counts down
          if systemFlags & SystemFlagGameStateEnding then CheckGameEndTransition
          goto GameEndCheckDone
CheckGameEndTransition
          rem Decrement game end timer
          if gameEndTimer > 0 then let gameEndTimer = gameEndTimer - 1
          rem When timer reaches 0, transition to winner announcement
          if gameEndTimer = 0 then TransitionToWinner
          goto GameEndCheckDone
TransitionToWinner
          rem Transition to winner announcement mode
          let gameMode = ModeWinner
          gosub bank14 ChangeGameMode
          return
GameEndCheckDone

          rem Update attack cooldowns (in Bank 7)
          gosub bank7 UpdateAttackCooldowns

          rem Update missiles (in Bank 7)
          gosub bank7 UpdateAllMissiles

          rem Check missile collisions (in Bank 7) - handled internally
          rem   by UpdateAllMissiles
          rem No separate CheckMissileCollisions call needed

          rem Check RoboTito stretch missile collisions
          gosub CheckRoboTitoStretchMissileCollisions

          rem Set sprite positions (now handled by movement system)
          rem gosub SetSpritePositions 
          rem Replaced by UpdatePlayerMovement

          rem Set sprite graphics (in Bank 8)
          gosub bank8 SetPlayerSprites

          rem Display health information
          gosub bank8 DisplayHealth
          
          rem Update P1/P2 health bars using pfscore system
          gosub bank8 UpdatePlayer12HealthBars
          
          rem Update P3/P4 health bars using playfield system
          gosub bank8 UpdatePlayer34HealthBars
          
          rem Update sound effects (game mode 6 only)
          gosub bank15 UpdateSoundEffect
          
          rem Update frame counter
          frame = frame + 1
          
          return

