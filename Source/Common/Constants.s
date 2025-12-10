;;; ChaosFight - Source/Common/Constants.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

          GameVersionMajor = 0
          GameVersionMinor = 1

          ;; Build year (4 digits, e.g. 2025, set by Makefile)
          BuildYear = BUILD_YEAR
          ;; Build day in julian day format (1-366, set by Makefile)
          BuildDay = BUILD_DAY

          ;; TV Standard constants (matches TVStandard enum values)
          ;; These match the TVStandard values set by platform files:
          ;; NTSC.s: TVStandard = 0
          ;; PAL.s: TVStandard = 1
          ;; SECAM.s: TVStandard = 2
          ;; Note: These are batariBASIC constants. For assembly .if directives,
          ;; use TVStandard == NTSC, TVStandard == PAL, TVStandard == SECAM
          NTSC = 0
          PAL = 1
          SECAM = 2

          ;; Game URL: https://interworldly.com/games/ChaosFight
          NumArenas = 16
          MaxArenaID = 1
          RandomArena = 255
          RecoveryFrameCount = 8
          KnockbackDistance = 12
          ;; Minimum horizontal separation distance (in pixels) between players
          ;; If players are this distance or more apart, skip collision separation
          ;; Characters are 8px wide, so 16px provides 2x sprite width separation
          ;; Matches hardcoded value used in other collision checks (P1vsP3, P1vsP4, etc.)
          CollisionSeparationDistance = 16

          ;;
          ;; PHYSICS CONSTANTS - Gravity and Terminal Velocity
          ;; Scale: 16px = 2m (character height), so 1px = 0.125m =
          ;;
          ;; 12.5cm
          ;; Gravity values are in 8.8 fixed-point subpixel units (low
          ;; byte)
          ;; Realistic Earth gravity would be 4410 px/frame² (too high
          ;; for gameplay!)
          ;; Normal gravity acceleration (0.1 px/frame²)
          ;; Value: 0.1 × 256 = 25.6 ≈ 26 (in low byte of 8.8 fixed-point)
          GravityNormal = 26

          ;; Reduced gravity acceleration (0.05 px/frame²) for Harpy
          ;; Value: 0.05 × 256 = 12.8 ≈ 13 (in low byte of 8.8 fixed-point)
          GravityReduced = 13

          ;; Terminal velocity cap (maximum downward fall speed in px/frame)
          ;; Prevents infinite acceleration from gravity
          TerminalVelocity = 8

          ;; Radish Goblin bounce movement consta

          ;; Bounce height values in pixels (converted to velocity in movement system)
          RadishGoblinBounceNormal = 10
          ;; Normal bounce height (10 pixels upward)
          RadishGoblinBounceHighSpeed = 5
          ;; High-speed bounce height (5 pixels upward, when falling at TerminalVelocity or greater)
          RadishGoblinBounceShort = 5
          ;; Short bounce height (5 pixels upward, from stick down release)

          ;; Character system consta

          ;; Only 16 characters are selectable (0-15), but code handles up to 32 entries (0-31)
          ;; Number of character slots in generated data
          NumCharacters = 16
          ;; Maximum selectable character ID (NumCharacters - 1)
          MaxCharacter = 15
          RandomCharacter = 253
          ;; Sentinel for “no character selected” sta

          NoCharacter = 255
          ;; Sentinel for CPU-controlled selection
          CPUCharacter = 254

          ;; Sentinel and special value consta

          ;; Missile lifetime value for infinite (until collision, no decrement)
          MissileLifetimeInfinite = 255
          ;; Sentinel value indicating no hit found in collision checks
          MissileHitNotFound = 255
          ;; Maximum 8-bit value ($FF), used for twos complement operations
          MaxByteValue = 255
          ;; Fall distance value for infinite (characters immune to fall damage)
          InfiniteFallDistance = 255

          ;; Highest song ID stored in Bank 15 music bank
          Bank14MaxSongID = 6
          ;; Lowest song ID stored in Bank 1 music bank
          Bank0MinSongID = 7
          ;; Bank0MinSongID = Bank14MaxSongID + 1

          ;; Character ID consta

          CharacterBernie = 0
          CharacterCurler = 1
          CharacterDragonOfStorms = 2
          CharacterZoeRyen = 3
          CharacterFatTony = 4
          CharacterMegax = 5
          CharacterHarpy = 6
          CharacterKnightGuy = 7
          CharacterFrooty = 8
          CharacterNefertem = 9
          CharacterNinjishGuy = 10
          CharacterPorkChop = 11
          CharacterRadishGoblin = 12
          CharacterRoboTito = 13
          CharacterUrsulo = 14
          CharacterShamone = 15
          CharacterMethHound = 31

          ;; Special sprite constants for SpecialSpritePointers table
          SpriteQuestionMark = 0
          SpriteCPU = 1
          SpriteNo = 2

          ;; Unified font glyph indices (Source/Generated/Numbers.bas SetFontNumbers)
          ;; 0-9: digits ’0’-’9’
          ;; A: ’?’ (question mark), B: ’No’, C: ’C’, D: ’CPU’, E: ’ ’ (blank), F: ’F’
          GlyphQuestionMark = 10
          GlyphNo = 11
          GlyphC = 12
          GlyphCPU = 13
          GlyphBlank = 14
          GlyphF = 15

          ;; playerState bit position consta

          ;; bit 3: 0=left, 1=right (matches REFP0 bit 3 for direct copy)
          PlayerStateFacing = 3
          ;; bit 1: 1=guarding
          PlayerStateGuarding = 1
          ;; bit 2: 1=jumping
          PlayerStateJumping = 2
          ;; bit 0: 1=in recovery/hitstun
          PlayerStateRecovery = 0
          ;; bit 4: 1=attacking
          PlayerStateAttacking = 4
          ;; Bits 7-5: animation state (3 bits)
          PlayerStateAnimation = 7

          ;; bit mask constants for playerState bit operations
          ;; Use with: playerState[index] = playerState[index] & (255 -
          ;; PlayerStateBitMask) to clear bit
          ;; Use with: playerState[index] = playerState[index] |
          PlayerStateBitFacing = 8
          ;; PlayerStateBitMask to set bit
          PlayerStateBitFacingNUSIZ = 64
          ;; bit mask for bit 3 (PlayerStateFacing) - matches REFP0 reflection bit
          ;; bit mask for bit 6 (NUSIZ reflection) -
          ;; PlayerStateBitFacing shifted left 3 bits
          NUSIZMaskReflection = 191
          ;; Mask to clear bit 6 (reflection) from NUSIZ: $BF =
          ;; %10111111
          PlayerStateBitGuarding = 2
          PlayerStateBitJumping = 4
          ;; bit mask for bit 1 (PlayerStateGuarding)
          PlayerStateBitRecovery = 1
          ;; bit mask for bit 2 (PlayerStateJumping)
          PlayerStateBitAttacking = 16
          ;; bit mask for bit 0 (PlayerStateRecovery)
          ;; bit mask for bit 4 (PlayerStateAttacking)

          ;; Mask to clear guard bit (bit 1): 255 - 2 = 253 ($FD)
          MaskClearGuard = 253

          ;; bit mask for preserving playerState flags (bits 0-3) while
          ;; clearing animation state (bits 4-7)
          MaskPlayerStateFlags = 15
          MaskPlayerStateLower = 31
          MaskPlayerStateAnimation = 240
          ;; Mask to preserve bits 0-3 (flags) and clear bits 4-7
          ;; (animation state): $0F = %00001111
          ;; Mask to preserve bits 4-7 (animation state): $F0 = %11110000
          ;; Use: playerState[index] = (playerState[index] &
          ;; MaskPlayerStateFlags) | (animationState <<
          ;; ShiftAnimationState)

          ShiftAnimationState = 4
          ;; bit shift constants for playerState bit operations
          ;; Shift amount for animation state (bits 4-7):
          ;; ActionAttackExecute << 4
          ;; Animation state is stored in bits 4-7 of playerState byte

          ;; Pre-calculated shifted animation state values (to avoid
          ;; bit shift
          ;; expressions that generate invalid assembly)
          ActionAttackWindupShifted = 208
          ;; ActionAttackWindup (13) << 4 = 208 (0xD0)
          ActionAttackExecuteShifted = 224
          ;; ActionAttackExecute (14) << 4 = 224 (0xE0)
          ActionAttackRecoveryShifted = 240
          ;; ActionAttackRecovery (15) << 4 = 240 (0xF0)

          ;; Suppress pointer-setting code for arena playfield data
          ;; This maintains 24-byte alignment required by LoadArenaByIndex routine
          ;; LoadArenaByIndex calculates pointers dynamically, so pointer-setting code is redundant
