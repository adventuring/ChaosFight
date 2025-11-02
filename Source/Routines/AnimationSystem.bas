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
          rem Skip eliminated players to avoid unnecessary processing
          let temp1 = 0  : rem Player index (0-3)
          if PlayersEliminated & 1 then goto AnimationSkipPlayer0
          gosub UpdatePlayerAnimation
          rem Player 1
AnimationSkipPlayer0
          let temp1 = 1  : rem Player index (0-3)
          if PlayersEliminated & 2 then goto AnimationSkipPlayer1
          gosub UpdatePlayerAnimation
          rem Player 2
AnimationSkipPlayer1
          if ControllerStatus & SetQuadtariDetected then goto AnimationUpdatePlayer3
          goto AnimationSkipPlayer3
AnimationUpdatePlayer3
          let temp1 = 2  : rem Player index (0-3)
          if PlayersEliminated & 4 then goto AnimationSkipPlayer2
          gosub UpdatePlayerAnimation
          rem Player 3
AnimationSkipPlayer2
          let temp1 = 3  : rem Player index (0-3)
          if PlayersEliminated & 8 then goto AnimationSkipPlayer3
          gosub UpdatePlayerAnimation
          rem Player 4
AnimationSkipPlayer3
          return

          rem Update animation for a specific player
          rem Input: temp1 = player index (0-3)
          rem Uses per-sprite 10fps counter (AnimationCounter), NOT global frame counter
UpdatePlayerAnimation
          rem Skip if player is eliminated
          rem PlayersEliminated is authoritative - set when health reaches 0
          if temp1 = 0 && PlayersEliminated & 1 then return
          if temp1 = 1 && PlayersEliminated & 2 then return
          if temp1 = 2 && PlayersEliminated & 4 then return
          if temp1 = 3 && PlayersEliminated & 8 then return
          
          rem Increment this sprite 10fps animation counter (NOT global frame counter)
          let AnimationCounter[temp1] = AnimationCounter[temp1] + 1
          
          rem Check if time to advance animation frame (every AnimationFrameDelay frames)
          if AnimationCounter[temp1] >= AnimationFrameDelay then goto AdvanceFrame
          goto SkipAdvance
AdvanceFrame
          let AnimationCounter[temp1] = 0
          gosub AdvanceAnimationFrame
SkipAdvance
        return

          rem Advance to next frame in current animation action
          rem Input: temp1 = player index (0-3)
          rem Frame counter is per-sprite 10fps counter, NOT global frame counter
AdvanceAnimationFrame
          rem Advance to next frame in current animation action
          rem Frame is from sprite 10fps counter (CurrentAnimationFrame), not global frame
          let CurrentAnimationFrame[temp1] = CurrentAnimationFrame[temp1] + 1
          
          rem Check if we have completed the current action (8 frames per action)
          if CurrentAnimationFrame[temp1] >= FramesPerSequence then goto LoopAnimation
          goto UpdateSprite
LoopAnimation
          let CurrentAnimationFrame[temp1] = 0
          rem Loop back to start of action
UpdateSprite
          rem Update character sprite with new animation frame
          rem Frame is from this sprite 10fps counter (CurrentAnimationFrame), not global frame counter
          let temp2 = CurrentAnimationFrame[temp1] 
          rem temp2 = Animation frame (0-7) from sprite 10fps counter
          let temp3 = CurrentAnimationSeq[temp1]
          rem temp3 = Animation action (0-15)
          let temp4 = temp1
          rem temp4 = Player number (0-3)
          gosub bank10 LoadPlayerSprite
          
          return

          rem Set animation action for a player
          rem Input: temp1 = player index (0-3), temp2 = animation action (0-15)
