          rem ChaosFight - Source/Routines/VblankHandlers.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          rem Vblank Handler Dispatcher
          rem Handles mode-specific logic during vblank period
          rem Called from kernel vblank_bB_code hook via JSR
          rem vblank_bB_code constant (defined after label) points to this subroutine

VblankHandlerDispatcher
          rem Returns: Far (return otherbank)
          asm
VblankHandlerDispatcher
end
          rem Vblank handler dispatcher - routes to mode-specific vblank handlers
          rem Returns: Far (return otherbank)
          rem Inputs: gameMode (global 0-7)
          rem Outputs: Dispatches to mode-specific vblank handlers
          rem Mutates: None; dispatcher only
          rem Calls: Various mode-specific vblank handlers
          rem Constraints: Must be colocated with all vblank mode handlers
          rem              Called from kernel during vblank period via JSR
          rem              vblank_bB_code constant points to this subroutine

          rem Optimized: Use on/gosub for space efficiency
          rem CRITICAL: on gameMode gosub is a NEAR call (pushes normal 2-byte return address)
          rem VblankHandlerDispatcher is called with cross-bank call (pushes 4-byte encoded return)
          rem Mode handlers return with return thisbank (pops 2 bytes from near call)
          rem VblankHandlerDispatcher must return with return otherbank (pops 4 bytes from cross-bank call)
          on gameMode gosub VblankModePublisherPrelude VblankModeAuthorPrelude VblankModeTitleScreen VblankModeCharacterSelect VblankModeFallingAnimation VblankModeArenaSelect VblankModeGameMain VblankModeWinnerAnnouncement
          ; Execution continues at ongosub0 label
          goto VblankHandlerDone
          return otherbank

VblankModePublisherPrelude
          rem Publisher Prelude vblank handler
          rem Returns: Near (return thisbank)
          rem CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          rem When called from Vblank, stack is shallower than when called from MainLoop
          gosub PlayMusic bank15
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeAuthorPrelude
          rem Author Prelude vblank handler
          rem Returns: Near (return thisbank)
          rem CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          rem When called from Vblank, stack is shallower than when called from MainLoop
          gosub PlayMusic bank15
          rem No heavy logic needed - all handled in overscan
          return thisbank

VblankModeTitleScreen
          rem Title Screen vblank handler
          rem Returns: Near (return thisbank)
          rem CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          rem When called from Vblank, stack is shallower than when called from MainLoop
          gosub PlayMusic bank15
          rem Update character animations for character parade
          rem CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on stack
          rem (was: gosub UpdateCharacterAnimations bank12)
          goto VblankSharedUpdateCharacterAnimations

VblankModeCharacterSelect
          rem Character Select vblank handler
          rem Returns: Near (return thisbank)
          rem Update character animations for character selection
          rem CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on stack
          rem (was: gosub UpdateCharacterAnimations bank12)
          goto VblankSharedUpdateCharacterAnimations

VblankModeFallingAnimation
          rem Falling Animation vblank handler
          rem Returns: Near (return thisbank)
          rem Update character animations for falling animation
          rem CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on stack
          rem (was: gosub UpdateCharacterAnimations bank12)
          goto VblankSharedUpdateCharacterAnimations

VblankModeArenaSelect
          rem Arena Select vblank handler
          rem Returns: Near (return thisbank)
          rem Update character animations for arena selection
          rem CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on stack
          rem (was: gosub UpdateCharacterAnimations bank12)
          goto VblankSharedUpdateCharacterAnimations

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
          rem Called Routines: UpdateCharacterAnimations (inlined), UpdatePlayerMovement,
          rem   PhysicsApplyGravity, ApplyMomentumAndRecovery,
          rem   CheckBoundaryCollisions, CheckPlayfieldCollisionAllDirections,
          rem   CheckAllPlayerCollisions, ProcessAllAttacks,
          rem   CheckAllPlayerEliminations, UpdateAllMissiles,
          rem   CheckRoboTitoStretchMissileCollisions, SetPlayerSprites,
          rem   DisplayHealth, UpdatePlayer12HealthBars, UpdatePlayer34HealthBars
          rem Constraints: Must be colocated with VblankModeGameMain

          rem Check if game is paused - skip all movement/physics/animation if so
          if systemFlags & SystemFlagGameStatePaused then return thisbank

          rem CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on stack
          rem Update animation system (10fps character animation) - INLINED from Bank 12
          rem Fall through to shared inlined UpdateCharacterAnimations code
          goto VblankSharedUpdateCharacterAnimations

