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

          ;; Optimized: Use on/cross-bank call to for space efficiency
          ;; CRITICAL: on gameMode cross-bank call to is a NEAR call (pushes normal 2-byte return address)
          ;; VblankHandlerDispatcher is called with cross-bank call (pushes 4-byte encoded return)
          ;; Mode handlers return with return thisbank (pops 2 bytes from near call)
          ;; VblankHandlerDispatcher must return with return otherbank (pops 4 bytes from cross-bank call)
          jsr VblankModePublisherPrelude
          ;; Execution continues at ongosub0 label
          jmp VblankHandlerDone

.pend

VblankModePublisherPrelude .proc
          ;; Publisher Prelude vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet (StartMusic sets it to songPointer)
          ;; On first frame, BeginPublisherPrelude hasn’t called StartMusic yet
          ;; Check if music is initialized before calling PlayMusic to prevent crash
          lda musicVoice0Pointer
          bne PlayPublisherPreludeMusic

          jmp VblankPublisherPreludeSkipMusic

PlayPublisherPreludeMusic:

          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 14
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterPlayMusicPublisherPrelude-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayMusicPublisherPrelude hi (encoded)]
          lda # <(AfterPlayMusicPublisherPrelude-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayMusicPublisherPrelude hi (encoded)] [SP+0: AfterPlayMusicPublisherPrelude lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayMusic-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayMusicPublisherPrelude hi (encoded)] [SP+1: AfterPlayMusicPublisherPrelude lo] [SP+0: PlayMusic hi (raw)]
          lda # <(PlayMusic-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayMusicPublisherPrelude hi (encoded)] [SP+2: AfterPlayMusicPublisherPrelude lo] [SP+1: PlayMusic hi (raw)] [SP+0: PlayMusic lo]
          ldx # 14
          jmp BS_jsr

AfterPlayMusicPublisherPrelude:


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
          bne PlayAuthorPreludeMusic
          jmp VblankAuthorPreludeSkipMusic
PlayAuthorPreludeMusic:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 14
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterPlayMusicAuthorPrelude-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayMusicAuthorPrelude hi (encoded)]
          lda # <(AfterPlayMusicAuthorPrelude-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayMusicAuthorPrelude hi (encoded)] [SP+0: AfterPlayMusicAuthorPrelude lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayMusic-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayMusicAuthorPrelude hi (encoded)] [SP+1: AfterPlayMusicAuthorPrelude lo] [SP+0: PlayMusic hi (raw)]
          lda # <(PlayMusic-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayMusicAuthorPrelude hi (encoded)] [SP+2: AfterPlayMusicAuthorPrelude lo] [SP+1: PlayMusic hi (raw)] [SP+0: PlayMusic lo]
          ldx # 14
          jmp BS_jsr
AfterPlayMusicAuthorPrelude:


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
          bne PlayTitleScreenMusic
          jmp VblankTitleScreenSkipMusic
PlayTitleScreenMusic:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 14
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterPlayMusicTitleScreen-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayMusicTitleScreen hi (encoded)]
          lda # <(AfterPlayMusicTitleScreen-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayMusicTitleScreen hi (encoded)] [SP+0: AfterPlayMusicTitleScreen lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayMusic-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayMusicTitleScreen hi (encoded)] [SP+1: AfterPlayMusicTitleScreen lo] [SP+0: PlayMusic hi (raw)]
          lda # <(PlayMusic-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayMusicTitleScreen hi (encoded)] [SP+2: AfterPlayMusicTitleScreen lo] [SP+1: PlayMusic hi (raw)] [SP+0: PlayMusic lo]
          ldx # 14
          jmp BS_jsr
AfterPlayMusicTitleScreen:


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
          bne VblankModeGameMainDone
          jmp VblankModeGameMainContinue
VblankModeGameMainDone:


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
          ;; UpdatePlayer12HealthBars, UpdatePlayer34HealthBars
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

          ;; VblankUCA_quadtariActive uses temp5 directly (no dim needed)
          lda controllerStatus
          and # SetQuadtariDetected
          sta VblankUCA_quadtariActive
          ;; Issue #1254: Loop through currentPlayer = 3 downto 0
          lda # 3
          sta currentPlayer
VUCA_Loop:
          ;; if currentPlayer >= 2 && !VblankUCA_quadtariActive then jmp VblankAnimationNextPlayer
          lda currentPlayer
          cmp # 3
          bcc CheckPlayerHealth
          lda VblankUCA_quadtariActive
          bne CheckPlayerHealth
          jmp VblankAnimationNextPlayer
CheckPlayerHealth:

          lda currentPlayer
          cmp # 3
          bcc UpdateAnimationCounter
          lda VblankUCA_quadtariActive
          bne UpdateAnimationCounter
          jmp VblankAnimationNextPlayer
UpdateAnimationCounter:



          ;; Skip if player is eliminated (health = 0)
          ;; if playerHealth[currentPlayer] = 0 then jmp VblankAnimationNextPlayer
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          bne AdvanceAnimationFrame
          jmp VblankAnimationNextPlayer
