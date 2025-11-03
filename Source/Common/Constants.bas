          rem ChaosFight - Source/Common/Constants.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          const GameVersionMajor=0
          const GameVersionMinor=1
          const BuildYear=BUILD_YEAR
          rem Build year (4 digits, e.g. 2025, set by Makefile)
          const BuildDay=BUILD_DAY
          rem Build day in julian day format (1-366, set by Makefile)
          rem Game URL: https://interworldly.com/games/ChaosFight
          rem URL stored as comment for attribution
          const NumLevels=2
          const RandomLevel=0
          const RecoveryFrameCount=8
          const KnockbackDistance=12          
          rem Character system constants
          const NumCharacters = 16
          rem Total number of characters (0-15)
          const MaxCharacter = 15
          rem Maximum character ID (NumCharacters - 1)
          const NoCharacter = 255
          rem No character selected ($FF)
          const CPUCharacter = 254
          rem CPU player character ($FE)
          const RandomCharacter = 253
          rem Random character selection ($FD)

          rem Special sprite constants for SpecialSpritePointers table
          const SpriteQuestionMark = 0
          const SpriteCPU = 1
          const SpriteNo = 2
          
          rem playerState bit position constants
          const PlayerStateFacing = 0
          rem Bit 0: 0=left, 1=right
          const PlayerStateGuarding = 1
          rem Bit 1: 1=guarding
          const PlayerStateJumping = 2
          rem Bit 2: 1=jumping
          const PlayerStateRecovery = 3
          rem Bit 3: 1=recovery (hitstun)
          const PlayerStateAttacking = 4
          rem Bit 4: 1=attacking
          const PlayerStateAnimation = 7
          rem Bit position for animation state (bits 7-4, 4 bits)
          
          rem playerState bitmask constants  
          const MaskPlayerStateFlags = %00001111
          rem Bits 0-3: clear animation state, keep flags (lower 4 bits)
          const MaskPlayerStateLower = %00011111
          rem Bits 0-4: lower 5 bits (alternative mask for some operations)
          const MaskPlayerStateAnimation = %11110000
          rem Bits 4-7: animation state only (upper 4 bits)
          const ShiftAnimationState = 4
          rem Shift count for animation state (<< 4)
          
          rem playerState bitmask constants for clearing individual flags
          const MaskClearGuard = %11111101
          rem Clear bit 1 (PlayerStateGuarding)
          const MaskClearFacing = %11111110
          rem Clear bit 0 (PlayerStateFacing)
          
          rem playerState animation state masks
          const MaskAnimationRecovering = %10010000
          rem Animation state 9: Recovering (1001 in bits 7-4)
          const MaskAnimationFalling = %10100000
          rem Animation state 10: Falling after jump (1010 in bits 7-4)
          
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
          
          rem Color mask constants
          const MaskDimColor = $F6
          rem Color dimming mask for hurt flashing (NTSC/PAL): clears bits 2-3 to dim color
          
          rem SECAM color constants (SECAM uses fixed color values, no luminance)
          rem Note: Use ColCyan() macro instead of ColorSECAMCyan constant
          rem ColCyan(6) provides SECAM cyan color for guard flashing and special effects
          
          rem Controller status bit constants (packed into single byte)
          const QuadtariDetected = 7
          rem Bit 7: Quadtari adapter detected
          const Players34Active = 6
          rem Bit 6: Players 3 or 4 are active (selected and not eliminated) - used for missile multiplexing
          const LeftPortGenesis = 0
          rem Bit 0: Genesis or Joy2b+ on left port
          const LeftPortJoy2bPlus = 1
          rem Bit 1: Joy2b+ on left port (subset of LeftPortGenesis)
          const RightPortGenesis = 2
          rem Bit 2: Genesis or Joy2b+ on right port
          const RightPortJoy2bPlus = 3
          rem Bit 3: Joy2b+ on right port (subset of RightPortGenesis)
          
          rem Bit accessor aliases for controllerStatus
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
          const ClearPlayers34Active = $BF
          rem $FF - $40: Clear bit 6 (Players34Active)
          const ClearSystemFlag7800 = $7F
          rem $FF - $80: Clear bit 7 (SystemFlag7800)
          rem Bit mask constants for setting bits
          const SetQuadtariDetected = $80
          rem Set bit 7 (QuadtariDetected)
          const SetPlayers34Active = $40
          rem Set bit 6 (Players34Active)
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
          const BounceDampenDivisor = 4
          rem Divisor applied to velocity on bounce reflect (4 = 25% reduction)
          const CurlingFrictionCoefficient = 32
          rem Coefficient of friction for curling stone (Q8 fixed-point: 32/256 = 0.125)
          const MinimumVelocityThreshold = 2
          rem Minimum velocity before missile stops (pixels/frame)
          const WallBounceVelocityMultiplier = 192
          rem Velocity multiplier on wall bounce (Q8 fixed-point: 192/256 = 0.75)
          const HarpyFallMultiplier = 128
          rem Harpy fall speed multiplier (Q8 fixed-point: 128/256 = 0.5x normal gravity)
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

          rem =================================================================
          rem HEALTH CONSTANTS
          rem =================================================================
          const PlayerHealthMax = 100
          rem Maximum player health (full health)
          const PlayerHealthHandicap = 75
          rem Handicap mode health (75% of max)
          const PlayerHealthLowThreshold = 25
          rem Low health threshold for visual effects (flashing)

          rem =================================================================
          rem TIMING CONSTANTS
          rem =================================================================
          const FramesPerSecond = 60
          rem NTSC frame rate (frames per second)
          const FramesPerSecondPAL = 50
          rem PAL frame rate (frames per second)
          const FramesPerDecisecond = 6
          rem NTSC frames per decisecond (60/10)
          const FramesPerDecisecondPAL = 5
          rem PAL frames per decisecond (50/10)
          const SecondsPerMinute = 60
          rem Seconds in a minute (used for frame count calculations)
          const FramesPerMinute = 3600
          rem NTSC frames per minute (60 * 60)
          const FramesPerMinutePAL = 3000
          rem PAL frames per minute (50 * 60)
          const WinScreenAutoAdvanceFrames = 600
          rem Auto-advance win screen after 10 seconds (60fps * 10)
          const TitleParadeDelayFrames = 600
          rem Title parade starts after 10 seconds (60fps * 10)
