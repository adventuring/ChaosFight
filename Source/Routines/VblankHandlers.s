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

          jsr BS_return

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
          jmp VblankPublisherPreludeSkipMusic
skip_6612:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayMusic-1)
          pha
          lda # <(PlayMusic-1)
          pha
                    ldx # 14
          jmp BS_jsr
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
          lda musicVoice0Pointer
          cmp # 0
          bne skip_5556
          jmp VblankAuthorPreludeSkipMusic
skip_5556:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayMusic-1)
          pha
          lda # <(PlayMusic-1)
          pha
                    ldx # 14
          jmp BS_jsr
return_point:


.pend

VblankAuthorPreludeSkipMusic .proc
          ;; No heavy logic needed - all handled in overscan
          rts

.pend

VblankModeTitleScreen .proc
          ;; Title Screen vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet
          lda musicVoice0Pointer
          cmp # 0
          bne skip_4663
          jmp VblankTitleScreenSkipMusic
skip_4663:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayMusic-1)
          pha
          lda # <(PlayMusic-1)
          pha
                    ldx # 14
          jmp BS_jsr
return_point:


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
          lda gameMode
          cmp ModeGame
          bne skip_646
          jmp VblankModeGameMainContinue
skip_646:


          rts

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
          rts

          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta

          ;; Update animation system (10fps character animation) - INLINED from Bank 12
          ;; Fall through to shared inlined UpdateCharacterAnimations code
          jmp VblankSharedUpdateCharacterAnimations

VblankSharedUpdateCharacterAnimations
          ;; CRITICAL: Shared inlined UpdateCharacterAnimations code
          ;; Used by: VblankModeTitleScreen, VblankModeCharacterSelect, VblankModeFallingAnimation,
          ;; VblankModeArenaSelect, VblankModeGameMain, VblankModeWinnerAnnouncement
          ;; Saves 4 bytes on stack by avoiding cross-bank call to UpdateCharacterAnimations bank12
          ;; CRITICAL: Skip sprite loading in Publisher Prelude and Author Prelude modes (no characters)
          rts
          rts
          ;; TODO: dim VblankUCA_quadtariActive = temp5
          lda controllerStatus
          and SetQuadtariDetected
          sta VblankUCA_quadtariActive
          ;; TODO: for currentPlayer = 0 to 3
          ;; if currentPlayer >= 2 && !VblankUCA_quadtariActive then goto VblankAnimationNextPlayer
          lda currentPlayer
          cmp # 3
          bcc skip_9120
          lda VblankUCA_quadtariActive
          bne skip_9120
          jmp VblankAnimationNextPlayer
skip_9120:

          lda currentPlayer
          cmp # 3
          bcc skip_7116
          lda VblankUCA_quadtariActive
          bne skip_7116
          jmp VblankAnimationNextPlayer
skip_7116:



          ;; Skip if player is eliminated (health = 0)
          ;; if playerHealth[currentPlayer] = 0 then goto VblankAnimationNextPlayer
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          bne skip_8150
          jmp VblankAnimationNextPlayer
skip_8150:

          ;; Increment this sprite 10fps animation counter (NOT global frame counter)
          ;; SCRAM read-modify-write: animationCounter_R → animationCounter_W
          ;; let temp4 = animationCounter_R[currentPlayer] + 1         
          lda currentPlayer
          asl
          tax
          lda animationCounter_R,x
          sta temp4
          lda currentPlayer
          asl
          tax
          lda temp4
          sta animationCounter_W,x

          ;; Check if time to advance animation frame (every AnimationFrameDelay frames)
          ;; if temp4 < AnimationFrameDelay then goto VblankDoneAdvanceInlined
          lda temp4
          cmp AnimationFrameDelay
          bcs skip_2980
          jmp VblankDoneAdvanceInlined
skip_2980:
          

.pend

