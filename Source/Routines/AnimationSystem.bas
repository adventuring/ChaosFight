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
          dim UAS_animCounterRead = temp4
          let UAS_animCounterRead = animationCounter_R[currentPlayer]
          let UAS_animCounterRead = UAS_animCounterRead + 1
          let animationCounter_W[currentPlayer] = UAS_animCounterRead
          
          rem Check if time to advance animation frame (every
          rem   AnimationFrameDelay frames)
          if UAS_animCounterRead >= AnimationFrameDelay then goto AdvanceFrame
          goto DoneAdvance
AdvanceFrame
          let animationCounter_W[currentPlayer] = 0
          rem Inline AdvanceAnimationFrame
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter
          rem   (currentAnimationFrame), not global frame
          rem SCRAM read-modify-write: Read from r081, modify, write to
          rem   w081
          dim UAS_animFrameRead = temp4
          let UAS_animFrameRead = currentAnimationFrame_R[currentPlayer]
          let UAS_animFrameRead = UAS_animFrameRead + 1
          let currentAnimationFrame_W[currentPlayer] = UAS_animFrameRead
          
          rem Check if we have completed the current action (8 frames
          rem   per action)
          rem Use temp variable from previous increment
          rem   (UAS_animFrameRead)
          if UAS_animFrameRead >= FramesPerSequence then goto HandleFrame7Transition
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
          dim AAF_animFrameRead = temp4
          let AAF_animFrameRead = currentAnimationFrame_R[currentPlayer]
          let AAF_animFrameRead = AAF_animFrameRead + 1
          let currentAnimationFrame_W[currentPlayer] = AAF_animFrameRead
          
          rem Check if we have completed the current action (8 frames
          rem   per action)
          rem Use temp variable from increment (AAF_animFrameRead)
          if AAF_animFrameRead >= FramesPerSequence then goto HandleFrame7Transition
          goto UpdateSprite
          
HandleFrame7Transition
          rem Frame 7 completed, handle action-specific transitions
          gosub HandleAnimationTransition
          goto UpdateSprite
          
UpdateSprite
          dim US_animationFrame = temp2
          dim US_animationAction = temp3
          dim US_playerNumber = temp4
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
          let US_animationFrame = currentAnimationFrame_R[currentPlayer] 
          let US_animationAction = currentAnimationSeq[currentPlayer]
          let US_playerNumber = currentPlayer
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
          dim SPA_animationAction = temp2
          dim SPA_animationFrame = temp2
          dim SPA_animationSeq = temp3
          dim SPA_playerNumber = temp4
          if SPA_animationAction >= AnimationSequenceCount then return
          
          let currentAnimationSeq[currentPlayer] = SPA_animationAction
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
          let SPA_animationFrame = 0
          let SPA_animationSeq = currentAnimationSeq[currentPlayer]
          let SPA_playerNumber = currentPlayer
          let temp2 = SPA_animationFrame
          let temp3 = SPA_animationSeq
          let temp4 = SPA_playerNumber
          gosub bank10 LoadPlayerSprite
          
          return

          rem Get current animation frame for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = current animation frame (0-7)
          rem EFFECTS: None (read-only query)
GetCurrentAnimationFrame
          dim GCAF_currentFrame = temp2
          rem SCRAM read: Read from r081
          let GCAF_currentFrame = currentAnimationFrame_R[currentPlayer]
          let temp2 = GCAF_currentFrame
          return

          rem Get current animation action for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem currentAnimationSeq[currentPlayer] = current action (read
          rem   from array)
          rem OUTPUT: temp2 = current animation action (0-15)
          rem EFFECTS: None (read-only query)
GetCurrentAnimationAction
          dim GCAA_currentAction = temp2
          let GCAA_currentAction = currentAnimationSeq[currentPlayer]
          let temp2 = GCAA_currentAction
          return

          rem Initialize animation system for all players
          rem Called at game start to set up initial animation states
          rem INPUT: None
          rem OUTPUT: None
          rem EFFECTS: Sets all players (0-3) to idle animation state
          rem   (ActionIdle)
