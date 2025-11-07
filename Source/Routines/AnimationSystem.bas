UpdateCharacterAnimations
          rem ChaosFight - Source/Routines/AnimationSystem.bas
          rem
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem 10fps character animation system with platform-specific
          rem   timing
          rem Animation System Routines
          rem Update character animations for all players
          rem Called every frame to manage 10fps animation timing
          rem Update character animations for all players (10fps timing)
          rem
          rem Input: controllerStatus (global) = controller detection
          rem state
          rem        currentPlayer (global) = player index (set inline)
          rem        animationCounter_R[] (global SCRAM array) =
          rem        per-sprite animation counters
          rem        currentAnimationFrame_R[] (global SCRAM array) =
          rem        current animation frames
          rem        currentAnimationSeq[] (global array) = current
          rem        animation sequences
          rem        playersEliminated_R (global SCRAM) = eliminated
          rem        players bitmask
          rem
          rem Output: animationCounter_W[] updated,
          rem currentAnimationFrame_W[] updated,
          rem         player sprites updated via UpdatePlayerAnimation
          rem
          rem Mutates: currentPlayer (set to 0-3), animationCounter_W[],
          rem currentAnimationFrame_W[],
          rem         player sprite pointers (via UpdatePlayerAnimation)
          rem
          rem Called Routines: UpdatePlayerAnimation - accesses
          rem currentPlayer, animationCounter_R/W,
          rem   currentAnimationFrame_R/W, currentAnimationSeq,
          rem   playersEliminated_R,
          rem   LoadPlayerSprite (bank10)
          rem
          rem Constraints: Must be colocated with
          rem AnimationUpdatePlayer3, AnimationSkipPlayer3 (called via
          rem goto)
          rem              Called every frame from game loop
          rem Update animation for each active player
          let currentPlayer = 0  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 1
          let currentPlayer = 1  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          if controllerStatus & SetQuadtariDetected then goto AnimationUpdatePlayer3 : rem Player 2
          goto AnimationSkipPlayer3
AnimationUpdatePlayer3
          rem Update Player 3 and 4 animations (4-player mode only)
          rem
          rem Input: currentPlayer (global) = player index (set inline)
          rem
          rem Output: Player 3 and 4 animations updated
          rem
          rem Mutates: currentPlayer (set to 2, then 3),
          rem animationCounter_W[], currentAnimationFrame_W[],
          rem         player sprite pointers (via UpdatePlayerAnimation)
          rem
          rem Called Routines: UpdatePlayerAnimation - accesses
          rem currentPlayer, animationCounter_R/W,
          rem   currentAnimationFrame_R/W, currentAnimationSeq,
          rem   playersEliminated_R,
          rem   LoadPlayerSprite (bank10)
          rem
          rem Constraints: Must be colocated with
          rem UpdateCharacterAnimations, AnimationSkipPlayer3
          let currentPlayer = 2  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 3
          let currentPlayer = 3  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
AnimationSkipPlayer3
          rem Player 4
          return