SetPlayerAnimation
          rem Validate animation action (byte-safe)
          if temp2 >= AnimationSequenceCount then return
          
          rem Set new animation action
          let CurrentAnimationSeq[temp1] = temp2
          rem temp1 = Player index (0-3), temp2 = Animation action (0-15)
          let CurrentAnimationFrame[temp1] = 0
          rem Start at first frame
          let AnimationCounter[temp1] = 0
          rem Reset animation counter
          
          rem Update character sprite immediately
          rem Frame is from this sprite 10fps counter, action from CurrentAnimationSeq
          let temp2 = CurrentAnimationFrame[temp1]
          rem temp2 = Animation frame (0-7) from sprite 10fps counter
          let temp3 = CurrentAnimationSeq[temp1]
          rem temp3 = Animation action (0-15)
          let temp4 = temp1
          rem temp4 = Player number (0-3)
          gosub bank10 LoadPlayerSprite
          
          return

          rem Get current animation frame for a player
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = current animation frame (0-7)
GetCurrentAnimationFrame
          let temp2 = CurrentAnimationFrame[temp1]
          rem temp1 = Player index (0-3), temp2 = Current animation frame (0-7)
          return

          rem Get current animation action for a player
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = current animation action (0-15)
GetCurrentAnimationAction
          let temp2 = CurrentAnimationSeq[temp1]
          rem temp1 = Player index (0-3), temp2 = Current animation action (0-15)
          return
          
          rem Legacy alias for backward compatibility
GetCurrentAnimationSequence
          gosub GetCurrentAnimationAction
          return

          rem Initialize animation system for all players
          rem Called at game start to set up initial animation states
InitializeAnimationSystem
          rem Initialize all players to idle animation
          let temp1 = 0  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          let temp1 = 1  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          let temp1 = 2  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          let temp1 = 3  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ANIMATION SEQUENCE MANAGEMENT
          rem =================================================================

          rem Set walking animation for a player
          rem Input: temp1 = player index (0-3)
SetWalkingAnimation
          let temp2 = AnimWalking
          gosub SetPlayerAnimation
          return

          rem Set idle animation for a player
          rem Input: temp1 = player index (0-3)
SetIdleAnimation
          let temp2 = AnimIdle
          gosub SetPlayerAnimation
          return

          rem Set attack animation for a player
          rem Input: temp1 = player index (0-3)
SetAttackAnimation
          let temp2 = AnimAttackWindup
          gosub SetPlayerAnimation
          return

          rem Set hit animation for a player
          rem Input: temp1 = player index (0-3)
SetHitAnimation
          let temp2 = AnimHit
          gosub SetPlayerAnimation
          return

          rem Set jumping animation for a player
          rem Input: temp1 = player index (0-3)
SetJumpingAnimation
          let temp2 = AnimJumping
          gosub SetPlayerAnimation
          return

          rem Set falling animation for a player
          rem Input: temp1 = player index (0-3)
SetFallingAnimation
          let temp2 = AnimFalling
          gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ANIMATION STATE QUERIES
          rem =================================================================

          rem Check if player is in walking animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if walking, 0 if not
IsPlayerWalking
          let temp2 = 0
          if CurrentAnimationSeq[temp1] = AnimWalking then temp2 = 1
          return

          rem Check if player is in attack animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if attacking, 0 if not
IsPlayerAttacking
          let temp2 = 0
          if CurrentAnimationSeq[temp1] < AnimAttackWindup then goto NotAttacking
          if CurrentAnimationSeq[temp1] > AnimAttackRecovery then goto NotAttacking
          let temp2 = 1
NotAttacking
          return

          rem Check if player is in hit animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if hit, 0 if not
IsPlayerHit
          let temp2 = 0
          if CurrentAnimationSeq[temp1] = AnimHit then temp2 = 1
          return

          rem Check if player is in jumping animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if jumping, 0 if not
IsPlayerJumping
          let temp2 = 0
          if CurrentAnimationSeq[temp1] = AnimJumping then goto IsJumping
          if CurrentAnimationSeq[temp1] = AnimFalling then goto IsJumping
          goto NotJumping
IsJumping
          let temp2 = 1
NotJumping
          return