          rem ChaosFight - Source/Routines/GameLoopMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem GAME LOOP - MAIN LOOP
          rem =================================================================
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
          rem   GameState - 0=normal, 1=paused
          rem   qtcontroller - Quadtari multiplexing state
          rem   All Player arrays (X, Y, State, Health, etc.)
          rem =================================================================

GameMainLoop
          rem Read enhanced controller buttons (Genesis Button C, Joy2B+ II/III)
          gosub ReadEnhancedButtons
          
          rem Handle console switches
          gosub HandleConsoleSwitches

          rem Handle all player input (with Quadtari multiplexing)
          gosub InputHandleAllPlayers

          rem Update animation system (10fps character animation)
          gosub UpdateCharacterAnimations
          
          rem Update movement system (full frame rate movement)
          gosub UpdatePlayerMovement

          rem Apply gravity and physics
          gosub PhysicsApplyGravity
          
          rem Apply momentum and recovery effects
          gosub ApplyMomentumAndRecovery

          rem Apply special movement physics (Bernie wrap, etc.)
          gosub ApplySpecialMovement

          rem Check boundary collisions
          gosub CheckBoundaryCollisions

          rem Check multi-player collisions
          gosub CheckAllPlayerCollisions

          rem Check for player eliminations
          gosub CheckAllPlayerEliminations

          rem Update attack cooldowns
          gosub UpdateAttackCooldowns

          rem Update missiles (in Bank 7)
          gosub bank7 UpdateAllMissiles

          rem Check missile collisions (in Bank 7) - handled internally by UpdateAllMissiles
          rem No separate CheckMissileCollisions call needed

          rem Set sprite positions (now handled by movement system)
          rem gosub SetSpritePositions 
          rem Replaced by UpdatePlayerMovement

          rem Set sprite graphics
          gosub SetPlayerSprites

          rem Display health information
          gosub DisplayHealth
          
          rem Update P1/P2 health bars using pfscore system
          gosub bank8 UpdatePlayer12HealthBars
          
          rem Update P3/P4 health bars using playfield system
          gosub bank8 UpdatePlayer34HealthBars

          rem Update frame counter
          frame = frame + 1

          return