AdvanceAnimationFrame:

          ;; Increment this sprite 10fps animation counter (NOT global frame counter)
          ;; SCRAM read-modify-write: animationCounter_R → animationCounter_W
          ;; Set temp4 = animationCounter_R[currentPlayer] + 1
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
          ;; if temp4 < AnimationFrameDelay then jmp VblankDoneAdvanceInlined
          lda temp4
          cmp # AnimationFrameDelay
          bcs VblankAdvanceFrame
          jmp VblankDoneAdvanceInlined
VblankAdvanceFrame:
          

.pend

VblankAdvanceFrame .proc
          lda currentPlayer
          asl
          tax
          lda # 0
          sta animationCounter_W,x
          ;; Advance to next frame in current animation action
          ;; SCRAM read-modify-write: currentAnimationFrame_R → currentAnimationFrame_W
          ;; Set temp4 = currentAnimationFrame_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda currentAnimationFrame_R,x
          sta temp4
          ;; Set temp4 = 1 + temp4
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
          ;; if temp4 >= FramesPerSequence then jmp VblankHandleFrame7Transition
          lda temp4
          cmp # FramesPerSequence

          bcc VblankUpdateSprite

          jmp VblankUpdateSprite

          VblankUpdateSprite:

          jmp VblankUpdateSprite

VblankDoneAdvanceInlined
          jmp VblankAnimationNextPlayer

VblankHandleFrame7Transition
          ;; Frame 7 completed, handle action-specific transitions
          ;; CRITICAL: Inlined HandleAnimationTransition to save 4 bytes on sta

          ;; (was: cross-bank call to HandleAnimationTransition bank12)
          ;; Set temp1 = currentAnimationSeq_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          ;; if ActionAttackRecovery < temp1 then jmp VblankTransitionLoopAnimation
          lda # ActionAttackRecovery
          cmp temp1
          bcs TransitionToLoopAnimation
          jmp VblankTransitionLoopAnimation
TransitionToLoopAnimation:
          

          jmp VblankTransitionLoopAnimation

VblankTransitionLoopAnimation
          lda currentPlayer
          asl
          tax
          lda # 0
          sta currentAnimationFrame_W,x
          jmp VblankUpdateSprite

VblankTransitionToIdle
          lda # ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionToFallen
          lda # ActionFallen
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleJump
          ;; Stay on frame 7 until Y velocity goes negative
          ;; If 0 < playerVelocityY[currentPlayer], then VblankTransitionHandleJumpTransitionToFalling
          lda currentPlayer
          asl
          tax
          lda playerVelocityY,x
          cmp # 1

          bcc TransitionToJumping

          jmp TransitionToJumping

          TransitionToJumping:

          lda # ActionJumping
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleJumpTransitionToFalling
          ;; Falling (positive Y velocity), transition to falling
          lda # ActionFalling
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleFallBack
          ;; Check wall collision using pfread
          ;; Convert player X position to playfield column (0-31)
                    ;; Set temp5 = playerX[currentPlayer]
                    lda currentPlayer          asl          tax          lda playerX,x          sta temp5
          ;; Set temp5 = temp5 - ScreenInsetX          lda temp5          sec          sbc # ScreenInsetX          sta temp5
          lda temp5
          sec
          sbc # ScreenInsetX
          sta temp5

          lda temp5
          sec
          sbc # ScreenInsetX
          sta temp5

          ;; Set temp5 = temp5 / 4          lda temp5          lsr          lsr          sta temp5
          lda temp5
          lsr
          lsr
          sta temp5

          lda temp5
          lsr
          lsr
          sta temp5

          ;; Convert player Y position to playfield row (0-7)
          ;; Set temp6 = playerY[currentPlayer]
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
          ;; Set temp6 = temp6 / 8          lda temp6          lsr          lsr          lsr          sta temp6
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
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterPlayfieldReadVblank-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadVblank hi (encoded)]
          lda # <(AfterPlayfieldReadVblank-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadVblank hi (encoded)] [SP+0: AfterPlayfieldReadVblank lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadVblank hi (encoded)] [SP+1: AfterPlayfieldReadVblank lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadVblank hi (encoded)] [SP+2: AfterPlayfieldReadVblank lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
          ldx # 15
          jmp BS_jsr
AfterPlayfieldReadVblank:


          lda temp3
          sta temp2
          if temp1 then VblankTransitionHandleFallBackHitWall
          lda temp1
          beq TransitionToFallen
          jmp VblankTransitionHandleFallBackHitWall
TransitionToFallen:
          

          ;; No wall collision, transition to fallen
          lda # ActionFallen
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankTransitionHandleFallBackHitWall
          ;; Hit wall, transition to idle
          lda # ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankSetPlayerAnimationInlined
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; Set animation action for a player (inlined from AnimationSystem.bas)
          ;; if temp2 >= AnimationSequenceCount then jmp VblankUpdateSprite
          lda temp2
          cmp # AnimationSequenceCount

          bcc SetAnimationSequence

          jmp SetAnimationSequence

          SetAnimationSequence:

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
          lda # 0
          sta currentAnimationFrame_W,x
          ;; SCRAM write to animationCounter_W
          ;; Reset animation counter
          lda currentPlayer
          asl
          tax
          lda # 0
          sta animationCounter_W,x
          ;; Update character sprite immediately using inlined LoadPlayerSprite logic
          ;; Set up parameters for sprite loading (frame=0, action=temp2, player=currentPlayer)
          lda # 0
          sta temp2
                    ;; Set temp3 = currentAnimationSeq_R[currentPlayer]
                    lda currentPlayer          asl          tax          lda currentAnimationSeq_R,x          sta temp3
          lda currentPlayer
          sta temp4
          ;; Fall through to VblankUpdateSprite which has inlined LoadPlayerSprite logic

