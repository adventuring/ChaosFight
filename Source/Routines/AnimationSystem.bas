          rem ChaosFight - Source/Routines/AnimationSystem.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

          data CharacterWindupNextAction
            255, 15, 255, 255, 14, 14, 255, 255, 255, 14, 255, 14, 255, 255, 255, 255
end

          data CharacterExecuteNextAction
            1, 255, 1, 1, 15, 1, 1, 1, 1, 1, 1, 15, 1, 1, 1, 1
end

UpdateCharacterAnimations
          rem Returns: Far (return otherbank)
          asm
UpdateCharacterAnimations

end
          rem Drives the 10fps animation system for every active player
          rem Returns: Far (return otherbank)
          rem Inputs: controllerStatus (global), currentPlayer (global scratch)
          rem         animationCounter_R[] (SCRAM), currentAnimationFrame_R[],
          rem         currentAnimationSeq[], playerHealth[] (global array)
          rem Outputs: animationCounter_W[], currentAnimationFrame_W[], player sprite state
          rem Mutates: currentPlayer (0-3), animationCounter_W[], currentAnimationFrame_W[]
          rem Calls: UpdatePlayerAnimation (bank10), LoadPlayerSprite (bank16)
          rem Constraints: None
          dim UCA_quadtariActive = temp5
          let UCA_quadtariActive = controllerStatus & SetQuadtariDetected
          for currentPlayer = 0 to 3
          if currentPlayer >= 2 && !UCA_quadtariActive then goto AnimationNextPlayer
          rem CRITICAL: Inlined UpdatePlayerAnimation to reduce stack depth from 19 to 17 bytes
          rem Skip if player is eliminated (health = 0)
          if playerHealth[currentPlayer] = 0 then goto AnimationNextPlayer

          rem Increment this sprite 10fps animation counter (NOT global
          rem   frame counter)
          rem SCRAM read-modify-write: animationCounter_R → animationCounter_W
          let temp4 = animationCounter_R[currentPlayer] + 1
          let animationCounter_W[currentPlayer] = temp4

          rem Check if time to advance animation frame (every AnimationFrameDelay frames)
          if temp4 < AnimationFrameDelay then goto DoneAdvanceInlined
AdvanceFrame
          rem Advance animation frame (counter reached threshold)
          rem Returns: Far (return otherbank)
          rem
          rem Input: currentPlayer (global), currentAnimationFrame_R[]
          rem (from UpdatePlayerAnimation)
          rem
          rem Output: animationCounter_W[] reset to 0,
          rem currentAnimationFrame_W[] incremented,
          rem         dispatches to HandleFrame7Transition or
          rem         UpdateSprite
          rem
          rem Mutates: animationCounter_W[] (reset to 0),
          rem currentAnimationFrame_W[] (incremented),
          rem         temp4 (used for frame read)
          rem
          rem Called Routines: HandleAnimationTransition - handles frame
          rem 7 completion,
          rem   UpdateSprite - loads player sprite
          rem
          rem Constraints: Must be colocated with UpdatePlayerAnimation,
          rem DoneAdvance, HandleFrame7Transition,
          rem              UpdateSprite
          let animationCounter_W[currentPlayer] = 0
          rem Inline AdvanceAnimationFrame
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter
          rem   (currentAnimationFrame), not global frame
          rem SCRAM read-modify-write: currentAnimationFrame_R → currentAnimationFrame_W
          let temp4 = currentAnimationFrame_R[currentPlayer]
          let temp4 = 1 + temp4
          let currentAnimationFrame_W[currentPlayer] = temp4

          rem Check if we have completed the current action (8 frames
          rem   per action)
          rem Use temp variable from previous increment
          rem   (temp4)
          if temp4 >= FramesPerSequence then goto HandleFrame7Transition
          goto UpdateSprite
DoneAdvance
          return thisbank
