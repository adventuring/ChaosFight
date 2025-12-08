;;; ChaosFight - Source/Routines/VblankHandlers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Vblank Handler Dispatcher
;;; Handles mode-specific logic during vblank period
;;; Called from kernel vblank_bB_code hook via jsr
          ;; vblank_bB_code constant (defined after label) points to this subroutine


VblankHandlerDispatcher .proc
          ;; Vblank handler dispatcher - routes to mode-specific vblank handlers
          ;; Returns: Far (return otherbank)
          ;; Inputs: gameMode (global 0-7)
          ;; Outputs: Dispatches to mode-specific vblank handlers
          ;; Mutates: None; dispatcher only
          ;; Calls: Various mode-specific vblank handlers
          ;; Constraints: Must be colocated with all vblank mode handlers
          ;; Called from kernel during vblank period via jsr
          ;; vblank_bB_code constant points to this subroutine

          ;; Optimized: Use on/gosub for space efficiency
          ;; CRITICAL: on gameMode gosub is a NEAR call (pushes normal 2-byte return address)
          ;; VblankHandlerDispatcher is called with cross-bank call (pushes 4-byte encoded return)
          ;; Mode handlers return with return thisbank (pops 2 bytes from near call)
          ;; VblankHandlerDispatcher must return with return otherbank (pops 4 bytes from cross-bank call)
          jsr VblankModePublisherPrelude
          ;; TODO: ; Execution continues at ongosub0 label
          jmp VblankHandlerDone

          ;; jsr BS_return (duplicate)

.pend

VblankModePublisherPrelude .proc
          ;; Publisher Prelude vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet (StartMusic sets it to songPointer)
          ;; On first frame, BeginPublisherPrelude hasn’t called StartMusic yet
          ;; Check if music is initialized before calling PlayMusic to prevent crash
          lda musicVoice0Pointer
          cmp # 0
          bne skip_6612
          ;; jmp VblankPublisherPreludeSkipMusic (duplicate)
skip_6612:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 14
          ;; jmp BS_jsr (duplicate)
return_point:


.pend

VblankPublisherPreludeSkipMusic .proc
          ;; No heavy logic needed - all handled in overscan
          rts

.pend

