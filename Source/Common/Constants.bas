          rem ChaosFight - Source/Common/Constants.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          const GameVersionMajor=0
          const GameVersionMinor=1

          rem Build year (4 digits, e.g. 2025, set by Makefile)
          const BuildYear=BUILD_YEAR
          rem Build day in julian day format (1-366, set by Makefile)
          const BuildDay=BUILD_DAY

          rem Game URL: https://interworldly.com/games/ChaosFight
          const NumArenas=16
          const MaxArenaID=1
          const RandomArena=255
          const RecoveryFrameCount=8
          const KnockbackDistance=12
          rem Minimum horizontal separation distance (in pixels) between players
          rem If players are this distance or more apart, skip collision separation
          rem Characters are 8px wide, so 16px provides 2× sprite width separation
          rem Matches hardcoded value used in other collision checks (P1vsP3, P1vsP4, etc.)
          const CollisionSeparationDistance=16

          rem
          rem PHYSICS CONSTANTS - Gravity And Terminal Velocity
          rem Scale: 16px = 2m (character height), so 1px = 0.125m =
          rem
          rem   12.5cm
          rem Gravity values are in 8.8 fixed-point subpixel units (low
          rem   byte)
          rem Realistic Earth gravity would be 4410 px/frame² (too high
          rem   for gameplay!)
          rem Normal gravity acceleration (0.1 px/frame²)
          rem Value: 0.1 × 256 = 25.6 ≈ 26 (in low byte of 8.8 fixed-point)
          const GravityNormal = 26

          rem Reduced gravity acceleration (0.05 px/frame²) for Harpy
          rem Value: 0.05 × 256 = 12.8 ≈ 13 (in low byte of 8.8 fixed-point)
          const GravityReduced = 13

          rem Terminal velocity cap (maximum downward fall speed in px/frame)
          rem Prevents infinite acceleration from gravity
          const TerminalVelocity = 8

          rem Radish Goblin bounce movement constants
          rem Bounce height values in pixels (converted to velocity in movement system)
          const RadishGoblinBounceNormal = 10
          rem Normal bounce height (10 pixels upward)
          const RadishGoblinBounceHighSpeed = 5
          rem High-speed bounce height (5 pixels upward, when falling at TerminalVelocity or greater)
          const RadishGoblinBounceShort = 5
          rem Short bounce height (5 pixels upward, from stick down release)

          rem Character system constants
          rem Only 16 characters are selectable (0-15), but code handles up to 32 entries (0-31)
          rem Number of character slots in generated data
          const NumCharacters=16
          rem Maximum selectable character ID (NumCharacters - 1)
          const MaxCharacter = 15
          const RandomCharacter = 253
          rem Sentinel for “no character selected” state
          const NoCharacter = 255
          rem Sentinel for CPU-controlled selection
          const CPUCharacter = 254

          rem Sentinel and special value constants
          rem Missile lifetime value for infinite (until collision, no decrement)
          const MissileLifetimeInfinite = 255
          rem Sentinel value indicating no hit found in collision checks
          const MissileHitNotFound = 255
          rem Maximum 8-bit value ($FF), used for twos complement operations
          const MaxByteValue = 255
          rem Fall distance value for infinite (characters immune to fall damage)
          const InfiniteFallDistance = 255

          rem Highest song ID stored in Bank 15 music bank
          const Bank15MaxSongID = 6
          rem Lowest song ID stored in Bank 1 music bank
          const Bank1MinSongID = Bank15MaxSongID + 1

          rem Character ID constants
          const CharacterBernie = 0
          const CharacterCurler = 1
          const CharacterDragonOfStorms = 2
          const CharacterZoeRyen = 3
          const CharacterFatTony = 4
          const CharacterMegax = 5
          const CharacterHarpy = 6
          const CharacterKnightGuy = 7
          const CharacterFrooty = 8
          const CharacterNefertem = 9
          const CharacterNinjishGuy = 10
          const CharacterPorkChop = 11
          const CharacterRadishGoblin = 12
          const CharacterRoboTito = 13
          const CharacterUrsulo = 14
          const CharacterShamone = 15
          const CharacterMethHound = 31

          rem Special sprite constants for SpecialSpritePointers table
          const SpriteQuestionMark = 0
          const SpriteCPU = 1
          const SpriteNo = 2

          rem Unified font glyph indices (Source/Generated/Numbers.bas FontData)
          rem 0-9: digits "0"-"9"
          rem A: "?" (question mark), B: "No", C: "C", D: "CPU", E: " " (blank), F: "F"
          const GlyphQuestionMark = 10
          const GlyphNo = 11
          const GlyphC = 12
          const GlyphCPU = 13
          const GlyphBlank = 14
          const GlyphF = 15

          rem playerState bit position constants
          rem Bit 3: 0=left, 1=right (matches REFP0 bit 3 for direct copy)
          const PlayerStateFacing = 3
          rem Bit 1: 1=guarding
          const PlayerStateGuarding = 1
          rem Bit 2: 1=jumping
          const PlayerStateJumping = 2
          rem Bit 0: 1=in recovery/hitstun
          const PlayerStateRecovery = 0
          rem Bit 4: 1=attacking
          const PlayerStateAttacking = 4
          rem Bits 7-5: animation state (3 bits)
          const PlayerStateAnimation = 7

          rem Bit mask constants for playerState bit operations
          rem Use with: playerState[index] = playerState[index] & (255 -
          rem   PlayerStateBitMask) to clear bit
          rem Use with: playerState[index] = playerState[index] |
          const PlayerStateBitFacing = 8
          rem   PlayerStateBitMask to set bit
          const PlayerStateBitFacingNUSIZ = 64
          rem Bit mask for bit 3 (PlayerStateFacing) - matches REFP0 reflection bit
          rem Bit mask for bit 6 (NUSIZ reflection) -
          rem PlayerStateBitFacing shifted left 3 bits
          const NUSIZMaskReflection = 191
          rem Mask to clear bit 6 (reflection) from NUSIZ: $BF =
          rem %10111111
          const PlayerStateBitGuarding = 2
          const PlayerStateBitJumping = 4
          rem Bit mask for bit 1 (PlayerStateGuarding)
          const PlayerStateBitRecovery = 1
          rem Bit mask for bit 2 (PlayerStateJumping)
          const PlayerStateBitAttacking = 16
          rem Bit mask for bit 0 (PlayerStateRecovery)
          rem Bit mask for bit 4 (PlayerStateAttacking)

          rem Mask to clear guard bit (bit 1): 255 - 2 = 253 ($FD)
          const MaskClearGuard = 253

          rem Bit mask for preserving playerState flags (bits 0-3) while
          rem clearing animation state (bits 4-7)
          const MaskPlayerStateFlags = 15
          const MaskPlayerStateLower = 31
          const MaskPlayerStateAnimation = 240
          rem Mask to preserve bits 0-3 (flags) and clear bits 4-7
          rem (animation state): $0F = %00001111
          rem Mask to preserve bits 4-7 (animation state): $F0 = %11110000
          rem Use: playerState[index] = (playerState[index] &
          rem MaskPlayerStateFlags) | (animationState <<
          rem ShiftAnimationState)

          const ShiftAnimationState = 4
          rem Bit shift constants for playerState bit operations
          rem Shift amount for animation state (bits 4-7):
          rem ActionAttackExecute << 4
          rem Animation state is stored in bits 4-7 of playerState byte

          rem Pre-calculated shifted animation state values (to avoid
          rem bit shift
          rem   expressions that generate invalid assembly)
          const ActionAttackWindupShifted = 208
          rem ActionAttackWindup (13) << 4 = 208 (0xD0)
          const ActionAttackExecuteShifted = 224
          rem ActionAttackExecute (14) << 4 = 224 (0xE0)
          const ActionAttackRecoveryShifted = 240
          rem ActionAttackRecovery (15) << 4 = 240 (0xF0)

          rem Suppress pointer-setting code for arena playfield data
          rem This maintains 24-byte alignment required by LoadArenaByIndex routine
          rem LoadArenaByIndex calculates pointers dynamically, so pointer-setting code is redundant
          const _suppress_pf_pointer_code = 1

          rem ECHOFIRST is generated by batariBASIC compiler (2600bas.c)
          rem Its a forward reference that resolves when the compiler generates it
          rem Define it here as a placeholder if referenced before compiler generates it
          rem This is a DASM conditional: if ECHOFIRST ... endif (generated by compiler)
          const ActionJumpingShifted = 160
          rem ActionJumping (10) << 4 = 160 (0xA0)
          const ActionFalling = 11
          const ActionFallingShifted = 176
          rem ActionFalling (11) << 4 = 176 (0xB0)
          const ActionFallenDown = 8
          const ActionFallenDownShifted = 128
          rem ActionFallenDown (8) << 4 = 128 (0x80) - Issue #1178: Bernie post-fall stun
          const MaskAnimationRecovering = 144
          rem ActionRecovering (9) << 4 = 144 (0x90)
          const MaskAnimationFalling = 176
          rem Alias for ActionFallingShifted (0xB0) for clarity in masks

          const HighBit = $80
          const TRUE = $80
          rem High bit constants for input testing
          rem Boolean TRUE value (high bit set)
          const PaddleLeftButton = 0
          rem Bit 7: high bit for testing input states
          const PaddleRightButton = 2
          rem INPT0: Left paddle button
          rem INPT2: Right paddle button

          const VBlankGroundINPT0123 = $C0
          rem VBLANK constants for controller detection
          rem VBLANK with paddle ground enabled for controller detection


          const QuadtariDetected = 7
          rem Controller status bit constants (packed into single byte)
          const Players34Active = 6
          rem Bit 7: Quadtari adapter detected
          rem Bit 6: Players 3 or 4 are active (selected and not
          const LeftPortGenesis = 0
          rem   eliminated) - used for missile multiplexing
          const LeftPortJoy2bPlus = 1
          rem Bit 0: Genesis or Joy2b+ on left port
          const RightPortGenesis = 2
          rem Bit 1: Joy2b+ on left port (subset of LeftPortGenesis)
          const RightPortJoy2bPlus = 3
          rem Bit 2: Genesis or Joy2b+ on right port
          rem Bit 3: Joy2b+ on right port (subset of RightPortGenesis)

          rem Bit accessor aliases for controllerStatus
          rem Bit accessor aliases removed to avoid compiler issues; use
          rem   bit masks directly

          const SystemFlag7800 = $80
          rem Console detection constants
          const SystemFlagColorBWOverride = $40
          rem Bit 7: 1=7800 console, 0=2600 console
          const SystemFlagPauseButtonPrev = $20
          rem Bit 6: 1=Color/B&W override active (7800 only)
          rem Bit 5: 1=Pause button was pressed previous frame
          const SystemFlagGameStatePaused = $10
          const SystemFlagGameStateEnding = $08
          rem Bit 4: 1=Game paused (0=normal play)
          rem Bit 3: 1=Game ending (transition to winner screen)
          const ConsoleDetectD0 = $2C
          rem Bits 0-2: Reserved for future use
          const ConsoleDetectD1 = $A9
          rem $D0 value for 7800 detection
          rem $D1 value for 7800 detection

          const ClearQuadtariDetected = $7F
          rem Bit mask constants for clearing bits
          const ClearPlayers34Active = $BF
          rem $FF - $80: Clear bit 7 (QuadtariDetected)
          const ClearSystemFlag7800 = $7F
          rem $FF - $40: Clear bit 6 (Players34Active)
          const ClearSystemFlagColorBWOverride = $BF
          rem $FF - $80: Clear bit 7 (SystemFlag7800)
          const ClearSystemFlagPauseButtonPrev = $DF
          rem $FF - $40: Clear bit 6 (ColorBWOverride)
          const ClearSystemFlagGameStatePaused = $EF
          rem $FF - $20: Clear bit 5 (PauseButtonPrev)
          const ClearSystemFlagGameStateEnding = $F7
          rem $FF - $10: Clear bit 4 (GameStatePaused)
          rem $FF - $08: Clear bit 3 (GameStateEnding)
          const SetQuadtariDetected = $80
          rem Bit mask constants for setting bits
          const SetSystemFlag7800 = $80
          rem Set bit 7 (QuadtariDetected)
          const SetSystemFlagColorBWOverride = $40
          rem Set bit 7 (SystemFlag7800)
          const SetSystemFlagPauseButtonPrev = $20
          rem Set bit 6 (ColorBWOverride)
          const SetSystemFlagGameStatePaused = $10
          rem Set bit 5 (PauseButtonPrev)
          const SetSystemFlagGameStateEnding = $08
          rem Set bit 4 (GameStatePaused)
          rem Set bit 3 (GameStateEnding)

          rem PlayerLocked value constants (for bit-packed playerLocked
          rem byte)
          const PlayerLockedUnlocked = 0
          rem 0 = Unlocked (still browsing)
          const PlayerLockedNormal = 1
          rem 1 = Locked normal (100% health)
          const PlayerHandicapped = 2
          rem 2 = Locked handicap (75% health)
          rem 3 = Reserved (unused)

          const PlayerHealthMax = 100
          rem Player health constants

          rem Animation system constants
          const US_SEPARATOR = 0
          rem Workaround for compiler bug with dim/const concatenation
          rem Maximum player health (100% = full health, range 0-100)
          const HealthBarMaxLength = 8
          rem Maximum health bar length in pixels (100 ÷ 12½ = 8)
          const PlayerHealthHandicap = 75
          rem Handicap player health (75% of max = 75 ÷ 100)
          const SetPlayers34Active = $40
          rem Set bit 6 (Players34Active)
          const SetLeftPortGenesis = $01
          rem Bit mask constants for controller port detections
          const SetLeftPortJoy2bPlus = $02
          const SetRightPortGenesis = $04
          const SetRightPortJoy2bPlus = $08
          const ClearLeftPortGenesis = $FE
          const ClearLeftPortJoy2bPlus = $FD
          const ClearRightPortGenesis = $FB
          const ClearRightPortJoy2bPlus = $F7

          rem
          const GravityPerFrame = 1
          rem Physics Tunables
          rem Pixels/frame added to vertical velocity when gravity
          const BounceDampenDivisor = 2
          rem   applies
          rem Divisor applied to velocity on bounce reflect (for minimal
          const CurlingFrictionCoefficient = 4
          rem   velocity reduction)
          rem Ice-like friction coefficient (Q8 fixed-point: 4/256 =
          rem   1.56% per frame reduction)
          rem Used for curling stone near-perfect momentum (very low
          rem   friction, similar to ice)
          rem Previous value: 32 (12.5% per frame) - too high for
          const KnockbackImpulse = 4
          rem   ice-like sliding
          const HitstunFrames = 10
          rem Frames of hitstun after a missile hit
          const MissileAABBSize = 4
          rem Missile bounding box size (square)
          const PlayerSpriteHalfWidth = 8
          rem Half-width of player sprite used in AABB checks
          const PlayerSpriteHeight = 16
          rem Player sprite height used in AABB checks
          const PlayerSpriteWidth = 16
          rem Player sprite width used in AABB checks
          const ScreenWidth = 160
          rem Total hardware screen width in pixels
          const ScreenLeftMargin = 16
          rem Left margin reserved for off-playfield area
          const ScreenRightMargin = 16
          rem Right margin reserved for off-playfield area
          const PlayerLeftEdge = ScreenLeftMargin
          rem Leftmost X position for a player sprite
          const PlayerRightEdge = ScreenWidth - ScreenRightMargin - PlayerSpriteWidth
          rem Rightmost X position for a player sprite
          const PlayerWrapOvershoot = PlayerSpriteHalfWidth
          rem Allow sprites to move partially off-screen before wrapping
          const PlayerLeftWrapThreshold = PlayerLeftEdge - PlayerWrapOvershoot
          rem X value that triggers wrap-around from left edge
          const PlayerRightWrapThreshold = PlayerRightEdge + PlayerWrapOvershoot
          rem X value that triggers wrap-around from right edge
          rem NOTE: EQU definitions for these constants are in Preamble.bas for DASM
          const PlayerCollisionDistance = 16
          rem Collision detection distance (sprite width in pixels)
          const MissileDefaultHeight = 1
          rem Default missile height when AOE (0) is reported
          const MissileMaxHeight = 8
          rem Cap for missile height (TIA limit)
          const MinimumVelocityThreshold = 1
          rem Minimum velocity threshold for missile deactivation (pixels/frame)
          const ScreenInsetX = 16
          rem Usable X inset from each side (playable area starts at 16)
          const ScreenUsableWidth = 128
          rem Usable width inside insets
          const ScreenBottom = 192
          rem Bottom pixel threshold
          const ScreenTopWrapThreshold = 200
          rem
          rem Byte-safe top-wrap detection threshold

          rem Music Constants
          const NoteAttackFrames = 4
          const NoteDecayFrames = 8
          rem Main game songs (0-Bank15MaxSongID)
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
          const MusicAtariToday = 27
          rem Title song Chaotica (index 26, loops)
          const MusicInterworldly = 28

          rem
          rem Sound Effect Constants
          const SoundAttackHit = 0
          rem Sound effect enumerated IDs (matching SoundPointers.bas indices 0-9)
          const SoundGuardBlock = 1
          const SoundJump = 2
          const SoundPlayerEliminated = 3
          const SoundMenuNavigate = 4
          const SoundMenuSelect = 5
          const SoundSpecialMove = 6
          const SoundPowerup = 7
          const SoundLandingSafe = 8
          const SoundLandingDamage = 9

          rem
          rem Animation System Constants
          rem Character frame animation runs at 10fps regardless of TV
          rem   standard
          rem Movement updates run at 60fps NTSC / 50fps PAL