VblankSharedUpdateCharacterAnimations
          rem CRITICAL: Shared inlined UpdateCharacterAnimations code
          rem Used by: VblankModeTitleScreen, VblankModeCharacterSelect, VblankModeFallingAnimation,
          rem   VblankModeArenaSelect, VblankModeGameMain, VblankModeWinnerAnnouncement
          rem Saves 4 bytes on stack by avoiding cross-bank call to UpdateCharacterAnimations bank12
          dim VblankUCA_quadtariActive = temp5
          let VblankUCA_quadtariActive = controllerStatus & SetQuadtariDetected
          for currentPlayer = 0 to 3
          if currentPlayer >= 2 && !VblankUCA_quadtariActive then goto VblankAnimationNextPlayer
          rem Skip if player is eliminated (health = 0)
          if playerHealth[currentPlayer] = 0 then goto VblankAnimationNextPlayer

          rem Increment this sprite 10fps animation counter (NOT global frame counter)
          rem SCRAM read-modify-write: animationCounter_R → animationCounter_W
          let temp4 = animationCounter_R[currentPlayer] + 1
          let animationCounter_W[currentPlayer] = temp4

          rem Check if time to advance animation frame (every AnimationFrameDelay frames)
          if temp4 < AnimationFrameDelay then goto VblankDoneAdvanceInlined
VblankAdvanceFrame
          let animationCounter_W[currentPlayer] = 0
          rem Advance to next frame in current animation action
          rem SCRAM read-modify-write: currentAnimationFrame_R → currentAnimationFrame_W
          let temp4 = currentAnimationFrame_R[currentPlayer]
          let temp4 = 1 + temp4
          let currentAnimationFrame_W[currentPlayer] = temp4

          rem Check if we have completed the current action (8 frames per action)
          if temp4 >= FramesPerSequence then goto VblankHandleFrame7Transition
          goto VblankUpdateSprite
VblankDoneAdvanceInlined
          goto VblankAnimationNextPlayer
VblankHandleFrame7Transition
          rem Frame 7 completed, handle action-specific transitions
          rem CRITICAL: Inlined HandleAnimationTransition to save 4 bytes on stack
          rem (was: gosub HandleAnimationTransition bank12)
          let temp1 = currentAnimationSeq_R[currentPlayer]
          if ActionAttackRecovery < temp1 then goto VblankTransitionLoopAnimation

          on temp1 goto VblankTransitionLoopAnimation VblankTransitionLoopAnimation VblankTransitionLoopAnimation VblankTransitionLoopAnimation VblankTransitionLoopAnimation VblankTransitionToIdle VblankTransitionHandleFallBack VblankTransitionToFallen VblankTransitionLoopAnimation VblankTransitionToIdle VblankTransitionHandleJump VblankTransitionLoopAnimation VblankTransitionToIdle VblankHandleAttackTransition VblankHandleAttackTransition VblankHandleAttackTransition

VblankTransitionLoopAnimation
          let currentAnimationFrame_W[currentPlayer] = 0
          goto VblankUpdateSprite

VblankTransitionToIdle
          let temp2 = ActionIdle
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankTransitionToFallen
          let temp2 = ActionFallen
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankTransitionHandleJump
          rem Stay on frame 7 until Y velocity goes negative
          if 0 < playerVelocityY[currentPlayer] then VblankTransitionHandleJump_TransitionToFalling
          let temp2 = ActionJumping
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankTransitionHandleJump_TransitionToFalling
          rem Falling (positive Y velocity), transition to falling
          let temp2 = ActionFalling
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankTransitionHandleFallBack
          rem Check wall collision using pfread
          rem Convert player X position to playfield column (0-31)
          let temp5 = playerX[currentPlayer]
          let temp5 = temp5 - ScreenInsetX
          let temp5 = temp5 / 4
          rem Convert player Y position to playfield row (0-7)
          let temp6 = playerY[currentPlayer]
          let temp6 = temp6 / 8
          let temp1 = temp5
          let temp3 = temp2
          let temp2 = temp6
          gosub PlayfieldRead bank16
          let temp2 = temp3
          if temp1 then VblankTransitionHandleFallBack_HitWall
          rem No wall collision, transition to fallen
          let temp2 = ActionFallen
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankTransitionHandleFallBack_HitWall
          rem Hit wall, transition to idle
          let temp2 = ActionIdle
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankSetPlayerAnimationInlined
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          rem Set animation action for a player (inlined from AnimationSystem.bas)
          if temp2 >= AnimationSequenceCount then goto VblankUpdateSprite
          rem SCRAM write to currentAnimationSeq_W
          let currentAnimationSeq_W[currentPlayer] = temp2
          rem Start at first frame
          let currentAnimationFrame_W[currentPlayer] = 0
          rem SCRAM write to animationCounter_W
          rem Reset animation counter
          let animationCounter_W[currentPlayer] = 0
          rem Update character sprite immediately using inlined LoadPlayerSprite logic
          rem Set up parameters for sprite loading (frame=0, action=temp2, player=currentPlayer)
          let temp2 = 0
          let temp3 = currentAnimationSeq_R[currentPlayer]
          let temp4 = currentPlayer
          rem Fall through to VblankUpdateSprite which has inlined LoadPlayerSprite logic