VblankAdvanceFrame .proc
          lda currentPlayer
          asl
          tax
          lda 0
          sta animationCounter_W,x
          ;; Advance to next frame in current animation action
          ;; SCRAM read-modify-write: currentAnimationFrame_R → currentAnimationFrame_W
          ;; let temp4 = currentAnimationFrame_R[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda currentAnimationFrame_R,x
          sta temp4
          ;; let temp4 = 1 + temp4
          lda temp4
          clc
          adc # 1
          sta temp4
          lda currentPlayer
          asl
          tax
          lda temp4
          sta currentAnimationFrame_W,x

          ;; Check if we have completed the current action (8 frames per action)
          ;; if temp4 >= FramesPerSequence then goto VblankHandleFrame7Transition
          lda temp4
          cmp FramesPerSequence

          bcc skip_7518

          jmp skip_7518

          skip_7518:

          jmp VblankUpdateSprite

VblankDoneAdvanceInlined
          jmp VblankAnimationNextPlayer

VblankHandleFrame7Transition
          ;; Frame 7 completed, handle action-specific transitions
          ;; CRITICAL: Inlined HandleAnimationTransition to save 4 bytes on sta

          ;; (was: gosub HandleAnimationTransition bank12)
          ;; let temp1 = currentAnimationSeq_R[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          ;; if ActionAttackRecovery < temp1 then goto VblankTransitionLoopAnimation
          lda ActionAttackRecovery
          cmp temp1
          bcs skip_6813
          jmp VblankTransitionLoopAnimation
skip_6813:
          

          jmp VblankTransitionLoopAnimation

VblankTransitionLoopAnimation
          lda currentPlayer
          asl
          tax
          lda 0
          sta currentAnimationFrame_W,x
          jmp VblankUpdateSprite

VblankTransitionToIdle
          lda ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionToFallen
          lda ActionFallen
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleJump
          ;; Stay on frame 7 until Y velocity goes negative
          if 0 < playerVelocityY[currentPlayer] then VblankTransitionHandleJump_TransitionToFalling
          lda currentPlayer
          asl

          tax

          lda playerVelocityY,x
          cmp # 1

          bcc skip_98

          jmp skip_98

          skip_98:

          lda ActionJumping
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleJump_TransitionToFalling
          ;; Falling (positive Y velocity), transition to falling
          lda ActionFalling
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleFallBack
          ;; Check wall collision using pfread
          ;; Convert player X position to playfield column (0-31)
                    ;; let temp5 = playerX[currentPlayer]
                    lda currentPlayer          asl          tax          lda playerX,x          sta temp5
          ;; let temp5 = temp5 - ScreenInsetX          lda temp5          sec          sbc ScreenInsetX          sta temp5
          lda temp5
          sec
          sbc ScreenInsetX
          sta temp5

          lda temp5
          sec
          sbc ScreenInsetX
          sta temp5

          ;; let temp5 = temp5 / 4          lda temp5          lsr          lsr          sta temp5
          lda temp5
          lsr
          lsr
          sta temp5

          lda temp5
          lsr
          lsr
          sta temp5

          ;; Convert player Y position to playfield row (0-7)
          ;; let temp6 = playerY[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp6
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp6
          ;; let temp6 = temp6 / 8          lda temp6          lsr          lsr          lsr          sta temp6
          lda temp6
          lsr
          lsr
          lsr
          sta temp6

          lda temp6
          lsr
          lsr
          lsr
          sta temp6

          lda temp5
          sta temp1
          lda temp2
          sta temp3
          lda temp6
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


          lda temp3
          sta temp2
          if temp1 then VblankTransitionHandleFallBack_HitWall
          lda temp1
          beq skip_3271
          jmp VblankTransitionHandleFallBack_HitWall
skip_3271:
          

          ;; No wall collision, transition to fallen
          lda ActionFallen
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleFallBack_HitWall
          ;; Hit wall, transition to idle
          lda ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankSetPlayerAnimationInlined
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; Set animation action for a player (inlined from AnimationSystem.bas)
          ;; if temp2 >= AnimationSequenceCount then goto VblankUpdateSprite
          lda temp2
          cmp AnimationSequenceCount

          bcc skip_205

          jmp skip_205

          skip_205:

          ;; SCRAM write to currentAnimationSeq_W
          lda currentPlayer
          asl
          tax
          lda temp2
          sta currentAnimationSeq_W,x
          ;; Start at first frame
          lda currentPlayer
          asl
          tax
          lda 0
          sta currentAnimationFrame_W,x
          ;; SCRAM write to animationCounter_W
          ;; Reset animation counter
          lda currentPlayer
          asl
          tax
          lda 0
          sta animationCounter_W,x
          ;; Update character sprite immediately using inlined LoadPlayerSprite logic
          ;; Set up parameters for sprite loading (frame=0, action=temp2, player=currentPlayer)
          lda # 0
          sta temp2
                    ;; let temp3 = currentAnimationSeq_R[currentPlayer]
                    lda currentPlayer          asl          tax          lda currentAnimationSeq_R,x          sta temp3
          lda currentPlayer
          sta temp4
          ;; Fall through to VblankUpdateSprite which has inlined LoadPlayerSprite logic

VblankHandleAttackTransition
          ;; let temp1 = currentAnimationSeq_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          ;; if temp1 < ActionAttackWindup then goto VblankUpdateSprite
          lda temp1
          cmp ActionAttackWindup
          bcs skip_2966
          jmp VblankUpdateSprite
skip_2966:
          

                    let temp1 = temp1 - ActionAttackWindup          lda temp1          sec          sbc ActionAttackWindup          sta temp1
          jmp VblankHandleWindupEnd

          jmp VblankUpdateSprite

VblankHandleWindupEnd
          ;; let temp1 = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp1
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp1
          ;; if temp1 >= 32 then goto VblankUpdateSprite
          lda temp1
          cmp 32

          bcc skip_1472

          jmp skip_1472

          skip_1472:

          if temp1 >= 16 then let temp1 = 0
          lda temp1
          cmp # 17

          bcc skip_6145

          lda # 0

          sta .skip_6145

          label_unknown:
          ;; let temp2 = CharacterWindupNextAction[temp1]         
          lda temp1
          asl
          tax
          lda CharacterWindupNextAction,x
          sta temp2
          lda temp2
          cmp # 255
          bne skip_360
          jmp VblankUpdateSprite
skip_360:


          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankHandleExecuteEnd
          ;; let temp1 = playerCharacter[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp1
          ;; if temp1 >= 32 then goto VblankUpdateSprite
          lda temp1
          cmp 32

          bcc skip_1472

          jmp skip_1472

          skip_1472:

          lda temp1
          cmp # 6
          bne skip_7575
          jmp VblankHarpyExecute
skip_7575:


          if temp1 >= 16 then let temp1 = 0
          lda temp1
          cmp # 17

          bcc skip_6145

          lda # 0

          sta .skip_6145

          label_unknown:
          ;; let temp2 = CharacterExecuteNextAction[temp1]         
          lda temp1
          asl
          tax
          lda CharacterExecuteNextAction,x
          sta temp2
          lda temp2
          cmp # 255
          bne skip_360
          jmp VblankUpdateSprite
skip_360:


          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

.pend

VblankHarpyExecute .proc
          ;; Harpy: Execute → Idle
          ;; Clear dive flag and stop diagonal movement when attack completes
          lda currentPlayer
          sta temp1
          ;; Clear dive flag (bit 4 in characterStateFlags)
          let C6E_stateFlags = 239 & characterStateFlags_R[temp1]
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          and # 239
          sta C6E_stateFlags
          lda temp1
          asl
          tax
          lda C6E_stateFlags
          sta characterStateFlags_W,x
          ;; Stop horizontal velocity (zero X velocity)
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          ;; Apply upward wing flap momentum after swoop attack
          lda temp1
          asl
          tax
          lda 254
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x
          ;; Transition to Idle
          lda ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankHandleRecoveryEnd
          ;; All characters: Recovery → Idle
          lda ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

.pend

VblankUpdateSprite .proc
          ;; Update character sprite with current animation frame and action
          ;; CRITICAL: Guard against calling bank 2 when no characters on screen
          ;; let currentCharacter = playerCharacter[currentPlayer]         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda currentCharacter
          cmp NoCharacter
          bne skip_7144
          jmp VblankAnimationNextPlayer
skip_7144:

          lda currentCharacter
          cmp CPUCharacter
          bne skip_480
          jmp VblankAnimationNextPlayer
skip_480:

          lda currentCharacter
          cmp RandomCharacter
          bne skip_8085
          jmp VblankAnimationNextPlayer
skip_8085:

          ;; CRITICAL: Validate character index is within valid range (0-MaxCharacter)
          ;; Uninitialized playerCharacter (0) is valid (Bernie), but values > MaxCharacter are invalid
          ;; if currentCharacter > MaxCharacter then goto VblankAnimationNextPlayer
          lda currentCharacter
          sec
          sbc MaxCharacter
          bcc skip_9310
          beq skip_9310
          jmp VblankAnimationNextPlayer
skip_9310:

          lda currentCharacter
          sec
          sbc MaxCharacter
          bcc skip_5976
          beq skip_5976
          jmp VblankAnimationNextPlayer
skip_5976:


                    ;; let temp2 = currentAnimationFrame_R[currentPlayer]
                    lda currentPlayer          asl          tax          lda currentAnimationFrame_R,x          sta temp2
          ;; let temp3 = currentAnimationSeq_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp3
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp3
          lda currentPlayer
          sta temp4
          ;; CRITICAL: Inlined LoadPlayerSprite dispatcher to save 4 bytes on sta

          lda currentCharacter
          sta temp1
          lda temp1
          sta temp6
          ;; Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          ;; if temp1 < 8 then goto VblankUpdateSprite_Bank2Dispatch          lda temp1          cmp 8          bcs .skip_680          jmp
          lda temp1
          cmp # 8
          bcs skip_9194
          goto_label:

          jmp goto_label
skip_9194:

          lda temp1
          cmp # 8
          bcs skip_9618
          jmp goto_label
skip_9618:

          

          ;; if temp1 < 16 then goto VblankUpdateSprite_Bank3Dispatch          lda temp1          cmp 16          bcs .skip_6822          jmp
          lda temp1
          cmp # 16
          bcs skip_7725
          jmp goto_label
skip_7725:

          lda temp1
          cmp # 16
          bcs skip_9622
          jmp goto_label
skip_9622:

          

          ;; if temp1 < 24 then goto VblankUpdateSprite_Bank4Dispatch          lda temp1          cmp 24          bcs .skip_5055          jmp
          lda temp1
          cmp # 24
          bcs skip_6786
          jmp goto_label
skip_6786:

          lda temp1
          cmp # 24
          bcs skip_9987
          jmp goto_label
skip_9987:

          

          jmp VblankUpdateSprite_Bank5Dispatch

VblankUpdateSprite_Bank2Dispatch
          lda temp1
          sta temp6
          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank2 in bank 2
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank2-1)
          pha
          lda # <(SetPlayerCharacterArtBank2-1)
          pha
                    ldx # 1
          jmp BS_jsr
return_point:


          jmp VblankAnimationNextPlayer

VblankUpdateSprite_Bank3Dispatch
          ;; let temp6 = temp1 - 8          lda temp1          sec          sbc 8          sta temp6
          lda temp1
          sec
          sbc 8
          sta temp6

          lda temp1
          sec
          sbc 8
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank3 in bank 3
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank3-1)
          pha
          lda # <(SetPlayerCharacterArtBank3-1)
          pha
                    ldx # 2
          jmp BS_jsr
return_point:


          jmp VblankAnimationNextPlayer

VblankUpdateSprite_Bank4Dispatch
          ;; let temp6 = temp1 - 16          lda temp1          sec          sbc 16          sta temp6
          lda temp1
          sec
          sbc 16
          sta temp6

          lda temp1
          sec
          sbc 16
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank4 in bank 4
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank4-1)
          pha
          lda # <(SetPlayerCharacterArtBank4-1)
          pha
                    ldx # 3
          jmp BS_jsr
return_point:


          jmp VblankAnimationNextPlayer

VblankUpdateSprite_Bank5Dispatch
          ;; let temp6 = temp1 - 24          lda temp1          sec          sbc 24          sta temp6
          lda temp1
          sec
          sbc 24
          sta temp6

          lda temp1
          sec
          sbc 24
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank5 in bank 5
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerCharacterArtBank5-1)
          pha
          lda # <(SetPlayerCharacterArtBank5-1)
          pha
                    ldx # 4
          jmp BS_jsr
