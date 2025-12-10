;;; Chaos Fight Source/Common/Enums.bas
;;; Copyright 2025 Bruce-Robert Pocock

;;; TV Standards
NTSC = 1
PAL = 2
SECAM = 3

          ;; Game Modes
ModePublisherPrelude = 0
ModeAuthorPrelude = 1
ModeTitle = 2
ModeCharacterSelect = 3
ModeFallingAnimation = 4
ModeArenaSelect = 5
ModeGame = 6
ModeWinner = 7
ModeAttract = 8

          ;;
          ;; Animation Action Enums
          ;; 16 animation actions (0-15) stored in playerState bits 4-7
          ;; Used for character animation sequences
          ;; Each action has up to 8 frames (0-7)

          ;; Standing still (facing right)
ActionStanding = 0

          ;; Idle (resting)
ActionIdle = 1

          ;; Standing still guarding
ActionGuarding = 2

          ;; Walking/running
ActionWalking = 3

          ;; Coming to stop
ActionStopping = 4

          ;; Taking a hit
ActionHit = 5

          ;; Falling backwards
ActionFallBack = 6

          ;; Falling down
ActionFallDown = 7

          ;; Fallen down
ActionFallen = 8

          ;; Recovering to sta

ActionRecovering = 9

          ;; Jumping
ActionJumping = 10

          ;; Falling after jump
ActionFalling = 11

          ;; Landing
ActionLanding = 12

          ;; Attack windup
ActionAttackWindup = 13

          ;; Attack execution
ActionAttackExecute = 14

          ;; Attack recovery
ActionAttackRecovery = 15

          ;; NOTE: RoboTito repurposes existing animation states:
          ;;
          ;; ActionJumping (10) = Stretching upward
          ;; ActionFalling (11) = Latched to ceiling
          ;; ActionLanding (12) = Retracting trunk

          ;; Missile Flags Bitfield Encoding
          ;; bit flags for missile behavior (CharacterMissileFlags)
          ;; Used for checking missile interaction properties

          ;; bit 0: Hit background (1=hit and disappear, 0=pass through)
MissileFlagHitBackground = 1

          ;; bit 1: Hit player (2=hit and disappear, 0=pass through)
MissileFlagHitPlayer = 2

          ;; bit 2: Apply gravity (4=affected by gravity, 0=no gravity)
MissileFlagGravity = 4

          ;; bit 3: Bounce off walls (8=bounce, 0=stop/hit)
MissileFlagBounce = 8

          ;; bit 4: Apply friction physics (curling stone deceleration)
MissileFlagFriction = 16

          ;; Combined flags for common combinations (bits 0-1)
MissileFlagHitBoth = 3

          ;; Bits 0 and 2 set: HitBackground|Gravity = 1+4 = 5 (%00000101)
MissileFlagHitBackgroundAndGravity = 5

          ;; Bits 0-4 set: HitBackground|HitPlayer|Gravity|Bounce|Friction
MissileFlagCurlerFull = 31

          ;; Attack Type Constants (for CharacterAttackTypes data table and PlayerAttackType array)
MeleeAttack = 0
RangedAttack = 1
AreaAttack = 2