VblankHandleAttackTransition
          ;; Set temp1 = currentAnimationSeq_R[currentPlayer]
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
          ;; if temp1 < ActionAttackWindup then jmp VblankUpdateSprite
          lda temp1
          cmp # ActionAttackWindup
          bcs HandleWindupEnd
          jmp VblankUpdateSprite
HandleWindupEnd:
          ;; Set temp1 = temp1 - ActionAttackWindup
          lda temp1
          sec
          sbc # ActionAttackWindup
          sta temp1
          jmp VblankHandleWindupEnd

          jmp VblankUpdateSprite

VblankHandleWindupEnd
          ;; Set temp1 = playerCharacter[currentPlayer]
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
          ;; if temp1 >= 32 then jmp VblankUpdateSprite
          lda temp1
          cmp # 32

          bcc CheckWindupNextAction

          jmp CheckWindupNextAction

          CheckWindupNextAction:
          ;; If temp1 >= 16, set temp1 = 0
          lda temp1
          cmp # 16
          bcc GetWindupNextActionCheck
          lda # 0
          sta temp1
GetWindupNextActionCheck:

          lda # 0

          sta .GetWindupNextAction

GetWindupNextAction:
          ;; Set temp2 = CharacterWindupNextAction[temp1]
          lda temp1
          asl
          tax
          lda CharacterWindupNextAction,x
          sta temp2
          lda temp2
          cmp # 255
          bne SetWindupAnimation
          jmp VblankUpdateSprite
SetWindupAnimation:


          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankHandleExecuteEnd
          ;; Set temp1 = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp1
          ;; if temp1 >= 32 then jmp VblankUpdateSprite
          lda temp1
          cmp # 32

          bcc CheckExecuteNextAction

          jmp CheckExecuteNextAction

          CheckExecuteNextAction:

          lda temp1
          cmp # 6
          bne GetExecuteNextActionCheck
          jmp VblankHarpyExecute
GetExecuteNextActionCheck:


          if temp1 >= 16 then let temp1 = 0
          lda temp1
          cmp # 17

          bcc skip_6145

          lda # 0

          sta .skip_6145

GetExecuteNextAction:
          ;; Set temp2 = CharacterExecuteNextAction[temp1]
          lda temp1
          asl
          tax
          lda CharacterExecuteNextAction,x
          sta temp2
          lda temp2
          cmp # 255
          bne SetExecuteAnimation
          jmp VblankUpdateSprite
SetExecuteAnimation:


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
          lda # 0
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          ;; Apply upward wing flap momentum after swoop attack
          lda temp1
          asl
          tax
          lda # 254
          sta playerVelocityY,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; Transition to Idle
          lda # ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

VblankHandleRecoveryEnd
          ;; All characters: Recovery → Idle
          lda # ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp VblankSetPlayerAnimationInlined

.pend

VblankUpdateSprite .proc
          ;; Update character sprite with current animation frame and action
          ;; CRITICAL: Guard against calling bank 2 when no characters on screen
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda currentCharacter
          cmp # NoCharacter
          bne CheckCPUCharacter
          jmp VblankAnimationNextPlayer
CheckCPUCharacter:

          lda currentCharacter
          cmp # CPUCharacter
          bne CheckRandomCharacter
          jmp VblankAnimationNextPlayer
CheckRandomCharacter:

          lda currentCharacter
          cmp # RandomCharacter
          bne ValidateCharacterRange
          jmp VblankAnimationNextPlayer
ValidateCharacterRange:

          ;; CRITICAL: Validate character index is within valid range (0-MaxCharacter)
          ;; Uninitialized playerCharacter (0) is valid (Bernie), but values > MaxCharacter are invalid
          ;; if currentCharacter > MaxCharacter then jmp VblankAnimationNextPlayer
          lda currentCharacter
          sec
          sbc # MaxCharacter
          bcc LoadSpriteFrame
          beq LoadSpriteFrame
          jmp VblankAnimationNextPlayer
LoadSpriteFrame:

          lda currentCharacter
          sec
          sbc # MaxCharacter
          bcc DetermineSpriteBank
          beq DetermineSpriteBank
          jmp VblankAnimationNextPlayer
DetermineSpriteBank:


                    ;; Set temp2 = currentAnimationFrame_R[currentPlayer]
                    lda currentPlayer          asl          tax          lda currentAnimationFrame_R,x          sta temp2
          ;; Set temp3 = currentAnimationSeq_R[currentPlayer]
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
          ;; if temp1 < 8 then jmp VblankUpdateSpriteBank2Dispatch          lda temp1          cmp 8          bcs .skip_680          jmp
          lda temp1
          cmp # 8
          bcs CheckBank3
          goto_label:

          jmp goto_label
