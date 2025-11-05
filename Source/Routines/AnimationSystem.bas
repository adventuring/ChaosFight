          rem ChaosFight - Source/Routines/AnimationSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem 10fps character animation system with platform-specific
          rem   timing

          rem ==========================================================
          rem ANIMATION SYSTEM ROUTINES
          rem ==========================================================

          rem Update character animations for all players
          rem Called every frame to manage 10fps animation timing
UpdateCharacterAnimations
          rem Update animation for each active player
          let currentPlayer = 0  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 1
          let currentPlayer = 1  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 2
          if controllerStatus & SetQuadtariDetected then goto AnimationUpdatePlayer3
          goto AnimationSkipPlayer3
AnimationUpdatePlayer3
          let currentPlayer = 2  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 3
          let currentPlayer = 3  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 4
AnimationSkipPlayer3
          return

          rem Update animation for a specific player
          rem Uses per-sprite 10fps counter (animationCounter), NOT
          rem   global frame counter
          rem INPUT: currentPlayer = player index (0-3)
          rem animationCounter[currentPlayer] = current frame timer
          rem   (per-sprite 10fps counter)
          rem currentAnimationSeq[currentPlayer] = current animation
          rem   action/sequence (0-15)
          rem OUTPUT: None
          rem EFFECTS: Increments per-sprite animation counter, advances
          rem   animation frame when counter reaches threshold,
          rem updates sprite graphics via LoadPlayerSprite, handles
          rem   frame 7 transition logic
UpdatePlayerAnimation
          rem Skip if player is eliminated
          if currentPlayer = 0 && playersEliminated_R & 1 then return
          if currentPlayer = 1 && playersEliminated_R & 2 then return
          if currentPlayer = 2 && playersEliminated_R & 4 then return
          if currentPlayer = 3 && playersEliminated_R & 8 then return
          if playerHealth[currentPlayer] = 0 then return
          
          rem Increment this sprite 10fps animation counter (NOT global
          rem   frame counter)
          rem SCRAM read-modify-write: Read from r077, modify, write to
          rem   w077
          dim UpdatePlayerAnimation_animCounterRead = temp4
          let UpdatePlayerAnimation_animCounterRead = animationCounter_R[currentPlayer]
          let UpdatePlayerAnimation_animCounterRead = UpdatePlayerAnimation_animCounterRead + 1
          let animationCounter_W[currentPlayer] = UpdatePlayerAnimation_animCounterRead
          
          rem Check if time to advance animation frame (every
          rem   AnimationFrameDelay frames)
          if UpdatePlayerAnimation_animCounterRead >= AnimationFrameDelay then goto AdvanceFrame
          goto DoneAdvance
AdvanceFrame
          let animationCounter_W[currentPlayer] = 0
          rem Inline AdvanceAnimationFrame
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter
          rem   (currentAnimationFrame), not global frame
          rem SCRAM read-modify-write: Read from r081, modify, write to
          rem   w081
          dim UpdatePlayerAnimation_animFrameRead = temp4
          let UpdatePlayerAnimation_animFrameRead = currentAnimationFrame_R[currentPlayer]
          let UpdatePlayerAnimation_animFrameRead = UpdatePlayerAnimation_animFrameRead + 1
          let currentAnimationFrame_W[currentPlayer] = UpdatePlayerAnimation_animFrameRead
          
          rem Check if we have completed the current action (8 frames
          rem   per action)
          rem Use temp variable from previous increment
          rem   (UpdatePlayerAnimation_animFrameRead)
          if UpdatePlayerAnimation_animFrameRead >= FramesPerSequence then goto HandleFrame7Transition
          goto UpdateSprite
DoneAdvance
          return

          rem Advance to next frame in current animation action
          rem Frame counter is per-sprite 10fps counter, NOT global
          rem   frame counter
          rem INPUT: currentPlayer = player index (0-3)
          rem currentAnimationSeq[currentPlayer] = current animation
          rem   action/sequence (0-15)
          rem currentAnimationFrame[currentPlayer] = current frame
          rem   within sequence (0-7)
          rem OUTPUT: None
          rem EFFECTS: Increments currentAnimationFrame[currentPlayer],
          rem   checks for frame 7 completion,
          rem triggers HandleAnimationTransition when 8 frames completed
