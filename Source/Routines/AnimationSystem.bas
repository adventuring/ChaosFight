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
          let currentPlayer = 0 : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 1
          let currentPlayer = 1 : rem Player index (0-3)
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
          let currentPlayer = 2 : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 3
          let currentPlayer = 3 : rem Player index (0-3)
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
          rem Skip if player is eliminated - use BitMask array lookup
          let temp4 = BitMask[currentPlayer]
          if playersEliminated_R & temp4 then return
          
          rem Increment this sprite 10fps animation counter (NOT global
          rem   frame counter)
          rem SCRAM read-modify-write: Read from r077, modify, write to
          rem w077
          let temp4 = animationCounter_R[currentPlayer] + 1
          let animationCounter_W[currentPlayer] = temp4
          
          rem Check if time to advance animation frame (every
          if temp4 >= AnimationFrameDelay then goto AdvanceFrame : rem   AnimationFrameDelay frames)
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
          rem   w081
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
          rem w081
          let temp4 = currentAnimationFrame_R[currentPlayer]
          let temp4 = 1 + temp4
          let currentAnimationFrame_W[currentPlayer] = temp4
          
          rem Check if we have completed the current action (8 frames
          rem   per action)
          if temp4 >= FramesPerSequence then goto HandleFrame7Transition : rem Use temp variable from increment (temp4)
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
          let temp2 = currentAnimationFrame_R[currentPlayer] : rem   where dim entries concatenate with subsequent constants
          let temp3 = currentAnimationSeq[currentPlayer]
          let temp4 = currentPlayer
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
          rem Constraints: None
          if temp2 >= AnimationSequenceCount then return
          
          let currentAnimationSeq[currentPlayer] = temp2
          let currentAnimationFrame_W[currentPlayer] = 0 : rem SCRAM write: Write to w081
          rem Start at first frame
          let animationCounter_W[currentPlayer] = 0 : rem SCRAM write: Write to w077
          rem Reset animation counter
          
          rem Update character sprite immediately
          rem Frame is from this sprite 10fps counter, action from
          rem   currentAnimationSeq
          rem Set up parameters for LoadPlayerSprite
          let temp2 = 0 : rem SCRAM read: Read from r081 (we just wrote 0, so this is 0)
          let temp3 = currentAnimationSeq[currentPlayer]
          let temp4 = currentPlayer
          gosub LoadPlayerSprite bank10
          
          return

GetCurrentAnimationFrame
          rem Return the current animation frame for currentPlayer.
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        currentAnimationFrame_R[] (SCRAM) = stored frame values
          rem Output: temp2 = current animation frame (0-7)
          rem Mutates: temp2 (set to current frame)
          rem Constraints: None
          let temp2 = currentAnimationFrame_R[currentPlayer] : rem SCRAM read: Read from r081
          return

GetCurrentAnimationAction
          rem Get current animation action for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem currentAnimationSeq[currentPlayer] = current action (read
          rem   from array)
          rem
          rem OUTPUT: temp2 = current animation action (0-15)
          rem EFFECTS: None (read-only query)
          let temp2 = currentAnimationSeq[currentPlayer]
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
          rem (ActionIdle)
          let currentPlayer = 0 : rem Initialize all players to idle animation
          let temp2 = ActionIdle
          gosub SetPlayerAnimation
          let currentPlayer = 1
          gosub SetPlayerAnimation
          let currentPlayer = 2
          gosub SetPlayerAnimation
          let currentPlayer = 3
          goto SetPlayerAnimation : rem tail call

SetWalkingAnimation
          rem
          rem Animation Sequence Management
          rem Set walking animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionWalking state
          let temp2 = ActionWalking
          goto SetPlayerAnimation : rem tail call

SetIdleAnimation
          rem Set idle animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionIdle state
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

SetAttackAnimation
          rem Set attack animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem
          rem EFFECTS: Changes player animation to ActionAttackWindup
          rem state
          let temp2 = ActionAttackWindup
          goto SetPlayerAnimation : rem tail call

SetHitAnimation
          rem Set hit animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionHit state
          let temp2 = ActionHit
          goto SetPlayerAnimation : rem tail call