VblankHandleAttackTransition
          let temp1 = currentAnimationSeq_R[currentPlayer]
          if temp1 < ActionAttackWindup then goto VblankUpdateSprite
          let temp1 = temp1 - ActionAttackWindup
          on temp1 goto VblankHandleWindupEnd VblankHandleExecuteEnd VblankHandleRecoveryEnd
          goto VblankUpdateSprite

VblankHandleWindupEnd
          let temp1 = playerCharacter[currentPlayer]
          if temp1 >= 32 then goto VblankUpdateSprite
          if temp1 >= 16 then let temp1 = 0
          let temp2 = CharacterWindupNextAction[temp1]
          if temp2 = 255 then goto VblankUpdateSprite
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankHandleExecuteEnd
          let temp1 = playerCharacter[currentPlayer]
          if temp1 >= 32 then goto VblankUpdateSprite
          if temp1 = 6 then goto VblankHarpyExecute
          if temp1 >= 16 then let temp1 = 0
          let temp2 = CharacterExecuteNextAction[temp1]
          if temp2 = 255 then goto VblankUpdateSprite
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankHarpyExecute
          rem Harpy: Execute → Idle
          rem Clear dive flag and stop diagonal movement when attack completes
          let temp1 = currentPlayer
          rem Clear dive flag (bit 4 in characterStateFlags)
          let C6E_stateFlags = 239 & characterStateFlags_R[temp1]
          let characterStateFlags_W[temp1] = C6E_stateFlags
          rem Stop horizontal velocity (zero X velocity)
          let playerVelocityX[temp1] = 0
          let playerVelocityXL[temp1] = 0
          rem Apply upward wing flap momentum after swoop attack
          let playerVelocityY[temp1] = 254
          let playerVelocityYL[temp1] = 0
          rem Transition to Idle
          let temp2 = ActionIdle
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankHandleRecoveryEnd
          rem All characters: Recovery → Idle
          let temp2 = ActionIdle
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto VblankSetPlayerAnimationInlined

VblankUpdateSprite
          rem Update character sprite with current animation frame and action
          let temp2 = currentAnimationFrame_R[currentPlayer]
          let temp3 = currentAnimationSeq_R[currentPlayer]
          let temp4 = currentPlayer
          rem CRITICAL: Inlined LoadPlayerSprite dispatcher to save 4 bytes on stack
          let currentCharacter = playerCharacter[currentPlayer]
          let temp1 = currentCharacter
          let temp6 = temp1
          rem Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          if temp1 < 8 then goto VblankUpdateSprite_Bank2Dispatch
          if temp1 < 16 then goto VblankUpdateSprite_Bank3Dispatch
          if temp1 < 24 then goto VblankUpdateSprite_Bank4Dispatch
          goto VblankUpdateSprite_Bank5Dispatch

VblankUpdateSprite_Bank2Dispatch
          let temp6 = temp1
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank2 bank2
          goto VblankAnimationNextPlayer

VblankUpdateSprite_Bank3Dispatch
          let temp6 = temp1 - 8
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank3 bank3
          goto VblankAnimationNextPlayer

VblankUpdateSprite_Bank4Dispatch
          let temp6 = temp1 - 16
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank4 bank4
          goto VblankAnimationNextPlayer

VblankUpdateSprite_Bank5Dispatch
          let temp6 = temp1 - 24
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank5 bank5
          goto VblankAnimationNextPlayer

VblankAnimationNextPlayer
          next
          rem End of shared inlined UpdateCharacterAnimations code
          rem For game mode, continue with additional game logic
          rem For other modes, return immediately
          if gameMode = ModeGame then goto VblankModeGameMainAfterAnimations
          return thisbank

VblankModeGameMainAfterAnimations
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
          rem CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          rem When called from Vblank, stack is shallower than when called from MainLoop
          gosub PlayMusic bank15
          rem Update character animations for winner screen
          rem CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on stack
          rem (was: gosub UpdateCharacterAnimations bank12)
          goto VblankSharedUpdateCharacterAnimations

VblankHandlerDone
          rem Vblank handler complete
          rem Returns: Far (return otherbank)
          rem Called via cross-bank call from VblankHandlerTrampoline, so must use return otherbank
          return otherbank

          rem Note: vblank_bB_code constant is defined in Bank16.bas pointing to VblankHandlerTrampoline
          rem The trampoline calls this dispatcher via cross-bank call