_suppress_pf_pointer_code = 1

          ;; ECHOFIRST is generated by batariBASIC compiler (2600bas.c)
          ;; Its a forward reference that resolves when the compiler generates it
          ;; Define it here as a placeholder if referenced before compiler generates it
          ;; This is a DASM conditional: if ECHOFIRST ... .fi (generated by compiler)
          ActionJumpingShifted = 160
          ;; ActionJumping (10) << 4 = 160 (0xA0)
          ;; ActionFalling = 11 (duplicate - defined in Enums.s)
          ActionFallingShifted = 176
          ;; ActionFalling (11) << 4 = 176 (0xB0)
          ActionFallenDown = 8
          ActionFallenDownShifted = 128
          ;; ActionFallenDown (8) << 4 = 128 (0×80) - Issue #1178: Bernie post-fall stun
          MaskAnimationRecovering = 144
          ;; ActionRecovering (9) << 4 = 144 (0×90)
          MaskAnimationFalling = 176
          ;; Alias for ActionFallingShifted (0xB0) for clarity in masks

          HighBit = $80
          TRUE = $80
          ;; High bit constants for input testing
          ;; Boolean TRUE value (high bit set)
          PaddleLeftButton = 0
          ;; bit 7: high bit for testing input sta

          PaddleRightButton = 2
          ;; INPT0: Left paddle button
          ;; INPT2: Right paddle button

          VBlankGroundINPT0123 = $C0
          ;; VBLANK constants for controller detection
          ;; VBLANK with paddle ground enabled for controller detection


          QuadtariDetected = 7
          ;; Controller status bit constants (packed into single byte)
          Players34Active = 6
          ;; bit 7: Quadtari adapter detected
          ;; bit 6: Players 3 or 4 are active (selected and not
          LeftPortGenesis = 0
          ;; eliminated) - used for missile multiplexing
          LeftPortJoy2bPlus = 1
          ;; bit 0: Genesis or Joy2b+ on left port
          RightPortGenesis = 2
          ;; bit 1: Joy2b+ on left port (subset of LeftPortGenesis)
          RightPortJoy2bPlus = 3
          ;; bit 2: Genesis or Joy2b+ on right port
          ;; bit 3: Joy2b+ on right port (subset of RightPortGenesis)

          ;; bit accessor aliases for controllerStatus
          ;; Use bit masks directly (accessor aliases not available)

          SystemFlag7800 = $80
          ;; Console detection consta

          SystemFlagColorBWOverride = $40
          ;; bit 7: 1=7800 console, 0=2600 console
          SystemFlagPauseButtonPrev = $20
          ;; bit 6: 1=Color/B&W override active (7800 only)
          ;; bit 5: 1=Pause button was pressed previous frame
          SystemFlagGameStatePaused = $10
          SystemFlagGameStateEnding = $08
          ;; bit 4: 1=Game paused (0=normal play)
          ;; bit 3: 1=Game ending (transition to winner screen)
          ConsoleDetectD0 = $2C
          ;; Bits 0-2: Reserved for future use
          ConsoleDetectD1 = $A9
          ;; $D0 value for 7800 detection
          ;; $D1 value for 7800 detection

          ClearQuadtariDetected = $7F
          ;; bit mask constants for clearing bits
          ClearPlayers34Active = $BF
          ;; $FF - $80: Clear bit 7 (QuadtariDetected)
          ClearSystemFlag7800 = $7F
          ;; $FF - $40: Clear bit 6 (Players34Active)
          ClearSystemFlagColorBWOverride = $BF
          ;; $FF - $80: Clear bit 7 (SystemFlag7800)
          ClearSystemFlagPauseButtonPrev = $DF
          ;; $FF - $40: Clear bit 6 (ColorBWOverride)
          ClearSystemFlagGameStatePaused = $EF
          ;; $FF - $20: Clear bit 5 (PauseButtonPrev)
          ClearSystemFlagGameStateEnding = $F7
          ;; $FF - $10: Clear bit 4 (GameStatePaused)
          ;; $FF - $08: Clear bit 3 (GameStateEnding)
          SetQuadtariDetected = $80
          ;; bit mask constants for setting bits
          SetSystemFlag7800 = $80
          ;; Set bit 7 (QuadtariDetected)
          SetSystemFlagColorBWOverride = $40
          ;; Set bit 7 (SystemFlag7800)
          SetSystemFlagPauseButtonPrev = $20
          ;; Set bit 6 (ColorBWOverride)
          SetSystemFlagGameStatePaused = $10
          ;; Set bit 5 (PauseButtonPrev)
          SetSystemFlagGameStateEnding = $08
          ;; Set bit 4 (GameStatePaused)
          ;; Set bit 3 (GameStateEnding)

          ;; PlayerLocked value constants (for bit-packed playerLocked
          ;; byte)
          PlayerLockedUnlocked = 0
          ;; 0 = Unlocked (still browsing)
          PlayerLockedNormal = 1
          ;; 1 = Locked normal (100% health)
          PlayerHandicapped = 2
          ;; 2 = Locked handicap (75% health)
          ;; 3 = Reserved (unused)

          PlayerHealthMax = 100
          ;; Player health consta


          ;; Animation system consta

          US_SEPARATOR = 0
          ;; Workaround for compiler bug with dim/const concatenation
          ;; Maximum player health (100% = full health, range 0-100)
          HealthBarMaxLength = 8
          ;; Maximum health bar length in pixels (100 ÷ 12½ = 8)
          PlayerHealthHandicap = 75
          ;; Handicap player health (75% of max = 75 ÷ 100)
          SetPlayers34Active = $40
          ;; Set bit 6 (Players34Active)
          SetLeftPortGenesis = $01
          ;; bit mask constants for controller port detections
          SetLeftPortJoy2bPlus = $02
          SetRightPortGenesis = $04
          SetRightPortJoy2bPlus = $08
          ClearLeftPortGenesis = $FE
          ClearLeftPortJoy2bPlus = $FD
          ClearRightPortGenesis = $FB
          ClearRightPortJoy2bPlus = $F7

          ;;
          GravityPerFrame = 1
          ;; Physics Tunables
          ;; Pixels/frame added to vertical velocity when gravity
          BounceDampenDivisor = 2
          ;; applies
          ;; Divisor applied to velocity on bounce reflect (for minimal
          CurlingFrictionCoefficient = 4
          ;; velocity reduction)
          ;; Ice-like friction coefficient (Q8 fixed-point: 4 ÷ 256 =
          ;; 1.56% per frame reduction)
          ;; Used for curling stone near-perfect momentum (very low
          ;; friction, similar to ice)
          KnockbackImpulse = 4
          HitstunFrames = 10
          ;; Frames of hitstun after a missile hit
          MissileAABBSize = 4
          ;; Missile bounding box size (square)
          PlayerSpriteHalfWidth = 8
          ;; Half-width of player sprite used in AABB checks
          PlayerSpriteHeight = 16
          ;; Player sprite height used in AABB checks
          PlayerSpriteWidth = 16
          ;; Player sprite width used in AABB checks
          ScreenWidth = 160
          ;; Total hardware screen width in pixels
          ScreenLeftMargin = 16
          ;; Left margin reserved for off-playfield area
          ScreenRightMargin = 16
          ;; Right margin reserved for off-playfield area
          PlayerLeftEdge = 16
          ;; Leftmost X position for a player sprite (ScreenLeftMargin)
          PlayerRightEdge = 128
          ;; Rightmost X position for a player sprite (ScreenWidth - ScreenRightMargin - PlayerSpriteWidth = 160 - 16 - 16)
          PlayerWrapOvershoot = 8
          ;; Allow sprites to move partially off-screen before wrapping (PlayerSpriteHalfWidth)
          PlayerLeftWrapThreshold = 8
          ;; × value that triggers wrap-around from left edge (PlayerLeftEdge - PlayerWrapOvershoot = 16 - 8)
          PlayerRightWrapThreshold = 136
          ;; × value that triggers wrap-around from right edge (PlayerRightEdge + PlayerWrapOvershoot = 128 + 8)
          PlayerCollisionDistance = 16
          ;; Collision detection distance (sprite width in pixels)
          MissileDefaultHeight = 1
          ;; Default missile height when AOE (0) is reported
          MissileMaxHeight = 8
          ;; Cap for missile height (TIA limit)
          MinimumVelocityThreshold = 1
          ;; Minimum velocity threshold for missile deactivation (pixels/frame)
          ScreenInsetX = 16
          ;; Usable × inset from each side (playable area starts at 16)
          ScreenUsableWidth = 128
          ;; Usable width inside insets
          ScreenBottom = 192
          ;; Bottom pixel threshold
          ScreenTopWrapThreshold = 200
          ;;
          ;; Byte-safe top-wrap detection threshold

          ;; Music Consta

          NoteAttackFrames = 4
          NoteDecayFrames = 8
          ;; Main game songs (0-Bank14MaxSongID)
          ;; Song indices match SongPointers.bas (29 songs total: 0-28)
          ;; Songs 0-25: Character theme songs in character ID order
          ;; (skipping duplicates)
          ;; Character order: 0=Bernie, 1=OCascadia, 2=Revontuli,
          ;; 3=EXO, 4=Grizzards,
          ;; 7=MagicalFairyForce, 9=Bolero, 10=LowRes, 13=RoboTito,
          ;; 14=SongOfTheBear,
          ;; 15=DucksAway, 16-30=Character16Theme-Character30Theme
          ;; Song 26: Chaotica (Title screen - loops)
          ;; Song 27: AtariToday (Publisher prelude - plays once)
          ;; Song 28: Interworldly (Author prelude - plays once)
          ;; NOTE: Only Chaotica (26) loops; all others play once
          SongBernie = 0
          SongOCascadia = 1
          SongRevontuli = 2
          SongEXO = 3
          SongGrizzards = 4
          SongMagicalFairyForce = 5
          SongBolero = 6
          SongLowRes = 7
          SongRoboTito = 8
          SongSongOfTheBear = 9
          SongDucksAway = 10
          SongCharacter16Theme = 11
          SongCharacter17Theme = 12
          SongCharacter18Theme = 13
          SongCharacter19Theme = 14
          SongCharacter20Theme = 15
          SongCharacter21Theme = 16
          SongCharacter22Theme = 17
          SongCharacter23Theme = 18
          SongCharacter24Theme = 19
          SongCharacter25Theme = 20
          SongCharacter26Theme = 21
          SongCharacter27Theme = 22
          SongCharacter28Theme = 23
          SongCharacter29Theme = 24
          SongCharacter30Theme = 25
          MusicChaotica = 26
          MusicTitle = 26
          MusicAtariToday = 27
          ;; Title song Chaotica (index 26, loops)
          MusicInterworldly = 28

          ;;
          ;; Sound Effect Consta

          SoundAttackHit = 0
          ;; Sound effect enumerated IDs (matching SoundPointers.bas indices 0-9)
          SoundGuardBlock = 1
          SoundJump = 2
          SoundPlayerEliminated = 3
          SoundMenuNavigate = 4
          SoundMenuSelect = 5
          SoundSpecialMove = 6
          SoundPowerup = 7
          SoundLandingSafe = 8
          SoundLandingDamage = 9

          ;;
          ;; Animation System Consta

          ;; Character frame animation runs at 10fps regardless of TV
          ;; sta

          ;; Movement updates run at 60fps NTSC / 50fps PAL

