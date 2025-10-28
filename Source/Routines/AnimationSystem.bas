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
          temp1 = 0  : rem Player index (0-3)
          gosub UpdatePlayerAnimation 
          rem Player 1
          temp1 = 1  : rem Player index (0-3)
          gosub UpdatePlayerAnimation 
          rem Player 2
          if ControllerStatus & SetQuadtariDetected then goto UpdatePlayer3
          goto SkipPlayer3
UpdatePlayer3
          temp1 = 2  : rem Player index (0-3)
          gosub UpdatePlayerAnimation 
          rem Player 3
          temp1 = 3  : rem Player index (0-3)
          gosub UpdatePlayerAnimation 
          rem Player 4
SkipPlayer3
          return

          rem Update animation for a specific player
          rem Input: temp1 = player index (0-3)
UpdatePlayerAnimation
          rem Skip if player is eliminated
          if PlayerHealth[temp1] = 0 then return
          
          rem Increment animation counter
          AnimationCounter[temp1] = AnimationCounter[temp1] + 1
          
          rem Check if time to advance animation frame
          if AnimationCounter[temp1] >= AnimationFrameDelay then goto AdvanceFrame
          goto SkipAdvance
AdvanceFrame
          AnimationCounter[temp1] = 0
          gosub AdvanceAnimationFrame
SkipAdvance
        return

          rem Advance to next frame in current animation sequence
          rem Input: temp1 = player index (0-3)
AdvanceAnimationFrame
          rem Advance to next frame in current animation sequence
          CurrentAnimationFrame[temp1] = CurrentAnimationFrame[temp1] + 1
          
          rem Check if we have completed the current sequence
          if CurrentAnimationFrame[temp1] >= FramesPerSequence then goto LoopAnimation
          goto UpdateSprite
LoopAnimation
          CurrentAnimationFrame[temp1] = 0 
          rem Loop back to start of sequence
UpdateSprite
          rem Update character sprite with new animation frame
          temp2 = CurrentAnimationFrame[temp1] 
          rem temp2 = Animation frame (0-7)
          temp3 = temp1 
          rem temp3 = Player number (0-3)
          gosub LoadPlayerSprite
          
          return

          rem Set animation sequence for a player
          rem Input: temp1 = player index (0-3), temp2 = animation sequence (0-15)
SetPlayerAnimation
          rem Validate animation sequence (byte-safe)
          if temp2 >= AnimationSequenceCount then return
          
          rem Set new animation sequence
          CurrentAnimationSeq[temp1] = temp2
          rem temp1 = Player index (0-3), temp2 = Animation sequence (0-15)
          CurrentAnimationFrame[temp1] = 0 
          rem Start at first frame
          AnimationCounter[temp1] = 0      
          rem Reset animation counter
          
          rem Update character sprite immediately
          temp3 = temp1 
          rem temp3 = Player number (0-3)
          gosub LoadPlayerSprite
          
          return

          rem Get current animation frame for a player
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = current animation frame (0-7)
GetCurrentAnimationFrame
          temp2 = CurrentAnimationFrame[temp1]
          rem temp1 = Player index (0-3), temp2 = Current animation frame (0-7)
          return

          rem Get current animation sequence for a player
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = current animation sequence (0-15)
GetCurrentAnimationSequence
          temp2 = CurrentAnimationSeq[temp1]
          rem temp1 = Player index (0-3), temp2 = Current animation sequence (0-15)
          return

          rem Initialize animation system for all players
          rem Called at game start to set up initial animation states
InitializeAnimationSystem
          rem Initialize all players to idle animation
          temp1 = 0  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          temp1 = 1  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          temp1 = 2  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          temp1 = 3  : temp2 = AnimIdle  : gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ANIMATION SEQUENCE MANAGEMENT
          rem =================================================================

          rem Set walking animation for a player
          rem Input: temp1 = player index (0-3)
SetWalkingAnimation
          temp2 = AnimWalking
          gosub SetPlayerAnimation
          return

          rem Set idle animation for a player
          rem Input: temp1 = player index (0-3)
SetIdleAnimation
          temp2 = AnimIdle
          gosub SetPlayerAnimation
          return

          rem Set attack animation for a player
          rem Input: temp1 = player index (0-3)
SetAttackAnimation
          temp2 = AnimAttackWindup
          gosub SetPlayerAnimation
          return

          rem Set hit animation for a player
          rem Input: temp1 = player index (0-3)
SetHitAnimation
          temp2 = AnimHit
          gosub SetPlayerAnimation
          return

          rem Set jumping animation for a player
          rem Input: temp1 = player index (0-3)
SetJumpingAnimation
          temp2 = AnimJumping
          gosub SetPlayerAnimation
          return

          rem Set falling animation for a player
          rem Input: temp1 = player index (0-3)
SetFallingAnimation
          temp2 = AnimFalling
          gosub SetPlayerAnimation
          return

          rem =================================================================
          rem ANIMATION STATE QUERIES
          rem =================================================================

          rem Check if player is in walking animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if walking, 0 if not
          IsPlayerWalking
          temp2 = 0
          if CurrentAnimationSeq[temp1] = AnimWalking then temp2 = 1
          return

          rem Check if player is in attack animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if attacking, 0 if not
IsPlayerAttacking
          temp2 = 0
          if CurrentAnimationSeq[temp1] < AnimAttackWindup then goto NotAttacking
          if CurrentAnimationSeq[temp1] > AnimAttackRecovery then goto NotAttacking
          temp2 = 1
NotAttacking
          return

          rem Check if player is in hit animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if hit, 0 if not
          IsPlayerHit
          temp2 = 0
          if CurrentAnimationSeq[temp1] = AnimHit then temp2 = 1
          return

          rem Check if player is in jumping animation
          rem Input: temp1 = player index (0-3)
          rem Output: temp2 = 1 if jumping, 0 if not
IsPlayerJumping
          temp2 = 0
          if CurrentAnimationSeq[temp1] = AnimJumping then goto IsJumping
          if CurrentAnimationSeq[temp1] = AnimFalling then goto IsJumping
          goto NotJumping
IsJumping
          temp2 = 1
NotJumping
          return