#ifdef TV_NTSC
          const GuardTimerMaxFrames = 60
          rem Maximum guard timer (1 second at 60fps NTSC)
#else
          const GuardTimerMaxFrames = 50
          rem Maximum guard timer (1 second at 50fps PAL/SECAM)
#endif

          rem =================================================================
          rem SIZE AND DIMENSION CONSTANTS
          rem =================================================================
          const HealthBarMaxLength = 32
          rem Maximum health bar length in playfield pixels
          const CollisionSeparationDistance = 16
          rem Minimum distance between players before separation (pixels)
          const PlayerSpriteWidth = 16
          rem Player sprite width in pixels
          const PlayerSpriteHalfWidth = 8
          rem Already defined above, but keeping for consistency
          rem Player sprite half-width (8 pixels, used in collision checks)

          rem =================================================================
          rem MUSIC CONSTANTS (Song IDs: 0-255)
          rem =================================================================
          const SongPublisher = 0
          rem Publisher preamble (AtariToday.mscz) - gameMode 0
          const SongAuthor = 1
          rem Author preamble (Interworldly.mscz) - gameMode 1
          const SongTitle = 2
          rem Title screen (Title.mscz) - gameMode 2
          const SongGameOver = 3
          rem GameOver screen (GameOver.mscz) - gameMode 7, defeat
          const SongVictory = 4
          rem Victory screen (Victory.mscz) - gameMode 7, win

          rem =================================================================
          rem SOUND EFFECT CONSTANTS (Sound IDs: 0-255, separate namespace from songs)
          rem =================================================================
          const SoundAttackHit = 0
          const SoundGuardBlock = 1
          const SoundJump = 2
          const SoundPlayerEliminated = 3
          const SoundMenuNavigate = 4
          const SoundMenuSelect = 5
          const SoundSpecialMove = 6
          const SoundPowerup = 7
          const SoundLandingSafe = 8
          const SoundLandingDamage = 9
          rem Reserve 10-255 for future sounds
          
          rem Legacy sound constant aliases for backward compatibility
          const SoundAttack = SoundAttackHit
          const SoundHit = SoundAttackHit
          const SoundGuard = SoundGuardBlock
          const SoundFall = SoundLandingDamage
          const SoundElimination = SoundPlayerEliminated
          const SoundSelect = SoundMenuSelect
          const SoundVictory = SoundSpecialMove

          rem =================================================================
          rem ANIMATION SYSTEM CONSTANTS
          rem =================================================================
          rem Character frame animation runs at 10fps regardless of TV standard
          rem Movement updates run at full frame rate (60fps NTSC, 50fps PAL)

          #ifdef TV_NTSC
          const AnimationFrameDelay = 6
          rem 60fps / 10fps = 6 frames
          const MovementFrameRate = 60
          rem 60fps movement updates
          const HarpyFlapCooldownFrames = 15
          rem Harpy flap cooldown: ¼ second at 60fps (60/4 = 15 frames)
          #endif

          #ifdef TV_PAL  
          const AnimationFrameDelay = 5
          rem 50fps / 10fps = 5 frames
          const MovementFrameRate = 50
          rem 50fps movement updates
          const HarpyFlapCooldownFrames = 13
          rem Harpy flap cooldown: ¼ second at 50fps (50/4 = 12.5, rounded to 13 frames)
          #endif

          #ifdef TV_SECAM
          const AnimationFrameDelay = 5
          rem Same as PAL (50fps / 10fps = 5 frames)
          const MovementFrameRate = 50
          rem 50fps movement updates
          const HarpyFlapCooldownFrames = 13
          rem Harpy flap cooldown: ¼ second at 50fps (50/4 = 12.5, rounded to 13 frames)
          #endif

          rem Animation sequence structure constants
          const AnimationSequenceCount = 16
          rem 16 animation sequences (0-15)
          const FramesPerSequence = 8
          rem 8 frames per sequence

          rem =================================================================
          rem SUBPIXEL POSITION CONSTANTS
          rem =================================================================
          rem Fixed-point scheme: 8.8 (integer.fraction), implemented with 8-bit bB vars
          rem NOTE: batariBASIC variables are 8-bit. Use two 8-bit arrays to represent
          rem       a 16-bit fixed-point value: Hi = integer pixels, Lo = subpixel (0..255).
          const SubpixelBits = 8
          rem 8 bits of subpixel precision (0..255)
          const SubpixelScale = 256
          rem 2^8 = 256 subpixel units per pixel

          rem =================================================================
          rem PLAYFIELD CONSTANTS (runtime variables, not compile-time)
          rem =================================================================
          rem NOTE: pfrowheight and pfrows are set at runtime by ScreenLayout.bas
          rem These are NOT constants - they are runtime variables
          rem pfrowheight: pixels per row (8 for admin, 16 for game)
          rem pfrows: number of rows (32 for admin, 8 for game)
          rem pfread: built-in batariBASIC function to read playfield pixel
          rem These are documented here for reference but cannot be consted

