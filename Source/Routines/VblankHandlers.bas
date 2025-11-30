          rem ChaosFight - Source/Routines/VblankHandlers.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Vblank Handler Dispatcher
          rem Handles mode-specific logic during vblank period
          rem Called from kernel vblank_bB_code hook via JSR
          rem vblank_bB_code constant (defined after label) points to this subroutine

VblankHandlerDispatcher
          rem Returns: Near (return thisbank)
          asm
VblankHandlerDispatcher
end
          rem Vblank handler dispatcher - routes to mode-specific vblank handlers
          rem Returns: Near (return thisbank)
          rem Inputs: gameMode (global 0-7)
          rem Outputs: Dispatches to mode-specific vblank handlers
          rem Mutates: None; dispatcher only
          rem Calls: Various mode-specific vblank handlers
          rem Constraints: Must be colocated with all vblank mode handlers
          rem              Called from kernel during vblank period via JSR
          rem              vblank_bB_code constant points to this subroutine

          rem Optimized: Use on/gosub for space efficiency
          on gameMode gosub VblankModePublisherPrelude VblankModeAuthorPrelude VblankModeTitleScreen VblankModeCharacterSelect VblankModeFallingAnimation VblankModeArenaSelect VblankModeGameMain VblankModeWinnerAnnouncement
          ; Execution continues at ongosub0 label
          goto VblankHandlerDone
          return thisbank

VblankModePublisherPrelude
          rem Publisher Prelude vblank handler
          rem Returns: Near (return thisbank)
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeAuthorPrelude
          rem Author Prelude vblank handler
          rem Returns: Near (return thisbank)
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeTitleScreen
          rem Title Screen vblank handler
          rem Returns: Near (return thisbank)
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeCharacterSelect
          rem Character Select vblank handler
          rem Returns: Near (return thisbank)
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeFallingAnimation
          rem Falling Animation vblank handler
          rem Returns: Near (return thisbank)
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeArenaSelect
          rem Arena Select vblank handler
          rem Returns: Near (return thisbank)
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeGameMain
          rem Game Mode vblank handler - handles heavy game logic
          rem Returns: Near (return thisbank)
          rem CRITICAL: Guard against being called when not in game mode
          if gameMode = ModeGame then goto VblankModeGameMainContinue
          return thisbank

VblankModeGameMainContinue
          rem Game Mode vblank handler - heavy logic only
          rem Returns: Near (return thisbank)
          rem Input: All player state arrays (from overscan input handling)
          rem Output: All game systems updated for one frame
          rem Mutates: All game state (players, missiles, animations, physics, etc.)
          rem Called Routines: UpdateCharacterAnimations, UpdatePlayerMovement,
          rem   PhysicsApplyGravity, ApplyMomentumAndRecovery,
          rem   CheckBoundaryCollisions, CheckPlayfieldCollisionAllDirections,
          rem   CheckAllPlayerCollisions, ProcessAllAttacks,
          rem   CheckAllPlayerEliminations, UpdateAllMissiles,
          rem   CheckRoboTitoStretchMissileCollisions, SetPlayerSprites,
          rem   DisplayHealth, UpdatePlayer12HealthBars, UpdatePlayer34HealthBars
          rem Constraints: Must be colocated with VblankModeGameMain

          rem Check if game is paused - skip all movement/physics/animation if so
          if systemFlags & SystemFlagGameStatePaused then return thisbank

          rem Update animation system (10fps character animation) (in Bank 12)
          gosub UpdateCharacterAnimations bank12

          rem Update movement system (full frame rate movement) (in Bank 8)
          gosub UpdatePlayerMovement bank8

          rem Apply gravity and physics (in Bank 13)
          gosub PhysicsApplyGravity bank13

          rem Apply momentum and recovery effects (in Bank 8)
          gosub ApplyMomentumAndRecovery bank8

          rem Check boundary collisions (in Bank 10)
          gosub CheckBoundaryCollisions bank10

          rem Optimized: Single loop for playfield collisions (walls, ceilings, ground)
          for currentPlayer = 0 to 3
          if currentPlayer >= 2 then goto VblankCheckQuadtariSkip
          goto VblankProcessCollision

VblankCheckQuadtariSkip
          if controllerStatus & SetQuadtariDetected then goto VblankProcessCollision
          goto VblankGameMainQuadtariSkip

VblankProcessCollision
          rem Check for Radish Goblin bounce movement (ground and wall bounces)
          gosub CheckPlayfieldCollisionAllDirections bank10
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then gosub RadishGoblinCheckGroundBounce bank12
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then gosub RadishGoblinCheckWallBounce bank12
          next

VblankGameMainQuadtariSkip
          rem Check multi-player collisions (in Bank 11)
          gosub CheckAllPlayerCollisions bank11

          rem Process mêlée and area attack collisions (in Bank 7)
          gosub ProcessAllAttacks bank7

          rem Check for player eliminations
          gosub CheckAllPlayerEliminations bank14

          rem Update missiles (in Bank 7)
          gosub UpdateAllMissiles bank7

          rem Check if game should end and transition to winner screen
          if systemFlags & SystemFlagGameStateEnding then VblankCheckGameEndTransition
          goto VblankGameEndCheckDone

VblankCheckGameEndTransition
          rem Check if game end timer should transition to winner screen
          rem Returns: Near (return thisbank)
          rem When timer reaches 0, transition to winner announcement
          if gameEndTimer_R = 0 then VblankTransitionToWinner
          rem Decrement game end timer
          let gameEndTimer_W = gameEndTimer_R - 1
          goto VblankGameEndCheckDone

VblankTransitionToWinner
          rem Transition to winner announcement mode
          rem Returns: Near (return thisbank)
          let gameMode = ModeWinner
          gosub ChangeGameMode bank14
          return thisbank

VblankGameEndCheckDone
          rem Update missiles again (in Bank 7)
          gosub UpdateAllMissiles bank7

          rem Check RoboTito stretch missile collisions (bank 7)
          gosub CheckRoboTitoStretchMissileCollisions bank10

          rem Set sprite graphics (in Bank 6)
          gosub SetPlayerSprites bank6

          rem Display health information (in Bank 11)
          gosub DisplayHealth bank11

          rem Update P1/P2 health bars using pfscore system
          gosub UpdatePlayer12HealthBars bank11

          rem Update P3/P4 health bars using playfield system
          gosub UpdatePlayer34HealthBars bank11

          return thisbank

VblankModeWinnerAnnouncement
          rem Winner Announcement vblank handler
          rem Returns: Near (return thisbank)
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankHandlerDone
          rem Vblank handler complete
          rem Returns: Near (return thisbank)
          return thisbank

          rem Note: vblank_bB_code constant is defined in Bank16.bas pointing to VblankHandlerTrampoline
          rem The trampoline calls this dispatcher via cross-bank call