UpdatePlayerAnimation
          rem Skip Player 3/4 animations (2-player mode only, label
          rem only)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with
          rem UpdateCharacterAnimations
          rem Update animation for a specific player
          rem Uses per-sprite 10fps counter (animationCounter), NOT
          rem   global frame counter
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem animationCounter[currentPlayer] = current frame timer
          rem   (per-sprite 10fps counter)
          rem currentAnimationSeq[currentPlayer] = current animation
          rem   action/sequence (0-15)
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Increments per-sprite animation counter, advances
          rem   animation frame when counter reaches threshold,
          rem updates sprite graphics via LoadPlayerSprite, handles
          rem   frame 7 transition logic
          rem Update animation for a specific player (10fps timing)
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        animationCounter_R[] (global SCRAM array) =
          rem        per-sprite animation counters
          rem        currentAnimationFrame_R[] (global SCRAM array) =
          rem        current animation frames
          rem        currentAnimationSeq[] (global array) = current
          rem        animation sequences
          rem        playersEliminated_R (global SCRAM) = eliminated
          rem        players bitmask
          rem        BitMask[] (global array) = bitmask lookup table
          rem        AnimationFrameDelay (constant) = frames per
          rem        animation step
          rem        FramesPerSequence (constant) = frames per animation
          rem        sequence
          rem
          rem Output: animationCounter_W[] updated,
          rem currentAnimationFrame_W[] updated,
          rem         player sprite updated via UpdateSprite
          rem
          rem Mutates: animationCounter_W[] (incremented, reset to 0
          rem when threshold reached),
          rem         currentAnimationFrame_W[] (incremented, reset to 0
          rem         when sequence complete),
          rem         temp4 (used for calculations), player sprite
          rem         pointers (via UpdateSprite)
          rem
          rem Called Routines: HandleAnimationTransition - handles frame
          rem 7 completion,
          rem   UpdateSprite - loads player sprite
          rem
          rem Constraints: Must be colocated with AdvanceFrame,
          rem DoneAdvance, HandleFrame7Transition,
          rem              UpdateSprite (all called via goto)
          dim UPA_eliminatedMask = temp4 : rem Skip if player is eliminated - use BitMask array lookup
          let UPA_eliminatedMask = BitMask[currentPlayer]
          if playersEliminated_R & UPA_eliminatedMask then return
          
          rem Increment this sprite 10fps animation counter (NOT global
          rem   frame counter)
          rem SCRAM read-modify-write: Read from r077, modify, write to
          dim UPA_animCounterRead = temp4 : rem   w077
          let UPA_animCounterRead = animationCounter_R[currentPlayer] + 1
          let animationCounter_W[currentPlayer] = UPA_animCounterRead
          
          rem Check if time to advance animation frame (every
          if UPA_animCounterRead >= AnimationFrameDelay then goto AdvanceFrame : rem   AnimationFrameDelay frames)
          goto DoneAdvance
AdvanceFrame
          rem Advance animation frame (counter reached threshold)
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
          let animationCounter_W[currentPlayer] = 0 : rem              UpdateSprite
          rem Inline AdvanceAnimationFrame
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter
          rem   (currentAnimationFrame), not global frame
          rem SCRAM read-modify-write: Read from r081, modify, write to
          dim UPA_animFrameRead = temp4 : rem   w081
          let UPA_animFrameRead = currentAnimationFrame_R[currentPlayer]
          let UPA_animFrameRead = 1 + UPA_animFrameRead
          let currentAnimationFrame_W[currentPlayer] = UPA_animFrameRead
          
          rem Check if we have completed the current action (8 frames
          rem   per action)
          rem Use temp variable from previous increment
          if UPA_animFrameRead >= FramesPerSequence then goto HandleFrame7Transition : rem   (UPA_animFrameRead)
          goto UpdateSprite
DoneAdvance
          return
AdvanceAnimationFrame
          rem Animation counter not at threshold (label only, no
          rem execution)
          rem
          rem Input: None (label only, no execution)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with UpdatePlayerAnimation
          rem Advance to next frame in current animation action
          rem Frame counter is per-sprite 10fps counter, NOT global
          rem   frame counter
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem currentAnimationSeq[currentPlayer] = current animation
          rem   action/sequence (0-15)
          rem currentAnimationFrame[currentPlayer] = current frame
          rem   within sequence (0-7)
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Increments currentAnimationFrame[currentPlayer],
          rem   checks for frame 7 completion,
          rem triggers HandleAnimationTransition when 8 frames completed
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter
          rem   (currentAnimationFrame), not global frame
          rem SCRAM read-modify-write: Read from r081, modify, write to
          dim AAF_animFrameRead = temp4 : rem   w081
          let AAF_animFrameRead = currentAnimationFrame_R[currentPlayer]
          let AAF_animFrameRead = 1 + AAF_animFrameRead
          let currentAnimationFrame_W[currentPlayer] = AAF_animFrameRead
          
          rem Check if we have completed the current action (8 frames
          rem   per action)
          if AAF_animFrameRead >= FramesPerSequence then goto HandleFrame7Transition : rem Use temp variable from increment (AAF_animFrameRead)
          goto UpdateSprite
          
HandleFrame7Transition
          rem Frame 7 completed, handle action-specific transitions
          rem
          rem Input: currentPlayer (global) = player index (from
          rem UpdatePlayerAnimation/AdvanceAnimationFrame)
          rem
          rem Output: Animation transition handled, dispatches to
          rem UpdateSprite
          rem
          rem Mutates: Animation state (via HandleAnimationTransition)
          rem
          rem Called Routines: HandleAnimationTransition - handles
          rem animation state transitions,
          rem   UpdateSprite - loads player sprite
          rem
          rem Constraints: Must be colocated with UpdatePlayerAnimation,
          rem AdvanceAnimationFrame, UpdateSprite
          gosub HandleAnimationTransition
          goto UpdateSprite
          