.if TVStandard == NTSC
          AnimationFrameDelay = 6
          MovementFrameRate = 60
          ;; 60fps / 10fps = 6 frames
          FramesPerSecond = 60
          ;; 60fps movement updates
          TitleParadeDelayFrames = 240
          ;; Parade starts after ~4 seconds at 60fps
          WinScreenAutoAdvanceFrames = 600
          ;; Winner screen auto-advance after 10 seconds
          GuardTimerMaxFrames = 60
          ;; Guard duration capped at 1 second
          HarpyFlapCooldownFrames = 40
          ;; ~0.66 seconds between Harpy flaps (1.5 flaps/sec)
.fi

.if TVStandard == PAL
          AnimationFrameDelay = 5
          MovementFrameRate = 50
          ;; 50fps / 10fps = 5 frames
          FramesPerSecond = 50
          ;; 50fps movement updates
          TitleParadeDelayFrames = 200
          ;; Parade starts after ~4 seconds at 50fps
          WinScreenAutoAdvanceFrames = 500
          ;; Winner screen auto-advance after 10 seconds
          GuardTimerMaxFrames = 50
          ;; Guard duration capped at 1 second
          HarpyFlapCooldownFrames = 33
          ;; ~0.66 seconds between Harpy flaps (1.5 flaps/sec)
