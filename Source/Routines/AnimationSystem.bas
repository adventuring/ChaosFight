          rem ChaosFight - Source/Routines/AnimationSystem.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem 10fps character animation system with platform-specific timing

          rem =================================================================
          rem ANIMATION SYSTEM ROUTINES
          rem =================================================================

          rem Update character animations for all players
          rem Called every frame to manage 10fps animation timing
UpdateCharacterAnimations
          rem Update animation for each active player
          currentPlayer = 0  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 1
          currentPlayer = 1  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 2
          if controllerStatus & SetQuadtariDetected then goto AnimationUpdatePlayer3
          goto AnimationSkipPlayer3
AnimationUpdatePlayer3
          currentPlayer = 2  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 3
          currentPlayer = 3  : rem Player index (0-3)
          gosub UpdatePlayerAnimation
          rem Player 4
AnimationSkipPlayer3
          return

          rem Update animation for a specific player
          rem Input: currentPlayer = player index (0-3)
          rem Uses per-sprite 10fps counter (animationCounter), NOT global frame counter
UpdatePlayerAnimation
          rem Skip if player is eliminated
          if currentPlayer = 0 && playersEliminated & 1 then return
          if currentPlayer = 1 && playersEliminated & 2 then return
          if currentPlayer = 2 && playersEliminated & 4 then return
          if currentPlayer = 3 && playersEliminated & 8 then return
          if playerHealth[currentPlayer] = 0 then return
          
          rem Increment this sprite 10fps animation counter (NOT global frame counter)
          let animationCounter[currentPlayer] = animationCounter[currentPlayer] + 1
          
          rem Check if time to advance animation frame (every AnimationFrameDelay frames)
          if animationCounter[currentPlayer] >= AnimationFrameDelay then goto AdvanceFrame
          goto SkipAdvance
AdvanceFrame
          let animationCounter[currentPlayer] = 0
          gosub AdvanceAnimationFrame
SkipAdvance
        return

          rem Advance to next frame in current animation action
          rem Input: currentPlayer = player index (0-3)
          rem Frame counter is per-sprite 10fps counter, NOT global frame counter
AdvanceAnimationFrame
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter (currentAnimationFrame), not global frame
          let currentAnimationFrame[currentPlayer] = currentAnimationFrame[currentPlayer] + 1
          
          rem Check if we have completed the current action (8 frames per action)
          if currentAnimationFrame[currentPlayer] >= FramesPerSequence then goto HandleFrame7Transition
          goto UpdateSprite
          
HandleFrame7Transition
          rem Frame 7 completed, handle action-specific transitions
          gosub HandleAnimationTransition
          goto UpdateSprite
          
UpdateSprite
          rem Update character sprite with new animation frame
          rem Frame is from this sprite 10fps counter (currentAnimationFrame), not global frame counter
          temp2 = currentAnimationFrame[currentPlayer] 
          rem temp2 = Animation frame (0-7) from sprite 10fps counter
          temp3 = currentAnimationSeq[currentPlayer]
          rem temp3 = Animation action (0-15)
          temp4 = currentPlayer
          rem temp4 = Player number (0-3)
          gosub bank10 LoadPlayerSprite
          
          return

          rem Set animation action for a player
          rem Input: currentPlayer = player index (0-3), temp2 = animation action (0-15)
SetPlayerAnimation
          rem Validate animation action (byte-safe)
          if temp2 >= AnimationSequenceCount then return
          
          rem Set new animation action
          let currentAnimationSeq[currentPlayer] = temp2
          rem currentPlayer = Player index (0-3), temp2 = Animation action (0-15)
          let currentAnimationFrame[currentPlayer] = 0 
          rem Start at first frame
          let animationCounter[currentPlayer] = 0      
          rem Reset animation counter
          
          rem Update character sprite immediately
          rem Frame is from this sprite 10fps counter, action from currentAnimationSeq
          temp2 = currentAnimationFrame[currentPlayer]
          rem temp2 = Animation frame (0-7) from sprite 10fps counter
          temp3 = currentAnimationSeq[currentPlayer]
          rem temp3 = Animation action (0-15)
          temp4 = currentPlayer
          rem temp4 = Player number (0-3)
          gosub bank10 LoadPlayerSprite
          
          return

          rem Get current animation frame for a player
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = current animation frame (0-7)
GetCurrentAnimationFrame
          temp2 = currentAnimationFrame[currentPlayer]
          rem currentPlayer = Player index (0-3), temp2 = Current animation frame (0-7)
          return

          rem Get current animation action for a player
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = current animation action (0-15)
GetCurrentAnimationAction
          temp2 = currentAnimationSeq[currentPlayer]
          rem currentPlayer = Player index (0-3), temp2 = Current animation action (0-15)
          return
          
          rem Legacy alias for backward compatibility