UpdateSprite
          rem Update character sprite with current animation frame and
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
          rem Called Routines: LoadPlayerSprite (bank10) - loads
          rem character sprite graphics
          rem
          rem Constraints: Must be colocated with UpdatePlayerAnimation,
          rem AdvanceAnimationFrame, HandleFrame7Transition
          dim US_animationFrame = temp2
          dim US_animationAction = temp3
          dim US_playerNumber = temp4
          const US_SEPARATOR = 0
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
          rem NOTE: US_SEPARATOR const added to work around compiler bug
          let US_animationFrame = currentAnimationFrame_R[currentPlayer] : rem   where dim entries concatenate with subsequent constants
          let US_animationAction = currentAnimationSeq[currentPlayer]
          let US_playerNumber = currentPlayer
          gosub LoadPlayerSprite bank10
          
          return

SetPlayerAnimation
          rem Set animation action for a player
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
          rem Called Routines: LoadPlayerSprite (bank10) - loads
          rem character sprite graphics
          dim SPA_animationAction = temp2 : rem Constraints: None
          dim SPA_animationFrame = temp2
          dim SPA_animationSeq = temp3
          dim SPA_playerNumber = temp4
          if SPA_animationAction >= AnimationSequenceCount then return
          
          let currentAnimationSeq[currentPlayer] = SPA_animationAction
          let currentAnimationFrame_W[currentPlayer] = 0 : rem SCRAM write: Write to w081
          rem Start at first frame
          let animationCounter_W[currentPlayer] = 0 : rem SCRAM write: Write to w077
          rem Reset animation counter
          
          rem Update character sprite immediately
          rem Frame is from this sprite 10fps counter, action from
          rem   currentAnimationSeq
          rem Set up parameters for LoadPlayerSprite
          let SPA_animationFrame = 0 : rem SCRAM read: Read from r081 (we just wrote 0, so this is 0)
          let SPA_animationSeq = currentAnimationSeq[currentPlayer]
          let SPA_playerNumber = currentPlayer
          let temp2 = SPA_animationFrame
          let temp3 = SPA_animationSeq
          let temp4 = SPA_playerNumber
          gosub LoadPlayerSprite bank10
          
          return

GetCurrentAnimationFrame
          rem Get current animation frame for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = current animation frame (0-7)
          rem
          rem EFFECTS: None (read-only query)
          rem Get current animation frame for a player (read-only query)
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        currentAnimationFrame_R[] (global SCRAM array) =
          rem        current animation frames
          rem
          rem Output: temp2 = current animation frame (0-7)
          rem
          rem Mutates: temp2 (set to current frame)
          rem
          rem Called Routines: None
          dim GCAF_currentFrame = temp2 : rem Constraints: None
          let GCAF_currentFrame = currentAnimationFrame_R[currentPlayer] : rem SCRAM read: Read from r081
          let temp2 = GCAF_currentFrame
          return

GetCurrentAnimationAction
          rem Get current animation action for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem currentAnimationSeq[currentPlayer] = current action (read
          rem   from array)
          rem
          rem OUTPUT: temp2 = current animation action (0-15)
          dim GCAA_currentAction = temp2 : rem EFFECTS: None (read-only query)
          let GCAA_currentAction = currentAnimationSeq[currentPlayer]
          let temp2 = GCAA_currentAction
          return

InitializeAnimationSystem
          rem Initialize animation system for all players
          rem Called at game start to set up initial animation states
          rem
          rem INPUT: None
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Sets all players (0-3) to idle animation state
          dim IAS_animationAction = temp2 : rem (ActionIdle)
          let currentPlayer = 0 : rem Initialize all players to idle animation
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
          goto SetPlayerAnimation : rem tail call

SetWalkingAnimation
          rem
          rem Animation Sequence Management
          rem Set walking animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          dim SWA_animationAction = temp2 : rem EFFECTS: Changes player animation to ActionWalking state
          let SWA_animationAction = ActionWalking
          let temp2 = SWA_animationAction
          goto SetPlayerAnimation : rem tail call