InitializeAnimationSystem
          dim IAS_animationAction = temp2
          rem Initialize all players to idle animation
          let currentPlayer = 0
          let IAS_animationAction = ActionIdle
          let temp2 = IAS_animationAction
          gosub SetPlayerAnimation
          let currentPlayer = 1
          let temp2 = IAS_animationAction
          gosub SetPlayerAnimation
          let currentPlayer = 2
          let temp2 = IAS_animationAction
          gosub SetPlayerAnimation
          let currentPlayer = 3
          let temp2 = IAS_animationAction
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
          dim SWA_animationAction = temp2
          let SWA_animationAction = ActionWalking
          let temp2 = SWA_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set idle animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionIdle state
SetIdleAnimation
          dim SIA_animationAction = temp2
          let SIA_animationAction = ActionIdle
          let temp2 = SIA_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set attack animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionAttackWindup
          rem   state
SetAttackAnimation
          dim SAA_animationAction = temp2
          let SAA_animationAction = ActionAttackWindup
          let temp2 = SAA_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set hit animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionHit state
SetHitAnimation
          dim SHA_animationAction = temp2
          let SHA_animationAction = ActionHit
          let temp2 = SHA_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set jumping animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionJumping state
SetJumpingAnimation
          dim SJA_animationAction = temp2
          let SJA_animationAction = ActionJumping
          let temp2 = SJA_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem Set falling animation for a player
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionFalling state
SetFallingAnimation
          dim SFA_animationAction = temp2
          let SFA_animationAction = ActionFalling
          let temp2 = SFA_animationAction
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
          dim IPW_isWalking = temp2
          let IPW_isWalking = 0
          if currentAnimationSeq[currentPlayer] = ActionWalking then let IPW_isWalking = 1
          let temp2 = IPW_isWalking
          return

          rem Check if player is in attack animation
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if attacking, 0 if not
          rem EFFECTS: None (read-only query)
IsPlayerAttacking
          dim IPA_isAttacking = temp2
          let IPA_isAttacking = 0
          if currentAnimationSeq[currentPlayer] < ActionAttackWindup then goto NotAttacking
          if currentAnimationSeq[currentPlayer] > ActionAttackRecovery then goto NotAttacking
          let IPA_isAttacking = 1
NotAttacking
          let temp2 = IPA_isAttacking
          return

          rem Check if player is in hit animation
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if hit, 0 if not
          rem EFFECTS: None (read-only query)
IsPlayerHit
          dim IPH_isHit = temp2
          let IPH_isHit = 0
          if currentAnimationSeq[currentPlayer] = ActionHit then let IPH_isHit = 1
          let temp2 = IPH_isHit
          return

          rem Check if player is in jumping animation
          rem INPUT: currentPlayer = player index (0-3)
          rem OUTPUT: temp2 = 1 if jumping, 0 if not
          rem EFFECTS: None (read-only query)
IsPlayerJumping
          dim IPJ_isJumping = temp2
          let IPJ_isJumping = 0
          if currentAnimationSeq[currentPlayer] = ActionJumping then goto IsJumping
          if currentAnimationSeq[currentPlayer] = ActionFalling then goto IsJumping
          goto NotJumping
IsJumping
          let IPJ_isJumping = 1
NotJumping
          let temp2 = IPJ_isJumping
          return

          rem ==========================================================
          rem ANIMATION TRANSITION HANDLING
          rem ==========================================================

          rem Handle frame 7 completion and transition to next action
          rem Input: currentPlayer = player index (0-3)
          rem Uses: currentAnimationSeq[currentPlayer] to determine
          rem   transition