CheckBank3:

          lda temp1
          cmp # 8
          bcs CheckBank3Dispatch
          jmp goto_label
CheckBank3Dispatch:

          

          ;; if temp1 < 16 then jmp VblankUpdateSpriteBank3Dispatch          lda temp1          cmp 16          bcs .skip_6822          jmp
          lda temp1
          cmp # 16
          bcs CheckBank4
          jmp goto_label
CheckBank4:

          lda temp1
          cmp # 16
          bcs CheckBank4Dispatch
          jmp goto_label
CheckBank4Dispatch:

          

          ;; if temp1 < 24 then jmp VblankUpdateSpriteBank4Dispatch          lda temp1          cmp # 24          bcs .skip_5055          jmp
          lda temp1
          cmp # 24
          bcs UseBank5
          jmp goto_label
UseBank5:

          lda temp1
          cmp # 24
          bcs UseBank5Dispatch
          jmp goto_label
UseBank5Dispatch:

          

          jmp VblankUpdateSpriteBank5Dispatch

VblankUpdateSpriteBank2Dispatch
          lda temp1
          sta temp6
          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank2 in bank 2
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank2Vblank-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank2Vblank hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank2Vblank-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank2Vblank hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank2Vblank lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank2-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank2Vblank hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank2Vblank lo] [SP+0: SetPlayerCharacterArtBank2 hi (raw)]
          lda # <(SetPlayerCharacterArtBank2-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank2Vblank hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank2Vblank lo] [SP+1: SetPlayerCharacterArtBank2 hi (raw)] [SP+0: SetPlayerCharacterArtBank2 lo]
          ldx # 1
          jmp BS_jsr
AfterSetPlayerCharacterArtBank2Vblank:


          jmp VblankAnimationNextPlayer

VblankUpdateSpriteBank3Dispatch
          ;; Set temp6 = temp1 - 8          lda temp1          sec          sbc # 8          sta temp6
          lda temp1
          sec
          sbc # 8
          sta temp6

          lda temp1
          sec
          sbc # 8
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank3 in bank 3
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank3Vblank-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank3Vblank hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank3Vblank-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank3Vblank hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank3Vblank lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank3-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank3Vblank hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank3Vblank lo] [SP+0: SetPlayerCharacterArtBank3 hi (raw)]
          lda # <(SetPlayerCharacterArtBank3-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank3Vblank hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank3Vblank lo] [SP+1: SetPlayerCharacterArtBank3 hi (raw)] [SP+0: SetPlayerCharacterArtBank3 lo]
          ldx # 2
          jmp BS_jsr
AfterSetPlayerCharacterArtBank3Vblank:


          jmp VblankAnimationNextPlayer

VblankUpdateSpriteBank4Dispatch
          ;; Set temp6 = temp1 - 16          lda temp1          sec          sbc 16          sta temp6
          lda temp1
          sec
          sbc # 16
          sta temp6

          lda temp1
          sec
          sbc # 16
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank4 in bank 4
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank4Vblank-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank4Vblank hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank4Vblank-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank4Vblank hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank4Vblank lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank4-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank4Vblank hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank4Vblank lo] [SP+0: SetPlayerCharacterArtBank4 hi (raw)]
          lda # <(SetPlayerCharacterArtBank4-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank4Vblank hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank4Vblank lo] [SP+1: SetPlayerCharacterArtBank4 hi (raw)] [SP+0: SetPlayerCharacterArtBank4 lo]
          ldx # 3
          jmp BS_jsr
AfterSetPlayerCharacterArtBank4Vblank:


          jmp VblankAnimationNextPlayer

VblankUpdateSpriteBank5Dispatch
          ;; Set temp6 = temp1 - 24          lda temp1          sec          sbc # 24          sta temp6
          lda temp1
          sec
          sbc # 24
          sta temp6

          lda temp1
          sec
          sbc # 24
          sta temp6

          lda temp4
          sta temp5
          ;; Cross-bank call to SetPlayerCharacterArtBank5 in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterSetPlayerCharacterArtBank5Vblank-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerCharacterArtBank5Vblank hi (encoded)]
          lda # <(AfterSetPlayerCharacterArtBank5Vblank-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerCharacterArtBank5Vblank hi (encoded)] [SP+0: AfterSetPlayerCharacterArtBank5Vblank lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerCharacterArtBank5-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerCharacterArtBank5Vblank hi (encoded)] [SP+1: AfterSetPlayerCharacterArtBank5Vblank lo] [SP+0: SetPlayerCharacterArtBank5 hi (raw)]
          lda # <(SetPlayerCharacterArtBank5-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerCharacterArtBank5Vblank hi (encoded)] [SP+2: AfterSetPlayerCharacterArtBank5Vblank lo] [SP+1: SetPlayerCharacterArtBank5 hi (raw)] [SP+0: SetPlayerCharacterArtBank5 lo]
          ldx # 4
          jmp BS_jsr
AfterSetPlayerCharacterArtBank5Vblank:


          jmp VblankAnimationNextPlayer

