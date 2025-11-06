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
          const NumArenas=16
          const MaxArenaID=1
          const RandomArena=255
          const RecoveryFrameCount=8
          const KnockbackDistance=12          
          
          rem PHYSICS CONSTANTS - Gravity And Terminal Velocity
          rem
          rem Scale: 16px = 2m (character height), so 1px = 0.125m =
          rem   12.5cm
          rem Gravity values are in 8.8 fixed-point subpixel units (low
          rem   byte)
          rem Realistic Earth gravity would be 4410 px/frame² (too high
          rem   for gameplay!)
          rem 
          rem Normal gravity acceleration (0.1 px/frame²)
          rem Value: 0.1 * 256 = 25.6 ≈ 26 (in low byte of 8.8
          rem   fixed-point)
          const GravityNormal = 26
          
          rem Reduced gravity acceleration (0.05 px/frame²) for Harpy
          rem Value: 0.05 * 256 = 12.8 ≈ 13 (in low byte of 8.8
          rem   fixed-point)
          const GravityReduced = 13
          
          rem Terminal velocity cap (maximum downward fall speed in
          rem   px/frame)
          rem Prevents infinite acceleration from gravity
          const TerminalVelocity = 8
          
          rem Character system constants
          rem Note: Only 16 characters are selectable (0-15), but code
          rem   handles up to 32 characters (0-31) including non-selectable
          rem   characters like MethHound (31)
          const NumCharacters=16
          rem Number of selectable characters
          const MaxCharacter = 15
          rem Maximum selectable character ID (NumCharacters - 1)
          const NoCharacter = 255
          rem No character selected ($FF)
          const CPUCharacter = 254
          rem CPU player character ($FE)
          
          rem Sentinel and special value constants
          const MissileLifetimeInfinite = 255
          rem Missile lifetime value for infinite (until collision, no
          rem   decrement)
          const MissileHitNotFound = 255
          rem Sentinel value indicating no hit found in collision checks
          const MaxByteValue = 255
          rem Maximum 8-bit value ($FF), used for two’s complement
          rem   operations
          const InfiniteFallDistance = 255
          rem Fall distance value for infinite (characters immune to
          rem   fall damage)
          
          rem Character ID constants
          const CharBernie = 0
          const CharCurler = 1
          const CharDragonOfStorms = 2
          const CharZoeRyen = 3
          const CharFatTony = 4
          const CharMegax = 5
          const CharHarpy = 6
          const CharKnightGuy = 7
          const CharFrooty = 8
          const CharNefertem = 9
          const CharNinjishGuy = 10
          const CharPorkChop = 11
          const CharRadishGoblin = 12
          const CharRoboTito = 13
          const CharUrsulo = 14
          const CharShamone = 15

          rem Special sprite constants for SpecialSpritePointers table
          const SpriteQuestionMark = 0
          const SpriteCPU = 1
          const SpriteNo = 2
          
          rem playerState bit position constants
          const PlayerStateFacing = 3
          rem Bit 3: 0=left, 1=right (matches REFP0 bit 3 for direct copy)
          const PlayerStateGuarding = 1
          rem Bit 1: 1=guarding
          const PlayerStateJumping = 2
          rem Bit 2: 1=jumping
          const PlayerStateRecovery = 0
          rem Bit 0: 1=in recovery/hitstun
          const PlayerStateAttacking = 4
          rem Bit 4: 1=attacking
          const PlayerStateAnimation = 7
          rem Bits 7-5: animation state (3 bits)
          
          rem Bit mask constants for PlayerState bit operations
          rem Use with: PlayerState[index] = PlayerState[index] & (255 -
          rem   PlayerStateBitMask) to clear bit
          rem Use with: PlayerState[index] = PlayerState[index] |
          rem   PlayerStateBitMask to set bit
          const PlayerStateBitFacing = 8
          rem Bit mask for bit 3 (PlayerStateFacing) - matches REFP0 reflection bit
          const PlayerStateBitFacingNUSIZ = 64
          rem Bit mask for bit 6 (NUSIZ reflection) - PlayerStateBitFacing shifted left 3 bits
          const NUSIZMaskReflection = 191
          rem Mask to clear bit 6 (reflection) from NUSIZ: $BF = %10111111
          const PlayerStateBitGuarding = 2
          rem Bit mask for bit 1 (PlayerStateGuarding)
          const PlayerStateBitJumping = 4
          rem Bit mask for bit 2 (PlayerStateJumping)
          const PlayerStateBitRecovery = 1
          rem Bit mask for bit 0 (PlayerStateRecovery)
          const PlayerStateBitAttacking = 16
          rem Bit mask for bit 4 (PlayerStateAttacking)
          
          rem Bit mask for preserving PlayerState flags (bits 0-3) while clearing animation state (bits 4-7)
          const MaskPlayerStateFlags = 15
          rem Mask to preserve bits 0-3 (flags) and clear bits 4-7 (animation state): $0F = %00001111
          rem Use: PlayerState[index] = (PlayerState[index] & MaskPlayerStateFlags) | (animationState << ShiftAnimationState)
          
          rem Bit shift constants for PlayerState bit operations
          const ShiftAnimationState = 4
          rem Shift amount for animation state (bits 4-7): ActionAttackExecute << 4
          rem Animation state is stored in bits 4-7 of PlayerState byte
          
          rem Pre-calculated shifted animation state values (to avoid bit shift
          rem   expressions that generate invalid assembly)
          rem ActionAttackExecute (14) << 4 = 224 (0xE0)
          const ActionAttackExecuteShifted = 224
          rem ActionJumping (10) << 4 = 160 (0xA0)
          const ActionJumpingShifted = 160
          rem ActionFalling (11) << 4 = 176 (0xB0)
          const ActionFallingShifted = 176
          
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
          
          rem Player elimination bit constants (playersEliminated flags)
          const PlayerEliminatedPlayer0 = 1
          rem Bit 0: Player 0 eliminated ($01)
          const PlayerEliminatedPlayer1 = 2
          rem Bit 1: Player 1 eliminated ($02)
          const PlayerEliminatedPlayer2 = 4
          rem Bit 2: Player 2 eliminated ($04)
          const PlayerEliminatedPlayer3 = 8
          rem Bit 3: Player 3 eliminated ($08)
          
          rem Controller status bit constants (packed into single byte)
          const QuadtariDetected = 7
          rem Bit 7: Quadtari adapter detected
          const Players34Active = 6
          rem Bit 6: Players 3 or 4 are active (selected and not
          rem   eliminated) - used for missile multiplexing
          const LeftPortGenesis = 0
          rem Bit 0: Genesis or Joy2b+ on left port
          const LeftPortJoy2bPlus = 1
          rem Bit 1: Joy2b+ on left port (subset of LeftPortGenesis)
          const RightPortGenesis = 2
          rem Bit 2: Genesis or Joy2b+ on right port
          const RightPortJoy2bPlus = 3
          rem Bit 3: Joy2b+ on right port (subset of RightPortGenesis)
          
          rem Bit accessor aliases for controllerStatus
          rem Bit accessor aliases removed to avoid compiler issues; use
          rem   bit masks directly
          
          rem Console detection constants
          const SystemFlag7800 = $80
          rem Bit 7: 1=7800 console, 0=2600 console
          const SystemFlagColorBWOverride = $40
          rem Bit 6: 1=Color/B&W override active (7800 only)
          const SystemFlagPauseButtonPrev = $20
          rem Bit 5: 1=Pause button was pressed previous frame
          const SystemFlagGameStatePaused = $10
          rem Bit 4: 1=Game paused (0=normal play)
          const SystemFlagGameStateEnding = $08
          rem Bit 3: 1=Game ending (transition to winner screen)
          rem Bits 0-2: Reserved for future use
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
          const ClearSystemFlagColorBWOverride = $BF
          rem $FF - $40: Clear bit 6 (ColorBWOverride)
          const ClearSystemFlagPauseButtonPrev = $DF
          rem $FF - $20: Clear bit 5 (PauseButtonPrev)
          const ClearSystemFlagGameStatePaused = $EF
          rem $FF - $10: Clear bit 4 (GameStatePaused)
          const ClearSystemFlagGameStateEnding = $F7
          rem $FF - $08: Clear bit 3 (GameStateEnding)
          rem Bit mask constants for setting bits
          const SetQuadtariDetected = $80
          rem Set bit 7 (QuadtariDetected)
          const SetSystemFlag7800 = $80
          rem Set bit 7 (SystemFlag7800)
          const SetSystemFlagColorBWOverride = $40
          rem Set bit 6 (ColorBWOverride)
          const SetSystemFlagPauseButtonPrev = $20
          rem Set bit 5 (PauseButtonPrev)
          const SetSystemFlagGameStatePaused = $10
          rem Set bit 4 (GameStatePaused)
          const SetSystemFlagGameStateEnding = $08
          rem Set bit 3 (GameStateEnding)
          
          rem PlayerLocked value constants (for bit-packed playerLocked byte)
          rem Values: 0=unlocked, 1=locked normal, 2=locked handicap
          const PlayerLockedUnlocked = 0
          rem 0 = Unlocked (still browsing)
          const PlayerLockedNormal = 1
          rem 1 = Locked normal (100% health)
          const PlayerLockedHandicap = 2
          rem 2 = Locked handicap (75% health)
          rem 3 = Reserved (unused)
          
          rem Player health constants
          const PlayerHealthMax = 100
          rem Maximum player health (100% = full health, range 0-100)
          const PlayerHealthHandicap = 75
          rem Handicap player health (75% of max = 75/100)
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

          rem Physics Tunables
          rem
          const GravityPerFrame = 1
          rem Pixels/frame added to vertical velocity when gravity
          rem   applies
          const BounceDampenDivisor = 2
          rem Divisor applied to velocity on bounce reflect (for minimal
          rem   velocity reduction)
          const CurlingFrictionCoefficient = 4
          rem Ice-like friction coefficient (Q8 fixed-point: 4/256 =
          rem   1.56% per frame reduction)
          rem Used for curling stone near-perfect momentum (very low
          rem   friction, similar to ice)
          rem Previous value: 32 (12.5% per frame) - too high for
          rem   ice-like sliding
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
          const PlayerSpriteWidth = 16
          rem Full width of double-width sprite (16 pixels)
          const PlayerCollisionDistance = 16
          rem Collision detection distance (sprite width in pixels)
          const MissileDefaultHeight = 1
          rem Default missile height when AOE (0) is reported
          const MissileMaxHeight = 8
          rem Cap for missile height (TIA limit)
          const MinimumVelocityThreshold = 1
          rem Minimum velocity threshold for missile deactivation (pixels/frame)
          rem Missiles with velocity below this threshold are deactivated
          const ScreenInsetX = 16
          rem Usable X inset from each side (playable area starts at 16)
          const ScreenUsableWidth = 128
          rem Usable width inside insets
          const ScreenBottom = 192
          rem Bottom pixel threshold
          const ScreenTopWrapThreshold = 200
          rem Byte-safe top-wrap detection threshold

          rem Music Constants
          rem
          rem Main game songs (0-4)
          rem Song indices match SongPointers.bas (29 songs total: 0-28)
          rem Songs 0-25: Character theme songs in character ID order
          rem   (skipping duplicates)
          rem Character order: 0=Bernie, 1=OCascadia, 2=Revontuli,
          rem   3=EXO, 4=Grizzards,
          rem 7=MagicalFairyForce, 9=Bolero, 10=LowRes, 13=RoboTito,
          rem   14=SongOfTheBear,
          rem   15=DucksAway, 16-30=Character16Theme-Character30Theme
          rem Song 26: Chaotica (Title screen - loops)
          rem Song 27: AtariToday (Publisher prelude - plays once)
          rem Song 28: Interworldly (Author prelude - plays once)
          rem NOTE: Only Chaotica (26) loops; all others play once
          const SongBernie = 0
          const SongOCascadia = 1
          const SongRevontuli = 2
          const SongEXO = 3
          const SongGrizzards = 4
          const SongMagicalFairyForce = 5
          const SongBolero = 6
          const SongLowRes = 7
          const SongRoboTito = 8
          const SongSongOfTheBear = 9
          const SongDucksAway = 10
          const SongCharacter16Theme = 11
          const SongCharacter17Theme = 12
          const SongCharacter18Theme = 13
          const SongCharacter19Theme = 14
          const SongCharacter20Theme = 15
          const SongCharacter21Theme = 16
          const SongCharacter22Theme = 17
          const SongCharacter23Theme = 18
          const SongCharacter24Theme = 19
          const SongCharacter25Theme = 20
          const SongCharacter26Theme = 21
          const SongCharacter27Theme = 22
          const SongCharacter28Theme = 23
          const SongCharacter29Theme = 24
          const SongCharacter30Theme = 25
          const MusicChaotica = 26
          const MusicTitle = 26
          rem Title song Chaotica (index 26, loops)
          const MusicAtariToday = 27
          const MusicInterworldly = 28

          rem Sound Effect Constants
          rem
          rem Sound effect enumerated IDs (matching SoundPointers.bas indices 0-9)
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

          rem Animation System Constants
          rem
          rem Character frame animation runs at 10fps regardless of TV
          rem   standard
          rem Movement updates run at full frame rate (60fps NTSC, 50fps
          rem   PAL)