HandleAnimationTransition
          dim HAT_currentAction = temp1
          dim HAT_animationAction = temp2
          rem Get current action
          let HAT_currentAction = currentAnimationSeq[currentPlayer]
          
          rem Branch by action type
          if HAT_currentAction = ActionIdle then goto TransitionLoopAnimation
          if HAT_currentAction = ActionGuarding then goto TransitionLoopAnimation
          if HAT_currentAction = ActionFalling then goto TransitionLoopAnimation
          
          rem Special: Jumping stays on frame 7 until falling
          if HAT_currentAction = ActionJumping then goto TransitionHandleJump
          
          rem Transitions to Idle
          if HAT_currentAction = ActionLanding then goto TransitionToIdle
          if HAT_currentAction = ActionHit then goto TransitionToIdle
          if HAT_currentAction = ActionRecovering then goto TransitionToIdle
          
          rem Special: FallBack checks wall collision
          if HAT_currentAction = ActionFallBack then goto TransitionHandleFallBack
          
          rem Fallen waits for stick input (handled elsewhere)
          if HAT_currentAction = ActionFallen then goto TransitionLoopAnimation
          if HAT_currentAction = ActionFallDown then goto TransitionToFallen
          
          rem Attack transitions (delegate to character-specific
          rem   handler)
          if HAT_currentAction >= ActionAttackWindup && HAT_currentAction <= ActionAttackRecovery then goto HandleAttackTransition
          
          rem Default: loop
          goto TransitionLoopAnimation

TransitionLoopAnimation
          rem SCRAM write: Write to w081
          let currentAnimationFrame_W[currentPlayer] = 0
          return

TransitionToIdle
          dim TTI_animationAction = temp2
          let TTI_animationAction = ActionIdle
          let temp2 = TTI_animationAction
          rem tail call
          goto SetPlayerAnimation

TransitionToFallen
          dim TTF_animationAction = temp2
          let TTF_animationAction = ActionFallen
          let temp2 = TTF_animationAction
          rem tail call
          goto SetPlayerAnimation

TransitionHandleJump
          dim THJ_animationAction = temp2
          dim THJ_playerIndex = temp4
          rem Stay on frame 7 until Y velocity goes negative
          rem Check if player is falling (positive Y velocity = downward)
          let THJ_playerIndex = currentPlayer
          if playerVelocityY[THJ_playerIndex] > 0 then THJ_TransitionToFalling
          rem Still ascending (negative or zero Y velocity), stay in jump
          let THJ_animationAction = ActionJumping
          let temp2 = THJ_animationAction
          rem tail call
          goto SetPlayerAnimation
THJ_TransitionToFalling
          rem Falling (positive Y velocity), transition to falling
          let THJ_animationAction = ActionFalling
          let temp2 = THJ_animationAction
          rem tail call
          goto SetPlayerAnimation

TransitionHandleFallBack
          dim THFB_animationAction = temp2
          dim THFB_playerIndex = temp4
          dim THFB_pfColumn = temp5
          dim THFB_pfRow = temp6
          rem Check wall collision using pfread
          rem If hit wall: goto idle, else: goto fallen
          let THFB_playerIndex = currentPlayer
          rem Convert player X position to playfield column (0-31)
          let THFB_pfColumn = playerX[THFB_playerIndex]
          let THFB_pfColumn = THFB_pfColumn - ScreenInsetX
          let THFB_pfColumn = THFB_pfColumn / 4
          rem Convert player Y position to playfield row (0-7)
          let THFB_pfRow = playerY[THFB_playerIndex]
          let THFB_pfRow = THFB_pfRow / 8
          rem Check if player hit a wall (playfield pixel is set)
          if pfread(THFB_pfColumn, THFB_pfRow) then THFB_HitWall
          rem No wall collision, transition to fallen
          let THFB_animationAction = ActionFallen
          let temp2 = THFB_animationAction
          rem tail call
          goto SetPlayerAnimation
THFB_HitWall
          rem Hit wall, transition to idle
          let THFB_animationAction = ActionIdle
          let temp2 = THFB_animationAction
          rem tail call
          goto SetPlayerAnimation

          rem ==========================================================
          rem ATTACK TRANSITION HANDLING
          rem ==========================================================
          rem Character-specific attack transitions based on patterns
          
