          rem Chaos Fight Source/Common/Enums.s
          rem Copyright 2025 Interworldly Adventuring, LLC

          rem TV Standards
          const NTSC = 1
          const PAL = 2
          const SECAM = 3

          rem Game Modes
          const ModePublisherPrelude = 0
          const ModeAuthorPrelude = 1
          const ModeTitle = 2
          const ModeCharacterSelect = 3
          const ModeFallingAnimation = 4
          const ModeLevelSelect = 5
          const ModeGame = 6
          const ModeWinner = 7

          rem =================================================================
          rem ANIMATION ACTION ENUMS
          rem =================================================================
          rem 16 animation actions (0-15) stored in PlayerState bits 4-7
          rem Used for character animation sequences
          rem Each action has up to 8 frames (0-7)
          
          const AnimStanding = 0
          rem Standing still (facing right)
          
          const AnimIdle = 1
          rem Idle (resting)
          
          const AnimGuarding = 2
          rem Standing still guarding
          
          const AnimWalking = 3
          rem Walking/running
          
          const AnimStopping = 4
          rem Coming to stop
          
          const AnimHit = 5
          rem Taking a hit
          
          const AnimFallBack = 6
          rem Falling backwards
          
          const AnimFallDown = 7
          rem Falling down
          
          const AnimFallen = 8
          rem Fallen down
          
          const AnimRecovering = 9
          rem Recovering to standing
          
          const AnimJumping = 10
          rem Jumping
          
          const AnimFalling = 11
          rem Falling after jump
          
          const AnimLanding = 12
          rem Landing
          
          const AnimAttackWindup = 13
          rem Attack windup
          
          const AnimAttackExecute = 14
          rem Attack execution
          
          const AnimAttackRecovery = 15
          rem Attack recovery