.fi

.if TVStandard == SECAM
          AnimationFrameDelay = 5
          ;; Same as PAL (50fps / 10fps = 5 frames)
          MovementFrameRate = 50
          FramesPerSecond = 50
          ;; 50fps movement updates
          TitleParadeDelayFrames = 200
          ;; Parade starts after ~4 seconds at 50fps
          WinScreenAutoAdvanceFrames = 500
          ;; Winner screen auto-advance after 10 seconds
          GuardTimerMaxFrames = 50
          ;; Guard duration capped at 1 second
          HarpyFlapCooldownFrames = 33
          ;; ~0.66 seconds between Harpy flaps (1.5 flaps/sec)
.fi

          AnimationSequenceCount = 16
          ;; Animation sequence structure consta

          FramesPerSequence = 8
          ;; 16 animation sequences (0-15)
          ;;
          ;; 8 frames per sequence

          ;; Subpixel Position Consta

          ;; Fixed-point scheme: 8.8 (integer.fraction), implemented
          ;; with 8-bit bB vars
          ;; NOTE: batariBASIC variables are 8-bit. Use two 8-bit
          ;; arrays to represent
          ;; a 16-bit fixed-point value: Hi = integer pixels, Lo =
          SubpixelBits = 8
          ;; subpixel (0..255).
          SubpixelScale = 256
          ;; 8 bits of subpixel precision (0..255)
          ;;
          ;; 2^8 = 256 subpixel units per pixel

          ;; PLAYFIELD CONSTANTS (runtime Variables, Not Compile-time)
          ;; NOTE: pfrowheight and pfrows are set at runtime by
          ;; ScreenLayout.bas
          ;; These are NOT constants - they are runtime variables
          ;; pfrowheight: pixels per row (always 16)
          ;; pfrows: number of rows (always 8)
          ;; pfread: built-in batariBASIC function to read playfield
          ;; pixel
          ;; These are documented here for reference but cannot be
          ;; consted

          ;; SCREEN LAYOUT CONSTANTS
          ScreenPfRowHeight = 16
          ScreenPfRows = 8


;;; Forward declarations for undefined symbols
;;; Additional constants for MultiSpriteSuperChip
;;; Forward declarations for song symbols (defined in generated music files)
;;; TIA/RIOT Hardware Registers (Atari 2600)
          INTIM = $0284  ;;; Timer (read-only)
          WSYNC = $02  ;;; Wait for horizontal sync
          GRP0 = $1B  ;;; Graphics Player 0
          HMCLR = $2C  ;;; Clear horizontal motion registers

          INPT0 = $08  ;;; Input port 0 (joystick/button)
          INPT1 = $09  ;;; Input port 1
          INPT2 = $0A  ;;; Input port 2
          INPT3 = $0B  ;;; Input port 3
          INPT4 = $0C  ;;; Input port 4 (paddle)
          INPT5 = $0D  ;;; Input port 5 (paddle)

;;; Forward declarations for sound symbols