return_point:


          jmp VblankAnimationNextPlayer

VblankAnimationNextPlayer
.pend

next_label_1_L950:.proc
          End of shared inlined UpdateCharacterAnimations code
          ;; For game mode, continue with additional game logic
          ;; For other modes, return immediately
          lda gameMode
          cmp ModeGame
          bne skip_3052
          jmp VblankModeGameMainAfterAnimations
skip_3052:


          rts

VblankModeGameMainAfterAnimations
          ;; Update movement system (full frame rate movement) (in Bank 8)
          ;; Cross-bank call to UpdatePlayerMovement in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdatePlayerMovement-1)
          pha
          lda # <(UpdatePlayerMovement-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:


          ;; Apply gravity and physics (in Bank 13)
          ;; Cross-bank call to PhysicsApplyGravity in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PhysicsApplyGravity-1)
          pha
          lda # <(PhysicsApplyGravity-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          ;; Apply momentum and recovery effects (in Bank 8)
          ;; Cross-bank call to ApplyMomentumAndRecovery in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ApplyMomentumAndRecovery-1)
          pha
          lda # <(ApplyMomentumAndRecovery-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:


          ;; Check boundary collisions (in Bank 10)
          ;; Cross-bank call to CheckBoundaryCollisions in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckBoundaryCollisions-1)
          pha
          lda # <(CheckBoundaryCollisions-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point:


          ;; Optimized: Single loop for playfield collisions (walls, ceilings, ground)
          ;; TODO: for currentPlayer = 0 to 3
          ;; if currentPlayer >= 2 then goto VblankCheckQuadtariSkip
          lda currentPlayer
          cmp 2

          bcc skip_7662

          jmp skip_7662

          skip_7662:

          jmp VblankProcessCollision