SetJumpingAnimation
          rem Set jumping animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionJumping state
          let temp2 = ActionJumping
          goto SetPlayerAnimation : rem tail call

SetFallingAnimation
          rem Set falling animation for a player
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: None
          rem EFFECTS: Changes player animation to ActionFalling state
          let temp2 = ActionFalling
          goto SetPlayerAnimation : rem tail call

IsPlayerWalking
          rem
          rem Animation State Queries
          rem Check if player is in walking animation
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if walking, 0 if not
          rem EFFECTS: None (read-only query)
          let temp2 = 0 : rem Use temp2 directly to avoid batariBASIC alias resolution issues
          if ActionWalking = currentAnimationSeq[currentPlayer] then let temp2 = 1
          return

IsPlayerAttacking
          rem Check if player is in attack animation
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if attacking, 0 if not
          rem EFFECTS: None (read-only query)
          let temp2 = 0
          if ActionAttackWindup > currentAnimationSeq[currentPlayer] then goto NotAttacking
          if ActionAttackRecovery < currentAnimationSeq[currentPlayer] then goto NotAttacking
          let temp2 = 1
NotAttacking
          return

IsPlayerHit
          rem Check if player is in hit animation
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if hit, 0 if not
          rem EFFECTS: None (read-only query)
          let temp2 = 0
          if ActionHit = currentAnimationSeq[currentPlayer] then let temp2 = 1
          return

IsPlayerJumping
          rem Check if player is in jumping animation based on sequence
          rem NOTE: Returns 1 only when the current animation sequence is
          rem       ActionJumping or ActionFalling. Permanent flyers such
          rem       as Frooty or Dragon of Storms remain in idle/hover
          rem       animations and will report 0 even while aloft. Use
          rem       PlayerStateBitJumping if you need to detect physical
          rem       airborne status instead of animation state.
          rem
          rem INPUT: currentPlayer = player index (0-3)
          rem
          rem OUTPUT: temp2 = 1 if jumping, 0 if not
          rem EFFECTS: None (read-only query)
          let temp2 = 0 : rem Use temp2 directly to avoid batariBASIC alias resolution issues
          if ActionJumping = currentAnimationSeq[currentPlayer] then let temp2 = 1
          if ActionFalling = currentAnimationSeq[currentPlayer] then let temp2 = 1
          return

HandleAnimationTransition
          rem
          rem Animation Transition Handling
          rem Handle frame 7 completion and transition to next action
          rem
          rem Input: currentPlayer = player index (0-3)
          rem Uses: currentAnimationSeq[currentPlayer] to determine
          rem transition
          let temp1 = currentAnimationSeq[currentPlayer] : rem Get current action
          if ActionAttackRecovery < temp1 then goto TransitionLoopAnimation : rem Guard against invalid action values
          
          on temp1 goto TransitionLoopAnimation TransitionLoopAnimation TransitionLoopAnimation TransitionLoopAnimation TransitionLoopAnimation TransitionToIdle TransitionHandleFallBack TransitionToFallen TransitionLoopAnimation TransitionToIdle TransitionHandleJump TransitionLoopAnimation TransitionToIdle HandleAttackTransition HandleAttackTransition HandleAttackTransition

TransitionLoopAnimation
          let currentAnimationFrame_W[currentPlayer] = 0 : rem SCRAM write: Write to w081
          return

TransitionToIdle
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

TransitionToFallen
          let temp2 = ActionFallen
          goto SetPlayerAnimation : rem tail call

TransitionHandleJump
          rem Stay on frame 7 until Y velocity goes negative
          rem Check if player is falling (positive Y velocity =
          rem downward)
          if 0 < playerVelocityY[currentPlayer] then TransitionHandleJump_TransitionToFalling
          let temp2 = ActionJumping : rem Still ascending (negative or zero Y velocity), stay in jump
          goto SetPlayerAnimation : rem tail call
TransitionHandleJump_TransitionToFalling
          let temp2 = ActionFalling : rem Falling (positive Y velocity), transition to falling
          goto SetPlayerAnimation : rem tail call