HandleFrame7Transition
          rem Frame 7 completed, handle action-specific transitions
          rem Returns: Far (return otherbank)
          rem
          rem Input: currentPlayer (global) = player index (from
          rem UpdatePlayerAnimation/AdvanceFrame)
          rem
          rem Output: Animation transition handled, dispatches to
          rem UpdateSprite
          rem
          rem Mutates: Animation state (via inlined HandleAnimationTransition)
          rem
          rem Called Routines: None (HandleAnimationTransition inlined to save 4 bytes)
          rem   UpdateSprite - loads player sprite
          rem
          rem Constraints: Must be colocated with UpdatePlayerAnimation,
          rem AdvanceAnimationFrame, UpdateSprite
          rem CRITICAL: Inlined HandleAnimationTransition to save 4 bytes on stack
          rem (was: gosub HandleAnimationTransition bank12)
          let temp1 = currentAnimationSeq_R[currentPlayer]
          if ActionAttackRecovery < temp1 then goto AnimationTransitionLoopAnimation

          on temp1 goto AnimationTransitionLoopAnimation AnimationTransitionLoopAnimation AnimationTransitionLoopAnimation AnimationTransitionLoopAnimation AnimationTransitionLoopAnimation AnimationTransitionToIdle AnimationTransitionHandleFallBack AnimationTransitionToFallen AnimationTransitionLoopAnimation AnimationTransitionToIdle AnimationTransitionHandleJump AnimationTransitionLoopAnimation AnimationTransitionToIdle AnimationHandleAttackTransition AnimationHandleAttackTransition AnimationHandleAttackTransition

AnimationTransitionLoopAnimation
          let currentAnimationFrame_W[currentPlayer] = 0
          goto UpdateSprite

AnimationTransitionToIdle
          let temp2 = ActionIdle
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationTransitionToFallen
          let temp2 = ActionFallen
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationTransitionHandleJump
          rem Stay on frame 7 until Y velocity goes negative
          if 0 < playerVelocityY[currentPlayer] then AnimationTransitionHandleJump_TransitionToFalling
          let temp2 = ActionJumping
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationTransitionHandleJump_TransitionToFalling
          rem Falling (positive Y velocity), transition to falling
          let temp2 = ActionFalling
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationTransitionHandleFallBack
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
          if temp1 then AnimationTransitionHandleFallBack_HitWall
          rem No wall collision, transition to fallen
          let temp2 = ActionFallen
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationTransitionHandleFallBack_HitWall
          rem Hit wall, transition to idle
          let temp2 = ActionIdle
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationHandleAttackTransition
          let temp1 = currentAnimationSeq_R[currentPlayer]
          if temp1 < ActionAttackWindup then goto UpdateSprite
          let temp1 = temp1 - ActionAttackWindup
          on temp1 goto AnimationHandleWindupEnd AnimationHandleExecuteEnd AnimationHandleRecoveryEnd
          goto UpdateSprite

AnimationHandleWindupEnd
          let temp1 = playerCharacter[currentPlayer]
          if temp1 >= 32 then goto UpdateSprite
          if temp1 >= 16 then let temp1 = 0
          let temp2 = CharacterWindupNextAction[temp1]
          if temp2 = 255 then goto UpdateSprite
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationHandleExecuteEnd
          let temp1 = playerCharacter[currentPlayer]
          if temp1 >= 32 then goto UpdateSprite
          if temp1 = 6 then goto AnimationHarpyExecute
          if temp1 >= 16 then let temp1 = 0
          let temp2 = CharacterExecuteNextAction[temp1]
          if temp2 = 255 then goto UpdateSprite
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationHarpyExecute
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
          goto AnimationSetPlayerAnimationInlined

AnimationHandleRecoveryEnd
          rem All characters: Recovery → Idle
          let temp2 = ActionIdle
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          goto AnimationSetPlayerAnimationInlined

