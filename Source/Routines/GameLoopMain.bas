          rem ChaosFight - Source/Routines/GameLoopMain.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem Game Loop - Main Loop
          rem Main gameplay loop that orchestrates all game systems.
          rem Called every frame during active gameplay.
          rem SEQUENCE PER FRAME:

ReadEnhancedButtons
          rem Returns: Near (return thisbank)
          asm

ReadEnhancedButtons

end
          rem Read enhanced controller buttons (Genesis Button C, Joy2B+ Button II)
          rem Returns: Near (return thisbank)
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
          return thisbank

GameMainLoop
          rem Returns: Far (return otherbank)
          asm

GameMainLoop



end
          rem   1. Handle console switches (pause, reset, color)
          rem Returns: Far (return otherbank)
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
          rem   UpdateCharacterAnimations (bank12),
          rem   UpdatePlayerMovement (bank8), PhysicsApplyGravity (bank13),
          rem   ApplyMomentumAndRecovery (bank8),
          rem   CheckBoundaryCollisions (bank10),
          rem   CheckPlayfieldCollisionAllDirections (bank10),
          rem   CheckAllPlayerCollisions (bank8),
          rem   ProcessAllAttacks (bank7), CheckAllPlayerEliminations (bank14),
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
          rem CRITICAL: Guard against being called in wrong game mode
          rem This prevents crashes when gameMode is corrupted or incorrectly set
          rem Only run game logic when actually in game mode (ModeGame = 6)
          if gameMode = ModeGame then goto GameMainLoopContinue

          return otherbank

GameMainLoopContinue
          rem OVSCAN HANDLER: Input reading and sound updates only
          rem Heavy game logic moved to vblank handler (VblankModeGameMain)
          rem This runs during overscan period before drawscreen is called

          rem Read enhanced controller buttons (Genesis Button C, Joy2B+
          rem   II/III)
          gosub ReadEnhancedButtons

          rem Handle console switches (in Bank 13)
          gosub HandleConsoleSwitches bank13 :

          rem Handle all player input (with Quadtari multiplexing) (in Bank 8)
          gosub InputHandleAllPlayers bank8 :

          rem Update guard timers (duration and cooldown)
          gosub UpdateGuardTimers bank6

          rem Update attack cooldown timers (in Bank 12)
          gosub UpdateAttackCooldowns bank12

          rem Issue #1177: Update Frooty charge system every frame
          for currentPlayer = 0 to 3
            if currentPlayer >= 2 then goto FrootyChargeQuadtariCheck

            goto FrootyChargeUpdate

FrootyChargeQuadtariCheck
            if (controllerStatus & SetQuadtariDetected) = 0 then goto FrootyChargeNext

FrootyChargeUpdate
            if playerCharacter[currentPlayer] = CharacterFrooty then gosub FrootyAttack bank8

FrootyChargeNext
          next

          rem Update sound effects (game mode 6 only)
          rem Sound updates must happen in overscan so they are ready for vblank
          gosub UpdateSoundEffect bank15

          rem Heavy game logic (physics, collisions, rendering) moved to vblank handler
          rem This allows better time distribution: overscan for input/sound, vblank for logic
          rem Vblank handler is called from kernel vblank_bB_code hook during vblank period

          rem Frame counter is automatically incremented by batariBASIC
          rem kernel
          rem Note: Heavy game logic (physics, collisions, rendering) is now handled
          rem in vblank handler (VblankModeGameMain) for better time distribution
          return otherbank

GameMainLoopPaused
          rem Game is paused - skip all movement/physics/animation updates
          rem Returns: Far (return otherbank)
          rem but still allow console switch handling for unpause
          rem Vblank handler will also check pause state and skip logic
          return otherbank