AdvanceAnimationFrame
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter
          rem   (currentAnimationFrame), not global frame
          rem SCRAM read-modify-write: Read from r081, modify, write to
          rem   w081
          dim AdvanceAnimationFrame_animFrameRead = temp4
          let AdvanceAnimationFrame_animFrameRead = currentAnimationFrame_R[currentPlayer]
          let AdvanceAnimationFrame_animFrameRead = AdvanceAnimationFrame_animFrameRead + 1
          let currentAnimationFrame_W[currentPlayer] = AdvanceAnimationFrame_animFrameRead
          
          rem Check if we have completed the current action (8 frames
          rem   per action)
          rem Use temp variable from increment (AdvanceAnimationFrame_animFrameRead)
          if AdvanceAnimationFrame_animFrameRead >= FramesPerSequence then goto HandleFrame7Transition
          goto UpdateSprite
          
HandleFrame7Transition
          rem Frame 7 completed, handle action-specific transitions
          gosub HandleAnimationTransition
          goto UpdateSprite
          
UpdateSprite
          dim UpdateSprite_animationFrame = temp2
          dim UpdateSprite_animationAction = temp3
          dim UpdateSprite_playerNumber = temp4
          rem Update character sprite with current animation frame and
          rem   action
          rem INPUT: currentPlayer = player index (0-3) (uses global
          rem   variable)
          rem currentAnimationFrame[currentPlayer] = current frame
          rem   within sequence (0-7)
          rem currentAnimationSeq[currentPlayer] = current animation
          rem   action/sequence (0-15)
          rem OUTPUT: None
          rem EFFECTS: Loads sprite graphics for current player with
          rem   current animation frame and action sequence
          rem Frame is from this sprite 10fps counter
          rem   (currentAnimationFrame), not global frame counter
          rem SCRAM read: Read from r081
          let UpdateSprite_animationFrame = currentAnimationFrame_R[currentPlayer] 
          let UpdateSprite_animationAction = currentAnimationSeq[currentPlayer]
          let UpdateSprite_playerNumber = currentPlayer
          gosub bank10 LoadPlayerSprite
          
          return

          rem Set animation action for a player
          rem INPUT: currentPlayer = player index (0-3), temp2 =
          rem   animation action (0-15)
          rem OUTPUT: None
          rem EFFECTS: Sets new animation sequence, resets animation
          rem   frame to 0, resets animation counter,
          rem immediately updates sprite graphics to show first frame of
          rem   new animation
SetPlayerAnimation
          dim SetPlayerAnimation_animationAction = temp2
          dim SetPlayerAnimation_animationFrame = temp2
          dim SetPlayerAnimation_animationSeq = temp3
          dim SetPlayerAnimation_playerNumber = temp4
          if SetPlayerAnimation_animationAction >= AnimationSequenceCount then return
          
          let currentAnimationSeq[currentPlayer] = SetPlayerAnimation_animationAction
          rem SCRAM write: Write to w081
          let currentAnimationFrame_W[currentPlayer] = 0 
          rem Start at first frame
          rem SCRAM write: Write to w077
          let animationCounter_W[currentPlayer] = 0      
          rem Reset animation counter
          
          rem Update character sprite immediately
          rem Frame is from this sprite 10fps counter, action from
          rem   currentAnimationSeq
          rem Set up parameters for LoadPlayerSprite
          rem SCRAM read: Read from r081 (we just wrote 0, so this is 0)
          let SetPlayerAnimation_animationFrame = 0
          let SetPlayerAnimation_animationSeq = currentAnimationSeq[currentPlayer]
          let SetPlayerAnimation_playerNumber = currentPlayer
          let temp2 = SetPlayerAnimation_animationFrame
          let temp3 = SetPlayerAnimation_animationSeq
          let temp4 = SetPlayerAnimation_playerNumber
          gosub bank10 LoadPlayerSprite
          
          return

          rem Get current animation frame for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = current animation frame (0-7)
          rem EFFECTS: None (read-only query)
GetCurrentAnimationFrame
          dim GetCurrentAnimationFrame_currentFrame = temp2
          rem SCRAM read: Read from r081
          let GetCurrentAnimationFrame_currentFrame = currentAnimationFrame_R[currentPlayer]
          let temp2 = GetCurrentAnimationFrame_currentFrame
          return

          rem Get current animation action for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem currentAnimationSeq[currentPlayer] = current action (read
          rem   from array)
          rem OUTPUT: temp2 = current animation action (0-15)
          rem EFFECTS: None (read-only query)