AnimationSetPlayerAnimationInlined
          rem CRITICAL: Inlined SetPlayerAnimation to save 4 bytes on stack
          rem Set animation action for a player (inlined from AnimationSystem.bas)
          if temp2 >= AnimationSequenceCount then goto UpdateSprite
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
          rem Fall through to UpdateSprite which has inlined LoadPlayerSprite logic

UpdateSprite
          rem Update character sprite with current animation frame and
          rem Returns: Far (return otherbank)
          rem action
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        currentAnimationFrame_R[] (global SCRAM array) =
          rem        current animation frames
          rem        currentAnimationSeq[] (global array) = current
          rem        animation sequences
          rem
          rem Output: Player sprite loaded with current animation frame
          rem and action
          rem
          rem Mutates: temp2, temp3, temp4 (passed to LoadPlayerSprite),
          rem player sprite pointers (via LoadPlayerSprite)
          rem
          rem Called Routines: LoadPlayerSprite (bank16) - loads
          rem character sprite graphics
          rem
          rem Constraints: Must be colocated with UpdatePlayerAnimation,
          rem AdvanceAnimationFrame, HandleFrame7Transition
          rem Update character sprite with current animation frame and
          rem   action
          rem
          rem INPUT: currentPlayer = player index (0-3) (uses global
          rem   variable)
          rem currentAnimationFrame[currentPlayer] = current frame
          rem   within sequence (0-7)
          rem currentAnimationSeq[currentPlayer] = current animation
          rem   action/sequence (0-15)
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Loads sprite graphics for current player with
          rem   current animation frame and action sequence
          rem Frame is from this sprite 10fps counter
          rem   (currentAnimationFrame), not global frame counter
          rem SCRAM read: Read from r081
          rem   where dim entries concatenate with subsequent constants
          let temp2 = currentAnimationFrame_R[currentPlayer]
          let temp3 = currentAnimationSeq_R[currentPlayer]
          let temp4 = currentPlayer
          rem CRITICAL: Inlined LoadPlayerSprite dispatcher to save 4 bytes on stack
          let currentCharacter = playerCharacter[currentPlayer]
          let temp1 = currentCharacter
          let temp6 = temp1
          rem Check which bank: 0-7=Bank2, 8-15=Bank3, 16-23=Bank4, 24-31=Bank5
          if temp1 < 8 then goto UpdateSprite_Bank2Dispatch
          if temp1 < 16 then goto UpdateSprite_Bank3Dispatch
          if temp1 < 24 then goto UpdateSprite_Bank4Dispatch
          goto UpdateSprite_Bank5Dispatch

UpdateSprite_Bank2Dispatch
          let temp6 = temp1
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank2 bank2
          goto AnimationNextPlayer

UpdateSprite_Bank3Dispatch
          let temp6 = temp1 - 8
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank3 bank3
          goto AnimationNextPlayer

UpdateSprite_Bank4Dispatch
          let temp6 = temp1 - 16
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank4 bank4
          goto AnimationNextPlayer

UpdateSprite_Bank5Dispatch
          let temp6 = temp1 - 24
          let temp5 = temp4
          gosub SetPlayerCharacterArtBank5 bank5
          goto AnimationNextPlayer
DoneAdvanceInlined
          rem End of inlined UpdatePlayerAnimation - skip to next player
          goto AnimationNextPlayer
AnimationNextPlayer
          next
          return otherbank
SetPlayerAnimation
          rem Returns: Far (return otherbank)
          asm
SetPlayerAnimation