SetIdleAnimation
          rem Set idle animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          dim SIA_animationAction = temp2 : rem EFFECTS: Changes player animation to ActionIdle state
          let SIA_animationAction = ActionIdle
          let temp2 = SIA_animationAction
          goto SetPlayerAnimation : rem tail call

SetAttackAnimation
          rem Set attack animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Changes player animation to ActionAttackWindup
          dim SAA_animationAction = temp2 : rem state
          let SAA_animationAction = ActionAttackWindup
          let temp2 = SAA_animationAction
          goto SetPlayerAnimation : rem tail call

SetHitAnimation
          rem Set hit animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          dim SHA_animationAction = temp2 : rem EFFECTS: Changes player animation to ActionHit state
          let SHA_animationAction = ActionHit
          let temp2 = SHA_animationAction
          goto SetPlayerAnimation : rem tail call

SetJumpingAnimation
          rem Set jumping animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          dim SJA_animationAction = temp2 : rem EFFECTS: Changes player animation to ActionJumping state
          let SJA_animationAction = ActionJumping
          let temp2 = SJA_animationAction
          goto SetPlayerAnimation : rem tail call

SetFallingAnimation
          rem Set falling animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          dim SFA_animationAction = temp2 : rem EFFECTS: Changes player animation to ActionFalling state
          let SFA_animationAction = ActionFalling
          let temp2 = SFA_animationAction
          goto SetPlayerAnimation : rem tail call

IsPlayerWalking
          rem
          rem Animation State Queries
          rem Check if player is in walking animation
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if walking, 0 if not
          dim IPW_isWalking = temp2 : rem EFFECTS: None (read-only query)
          let temp2 = 0 : rem Use temp2 directly to avoid batariBASIC alias resolution issues
          if ActionWalking = currentAnimationSeq[currentPlayer] then let temp2 = 1
          return

IsPlayerAttacking
          rem Check if player is in attack animation
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if attacking, 0 if not
          dim IPA_isAttacking = temp2 : rem EFFECTS: None (read-only query)
          let IPA_isAttacking = 0
          if ActionAttackWindup > currentAnimationSeq[currentPlayer] then goto NotAttacking
          if ActionAttackRecovery < currentAnimationSeq[currentPlayer] then goto NotAttacking
          let IPA_isAttacking = 1
NotAttacking
          let temp2 = IPA_isAttacking
          return

IsPlayerHit
          rem Check if player is in hit animation
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if hit, 0 if not
          dim IPH_isHit = temp2 : rem EFFECTS: None (read-only query)
          let IPH_isHit = 0
          if ActionHit = currentAnimationSeq[currentPlayer] then let IPH_isHit = 1
          let temp2 = IPH_isHit
          return

IsPlayerJumping
          rem Check if player is in jumping animation
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if jumping, 0 if not
          dim IPJ_isJumping = temp2 : rem EFFECTS: None (read-only query)
          let temp2 = 0 : rem Use temp2 directly to avoid batariBASIC alias resolution issues
          if ActionJumping = currentAnimationSeq[currentPlayer] then goto IsJumping
          if ActionFalling = currentAnimationSeq[currentPlayer] then goto IsJumping
          goto NotJumping
IsJumping
          let temp2 = 1
NotJumping
          return

HandleAnimationTransition
          rem
          rem Animation Transition Handling
          rem Handle frame 7 completion and transition to next action
          rem
          rem Input: currentPlayer = player index (0-3)
          rem Uses: currentAnimationSeq[currentPlayer] to determine
          dim HAT_currentAction = temp1 : rem transition
          dim HAT_animationAction = temp2
          let HAT_currentAction = currentAnimationSeq[currentPlayer] : rem Get current action
          
          if ActionIdle = HAT_currentAction then goto TransitionLoopAnimation : rem Branch by action type
          if ActionGuarding = HAT_currentAction then goto TransitionLoopAnimation
          if ActionFalling = HAT_currentAction then goto TransitionLoopAnimation
          
          if ActionJumping = HAT_currentAction then goto TransitionHandleJump : rem Special: Jumping stays on frame 7 until falling
          
          if ActionLanding = HAT_currentAction then goto TransitionToIdle : rem Transitions to Idle
          if ActionHit = HAT_currentAction then goto TransitionToIdle
          if ActionRecovering = HAT_currentAction then goto TransitionToIdle
          
          if ActionFallBack = HAT_currentAction then goto TransitionHandleFallBack : rem Special: FallBack checks wall collision
          
          if ActionFallen = HAT_currentAction then goto TransitionLoopAnimation : rem Fallen waits for stick input (handled elsewhere)
          if ActionFallDown = HAT_currentAction then goto TransitionToFallen
          
          rem Attack transitions (delegate to character-specific
          if ActionAttackWindup <= HAT_currentAction && ActionAttackRecovery >= HAT_currentAction then goto HandleAttackTransition : rem   handler)
          
          goto TransitionLoopAnimation : rem Default: loop