GetCurrentAnimationSequence
          gosub GetCurrentAnimationAction
          return

          rem Initialize animation system for all players
          rem Called at game start to set up initial animation states
InitializeAnimationSystem
          rem Initialize all players to idle animation
          currentPlayer = 0  : temp2 = ActionIdle  : gosub SetPlayerAnimation
          currentPlayer = 1  : temp2 = ActionIdle  : gosub SetPlayerAnimation
          currentPlayer = 2  : temp2 = ActionIdle  : gosub SetPlayerAnimation
          currentPlayer = 3  : temp2 = ActionIdle  : gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ANIMATION SEQUENCE MANAGEMENT
          rem =================================================================

          rem Set walking animation for a player
          rem Input: currentPlayer = player index (0-3)
SetWalkingAnimation
          temp2 = ActionWalking
          gosub SetPlayerAnimation
          return

          rem Set idle animation for a player
          rem Input: currentPlayer = player index (0-3)
SetIdleAnimation
          temp2 = ActionIdle
          gosub SetPlayerAnimation
          return

          rem Set attack animation for a player
          rem Input: currentPlayer = player index (0-3)
SetAttackAnimation
          temp2 = ActionAttackWindup
          gosub SetPlayerAnimation
          return

          rem Set hit animation for a player
          rem Input: currentPlayer = player index (0-3)
SetHitAnimation
          temp2 = ActionHit
          gosub SetPlayerAnimation
          return

          rem Set jumping animation for a player
          rem Input: currentPlayer = player index (0-3)
SetJumpingAnimation
          temp2 = ActionJumping
          gosub SetPlayerAnimation
          return

          rem Set falling animation for a player
          rem Input: currentPlayer = player index (0-3)
SetFallingAnimation
          temp2 = ActionFalling
          gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ANIMATION STATE QUERIES
          rem =================================================================

          rem Check if player is in walking animation
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = 1 if walking, 0 if not
IsPlayerWalking
          temp2 = 0
          if currentAnimationSeq[currentPlayer] = ActionWalking then temp2 = 1
          return

          rem Check if player is in attack animation
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = 1 if attacking, 0 if not
IsPlayerAttacking
          temp2 = 0
          if currentAnimationSeq[currentPlayer] < ActionAttackWindup then goto NotAttacking
          if currentAnimationSeq[currentPlayer] > ActionAttackRecovery then goto NotAttacking
          temp2 = 1
NotAttacking
          return

          rem Check if player is in hit animation
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = 1 if hit, 0 if not
IsPlayerHit
          temp2 = 0
          if currentAnimationSeq[currentPlayer] = ActionHit then temp2 = 1
          return

          rem Check if player is in jumping animation
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = 1 if jumping, 0 if not
IsPlayerJumping
          temp2 = 0
          if currentAnimationSeq[currentPlayer] = ActionJumping then goto IsJumping
          if currentAnimationSeq[currentPlayer] = ActionFalling then goto IsJumping
          goto NotJumping
IsJumping
          temp2 = 1
NotJumping
          return

          rem =================================================================
          rem ANIMATION TRANSITION HANDLING
          rem =================================================================

          rem Handle frame 7 completion and transition to next action
          rem Input: currentPlayer = player index (0-3)
          rem Uses: currentAnimationSeq[currentPlayer] to determine transition
HandleAnimationTransition
          rem Get current action
          temp1 = currentAnimationSeq[currentPlayer]
          
          rem Branch by action type
          if temp1 = ActionIdle then goto TransitionLoopAnimation
          if temp1 = ActionGuarding then goto TransitionLoopAnimation
          if temp1 = ActionFalling then goto TransitionLoopAnimation
          
          rem Special: Jumping stays on frame 7 until falling
          if temp1 = ActionJumping then goto TransitionHandleJump
          
          rem Transitions to Idle
          if temp1 = ActionLanding then goto TransitionToIdle
          if temp1 = ActionHit then goto TransitionToIdle
          if temp1 = ActionRecovering then goto TransitionToIdle
          
          rem Special: FallBack checks wall collision
          if temp1 = ActionFallBack then goto TransitionHandleFallBack
          
          rem Fallen waits for stick input (handled elsewhere)
          if temp1 = ActionFallen then goto TransitionLoopAnimation
          if temp1 = ActionFallDown then goto TransitionToFallen
          
          rem Attack transitions (delegate to character-specific handler)
          if temp1 >= ActionAttackWindup && temp1 <= ActionAttackRecovery then goto HandleAttackTransition
          
          rem Default: loop
          goto TransitionLoopAnimation