.pend

VblankCheckQuadtariSkip .proc
          ;; if controllerStatus & SetQuadtariDetected then goto VblankProcessCollision
          jmp VblankGameMainQuadtariSkip

VblankProcessCollision
          ;; Check for Radish Goblin bounce movement (ground and wall bounces)
          ;; Cross-bank call to CheckPlayfieldCollisionAllDirections in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckPlayfieldCollisionAllDirections-1)
          pha
          lda # <(CheckPlayfieldCollisionAllDirections-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point:


          ;; Cross-bank call to RadishGoblinCheckGroundBounce in bank 12
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RadishGoblinCheckGroundBounce-1)
          pha
          lda # <(RadishGoblinCheckGroundBounce-1)
          pha
                    ldx # 11
          jmp BS_jsr
return_point:


          ;; Cross-bank call to RadishGoblinCheckWallBounce in bank 12
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(RadishGoblinCheckWallBounce-1)
          pha
          lda # <(RadishGoblinCheckWallBounce-1)
          pha
                    ldx # 11
          jmp BS_jsr
return_point:


.pend

next_label_2_1_L1090:.proc

.pend

VblankGameMainQuadtariSkip .proc
          ;; Check multi-player collisions (in Bank 11)
          ;; Cross-bank call to CheckAllPlayerCollisions in bank 11
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckAllPlayerCollisions-1)
          pha
          lda # <(CheckAllPlayerCollisions-1)
          pha
                    ldx # 10
          jmp BS_jsr