TransitionLoopAnimation
          let currentAnimationFrame_W[currentPlayer] = 0 : rem SCRAM write: Write to w081
          return

TransitionToIdle
          dim TTI_animationAction = temp2
          let TTI_animationAction = ActionIdle
          let temp2 = TTI_animationAction
          goto SetPlayerAnimation : rem tail call

TransitionToFallen
          dim TTF_animationAction = temp2
          let TTF_animationAction = ActionFallen
          let temp2 = TTF_animationAction
          goto SetPlayerAnimation : rem tail call

TransitionHandleJump
          dim THJ_animationAction = temp2
          rem Stay on frame 7 until Y velocity goes negative
          rem Check if player is falling (positive Y velocity =
          rem downward)
          if 0 < playerVelocityY[currentPlayer] then TransitionHandleJump_TransitionToFalling
          let THJ_animationAction = ActionJumping : rem Still ascending (negative or zero Y velocity), stay in jump
          let temp2 = THJ_animationAction
          goto SetPlayerAnimation : rem tail call
TransitionHandleJump_TransitionToFalling
          let THJ_animationAction = ActionFalling : rem Falling (positive Y velocity), transition to falling
          let temp2 = THJ_animationAction
          goto SetPlayerAnimation : rem tail call

TransitionHandleFallBack
          dim THFB_animationAction = temp2
          dim THFB_pfColumn = temp5
          dim THFB_pfRow = temp6
          rem Check wall collision using pfread
          rem If hit wall: goto idle, else: goto fallen
          let THFB_pfColumn = playerX[currentPlayer] : rem Convert player X position to playfield column (0-31)
          let THFB_pfColumn = THFB_pfColumn - ScreenInsetX
          let THFB_pfColumn = THFB_pfColumn / 4
          let THFB_pfRow = playerY[currentPlayer] : rem Convert player Y position to playfield row (0-7)
          let THFB_pfRow = THFB_pfRow / 8
          if pfread(THFB_pfColumn, THFB_pfRow) then TransitionHandleFallBack_HitWall : rem Check if player hit a wall (playfield pixel is set)
          let THFB_animationAction = ActionFallen : rem No wall collision, transition to fallen
          let temp2 = THFB_animationAction
          goto SetPlayerAnimation : rem tail call
TransitionHandleFallBack_HitWall
          let THFB_animationAction = ActionIdle : rem Hit wall, transition to idle
          let temp2 = THFB_animationAction
          goto SetPlayerAnimation : rem tail call

          rem
          rem Attack Transition Handling
          rem Character-specific attack transitions based on patterns
          
HandleAttackTransition
          dim HAT2_currentAction = temp1
          let HAT2_currentAction = currentAnimationSeq[currentPlayer] : rem Branch by attack phase
          
          if ActionAttackWindup = HAT2_currentAction then goto HandleWindupEnd
          if ActionAttackExecute = HAT2_currentAction then goto HandleExecuteEnd
          if ActionAttackRecovery = HAT2_currentAction then goto HandleRecoveryEnd
          return
          
