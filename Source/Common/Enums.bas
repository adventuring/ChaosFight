          rem Chaos Fight Source/Common/Enums.s
          rem Copyright 2025 Interworldly Adventuring, LLC

          rem TV Standards
          const NTSC = 1
          const PAL = 2
          const SECAM = 3

          rem Game Modes
          const ModePublisherPreamble = 0
          const ModeAuthorPreamble = 1
          const ModeTitle = 2
          const ModeCharacterSelect = 3
          const ModeFallingAnimation = 4
          const ModeLevelSelect = 5
          const ModeGame = 6
          const ModeWinner = 7

          rem =================================================================
          rem ANIMATION ACTION ENUMS
          rem =================================================================
          rem 16 animation actions (0-15) stored in playerState bits 4-7
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

          rem NOTE: RoboTito repurposes existing animation states:
          rem AnimJumping (10) = Stretching upward
          rem AnimFalling (11) = Latched to ceiling  
          rem AnimLanding (12) = Retracting trunk

          rem =================================================================
          rem MISSILE FLAGS BITFIELD ENCODING
          rem =================================================================
          rem Bit flags for missile behavior (CharacterMissileFlags)
          rem Used for checking missile interaction properties
          
          const MissileFlagHitBackground = 1
          rem Bit 0: Hit background (1=hit and disappear, 0=pass through)
          
          const MissileFlagHitPlayer = 2
          rem Bit 1: Hit player (1=hit and disappear, 0=pass through)
          
          const MissileFlagGravity = 4
          rem Bit 2: Apply gravity (1=affected by gravity, 0=no gravity)
          
          const MissileFlagBounce = 8
          rem Bit 3: Bounce off walls (1=bounce, 0=stop/hit)
          
          const MissileFlagFriction = 16
          rem Bit 4: Apply friction physics (curling stone deceleration)
          
          rem Combined flags for common combinations
          const MissileFlagHitBoth = 3
          rem Bits 0-1: Hit both background and players (%00000011)
