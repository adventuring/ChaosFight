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
          if currentAnimationFrame[currentPlayer] >= FramesPerSequence then goto LoopAnimation
          goto UpdateSprite
LoopAnimation
          let currentAnimationFrame[currentPlayer] = 0 
          rem Loop back to start of action
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
          currentPlayer = 0  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          currentPlayer = 1  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          currentPlayer = 2  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          currentPlayer = 3  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ANIMATION SEQUENCE MANAGEMENT
          rem =================================================================

          rem Set walking animation for a player
          rem Input: currentPlayer = player index (0-3)
SetWalkingAnimation
          temp2 = AnimWalking
          gosub SetPlayerAnimation
          return

          rem Set idle animation for a player
          rem Input: currentPlayer = player index (0-3)
SetIdleAnimation
          temp2 = AnimIdle
          gosub SetPlayerAnimation
          return

          rem Set attack animation for a player
          rem Input: currentPlayer = player index (0-3)
SetAttackAnimation
          temp2 = AnimAttackWindup
          gosub SetPlayerAnimation
          return

          rem Set hit animation for a player
          rem Input: currentPlayer = player index (0-3)
SetHitAnimation
          temp2 = AnimHit
          gosub SetPlayerAnimation
          return

          rem Set jumping animation for a player
          rem Input: currentPlayer = player index (0-3)
SetJumpingAnimation
          temp2 = AnimJumping
          gosub SetPlayerAnimation
          return

          rem Set falling animation for a player
          rem Input: currentPlayer = player index (0-3)
SetFallingAnimation
          temp2 = AnimFalling
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
          if currentAnimationSeq[currentPlayer] = AnimWalking then temp2 = 1
          return

          rem Check if player is in attack animation
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = 1 if attacking, 0 if not
IsPlayerAttacking
          temp2 = 0
          if currentAnimationSeq[currentPlayer] < AnimAttackWindup then goto NotAttacking
          if currentAnimationSeq[currentPlayer] > AnimAttackRecovery then goto NotAttacking
          temp2 = 1
NotAttacking
          return

          rem Check if player is in hit animation
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = 1 if hit, 0 if not
IsPlayerHit
          temp2 = 0
          if currentAnimationSeq[currentPlayer] = AnimHit then temp2 = 1
          return

          rem Check if player is in jumping animation
          rem Input: currentPlayer = player index (0-3)
          rem Output: temp2 = 1 if jumping, 0 if not
IsPlayerJumping
          temp2 = 0
          if currentAnimationSeq[currentPlayer] = AnimJumping then goto IsJumping
          if currentAnimationSeq[currentPlayer] = AnimFalling then goto IsJumping
          goto NotJumping
IsJumping
          temp2 = 1
NotJumping
          return