TransitionHandleFallBack
          rem Check wall collision using pfread
          rem If hit wall: goto idle, else: goto fallen
          let temp5 = playerX[currentPlayer] : rem Convert player X position to playfield column (0-31)
          let temp5 = temp5 - ScreenInsetX
          let temp5 = temp5 / 4
          let temp6 = playerY[currentPlayer] : rem Convert player Y position to playfield row (0-7)
          let temp6 = temp6 / 8
          if pfread(temp5, temp6) then TransitionHandleFallBack_HitWall : rem Check if player hit a wall (playfield pixel is set)
          let temp2 = ActionFallen : rem No wall collision, transition to fallen
          goto SetPlayerAnimation : rem tail call
TransitionHandleFallBack_HitWall
          let temp2 = ActionIdle : rem Hit wall, transition to idle
          goto SetPlayerAnimation : rem tail call

          rem
          rem Attack Transition Handling
          rem Character-specific attack transitions based on patterns
          
HandleAttackTransition
          let temp1 = currentAnimationSeq[currentPlayer] : rem Branch by attack phase
          
          if ActionAttackWindup = temp1 then goto HandleWindupEnd
          if ActionAttackExecute = temp1 then goto HandleExecuteEnd
          if ActionAttackRecovery = temp1 then goto HandleRecoveryEnd
          return
          
HandleWindupEnd
          rem Character-specific windup→next transitions
          rem Most characters skip windup (go directly to Execute)
          let temp1 = playerCharacter[currentPlayer] : rem Get character ID
          rem Dispatch to character-specific windup handler (0-31)
          rem MethHound (31) uses Character15_Windup (Shamone) handler
          if temp1 < 8 then goto WindupDispatchBank0
          let temp1 = temp1 - 8
          if temp1 < 8 then goto WindupDispatchBank1
          let temp1 = temp1 - 8
          if temp1 < 8 then goto WindupDispatchBank2
          let temp1 = temp1 - 8
          goto WindupDispatchBank3

WindupDispatchBank0
          if temp1 = 0 then goto Character0_Windup
          if temp1 = 1 then goto Character1_Windup
          if temp1 = 2 then goto Character2_Windup
          if temp1 = 3 then goto Character3_Windup
          if temp1 = 4 then goto Character4_Windup
          if temp1 = 5 then goto Character5_Windup
          if temp1 = 6 then goto Character6_Windup
          if temp1 = 7 then goto Character7_Windup
          goto DoneWindupDispatch

WindupDispatchBank1
          if temp1 = 0 then goto Character8_Windup
          if temp1 = 1 then goto Character9_Windup
          if temp1 = 2 then goto Character10_Windup
          if temp1 = 3 then goto Character11_Windup
          if temp1 = 4 then goto Character12_Windup
          if temp1 = 5 then goto Character13_Windup
          if temp1 = 6 then goto Character14_Windup
          if temp1 = 7 then goto Character15_Windup
          goto DoneWindupDispatch

WindupDispatchBank2
          if temp1 = 0 then goto Character16_Windup
          if temp1 = 1 then goto Character17_Windup
          if temp1 = 2 then goto Character18_Windup
          if temp1 = 3 then goto Character19_Windup
          if temp1 = 4 then goto Character20_Windup
          if temp1 = 5 then goto Character21_Windup
          if temp1 = 6 then goto Character22_Windup
          if temp1 = 7 then goto Character23_Windup
          goto DoneWindupDispatch

WindupDispatchBank3
          if temp1 = 0 then goto Character24_Windup
          if temp1 = 1 then goto Character25_Windup
          if temp1 = 2 then goto Character26_Windup
          if temp1 = 3 then goto Character27_Windup
          if temp1 = 4 then goto Character28_Windup
          if temp1 = 5 then goto Character29_Windup
          if temp1 = 6 then goto Character30_Windup
          if temp1 = 7 then goto Character15_Windup
          goto DoneWindupDispatch
DoneWindupDispatch
          
Character0_Windup
          rem Bernie: no windup used, Execute only
          return
Character1_Windup
          rem Curler: Windup → Recovery
          rem NOTE: Curling stone missile spawning handled by
          rem CurlerAttack
          let temp2 = ActionAttackRecovery : rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          goto SetPlayerAnimation : rem tail call