GetCurrentAnimationAction
          dim GetCurrentAnimationAction_currentAction = temp2
          let GetCurrentAnimationAction_currentAction = currentAnimationSeq[currentPlayer]
          let temp2 = GetCurrentAnimationAction_currentAction
          return

          rem Initialize animation system for all players
          rem Called at game start to set up initial animation states
          rem INPUT: None
          rem OUTPUT: None
          rem EFFECTS: Sets all players (0-3) to idle animation state
          rem   (ActionIdle)
InitializeAnimationSystem
          dim InitializeAnimationSystem_animationAction = temp2
          rem Initialize all players to idle animation
          let currentPlayer = 0
          let InitializeAnimationSystem_animationAction = ActionIdle
          let temp2 = InitializeAnimationSystem_animationAction
          gosub SetPlayerAnimation
          let currentPlayer = 1
          let temp2 = InitializeAnimationSystem_animationAction
          gosub SetPlayerAnimation
          let currentPlayer = 2
          let temp2 = InitializeAnimationSystem_animationAction
          gosub SetPlayerAnimation
          let currentPlayer = 3
          let temp2 = InitializeAnimationSystem_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem ==========================================================
          rem ANIMATION SEQUENCE MANAGEMENT
          rem ==========================================================

          rem Set walking animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionWalking state
SetWalkingAnimation
          dim SetWalkingAnimation_animationAction = temp2
          let SetWalkingAnimation_animationAction = ActionWalking
          let temp2 = SetWalkingAnimation_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set idle animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionIdle state
SetIdleAnimation
          dim SetIdleAnimation_animationAction = temp2
          let SetIdleAnimation_animationAction = ActionIdle
          let temp2 = SetIdleAnimation_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set attack animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionAttackWindup
          rem   state
SetAttackAnimation
          dim SetAttackAnimation_animationAction = temp2
          let SetAttackAnimation_animationAction = ActionAttackWindup
          let temp2 = SetAttackAnimation_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set hit animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionHit state
SetHitAnimation
          dim SetHitAnimation_animationAction = temp2
          let SetHitAnimation_animationAction = ActionHit
          let temp2 = SetHitAnimation_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set jumping animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionJumping state
SetJumpingAnimation
          dim SetJumpingAnimation_animationAction = temp2
          let SetJumpingAnimation_animationAction = ActionJumping
          let temp2 = SetJumpingAnimation_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set falling animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionFalling state
SetFallingAnimation
          dim SetFallingAnimation_animationAction = temp2
          let SetFallingAnimation_animationAction = ActionFalling
          let temp2 = SetFallingAnimation_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem ==========================================================
          rem ANIMATION STATE QUERIES
          rem ==========================================================

          rem Check if player is in walking animation
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if walking, 0 if not
          rem EFFECTS: None (read-only query)
IsPlayerWalking
          dim IsPlayerWalking_isWalking = temp2
          let IsPlayerWalking_isWalking = 0
          if currentAnimationSeq[currentPlayer] = ActionWalking then let IsPlayerWalking_isWalking = 1
          let temp2 = IsPlayerWalking_isWalking
          return

          rem Check if player is in attack animation
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if attacking, 0 if not
          rem EFFECTS: None (read-only query)
IsPlayerAttacking
          dim IsPlayerAttacking_isAttacking = temp2
          let IsPlayerAttacking_isAttacking = 0
          if currentAnimationSeq[currentPlayer] < ActionAttackWindup then goto NotAttacking
          if currentAnimationSeq[currentPlayer] > ActionAttackRecovery then goto NotAttacking
          let IsPlayerAttacking_isAttacking = 1
NotAttacking
          let temp2 = IsPlayerAttacking_isAttacking
          return

          rem Check if player is in hit animation
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if hit, 0 if not
          rem EFFECTS: None (read-only query)