HandleWindupEnd
          dim HWE_characterType = temp1
          dim HWE_animationAction = temp2
          rem Character-specific windup→next transitions
          rem Most characters skip windup (go directly to Execute)
          let HWE_characterType = playerChar[currentPlayer] : rem Get character ID
          rem Dispatch to character-specific windup handler (0-31)
          let temp1 = HWE_characterType : rem MethHound (31) uses Char15_Windup (Shamone) handler
          if 8 > temp1 then on temp1 goto Char0_Windup, Char1_Windup, Char2_Windup, Char3_Windup, Char4_Windup, Char5_Windup, Char6_Windup, Char7_Windup
          if 8 > temp1 then goto DoneWindupDispatch
          let temp1 = temp1 - 8
          if 8 > temp1 then on temp1 goto Char8_Windup, Char9_Windup, Char10_Windup, Char11_Windup, Char12_Windup, Char13_Windup, Char14_Windup, Char15_Windup
          if 8 > temp1 then goto DoneWindupDispatch
          let temp1 = temp1 - 8
          if 8 > temp1 then on temp1 goto Char16_Windup, Char17_Windup, Char18_Windup, Char19_Windup, Char20_Windup, Char21_Windup, Char22_Windup, Char23_Windup
          if 8 > temp1 then goto DoneWindupDispatch
          let temp1 = temp1 - 8
          if temp1 = 0 then goto Char24_Windup
          if temp1 = 1 then goto Char25_Windup
          if temp1 = 2 then goto Char26_Windup
          if temp1 = 3 then goto Char27_Windup
          if temp1 = 4 then goto Char28_Windup
          if temp1 = 5 then goto Char29_Windup
          if temp1 = 6 then goto Char30_Windup
          if temp1 = 7 then goto Char15_Windup
DoneWindupDispatch
          
Char0_Windup
          rem Bernie: no windup used, Execute only
          return
Char1_Windup
          dim C1W_animationAction = temp2
          rem Curler: Windup → Recovery
          rem NOTE: Curling stone missile spawning handled by
          rem CurlerAttack
          let C1W_animationAction = ActionAttackRecovery : rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          let temp2 = C1W_animationAction
          goto SetPlayerAnimation : rem tail call
Char2_Windup
          rem Dragon of Storms: Execute only
          return
Char3_Windup
          rem Zoe Ryen: Execute only
          return
Char4_Windup
          dim C4W_animationAction = temp2
          let C4W_animationAction = ActionAttackExecute : rem Fat Tony: Windup → Execute
          let temp2 = C4W_animationAction
          goto SetPlayerAnimation : rem tail call
Char5_Windup
          dim C5W_animationAction = temp2
          let C5W_animationAction = ActionAttackExecute : rem Megax: Windup → Execute
          let temp2 = C5W_animationAction
          goto SetPlayerAnimation : rem tail call
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
          let C9W_animationAction = ActionAttackExecute : rem Nefertem: Windup → Execute
          let temp2 = C9W_animationAction
          goto SetPlayerAnimation : rem tail call
Char10_Windup
          rem Ninjish Guy: Execute only
          return
Char11_Windup
          dim C11W_animationAction = temp2
          let C11W_animationAction = ActionAttackExecute : rem Pork Chop: Windup → Execute
          let temp2 = C11W_animationAction
          goto SetPlayerAnimation : rem tail call
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
          let HEE_characterType = playerChar[currentPlayer] : rem Character-specific execute→next transitions
          rem Dispatch to character-specific execute handler (0-31)
          let temp1 = HEE_characterType : rem MethHound (31) uses Char15_Execute (Shamone) handler
          if 8 > temp1 then on temp1 goto Char0_Execute, Char1_Execute, Char2_Execute, Char3_Execute, Char4_Execute, Char5_Execute, Char6_Execute, Char7_Execute
          if 8 > temp1 then goto DoneExecuteDispatch
          let temp1 = temp1 - 8
          if 8 > temp1 then on temp1 goto Char8_Execute, Char9_Execute, Char10_Execute, Char11_Execute, Char12_Execute, Char13_Execute, Char14_Execute, Char15_Execute
          if 8 > temp1 then goto DoneExecuteDispatch
          let temp1 = temp1 - 8
          if 8 > temp1 then on temp1 goto Char16_Execute, Char17_Execute, Char18_Execute, Char19_Execute, Char20_Execute, Char21_Execute, Char22_Execute, Char23_Execute
          if 8 > temp1 then goto DoneExecuteDispatch
          let temp1 = temp1 - 8
          if temp1 = 0 then goto Char24_Execute
          if temp1 = 1 then goto Char25_Execute
          if temp1 = 2 then goto Char26_Execute
          if temp1 = 3 then goto Char27_Execute
          if temp1 = 4 then goto Char28_Execute
          if temp1 = 5 then goto Char29_Execute
          if temp1 = 6 then goto Char30_Execute
          if temp1 = 7 then goto Char15_Execute
DoneExecuteDispatch
          
Char0_Execute
          dim C0E_animationAction = temp2
          let C0E_animationAction = ActionIdle : rem Bernie: Execute → Idle
          let temp2 = C0E_animationAction
          goto SetPlayerAnimation : rem tail call
