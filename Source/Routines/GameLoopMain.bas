          rem ChaosFight - Source/Routines/GameLoopMain.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Game Loop - Main Loop
          rem Main gameplay loop that orchestrates all game systems.
          rem Called every frame during active gameplay.
          rem SEQUENCE PER FRAME:

ReadEnhancedButtons
          asm
ReadEnhancedButtons
end
          rem Read enhanced controller buttons (Genesis Button C, Joy2B+ Button II)
          rem Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)
          rem Stores button states in enhancedButtonStates for use throughout the frame
          rem
          rem Input: controllerStatus (global) = controller capabilities,
          rem INPT0-3 (hardware) = paddle port states
          rem
          rem Output: enhancedButtonStates_W = bit-packed button states
          rem (Bit 0=P1, Bit 1=P2, Bits 2-3=always 0)
          rem
          rem Mutates: enhancedButtonStates_W, temp1 (used for calculations)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be called early in game loop before input processing
          let temp1 = 0

          rem Player 1 (INPT0) - Genesis/Joy2b+ Button C/II
          if controllerStatus & SetLeftPortGenesis then if !INPT0{7} then temp1 = temp1 | 1
          if controllerStatus & SetLeftPortJoy2bPlus then if !INPT0{7} then temp1 = temp1 | 1

          rem Player 2 (INPT2) - Genesis/Joy2b+ Button C/II
          if controllerStatus & SetRightPortGenesis then if (INPT2 & $80) = 0 then temp1 = temp1 | 2
          if controllerStatus & SetRightPortJoy2bPlus then if (INPT2 & $80) = 0 then temp1 = temp1 | 2

          rem Players 3-4 cannot have enhanced controllers (require Quadtari)
          rem Bits 2-3 remain 0

          let enhancedButtonStates_W = temp1
          return

GameMainLoop
          asm
GameMainLoop

end
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
          rem HandleConsoleSwitches (bank13),
          rem   InputHandleAllPlayers (bank8), UpdateGuardTimers (bank6),
          rem   UpdateCharacterAnimations (bank11),
          rem   UpdatePlayerMovement (bank8), PhysicsApplyGravity (bank10),
          rem   ApplyMomentumAndRecovery (bank8),
          rem   CheckBoundaryCollisions (bank10),
          rem   CheckPlayfieldCollisionAllDirections (bank10),
          rem   CheckAllPlayerCollisions (bank8),
          rem   ProcessAllAttacks (bank7), CheckAllPlayerEliminations,
          rem   UpdateAllMissiles (bank7),
          rem   CheckRoboTitoStretchMissileCollisions (bank10), SetPlayerSprites (bank2),
          rem   DisplayHealth (bank6), UpdatePlayer12HealthBars (bank6),
          rem   UpdatePlayer34HealthBars (bank6), UpdateSoundEffect
          rem   (bank15)
          rem
          rem Constraints: Must be colocated with
          rem GameMainLoopQuadtariSkip, CheckGameEndTransition,
          rem              TransitionToWinner, GameEndCheckDone (all
          rem              called via goto)
          rem              Entry point for main gameplay loop (called
          rem              from MainLoop)
          rem Read enhanced controller buttons (Genesis Button C, Joy2B+
          gosub ReadEnhancedButtons
          rem   II/III)

          gosub HandleConsoleSwitches bank13 :
          rem Handle console switches (in Bank 13)

          rem Check if game is paused - skip movement/physics/animation if so
          if systemFlags & SystemFlagGameStatePaused then goto GameMainLoopPaused

          gosub InputHandleAllPlayers bank8 :
          rem Handle all player input (with Quadtari multiplexing) (in Bank 8)

          gosub UpdateGuardTimers bank6
          rem Update guard timers (duration and cooldown)

          gosub UpdateAttackCooldowns bank11
          rem Update attack cooldown timers

          gosub UpdateCharacterAnimations bank13
          rem Update animation system (10fps character animation) (in Bank 14)

          gosub UpdatePlayerMovement bank8 :
          rem Update movement system (full frame rate movement) (in Bank 11)

          gosub PhysicsApplyGravity bank10
          rem Apply gravity and physics (in Bank 11)

          gosub ApplyMomentumAndRecovery bank8
          rem Apply momentum and recovery effects (in Bank 8)

          gosub CheckBoundaryCollisions bank10
          rem Check boundary collisions (in Bank 10)

          rem Optimized: Single loop for playfield collisions (walls, ceilings, ground)
          for currentPlayer = 0 to 3
          if currentPlayer >= 2 then goto CheckQuadtariSkip
          goto ProcessCollision
CheckQuadtariSkip
          if controllerStatus & SetQuadtariDetected then goto ProcessCollision
          goto GameMainLoopQuadtariSkip
ProcessCollision
          gosub CheckPlayfieldCollisionAllDirections bank10
          rem Check for Radish Goblin bounce movement (ground and wall bounces)
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then gosub RadishGoblinCheckGroundBounce bank12
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then gosub RadishGoblinCheckWallBounce bank12
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

          gosub CheckAllPlayerCollisions bank11
          rem Check multi-player collisions (in Bank 11)

          gosub ProcessAllAttacks bank7
          rem Process melee and area attack collisions (in Bank 7)
          rem WIP #1146: Hook present while attack-state gating is implemented

          gosub CheckAllPlayerEliminations bank14
          rem Check for player eliminations

          gosub UpdateAllMissiles bank7
          rem Update missiles (in Bank 12)

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
          let gameEndTimer_W = gameEndTimer_R - 1
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

          gosub UpdateAllMissiles bank7
          rem Update missiles (in Bank 12)

          rem Check missile collisions (in Bank 7) - handled internally
          rem   by UpdateAllMissiles
          rem No separate CheckMissileCollisions call needed

          gosub CheckRoboTitoStretchMissileCollisions bank10
          rem Check RoboTito stretch missile collisions (bank 7)

          rem Set sprite positions (now handled by movement system)
          rem Call SetSpritePositions
          rem Replaced by UpdatePlayerMovement

          gosub SetPlayerSprites bank6
          rem Set sprite graphics (in Bank 6)

          gosub DisplayHealth bank11
          rem Display health information (in Bank 11)

          gosub UpdatePlayer12HealthBars bank11
          rem Update P1/P2 health bars using pfscore system

          gosub UpdatePlayer34HealthBars bank11
          rem Update P3/P4 health bars using playfield system

          gosub UpdateSoundEffect bank15
          rem Update sound effects (game mode 6 only)

          rem Frame counter is automatically incremented by batariBASIC
          rem kernel

GameMainLoopPaused
          rem Game is paused - skip all movement/physics/animation updates
          rem but still allow console switch handling for unpause
          return