TransitionLoopAnimation
          let currentAnimationFrame[currentPlayer] = 0
          return

TransitionToIdle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return

TransitionToFallen
          temp2 = ActionFallen : gosub SetPlayerAnimation
          return

TransitionHandleJump
          rem Stay on frame 7 until Y velocity goes negative
          rem TODO: Get playerVelocityY array access working
          rem For now, simple fallback to falling after delay
          temp2 = ActionFalling : gosub SetPlayerAnimation
          return

TransitionHandleFallBack
          rem Check wall collision
          rem If hit wall: goto idle, else: goto fallen
          rem TODO: implement wall collision check
          temp2 = ActionFallen : gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ATTACK TRANSITION HANDLING
          rem =================================================================
          rem Character-specific attack transitions based on patterns
          
HandleAttackTransition
          rem Branch by attack phase
          temp1 = currentAnimationSeq[currentPlayer]
          
          if temp1 = ActionAttackWindup then goto HandleWindupEnd
          if temp1 = ActionAttackExecute then goto HandleExecuteEnd
          if temp1 = ActionAttackRecovery then goto HandleRecoveryEnd
          return
          
HandleWindupEnd
          rem Character-specific windup→next transitions
          rem Most characters skip windup (go directly to Execute)
          rem Get character ID
          temp1 = playerChar[currentPlayer]
          on temp1 goto Char0_Windup, Char1_Windup, Char2_Windup, Char3_Windup, Char4_Windup, Char5_Windup, Char6_Windup, Char7_Windup, Char8_Windup, Char9_Windup, Char10_Windup, Char11_Windup, Char12_Windup, Char13_Windup, Char14_Windup, Char15_Windup
          
Char0_Windup
          rem Bernie: no windup used, Execute only
          return
Char1_Windup
          rem Curler: Windup → Recovery
          temp2 = ActionAttackRecovery : gosub SetPlayerAnimation
          rem TODO: Spawn curling stone missile at foot level
          return
Char2_Windup
          rem Dragon of Storms: Execute only
          return
Char3_Windup
          rem Zoe Ryen: Execute only
          return
Char4_Windup
          rem Fat Tony: Windup → Execute
          temp2 = ActionAttackExecute : gosub SetPlayerAnimation
          return
Char5_Windup
          rem Megax: Windup → Execute
          temp2 = ActionAttackExecute : gosub SetPlayerAnimation
          return
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
          rem Nefertem: Windup → Execute
          temp2 = ActionAttackExecute : gosub SetPlayerAnimation
          return
Char10_Windup
          rem Ninjish Guy: Execute only
          return
Char11_Windup
          rem Pork Chop: Windup → Execute
          temp2 = ActionAttackExecute : gosub SetPlayerAnimation
          return
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
          rem Character-specific execute→next transitions
          temp1 = playerChar[currentPlayer]
          on temp1 goto Char0_Execute, Char1_Execute, Char2_Execute, Char3_Execute, Char4_Execute, Char5_Execute, Char6_Execute, Char7_Execute, Char8_Execute, Char9_Execute, Char10_Execute, Char11_Execute, Char12_Execute, Char13_Execute, Char14_Execute, Char15_Execute
          
Char0_Execute
          rem Bernie: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char1_Execute
          rem Curler: no Execute used
          return
Char2_Execute
          rem Dragon of Storms: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char3_Execute
          rem Zoe Ryen: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char4_Execute
          rem Fat Tony: Execute → Recovery
          temp2 = ActionAttackRecovery : gosub SetPlayerAnimation
          rem TODO: Spawn laser bullet missile
          return
Char5_Execute
          rem Megax: Execute → Idle (fire breath during Execute)
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char6_Execute
          rem Harpy: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char7_Execute
          rem Knight Guy: Execute → Idle (sword during Execute)
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char8_Execute
          rem Frooty: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char9_Execute
          rem Nefertem: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char10_Execute
          rem Ninjish Guy: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char11_Execute
          rem Pork Chop: Execute → Recovery
          temp2 = ActionAttackRecovery : gosub SetPlayerAnimation
          return
Char12_Execute
          rem Radish Goblin: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char13_Execute
          rem Robo Tito: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char14_Execute
          rem Ursulo: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return
Char15_Execute
          rem Shamone: Execute → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return

HandleRecoveryEnd
          rem All characters: Recovery → Idle
          temp2 = ActionIdle : gosub SetPlayerAnimation
          return