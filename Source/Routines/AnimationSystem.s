;;; ChaosFight - Source/Routines/AnimationSystem.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

CharacterWindupNextAction:
          .byte 255, 15, 255, 255, 14, 14, 255, 255, 255, 14, 255, 14, 255, 255, 255, 255

CharacterExecuteNextAction:
          .byte 1, 255, 1, 1, 15, 1, 1, 1, 1, 1, 1, 15, 1, 1, 1, 1

UpdateCharacterAnimations
          ;; Returns: Far (return otherbank)
;; UpdateCharacterAnimations (duplicate)

          ;; Drives the 10fps animation system for every active player
          ;; Returns: Far (return otherbank)
          ;; Inputs: controllerStatus (global), currentPlayer (global scratch)
          ;; animationCounter_R[] (SCRAM), currentAnimationFrame_R[],
          ;; currentAnimationSeq[], playerHealth[] (global array)
          ;; Outputs: animationCounter_W[], currentAnimationFrame_W[], player sprite sta

          ;; Mutates: currentPlayer (0-3), animationCounter_W[], currentAnimationFrame_W[]
          ;; Calls: UpdatePlayerAnimation (bank10), LoadPlayerSprite (bank16)
          ;; Constraints: None
          ;; CRITICAL: Skip sprite loading in Publisher Prelude and Author Prelude modes (no characters)
          jsr BS_return
          ;; jsr BS_return (duplicate)
          ;; TODO: dim UCA_quadtariActive = temp5
          lda controllerStatus
          and SetQuadtariDetected
          sta UCA_quadtariActive
          ;; TODO: for currentPlayer = 0 to 3
          ;; ;; if currentPlayer >= 2 && !UCA_quadtariActive then goto AnimationNextPlayer
          ;; lda currentPlayer (duplicate)
          cmp # 3
          bcc UCA_CheckPlayerLimit
          ;; lda UCA_quadtariActive (duplicate)
          bne UCA_CheckPlayerLimit
          jmp UpdateSprite.AnimationNextPlayer