Char1_Execute
          rem Curler: no Execute used
          return
Char2_Execute
          dim C2E_animationAction = temp2
          let C2E_animationAction = ActionIdle : rem Dragon of Storms: Execute → Idle
          let temp2 = C2E_animationAction
          goto SetPlayerAnimation : rem tail call
Char3_Execute
          dim C3E_animationAction = temp2
          let C3E_animationAction = ActionIdle : rem Zoe Ryen: Execute → Idle
          let temp2 = C3E_animationAction
          goto SetPlayerAnimation : rem tail call
Char4_Execute
          dim C4E_animationAction = temp2
          rem Fat Tony: Execute → Recovery
          rem   FatTonyAttack
          rem NOTE: Laser bullet missile spawning handled by
          let C4E_animationAction = ActionAttackRecovery : rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          let temp2 = C4E_animationAction
          goto SetPlayerAnimation : rem tail call
Char5_Execute
          dim C5E_animationAction = temp2
          let C5E_animationAction = ActionIdle : rem Megax: Execute → Idle (fire breath during Execute)
          let temp2 = C5E_animationAction
          goto SetPlayerAnimation : rem tail call
Char6_Execute
          dim C6E_animationAction = temp2
          dim C6E_playerIndex = temp1
          rem Harpy: Execute → Idle
          rem Clear dive flag and stop diagonal movement when attack
          rem   completes
          let C6E_playerIndex = currentPlayer : rem Also apply upward wing flap momentum after swoop attack
          rem Clear dive flag (bit 4 in characterStateFlags)
          let C6E_stateFlags = 239 & characterStateFlags_R[C6E_playerIndex] : rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[C6E_playerIndex] = C6E_stateFlags
          rem Clear bit 4 (239 = 0xEF = ~0x10)
          let playerVelocityX[C6E_playerIndex] = 0 : rem Stop horizontal velocity (zero X velocity)
          let playerVelocityXL[C6E_playerIndex] = 0
          rem Apply upward wing flap momentum after swoop attack
          rem   (equivalent to HarpyJump)
          rem Same as normal flap: -2 pixels/frame upward (254 in twos
          let playerVelocityY[C6E_playerIndex] = 254 : rem   complement)
          rem -2 in 8-bit twos complement: 256 - 2 = 254
          let playerVelocityYL[C6E_playerIndex] = 0
          rem Keep jumping flag set to allow vertical movement
          rem playerState[C6E_playerIndex] bit 2 (jumping) already set
          rem   from attack, keep it
          let C6E_animationAction = ActionIdle : rem Transition to Idle
          let temp2 = C6E_animationAction
          goto SetPlayerAnimation : rem tail call
Char7_Execute
          dim C7E_animationAction = temp2
          let C7E_animationAction = ActionIdle : rem Knight Guy: Execute → Idle (sword during Execute)
          let temp2 = C7E_animationAction
          goto SetPlayerAnimation : rem tail call
Char8_Execute
          dim C8E_animationAction = temp2
          let C8E_animationAction = ActionIdle : rem Frooty: Execute → Idle
          let temp2 = C8E_animationAction
          goto SetPlayerAnimation : rem tail call
Char9_Execute
          dim C9E_animationAction = temp2
          let C9E_animationAction = ActionIdle : rem Nefertem: Execute → Idle
          let temp2 = C9E_animationAction
          goto SetPlayerAnimation : rem tail call
Char10_Execute
          dim C10E_animationAction = temp2
          let C10E_animationAction = ActionIdle : rem Ninjish Guy: Execute → Idle
          let temp2 = C10E_animationAction
          goto SetPlayerAnimation : rem tail call
Char11_Execute
          dim C11E_animationAction = temp2
          let C11E_animationAction = ActionAttackRecovery : rem Pork Chop: Execute → Recovery
          let temp2 = C11E_animationAction
          goto SetPlayerAnimation : rem tail call
Char12_Execute
          dim C12E_animationAction = temp2
          let C12E_animationAction = ActionIdle : rem Radish Goblin: Execute → Idle
          let temp2 = C12E_animationAction
          goto SetPlayerAnimation : rem tail call
Char13_Execute
          dim C13E_animationAction = temp2
          let C13E_animationAction = ActionIdle : rem Robo Tito: Execute → Idle
          let temp2 = C13E_animationAction
          goto SetPlayerAnimation : rem tail call