#ifdef TV_NTSC
          const AnimationFrameDelay = 6
          const MovementFrameRate = 60
          rem 60fps ÷ 10fps = 6 frames
          const FramesPerSecond = 60
          rem 60fps movement updates
          const TitleParadeDelayFrames = 240
          rem Parade starts after ~4 seconds at 60fps
          const WinScreenAutoAdvanceFrames = 600
          rem Winner screen auto-advance after 10 seconds
          const GuardTimerMaxFrames = 60
          rem Guard duration capped at 1 second
          const HarpyFlapCooldownFrames = 40
          rem ~0.66 seconds between Harpy flaps (1.5 flaps/sec)
#endif

#ifdef TV_PAL
          const AnimationFrameDelay = 5
          const MovementFrameRate = 50
          rem 50fps ÷ 10fps = 5 frames
          const FramesPerSecond = 50
          rem 50fps movement updates
          const TitleParadeDelayFrames = 200
          rem Parade starts after ~4 seconds at 50fps
          const WinScreenAutoAdvanceFrames = 500
          rem Winner screen auto-advance after 10 seconds
          const GuardTimerMaxFrames = 50
          rem Guard duration capped at 1 second
          const HarpyFlapCooldownFrames = 33
          rem ~0.66 seconds between Harpy flaps (1.5 flaps/sec)