UCA_CheckPlayerLimit:

          ;; lda currentPlayer (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bcc UCA_CheckQuadtari (duplicate)
          ;; lda UCA_quadtariActive (duplicate)
          ;; bne UCA_CheckQuadtari (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
UCA_CheckQuadtari:


          ;; CRITICAL: Inlined UpdatePlayerAnimation to reduce stack depth from 19 to 17 bytes
          ;; Skip if player is eliminated (health = 0)
                    ;; if playerHealth[currentPlayer] = 0 then goto AnimationNextPlayer
          ;; lda currentPlayer (duplicate)
          asl
          tax
          ;; lda playerHealth,x (duplicate)
          ;; bne UCA_CheckPlayerHealth (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
UCA_CheckPlayerHealth:
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne UCA_CheckCharacter (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
UCA_CheckCharacter:


          ;; Increment this sprite 10fps animation counter (NOT global
          ;; frame counter)
          ;; SCRAM read-modify-write: animationCounter_R → animationCounter_W
          ;; ;; let temp4 = animationCounter_R[currentPlayer] + 1
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda animationCounter_R,x (duplicate)
          clc
          adc # 1
          ;; sta temp4 (duplicate)

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda animationCounter_R,x (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta animationCounter_W,x (duplicate)

          ;; Check if time to advance animation frame (every AnimationFrameDelay frames)
                    ;; if temp4 < AnimationFrameDelay then goto DoneAdvanceInlined
          ;; lda temp4 (duplicate)
          ;; cmp AnimationFrameDelay (duplicate)
          bcs UPA_CheckAnimationSpeed
          ;; jmp DoneAdvanceInlined (duplicate)
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
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta animationCounter_W,x (duplicate)
          ;; Inline AdvanceAnimationFrame
          ;; Advance to next frame in current animation action
          ;; Frame is from sprite 10fps counter
          ;; (currentAnimationFrame), not global frame
          ;; SCRAM read-modify-write: currentAnimationFrame_R → currentAnimationFrame_W
                    ;; let temp4 = currentAnimationFrame_R[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationFrame_R,x (duplicate)
          ;; sta temp4 (duplicate)
                    ;; let temp4 = 1 + temp4
          ;; lda temp4 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp4 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta currentAnimationFrame_W,x (duplicate)

          ;; Check if we have completed the current action (8 frames
          ;; per action)
          ;; Use temp variable from previous increment
          ;; (temp4)
          ;; if temp4 >= FramesPerSequence then goto HandleFrame7Transition
          ;; lda temp4 (duplicate)
          ;; cmp FramesPerSequence (duplicate)

          ;; bcc UPA_CheckAnimationLength (duplicate)

          ;; jmp UPA_CheckAnimationLength (duplicate)

          UPA_CheckAnimationLength:
          ;; jmp UpdateSprite (duplicate)
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

          ;; (was: gosub HandleAnimationTransition bank12)
                    ;; let temp1 = currentAnimationSeq_R[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if ActionAttackRecovery < temp1 then goto AnimationTransitionLoopAnimation
          ;; lda ActionAttackRecovery (duplicate)
          ;; cmp temp1 (duplicate)
          ;; bcs skip_613 (duplicate)
          ;; jmp AnimationTransitionLoopAnimation (duplicate)
skip_613:

          

          ;; jmp AnimationTransitionLoopAnimation (duplicate)

AnimationTransitionLoopAnimation
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta currentAnimationFrame_W,x (duplicate)
          ;; jmp UpdateSprite (duplicate)

AnimationTransitionToIdle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationTransitionToFallen
          ;; lda ActionFallen (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationTransitionHandleJump
          ;; Stay on frame 7 until Y velocity goes negative
          ;; if 0 < playerVelocityY[currentPlayer] then AnimationTransitionHandleJump_TransitionToFalling
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)

          ;; tax (duplicate)

          ;; lda playerVelocityY,x (duplicate)
          ;; cmp # 1 (duplicate)

          ;; bcc skip_432 (duplicate)

          ;; jmp skip_432 (duplicate)

          skip_432:
          ;; lda ActionJumping (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationTransitionHandleJump_TransitionToFalling
          ;; Falling (positive Y velocity), transition to falling
          ;; lda ActionFalling (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationTransitionHandleFallBack
          ;; Check wall collision using pfread
          ;; Convert player X position to playfield column (0-31)
                    ;; let temp5 = playerX[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp5 (duplicate)
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
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 15
          ;; jmp BS_jsr (duplicate)
return_point:

          ;; lda temp3 (duplicate)
          ;; sta temp2 (duplicate)
          ;; if temp1 then AnimationTransitionHandleFallBack_HitWall
          ;; lda temp1 (duplicate)
          beq skip_6180
          ;; jmp AnimationTransitionHandleFallBack_HitWall (duplicate)
skip_6180:
          ;; No wall collision, transition to fallen
          ;; lda ActionFallen (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationTransitionHandleFallBack_HitWall
          ;; Hit wall, transition to idle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationHandleAttackTransition
                    ;; let temp1 = currentAnimationSeq_R[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if temp1 < ActionAttackWindup then goto UpdateSprite
          ;; lda temp1 (duplicate)
          ;; cmp ActionAttackWindup (duplicate)
          ;; bcs skip_3489 (duplicate)
          ;; jmp UpdateSprite (duplicate)
skip_3489:
          
                    ;; let temp1 = temp1 - ActionAttackWindup          lda temp1          sec          sbc ActionAttackWindup          sta temp1
          ;; jmp AnimationHandleWindupEnd (duplicate)
          ;; jmp UpdateSprite (duplicate)

AnimationHandleWindupEnd
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
          ;; if temp1 >= 32 then goto UpdateSprite
          ;; lda temp1 (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_6005 (duplicate)

          ;; jmp skip_6005 (duplicate)

          skip_6005:
          ;; if temp1 >= 16 then let temp1 = 0
          ;; lda temp1 (duplicate)
          ;; cmp # 17 (duplicate)

          ;; bcc skip_4121 (duplicate)

          ;; lda # 0 (duplicate)

          ;; sta .skip_4121 (duplicate)

          label_unknown:
                    ;; let temp2 = CharacterWindupNextAction[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWindupNextAction,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_4504 (duplicate)
          ;; jmp UpdateSprite (duplicate)
skip_4504:

          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationHandleExecuteEnd
                    ;; let temp1 = playerCharacter[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; if temp1 >= 32 then goto UpdateSprite
          ;; lda temp1 (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_6005 (duplicate)

          ;; jmp skip_6005 (duplicate)

          ;; skip_6005: (duplicate)
          ;; lda temp1 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bne skip_6753 (duplicate)
          ;; jmp AnimationHarpyExecute (duplicate)
skip_6753:

          ;; if temp1 >= 16 then let temp1 = 0
          ;; lda temp1 (duplicate)
          ;; cmp # 17 (duplicate)

          ;; bcc skip_4121 (duplicate)

          ;; lda # 0 (duplicate)

          ;; sta .skip_4121 (duplicate)

          ;; label_unknown: (duplicate)
          ;; let temp2 = CharacterExecuteNextAction[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterExecuteNextAction,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 255 (duplicate)
          ;; bne skip_4504 (duplicate)
          ;; jmp UpdateSprite (duplicate)
;; skip_4504: (duplicate)

          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationHarpyExecute
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

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationHandleRecoveryEnd
          ;; All characters: Recovery → Idle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; jmp AnimationSetPlayerAnimationInlined (duplicate)

AnimationSetPlayerAnimationInlined
          ;; CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on sta

          ;; Set animation action for a player (inlined from AnimationSystem.bas)
          ;; if temp2 >= AnimationSequenceCount then goto UpdateSprite
          ;; lda temp2 (duplicate)
          ;; cmp AnimationSequenceCount (duplicate)

          ;; bcc skip_3988 (duplicate)

          ;; jmp skip_3988 (duplicate)

          skip_3988:
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
                    ;; let temp3 = currentAnimationSeq_R[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp4 (duplicate)
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
          ;; and action
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

                    ;; let temp2 = currentAnimationFrame_R[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationFrame_R,x (duplicate)
          ;; sta temp2 (duplicate)
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

          ;; CRITICAL: Guard against calling bank 2 when no characters on screen
                    ;; let currentCharacter = playerCharacter[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda currentCharacter (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_4610 (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
skip_4610:

          ;; lda currentCharacter (duplicate)
          ;; cmp CPUCharacter (duplicate)
          ;; bne skip_6470 (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
skip_6470:

          ;; lda currentCharacter (duplicate)
          ;; cmp RandomCharacter (duplicate)
          ;; bne skip_9690 (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
skip_9690:

          ;; CRITICAL: Validate character index is within valid range (0-MaxCharacter)
          ;; Uninitialized playerCharacter (0) is valid (Bernie), but values > MaxCharacter are invalid
          ;; ;; if currentCharacter > MaxCharacter then goto AnimationNextPlayer
          ;; lda currentCharacter (duplicate)
          ;; sec (duplicate)
          ;; sbc MaxCharacter (duplicate)
          ;; bcc skip_758 (duplicate)
          ;; beq skip_758 (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
skip_758:

          ;; lda currentCharacter (duplicate)
          ;; sec (duplicate)
          ;; sbc MaxCharacter (duplicate)
          ;; bcc skip_2038 (duplicate)
          ;; beq skip_2038 (duplicate)
          ;; jmp AnimationNextPlayer (duplicate)
skip_2038:


          ;; lda currentCharacter (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          ;; ;; if temp1 < 8 then goto UpdateSprite_Bank2Dispatch          lda temp1          cmp 8          bcs .skip_5345          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bcs skip_8879 (duplicate)
          Anim_goto_label:

          ;; jmp goto_label (duplicate)
skip_8879:

          ;; lda temp1 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bcs skip_2468 (duplicate)
          ;; jmp goto_label (duplicate)
skip_2468:

          
          ;; ;; if temp1 < 16 then goto UpdateSprite_Bank3Dispatch          lda temp1          cmp 16          bcs .skip_8905          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 16 (duplicate)
          ;; bcs skip_5626 (duplicate)
          ;; jmp goto_label (duplicate)
skip_5626:

          ;; lda temp1 (duplicate)
          ;; cmp # 16 (duplicate)
          ;; bcs skip_6358 (duplicate)
          ;; jmp goto_label (duplicate)
skip_6358:

          
          ;; ;; if temp1 < 24 then goto UpdateSprite_Bank4Dispatch          lda temp1          cmp 24          bcs .skip_205          jmp
          ;; lda temp1 (duplicate)
          ;; cmp # 24 (duplicate)
          ;; bcs skip_8945 (duplicate)
          ;; jmp goto_label (duplicate)
skip_8945:

          ;; lda temp1 (duplicate)
          ;; cmp # 24 (duplicate)
          ;; bcs skip_458 (duplicate)
          ;; jmp goto_label (duplicate)
skip_458:

          
          ;; jmp UpdateSprite_Bank5Dispatch (duplicate)

UpdateSprite_Bank2Dispatch
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

          ;; jmp AnimationNextPlayer (duplicate)

UpdateSprite_Bank3Dispatch
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

          ;; jmp AnimationNextPlayer (duplicate)

UpdateSprite_Bank4Dispatch
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

          ;; jmp AnimationNextPlayer (duplicate)

UpdateSprite_Bank5Dispatch
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

          ;; jmp AnimationNextPlayer (duplicate)
DoneAdvanceInlined
          ;; End of inlined UpdatePlayerAnimation - skip to next player
          ;; jmp AnimationNextPlayer (duplicate)
AnimationNextPlayer:
.pend

Anim_next_label_1:.proc
          ;; jsr BS_return (duplicate)
SetPlayerAnimation
          ;; Returns: Far (return otherbank)
;; SetPlayerAnimation (duplicate)

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
          ;; jsr BS_return (duplicate)

          ;; SCRAM write to currentAnimationFrame_W
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

          ;; Update character sprite immediately
          ;; Frame is from this sprite 10fps counter, action from
          ;; currentAnimationSeq
          ;; CRITICAL: Guard against calling LoadPlayerSprite when no characters on screen
          ;; Check if player has a valid character before loading sprite
                    ;; let temp1 = playerCharacter[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr BS_return (duplicate)
          ;; jsr BS_return (duplicate)
          ;; jsr BS_return (duplicate)
          ;; Set up parameters for LoadPlayerSprite
          ;; SCRAM read: Read from r081 (we just wrote 0, so this is 0)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
                    ;; let temp3 = currentAnimationSeq_R[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; sta temp4 (duplicate)
          ;; Cross-bank call to LoadPlayerSprite in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(LoadPlayerSprite-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(LoadPlayerSprite-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; TODO: for currentPlayer = 0 to 3
          ;; Cross-bank call to SetPlayerAnimation in bank 12
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SetPlayerAnimation-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SetPlayerAnimation-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 11 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

.pend

next_label_2_1:.proc
          ;; jsr BS_return (duplicate)
HandleAnimationTransition
          ;; Returns: Far (return thisbank)
;; HandleAnimationTransition (duplicate)
                    ;; let temp1 = currentAnimationSeq_R[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp1 (duplicate)
                    ;; if ActionAttackRecovery < temp1 then goto TransitionLoopAnimation
          ;; lda ActionAttackRecovery (duplicate)
          ;; cmp temp1 (duplicate)
          ;; bcs skip_6040 (duplicate)
          ;; jmp TransitionLoopAnimation (duplicate)
skip_6040:

          

          ;; jmp TransitionLoopAnimation (duplicate)

TransitionLoopAnimation
          ;; SCRAM write to currentAnimationFrame_W
          ;; Returns: Far (return otherbank)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta currentAnimationFrame_W,x (duplicate)
          ;; jsr BS_return (duplicate)
TransitionToIdle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; jmp SetPlayerAnimation (duplicate)

TransitionToFallen
          ;; Returns: Far (return otherbank)
          ;; lda ActionFallen (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; Returns: Far (return otherbank)
          ;; jmp SetPlayerAnimation (duplicate)

TransitionHandleJump
          ;; Stay on frame 7 until Y velocity goes negative
          ;; Returns: Far (return otherbank)
          ;; Check if player is falling (positive Y velocity =
          ;; downward)
          ;; Still ascending (negative or zero Y velocity), stay in jump
          ;; if 0 < playerVelocityY[currentPlayer] then TransitionHandleJump_TransitionToFalling
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)

          ;; tax (duplicate)

          ;; lda playerVelocityY,x (duplicate)
          ;; cmp # 1 (duplicate)

          ;; bcc skip_4371 (duplicate)

          ;; jmp skip_4371 (duplicate)

          skip_4371:
          ;; lda ActionJumping (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; jmp SetPlayerAnimation (duplicate)
TransitionHandleJump_TransitionToFalling
          ;; Falling (positive Y velocity), transition to falling
          ;; Returns: Far (return otherbank)
          ;; lda ActionFalling (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; jmp SetPlayerAnimation (duplicate)

TransitionHandleFallBack
          ;; Check wall collision using pfread
          ;; Returns: Far (return otherbank)
          ;; If hit wall: goto idle, else: goto fallen
          ;; Convert player X position to playfield column (0-31)
                    ;; let temp5 = playerX[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp5 (duplicate)
          ;; ;; let temp5 = temp5 - ScreenInsetX          lda temp5          sec          sbc ScreenInsetX          sta temp5
          ;; lda temp5 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp5 (duplicate)

          ;; lda temp5 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp5 (duplicate)

          ;; ;; let temp5 = temp5 / 4          lda temp5          lsr          lsr          sta temp5
          ;; lda temp5 (duplicate)
          ;; lsr (duplicate)
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
          ;; Check if player hit a wall (playfield pixel is set)
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
          ;; if temp1 then TransitionHandleFallBack_HitWall
          ;; lda temp1 (duplicate)
          ;; beq skip_4030 (duplicate)
          ;; jmp TransitionHandleFallBack_HitWall (duplicate)
skip_4030:
          
          ;; No wall collision, transition to fallen
          ;; lda ActionFallen (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; jmp SetPlayerAnimation (duplicate)
TransitionHandleFallBack_HitWall
          ;; Hit wall, transition to idle
          ;; Returns: Far (return otherbank)
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; jmp SetPlayerAnimation (duplicate)

          ;;
          ;; Attack Transition Handling
          ;; Character-specific attack transitions based on patterns

HandleAttackTransition
          ;; Returns: Far (return otherbank)
                    ;; let temp1 = currentAnimationSeq_R[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda currentAnimationSeq_R,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr BS_return (duplicate)
          ;; ;; let temp1 = temp1 - ActionAttackWindup          lda temp1          sec          sbc ActionAttackWindup          sta temp1
          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc ActionAttackWindup (duplicate)
          ;; sta temp1 (duplicate)

          ;; lda temp1 (duplicate)
          ;; sec (duplicate)
          ;; sbc ActionAttackWindup (duplicate)
          ;; sta temp1 (duplicate)

          ;; jmp HandleWindupEnd (duplicate)
          ;; jsr BS_return (duplicate)
HandleWindupEnd
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
          ;; rts (duplicate)
          ;; if temp1 >= 16 then let temp1 = 0
          ;; lda temp1 (duplicate)
          ;; cmp # 17 (duplicate)

          ;; bcc skip_4121 (duplicate)

          ;; lda # 0 (duplicate)

          ;; sta .skip_4121 (duplicate)

          ;; label_unknown: (duplicate)
                    ;; let temp2 = CharacterWindupNextAction[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWindupNextAction,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; rts (duplicate)
          ;; jmp SetPlayerAnimation (duplicate)

HandleExecuteEnd
          ;; Returns: Far (return otherbank)
                    ;; let temp1 = playerCharacter[currentPlayer]
         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp1 (duplicate)
          ;; jsr BS_return (duplicate)
          ;; lda temp1 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bne skip_2609 (duplicate)
          ;; jmp HarpyExecute (duplicate)
skip_2609:

          ;; if temp1 >= 16 then let temp1 = 0
          ;; lda temp1 (duplicate)
          ;; cmp # 17 (duplicate)

          ;; bcc skip_4121 (duplicate)

          ;; lda # 0 (duplicate)

          ;; sta .skip_4121 (duplicate)

          ;; label_unknown: (duplicate)
          ;; let temp2 = CharacterExecuteNextAction[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterExecuteNextAction,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; jsr BS_return (duplicate)
          ;; jmp SetPlayerAnimation (duplicate)

.pend

HarpyExecute .proc
          ;; Harpy: Execute → Idle
          ;; Returns: Far (return otherbank)
          ;; Clear dive flag and stop diagonal movement when attack
          ;; completes
          ;; Also apply upward wing flap momentum after swoop attack
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
          ;; Clear dive flag (bit 4 in characterStateFlags)
          ;; Fix RMW: Read from _R, modify, write to _W
          ;; let C6E_stateFlags = 239 & characterStateFlags_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterStateFlags_R,x (duplicate)
          ;; and # 239 (duplicate)
          ;; sta C6E_stateFlags (duplicate)
          ;; Clear bit 4 (239 = 0xEF = ~0x10)
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
          ;; Apply upward wing flap momentum after swoop attack
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; (equivalent to HarpyJump)
          ;; Same as normal flap: -2 pixels/frame upward (254 in twos
          ;; complement)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 254 (duplicate)
          ;; sta playerVelocityY,x (duplicate)
          ;; -2 in 8-bit twos complement: 256 - 2 = 254
          ;; Keep jumping flag set to allow vertical movement
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)
          ;; playerState[temp1] bit 2 (jumping) already set
          ;; from attack, keep it
          ;; Transition to Idle
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; jmp SetPlayerAnimation (duplicate)
          ;; Placeholder characters (16-30) reuse the table entries for
          ;; Bernie (0) so they no-op on windup and fall to Idle on
          ;; execute, keeping the jump tables dense until bespoke logic
          ;; arrives.

HandleRecoveryEnd
          ;; All characters: Recovery → Idle
          ;; Returns: Far (return otherbank)
          ;; lda ActionIdle (duplicate)
          ;; sta temp2 (duplicate)
          ;; tail call
          ;; jmp SetPlayerAnimation (duplicate)

.pend