return_point:


          ;; Process mêlée and area attack collisions (in Bank 7)
          ;; Cross-bank call to ProcessAllAttacks in bank 7
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ProcessAllAttacks-1)
          pha
          lda # <(ProcessAllAttacks-1)
          pha
                    ldx # 6
          jmp BS_jsr
return_point:


          ;; Check for player eliminations
          ;; Cross-bank call to CheckAllPlayerEliminations in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckAllPlayerEliminations-1)
          pha
          lda # <(CheckAllPlayerEliminations-1)
          pha
                    ldx # 13
          jmp BS_jsr
return_point:


          ;; Update missiles (in Bank 7)
          ;; Cross-bank call to UpdateAllMissiles in bank 7
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdateAllMissiles-1)
          pha
          lda # <(UpdateAllMissiles-1)
          pha
                    ldx # 6
          jmp BS_jsr
return_point:


          ;; Check if game should end and transition to winner screen
                    if systemFlags & SystemFlagGameStateEnding then VblankCheckGameEndTransition
          jmp VblankGameEndCheckDone

VblankCheckGameEndTransition
          ;; Check if game end timer should transition to winner screen
          ;; Returns: Near (return thisbank)
          ;; When timer reaches 0, transition to winner announcement
          lda gameEndTimer_R
          cmp # 0
          bne skip_3791
          ;; TODO: VblankTransitionToWinner