#endif

#ifdef TV_SECAM
          const AnimationFrameDelay = 5
          rem Same as PAL (50fps / 10fps = 5 frames)
          const MovementFrameRate = 50
          const FramesPerSecond = 50
          rem 50fps movement updates
          const TitleParadeDelayFrames = 200
          rem Parade starts after ~4 seconds at 50fps
          const WinScreenAutoAdvanceFrames = 500
          rem Winner screen auto-advance after 10 seconds
          const GuardTimerMaxFrames = 50
          rem Guard duration capped at 1 second
          const HarpyFlapCooldownFrames = 33
          rem ~0.66 seconds between Harpy flaps (1.5 flaps/sec)
#endif

          const AnimationSequenceCount = 16
          rem Animation sequence structure constants
          const FramesPerSequence = 8
          rem 16 animation sequences (0-15)
          rem
          rem 8 frames per sequence

          rem Subpixel Position Constants
          rem Fixed-point scheme: 8.8 (integer.fraction), implemented
          rem   with 8-bit bB vars
          rem NOTE: batariBASIC variables are 8-bit. Use two 8-bit
          rem   arrays to represent
          rem a 16-bit fixed-point value: Hi = integer pixels, Lo =
          const SubpixelBits = 8
          rem   subpixel (0..255).
          const SubpixelScale = 256
          rem 8 bits of subpixel precision (0..255)
          rem
          rem 2^8 = 256 subpixel units per pixel

          rem PLAYFIELD CONSTANTS (runtime Variables, Not Compile-time)
          rem NOTE: pfrowheight and pfrows are set at runtime by
          rem   ScreenLayout.bas
          rem These are NOT constants - they are runtime variables
          rem pfrowheight: pixels per row (always 16)
          rem pfrows: number of rows (always 8)
          rem pfread: built-in batariBASIC function to read playfield
          rem   pixel
          rem These are documented here for reference but cannot be
          rem   consted

          rem SCREEN LAYOUT CONSTANTS
          const ScreenPfRowHeight = 16
          const ScreenPfRows = 8

