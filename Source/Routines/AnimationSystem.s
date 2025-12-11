;;; ChaosFight - Source/Routines/AnimationSystem.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CharacterWindupNextAction:
          .byte 255, 15, 255, 255, 14, 14, 255, 255, 255, 14, 255, 14, 255, 255, 255, 255

CharacterExecuteNextAction:
          .byte 1, 255, 1, 1, 15, 1, 1, 1, 1, 1, 1, 15, 1, 1, 1, 1

UpdateCharacterAnimations:
          ;; Returns: Far (return otherbank)
          ;; Drives the 10fps animation system for every active player
          ;; Inputs: controllerStatus (global), currentPlayer (global scratch)
          ;; animationCounter_R[] (SCRAM), currentAnimationFrame_R[],
          ;; currentAnimationSeq[], playerHealth[] (global array)
          ;; Outputs: animationCounter_W[], currentAnimationFrame_W[], player sprite sta

          ;; Mutates: currentPlayer (0-3), animationCounter_W[], currentAnimationFrame_W[]
          ;; Calls: UpdatePlayerAnimation (bank10), LoadPlayerSprite (bank16)
          ;; Constraints: None
          ;; CRITICAL: Skip sprite loading in Publisher Prelude and Author Prelude modes (no characters)
          jmp BS_return
          ;; UCA_quadtariActive uses temp5 directly (no dim needed)
          lda controllerStatus
          and # SetQuadtariDetected
          sta UCA_quadtariActive
          ;; TODO: #1254 for currentPlayer = 0 to 3
          ;; If currentPlayer >= 2 && !UCA_quadtariActive, then jmp AnimationNextPlayer
          lda currentPlayer
          cmp # 3
          bcc UCA_CheckQuadtari

          lda UCA_quadtariActive
          bne UCA_CheckQuadtari

          jmp AnimationNextPlayer

UCA_CheckQuadtari:

          ;; CRITICAL: Inlined UpdatePlayerAnimation to reduce stack depth from 19 to 17 bytes
          ;; Skip if player is eliminated (health = 0)
          ;; If playerHealth[currentPlayer] = 0, then jmp AnimationNextPlayer
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          bne UCA_CheckCharacter

          jmp AnimationNextPlayer

UCA_CheckCharacter:


          ;; Increment this sprite 10fps animation counter (NOT global
          ;; frame counter)
          ;; SCRAM read-modify-write: animationCounter_R → animationCounter_W
          ;; Set temp4 = animationCounter_R[currentPlayer] + 1
          lda currentPlayer
          asl
          tax
          lda animationCounter_R,x
          clc
          adc # 1
          sta temp4

          lda currentPlayer
          asl
          tax
          lda animationCounter_R,x
          clc
          adc # 1
          sta temp4
          lda currentPlayer
          asl
          tax
          lda temp4
          sta animationCounter_W,x

          ;; Check if time to advance animation frame (every AnimationFrameDelay frames)
          ;; If temp4 < AnimationFrameDelay, then jmp DoneAdvanceInlined
          lda temp4
          cmp AnimationFrameDelay
          bcs UPA_CheckAnimationSpeed
          jmp DoneAdvanceInlined
UPA_CheckAnimationSpeed:
          

AdvanceFrame .proc
          ;; Advance animation frame (counter reached threshold)
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: currentPlayer (global), currentAnimationFrame_R[]
          ;; (from UpdatePlayerAnimation)
          ;;
          ;; Output: animationCounter_W[] reset to 0,
          ;; currentAnimationFrame_W[] incremented,
          ;; dispatches to HandleFrame7Transition or
          ;; UpdateSprite
          ;;
          ;; Mutates: animationCounter_W[] (reset to 0),
          ;; currentAnimationFrame_W[] (incremented),
          ;; temp4 (used for frame read)
          ;;
          ;; Called Routines: HandleAnimationTransition - handles frame
          ;; 7 completion,
          ;; UpdateSprite - loads player sprite
          ;;
          ;; Constraints: Must be colocated with UpdatePlayerAnimation,
          ;; DoneAdvance, HandleFrame7Transition,
          ;; UpdateSprite
          lda currentPlayer
          asl
          tax
          lda 0
          sta animationCounter_W,x
          ;; Inline AdvanceAnimationFrame
          ;; Advance to next frame in current animation action
          ;; Frame is from sprite 10fps counter
          ;; (currentAnimationFrame), not global frame
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
          lda temp4
          clc
          adc # 1
          sta temp4
          lda currentPlayer
          asl
          tax
          lda temp4
          sta currentAnimationFrame_W,x

          ;; Check if we have completed the current action (8 frames
          ;; per action)
          ;; Use temp variable from previous increment
          ;; (temp4)
          ;; If temp4 >= FramesPerSequence, then jmp HandleFrame7Transition
          lda temp4
          cmp FramesPerSequence

          bcc UPA_CheckAnimationLength

          jmp UPA_CheckAnimationLength

          UPA_CheckAnimationLength:
          jmp UpdateSprite
