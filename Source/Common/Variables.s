;;; ChaosFight - Source/Common/Variables.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; MEMORY LAYOUT - MULTISPRITE KERNEL WITH SUPERCHIP:
;;; - Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z
          ;; ($d4-$ed) = 26 bytes = 74 bytes always available
          ;; - SuperChip RAM (SCRAM): Accessed via r000-r127/w000-w127
          ;; ($1000-$107F physical RAM) = 128 bytes
          ;; NOTE: There is NO var48-var127! SuperChip RAM is accessed
          ;; via r000-r127/w000-w127 only!
          ;; - MULTISPRITE KERNEL: Playfield data is stored in ROM (not
          ;; RAM), so playfield uses ZERO bytes of RAM
          ;; This means ALL 128 bytes of SCRAM (r000-r127/w000-w127)
          ;;
          ;; are available at all times!
          ;; NOTE: Multisprite playfield is symmetrical
          ;; (repeated/reflected), not asymmetrical

          ;; Variable Memory Layout - Dual Context System

          ;;
          ;; ChaosFight uses TWO memory contexts that never overlap:
          ;; 1. Admin Mode: Title, preludes, character select, falling
          ;; in, arena select, winner (GameModes 0,1,2,3,4,5,7)
          ;; 2. Game Mode: Gameplay only (GameMode 6)
          ;; CRITICAL KERNEL LIMITATION:
          ;; batariBASIC sets kernel at COMPILE TIME - cannot switch at
          ;; runtime!
          ;; Current setting: multisprite kernel (required for 4-player
          ;; gameplay)
          ;; This means ADMIN screens must work with multisprite kernel
          limitations:
          ;; - Playfield is symmetrical (repeated/reflected), not
          ;; asymmetrical
          ;; - Can still use 4-player sprite capability even on ADMIN
          ;; screens

          ;; This allows us to REDIM the same memory locations for
          ;; different
          ;; purposes depending on which screen we are on, maximizing
          ;; our limited RAM!

          ;; STANDARD RAM (Available everywhere):
          ;; a-z = 26 variables

          ;; SUPERCHIP RAM AVAILABILITY (SCRAM - accessed via separate
          ;; read/write ports):
          ;; Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z
          ;; ($d4-$ed) = 26 bytes = 74 bytes always available
          ;; SuperChip RAM (SCRAM): r000-r127/w000-w127 ($1000-$107F
          ;; physical RAM) = 128 bytes
          ;; - r000-r127: read ports at $F080-$F0FF
          ;;
          ;; - w000-w127: write ports at $F000-$F07F
          ;; - NOTE: r000-r127 and w000-w127 map to SAME physical
          ;; 128-byte SCRAM!
          ;; - NOTE: There is NO var48-var127! SuperChip RAM accessed
          ;; via r000-r127/w000-w127 only!
          ;; MULTISPRITE KERNEL BEHAVIOR:
          ;; - Playfield data is stored in ROM (ROMpf=1), NOT in RAM
          ;;
          ;; - Playfield uses ZERO bytes of SCRAM - ALL 128 bytes are
          ;; available!
          ;; - Playfield is symmetrical (repeated/reflected), not
          ;; asymmetrical like standard kernel
          ;; - This applies to ALL screens (Admin Mode and Game Mode)
          ;; TOTAL AVAILABLE RAM:
          ;; - Standard RAM: 74 bytes (var0-var47, a-z)
          ;; - SCRAM: 128 bytes (r000-r127/w000-w127) - ALL available!
          ;; - TOTAL: 202 bytes available at all times!

          ;; Common Vars (needed in both contexts):
          ;; - playerCharacter[0-3], playerLocked[0-3]
          ;; - playerCharacter[0-3], selectedArena
          ;; - QuadtariDetected
          ;; - temp1-4, qtcontroller, frame (built-ins)

          ;; REDIMMED VARIABLES (different meaning per context):
          ;; - var24-var40: Shared between Admin Mode and Game Mode
          ;; (intentional redim)
          ;; - var24-var26: Arena select (Admin) or playerVelocityXL[0-2]
          ;; (Game) - ZPRAM for physics
          ;; - var27: Arena select (Admin) or playerVelocityXL[3] (Game) - ZPRAM for physics
          ;; - var28-var35: Prelude/music (Admin) or playerVelocityY
          ;; 8.8 (Game, var28-var31=high, var32-var35=low) -
          ;; ZPRAM for physics
          ;; - var37-var40: Character select (Admin) or
          ;; playerAttackCooldown (Game) - ZPRAM
          ;; NOTE: Animation vars (animationCounter,
          ;; currentAnimationFrame, currentAnimationSeq) in SCRAM
          ;; to free zero-page space (var24-var31, var33-var36) for
          ;; frequently-accessed physics variables
          ;; - a,b,c,d: Fall animation vars (Admin Mode) or MissileX (Game Mode)
          ;; - w-z: Animation vars (Admin Mode) or missile velocities (Game Mode)
          ;; - e: console7800Detected (COMMON); missileLifetime in SCRAM w045
          ;; to avoid conflict
          ;; - selectedArena stored in SCRAM w117 to avoid redim conflict

          ;; COMMON VARS (used In BOTH Admin Mode and Game Mode)
          ;; These variables maintain their values across context
          ;; switches
          ;; NOTE: All Common vars use earliest letters/digits (a, b,
          ;; c, ..., var0, var1, var2, ...)

          ;; Built-in variables (NO DIM NEEDED - already exist in
          ;; batariBasic):
          ;; temp1, temp2, temp3, temp4, temp5, temp6 - temporary
          ;;
          ;; storage
          ;; qtcontroller - Quadtari multiplexing state (0 or 1)

          ;; COMMON VARS - Standard RAM (a-z) - Sorted Alphabetically
          
          ;; Frame counter (increments every frame in MainLoop)
          ;; Used for frame budgeting, animation timing, and other per-frame logic
          frame  = $eb

          ;; Current player index (0-3) for iteration loops
          ;; Set before calling per-player routines such as AnimationSystem or PlayerElimination
          ;; Keeps temp registers free by acting as shared loop sta

          ;; Current character index (0-31) for character logic
          ;; Loaded from playerCharacter[currentPlayer] prior to use to reduce temp reassignments
          ;; Used across SpriteLoader and other character-specific routines
          currentPlayer  = $de
          currentCharacter  = $e9

          ;; Combat system attacker/defender indices (reused every frame)
          attackerID  = $ea
          defenderID  = $ec

          ;; GetPlayerLocked helper variables (set by GetPlayerLocked function)
          GPL_playerIndex  = $ed
          GPL_lockedState  = $ee

          ;; 7800 system detection flag (must be at address $80)
          ;; $00 = 2600 console, $80 = 7800 console
          ;; Set during cold start console detection
          console7800Detected  = $80

          ;; Game state and system flags (consolidated to save RAM)
          ;; Game mode index (0-8): ModePublisherPrelude, ModeAuthorPrelude, etc.
          ;; System flags (packed byte):
          ;; bit 7: 7800 console detected (SystemFlag7800 = $80) - mirrors console7800Detected
          ;; bit 6: Color/B&W override active
          ;; (SystemFlagColorBWOverride = $40, 7800 only)
          ;; bit 5: Pause button previous state (SystemFlagPauseButtonPrev = $20)
          ;; bit 4: Game state paused (SystemFlagGameStatePaused = $10, 0=normal, 1=paused)
          ;; bit 3: Game state ending (SystemFlagGameStateEnding = $08, 0=normal, 1=ending)
          ;; Bits 0-2: Reserved for future use
          gameMode  = $eb
          systemFlags  = $e1
          ;; Packed controller status bits (controller hardware detection):
          ;; bit 7: Quadtari adapter detected ($80)
          ;; bit 0: Genesis/MegaDrive controller on left port ($01)
          ;; bit 1: Joy2b+ controller on left port ($02)
          ;; bit 2: Genesis/MegaDrive controller on right port ($04)
          ;; bit 3: Joy2b+ controller on right port ($08)
          ;; Bits 4-6: Reserved for future use
          ;; NOTE: 7800 console detection is in systemFlags (bit 7), not controllerStatus
          controllerStatus  = $e3

          ;; Frame phase counter (cycles 0-3 each frame for multi-frame operations)
          framePhase  = $e4
          ;; Animation system temporary variable
          UCA_quadtariActive  = temp5

          ;; Character selection results (set during ADMIN, read during GAME)
          ;; Player-character selection (0-31) cached across contexts
          ;; Note: playerCharacter is defined below as var48 - do not redefine here
          ;; COMMON VARS - SCRAM (r000-r127/w000-w127) - sorted
          ;; numerically
          ;; Array accessible as playerLocked[0] through playerLocked[3]
          ;; Bit-packed: 2 bits per player (4 players × 2 bits = 8 bits = 1 byte)
          ;; Bits 0-1: Player 0 locked state (0=unlocked, 1=normal, 2=handicap)
          ;; Bits 2-3: Player 1 locked sta

          ;; Bits 4-5: Player 2 locked sta

          ;; Bits 6-7: Player 3 locked sta

          ;; Use helper routines GetPlayerLocked/SetPlayerLocked (Source/Routines/PlayerLockedHelpers.bas)
          playerLocked  = $e0

          ;; Console switch handling (used in both Admin Mode and Game Mode)
          ;; Stored at w092 to keep w000-w091 dedicated to PlayerFrameBuffer sta

          ;; and game-only scratch space
          colorBWPrevious_W  = $F05C
          colorBWPrevious_R  = $F0DC

          ;; Arena selection (COMMON - used in both Admin and Game Mode)
          ;; NOTE: Must be in SCRAM since w is REDIMMED between
          ;; Admin/Game modes
          ;; Relocated to w117 to vacate low SCRAM for the player frame buffer
          selectedArena_W  = $F075
          selectedArena_R  = $F0F5

          ;; Arena Select fire button hold timer (COMMON - used in Admin Mode)
          ;; Admin Mode timer
          fireHoldTimer_W  = $F05F
          fireHoldTimer_R  = $F0DF

          ;; Random number generator 16-bit state (COMMON - optional, used by randomize routine)
          ;; CRITICAL: Must be in SCRAM, not zero-page stack area ($f0-$ff)
          ;; Located at w120/r120 (single byte, optional enhancement to rand)
          rand16_W  = $F078
          rand16_R  = $F0F8

          ;;
          ;; Music/sound POINTERS - Zero Page Memory (standard Ram)
          ;; CRITICAL: 16-bit pointers MUST be in zero page for
          ;; indirect addressing
          ;; Music and Sound never run simultaneously, so pointers can
          ;; be shared
          ;; Used in Admin Mode (music) and Game Mode (sound effects)

          ;; Music System Pointers (Admin Mode: gameMode 0-2, 7)
          ;; NOTE: Music only runs in Admin Mode, so safe to use
          ;; Song data pointer (16-bit zero page word)
          ;; Music system uses songPointer for Bank 1 voice streams (shared with soundPointer scratch)
          songPointer = $CB
          songPointerH = $CC
          ;; Voice 0 stream pointer (shared with soundEffectPointer)
          musicVoice0Pointer = $CD
          musicVoice0PointerH = $CE
          ;; Voice 1 stream pointer (shared with soundEffectPointer1)
          ;; Both music voice pointers live in zero page to allow `(pointer),y` addressing
          musicVoice1Pointer = $CF
          musicVoice1PointerH = $D0

          ;; Sound Effect System Pointers (Game Mode: gameMode 6)
          ;; Sound system reuses music voice zero-page words; music takes priority
          ;; LoadSoundPointer assigns directly to soundEffectPointer to avoid using zero-page variables in stack space ($f0-$ff)
          ;; Voice 0 active sound effect pointer (shares ZP with musicVoice0Pointer)
          soundEffectPointer = $CD
          soundEffectPointerH = $CE
          ;; Voice 1 active sound effect pointer
          ;; soundEffectPointer* words are zero page to support `(pointer),y` addressing during playback
          soundEffectPointer1 = $D1
          soundEffectPointer1H = $D2

          ;; MUSIC/SOUND FRAME COUNTERS - SCRAM (not pointers, can be
          ;; in SCRAM)
          ;; Frame counters are simple counters, not pointers, so SCRAM
          ;; is acceptable

          ;; Music System Frame Counters (SCRAM - used in Admin Mode)
          ;; Stored at w064-w065 to keep w020-w021 free for animation tables
          ;; for PlayerFrameBuffer (w000-w063)
          ;; NOTE: Overlaps with Game Mode playerSubpixelX - safe since
          ;; Admin and Game Mode never run simultaneously
          musicVoice0Frame_W  = $F040
          musicVoice0Frame_R  = $F0C0
          musicVoice1Frame_W  = $F041
          ;; Frame counters for current notes on each voice (SCRAM
          ;; acceptable)
          musicVoice1Frame_R  = $F0C1
          ;; Music system frame counter aliases (shared naming with sound system)
          ;; NOTE: voice0Frame and voice1Frame are defined as  = in 2600bas.c (before ORG)
          ;; to avoid duplicate definitions. Do not dim them here.
          ;; dim voice0Frame = musicVoice0Frame_W (commented - defined in 2600bas.c)
          ;; dim voice1Frame = musicVoice1Frame_W (commented - defined in 2600bas.c)

          ;; Music System Current Song ID and Loop Pointers (SCRAM -
          ;; used in Admin Mode)
          ;; Uses w066 to preserve w022 for game-mode specific data
          ;; PlayerFrameBuffer (w000-w063)
          currentSongID_W  = $F042
          ;; Current playing song ID (used to check if Chaotica for
          currentSongID_R = $F0C2
          ;; Initial Voice 0 pointer for looping (Chaotica only)
          musicVoice0StartPointer_W = $F043
          musicVoice0StartPointer_WL = $F044
          musicVoice0StartPointer_R = $F0C3
          musicVoice0StartPointer_RL = $F0C4
          musicVoice1StartPointer_W = $F045
          musicVoice1StartPointer_WL = $F046
          ;; Allocated at w067-w070 to keep w030/w033-w035 available for physics buffers
          ;; space for PlayerFrameBuffer
          ;; Initial Voice 1 pointer for looping (Chaotica only)
          musicVoice1StartPointer_R = $F0C5
          musicVoice1StartPointer_RL = $F0C6

          ;; Music System Envelope State (SCRAM - used in Admin Mode)
          ;; Uses w071-w074 so w036-w039 can be reused for playerSubpixelX
          ;; for playerFrameBuffer (w000-w063)
          ;; NOTE: Overlaps with Game Mode playerSubpixelY - safe since
          ;; Admin and Game Mode never run simultaneously
          ;; Admin and Game Mode never run simultaneously
          musicVoice0TargetAUDV_W  = $F047
          ;; Target AUDV value from note data (envelope calculation)
          musicVoice0TargetAUDV_R  = $F0C7
          musicVoice1TargetAUDV_R  = $F0C8
          ;; envelope calculation target
          ;; Total frames (Duration + Delay) captured when the note loaded (voice 0)
          musicVoice1TargetAUDV_W  = $F048
          ;; envelope duration tracking
          musicVoice0TotalFrames_W  = $F049
          ;; Total frames (Duration + Delay) captured when the note loaded (voice 1)
          musicVoice0TotalFrames_R  = $F0C9
          ;; envelope duration tracking
          musicVoice1TotalFrames_W  = $F04A
          ;; Note: Duration + Delay precomputes total sustain time for envelope math
          musicVoice1TotalFrames_R  = $F0CA

          ;; Sound Effect System Frame Counters (SCRAM - used in Game
          ;; Mode)
          ;; Moved from w111-w112 to avoid conflict with missileLifetime (w110-w113)
          soundEffectFrame_W  = $F064
          soundEffectFrame_R  = $F0E4
          soundEffectFrame1_W  = $F066
          ;; Located at w100 and w102 to avoid conflicts with missileLifetime and harpyLastFlapFrame
          ;; Frame counters for current sound effect notes on each
          ;; voice (SCRAM acceptable)
          ;; NOTE: w101-w104 used by harpyLastFlapFrame, so soundEffectFrame1 uses w102
          ;; (skipping w101 which is first byte of harpyLastFlapFrame array)
          soundEffectFrame1_R  = $F0E6
          ;; Sound effect frame counter aliases (shared naming with music system)
          ;; Note: voice0Frame/voice1Frame are aliases for music; sound effects use soundEffectFrame_W/R directly
          ;; No aliases needed for sound effects - they use different variable names

          ;; ADMIN MODE VARIABLES (may be re-used in Game Mode for
          ;;
          ;; other purposes)
          ;; These variables are ONLY valid on Admin Mode screens
          ;; (GameModes 0-5,7)

          ;; ADMIN MODE - Standard RAM (a-z) - Sorted Alphabetically

          ;; ADMIN: Falling animation variables (standard RAM a,b,c,d)
          ;; NOTE: These are REDIMMED in Game Mode for missileX[0-3]
          fallFrame  = $dc
          fallSpeed  = $dd
          fallComplete  = $de
          ;; ADMIN: Falling animation screen (Mode 4) variables
          activePlayers  = $df

          ;; ADMIN: Character select and title screen animation
          ;; (Standard RAM w,x,t,u,v)
          ;; NOTE: w,x are REDIMMED in Game Mode for missile velocities
          ;; NOTE: t,u,v are ADMIN-only (not used in Game Mode)
          readyCount  = $ee
          ;; ADMIN: Count of locked players
          ;; ADMIN: Animation frame counter (REDIM - conflicts with
          characterSelectAnimationTimer  = $ed
          ;; missileVelocityX in Game Mode)
          characterSelectAnimationState  = $ef
          ;; ADMIN: Current animation state (ADMIN-only, no conflict)
          characterSelectAnimationIndex  = $eb
          ;; ADMIN: Which character animating (ADMIN-only, no conflict)
          ;; ADMIN: Current frame in sequence (ADMIN-only, no conflict)
          characterSelectAnimationFrame  = $ec

          ;; ADMIN MODE - Standard RAM (var0-var47) - sorted
          ;; numerically

          ;; ADMIN: Character selection state (var37-var38)
          ;; NOTE: These are REDIMMED in Game Mode for
          ;; playerAttackCooldown
          ;; ADMIN: Currently selected character index (0-15) for
          ;; preview (REDIMMED - Game Mode uses var37 for
          ;; ADMIN: Character select variables moved to SCRAM to free var37-var40 for playerCharacter (COMMON)
          ;; NOTE: Overlaps with Game Mode characterSpecialAbility/enhancedButtonStates (w089-w090) - safe since Admin and Game never run simultaneously
          characterSelectCharacterIndex_W  = $F07A
          characterSelectCharacterIndex_R  = $F0FA
          ;; ADMIN: Which player is currently selecting (1-4)
          characterSelectPlayer_W  = $F07B
          characterSelectPlayer_R  = $F0FB

          ;; ADMIN: Arena select variables (var24-var27)
          ;; NOTE: These are REDIMMED in Game Mode for playerVelocityXL
          ;; (var24-var27)
          ;; ADMIN: Arena preview state (REDIMMED - Game Mode uses
          ;; var24 for playerVelocityXL[0])
          arenaPreviewData  = $BC
          ;; ADMIN: Cursor position (REDIMMED - Game Mode uses var25
          ;; for playerVelocityXL[1])
          arenaCursorPos_W  = $BD
          ;; ADMIN: Confirmation timer (REDIMMED - Game Mode uses var26
          ;; for playerVelocityXL[2])
          arenaConfirmTimer  = $BE

          ;; ADMIN: Prelude screen variables (var28-var32)
          ;; NOTE: These are REDIMMED in Game Mode for playerVelocityY
          ;; (8.8 fixed-point, uses var28-var35)
          ;; ADMIN: Screen timer (REDIMMED - Game Mode uses var28-var31
          preambleTimer  = $C0
          ;; for playerVelocityY high bytes)
          ;; ADMIN: Which prelude (REDIMMED - Game Mode uses var29 for
          preambleState  = $C1
          ;; playerVelocityY[1] high byte)
          ;; ADMIN: Music status (REDIMMED - Game Mode uses var30 for
          musicPlaying  = $C2
          ;; playerVelocityY[2] high byte)
          ;; ADMIN: Current note (REDIMMED - Game Mode uses var31 for
          musicPosition  = $C3
          ;; playerVelocityY[3] high byte)
          ;; ADMIN: Music frame counter (REDIMMED - Game Mode uses
          ;; var32-var35 for playerVelocityY low bytes)
          musicTimer  = $C4

          ;; ADMIN: Title screen parade (var33-var36)
          ;; NOTE: These are REDIMMED in Game Mode for
          ;; currentAnimationSeq (var33-var36, but var37-var40 for
          ;; playerAttackCooldown)
          ;; ADMIN: Parade timing (REDIMMED - Game Mode uses var33 for
          titleParadeTimer  = $C5
          ;; currentAnimationSeq[0])
          ;; ADMIN: Current parade character (REDIMMED - Game Mode uses
          titleParadeCharacter  = $C6
          ;; var34 for currentAnimationSeq[1])
          ;; ADMIN: Parade X position (REDIMMED - Game Mode uses var35
          titleParadeX  = $C7
          ;; for currentAnimationSeq[2])
          ;; ADMIN: Parade active flag (REDIMMED - Game Mode uses var36
          ;; for currentAnimationSeq[3])
          titleParadeActive  = $C8

          ;; ADMIN: Titlescreen kernel window values (runtime control)
          ;; Runtime window values for titlescreen kernel minikernels
          ;; (0=hidden, 42=visible)
          ;; These override compile-time constants if kernel supports
          ;; runtime variables
          ;; var20-var23 unused in Admin Mode - used for titlescreen
          ;; window control
          ;; ADMIN: Runtime window value for bmp_48x2_1 (AtariAge) -
          titlescreenWindow1  = $B8
          ;; 0=hidden, 42=visible
          ;; ADMIN: Runtime window value for bmp_48x2_2 (AtariAgeText)
          titlescreenWindow2  = $B9
          ;; - 0=hidden, 42=visible
          ;; ADMIN: Runtime window value for bmp_48x2_3 (ChaosFight) -
          titlescreenWindow3  = $BA
          ;; 0=hidden, 42=visible
          ;; ADMIN: Runtime window value for bmp_48x2_4 (BRP)
          ;; - 0=hidden, 42=visible
          titlescreenWindow4  = $BB
          bmp_index  = $BC

          ;; GAME MODE VARIABLES (may be re-used in Admin Mode for
          ;; other purposes)
          ;; These variables are ONLY valid on Game Mode screens
          ;; (GameMode 6)

          ;; Player data arrays using batariBasic array syntax
          ;; playerX[0-3] = player1X, player2X, player3X, player4X
          playerX  = $A4

          ;; playerY[0-3] = player1Y, player2Y, player3Y, player4Y
          playerY  = $A8

          ;; playerState[0-3] = player1State, player2State,
          ;; player3State, player4State
          ;; Packed player data: Facing (1 bit), State flags (3 bits),
          ;; Animation (4 bits)
          ;; playerState byte format:
          ;; [Animation:4][Recovery:1][Jumping:1][Guarding:1]
          ;; [Facing:1]
          ;; bit 0: Facing (1=right, 0=left)
          ;; bit 1: Guarding
          ;; bit 2: Jumping
          ;; bit 3: Recovery (hitstun)
          ;; Bits 4-7: Animation state (0-15)
          playerState  = $AC


          ;; playerHealth[0-3] = player1Health, player2Health,
          ;; player3Health, player4Health
          playerHealth  = $B0

          ;; playerCharacter[0-3] - Character type indices (0-MaxCharacter)
          ;; COMMON VAR - used in both Admin and Game Mode
          ;; Uses var37-var40 (freed by playerAttackCooldown being in SCRAM)
          ;; Must use var37-var40 (not var48) since var48-var127 don’t exist
          playerCharacter  = $C9

          ;; playerAttackType[0-3] - Attack type for each player (0=MeleeAttack, 1=RangedAttack, 2=AreaAttack)
          ;; Initialized from CharacterAttackTypes[playerCharacter[playerIndex]]
          ;; Stored in SuperChip RAM at w075-w078 (4 bytes for 4 players)
          ;; NOTE: w075 is Admin Mode only (randomSelectFlags), so free in Game Mode
          ;; w076-w077 overlap with Game Mode (playerSubpixelY_WL, animationCounter_W)
          ;; but w076-w077 are REDIMMED between modes, so OK
          playerAttackType_W  = $F04B
          playerAttackType_R  = $F0CB

          ;; PlayerFacing is extracted from playerState bit 3 (PlayerStateBitFacing)
          ;; 0=right (bit 3=1), 1=left (bit 3=0)
          ;; No separate PlayerFacing array needed - use playerState & PlayerStateBitFacing

          ;; Player sprite pointer aliases (built-in batariBASIC multisprite kernel variables)
          ;; These are aliases for the lo/hi byte pairs used by the multisprite kernel
          player1pointer  = player1pointerlo.player1pointerhi
          player2pointer  = player2pointerlo.player2pointerhi
          player3pointer  = player3pointerlo.player3pointerhi
          player4pointer  = player4pointerlo.player4pointerhi
          player5pointer  = player5pointerlo.player5pointerhi

          ;; playerRecoveryFrames[0-3] - Recovery/hitstun frame
          ;; counters
          playerRecoveryFrames  = $B4

          ;; playerVelocityX[0-3] = 8.8 fixed-point X velocity
          ;; High byte (integer part) in zero-page for fast access
          ;; every frame
          playerVelocityX  = $B8
          ;; High bytes (integer part) in zero-page var20-var23
          ;; Low bytes (fractional part) in zero-page var24-var27
          ;; (freed by moving animation vars)
          ;; Access: playerVelocityX[i] = high byte,
          ;; playerVelocityXL[i] = low byte (both in ZPRAM!)
          playerVelocityXL  = $BC

          ;; playerVelocityY[0-3] = 8.8 fixed-point Y velocity
          ;; Both high and low bytes in zero-page for fast access every
          ;; frame
          ;; Game Mode: 8.8 fixed-point Y velocity (8 bytes) -
          ;; var28-var35 in zero-page
          ;; var28-var31 = high bytes, var32-var35 = low bytes
          ;; Array accessible as playerVelocityY[0-3] and
          playerVelocityY  = $C0
          ;; playerVelocityYL[0-3] (all in ZPRAM!)
          ;; Low bytes (fractional part) in zero-page var32-var35
          ;; Access: playerVelocityY[i] = high byte (var28-var31),
          ;; playerVelocityYL[i] = low byte (var32-var35) (both in
          ;; ZPRAM!)
          playerVelocityYL  = $C4

          ;; playerSubpixelX[0-3] = 8.8 fixed-point X position
          ;; Updated every frame but accessed less frequently than
          ;; velocity, so SCRAM is acceptable
          ;; Uses w064-w071 to leave w049-w056 for playerSubpixelX (Game Mode)
          ;; for PlayerFrameBuffer (w000-w063)
          ;; NOTE: Overlaps with Admin Mode music variables (w064-w079)
          ;; -
          ;; safe since Admin and Game Mode never run simultaneously
          playerSubpixelX_W  = $F040
          ;; Game Mode: 8.8 fixed-point X position (8 bytes) - SCRAM
          ;; w064-w071 (write), r064-r071 (read)
          ;; Array accessible as playerSubpixelX_W[0-3] (high bytes) and
          ;; playerSubpixelX_WL[0-3] (low bytes) (write ports)
          ;; Array accessible as playerSubpixelX_R[0-3] (high bytes) and
          ;; playerSubpixelX_RL[0-3] (low bytes) (read ports)
          playerSubpixelX_WL  = $F044
          playerSubpixelX_R  = $F0C0
          playerSubpixelX_RL  = $F0C4

          ;; playerSubpixelY[0-3] = 8.8 fixed-point Y position
          ;; Uses w072-w079 to leave w057-w064 for shared Admin/Game allocations
          ;; for PlayerFrameBuffer (w000-w063)
          ;; NOTE: Overlaps with Admin Mode music variables (w064-w079)
          ;; -
          ;; safe since Admin and Game Mode never run simultaneously
          playerSubpixelY_W  = $F048
          ;; Game Mode: 8.8 fixed-point Y position (8 bytes) - SCRAM
          ;; w072-w079 (write), r072-r079 (read)
          ;; Array accessible as playerSubpixelY_W[0-3] (high bytes) and
          ;; playerSubpixelY_WL[0-3] (low bytes) (write ports)
          ;; Array accessible as playerSubpixelY_R[0-3] (high bytes) and
          ;; playerSubpixelY_RL[0-3] (low bytes) (read ports)
          playerSubpixelY_WL  = $F04C
          playerSubpixelY_R  = $F0C8
          playerSubpixelY_RL  = $F0CC

          ;; Shared 16-bit accumulator for subpixel math (temp2 = low byte, temp3 = high byte)
          subpixelAccumulator = temp2
          subpixelAccumulatorH = temp3

          ;; GAME MODE - Zero-page RAM (var24-var47) - sorted
          ;; numerically

          ;; Game Mode: Animation system variables (in SCRAM -
          ;; updated at 10fps, not every frame)
          ;; NOTE: Animation vars updated at 10fps (every 6 frames), so
          ;; SCRAM access cost is acceptable
          ;; Freed var24-var31 and var33-var36 (12 bytes) for physics
          ;; variables that update every frame
          animationCounter_W  = $F04D
          ;; Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame
          animationCounter_R  = $F0CD
          ;; counter (4 bytes) - SCRAM w077-w080
          currentAnimationFrame_W  = $F051
          ;; Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in
          currentAnimationFrame_R  = $F0D1
          ;; sequence (4 bytes) - SCRAM w081-w084
          currentAnimationSeq_W  = $F055
          ;; Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current
          ;; animation sequence (4 bytes) - SCRAM w085-w088
          currentAnimationSeq_R  = $F0D5

          ;; Game Mode: Attack cooldown timers
          ;; In SCRAM to free var37-var40 for playerCharacter (COMMON var)
          ;; Array accessible as playerAttackCooldown_W[0] through
          ;; playerAttackCooldown_W[3] (use _W for writes, _R for reads)
          ;; NOTE: var37-var40 now used for playerCharacter (COMMON), var37-var38 still used for characterSelect (Admin Mode)
          playerAttackCooldown_W  = $F05A
          playerAttackCooldown_R  = $F0DA

          ;; Game Mode: Additional game state variables (in SCRAM
          ;; - less performance critical)
          ;; NOTE: These are accessed infrequently (elimination/win
          ;; screen only), safe in SCRAM
          ;; Allocated in SCRAM to free ZPRAM var24-var31 for physics
          ;; animation vars
          playersRemaining_W  = $F060
          ;; Game Mode: Count of active players (SCRAM - low frequency
          playersRemaining_R  = $F0E0
          ;; access)
          gameEndTimer_W  = $F062
          gameEndTimer_R  = $F0E2
          ;; Game Mode: Countdown to game end screen (SCRAM)
          eliminationEffectTimer_W  = $F063
          ;; Game Mode: Visual effect timers (single byte, bits for
          eliminationEffectTimer_R  = $F0E3
          ;; each player) (SCRAM)
          eliminationOrder_W  = $F069
          ;; Game Mode: Order players were eliminated [0-3] (packed
          eliminationOrder_R  = $F0E9
          ;; into 4 bits) (SCRAM)
          eliminationCounter_W  = $F06A
          eliminationCounter_R  = $F0EA
          ;; Game Mode: Counter for elimination sequence (SCRAM)
          winnerPlayerIndex_W  = $F06B
          winnerPlayerIndex_R  = $F0EB
          ;; Game Mode: Index of winning player (0-3) (SCRAM)
          displayRank_W  = $F06C
          displayRank_R  = $F0EC
          ;; Game Mode: Current rank being displayed (1-4) (SCRAM)
          winScreenTimer_W  = $F06D
          winScreenTimer_R  = $F0ED
          ;; Game Mode: Winner screen countdown timer (SCRAM)
          ;;
          ;; Game Mode: Win screen display timer (SCRAM)

          ;; Issue #1177: Frooty lollipop charge system (SCRAM)
          frootyChargeTimer_W  = $F068
          frootyChargeTimer_R  = $F0E8
          ;; Frooty charge timer array [0-3] (0-30 ticks, 4 bytes: w104-w107)
          ;; NOTE: Partially overlaps with harpyLastFlapFrame[3] (w104), but Frooty and Harpy
          ;; are different characters, so no conflict
          frootyChargeState_W  = $F06C
          frootyChargeState_R  = $F0EC
          ;; Frooty charge state array [0-3] (packed: bit 7=charging, bits 0-2=frame counter 0-5, 4 bytes: w108-w111)
          ;; NOTE: Partially overlaps with displayRank (w108) and winScreenTimer (w109),
          ;; but these are only used on win screen, Frooty charge is gameplay-only

          ;; GAME MODE - Zero page RAM (a-z) - Sorted Alphabetically

          ;; Game Mode: Missile active flags - bit-packed into single
          ;; byte (standard RAM)
          ;; Format:
          ;; [M4Active:1][M3Active:1][M2Active:1][M1Active:1]
          ;; [unused:4]
          ;; bit 0 = Missile1 active, bit 1 = Missile2 active, etc.
          ;; Game Mode: Missile active flags (standard RAM)
          missileActive  = $e4

          ;; Game Mode: Missile X positions [0-3] for players 1-4
          ;; (standard RAM a,b,c,d)
          ;; NOTE: These are REDIMMED in Admin Mode for fall animation
          ;; variables
          ;; Array accessible as missileX[0] through missileX[3]
          missileX  = $dc

          ;; Game Mode: Missile lifetime counters [0-3] - frames
          ;; remaining
          ;; For mêlée attacks: small value (2-8 frames)
          ;; For ranged attacks: larger value or 255 for until
          ;; collision
          ;; Placed in SCRAM because the values are accessed infrequently
          ;; than other missile vars
          ;; NOTE: console7800Detected (COMMON) uses ’e’ in sta

          ;; RAM, missileLifetime in SCRAM to avoid conflict
          missileLifetime_W  = $F06E
          ;; Game Mode: Missile lifetime array (4 bytes) - SCRAM
          ;; w110-w113 for performance
          ;; Array accessible as missileLifetime[0] through
          ;; missileLifetime[3]
          missileLifetime_R  = $F0EE

          ;; Game Mode: Missile velocities [0-3] for × and Y axes
          ;; (standard RAM w,x)
          ;; NOTE: These are REDIMMED in Admin Mode for character
          ;; select animation
          ;; Stored velocities for bounce calculations and physics
          ;; updates
          ;; Game Mode: Missile X velocity array (4 bytes) - REDIM from
          missileVelocityX  = $ed
          ;; characterSelectAnimationTimer
          ;; Game Mode: Missile Y velocity array (4 bytes) - REDIM from
          ;; characterSelectAnimationState
          missileVelocityY  = $ee

          ;; Missile momentum stored in temp variables during
          ;; UpdateMissiles subroutine
          ;; temp1 = current player index being processed
          ;; temp2 = missileX delta (momentum)
          ;; temp3 = missileY delta (momentum)
          ;; temp4 = scratch for collision checks
          ;; These are looked up from character data each frame and
          ;; stored in missileVelocityX/Y

          ;; GAME MODE - SCRAM (r000-r127/w000-w127) - sorted
          ;; numerically

          ;; playerFrameBuffer (64-byte contiguous block for sprite
          ;; rendering)
          ;; OPTIMIZED: Allocated at w000-w063 (64 bytes) after moving
          ;; variables to higher addresses
          ;; This block is used for buffering player sprite data during
          ;; rendering operations
          ;; Physical addresses: $F000-$F03F (write ports), $F080-$F0BF
          ;; (read ports)
          playerFrameBuffer_W  = $F000
          ;; 64-byte buffer for player frame data (w000-w063)
          ;; Array accessible as playerFrameBuffer[0] through
          ;; playerFrameBuffer[63]
          playerFrameBuffer_R  = $F080

          ;; Game Mode: Missile Y positions [0-3] - using SCRAM
          ;; (SuperChip RAM)
          ;; Uses w097-w100 so w000-w063 remain dedicated to PlayerFrameBuffer
          ;; PlayerFrameBuffer
          missileY_W  = $F061
          ;; NOTE: batariBASIC uses array syntax - missileY[0] =
          ;; w097/r097, missileY[1] = w098/r098, etc.
          ;; NOTE: Must use missileY_R for reads and missileY_W for
          ;; writes to avoid RMW issues
          missileY_R  = $F0E1

          ;; Game Mode: Player timers array [0-3] - used for guard
          ;; cooldowns and other timers
          ;; SCRAM allocated since var44-var47 already used by
          ;; playerAttackCooldown
          ;; Uses w093-w096 to keep w004-w007 available for runtime buffers
          ;; for PlayerFrameBuffer (w000-w063)
          playerTimers_W  = $F05D
          ;; Game Mode: Player timers array (4 bytes) - SCRAM w093-w096
          ;; Array accessible as playerTimers[0] through
          ;; playerTimers[3]
          playerTimers_R  = $F0DD

          ;; PlayerEliminated[0-3] - bit flags for eliminated players
          ;; bit 0 = Player 1, bit 1 = Player 2, bit 2 = Player 3, bit
          ;; 3 = Player 4
          ;; Set when player health reaches 0, prevents respawn/reentry

          ;; Character-specific state flags for special mechanics
          ;; (SCRAM)
          ;; Moved from w093-w096 to avoid conflict with playerTimers
          characterStateFlags_W  = $F07C
          ;; [0]=P1, [1]=P2, [2]=P3, [3]=P4 character state bits (4
          ;; bytes: w124-w127)
          ;; bit 0: RoboTito ceiling latched
          ;; bit 1: Harpy in flight mode
          ;; bit 2: Harpy in dive mode
          ;; bit 3-7: Reserved for future character mechanics
          ;; NOTE: Shares w124-w127 with cachedHitbox - both are temp/per-frame
          ;; and never used simultaneously (cachedHitbox only during attack processing)
          characterStateFlags_R  = $F0FC

          ;; Radish Goblin bounce movement state tracking (SCRAM - Game Mode only)
          ;; Tracks bounce state and contact positions for Radish Goblin character
          ;; Uses w078-w081, w082-w085, w086-w089 (12 bytes total for 3 arrays of 4 players each)
          ;; NOTE: Overlaps with Admin Mode variables - safe since Admin and Game Mode never run simultaneously
          ;; NOTE: w085 overlaps with currentAnimationSeq - safe since Radish Goblin movement only active in Game Mode
          radishGoblinBounceState_W  = $F04E
          ;; Bounce state: 0=no bounce yet on current contact, 1=bounced
          ;; Array accessible as radishGoblinBounceState[0] through radishGoblinBounceState[3]
          radishGoblinBounceState_R  = $F0CE
          radishGoblinLastContactY_W  = $F052
          ;; Last Y position where ground contact occurred (for detecting when player leaves ground)
          ;; Array accessible as radishGoblinLastContactY[0] through radishGoblinLastContactY[3]
          ;; NOTE: w082-w085 overlaps with currentAnimationFrame (w081-w084) - safe since only one active at a time
          radishGoblinLastContactY_R  = $F0D2
          radishGoblinLastContactX_W  = $F056
          ;; Last X position where wall contact occurred (for detecting when player leaves wall)
          ;; Array accessible as radishGoblinLastContactX[0] through radishGoblinLastContactX[3]
          ;; NOTE: w086-w089 overlaps with currentAnimationSeq (w085-w088) and characterSpecialAbility (w089) - safe since only one active at a time
          radishGoblinLastContactX_R  = $F0D6

          ;; Missile angular velocity for curling stone rotation
          ;; (SCRAM)
          ;; Moved from w097 to avoid conflict with missileY (w097-w100)
          ;; RESERVED for future implementation - not currently used
          missileAngularVel_W  = $F069
          ;; [0-3] angular velocity for rotation effects (4 bytes:
          ;; w105-w108, reserved for future)
          ;; NOTE: w105-w108 partially used by eliminationOrder, but
          ;; missileAngularVel is reserved for future and not currently used
          missileAngularVel_R  = $F0E9

          ;; Missile NUSIZ tracking (SCRAM)
          ;; Tracks NUSIZ register values for each missile (0-3) to
          ;; ensure proper sizing
          missileNUSIZ_W  = $F072
          ;; [0-3] NUSIZ values for missiles M0-M3 (4 bytes: w114-w117)
          ;; Array accessible as missileNUSIZ[0] through
          ;; missileNUSIZ[3]
          missileNUSIZ_R  = $F0F2

          ;; RoboTito stretch missile height tracking (SCRAM)
          ;; Tracks missile height for RoboTito stretch visual effect
          missileStretchHeight_W  = $F076
          ;; [0-3] Missile height in scanlines for RoboTito stretch
          ;; visual
          ;; (4 bytes: w118-w121)
          ;; Height extends downward from player position to ground
          ;; level
          ;; Array accessible as missileStretchHeight[0] through
          ;; missileStretchHeight[3]
          missileStretchHeight_R  = $F0F6

          ;; Character special ability state (SCRAM)
          ;; Shared array for character-specific abilities that are mutually
          ;; exclusive per player (one player can only be one character).
          ;; For RoboTito: stores stretch permission (0=no, 1=yes) per player
          ;; For Harpy: stores flight energy (0-255) per player
          ;; For other characters: unused (available for future abilities)
          characterSpecialAbility_W  = $F059
          ;; [0-3] Special ability state for each player (4 bytes: w089-w092)
          ;; Array accessible as characterSpecialAbility[0] through
          ;; characterSpecialAbility[3]
          ;; RoboTito: characterSpecialAbility[player] = stretch permission (0 or 1)
          ;; Harpy: characterSpecialAbility[player] = flight energy (0-255)
          characterSpecialAbility_R  = $F0D9

          enhancedButtonStates_W  = $F05A
          ;; Enhanced controller button states (Genesis Button C, Joy2B+
          ;; Button II)
          ;; Only players 1-2 can have enhanced controllers (players 3-4 require Quadtari)
          ;; Bit-packed: 1 bit per eligible player (1=pressed, 0=released)
          ;; bit 0: Player 1 enhanced button, bit 1: Player 2 enhanced button
          ;; Bits 2-3: Always 0 (players 3-4 cannot have enhanced controllers)
          ;; Updated at start of each game loop frame
          ;; Moved from w123 to w090 to free w122-w125 for missileFlags
          enhancedButtonStates_R  = $F0DA

          ;; Missile flags cache (SCRAM)
          ;; Cached missile flags per player to avoid per-frame lookups
          ;; in UpdateOneMissile. Flags are set at spawn time and reused
          ;; throughout missile lifetime.
          missileFlags_W  = $F07A
          ;; [0-3] Missile flags for each player missile (4 bytes: w122-w125)
          ;; Array accessible as missileFlags[0] through missileFlags[3]
          ;; Cached from CharacterMissileFlags[] at spawn time
          missileFlags_R  = $F0FA

          ;; Last flap frame tracker for rapid tap detection (SCRAM)
          harpyLastFlapFrame_W  = $F065
          ;; [0]=P1, [1]=P2, [2]=P3, [3]=P4 last flap frame counter (4
          ;; bytes: w101-w104)
          ;; Used to detect rapid UP tapping
          ;; Array accessible as harpyLastFlapFrame[0] through
          ;; harpyLastFlapFrame[3]
          harpyLastFlapFrame_R  = $F0E5

          ;; ADMIN MODE - SCRAM (r000-r127/w000-w127) - sorted
          ;; numerically

          ;; ADMIN: Random character selection flags (SCRAM - used in
          ;; character select)
          ;; Uses w075 to keep w027 available for Admin Mode data tables
          ;; PlayerFrameBuffer (w000-w063)
          ;; NOTE: Overlaps with Game Mode variables - safe since Admin
          ;; and Game Mode never run simultaneously
          randomSelectFlags_W  = $F04B
          ;; bit 7 = handicap flag (1 if down+fire was held), bits 0-6
          ;; unused
          ;; Array accessible as randomSelectFlags[0] through
          ;; randomSelectFlags[3]
          randomSelectFlags_R  = $F0CB

          ;; ADMIN: Character select animation frame counters (SCRAM -
          ;; used in character select)
          ;; Uses w076-w079 to keep lower SCRAM addresses free for shared buffers
          ;; for PlayerFrameBuffer (w000-w063)
          ;; NOTE: Overlaps with Game Mode playerSubpixelY - safe since
          ;; Admin and Game Mode never run simultaneously
          characterSelectPlayerAnimationFrame_W  = $F04C
          ;; Frame counters for idle/walk animation cycles in character
          ;; select
          ;; Array accessible as characterSelectPlayerAnimationFrame[0] through
          ;; characterSelectPlayerAnimationFrame[3]
          characterSelectPlayerAnimationFrame_R  = $F0CC

          ;; ADMIN: Character select animation timers (SCRAM - used in
          ;; character select)
          ;; Uses w080-w083 to keep w032-w035 open for animation scratch
          ;; for PlayerFrameBuffer (w000-w063)
          ;; NOTE: Overlaps with Game Mode variables - safe since Admin
          ;; and Game Mode never run simultaneously
          ;; character select animation runs again, so safe overlap
          characterSelectPlayerAnimationTimer_W  = $F050
          ;; Animation frame delay accumulators (counts output frames
          ;; until AnimationFrameDelay)
          ;; Array accessible as characterSelectPlayerAnimationTimer[0] through
          ;; characterSelectPlayerAnimationTimer[3]
          characterSelectPlayerAnimationTimer_R  = $F0D0

          ;; TODO: #1311 / FUTURE EXPANSION

          ;; NOTE: var0-3 used by playerX (core gameplay, cannot redim)
          ;; NOTE: var4-7 used by playerY (core gameplay, cannot redim)
          ;; NOTE: var8-11 used by playerState (core gameplay, cannot redim)
          ;; NOTE: var12-15 used by playerHealth (core gameplay, cannot redim)
          ;; NOTE: var16-19 used by playerRecoveryFrames (core gameplay, cannot redim)
          ;; NOTE: var20-23 used by playerVelocityX (core gameplay, cannot redim)

          ;; GAME: Subpixel position and velocity system - IMPLEMENTED
          ;; using batariBASIC 8.8 fixed-point
          ;; NOTE: Using batariBASIC built-in 8.8 fixed-point support:
          ;; playerVelocityX: high bytes in ZPRAM (var20-var23), low
          ;; bytes in ZPRAM (var24-var27)
          ;; playerVelocityY: both high and low bytes in ZPRAM
          ;; (var28-var35)
          ;; playerSubpixelX/Y: in SCRAM (w049-w064, 16 bytes) - less
          ;; frequently accessed

          ;; TEMPORARY WORKING VARIABLES - ZERO PAGE (for temp7+
          ;; replacements)
          ;; These replace invalid temp7+ variables (only temp1-temp6
          ;; exist)
          ;; Relocated from SCRAM to vacant zero-page slots so w000-w063
          ;; remain dedicated to PlayerFrameBuffer data.
          ;; Each variable has a semantically meaningful name based on
          ;; its usage context

          oldHealthValue  = $A5
          ;; Old health value for byte-safe clamp checks (used in
          ;; damage calculations)

          recoveryFramesCalc  = $A6
          ;; Recovery frames calculation value (used in fall damage and
          ;; hit processing)

          playerStateTemp  = $A7
          ;; Temporary player state value for bit manipulation
          ;; operations

          playfieldRow  = $A9
          ;; Playfield row index for collision calculations

          playfieldColumn  = $AA
          ;; Playfield column index for collision calculations

          rowYPosition  = $AB
          ;; Game Mode: Y position of playfield row (used in gravity calculations)
          winScreenCandidateOrder  = $AB
          ;; Admin Mode: Winner screen elimination order candidate
          ;; (shares rowYPosition RAM in Admin Mode)

          rowCounter  = $AD
          ;; Game Mode: Loop counter for row calculations
          winScreenThirdPlaceOrder  = $AD
          ;; Admin Mode: Winner screen third-place elimination order
          ;; (shares rowCounter RAM in Admin Mode)

          characterHeight  = $AE
          ;; Character height value from CharacterHeights table

          characterWeight  = $AF
          ;; Character weight value from CharacterWeights table

          yDistance  = $B1
          ;; Y distance between players for collision calculations

          halfHeight1  = $B2
          ;; Half height of first player for collision overlap calculation

          halfHeight2  = $B3
          ;; Half height of second player for collision overlap calculation

          totalHeight  = $B5
          ;; Total height for collision overlap check (halfHeight1 + halfHeight2)

          totalWeight  = $B6
          ;; Total weight of both players for momentum calculations

          weightDifference  = $B7
          ;; Weight difference between players for impulse calculation

          impulseStrength  = $CC
          ;; Impulse strength for knockback momentum calculation

          ;; Original player positions and distance for collision nudging (SCRAM)
          ;; Moved from w114-w116 to avoid conflict with missileNUSIZ (w114-w117)
          originalPlayerX_W  = $F067
          ;; Original player X position for collision checking and nudging
          originalPlayerX_R  = $F0E7

          originalPlayerY_W  = $F068
          ;; Original player Y position for collision checking and nudging
          ;; NOTE: w104 partially overlaps with harpyLastFlapFrame (w101-w104),
          ;; but originalPlayerY only needs 1 byte (w104), and harpyLastFlapFrame
          ;; uses w101-w104 as an array. These should not conflict if we verify
          ;; originalPlayerY is only used when harpyLastFlapFrame is not in use.
          originalPlayerY_R  = $F0E8

          distanceUp_W  = $F069
          ;; Distance to move player upward toward target
          ;; NOTE: w105 partially overlaps with eliminationOrder (w105), but distanceUp
          ;; is only a single byte and eliminationOrder is an array. Verify no conflict.
          distanceUp_R  = $F0E9

          gravityRate  = $CE
          ;; Gravity acceleration rate (normal or reduced)

          damageWeightProduct  = $D0
          ;; Intermediate value: damage × weight (used in fall damage
          ;; calculations)

          missileLifetimeValue  = $e2
          ;; Missile lifetime value from CharacterMissileLifetime table

          characterMovementSpeed  = $e6
          ;; Character movement speed value from CharacterMovementSpeed table
          ;; (temporary calculation variable for movement routines)

          missileVelocityXCalc  = $e7
          ;; Missile X velocity for friction calculations (temporary
          ;; calculation variable)

          velocityCalculation  = $e5
          ;; Velocity calculation temporary variable for friction and impulse calculations

          soundEffectID_W  = $F077
          soundEffectID_R  = $F0F7
          ;; Sound effect ID for playback (SCRAM - moved from z to avoid stack space $f0)
          ;; NOTE: w119 is part of missileStretchHeight array (w118-w121) but soundEffectID
          ;; is only used during sound playback, not during missile rendering, so safe to share

          characterIndex  = $e8
          ;; Character index for table lookups

          aoeOffset  = $ed
          ;; AOE offset value from CharacterAOEOffsets table

          healthBarRemainder  = $ee
          ;; Health bar remainder calculation (for displaying partial
          ;; bars)

          ;; Cached hitbox for current attacker (SCRAM) - calculated
          ;; once
          ;; per attacker to avoid redundant calculations
          ;; When processing an attacker, we check against 3 defenders,
          ;; so caching saves 2 redundant hitbox calculations per
          ;; attacker
          ;; Uses 4 bytes: left, right, top, bottom for current attacker
          cachedHitboxLeft_W  = $F07C
          cachedHitboxLeft_R  = $F0FC
          cachedHitboxRight_W  = $F07D
          cachedHitboxRight_R  = $F0FD
          cachedHitboxTop_W  = $F07E
          cachedHitboxTop_R  = $F0FE
          cachedHitboxBottom_W  = $F07F
          ;; Single hitbox cache (4 bytes total) - reused for each
          ;; attacker
          cachedHitboxBottom_R  = $F0FF

          ;; Hitbox calculation variables (global, used in Combat.bas)
          ;; These are set by CalculateAttackHitbox and immediately
          ;; copied to cached versions
          ;; NOTE: Since CalculateAttackHitbox is only called from
          ;; ProcessAttackerAttacks,
          ;; and the values are immediately copied to cached
          ;; versions, we can alias
          ;; the hitbox variables directly to the cached versions to
          ;; save memory.
          ;; This avoids needing separate storage since they’re never
          ;; used simultaneously.
          ;; Hitbox bounds for attack collision detection (aliased to
          ;; cached versions)
          ;; NOTE: CalculateAttackHitbox sets these, then
          ;; ProcessAttackerAttacks uses them.
          ;; Since they’re immediately copied (no-op since aliased),
          ;; this is safe.

          ;; Hit detection flag (used in Combat.bas)
          hit  = $D2

          ;; Animation system temporary (used in AnimationSystem.bas)
          C6E_stateFlags  = $D1

          ;; Sound effect parameter (used in TriggerEliminationEffects.bas)
          ;; temp1 is used directly for sound ID

          ;; Scratch relocation summary:
          ;; • Zero page now hosts the temp7+ replacements above
          ;; • SCRAM below w064 is reserved exclusively for PlayerFrameBuffer
          ;; batariBASIC automatically handles carry operations for 8.8
          ;; fixed-point arithmetic