VblankModeAuthorPrelude .proc
          ;; Author Prelude vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet
          ;; lda musicVoice0Pointer (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_5556 (duplicate)
          ;; jmp VblankAuthorPreludeSkipMusic (duplicate)
skip_5556:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


.pend

VblankAuthorPreludeSkipMusic .proc
          ;; No heavy logic needed - all handled in overscan
          ;; rts (duplicate)

.pend

VblankModeTitleScreen .proc
          ;; Title Screen vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet
          ;; lda musicVoice0Pointer (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4663 (duplicate)
          ;; jmp VblankTitleScreenSkipMusic (duplicate)
skip_4663:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


.pend

VblankTitleScreenSkipMusic .proc
          ;; Update character animations for character parade
          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta


.pend

VblankModeCharacterSelect .proc
          ;; Character Select vblank handler
          ;; Returns: Near (return thisbank)
          ;; Update character animations for character selection
          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta


VblankModeFallingAnimation
          ;; Falling Animation vblank handler
          ;; Returns: Near (return thisbank)
          ;; Update character animations for falling animation
          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta


.pend

VblankModeArenaSelect .proc
          ;; Arena Select vblank handler
          ;; Returns: Near (return thisbank)
          ;; Update character animations for arena selection
          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta


.pend

VblankModeGameMain .proc
          ;; Game Mode vblank handler - handles heavy game logic
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard against being called when not in game mode
          ;; lda gameMode (duplicate)
          ;; cmp ModeGame (duplicate)
          ;; bne skip_646 (duplicate)
          ;; jmp VblankModeGameMainContinue (duplicate)
skip_646:


          ;; rts (duplicate)

VblankModeGameMainContinue
          ;; Game Mode vblank handler - heavy logic only
          ;; Returns: Near (return thisbank)
          ;; Input: All player state arrays (from overscan input handling)
          ;; Output: All game systems updated for one frame
          ;; Mutates: All game state (players, missiles, animations, physics, etc.)
          ;; Called Routines: UpdateCharacterAnimations (inlined), UpdatePlayerMovement,
          ;; PhysicsApplyGravity, ApplyMomentumAndRecovery,
          ;; CheckBoundaryCollisions, CheckPlayfieldCollisionAllDirections,
          ;; CheckAllPlayerCollisions, ProcessAllAttacks,
          ;; CheckAllPlayerEliminations, UpdateAllMissiles,
          ;; CheckRoboTitoStretchMissileCollisions, SetPlayerSprites,
          ;; DisplayHealth, UpdatePlayer12HealthBars, UpdatePlayer34HealthBars
          ;; Constraints: Must be colocated with VblankModeGameMain

          ;; Check if game is paused - skip all movement/physics/animation if so
          ;; rts (duplicate)

          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta

          ;; Update animation system (10fps character animation) - INLINED from Bank 12
          ;; Fall through to shared inlined UpdateCharacterAnimations code
          ;; jmp VblankSharedUpdateCharacterAnimations (duplicate)

VblankSharedUpdateCharacterAnimations
          ;; CRITICAL: Shared inlined UpdateCharacterAnimations code
          ;; Used by: VblankModeTitleScreen, VblankModeCharacterSelect, VblankModeFallingAnimation,
          ;; VblankModeArenaSelect, VblankModeGameMain, VblankModeWinnerAnnouncement
          ;; Saves 4 bytes on stack by avoiding cross-bank call to UpdateCharacterAnimations bank12
          ;; CRITICAL: Skip sprite loading in Publisher Prelude and Author Prelude modes (no characters)
          ;; rts (duplicate)
          ;; rts (duplicate)
          ;; TODO: dim VblankUCA_quadtariActive = temp5
          ;; lda controllerStatus (duplicate)
          and SetQuadtariDetected
          sta VblankUCA_quadtariActive
          ;; TODO: for currentPlayer = 0 to 3
          ;; ;; if currentPlayer >= 2 && !VblankUCA_quadtariActive then goto VblankAnimationNextPlayer
          ;; lda currentPlayer (duplicate)
          ;; cmp # 3 (duplicate)
          bcc skip_9120
          ;; lda VblankUCA_quadtariActive (duplicate)
          ;; bne skip_9120 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_9120:

          ;; lda currentPlayer (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bcc skip_7116 (duplicate)
          ;; lda VblankUCA_quadtariActive (duplicate)
          ;; bne skip_7116 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_7116:



          ;; Skip if player is eliminated (health = 0)
                    ;; if playerHealth[currentPlayer] = 0 then goto VblankAnimationNextPlayer
          ;; lda currentPlayer (duplicate)
          asl
          tax
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_8150 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_8150:

          ;; Increment this sprite 10fps animation counter (NOT global frame counter)
          ;; SCRAM read-modify-write: animationCounter_R → animationCounter_W
                    ;; let temp4 = animationCounter_R[currentPlayer] + 1         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda animationCounter_R,x (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta animationCounter_W,x (duplicate)

          ;; Check if time to advance animation frame (every AnimationFrameDelay frames)
                    ;; if temp4 < AnimationFrameDelay then goto VblankDoneAdvanceInlined
          ;; lda temp4 (duplicate)
          ;; cmp AnimationFrameDelay (duplicate)
          bcs skip_2980
          ;; jmp VblankDoneAdvanceInlined (duplicate)
skip_2980:
          

.pend

VblankAdvanceFrame .proc
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta animationCounter_W,x (duplicate)
          ;; Advance to next frame in current animation action
          ;; SCRAM read-modify-write: currentAnimationFrame_R → currentAnimationFrame_W
                    ;; let temp4 = currentAnimationFrame_R[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationFrame_R,x (duplicate)
          ;; sta temp4 (duplicate)
                    ;; let temp4 = 1 + temp4
          ;; lda temp4 (duplicate)
          clc
          adc # 1
          ;; sta temp4 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta currentAnimationFrame_W,x (duplicate)

          ;; Check if we have completed the current action (8 frames per action)
          ;; if temp4 >= FramesPerSequence then goto VblankHandleFrame7Transition
          ;; lda temp4 (duplicate)
          ;; cmp FramesPerSequence (duplicate)

          ;; bcc skip_7518 (duplicate)

          ;; jmp skip_7518 (duplicate)

          skip_7518:

          ;; jmp VblankUpdateSprite (duplicate)

VblankDoneAdvanceInlined
          ;; jmp VblankAnimationNextPlayer (duplicate)

VblankHandleFrame7Transition
          ;; Frame 7 completed, handle action-specific transitions
          ;; CRITICAL: Inlined HandleAnimationTransition to save 4 bytes on sta

          ;; (was: gosub HandleAnimationTransition bank12)
                    ;; let temp1 = currentAnimationSeq_R[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if ActionAttackRecovery < temp1 then goto VblankTransitionLoopAnimation
          ;; lda ActionAttackRecovery (duplicate)
          ;; cmp temp1 (duplicate)
          ;; bcs skip_6813 (duplicate)
          ;; jmp VblankTransitionLoopAnimation (duplicate)
skip_6813:
          

          ;; jmp VblankTransitionLoopAnimation (duplicate)

VblankTransitionLoopAnimation
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta currentAnimationFrame_W,x (duplicate)
          ;; jmp VblankUpdateSprite (duplicate)

VblankTransitionToIdle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankTransitionToFallen
          ;; lda ActionFallen (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankTransitionHandleJump
          ;; Stay on frame 7 until Y velocity goes negative
          ;; if 0 < playerVelocityY[currentPlayer] then VblankTransitionHandleJump_TransitionToFalling
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)

          ;; tax (duplicate)

          ;; lda playerVelocityY,x (duplicate)
          ;; cmp # 1 (duplicate)

          ;; bcc skip_98 (duplicate)

          ;; jmp skip_98 (duplicate)

          skip_98:

          ;; lda ActionJumping (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankTransitionHandleJump_TransitionToFalling
          ;; Falling (positive Y velocity), transition to falling
          ;; lda ActionFalling (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankTransitionHandleFallBack
          ;; Check wall collision using pfread
          ;; Convert player X position to playfield column (0-31)
                    ;; let temp5 = playerX[currentPlayer]          lda currentPlayer          asl          tax          lda playerX,x          sta temp5
          ;; ;; let temp5 = temp5 - ScreenInsetX          lda temp5          sec          sbc ScreenInsetX          sta temp5
          ;; lda temp5 (duplicate)
          sec
          sbc ScreenInsetX
          ;; sta temp5 (duplicate)

          ;; lda temp5 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp5 (duplicate)

          ;; ;; let temp5 = temp5 / 4          lda temp5          lsr          lsr          sta temp5
          ;; lda temp5 (duplicate)
          lsr
          ;; lsr (duplicate)
          ;; sta temp5 (duplicate)

          ;; lda temp5 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp5 (duplicate)

          ;; Convert player Y position to playfield row (0-7)
                    ;; let temp6 = playerY[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; ;; let temp6 = temp6 / 8          lda temp6          lsr          lsr          lsr          sta temp6
          ;; lda temp6 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp6 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp5 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; lda temp3 (duplicate)
          ;; sta temp2 (duplicate)
          ;; if temp1 then VblankTransitionHandleFallBack_HitWall
          ;; lda temp1 (duplicate)
          beq skip_3271
          ;; jmp VblankTransitionHandleFallBack_HitWall (duplicate)
skip_3271:
          

          ;; No wall collision, transition to fallen
          ;; lda ActionFallen (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankTransitionHandleFallBack_HitWall
          ;; Hit wall, transition to idle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankSetPlayerAnimationInlined
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; Set animation action for a player (inlined from AnimationSystem.bas)
          ;; if temp2 >= AnimationSequenceCount then goto VblankUpdateSprite
          ;; lda temp2 (duplicate)
          ;; cmp AnimationSequenceCount (duplicate)

          ;; bcc skip_205 (duplicate)

          ;; jmp skip_205 (duplicate)

          skip_205:

          ;; SCRAM write to currentAnimationSeq_W
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta currentAnimationSeq_W,x (duplicate)
          ;; Start at first frame
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta currentAnimationFrame_W,x (duplicate)
          ;; SCRAM write to animationCounter_W
          ;; Reset animation counter
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta animationCounter_W,x (duplicate)
          ;; Update character sprite immediately using inlined LoadPlayerSprite logic
          ;; Set up parameters for sprite loading (frame=0, action=temp2, player=currentPlayer)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
                    ;; let temp3 = currentAnimationSeq_R[currentPlayer]          lda currentPlayer          asl          tax          lda currentAnimationSeq_R,x          sta temp3
          ;; lda currentPlayer (duplicate)
          ;; sta temp4 (duplicate)
          ;; Fall through to VblankUpdateSprite which has inlined LoadPlayerSprite logic

VblankHandleAttackTransition
                    ;; let temp1 = currentAnimationSeq_R[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if temp1 < ActionAttackWindup then goto VblankUpdateSprite
          ;; lda temp1 (duplicate)
          ;; cmp ActionAttackWindup (duplicate)
          ;; bcs skip_2966 (duplicate)
          ;; jmp VblankUpdateSprite (duplicate)
skip_2966:
          

                    ;; let temp1 = temp1 - ActionAttackWindup          lda temp1          sec          sbc ActionAttackWindup          sta temp1
          ;; jmp VblankHandleWindupEnd (duplicate)

          ;; jmp VblankUpdateSprite (duplicate)

VblankHandleWindupEnd
                    ;; let temp1 = playerCharacter[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; if temp1 >= 32 then goto VblankUpdateSprite
          ;; lda temp1 (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_1472 (duplicate)

          ;; jmp skip_1472 (duplicate)

          skip_1472:

          ;; if temp1 >= 16 then let temp1 = 0
          ;; lda temp1 (duplicate)
          ;; cmp # 17 (duplicate)

          ;; bcc skip_6145 (duplicate)

          ;; lda # 0 (duplicate)

          ;; sta .skip_6145 (duplicate)

          label_unknown:
                    ;; let temp2 = CharacterWindupNextAction[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWindupNextAction,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_360 (duplicate)
          ;; jmp VblankUpdateSprite (duplicate)
skip_360:


          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankHandleExecuteEnd
                    ;; let temp1 = playerCharacter[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; if temp1 >= 32 then goto VblankUpdateSprite
          ;; lda temp1 (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_1472 (duplicate)

          ;; jmp skip_1472 (duplicate)

          ;; skip_1472: (duplicate)

          ;; lda temp1 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bne skip_7575 (duplicate)
          ;; jmp VblankHarpyExecute (duplicate)
skip_7575:


          ;; if temp1 >= 16 then let temp1 = 0
          ;; lda temp1 (duplicate)
          ;; cmp # 17 (duplicate)

          ;; bcc skip_6145 (duplicate)

          ;; lda # 0 (duplicate)

          ;; sta .skip_6145 (duplicate)

          ;; label_unknown: (duplicate)
                    ;; let temp2 = CharacterExecuteNextAction[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterExecuteNextAction,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_360 (duplicate)
          ;; jmp VblankUpdateSprite (duplicate)
;; skip_360: (duplicate)


          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

.pend

VblankHarpyExecute .proc
          ;; Harpy: Execute → Idle
          ;; Clear dive flag and stop diagonal movement when attack completes
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
          ;; Clear dive flag (bit 4 in characterStateFlags)
          ;; let C6E_stateFlags = 239 & characterStateFlags_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterStateFlags_R,x (duplicate)
          ;; and # 239 (duplicate)
          ;; sta C6E_stateFlags (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda C6E_stateFlags (duplicate)
          ;; sta characterStateFlags_W,x (duplicate)
          ;; Stop horizontal velocity (zero X velocity)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; Apply upward wing flap momentum after swoop attack
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 254 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
          ;; Transition to Idle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

VblankHandleRecoveryEnd
          ;; All characters: Recovery → Idle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp VblankSetPlayerAnimationInlined (duplicate)

.pend

VblankUpdateSprite .proc
          ;; Update character sprite with current animation frame and action
          ;; CRITICAL: Guard against calling bank 2 when no characters on screen
                    ;; let currentCharacter = playerCharacter[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda currentCharacter (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_7144 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_7144:

          ;; lda currentCharacter (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_480 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_480:

          ;; lda currentCharacter (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_8085 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_8085:

          ;; CRITICAL: Validate character index is within valid range (0-MaxCharacter)
          ;; Uninitialized playerCharacter (0) is valid (Bernie), but values > MaxCharacter are invalid
          ;; ;; if currentCharacter > MaxCharacter then goto VblankAnimationNextPlayer
          ;; lda currentCharacter (duplicate)
          ;; sec (duplicate)
          ;; sbc MaxCharacter (duplicate)
          ;; bcc skip_9310 (duplicate)
          ;; beq skip_9310 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_9310:

          ;; lda currentCharacter (duplicate)
          ;; sec (duplicate)
          ;; sbc MaxCharacter (duplicate)
          ;; bcc skip_5976 (duplicate)
          ;; beq skip_5976 (duplicate)
          ;; jmp VblankAnimationNextPlayer (duplicate)
skip_5976:


                    ;; let temp2 = currentAnimationFrame_R[currentPlayer]          lda currentPlayer          asl          tax          lda currentAnimationFrame_R,x          sta temp2
                    ;; let temp3 = currentAnimationSeq_R[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp4 (duplicate)
          ;; CRITICAL: Inlined LoadPlayerSprite dispatcher to save 4 bytes on sta

          ;; lda currentCharacter (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          ;; ;; if temp1 < 8 then goto VblankUpdateSprite_Bank2Dispatch          lda temp1          cmp 8          bcs .skip_680          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bcs skip_9194 (duplicate)
          goto_label:

          ;; jmp goto_label (duplicate)
skip_9194:

          ;; lda temp1 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bcs skip_9618 (duplicate)
          ;; jmp goto_label (duplicate)
skip_9618:

          

          ;; ;; if temp1 < 16 then goto VblankUpdateSprite_Bank3Dispatch          lda temp1          cmp 16          bcs .skip_6822          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 16 (duplicate)
          ;; bcs skip_7725 (duplicate)
          ;; jmp goto_label (duplicate)
skip_7725:

          ;; lda temp1 (duplicate)
          ;; cmp # 16 (duplicate)
          ;; bcs skip_9622 (duplicate)
          ;; jmp goto_label (duplicate)
skip_9622:

          

          ;; ;; if temp1 < 24 then goto VblankUpdateSprite_Bank4Dispatch          lda temp1          cmp 24          bcs .skip_5055          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 24 (duplicate)
          ;; bcs skip_6786 (duplicate)
          ;; jmp goto_label (duplicate)
skip_6786:

          ;; lda temp1 (duplicate)
          ;; cmp # 24 (duplicate)
          ;; bcs skip_9987 (duplicate)
          ;; jmp goto_label (duplicate)
skip_9987:

          

          ;; jmp VblankUpdateSprite_Bank5Dispatch (duplicate)

VblankUpdateSprite_Bank2Dispatch
          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp5 (duplicate)
          ;; Cross-bank call to SetPlayerCharacterArtBank2 in bank 2
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerCharacterArtBank2-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerCharacterArtBank2-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 1 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp VblankAnimationNextPlayer (duplicate)

VblankUpdateSprite_Bank3Dispatch
          ;; ;; let temp6 = temp1 - 8          lda temp1          sec          sbc 8          sta temp6
          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc 8 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc 8 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp5 (duplicate)
          ;; Cross-bank call to SetPlayerCharacterArtBank3 in bank 3
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerCharacterArtBank3-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerCharacterArtBank3-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 2 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp VblankAnimationNextPlayer (duplicate)

VblankUpdateSprite_Bank4Dispatch
          ;; ;; let temp6 = temp1 - 16          lda temp1          sec          sbc 16          sta temp6
          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc 16 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc 16 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp5 (duplicate)
          ;; Cross-bank call to SetPlayerCharacterArtBank4 in bank 4
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerCharacterArtBank4-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerCharacterArtBank4-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 3 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp VblankAnimationNextPlayer (duplicate)

VblankUpdateSprite_Bank5Dispatch
          ;; ;; let temp6 = temp1 - 24          lda temp1          sec          sbc 24          sta temp6
          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc 24 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc 24 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp4 (duplicate)
          ;; sta temp5 (duplicate)
          ;; Cross-bank call to SetPlayerCharacterArtBank5 in bank 5
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerCharacterArtBank5-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerCharacterArtBank5-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 4 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jmp VblankAnimationNextPlayer (duplicate)

VblankAnimationNextPlayer
.pend

next_label_1_L950:.proc
          ;; End of shared inlined UpdateCharacterAnimations code
          ;; For game mode, continue with additional game logic
          ;; For other modes, return immediately
          ;; lda gameMode (duplicate)
          ;; cmp ModeGame (duplicate)
          ;; bne skip_3052 (duplicate)
          ;; jmp VblankModeGameMainAfterAnimations (duplicate)
skip_3052:


          ;; rts (duplicate)

VblankModeGameMainAfterAnimations
          ;; Update movement system (full frame rate movement) (in Bank 8)
          ;; Cross-bank call to UpdatePlayerMovement in bank 8
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdatePlayerMovement-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdatePlayerMovement-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 7 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Apply gravity and physics (in Bank 13)
          ;; Cross-bank call to PhysicsApplyGravity in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PhysicsApplyGravity-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PhysicsApplyGravity-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Apply momentum and recovery effects (in Bank 8)
          ;; Cross-bank call to ApplyMomentumAndRecovery in bank 8
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ApplyMomentumAndRecovery-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ApplyMomentumAndRecovery-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 7 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Check boundary collisions (in Bank 10)
          ;; Cross-bank call to CheckBoundaryCollisions in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckBoundaryCollisions-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckBoundaryCollisions-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Optimized: Single loop for playfield collisions (walls, ceilings, ground)
          ;; TODO: for currentPlayer = 0 to 3
          ;; if currentPlayer >= 2 then goto VblankCheckQuadtariSkip
          ;; lda currentPlayer (duplicate)
          ;; cmp 2 (duplicate)

          ;; bcc skip_7662 (duplicate)

          ;; jmp skip_7662 (duplicate)

          skip_7662:

          ;; jmp VblankProcessCollision (duplicate)

.pend

VblankCheckQuadtariSkip .proc
                    ;; if controllerStatus & SetQuadtariDetected then goto VblankProcessCollision
          ;; jmp VblankGameMainQuadtariSkip (duplicate)

VblankProcessCollision
          ;; Check for Radish Goblin bounce movement (ground and wall bounces)
          ;; Cross-bank call to CheckPlayfieldCollisionAllDirections in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckPlayfieldCollisionAllDirections-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckPlayfieldCollisionAllDirections-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to RadishGoblinCheckGroundBounce in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinCheckGroundBounce-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinCheckGroundBounce-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Cross-bank call to RadishGoblinCheckWallBounce in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(RadishGoblinCheckWallBounce-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(RadishGoblinCheckWallBounce-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


.pend

next_label_2_1_L1090:.proc

.pend

VblankGameMainQuadtariSkip .proc
          ;; Check multi-player collisions (in Bank 11)
          ;; Cross-bank call to CheckAllPlayerCollisions in bank 11
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckAllPlayerCollisions-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckAllPlayerCollisions-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 10 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Process mêlée and area attack collisions (in Bank 7)
          ;; Cross-bank call to ProcessAllAttacks in bank 7
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ProcessAllAttacks-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ProcessAllAttacks-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 6 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Check for player eliminations
          ;; Cross-bank call to CheckAllPlayerEliminations in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckAllPlayerEliminations-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckAllPlayerEliminations-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Update missiles (in Bank 7)
          ;; Cross-bank call to UpdateAllMissiles in bank 7
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdateAllMissiles-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdateAllMissiles-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 6 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Check if game should end and transition to winner screen
                    ;; if systemFlags & SystemFlagGameStateEnding then VblankCheckGameEndTransition
          ;; jmp VblankGameEndCheckDone (duplicate)

VblankCheckGameEndTransition
          ;; Check if game end timer should transition to winner screen
          ;; Returns: Near (return thisbank)
          ;; When timer reaches 0, transition to winner announcement
          ;; lda gameEndTimer_R (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3791 (duplicate)
          ;; TODO: VblankTransitionToWinner
skip_3791:


          ;; Decrement game end timer
          ;; lda gameEndTimer_R (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta gameEndTimer_W (duplicate)
          ;; jmp VblankGameEndCheckDone (duplicate)

VblankTransitionToWinner
          ;; Transition to winner announcement mode
          ;; Returns: Near (return thisbank)
          ;; lda ModeWinner (duplicate)
          ;; sta gameMode (duplicate)
          ;; Cross-bank call to ChangeGameMode in bank 14
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(ChangeGameMode-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 13 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; rts (duplicate)

VblankGameEndCheckDone
          ;; Update missiles again (in Bank 7)
          ;; Cross-bank call to UpdateAllMissiles in bank 7
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdateAllMissiles-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdateAllMissiles-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 6 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Check RoboTito stretch missile collisions (bank 7)
          ;; Cross-bank call to CheckRoboTitoStretchMissileCollisions in bank 10
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckRoboTitoStretchMissileCollisions-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckRoboTitoStretchMissileCollisions-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 9 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Set sprite graphics (in Bank 6)
          ;; Cross-bank call to SetPlayerSprites in bank 6
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerSprites-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerSprites-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 5 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Display health information (in Bank 11)
          ;; Cross-bank call to DisplayHealth in bank 11
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(DisplayHealth-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(DisplayHealth-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 10 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Update P1/P2 health bars using pfscore system
          ;; Cross-bank call to UpdatePlayer12HealthBars in bank 11
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdatePlayer12HealthBars-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdatePlayer12HealthBars-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 10 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Update P3/P4 health bars using playfield system
          ;; Cross-bank call to UpdatePlayer34HealthBars in bank 11
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(UpdatePlayer34HealthBars-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(UpdatePlayer34HealthBars-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 10 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; rts (duplicate)

.pend

VblankModeWinnerAnnouncement .proc
          ;; Winner Announcement vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet
          ;; lda musicVoice0Pointer (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_2479 (duplicate)
          ;; jmp VblankWinnerAnnouncementSkipMusic (duplicate)
skip_2479:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayMusic-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


.pend

VblankWinnerAnnouncementSkipMusic .proc
          ;; Update character animations for winner screen
          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta


VblankHandlerDone
          ;; Vblank handler complete
          ;; Returns: Far (return otherbank)
          ;; Called via cross-bank call from VblankHandlerTrampoline, so must use return otherbank
          ;; jsr BS_return (duplicate)
          ;; Note: vblank_bB_code constant is defined in Bank15.s pointing to VblankHandlerTrampoline
          ;; The trampoline calls this dispatcher via cross-bank call

.pend