DoneAdvance
          rts
HandleFrame7Transition
          ;; Frame 7 completed, handle action-specific transitions
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: currentPlayer (global) = player index (from
          ;; UpdatePlayerAnimation/AdvanceFrame)
          ;;
          ;; Output: Animation transition handled, dispatches to
          ;; UpdateSprite
          ;;
          ;; Mutates: Animation state (via inlined HandleAnimationTransition)
          ;;
          ;; Called Routines: None (HandleAnimationTransition inlined to save 4 bytes)
          ;; UpdateSprite - loads player sprite
          ;;
          ;; Constraints: Must be colocated with UpdatePlayerAnimation,
          ;; AdvanceAnimationFrame, UpdateSprite
          ;; CRITICAL: Inlined HandleAnimationTransition to save 4 bytes on sta

          ;; (was: cross-bank call to HandleAnimationTransition bank12)
          ;; Set temp1 = currentAnimationSeq_R[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          ;; If ActionAttackRecovery < temp1, then jmp AnimationTransitionLoopAnimation
          lda ActionAttackRecovery
          cmp temp1
          bcs AnimationTransitionLoopAnimation
          jmp AnimationTransitionLoopAnimation
AnimationTransitionLoopAnimation:

          

          jmp AnimationTransitionLoopAnimation

AnimationTransitionLoopAnimation
          lda currentPlayer
          asl
          tax
          lda 0
          sta currentAnimationFrame_W,x
          jmp UpdateSprite

AnimationTransitionToIdle
          lda ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationTransitionToFallen
          lda ActionFallen
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationTransitionHandleJump
          ;; Stay on frame 7 until Y velocity goes negative
          if 0 < playerVelocityY[currentPlayer] then AnimationTransitionHandleJump_TransitionToFalling
          lda currentPlayer
          asl

          tax

          lda playerVelocityY,x
          cmp # 1

          bcc TransitionToJumping

          jmp TransitionToJumping

          TransitionToJumping:
          lda ActionJumping
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationTransitionHandleJump_TransitionToFalling
          ;; Falling (positive Y velocity), transition to falling
          lda ActionFalling
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationTransitionHandleFallBack
          ;; Check wall collision using pfread
          ;; Convert player X position to playfield column (0-31)
          ;; Set temp5 = playerX[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerX,x
          sta temp5
          ;; Set temp5 = temp5 - ScreenInsetX          lda temp5          sec          sbc ScreenInsetX          sta temp5
          lda temp5
          sec
          sbc ScreenInsetX
          sta temp5

          lda temp5
          sec
          sbc ScreenInsetX
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
AfterPlayfieldReadAnimationTransition:

          lda temp3
          sta temp2
          if temp1 then AnimationTransitionHandleFallBack_HitWall
          lda temp1
          beq TransitionToFallen
          jmp AnimationTransitionHandleFallBack_HitWall
TransitionToFallen:
          ;; No wall collision, transition to fallen
          lda ActionFallen
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationTransitionHandleFallBack_HitWall
          ;; Hit wall, transition to idle
          lda ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationHandleAttackTransition
          ;; Set temp1 = currentAnimationSeq_R[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          ;; If temp1 < ActionAttackWindup, then jmp UpdateSprite
          lda temp1
          cmp ActionAttackWindup
          bcs HandleWindupEnd
          jmp UpdateSprite
HandleWindupEnd:
          
                    let temp1 = temp1 - ActionAttackWindup          lda temp1          sec          sbc ActionAttackWindup          sta temp1
          jmp AnimationHandleWindupEnd
          jmp UpdateSprite

AnimationHandleWindupEnd
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
          ;; If temp1 >= 32, then jmp UpdateSprite
          lda temp1
          cmp 32

          bcc ClampCharacterIndex

          jmp ClampCharacterIndex

          ClampCharacterIndex:
          if temp1 >= 16 then let temp1 = 0
          lda temp1
          cmp # 17

          bcc GetWindupNextAction

          lda # 0

          sta .GetWindupNextAction

          label_unknown:
          ;; Set temp2 = CharacterWindupNextAction[temp1]         
          lda temp1
          asl
          tax
          lda CharacterWindupNextAction,x
          sta temp2
          lda temp2
          cmp # 255
          bne SetWindupAnimation
          jmp UpdateSprite
SetWindupAnimation:

          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationHandleExecuteEnd
          ;; Set temp1 = playerCharacter[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp1
          ;; If temp1 >= 32, then jmp UpdateSprite
          lda temp1
          cmp 32

          bcc ClampCharacterIndexExecute

          jmp ClampCharacterIndexExecute

          ClampCharacterIndexExecute:
          lda temp1
          cmp # 6
          bne GetExecuteNextAction
          jmp AnimationHarpyExecute
GetExecuteNextAction:

          if temp1 >= 16 then let temp1 = 0
          lda temp1
          cmp # 17

          bcc GetExecuteNextActionLabel

          lda # 0

          sta .GetExecuteNextActionLabel

          label_unknown:
          ;; Set temp2 = CharacterExecuteNextAction[temp1]
          lda temp1
          asl
          tax
          lda CharacterExecuteNextAction,x
          sta temp2
          lda temp2
          cmp # 255
          bne SetExecuteAnimation
          jmp UpdateSprite
SetExecuteAnimation:

          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationHarpyExecute
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

          jmp AnimationSetPlayerAnimationInlined

AnimationHandleRecoveryEnd
          ;; All characters: Recovery → Idle
          lda ActionIdle
          sta temp2
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          jmp AnimationSetPlayerAnimationInlined

AnimationSetPlayerAnimationInlined
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; Set animation action for a player (inlined from AnimationSystem.bas)
          ;; If temp2 >= AnimationSequenceCount, then jmp UpdateSprite
          lda temp2
          cmp AnimationSequenceCount

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
          ;; Set temp3 = currentAnimationSeq_R[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp3
          lda currentPlayer
          sta temp4
          ;; Fall through to UpdateSprite which has inlined LoadPlayerSprite logic

.pend

UpdateSprite .proc
          ;; Update character sprite with current animation frame and
          ;; Returns: Far (return otherbank)
          ;; action
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; currentAnimationFrame_R[] (global SCRAM array) =
          ;; current animation frames
          ;; currentAnimationSeq[] (global array) = current
          ;; animation sequences
          ;;
          ;; Output: Player sprite loaded with current animation frame
          and action
          ;;
          ;; Mutates: temp2, temp3, temp4 (passed to LoadPlayerSprite),
          ;; player sprite pointers (via LoadPlayerSprite)
          ;;
          ;; Called Routines: LoadPlayerSprite (bank16) - loads
          ;; character sprite graphics
          ;;
          ;; Constraints: Must be colocated with UpdatePlayerAnimation,
          ;; AdvanceAnimationFrame, HandleFrame7Transition
          ;; Update character sprite with current animation frame and
          ;; action
          ;;
          ;; INPUT: currentPlayer = player index (0-3) (uses global
          ;; variable)
          ;; currentAnimationFrame[currentPlayer] = current frame
          ;; within sequence (0-7)
          ;; currentAnimationSeq[currentPlayer] = current animation
          ;; action/sequence (0-15)
          ;;
          ;; OUTPUT: None
          ;;
          ;; EFFECTS: Loads sprite graphics for current player with
          ;; current animation frame and action sequence
          ;; Frame is from this sprite 10fps counter
          ;; (currentAnimationFrame), not global frame counter
          ;; SCRAM read: Read from r081
          ;; where dim entries concatenate with subsequent consta

          ;; Set temp2 = currentAnimationFrame_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda currentAnimationFrame_R,x
          sta temp2
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

          ;; CRITICAL: Guard against calling bank 2 when no characters on screen
          ;; Set currentCharacter = playerCharacter[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda currentCharacter
          cmp NoCharacter
          bne CheckCPUCharacterSprite
          jmp AnimationNextPlayer
CheckCPUCharacterSprite:

          lda currentCharacter
          cmp CPUCharacter
          bne CheckRandomCharacterSprite
          jmp AnimationNextPlayer
CheckRandomCharacterSprite:

          lda currentCharacter
          cmp RandomCharacter
          bne ValidateCharacterRangeSprite
          jmp AnimationNextPlayer
ValidateCharacterRangeSprite:

          ;; CRITICAL: Validate character index is within valid range (0-MaxCharacter)
          ;; Uninitialized playerCharacter (0) is valid (Bernie), but values > MaxCharacter are invalid
          ;; If currentCharacter > MaxCharacter, then jmp AnimationNextPlayer
          lda currentCharacter
          sec
          sbc MaxCharacter
          bcc DetermineSpriteBank
          beq DetermineSpriteBank
          jmp AnimationNextPlayer
DetermineSpriteBank:

          lda currentCharacter
          sec
          sbc MaxCharacter
          bcc CheckBank2
          beq CheckBank2
          jmp AnimationNextPlayer
CheckBank2:


          lda currentCharacter
          sta temp1
          lda temp1
          sta temp6
          ;; Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          ;; If temp1 < 8, then jmp UpdateSprite_Bank2Dispatch          lda temp1          cmp 8          bcs .skip_5345          jmp
          lda temp1
          cmp # 8
          bcs CheckBank3
          Anim_goto_label:

          jmp goto_label
CheckBank3:

          lda temp1
          cmp # 8
          bcs CheckBank3Dispatch
          jmp goto_label
CheckBank3Dispatch:

          
          ;; If temp1 < 16, then jmp UpdateSprite_Bank3Dispatch          lda temp1          cmp 16          bcs .skip_8905          jmp
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

          
          ;; If temp1 < 24, then jmp UpdateSprite_Bank4Dispatch          lda temp1          cmp 24          bcs .skip_205          jmp
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

          
          jmp UpdateSprite_Bank5Dispatch

UpdateSprite_Bank2Dispatch
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
AfterSetPlayerCharacterArtBank2:

          jmp AnimationNextPlayer

UpdateSprite_Bank3Dispatch
          ;; Set temp6 = temp1 - 8          lda temp1          sec          sbc 8          sta temp6
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
AfterSetPlayerCharacterArtBank3:

          jmp AnimationNextPlayer

UpdateSprite_Bank4Dispatch
          ;; Set temp6 = temp1 - 16          lda temp1          sec          sbc 16          sta temp6
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
AfterSetPlayerCharacterArtBank4:

          jmp AnimationNextPlayer

UpdateSprite_Bank5Dispatch
          ;; Set temp6 = temp1 - 24          lda temp1          sec          sbc 24          sta temp6
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
AfterSetPlayerCharacterArtBank5:

          jmp AnimationNextPlayer
DoneAdvanceInlined
          End of inlined UpdatePlayerAnimation - skip to next player
          jmp AnimationNextPlayer
AnimationNextPlayer:
.pend

Anim_next_label_1:.proc
          jmp BS_return
SetPlayerAnimation
          ;; Returns: Far (return otherbank)
SetPlayerAnimation

          ;; Set animation action for a player
          ;; Returns: Far (return otherbank)
          ;;
          ;; INPUT: currentPlayer = player index (0-3), temp2 =
          ;; animation action (0-15)
          ;;
          ;; OUTPUT: None
          ;;
          ;; EFFECTS: Sets new animation sequence, resets animation
          ;; frame to 0, resets animation counter,
          ;; immediately updates sprite graphics to show first frame of
          ;; new animation
          ;; Set animation action for a player
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; temp2 = animation action (0-15)
          ;; AnimationSequenceCount (constant) = maximum
          ;; animation sequence count
          ;;
          ;; Output: currentAnimationSeq[] updated,
          ;; currentAnimationFrame_W[] reset to 0,
          ;; animationCounter_W[] reset to 0, player sprite
          ;; updated
          ;;
          ;; Mutates: currentAnimationSeq[] (set to new action),
          ;; currentAnimationFrame_W[] (reset to 0),
          ;; animationCounter_W[] (reset to 0), temp2, temp3,
          ;; temp4 (passed to LoadPlayerSprite),
          ;; player sprite pointers (via LoadPlayerSprite)
          ;;
          ;; Called Routines: LoadPlayerSprite (bank16) - loads
          ;; character sprite graphics
          ;; Constraints: None
          jmp BS_return

          ;; SCRAM write to currentAnimationFrame_W
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

          ;; Update character sprite immediately
          ;; Frame is from this sprite 10fps counter, action from
          ;; currentAnimationSeq
          ;; CRITICAL: Guard against calling LoadPlayerSprite when no characters on screen
          ;; Check if player has a valid character before loading sprite
          ;; Set temp1 = playerCharacter[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp1
          jmp BS_return
          jmp BS_return
          jmp BS_return
          ;; Set up parameters for LoadPlayerSprite
          ;; SCRAM read: Read from r081 (we just wrote 0, so this is 0)
          lda # 0
          sta temp2
          ;; Set temp3 = currentAnimationSeq_R[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp3
          lda currentPlayer
          sta temp4
          ;; Cross-bank call to LoadPlayerSprite in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(LoadPlayerSprite-1)
          pha
          lda # <(LoadPlayerSprite-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterLoadPlayerSprite:


          jmp BS_return

InitializeAnimationSystem
          ;; Initialize animation system for all players
          ;; Returns: Far (return otherbank)
          ;; Called at game start to set up initial animation sta

          ;;
          ;; INPUT: None
          ;;
          ;; OUTPUT: None
          ;;
          ;; EFFECTS: Sets all players (0-3) to idle animation sta

          ;; (ActionIdle)
          ;; Initialize all players to idle animation
          lda ActionIdle
          sta temp2
          ;; TODO: #1254 for currentPlayer = 0 to 3
          ;; Cross-bank call to SetPlayerAnimation in bank 12
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(SetPlayerAnimation-1)
          pha
          lda # <(SetPlayerAnimation-1)
          pha
                    ldx # 11
          jmp BS_jsr
AfterSetPlayerAnimationTransition:

.pend

HandleAnimationTransition .proc
          jmp BS_return
          ;; Returns: Far (return thisbank)
          ;; Set temp1 = currentAnimationSeq_R[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          ;; If ActionAttackRecovery < temp1, then jmp TransitionLoopAnimation
          lda ActionAttackRecovery
          cmp temp1
          bcs TransitionLoopAnimation
          jmp TransitionLoopAnimation
TransitionLoopAnimation:

          

          jmp TransitionLoopAnimation

TransitionLoopAnimation
          ;; SCRAM write to currentAnimationFrame_W
          ;; Returns: Far (return otherbank)
          lda currentPlayer
          asl
          tax
          lda 0
          sta currentAnimationFrame_W,x
          jmp BS_return
TransitionToIdle
          lda ActionIdle
          sta temp2
          ;; tail call
          jmp SetPlayerAnimation

TransitionToFallen
          ;; Returns: Far (return otherbank)
          lda ActionFallen
          sta temp2
          ;; tail call
          ;; Returns: Far (return otherbank)
          jmp SetPlayerAnimation

TransitionHandleJump
          ;; Stay on frame 7 until Y velocity goes negative
          ;; Returns: Far (return otherbank)
          ;; Check if player is falling (positive Y velocity =
          ;; downward)
          ;; Still ascending (negative or zero Y velocity), stay in jump
          if 0 < playerVelocityY[currentPlayer] then TransitionHandleJump_TransitionToFalling
          lda currentPlayer
          asl

          tax

          lda playerVelocityY,x
          cmp # 1

          bcc TransitionToJumpingHandle

          jmp TransitionToJumpingHandle

          TransitionToJumpingHandle:
          lda ActionJumping
          sta temp2
          ;; tail call
          jmp SetPlayerAnimation
TransitionHandleJump_TransitionToFalling
          ;; Falling (positive Y velocity), transition to falling
          ;; Returns: Far (return otherbank)
          lda ActionFalling
          sta temp2
          ;; tail call
          jmp SetPlayerAnimation

TransitionHandleFallBack
          ;; Check wall collision using pfread
          ;; Returns: Far (return otherbank)
          If hit wall: jmp idle, else: jmp fallen
          ;; Convert player X position to playfield column (0-31)
          ;; Set temp5 = playerX[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerX,x
          sta temp5
          ;; Set temp5 = temp5 - ScreenInsetX          lda temp5          sec          sbc ScreenInsetX          sta temp5
          lda temp5
          sec
          sbc ScreenInsetX
          sta temp5

          lda temp5
          sec
          sbc ScreenInsetX
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
          ;; Check if player hit a wall (playfield pixel is set)
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
AfterPlayfieldReadTransition:

          lda temp3
          sta temp2
          if temp1 then TransitionHandleFallBack_HitWall
          lda temp1
          beq TransitionToFallenHandle
          jmp TransitionHandleFallBack_HitWall
TransitionToFallenHandle:
          
          ;; No wall collision, transition to fallen
          lda ActionFallen
          sta temp2
          ;; tail call
          jmp SetPlayerAnimation
TransitionHandleFallBack_HitWall
          ;; Hit wall, transition to idle
          ;; Returns: Far (return otherbank)
          lda ActionIdle
          sta temp2
          ;; tail call
          jmp SetPlayerAnimation

          ;;
          ;; Attack Transition Handling
          ;; Character-specific attack transitions based on patterns

HandleAttackTransition
          ;; Returns: Far (return otherbank)
          ;; Set temp1 = currentAnimationSeq_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda currentAnimationSeq_R,x
          sta temp1
          jmp BS_return
          ;; Set temp1 = temp1 - ActionAttackWindup          lda temp1          sec          sbc ActionAttackWindup          sta temp1
          lda temp1
          sec
          sbc ActionAttackWindup
          sta temp1

          lda temp1
          sec
          sbc ActionAttackWindup
          sta temp1

          jmp HandleWindupEnd
          jmp BS_return
HandleWindupEnd
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
          rts
          if temp1 >= 16 then let temp1 = 0
          lda temp1
          cmp # 17

          bcc GetWindupNextActionHandle

          lda # 0

          sta .GetWindupNextActionHandle

          label_unknown:
          ;; Set temp2 = CharacterWindupNextAction[temp1]         
          lda temp1
          asl
          tax
          lda CharacterWindupNextAction,x
          sta temp2
          rts
          jmp SetPlayerAnimation

HandleExecuteEnd
          ;; Returns: Far (return otherbank)
          ;; Set temp1 = playerCharacter[currentPlayer]
         
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta temp1
          jmp BS_return
          lda temp1
          cmp # 6
          bne GetExecuteNextActionHandle
          jmp HarpyExecute
GetExecuteNextActionHandle:

          if temp1 >= 16 then let temp1 = 0
          lda temp1
          cmp # 17

          bcc GetExecuteNextActionHandleLabel

          lda # 0

          sta .GetExecuteNextActionHandleLabel

          label_unknown:
          ;; Set temp2 = CharacterExecuteNextAction[temp1]
          lda temp1
          asl
          tax
          lda CharacterExecuteNextAction,x
          sta temp2
          jmp BS_return
          jmp SetPlayerAnimation

.pend

HarpyExecute .proc
          ;; Harpy: Execute → Idle
          ;; Returns: Far (return otherbank)
          ;; Clear dive flag and stop diagonal movement when attack
          ;; completes
          ;; Also apply upward wing flap momentum after swoop attack
          lda currentPlayer
          sta temp1
          ;; Clear dive flag (bit 4 in characterStateFlags)
          ;; Fix RMW: Read from _R, modify, write to _W
          let C6E_stateFlags = 239 & characterStateFlags_R[temp1]
          lda temp1
          asl
          tax
          lda characterStateFlags_R,x
          and # 239
          sta C6E_stateFlags
          ;; Clear bit 4 (239 = 0xEF = ~0x10)
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
          ;; Apply upward wing flap momentum after swoop attack
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          ;; (equivalent to HarpyJump)
          ;; Same as normal flap: -2 pixels/frame upward (254 in twos
          ;; complement)
          lda temp1
          asl
          tax
          lda 254
          sta playerVelocityY,x
          ;; -2 in 8-bit twos complement: 256 - 2 = 254
          ;; Keep jumping flag set to allow vertical movement
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x
          ;; playerState[temp1] bit 2 (jumping) already set
          ;; from attack, keep it
          ;; Transition to Idle
          lda ActionIdle
          sta temp2
          ;; tail call
          jmp SetPlayerAnimation
          ;; Placeholder characters (16-30) reuse the table entries for
          ;; Bernie (0) so they no-op on windup and fall to Idle on
          ;; execute, keeping the jump tables dense until bespoke logic
          ;; arrives.

HandleRecoveryEnd
          ;; All characters: Recovery → Idle
          ;; Returns: Far (return otherbank)
          lda ActionIdle
          sta temp2
          ;; tail call
          jmp SetPlayerAnimation

.pend