HandleAttackTransition
          dim HAT2_currentAction = temp1
          rem Branch by attack phase
          let HAT2_currentAction = currentAnimationSeq[currentPlayer]
          
          if HAT2_currentAction = ActionAttackWindup then goto HandleWindupEnd
          if HAT2_currentAction = ActionAttackExecute then goto HandleExecuteEnd
          if HAT2_currentAction = ActionAttackRecovery then goto HandleRecoveryEnd
          return
          
HandleWindupEnd
          dim HWE_characterType = temp1
          dim HWE_animationAction = temp2
          rem Character-specific windup→next transitions
          rem Most characters skip windup (go directly to Execute)
          rem Get character ID
          let HWE_characterType = playerChar[currentPlayer]
          let temp1 = HWE_characterType
          if temp1 < 8 then on temp1 goto Char0_Windup, Char1_Windup, Char2_Windup, Char3_Windup, Char4_Windup, Char5_Windup, Char6_Windup, Char7_Windup
          if temp1 >= 8 then temp1 = temp1 - 8
          if temp1 >= 8 then on temp1 goto Char8_Windup, Char9_Windup, Char10_Windup, Char11_Windup, Char12_Windup, Char13_Windup, Char14_Windup, Char15_Windup
          
Char0_Windup
          rem Bernie: no windup used, Execute only
          return
Char1_Windup
          dim C1W_animationAction = temp2
          rem Curler: Windup → Recovery
          rem NOTE: Curling stone missile spawning handled by CurlerAttack
          rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          let C1W_animationAction = ActionAttackRecovery
          let temp2 = C1W_animationAction
          rem tail call
          goto SetPlayerAnimation
Char2_Windup
          rem Dragon of Storms: Execute only
          return
Char3_Windup
          rem Zoe Ryen: Execute only
          return
Char4_Windup
          dim C4W_animationAction = temp2
          rem Fat Tony: Windup → Execute
          let C4W_animationAction = ActionAttackExecute
          let temp2 = C4W_animationAction
          rem tail call
          goto SetPlayerAnimation
Char5_Windup
          dim C5W_animationAction = temp2
          rem Megax: Windup → Execute
          let C5W_animationAction = ActionAttackExecute
          let temp2 = C5W_animationAction
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
          dim C9W_animationAction = temp2
          rem Nefertem: Windup → Execute
          let C9W_animationAction = ActionAttackExecute
          let temp2 = C9W_animationAction
          rem tail call
          goto SetPlayerAnimation
Char10_Windup
          rem Ninjish Guy: Execute only
          return
Char11_Windup
          dim C11W_animationAction = temp2
          rem Pork Chop: Windup → Execute
          let C11W_animationAction = ActionAttackExecute
          let temp2 = C11W_animationAction
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
          dim HEE_characterType = temp1
          dim HEE_animationAction = temp2
          rem Character-specific execute→next transitions
          let HEE_characterType = playerChar[currentPlayer]
          let temp1 = HEE_characterType
          if temp1 < 8 then on temp1 goto Char0_Execute, Char1_Execute, Char2_Execute, Char3_Execute, Char4_Execute, Char5_Execute, Char6_Execute, Char7_Execute
          if temp1 >= 8 then temp1 = temp1 - 8
          if temp1 >= 8 then on temp1 goto Char8_Execute, Char9_Execute, Char10_Execute, Char11_Execute, Char12_Execute, Char13_Execute, Char14_Execute, Char15_Execute
          
Char0_Execute
          dim C0E_animationAction = temp2
          rem Bernie: Execute → Idle
          let C0E_animationAction = ActionIdle
          let temp2 = C0E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char1_Execute
          rem Curler: no Execute used
          return