#ifdef TV_NTSC
          const AnimationFrameDelay = 6
          rem 60fps / 10fps = 6 frames
          const MovementFrameRate = 60
          rem 60fps movement updates
          const FramesPerSecond = 60
          rem 60fps frame rate
#endif

#ifdef TV_PAL  
          const AnimationFrameDelay = 5
          rem 50fps / 10fps = 5 frames
          const MovementFrameRate = 50
          rem 50fps movement updates
          const FramesPerSecond = 50
          rem 50fps frame rate
#endif

#ifdef TV_SECAM
          const AnimationFrameDelay = 5
          rem Same as PAL (50fps / 10fps = 5 frames)
          const MovementFrameRate = 50
          rem 50fps movement updates
          const FramesPerSecond = 50
          rem 50fps frame rate
#endif

          rem Animation sequence structure constants
          const AnimationSequenceCount = 16
          rem 16 animation sequences (0-15)
          const FramesPerSequence = 8
          rem 8 frames per sequence

          rem Subpixel Position Constants
          rem
          rem Fixed-point scheme: 8.8 (integer.fraction), implemented
          rem   with 8-bit bB vars
          rem NOTE: batariBASIC variables are 8-bit. Use two 8-bit
          rem   arrays to represent
          rem a 16-bit fixed-point value: Hi = integer pixels, Lo =
          rem   subpixel (0..255).
          const SubpixelBits = 8
          rem 8 bits of subpixel precision (0..255)
          const SubpixelScale = 256
          rem 2^8 = 256 subpixel units per pixel

          rem PLAYFIELD CONSTANTS (runtime Variables, Not Compile-time)
          rem
          rem NOTE: pfrowheight and pfrows are set at runtime by
          rem   ScreenLayout.bas
          rem These are NOT constants - they are runtime variables
          rem pfrowheight: pixels per row (8 for admin, 16 for game)
          rem pfrows: number of rows (32 for admin, 8 for game)
          rem pfread: built-in batariBASIC function to read playfield
          rem   pixel
          rem These are documented here for reference but cannot be
          rem   consted