IsPlayerHit
          dim IsPlayerHit_isHit = temp2
          let IsPlayerHit_isHit = 0
          if currentAnimationSeq[currentPlayer] = ActionHit then let IsPlayerHit_isHit = 1
          let temp2 = IsPlayerHit_isHit
          return

          rem Check if player is in jumping animation
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if jumping, 0 if not
          rem EFFECTS: None (read-only query)
IsPlayerJumping
          dim IsPlayerJumping_isJumping = temp2
          let IsPlayerJumping_isJumping = 0
          if currentAnimationSeq[currentPlayer] = ActionJumping then goto IsJumping
          if currentAnimationSeq[currentPlayer] = ActionFalling then goto IsJumping
          goto NotJumping
IsJumping
          let IsPlayerJumping_isJumping = 1
NotJumping
          let temp2 = IsPlayerJumping_isJumping
          return

          rem ==========================================================
          rem ANIMATION TRANSITION HANDLING
          rem ==========================================================

          rem Handle frame 7 completion and transition to next action
          rem Input: currentPlayer = player index (0-3)
          rem Uses: currentAnimationSeq[currentPlayer] to determine
          rem   transition
HandleAnimationTransition
          dim HandleAnimationTransition_currentAction = temp1
          dim HandleAnimationTransition_animationAction = temp2
          rem Get current action
          let HandleAnimationTransition_currentAction = currentAnimationSeq[currentPlayer]
          
          rem Branch by action type
          if HandleAnimationTransition_currentAction = ActionIdle then goto TransitionLoopAnimation
          if HandleAnimationTransition_currentAction = ActionGuarding then goto TransitionLoopAnimation
          if HandleAnimationTransition_currentAction = ActionFalling then goto TransitionLoopAnimation
          
          rem Special: Jumping stays on frame 7 until falling
          if HandleAnimationTransition_currentAction = ActionJumping then goto TransitionHandleJump
          
          rem Transitions to Idle
          if HandleAnimationTransition_currentAction = ActionLanding then goto TransitionToIdle
          if HandleAnimationTransition_currentAction = ActionHit then goto TransitionToIdle
          if HandleAnimationTransition_currentAction = ActionRecovering then goto TransitionToIdle
          
          rem Special: FallBack checks wall collision
          if HandleAnimationTransition_currentAction = ActionFallBack then goto TransitionHandleFallBack
          
          rem Fallen waits for stick input (handled elsewhere)
          if HandleAnimationTransition_currentAction = ActionFallen then goto TransitionLoopAnimation
          if HandleAnimationTransition_currentAction = ActionFallDown then goto TransitionToFallen
          
          rem Attack transitions (delegate to character-specific
          rem   handler)
          if HandleAnimationTransition_currentAction >= ActionAttackWindup && HandleAnimationTransition_currentAction <= ActionAttackRecovery then goto HandleAttackTransition
          
          rem Default: loop
          goto TransitionLoopAnimation

TransitionLoopAnimation
          rem SCRAM write: Write to w081
          let currentAnimationFrame_W[currentPlayer] = 0
          return

TransitionToIdle
          dim TransitionToIdle_animationAction = temp2
          let TransitionToIdle_animationAction = ActionIdle
          let temp2 = TransitionToIdle_animationAction
          rem tail call
          goto SetPlayerAnimation

TransitionToFallen
          dim TransitionToFallen_animationAction = temp2
          let TransitionToFallen_animationAction = ActionFallen
          let temp2 = TransitionToFallen_animationAction
          rem tail call
          goto SetPlayerAnimation

TransitionHandleJump
          dim TransitionHandleJump_animationAction = temp2
          dim TransitionHandleJump_playerIndex = temp4
          rem Stay on frame 7 until Y velocity goes negative
          rem Check if player is falling (positive Y velocity = downward)
          let TransitionHandleJump_playerIndex = currentPlayer
          if playerVelocityY[TransitionHandleJump_playerIndex] > 0 then TransitionHandleJump_TransitionToFalling
          rem Still ascending (negative or zero Y velocity), stay in jump
          let TransitionHandleJump_animationAction = ActionJumping
          let temp2 = TransitionHandleJump_animationAction
          rem tail call
          goto SetPlayerAnimation
TransitionHandleJump_TransitionToFalling
          rem Falling (positive Y velocity), transition to falling
          let TransitionHandleJump_animationAction = ActionFalling
          let temp2 = TransitionHandleJump_animationAction
          rem tail call
          goto SetPlayerAnimation