end
          rem Set animation action for a player
          rem Returns: Far (return otherbank)
          rem
          rem INPUT: currentPlayer = player index (0-3), temp2 =
          rem   animation action (0-15)
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Sets new animation sequence, resets animation
          rem   frame to 0, resets animation counter,
          rem immediately updates sprite graphics to show first frame of
          rem   new animation
          rem Set animation action for a player
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        temp2 = animation action (0-15)
          rem        AnimationSequenceCount (constant) = maximum
          rem        animation sequence count
          rem
          rem Output: currentAnimationSeq[] updated,
          rem currentAnimationFrame_W[] reset to 0,
          rem         animationCounter_W[] reset to 0, player sprite
          rem         updated
          rem
          rem Mutates: currentAnimationSeq[] (set to new action),
          rem currentAnimationFrame_W[] (reset to 0),
          rem         animationCounter_W[] (reset to 0), temp2, temp3,
          rem         temp4 (passed to LoadPlayerSprite),
          rem         player sprite pointers (via LoadPlayerSprite)
          rem
          rem Called Routines: LoadPlayerSprite (bank16) - loads
          rem character sprite graphics
          rem Constraints: None
          if temp2 >= AnimationSequenceCount then return otherbank

          rem SCRAM write to currentAnimationFrame_W
          let currentAnimationSeq_W[currentPlayer] = temp2
          rem Start at first frame
          let currentAnimationFrame_W[currentPlayer] = 0
          rem SCRAM write to animationCounter_W
          rem Reset animation counter
          let animationCounter_W[currentPlayer] = 0

          rem Update character sprite immediately
          rem Frame is from this sprite 10fps counter, action from
          rem   currentAnimationSeq
          rem Set up parameters for LoadPlayerSprite
          rem SCRAM read: Read from r081 (we just wrote 0, so this is 0)
          let temp2 = 0
          let temp3 = currentAnimationSeq_R[currentPlayer]
          let temp4 = currentPlayer
          gosub LoadPlayerSprite bank16

          return otherbank

InitializeAnimationSystem
          rem Initialize animation system for all players
          rem Returns: Far (return otherbank)
          rem Called at game start to set up initial animation states
          rem
          rem INPUT: None
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Sets all players (0-3) to idle animation state
          rem (ActionIdle)
          rem Initialize all players to idle animation
          let temp2 = ActionIdle
          for currentPlayer = 0 to 3
            gosub SetPlayerAnimation bank12
          next
          return otherbank
HandleAnimationTransition
          rem Returns: Far (return thisbank)
          asm
HandleAnimationTransition
end
          let temp1 = currentAnimationSeq_R[currentPlayer]
          if ActionAttackRecovery < temp1 then goto TransitionLoopAnimation

          on temp1 goto TransitionLoopAnimation TransitionLoopAnimation TransitionLoopAnimation TransitionLoopAnimation TransitionLoopAnimation TransitionToIdle TransitionHandleFallBack TransitionToFallen TransitionLoopAnimation TransitionToIdle TransitionHandleJump TransitionLoopAnimation TransitionToIdle HandleAttackTransition HandleAttackTransition HandleAttackTransition

TransitionLoopAnimation
          rem SCRAM write to currentAnimationFrame_W
          rem Returns: Far (return otherbank)
          let currentAnimationFrame_W[currentPlayer] = 0
          return otherbank
TransitionToIdle
          let temp2 = ActionIdle
          rem tail call
          goto SetPlayerAnimation

TransitionToFallen
          rem Returns: Far (return otherbank)
          let temp2 = ActionFallen
          rem tail call
          rem Returns: Far (return otherbank)
          goto SetPlayerAnimation

TransitionHandleJump
          rem Stay on frame 7 until Y velocity goes negative
          rem Returns: Far (return otherbank)
          rem Check if player is falling (positive Y velocity =
          rem downward)
          rem Still ascending (negative or zero Y velocity), stay in jump
          if 0 < playerVelocityY[currentPlayer] then TransitionHandleJump_TransitionToFalling
          let temp2 = ActionJumping
          rem tail call
          goto SetPlayerAnimation
TransitionHandleJump_TransitionToFalling
          rem Falling (positive Y velocity), transition to falling
          rem Returns: Far (return otherbank)
          let temp2 = ActionFalling
          rem tail call
          goto SetPlayerAnimation

