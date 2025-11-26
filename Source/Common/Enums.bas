          rem Chaos Fight Source/Common/Enums.bas
          rem Copyright 2025 Bruce-Robert Pocock

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
          const ModeArenaSelect = 5
          const ModeGame = 6
          const ModeWinner = 7
          const ModeAttract = 8

          rem
          rem Animation Action Enums
          rem 16 animation actions (0-15) stored in playerState bits 4-7
          rem Used for character animation sequences
          rem Each action has up to 8 frames (0-7)

          rem Standing still (facing right)
          const ActionStanding = 0

          rem Idle (resting)
          const ActionIdle = 1

          rem Standing still guarding
          const ActionGuarding = 2

          rem Walking/running
          const ActionWalking = 3

          rem Coming to stop
          const ActionStopping = 4

          rem Taking a hit
          const ActionHit = 5

          rem Falling backwards
          const ActionFallBack = 6

          rem Falling down
          const ActionFallDown = 7

          rem Fallen down
          const ActionFallen = 8

          rem Recovering to standing
          const ActionRecovering = 9

          rem Jumping
          const ActionJumping = 10

          rem Falling after jump
          const ActionFalling = 11

          rem Landing
          const ActionLanding = 12

          rem Attack windup
          const ActionAttackWindup = 13

          rem Attack execution
          const ActionAttackExecute = 14

          rem Attack recovery
          const ActionAttackRecovery = 15

          rem NOTE: RoboTito repurposes existing animation states:
          rem
          rem ActionJumping (10) = Stretching upward
          rem ActionFalling (11) = Latched to ceiling
          rem ActionLanding (12) = Retracting trunk

          rem Missile Flags Bitfield Encoding
          rem Bit flags for missile behavior (CharacterMissileFlags)
          rem Used for checking missile interaction properties

          rem Bit 0: Hit background (1=hit and disappear, 0=pass through)
          const MissileFlagHitBackground = 1

          rem Bit 1: Hit player (2=hit and disappear, 0=pass through)
          const MissileFlagHitPlayer = 2

          rem Bit 2: Apply gravity (4=affected by gravity, 0=no gravity)
          const MissileFlagGravity = 4

          rem Bit 3: Bounce off walls (8=bounce, 0=stop/hit)
          const MissileFlagBounce = 8

          rem Bit 4: Apply friction physics (curling stone deceleration)
          const MissileFlagFriction = 16

          rem Combined flags for common combinations (bits 0-1)
          const MissileFlagHitBoth = 3

          rem Bits 0 and 2 set: HitBackground|Gravity = 1+4 = 5 (%00000101)
          const MissileFlagHitBackgroundAndGravity = 5

          rem Bits 0-4 set: HitBackground|HitPlayer|Gravity|Bounce|Friction
          const MissileFlagCurlerFull = 31

          rem Attack Type Constants (for CharacterAttackTypes data table and PlayerAttackType array)
          const MeleeAttack = 0
          const RangedAttack = 1
          const AreaAttack = 2