TransitionHandleFallBack
          dim TransitionHandleFallBack_animationAction = temp2
          dim TransitionHandleFallBack_playerIndex = temp4
          dim TransitionHandleFallBack_pfColumn = temp5
          dim TransitionHandleFallBack_pfRow = temp6
          rem Check wall collision using pfread
          rem If hit wall: goto idle, else: goto fallen
          let TransitionHandleFallBack_playerIndex = currentPlayer
          rem Convert player X position to playfield column (0-31)
          let TransitionHandleFallBack_pfColumn = playerX[TransitionHandleFallBack_playerIndex]
          let TransitionHandleFallBack_pfColumn = TransitionHandleFallBack_pfColumn - ScreenInsetX
          let TransitionHandleFallBack_pfColumn = TransitionHandleFallBack_pfColumn / 4
          rem Convert player Y position to playfield row (0-7)
          let TransitionHandleFallBack_pfRow = playerY[TransitionHandleFallBack_playerIndex]
          let TransitionHandleFallBack_pfRow = TransitionHandleFallBack_pfRow / 8
          rem Check if player hit a wall (playfield pixel is set)
          if pfread(TransitionHandleFallBack_pfColumn, TransitionHandleFallBack_pfRow) then TransitionHandleFallBack_HitWall
          rem No wall collision, transition to fallen
          let TransitionHandleFallBack_animationAction = ActionFallen
          let temp2 = TransitionHandleFallBack_animationAction
          rem tail call
          goto SetPlayerAnimation
TransitionHandleFallBack_HitWall
          rem Hit wall, transition to idle
          let TransitionHandleFallBack_animationAction = ActionIdle
          let temp2 = TransitionHandleFallBack_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem ==========================================================
          rem ATTACK TRANSITION HANDLING
          rem ==========================================================
          rem Character-specific attack transitions based on patterns
          
HandleAttackTransition
          dim HandleAttackTransition_currentAction = temp1
          rem Branch by attack phase
          let HandleAttackTransition_currentAction = currentAnimationSeq[currentPlayer]
          
          if HandleAttackTransition_currentAction = ActionAttackWindup then goto HandleWindupEnd
          if HandleAttackTransition_currentAction = ActionAttackExecute then goto HandleExecuteEnd
          if HandleAttackTransition_currentAction = ActionAttackRecovery then goto HandleRecoveryEnd
          return
          
HandleWindupEnd
          dim HandleWindupEnd_characterType = temp1
          dim HandleWindupEnd_animationAction = temp2
          rem Character-specific windup→next transitions
          rem Most characters skip windup (go directly to Execute)
          rem Get character ID
          let HandleWindupEnd_characterType = playerChar[currentPlayer]
          rem Dispatch to character-specific windup handler (0-31)
          rem MethHound (31) uses Char15_Windup (Shamone) handler
          let temp1 = HandleWindupEnd_characterType
          if temp1 < 8 then on temp1 goto Char0_Windup, Char1_Windup, Char2_Windup, Char3_Windup, Char4_Windup, Char5_Windup, Char6_Windup, Char7_Windup
          if temp1 < 8 then goto DoneWindupDispatch
          temp1 = temp1 - 8
          if temp1 < 8 then on temp1 goto Char8_Windup, Char9_Windup, Char10_Windup, Char11_Windup, Char12_Windup, Char13_Windup, Char14_Windup, Char15_Windup
          if temp1 < 8 then goto DoneWindupDispatch
          temp1 = temp1 - 8
          if temp1 < 8 then on temp1 goto Char16_Windup, Char17_Windup, Char18_Windup, Char19_Windup, Char20_Windup, Char21_Windup, Char22_Windup, Char23_Windup
          if temp1 < 8 then goto DoneWindupDispatch
          temp1 = temp1 - 8
          on temp1 goto Char24_Windup, Char25_Windup, Char26_Windup, Char27_Windup, Char28_Windup, Char29_Windup, Char30_Windup, Char15_Windup
DoneWindupDispatch
          
Char0_Windup
          rem Bernie: no windup used, Execute only
          return
Char1_Windup
          dim Char1_Windup_animationAction = temp2
          rem Curler: Windup → Recovery
          rem NOTE: Curling stone missile spawning handled by CurlerAttack
          rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          let Char1_Windup_animationAction = ActionAttackRecovery
          let temp2 = Char1_Windup_animationAction
          rem tail call
          goto SetPlayerAnimation