VblankAnimationNextPlayer:
          ;; Issue #1254: Loop decrement and check (count down from 3 to 0)
          dec currentPlayer
          bpl VUCA_Loop
.pend

VblankGameModeCheck .proc
          ;; End of shared inlined UpdateCharacterAnimations code
          ;; For game mode, continue with additional game logic
          ;; For other modes, return immediately
          lda gameMode
          cmp # ModeGame
          bne VblankHandlerDoneCheck
          jmp VblankModeGameMainAfterAnimations
VblankHandlerDoneCheck:


          rts

VblankModeGameMainAfterAnimations
          ;; Update movement system (full frame rate movement) (in Bank 8)
          ;; Cross-bank call to UpdatePlayerMovement in bank 7
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterUpdatePlayerMovement-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdatePlayerMovement hi (encoded)]
          lda # <(AfterUpdatePlayerMovement-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdatePlayerMovement hi (encoded)] [SP+0: AfterUpdatePlayerMovement lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdatePlayerMovement-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdatePlayerMovement hi (encoded)] [SP+1: AfterUpdatePlayerMovement lo] [SP+0: UpdatePlayerMovement hi (raw)]
          lda # <(UpdatePlayerMovement-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdatePlayerMovement hi (encoded)] [SP+2: AfterUpdatePlayerMovement lo] [SP+1: UpdatePlayerMovement hi (raw)] [SP+0: UpdatePlayerMovement lo]
          ldx # 7
          jmp BS_jsr
AfterUpdatePlayerMovement:
AfterUpdatePlayerMovementVblank:


          ;; Apply gravity and physics (in Bank 13)
          ;; Cross-bank call to PhysicsApplyGravity in bank 12
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterPhysicsApplyGravity-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPhysicsApplyGravity hi (encoded)]
          lda # <(AfterPhysicsApplyGravity-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPhysicsApplyGravity hi (encoded)] [SP+0: AfterPhysicsApplyGravity lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PhysicsApplyGravity-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPhysicsApplyGravity hi (encoded)] [SP+1: AfterPhysicsApplyGravity lo] [SP+0: PhysicsApplyGravity hi (raw)]
          lda # <(PhysicsApplyGravity-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPhysicsApplyGravity hi (encoded)] [SP+2: AfterPhysicsApplyGravity lo] [SP+1: PhysicsApplyGravity hi (raw)] [SP+0: PhysicsApplyGravity lo]
          ldx # 12
          jmp BS_jsr
AfterPhysicsApplyGravity:


          ;; Apply momentum and recovery effects (in Bank 8)
          ;; Cross-bank call to ApplyMomentumAndRecovery in bank 7
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterApplyMomentumAndRecovery-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterApplyMomentumAndRecovery hi (encoded)]
          lda # <(AfterApplyMomentumAndRecovery-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterApplyMomentumAndRecovery hi (encoded)] [SP+0: AfterApplyMomentumAndRecovery lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ApplyMomentumAndRecovery-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterApplyMomentumAndRecovery hi (encoded)] [SP+1: AfterApplyMomentumAndRecovery lo] [SP+0: ApplyMomentumAndRecovery hi (raw)]
          lda # <(ApplyMomentumAndRecovery-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterApplyMomentumAndRecovery hi (encoded)] [SP+2: AfterApplyMomentumAndRecovery lo] [SP+1: ApplyMomentumAndRecovery hi (raw)] [SP+0: ApplyMomentumAndRecovery lo]
          ldx # 7
          jmp BS_jsr
AfterApplyMomentumAndRecovery:


          ;; Check boundary collisions (in Bank 10)
          ;; Cross-bank call to CheckBoundaryCollisions in bank 9
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterCheckBoundaryCollisions-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckBoundaryCollisions hi (encoded)]
          lda # <(AfterCheckBoundaryCollisions-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckBoundaryCollisions hi (encoded)] [SP+0: AfterCheckBoundaryCollisions lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckBoundaryCollisions-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckBoundaryCollisions hi (encoded)] [SP+1: AfterCheckBoundaryCollisions lo] [SP+0: CheckBoundaryCollisions hi (raw)]
          lda # <(CheckBoundaryCollisions-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckBoundaryCollisions hi (encoded)] [SP+2: AfterCheckBoundaryCollisions lo] [SP+1: CheckBoundaryCollisions hi (raw)] [SP+0: CheckBoundaryCollisions lo]
          ldx # 9
          jmp BS_jsr
AfterCheckBoundaryCollisions:


          ;; Optimized: Single loop for playfield collisions (walls, ceilings, ground)
          ;; Issue #1254: Loop through currentPlayer = 3 downto 0
          lda # 3
          sta currentPlayer
VPC_Loop:
          ;; if currentPlayer >= 2 then check Quadtari status
          lda currentPlayer
          cmp # 2
          bcc VblankProcessCollision
          ;; currentPlayer >= 2, check if Quadtari detected
          lda controllerStatus
          and # SetQuadtariDetected
          bne VblankProcessCollision
          ;; No Quadtari - skip players 2-3 collision checks
          jmp VblankGameMainQuadtariCheckDone