Character2_Windup
          rem Dragon of Storms: Execute only
          return
Character3_Windup
          rem Zoe Ryen: Execute only
          return
Character4_Windup
          let temp2 = ActionAttackExecute : rem Fat Tony: Windup → Execute
          goto SetPlayerAnimation : rem tail call
Character5_Windup
          let temp2 = ActionAttackExecute : rem Megax: Windup → Execute
          goto SetPlayerAnimation : rem tail call
Character6_Windup
          rem Harpy: Execute only
          return
Character7_Windup
          rem Knight Guy: Execute only
          return
Character8_Windup
          rem Frooty: Execute only
          return
Character9_Windup
          let temp2 = ActionAttackExecute : rem Nefertem: Windup → Execute
          goto SetPlayerAnimation : rem tail call
Character10_Windup
          rem Ninjish Guy: Execute only
          return
Character11_Windup
          let temp2 = ActionAttackExecute : rem Pork Chop: Windup → Execute
          goto SetPlayerAnimation : rem tail call
Character12_Windup
          rem Radish Goblin: Execute only
          return
Character13_Windup
          rem Robo Tito: Execute only
          return
Character14_Windup
          rem Ursulo: Execute only
          return
Character15_Windup
          rem Shamone: Execute only
          return

HandleExecuteEnd
          let temp1 = playerCharacter[currentPlayer] : rem Character-specific execute→next transitions
          rem Dispatch to character-specific execute handler (0-31)
          rem MethHound (31) uses Character15_Execute (Shamone) handler
          if temp1 < 8 then goto ExecuteDispatchBank0
          let temp1 = temp1 - 8
          if temp1 < 8 then goto ExecuteDispatchBank1
          let temp1 = temp1 - 8
          if temp1 < 8 then goto ExecuteDispatchBank2
          let temp1 = temp1 - 8
          goto ExecuteDispatchBank3

ExecuteDispatchBank0
          if temp1 = 0 then goto Character0_Execute
          if temp1 = 1 then goto Character1_Execute
          if temp1 = 2 then goto Character2_Execute
          if temp1 = 3 then goto Character3_Execute
          if temp1 = 4 then goto Character4_Execute
          if temp1 = 5 then goto Character5_Execute
          if temp1 = 6 then goto Character6_Execute
          if temp1 = 7 then goto Character7_Execute
          goto DoneExecuteDispatch

ExecuteDispatchBank1
          if temp1 = 0 then goto Character8_Execute
          if temp1 = 1 then goto Character9_Execute
          if temp1 = 2 then goto Character10_Execute
          if temp1 = 3 then goto Character11_Execute
          if temp1 = 4 then goto Character12_Execute
          if temp1 = 5 then goto Character13_Execute
          if temp1 = 6 then goto Character14_Execute
          if temp1 = 7 then goto Character15_Execute
          goto DoneExecuteDispatch

ExecuteDispatchBank2
          if temp1 = 0 then goto Character16_Execute
          if temp1 = 1 then goto Character17_Execute
          if temp1 = 2 then goto Character18_Execute
          if temp1 = 3 then goto Character19_Execute
          if temp1 = 4 then goto Character20_Execute
          if temp1 = 5 then goto Character21_Execute
          if temp1 = 6 then goto Character22_Execute
          if temp1 = 7 then goto Character23_Execute
          goto DoneExecuteDispatch

ExecuteDispatchBank3
          if temp1 = 0 then goto Character24_Execute
          if temp1 = 1 then goto Character25_Execute
          if temp1 = 2 then goto Character26_Execute
          if temp1 = 3 then goto Character27_Execute
          if temp1 = 4 then goto Character28_Execute
          if temp1 = 5 then goto Character29_Execute
          if temp1 = 6 then goto Character30_Execute
          if temp1 = 7 then goto Character15_Execute
          goto DoneExecuteDispatch
DoneExecuteDispatch
          
Character0_Execute
          let temp2 = ActionIdle : rem Bernie: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character1_Execute
          rem Curler: no Execute used
          return