Char2_Windup
          rem Dragon of Storms: Execute only
          return
Char3_Windup
          rem Zoe Ryen: Execute only
          return
Char4_Windup
          dim Char4_Windup_animationAction = temp2
          rem Fat Tony: Windup → Execute
          let Char4_Windup_animationAction = ActionAttackExecute
          let temp2 = Char4_Windup_animationAction
          rem tail call
          goto SetPlayerAnimation
Char5_Windup
          dim Char5_Windup_animationAction = temp2
          rem Megax: Windup → Execute
          let Char5_Windup_animationAction = ActionAttackExecute
          let temp2 = Char5_Windup_animationAction
          rem tail call
          goto SetPlayerAnimation
Char6_Windup
          rem Harpy: Execute only
          return
Char7_Windup
          rem Knight Guy: Execute only
          return
Char8_Windup
          rem Frooty: Execute only
          return
Char9_Windup
          dim Char9_Windup_animationAction = temp2
          rem Nefertem: Windup → Execute
          let Char9_Windup_animationAction = ActionAttackExecute
          let temp2 = Char9_Windup_animationAction
          rem tail call
          goto SetPlayerAnimation
Char10_Windup
          rem Ninjish Guy: Execute only
          return
Char11_Windup
          dim Char11_Windup_animationAction = temp2
          rem Pork Chop: Windup → Execute
          let Char11_Windup_animationAction = ActionAttackExecute
          let temp2 = Char11_Windup_animationAction
          rem tail call
          goto SetPlayerAnimation
Char12_Windup
          rem Radish Goblin: Execute only
          return
Char13_Windup
          rem Robo Tito: Execute only
          return
Char14_Windup
          rem Ursulo: Execute only
          return
Char15_Windup
          rem Shamone: Execute only
          return

HandleExecuteEnd
          dim HandleExecuteEnd_characterType = temp1
          dim HandleExecuteEnd_animationAction = temp2
          rem Character-specific execute→next transitions
          let HandleExecuteEnd_characterType = playerChar[currentPlayer]
          rem Dispatch to character-specific execute handler (0-31)
          rem MethHound (31) uses Char15_Execute (Shamone) handler
          let temp1 = HandleExecuteEnd_characterType
          if temp1 < 8 then on temp1 goto Char0_Execute, Char1_Execute, Char2_Execute, Char3_Execute, Char4_Execute, Char5_Execute, Char6_Execute, Char7_Execute
          if temp1 < 8 then goto DoneExecuteDispatch
          temp1 = temp1 - 8
          if temp1 < 8 then on temp1 goto Char8_Execute, Char9_Execute, Char10_Execute, Char11_Execute, Char12_Execute, Char13_Execute, Char14_Execute, Char15_Execute
          if temp1 < 8 then goto DoneExecuteDispatch
          temp1 = temp1 - 8
          if temp1 < 8 then on temp1 goto Char16_Execute, Char17_Execute, Char18_Execute, Char19_Execute, Char20_Execute, Char21_Execute, Char22_Execute, Char23_Execute
          if temp1 < 8 then goto DoneExecuteDispatch
          temp1 = temp1 - 8
          on temp1 goto Char24_Execute, Char25_Execute, Char26_Execute, Char27_Execute, Char28_Execute, Char29_Execute, Char30_Execute, Char15_Execute
DoneExecuteDispatch
          
Char0_Execute
          dim Char0_Execute_animationAction = temp2
          rem Bernie: Execute → Idle
          let Char0_Execute_animationAction = ActionIdle
          let temp2 = Char0_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char1_Execute
          rem Curler: no Execute used
          return