Char14_Execute
          dim C14E_animationAction = temp2
          let C14E_animationAction = ActionIdle : rem Ursulo: Execute → Idle
          let temp2 = C14E_animationAction
          goto SetPlayerAnimation : rem tail call
Char15_Execute
          dim C15E_animationAction = temp2
          let C15E_animationAction = ActionIdle : rem Shamone: Execute → Idle
          let temp2 = C15E_animationAction
          goto SetPlayerAnimation : rem tail call

          rem
          rem PLACEHOLDER CHARACTER ANIMATION HANDLERS (16-30)
          rem These characters are not yet implemented and use standard
          rem   behaviors (Execute → Idle, no Windup)

Char16_Windup
          rem Placeholder: no windup used, Execute only
          return

Char17_Windup
          rem Placeholder: no windup used, Execute only
          return

Char18_Windup
          rem Placeholder: no windup used, Execute only
          return

Char19_Windup
          rem Placeholder: no windup used, Execute only
          return

Char20_Windup
          rem Placeholder: no windup used, Execute only
          return

Char21_Windup
          rem Placeholder: no windup used, Execute only
          return

Char22_Windup
          rem Placeholder: no windup used, Execute only
          return

Char23_Windup
          rem Placeholder: no windup used, Execute only
          return

Char24_Windup
          rem Placeholder: no windup used, Execute only
          return

Char25_Windup
          rem Placeholder: no windup used, Execute only
          return

Char26_Windup
          rem Placeholder: no windup used, Execute only
          return

Char27_Windup
          rem Placeholder: no windup used, Execute only
          return

Char28_Windup
          rem Placeholder: no windup used, Execute only
          return

Char29_Windup
          rem Placeholder: no windup used, Execute only
          return

Char30_Windup
          rem Placeholder: no windup used, Execute only
          return

Char16_Execute
          dim C16E_animationAction = temp2
          let C16E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C16E_animationAction
          goto SetPlayerAnimation : rem tail call

Char17_Execute
          dim C17E_animationAction = temp2
          let C17E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C17E_animationAction
          goto SetPlayerAnimation : rem tail call

Char18_Execute
          dim C18E_animationAction = temp2
          let C18E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C18E_animationAction
          goto SetPlayerAnimation : rem tail call

Char19_Execute
          dim C19E_animationAction = temp2
          let C19E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C19E_animationAction
          goto SetPlayerAnimation : rem tail call

Char20_Execute
          dim C20E_animationAction = temp2
          let C20E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C20E_animationAction
          goto SetPlayerAnimation : rem tail call

Char21_Execute
          dim C21E_animationAction = temp2
          let C21E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C21E_animationAction
          goto SetPlayerAnimation : rem tail call

Char22_Execute
          dim C22E_animationAction = temp2
          let C22E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C22E_animationAction
          goto SetPlayerAnimation : rem tail call

Char23_Execute
          dim C23E_animationAction = temp2
          let C23E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C23E_animationAction
          goto SetPlayerAnimation : rem tail call

Char24_Execute
          dim C24E_animationAction = temp2
          let C24E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C24E_animationAction
          goto SetPlayerAnimation : rem tail call

Char25_Execute
          dim C25E_animationAction = temp2
          let C25E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C25E_animationAction
          goto SetPlayerAnimation : rem tail call

Char26_Execute
          dim C26E_animationAction = temp2
          let C26E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C26E_animationAction
          goto SetPlayerAnimation : rem tail call

Char27_Execute
          dim C27E_animationAction = temp2
          let C27E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C27E_animationAction
          goto SetPlayerAnimation : rem tail call

Char28_Execute
          dim C28E_animationAction = temp2
          let C28E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C28E_animationAction
          goto SetPlayerAnimation : rem tail call

Char29_Execute
          dim C29E_animationAction = temp2
          let C29E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C29E_animationAction
          goto SetPlayerAnimation : rem tail call

Char30_Execute
          dim C30E_animationAction = temp2
          let C30E_animationAction = ActionIdle : rem Placeholder: Execute → Idle
          let temp2 = C30E_animationAction
          goto SetPlayerAnimation : rem tail call

HandleRecoveryEnd
          dim HRE_animationAction = temp2
          let HRE_animationAction = ActionIdle : rem All characters: Recovery → Idle
          let temp2 = HRE_animationAction
          goto SetPlayerAnimation : rem tail call