VblankProcessCollision:
          ;; Check for Radish Goblin bounce movement (ground and wall bounces)
          ;; Cross-bank call to CheckPlayfieldCollisionAllDirections in bank 9
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterCheckPlayfieldCollisionAllDirections-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckPlayfieldCollisionAllDirections hi (encoded)]
          lda # <(AfterCheckPlayfieldCollisionAllDirections-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckPlayfieldCollisionAllDirections hi (encoded)] [SP+0: AfterCheckPlayfieldCollisionAllDirections lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckPlayfieldCollisionAllDirections-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckPlayfieldCollisionAllDirections hi (encoded)] [SP+1: AfterCheckPlayfieldCollisionAllDirections lo] [SP+0: CheckPlayfieldCollisionAllDirections hi (raw)]
          lda # <(CheckPlayfieldCollisionAllDirections-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckPlayfieldCollisionAllDirections hi (encoded)] [SP+2: AfterCheckPlayfieldCollisionAllDirections lo] [SP+1: CheckPlayfieldCollisionAllDirections hi (raw)] [SP+0: CheckPlayfieldCollisionAllDirections lo]
          ldx # 9
          jmp BS_jsr
AfterCheckPlayfieldCollisionAllDirections:


          ;; Cross-bank call to RadishGoblinCheckGroundBounce in bank 11
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterRadishGoblinCheckGroundBounce-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRadishGoblinCheckGroundBounce hi (encoded)]
          lda # <(AfterRadishGoblinCheckGroundBounce-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRadishGoblinCheckGroundBounce hi (encoded)] [SP+0: AfterRadishGoblinCheckGroundBounce lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RadishGoblinCheckGroundBounce-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRadishGoblinCheckGroundBounce hi (encoded)] [SP+1: AfterRadishGoblinCheckGroundBounce lo] [SP+0: RadishGoblinCheckGroundBounce hi (raw)]
          lda # <(RadishGoblinCheckGroundBounce-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRadishGoblinCheckGroundBounce hi (encoded)] [SP+2: AfterRadishGoblinCheckGroundBounce lo] [SP+1: RadishGoblinCheckGroundBounce hi (raw)] [SP+0: RadishGoblinCheckGroundBounce lo]
          ldx # 11
          jmp BS_jsr
AfterRadishGoblinCheckGroundBounce:


          ;; Cross-bank call to RadishGoblinCheckWallBounce in bank 11
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterRadishGoblinCheckWallBounce-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRadishGoblinCheckWallBounce hi (encoded)]
          lda # <(AfterRadishGoblinCheckWallBounce-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRadishGoblinCheckWallBounce hi (encoded)] [SP+0: AfterRadishGoblinCheckWallBounce lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RadishGoblinCheckWallBounce-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRadishGoblinCheckWallBounce hi (encoded)] [SP+1: AfterRadishGoblinCheckWallBounce lo] [SP+0: RadishGoblinCheckWallBounce hi (raw)]
          lda # <(RadishGoblinCheckWallBounce-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRadishGoblinCheckWallBounce hi (encoded)] [SP+2: AfterRadishGoblinCheckWallBounce lo] [SP+1: RadishGoblinCheckWallBounce hi (raw)] [SP+0: RadishGoblinCheckWallBounce lo]
          ldx # 11
          jmp BS_jsr
AfterRadishGoblinCheckWallBounce:


.pend

VblankGameMainQuadtariCheckDone .proc
          ;; Issue #1254: Loop decrement and check (count down from 3 to 0)
          dec currentPlayer
          bpl VPC_Loop

.pend

VblankGameMainQuadtariSkip .proc
          ;; Check multi-player collisions (in Bank 11)
          ;; Cross-bank call to CheckAllPlayerCollisions in bank 10
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterCheckAllPlayerCollisions-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckAllPlayerCollisions hi (encoded)]
          lda # <(AfterCheckAllPlayerCollisions-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckAllPlayerCollisions hi (encoded)] [SP+0: AfterCheckAllPlayerCollisions lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckAllPlayerCollisions-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckAllPlayerCollisions hi (encoded)] [SP+1: AfterCheckAllPlayerCollisions lo] [SP+0: CheckAllPlayerCollisions hi (raw)]
          lda # <(CheckAllPlayerCollisions-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckAllPlayerCollisions hi (encoded)] [SP+2: AfterCheckAllPlayerCollisions lo] [SP+1: CheckAllPlayerCollisions hi (raw)] [SP+0: CheckAllPlayerCollisions lo]
          ldx # 10
          jmp BS_jsr
AfterCheckAllPlayerCollisions:


          ;; Process mêlée and area attack collisions (in Bank 7)
          ;; Cross-bank call to ProcessAllAttacks in bank 6
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterProcessAllAttacks-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterProcessAllAttacks hi (encoded)]
          lda # <(AfterProcessAllAttacks-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterProcessAllAttacks hi (encoded)] [SP+0: AfterProcessAllAttacks lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ProcessAllAttacks-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterProcessAllAttacks hi (encoded)] [SP+1: AfterProcessAllAttacks lo] [SP+0: ProcessAllAttacks hi (raw)]
          lda # <(ProcessAllAttacks-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterProcessAllAttacks hi (encoded)] [SP+2: AfterProcessAllAttacks lo] [SP+1: ProcessAllAttacks hi (raw)] [SP+0: ProcessAllAttacks lo]
          ldx # 6
          jmp BS_jsr
