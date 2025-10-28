          rem ChaosFight - Source/Common/Constants.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          const GameVersionMajor=0
          const GameVersionMinor=1
          const BuildDate=BUILD_DATE
          rem Build date in year.julian format (set by Makefile)
          rem Game URL: https://interworldly.com/games/ChaosFight
          rem URL stored as comment for attribution
          const NumLevels=2
          const RandomLevel=0
          const RecoveryFrameCount=8
          const KnockbackDistance=12          
          rem Character system constants
          const MaxCharacter = 15
          rem Maximum character ID (0-15 = 16 characters)
          const NoCharacter = 255
          rem No character selected ($FF)
          const CPUCharacter = 255
          rem CPU player character ($FF)

          rem Special sprite constants for SpecialSpritePointers table
          const SpriteQuestionMark = 0
          const SpriteCPU = 1
          const SpriteNo = 2
          
          rem PlayerState bit constants
          const PlayerStateFacing = 0
          rem Bit 0: 0=left, 1=right
          const PlayerStateGuarding = 1
          rem Bit 1: 1=guarding
          const PlayerStateJumping = 2
          rem Bit 2: 1=jumping
          const PlayerStateAttacking = 4
          rem Bit 4: 1=attacking
          const PlayerStateAnimation = 7
          rem Bits 7-5: animation state (3 bits)
          
          rem High bit constants for input testing
          const HighBit = $80
          rem Bit 7: high bit for testing input states
          const PaddleLeftButton = 0
          rem INPT0: Left paddle button
          const PaddleRightButton = 2
          rem INPT2: Right paddle button
          
          rem VBLANK constants for controller detection
          const VBlankGroundINPT0123 = $C0
          rem VBLANK with paddle ground enabled for controller detection
          
          rem Controller status bit constants (packed into single byte)
          const QuadtariDetected = 7
          rem Bit 7: Quadtari adapter detected
          const LeftPortGenesis = 0
          rem Bit 0: Genesis or Joy2b+ on left port
          const LeftPortJoy2bPlus = 1
          rem Bit 1: Joy2b+ on left port (subset of LeftPortGenesis)
          const RightPortGenesis = 2
          rem Bit 2: Genesis or Joy2b+ on right port
          const RightPortJoy2bPlus = 3
          rem Bit 3: Joy2b+ on right port (subset of RightPortGenesis)
          
          rem Bit accessor aliases for ControllerStatus
          rem Bit accessor aliases removed to avoid compiler issues; use bit masks directly
          
          rem Console detection constants
          const SystemFlag7800 = $80
          rem Bit 7: 1=7800 console, 0=2600 console
          const ConsoleDetectD0 = $2C
          rem $D0 value for 7800 detection
          const ConsoleDetectD1 = $A9
          rem $D1 value for 7800 detection
          
          rem Bit mask constants for clearing bits
          const ClearQuadtariDetected = $7F
          rem $FF - $80: Clear bit 7 (QuadtariDetected)
          const ClearSystemFlag7800 = $7F
          rem $FF - $80: Clear bit 7 (SystemFlag7800)
          rem Bit mask constants for setting bits
          const SetQuadtariDetected = $80
          rem Set bit 7 (QuadtariDetected)
          rem Bit mask constants for controller port detections
          const SetLeftPortGenesis = $01
          const SetLeftPortJoy2bPlus = $02
          const SetRightPortGenesis = $04
          const SetRightPortJoy2bPlus = $08
          const ClearLeftPortGenesis = $FE
          const ClearLeftPortJoy2bPlus = $FD
          const ClearRightPortGenesis = $FB
          const ClearRightPortJoy2bPlus = $F7

          rem =================================================================
          rem PHYSICS TUNABLES
          rem =================================================================
          const GravityPerFrame = 1
          rem Pixels/frame added to vertical velocity when gravity applies
          const BounceDampenDivisor = 2
          rem Divisor applied to velocity on bounce reflect
          const KnockbackImpulse = 4
          rem Pixels/frame impulse applied on hit knockback
          const HitstunFrames = 10
          rem Frames of hitstun after a missile hit
          const MissileSpawnOffsetLeft = 4
          rem Pixels to the left when facing left at spawn
          const MissileSpawnOffsetRight = 12
          rem Pixels to the right when facing right at spawn
          const MissileAABBSize = 4
          rem Missile bounding box size (square)
          const PlayerSpriteHalfWidth = 8
          rem Half-width of player sprite used in AABB checks
          const PlayerSpriteHeight = 16
          rem Player sprite height used in AABB checks
          const MissileDefaultHeight = 1
          rem Default missile height when AOE (0) is reported
          const MissileMaxHeight = 8
          rem Cap for missile height (TIA limit)
          const ScreenInsetX = 16
          rem Usable X inset from each side (playable area starts at 16)
          const ScreenUsableWidth = 128
          rem Usable width inside insets
          const ScreenBottom = 192
          rem Bottom pixel threshold
          const ScreenTopWrapThreshold = 200
          rem Byte-safe top-wrap detection threshold
          
          rem Animation constants included separately
