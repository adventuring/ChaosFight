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
          const ModeAttract = 8

          rem =================================================================
          rem ANIMATION ACTION ENUMS
          rem =================================================================
          rem 16 animation actions (0-15) stored in playerState bits 4-7
          rem Used for character animation sequences
          rem Each action has up to 8 frames (0-7)
          
          const ActionStanding = 0
          rem Standing still (facing right)
          
          const ActionIdle = 1
          rem Idle (resting)
          
          const ActionGuarding = 2
          rem Standing still guarding
          
          const ActionWalking = 3
          rem Walking/running
          
          const ActionStopping = 4
          rem Coming to stop
          
          const ActionHit = 5
          rem Taking a hit
          
          const ActionFallBack = 6
          rem Falling backwards
          
          const ActionFallDown = 7
          rem Falling down
          
          const ActionFallen = 8
          rem Fallen down
          
          const ActionRecovering = 9
          rem Recovering to standing
          
          const ActionJumping = 10
          rem Jumping
          
          const ActionFalling = 11
          rem Falling after jump
          
          const ActionLanding = 12
          rem Landing
          
          const ActionAttackWindup = 13
          rem Attack windup
          
          const ActionAttackExecute = 14
          rem Attack execution
          
          const ActionAttackRecovery = 15
          rem Attack recovery