AfterProcessAllAttacks:


          ;; Check for player eliminations
          ;; Cross-bank call to CheckAllPlayerEliminations in bank 13
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterCheckAllPlayerEliminations-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckAllPlayerEliminations hi (encoded)]
          lda # <(AfterCheckAllPlayerEliminations-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckAllPlayerEliminations hi (encoded)] [SP+0: AfterCheckAllPlayerEliminations lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckAllPlayerEliminations-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckAllPlayerEliminations hi (encoded)] [SP+1: AfterCheckAllPlayerEliminations lo] [SP+0: CheckAllPlayerEliminations hi (raw)]
          lda # <(CheckAllPlayerEliminations-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckAllPlayerEliminations hi (encoded)] [SP+2: AfterCheckAllPlayerEliminations lo] [SP+1: CheckAllPlayerEliminations hi (raw)] [SP+0: CheckAllPlayerEliminations lo]
          ldx # 13
          jmp BS_jsr
AfterCheckAllPlayerEliminations:


          ;; Update missiles (in Bank 6)
          ;; Cross-bank call to UpdateAllMissiles in bank 6
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterUpdateAllMissiles-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdateAllMissiles hi (encoded)]
          lda # <(AfterUpdateAllMissiles-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdateAllMissiles hi (encoded)] [SP+0: AfterUpdateAllMissiles lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdateAllMissiles-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdateAllMissiles hi (encoded)] [SP+1: AfterUpdateAllMissiles lo] [SP+0: UpdateAllMissiles hi (raw)]
          lda # <(UpdateAllMissiles-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdateAllMissiles hi (encoded)] [SP+2: AfterUpdateAllMissiles lo] [SP+1: UpdateAllMissiles hi (raw)] [SP+0: UpdateAllMissiles lo]
          ldx # 6
          jmp BS_jsr
AfterUpdateAllMissiles:


          ;; Check if game should end and transition to winner screen
          ;; If systemFlags & SystemFlagGameStateEnding, then VblankCheckGameEndTransition
          lda systemFlags
          and # SystemFlagGameStateEnding
          beq VblankGameEndCheckDone
          jmp VblankCheckGameEndTransition
VblankGameEndCheckDone:

VblankCheckGameEndTransition
          ;; Check if game end timer should transition to winner screen
          ;; Returns: Near (return thisbank)
          ;; When timer reaches 0, transition to winner announcement
          lda gameEndTimer_R
          bne DecrementGameEndTimer
          jsr VblankTransitionToWinner
          jmp VblankGameEndCheckDone
DecrementGameEndTimer:


          ;; Decrement game end timer
          lda gameEndTimer_R
          sec
          sbc # 1
          sta gameEndTimer_W
          jmp VblankGameEndCheckDone

VblankTransitionToWinner
          ;; Transition to winner announcement mode
          ;; Returns: Near (return thisbank)
          lda # ModeWinner
          sta gameMode
          ;; Cross-bank call to ChangeGameMode in bank 13
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterChangeGameModeToWinner-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterChangeGameModeToWinner hi (encoded)]
          lda # <(AfterChangeGameModeToWinner-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterChangeGameModeToWinner hi (encoded)] [SP+0: AfterChangeGameModeToWinner lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterChangeGameModeToWinner hi (encoded)] [SP+1: AfterChangeGameModeToWinner lo] [SP+0: ChangeGameMode hi (raw)]
          lda # <(ChangeGameMode-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterChangeGameModeToWinner hi (encoded)] [SP+2: AfterChangeGameModeToWinner lo] [SP+1: ChangeGameMode hi (raw)] [SP+0: ChangeGameMode lo]
          ldx # 13
          jmp BS_jsr
AfterChangeGameModeToWinner:


          rts

VblankGameEndCheckDone
          ;; Update missiles again (in Bank 6)
          ;; Cross-bank call to UpdateAllMissiles in bank 6
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterUpdateAllMissilesSecond-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdateAllMissilesSecond hi (encoded)]
          lda # <(AfterUpdateAllMissilesSecond-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdateAllMissilesSecond hi (encoded)] [SP+0: AfterUpdateAllMissilesSecond lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdateAllMissiles-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdateAllMissilesSecond hi (encoded)] [SP+1: AfterUpdateAllMissilesSecond lo] [SP+0: UpdateAllMissiles hi (raw)]
          lda # <(UpdateAllMissiles-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdateAllMissilesSecond hi (encoded)] [SP+2: AfterUpdateAllMissilesSecond lo] [SP+1: UpdateAllMissiles hi (raw)] [SP+0: UpdateAllMissiles lo]
          ldx # 6
          jmp BS_jsr