Character2_Execute
          let temp2 = ActionIdle : rem Dragon of Storms: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character3_Execute
          let temp2 = ActionIdle : rem Zoe Ryen: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character4_Execute
          rem Fat Tony: Execute → Recovery
          rem   FatTonyAttack
          rem NOTE: Laser bullet missile spawning handled by
          let temp2 = ActionAttackRecovery : rem   (calls PerformRangedAttack) in CharacterAttacks.bas
          goto SetPlayerAnimation : rem tail call
Character5_Execute
          let temp2 = ActionIdle : rem Megax: Execute → Idle (fire breath during Execute)
          goto SetPlayerAnimation : rem tail call
Character6_Execute
          rem Harpy: Execute → Idle
          rem Clear dive flag and stop diagonal movement when attack
          rem   completes
          let temp1 = currentPlayer : rem Also apply upward wing flap momentum after swoop attack
          rem Clear dive flag (bit 4 in characterStateFlags)
          let C6E_stateFlags = 239 & characterStateFlags_R[temp1] : rem Fix RMW: Read from _R, modify, write to _W
          let characterStateFlags_W[temp1] = C6E_stateFlags
          rem Clear bit 4 (239 = 0xEF = ~0x10)
          let playerVelocityX[temp1] = 0 : rem Stop horizontal velocity (zero X velocity)
          let playerVelocityXL[temp1] = 0
          rem Apply upward wing flap momentum after swoop attack
          rem   (equivalent to HarpyJump)
          rem Same as normal flap: -2 pixels/frame upward (254 in twos
          let playerVelocityY[temp1] = 254 : rem   complement)
          rem -2 in 8-bit twos complement: 256 - 2 = 254
          let playerVelocityYL[temp1] = 0
          rem Keep jumping flag set to allow vertical movement
          rem playerState[temp1] bit 2 (jumping) already set
          rem   from attack, keep it
          let temp2 = ActionIdle : rem Transition to Idle
          goto SetPlayerAnimation : rem tail call
Character7_Execute
          let temp2 = ActionIdle : rem Knight Guy: Execute → Idle (sword during Execute)
          goto SetPlayerAnimation : rem tail call
Character8_Execute
          let temp2 = ActionIdle : rem Frooty: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character9_Execute
          let temp2 = ActionIdle : rem Nefertem: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character10_Execute
          let temp2 = ActionIdle : rem Ninjish Guy: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character11_Execute
          let temp2 = ActionAttackRecovery : rem Pork Chop: Execute → Recovery
          goto SetPlayerAnimation : rem tail call
Character12_Execute
          let temp2 = ActionIdle : rem Radish Goblin: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character13_Execute
          let temp2 = ActionIdle : rem Robo Tito: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character14_Execute
          let temp2 = ActionIdle : rem Ursulo: Execute → Idle
          goto SetPlayerAnimation : rem tail call
Character15_Execute
          let temp2 = ActionIdle : rem Shamone: Execute → Idle
          goto SetPlayerAnimation : rem tail call

          rem
          rem PLACEHOLDER CHARACTER ANIMATION HANDLERS (16-30)
          rem These characters are not yet implemented and use standard
          rem   behaviors (Execute → Idle, no Windup)

          rem Windup routines return immediately; execute handlers drop back to Idle.

Character16_Windup
          return

Character17_Windup
          return

Character18_Windup
          return

Character19_Windup
          return

Character20_Windup
          return

Character21_Windup
          return

Character22_Windup
          return

Character23_Windup
          return

Character24_Windup
          return

Character25_Windup
          return

Character26_Windup
          return

Character27_Windup
          return

Character28_Windup
          return

Character29_Windup
          return

Character30_Windup
          return

          rem Execute handlers fall back to Idle until placeholder characters are implemented.

Character16_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character17_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character18_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character19_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character20_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character21_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character22_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character23_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character24_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character25_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character26_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character27_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character28_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character29_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

Character30_Execute
          let temp2 = ActionIdle
          goto SetPlayerAnimation : rem tail call

HandleRecoveryEnd
          let temp2 = ActionIdle : rem All characters: Recovery → Idle
          goto SetPlayerAnimation : rem tail call
