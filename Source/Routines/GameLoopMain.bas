          rem ChaosFight - Source/Routines/GameLoopMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem GAME LOOP - MAIN LOOP
          rem =================================================================
          rem Main gameplay loop that orchestrates all game systems.
          rem Called every frame during active gameplay.
          rem
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
          rem
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
          gosub HandleAllPlayerInput

          rem Apply gravity and physics
          gosub ApplyGravity
          
          rem Apply momentum and recovery effects
          gosub ApplyMomentumAndRecovery

          rem Apply special movement physics (Bernie wrap, etc.)
          gosub ApplySpecialMovement

          rem Check boundary collisions
          gosub CheckBoundaryCollisions

          rem Check multi-player collisions
          gosub CheckAllPlayerCollisions

          rem Update attack cooldowns
          gosub UpdateAttackCooldowns

          rem Update missiles
          gosub UpdateMissiles

          rem Check missile collisions
          gosub CheckMissileCollisions

          rem Set sprite positions
          gosub SetSpritePositions

          rem Set sprite graphics
          gosub SetPlayerSprites

          rem Display health information
          gosub DisplayHealth

          rem Update frame counter
          frame = frame + 1

          rem Draw screen
          drawscreen
          goto GameMainLoop