AfterUpdateAllMissilesSecond:


          ;; Check RoboTito stretch missile collisions (bank 9)
          ;; Cross-bank call to CheckRoboTitoStretchMissileCollisions in bank 9
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterCheckRoboTitoStretchMissileCollisions-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterCheckRoboTitoStretchMissileCollisions hi (encoded)]
          lda # <(AfterCheckRoboTitoStretchMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterCheckRoboTitoStretchMissileCollisions hi (encoded)] [SP+0: AfterCheckRoboTitoStretchMissileCollisions lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(CheckRoboTitoStretchMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterCheckRoboTitoStretchMissileCollisions hi (encoded)] [SP+1: AfterCheckRoboTitoStretchMissileCollisions lo] [SP+0: CheckRoboTitoStretchMissileCollisions hi (raw)]
          lda # <(CheckRoboTitoStretchMissileCollisions-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterCheckRoboTitoStretchMissileCollisions hi (encoded)] [SP+2: AfterCheckRoboTitoStretchMissileCollisions lo] [SP+1: CheckRoboTitoStretchMissileCollisions hi (raw)] [SP+0: CheckRoboTitoStretchMissileCollisions lo]
          ldx # 9
          jmp BS_jsr
AfterCheckRoboTitoStretchMissileCollisions:


          ;; Set sprite graphics (in Bank 5)
          ;; Cross-bank call to SetPlayerSprites in bank 5
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterSetPlayerSprites-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSetPlayerSprites hi (encoded)]
          lda # <(AfterSetPlayerSprites-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSetPlayerSprites hi (encoded)] [SP+0: AfterSetPlayerSprites lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SetPlayerSprites-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSetPlayerSprites hi (encoded)] [SP+1: AfterSetPlayerSprites lo] [SP+0: SetPlayerSprites hi (raw)]
          lda # <(SetPlayerSprites-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSetPlayerSprites hi (encoded)] [SP+2: AfterSetPlayerSprites lo] [SP+1: SetPlayerSprites hi (raw)] [SP+0: SetPlayerSprites lo]
          ldx # 5
          jmp BS_jsr
AfterSetPlayerSprites:


          ;; Health display is handled by UpdatePlayer12HealthBars and


          ;; Update P1/P2 health bars using pfscore system
          ;; Cross-bank call to UpdatePlayer12HealthBars in bank 11
          lda # >(AfterUpdatePlayer12HealthBars-1)
          pha
          lda # <(AfterUpdatePlayer12HealthBars-1)
          pha
          lda # >(UpdatePlayer12HealthBars-1)
          pha
          lda # <(UpdatePlayer12HealthBars-1)
          pha
                    ldx # 10
          jmp BS_jsr
AfterUpdatePlayer12HealthBars:


          ;; Update P3/P4 health bars using playfield system
          ;; Cross-bank call to UpdatePlayer34HealthBars in bank 10
          ;; Return address: ENCODED with caller bank 10 ($a0) for BS_return to decode
          lda # ((>(AfterUpdatePlayer34HealthBars-1)) & $0f) | $a0  ;;; Encode bank 10 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterUpdatePlayer34HealthBars hi (encoded)]
          lda # <(AfterUpdatePlayer34HealthBars-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterUpdatePlayer34HealthBars hi (encoded)] [SP+0: AfterUpdatePlayer34HealthBars lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(UpdatePlayer34HealthBars-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterUpdatePlayer34HealthBars hi (encoded)] [SP+1: AfterUpdatePlayer34HealthBars lo] [SP+0: UpdatePlayer34HealthBars hi (raw)]
          lda # <(UpdatePlayer34HealthBars-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterUpdatePlayer34HealthBars hi (encoded)] [SP+2: AfterUpdatePlayer34HealthBars lo] [SP+1: UpdatePlayer34HealthBars hi (raw)] [SP+0: UpdatePlayer34HealthBars lo]
          ldx # 10
          jmp BS_jsr
AfterUpdatePlayer34HealthBars:


          rts

.pend

VblankModeWinnerAnnouncement .proc
          ;; Winner Announcement vblank handler
          ;; Returns: Near (return thisbank)
          ;; CRITICAL: Guard PlayMusic call - only call if music is initialized
          ;; musicVoice0Pointer = 0 means music not started yet
          lda musicVoice0Pointer
          bne PlayWinnerAnnouncementMusic
          jmp VblankWinnerAnnouncementSkipMusic
PlayWinnerAnnouncementMusic:


          ;; CRITICAL: Call PlayMusic here (earlier in frame) to reduce stack depth
          ;; When called from Vblank, stack is shallower than when called from MainLoop
          ;; Cross-bank call to PlayMusic in bank 15
          lda # >(AfterPlayMusicWinnerAnnouncement-1)
          pha
          lda # <(AfterPlayMusicWinnerAnnouncement-1)
          pha
          lda # >(PlayMusic-1)
          pha
          lda # <(PlayMusic-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterPlayMusicWinnerAnnouncement:


.pend

VblankWinnerAnnouncementSkipMusic .proc
          ;; Update character animations for winner screen
          ;; CRITICAL: Inlined UpdateCharacterAnimations to save 4 bytes on sta

.pend

VblankHandlerDone:
          ;; Vblank handler complete
          ;; Returns: Far (return otherbank)
          ;; Called via cross-bank call from VblankHandlerTrampoline, so must use return otherbank
          jmp BS_return
          ;; Note: vblank_bB_code constant is defined in Bank15.s pointing to VblankHandlerTrampoline
          ;; The trampoline calls this dispatcher via cross-bank call