Char2_Execute
          dim C2E_animationAction = temp2
          rem Dragon of Storms: Execute → Idle
          let C2E_animationAction = ActionIdle
          let temp2 = C2E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char3_Execute
          dim C3E_animationAction = temp2
          rem Zoe Ryen: Execute → Idle
          let C3E_animationAction = ActionIdle
          let temp2 = C3E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char4_Execute
          dim C4E_animationAction = temp2
          rem Fat Tony: Execute → Recovery
          rem NOTE: Laser bullet missile spawning handled by FatTonyAttack
          rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          let C4E_animationAction = ActionAttackRecovery
          let temp2 = C4E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char5_Execute
          dim C5E_animationAction = temp2
          rem Megax: Execute → Idle (fire breath during Execute)
          let C5E_animationAction = ActionIdle
          let temp2 = C5E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char6_Execute
          dim C6E_animationAction = temp2
          dim C6E_playerIndex = temp1
          rem Harpy: Execute → Idle
          rem Clear dive flag and stop diagonal movement when attack
          rem   completes
          rem Also apply upward wing flap momentum after swoop attack
          let C6E_playerIndex = currentPlayer
          rem Clear dive flag (bit 4 in characterStateFlags)
          rem Fix RMW: Read from _R, modify, write to _W
          let C6E_stateFlags = characterStateFlags_R[C6E_playerIndex] & 239
          let characterStateFlags_W[C6E_playerIndex] = C6E_stateFlags
          rem Clear bit 4 (239 = 0xEF = ~0x10)
          rem Stop horizontal velocity (zero X velocity)
          let playerVelocityX[C6E_playerIndex] = 0
          let playerVelocityX_lo[C6E_playerIndex] = 0
          rem Apply upward wing flap momentum after swoop attack
          rem   (equivalent to HarpyJump)
          rem Same as normal flap: -2 pixels/frame upward (254 in two’s
          rem   complement)
          let playerVelocityY[C6E_playerIndex] = 254
          rem -2 in 8-bit two’s complement: 256 - 2 = 254
          let playerVelocityY_lo[C6E_playerIndex] = 0
          rem Keep jumping flag set to allow vertical movement
          rem playerState[C6E_playerIndex] bit 2 (jumping) already set
          rem   from attack, keep it
          rem Transition to Idle
          let C6E_animationAction = ActionIdle
          let temp2 = C6E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char7_Execute
          dim C7E_animationAction = temp2
          rem Knight Guy: Execute → Idle (sword during Execute)
          let C7E_animationAction = ActionIdle
          let temp2 = C7E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char8_Execute
          dim C8E_animationAction = temp2
          rem Frooty: Execute → Idle
          let C8E_animationAction = ActionIdle
          let temp2 = C8E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char9_Execute
          dim C9E_animationAction = temp2
          rem Nefertem: Execute → Idle
          let C9E_animationAction = ActionIdle
          let temp2 = C9E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char10_Execute
          dim C10E_animationAction = temp2
          rem Ninjish Guy: Execute → Idle
          let C10E_animationAction = ActionIdle
          let temp2 = C10E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char11_Execute
          dim C11E_animationAction = temp2
          rem Pork Chop: Execute → Recovery
          let C11E_animationAction = ActionAttackRecovery
          let temp2 = C11E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char12_Execute
          dim C12E_animationAction = temp2
          rem Radish Goblin: Execute → Idle
          let C12E_animationAction = ActionIdle
          let temp2 = C12E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char13_Execute
          dim C13E_animationAction = temp2
          rem Robo Tito: Execute → Idle
          let C13E_animationAction = ActionIdle
          let temp2 = C13E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char14_Execute
          dim C14E_animationAction = temp2
          rem Ursulo: Execute → Idle
          let C14E_animationAction = ActionIdle
          let temp2 = C14E_animationAction
          rem tail call
          goto SetPlayerAnimation
Char15_Execute
          dim C15E_animationAction = temp2
          rem Shamone: Execute → Idle
          let C15E_animationAction = ActionIdle
          let temp2 = C15E_animationAction
          rem tail call
          goto SetPlayerAnimation

HandleRecoveryEnd
          dim HRE_animationAction = temp2
          rem All characters: Recovery → Idle
          let HRE_animationAction = ActionIdle
          let temp2 = HRE_animationAction
          rem tail call
          goto SetPlayerAnimation