Char2_Execute
          dim Char2_Execute_animationAction = temp2
          rem Dragon of Storms: Execute → Idle
          let Char2_Execute_animationAction = ActionIdle
          let temp2 = Char2_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char3_Execute
          dim Char3_Execute_animationAction = temp2
          rem Zoe Ryen: Execute → Idle
          let Char3_Execute_animationAction = ActionIdle
          let temp2 = Char3_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char4_Execute
          dim Char4_Execute_animationAction = temp2
          rem Fat Tony: Execute → Recovery
          rem NOTE: Laser bullet missile spawning handled by FatTonyAttack
          rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          let Char4_Execute_animationAction = ActionAttackRecovery
          let temp2 = Char4_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char5_Execute
          dim Char5_Execute_animationAction = temp2
          rem Megax: Execute → Idle (fire breath during Execute)
          let Char5_Execute_animationAction = ActionIdle
          let temp2 = Char5_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char6_Execute
          dim Char6_Execute_animationAction = temp2
          dim Char6_Execute_playerIndex = temp1
          rem Harpy: Execute → Idle
          rem Clear dive flag and stop diagonal movement when attack
          rem   completes
          rem Also apply upward wing flap momentum after swoop attack
          let Char6_Execute_playerIndex = currentPlayer
          rem Clear dive flag (bit 4 in characterStateFlags)
          rem Fix RMW: Read from _R, modify, write to _W
          let Char6_Execute_stateFlags = characterStateFlags_R[Char6_Execute_playerIndex] & 239
          let characterStateFlags_W[Char6_Execute_playerIndex] = Char6_Execute_stateFlags
          rem Clear bit 4 (239 = 0xEF = ~0x10)
          rem Stop horizontal velocity (zero X velocity)
          let playerVelocityX[Char6_Execute_playerIndex] = 0
          let playerVelocityX_lo[Char6_Execute_playerIndex] = 0
          rem Apply upward wing flap momentum after swoop attack
          rem   (equivalent to HarpyJump)
          rem Same as normal flap: -2 pixels/frame upward (254 in two's
          rem   complement)
          let playerVelocityY[Char6_Execute_playerIndex] = 254
          rem -2 in 8-bit two's complement: 256 - 2 = 254
          let playerVelocityY_lo[Char6_Execute_playerIndex] = 0
          rem Keep jumping flag set to allow vertical movement
          rem playerState[Char6_Execute_playerIndex] bit 2 (jumping) already set
          rem   from attack, keep it
          rem Transition to Idle
          let Char6_Execute_animationAction = ActionIdle
          let temp2 = Char6_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char7_Execute
          dim Char7_Execute_animationAction = temp2
          rem Knight Guy: Execute → Idle (sword during Execute)
          let Char7_Execute_animationAction = ActionIdle
          let temp2 = Char7_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char8_Execute
          dim Char8_Execute_animationAction = temp2
          rem Frooty: Execute → Idle
          let Char8_Execute_animationAction = ActionIdle
          let temp2 = Char8_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char9_Execute
          dim Char9_Execute_animationAction = temp2
          rem Nefertem: Execute → Idle
          let Char9_Execute_animationAction = ActionIdle
          let temp2 = Char9_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char10_Execute
          dim Char10_Execute_animationAction = temp2
          rem Ninjish Guy: Execute → Idle
          let Char10_Execute_animationAction = ActionIdle
          let temp2 = Char10_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char11_Execute
          dim Char11_Execute_animationAction = temp2
          rem Pork Chop: Execute → Recovery
          let Char11_Execute_animationAction = ActionAttackRecovery
          let temp2 = Char11_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char12_Execute
          dim Char12_Execute_animationAction = temp2
          rem Radish Goblin: Execute → Idle
          let Char12_Execute_animationAction = ActionIdle
          let temp2 = Char12_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char13_Execute
          dim Char13_Execute_animationAction = temp2
          rem Robo Tito: Execute → Idle
          let Char13_Execute_animationAction = ActionIdle
          let temp2 = Char13_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char14_Execute
          dim Char14_Execute_animationAction = temp2
          rem Ursulo: Execute → Idle
          let Char14_Execute_animationAction = ActionIdle
          let temp2 = Char14_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation
Char15_Execute
          dim Char15_Execute_animationAction = temp2
          rem Shamone: Execute → Idle
          let Char15_Execute_animationAction = ActionIdle
          let temp2 = Char15_Execute_animationAction
          rem tail call
          goto SetPlayerAnimation

HandleRecoveryEnd
          dim HandleRecoveryEnd_animationAction = temp2
          rem All characters: Recovery → Idle
          let HandleRecoveryEnd_animationAction = ActionIdle
          let temp2 = HandleRecoveryEnd_animationAction
          rem tail call
          goto SetPlayerAnimation