skip_3791:


          ;; Decrement game end timer
          lda gameEndTimer_R
          sec
          sbc # 1
          sta gameEndTimer_W
          jmp VblankGameEndCheckDone

VblankTransitionToWinner
          ;; Transition to winner announcement mode
          ;; Returns: Near (return thisbank)
          lda ModeWinner
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 14
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(ChangeGameMode-1)
          pha
          lda # <(ChangeGameMode-1)
          pha
                    ldx # 13
          jmp BS_jsr
return_point:


          rts

VblankGameEndCheckDone
          ;; Update missiles again (in Bank 7)
          ;; Cross-bank call to UpdateAllMissiles in bank 7
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdateAllMissiles-1)
          pha
          lda # <(UpdateAllMissiles-1)
          pha
                    ldx # 6
          jmp BS_jsr
return_point:


          ;; Check RoboTito stretch missile collisions (bank 7)
          ;; Cross-bank call to CheckRoboTitoStretchMissileCollisions in bank 10
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckRoboTitoStretchMissileCollisions-1)
          pha
          lda # <(CheckRoboTitoStretchMissileCollisions-1)
          pha
                    ldx # 9
          jmp BS_jsr
return_point:


          ;; Set sprite graphics (in Bank 6)
          ;; Cross-bank call to SetPlayerSprites in bank 6
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerSprites-1)
          pha
          lda # <(SetPlayerSprites-1)
          pha
                    ldx # 5
          jmp BS_jsr
return_point:


          ;; Display health information (in Bank 11)
          ;; Cross-bank call to DisplayHealth in bank 11
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(DisplayHealth-1)
          pha
          lda # <(DisplayHealth-1)
          pha
                    ldx # 10
          jmp BS_jsr
return_point:


          ;; Update P1/P2 health bars using pfscore system
          ;; Cross-bank call to UpdatePlayer12HealthBars in bank 11
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdatePlayer12HealthBars-1)
          pha
          lda # <(UpdatePlayer12HealthBars-1)
          pha
                    ldx # 10
          jmp BS_jsr
return_point:


          ;; Update P3/P4 health bars using playfield system
          ;; Cross-bank call to UpdatePlayer34HealthBars in bank 11
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(UpdatePlayer34HealthBars-1)
          pha
          lda # <(UpdatePlayer34HealthBars-1)
          pha
                    ldx # 10
          jmp BS_jsr
return_point:


          rts

.pend

VblankModeWinnerAnnouncement .proc
          ;; Winner Announcement vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet
          lda musicVoice0Pointer
          cmp # 0
          bne skip_2479
          jmp VblankWinnerAnnouncementSkipMusic
skip_2479:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayMusic-1)
          pha
          lda # <(PlayMusic-1)
          pha
                    ldx # 14
          jmp BS_jsr
return_point:


.pend

VblankWinnerAnnouncementSkipMusic .proc
          ;; Update character animations for winner screen
          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta


VblankHandlerDone
          ;; Vblank handler complete
          ;; Returns: Far (return otherbank)
          ;; Called via cross-bank call from VblankHandlerTrampoline, so must use return otherbank
          jsr BS_return
          ;; Note: vblank_bB_code constant is defined in Bank15.s pointing to VblankHandlerTrampoline
          ;; The trampoline calls this dispatcher via cross-bank call

.pend