TransitionHandleFallBack
          rem Check wall collision using pfread
          rem Returns: Far (return otherbank)
          rem If hit wall: goto idle, else: goto fallen
          rem Convert player X position to playfield column (0-31)
          let temp5 = playerX[currentPlayer]
          let temp5 = temp5 - ScreenInsetX
          let temp5 = temp5 / 4
          rem Convert player Y position to playfield row (0-7)
          let temp6 = playerY[currentPlayer]
          rem Check if player hit a wall (playfield pixel is set)
          let temp6 = temp6 / 8
          let temp1 = temp5
          let temp3 = temp2
          let temp2 = temp6
          gosub PlayfieldRead bank16
          let temp2 = temp3
          if temp1 then TransitionHandleFallBack_HitWall
          rem No wall collision, transition to fallen
          let temp2 = ActionFallen
          rem tail call
          goto SetPlayerAnimation
TransitionHandleFallBack_HitWall
          rem Hit wall, transition to idle
          rem Returns: Far (return otherbank)
          let temp2 = ActionIdle
          rem tail call
          goto SetPlayerAnimation

          rem
          rem Attack Transition Handling
          rem Character-specific attack transitions based on patterns

HandleAttackTransition
          rem Returns: Far (return otherbank)
          let temp1 = currentAnimationSeq_R[currentPlayer]
          if temp1 < ActionAttackWindup then return otherbank
          let temp1 = temp1 - ActionAttackWindup
          on temp1 goto HandleWindupEnd HandleExecuteEnd HandleRecoveryEnd
          return otherbank
HandleWindupEnd
          let temp1 = playerCharacter[currentPlayer]
          if temp1 >= 32 then return thisbank
          if temp1 >= 16 then let temp1 = 0
          let temp2 = CharacterWindupNextAction[temp1]
          if temp2 = 255 then return thisbank
          goto SetPlayerAnimation

HandleExecuteEnd
          rem Returns: Far (return otherbank)
          let temp1 = playerCharacter[currentPlayer]
          if temp1 >= 32 then return otherbank
          if temp1 = 6 then goto HarpyExecute
          if temp1 >= 16 then let temp1 = 0
          let temp2 = CharacterExecuteNextAction[temp1]
          if temp2 = 255 then return otherbank
          goto SetPlayerAnimation

HarpyExecute
          rem Harpy: Execute → Idle
          rem Returns: Far (return otherbank)
          rem Clear dive flag and stop diagonal movement when attack
          rem   completes
          rem Also apply upward wing flap momentum after swoop attack
          let temp1 = currentPlayer
          rem Clear dive flag (bit 4 in characterStateFlags)
          rem Fix RMW: Read from _R, modify, write to _W
          let C6E_stateFlags = 239 & characterStateFlags_R[temp1]
          rem Clear bit 4 (239 = 0xEF = ~0x10)
          let characterStateFlags_W[temp1] = C6E_stateFlags
          rem Stop horizontal velocity (zero X velocity)
          let playerVelocityX[temp1] = 0
          rem Apply upward wing flap momentum after swoop attack
          let playerVelocityXL[temp1] = 0
          rem   (equivalent to HarpyJump)
          rem Same as normal flap: -2 pixels/frame upward (254 in twos
          rem   complement)
          let playerVelocityY[temp1] = 254
          rem -2 in 8-bit twos complement: 256 - 2 = 254
          rem Keep jumping flag set to allow vertical movement
          let playerVelocityYL[temp1] = 0
          rem playerState[temp1] bit 2 (jumping) already set
          rem   from attack, keep it
          rem Transition to Idle
          let temp2 = ActionIdle
          rem tail call
          goto SetPlayerAnimation
          rem Placeholder characters (16-30) reuse the table entries for
          rem Bernie (0) so they no-op on windup and fall to Idle on
          rem execute, keeping the jump tables dense until bespoke logic
          rem arrives.

HandleRecoveryEnd
          rem All characters: Recovery → Idle
          rem Returns: Far (return otherbank)
          let temp2 = ActionIdle
          rem tail call
          goto SetPlayerAnimation
