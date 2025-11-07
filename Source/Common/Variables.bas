          rem ChaosFight - Source/Common/Variables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem MEMORY LAYOUT - MULTISPRITE KERNEL WITH SUPERCHIP:
          rem - Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z
          rem   ($d4-$ed) = 26 bytes = 74 bytes always available
          rem - SuperChip RAM (SCRAM): Accessed via r000-r127/w000-w127
          rem   ($1000-$107F physical RAM) = 128 bytes
          rem NOTE: There is NO var48-var127! SuperChip RAM is accessed
          rem   via r000-r127/w000-w127 only!
          rem - MULTISPRITE KERNEL: Playfield data is stored in ROM (not
          rem   RAM), so playfield uses ZERO bytes of RAM
          rem This means ALL 128 bytes of SCRAM (r000-r127/w000-w127)
          rem
          rem   are available at all times!
          rem NOTE: Multisprite playfield is symmetrical
          rem   (repeated/reflected), not asymmetrical

          rem Variable Memory Layout - Dual Context System
          
          rem
          rem ChaosFight uses TWO memory contexts that never overlap:
          rem 1. Admin Mode: Title, preludes, character select, falling
          rem   in, arena select, winner (GameModes 0,1,2,3,4,5,7)
          rem   2. Game Mode: Gameplay only (GameMode 6)
          rem CRITICAL KERNEL LIMITATION:
          rem batariBASIC sets kernel at COMPILE TIME - cannot switch at
          rem   runtime!
          rem Current setting: multisprite kernel (required for 4-player
          rem   gameplay)
          rem This means ADMIN screens must work with multisprite kernel
          rem   limitations:
          rem - Playfield is symmetrical (repeated/reflected), not
          rem   asymmetrical
          rem - Can still use 4-player sprite capability even on ADMIN
          rem   screens

          rem This allows us to REDIM the same memory locations for
          rem   different
          rem purposes depending on which screen we are on, maximizing
          rem   our limited RAM!
          
          rem STANDARD RAM (Available everywhere):
          rem   a-z = 26 variables
          
          rem SUPERCHIP RAM AVAILABILITY (SCRAM - accessed via separate
          rem   read/write ports):
          rem Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z
          rem   ($d4-$ed) = 26 bytes = 74 bytes always available
          rem SuperChip RAM (SCRAM): r000-r127/w000-w127 ($1000-$107F
          rem   physical RAM) = 128 bytes
          rem     - r000-r127: read ports at $F080-$F0FF
          rem   
          rem     - w000-w127: write ports at $F000-$F07F
          rem - NOTE: r000-r127 and w000-w127 map to SAME physical
          rem   128-byte SCRAM!
          rem - NOTE: There is NO var48-var127! SuperChip RAM accessed
          rem   via r000-r127/w000-w127 only!
          rem   MULTISPRITE KERNEL BEHAVIOR:
          rem - Playfield data is stored in ROM (ROMpf=1), NOT in RAM
          rem
          rem - Playfield uses ZERO bytes of SCRAM - ALL 128 bytes are
          rem   available!
          rem - Playfield is symmetrical (repeated/reflected), not
          rem   asymmetrical like standard kernel
          rem - This applies to ALL screens (Admin Mode and Game Mode)
          rem   TOTAL AVAILABLE RAM:
          rem     - Standard RAM: 74 bytes (var0-var47, a-z)
          rem - SCRAM: 128 bytes (r000-r127/w000-w127) - ALL available!
          rem     - TOTAL: 202 bytes available at all times!
          
          rem Common Vars (needed in both contexts):
          rem   - playerChar[0-3], playerLocked[0-3]
          rem   - selectedChar1-4, selectedArena
          rem   - QuadtariDetected
          rem   - temp1-4, qtcontroller, frame (built-ins)
          
          rem REDIMMED VARIABLES (different meaning per context):
          rem - var24-var40: Shared between Admin Mode and Game Mode
          rem   (intentional redim)
          rem - var24-var27: Arena select (Admin) or playerVelocityXL
          rem   (Game) - ZPRAM for physics
          rem - var28-var35: Prelude/music (Admin) or playerVelocityY
          rem   8.8 (Game, var28-var31=high, var32-var35=low) -
          rem   ZPRAM for physics
          rem - var37-var40: Character select (Admin) or
          rem   playerAttackCooldown (Game) - ZPRAM
          rem NOTE: Animation vars (animationCounter,
          rem currentAnimationFrame, currentAnimationSeq) moved to SCRAM
          rem to free zero-page space (var24-var31, var33-var36) for
          rem   frequently-accessed physics variables
          rem - a,b,c,d: Fall animation vars (Admin Mode) or MissileX
          rem   (Game Mode)
          rem - w-z: Animation vars (Admin Mode) or Missile velocities
          rem   (Game Mode)
          rem - e: console7800Detected (COMMON) - missileLifetime moved
          rem
          rem   to SCRAM w045 to avoid conflict
          rem - selectedArena: Moved from w to w014 (SCRAM) to avoid
          rem   redim conflict
          
          rem COMMON VARS (used In BOTH Admin Mode And Game Mode)
          rem These variables maintain their values across context
          rem   switches
          rem NOTE: All Common vars use earliest letters/digits (a, b,
          rem   c, ..., var0, var1, var2, ...)
          
          rem Built-in variables (NO DIM NEEDED - already exist in
          rem   batariBasic):
          rem temp1, temp2, temp3, temp4, temp5, temp6 - temporary
          rem
          rem   storage
          rem   qtcontroller - Quadtari multiplexing state (0 or 1)
          rem   frame - frame counter (increments every frame)
          
          rem COMMON VARS - Standard RAM (a-z) - Sorted Alphabetically

          dim currentPlayer = c : rem Current iteration variables (used in loops across routines)
          rem Current player index (0-3) for iteration loops
          rem Set before calling functions that operate on a single
          rem player
          rem Used extensively in AnimationSystem, PlayerElimination,
          dim currentCharacter = n : rem   MovementSystem, and other routines
          rem Current character index (0-31) for character-specific
          rem operations
          rem Set from playerChar[currentPlayer] before character
          rem operations
          rem Used in SpriteLoader, character-specific logic, etc.
          rem Reduces temp variable pressure by eliminating parameter
          rem passing
          
          dim gameMode = p : rem Game state and system flags (consolidated to save RAM)
          dim systemFlags = f : rem Game mode index (0-8): ModePublisherPrelude, ModeAuthorPrelude, etc.
          rem System flags (packed byte):
          rem   Bit 7: 7800 console detected (SystemFlag7800 = $80)
          rem   Bit 6: Color/B&W override active
          rem   (SystemFlagColorBWOverride = $40, 7800 only)
          rem   Bit 5: Pause button previous state
          rem   (SystemFlagPauseButtonPrev = $20)
          rem   Bit 4: Game state paused (SystemFlagGameStatePaused =
          rem   $10, 0=normal, 1=paused)
          rem   Bit 3: Game state ending (SystemFlagGameStateEnding =
          rem   $08, 0=normal, 1=ending)
          rem   Bits 0-2: Reserved for future use
          rem NOTE: Previously separate variables (console7800Detected,
          rem colorBWOverride,
          dim controllerStatus = h : rem   pauseButtonPrev, gameState) are now consolidated into this byte
          rem Packed controller status bits: $80=Quadtari,
          rem   $01=LeftGenesis, $02=LeftJoy2b+, $04=RightGenesis,
          rem   $08=RightJoy2b+
          rem HandicapMode - defined locally in CharacterSelect.bas as
          rem   temp1 (local scope only)
          
          rem Character selection results (set during ADMIN, read during
          dim playerChar = j : rem   GAME)
          dim playerDamage_W = w067 : rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using j,k,l,m
          dim playerDamage_R = r067
          dim playerDamage = playerDamage_W
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 base damage per player
          rem (4 bytes: w067-w070) - SCRAM for low-frequency access
          rem Moved from w050-w053 to w067-w070 to avoid conflict with
          rem   playerSubpixelX[0-3] (w049-w056) in Game Mode
          dim playerLocked = e : rem Array accessible as playerDamage[0] through playerDamage[3]
          rem Bit-packed: 2 bits per player (4 players × 2 bits = 8 bits
          rem = 1 byte)
          rem Bits 0-1: Player 0 locked state (0=unlocked, 1=normal,
          rem 2=handicap)
          rem Bits 2-3: Player 1 locked state
          rem Bits 4-5: Player 2 locked state
          rem Bits 6-7: Player 3 locked state
          rem NOTE: Use helper functions GetPlayerLocked/SetPlayerLocked
          rem to access
          rem   (see Source/Routines/PlayerLockedHelpers.bas)
          dim selectedChar1 = s : rem Previously used 4 bytes (n,o,p,q) - now consolidated to 1 byte (e)
          rem selectedChar2, selectedChar3, and selectedChar4 moved to
          rem   SuperChip RAM to avoid conflicts
          rem OPTIMIZED: Moved from w001-w003 to w084-w086 to free space
          rem   for PlayerFrameBuffer (w000-w063)
          rem NOTE: These are REDIMMED with Admin Mode char select anim
          rem   variables - safe since selectedChar* are only read once
          rem   at
          dim selectedChar2_W = w084 : rem   game start (BeginGameLoop), then copied to PlayerChar array
          dim selectedChar2_R = r084
          dim selectedChar3_W = w085
          dim selectedChar3_R = r085
          dim selectedChar4_W = w086
          dim selectedChar4_R = r086
          rem COMMON VARS - SCRAM (r000-r127/w000-w127) - sorted
          rem   numerically
          
          rem Console switch handling (used in both Admin Mode and Game
          rem   Mode)
          rem OPTIMIZED: Moved from w008 to w012 to free space for
          dim colorBWPrevious_W = w012 : rem   PlayerFrameBuffer (w000-w063)
          dim colorBWPrevious_R = r012
          
          rem Arena selection (COMMON - used in both Admin and Game
          rem   Mode)
          rem NOTE: Must be in SCRAM since w is REDIMMED between
          rem   Admin/Game modes
          rem NOTE: w010 is used by harpyFlightEnergy array, so using
          dim selectedArena_W = w014 : rem   w014 instead
          dim selectedArena_R = r014
          
          rem Arena Select fire button hold timer (COMMON - used in
          dim fireHoldTimer_W = w015 : rem   Admin Mode)
          dim fireHoldTimer_R = r015
          
          rem
          rem Music/sound POINTERS - Zero Page Memory (standard Ram)
          rem CRITICAL: 16-bit pointers MUST be in zero page for
          rem   indirect addressing
          rem Music and Sound never run simultaneously, so pointers can
          rem   be shared
          rem Used in Admin Mode (music) and Game Mode (sound effects)
          
          rem Music System Pointers (Admin Mode: gameMode 0-2, 7)
          rem NOTE: Music only runs in Admin Mode, so safe to use
          dim songPointerL = var39 : rem   var39-var44
          dim songPointerH = var40
          rem Song data pointer low/high bytes (in Songs bank) - zero
          dim musicVoice0PointerL = var41 : rem   page
          dim musicVoice0PointerH = var42
          rem Voice 0 stream position low/high bytes (high byte = 0
          dim musicVoice1PointerL = var43 : rem   means inactive) - zero page
          dim musicVoice1PointerH = var44
          rem Voice 1 stream position low/high bytes (high byte = 0
          rem   means inactive) - zero page
          
          rem Sound Effect System Pointers (Game Mode: gameMode 6)
          rem NOTE: Must avoid var40 (currentAnimationSeq) and var44
          rem   (playerAttackCooldown[0])
          rem Uses var39, var41 (shared with Music), y,z,var45,var46
          rem Voice 0: var39+var41 (shared), SCRAM for high bytes
          dim soundPointerL = var39 : rem Voice 1: var45+var46 for pointers (zero page)
          dim soundPointerH_W = w048
          dim soundPointerH_R = r048
          dim soundPointerH = soundPointerH_W
          rem Sound data pointer low/high bytes (in Sounds bank) - low
          rem byte
          rem   in zero page (var39), high byte in SCRAM (w048/r048)
          dim soundEffectPointerL = var41 : rem   Moved to SCRAM to avoid conflict with charSelectAnimIndex (y)
          dim soundEffectPointerH_W = w066
          dim soundEffectPointerH_R = r066
          dim soundEffectPointerH = soundEffectPointerH_W
          rem Sound effect Voice 0 stream position low/high bytes (high
          rem   byte = 0 means inactive) - low byte in zero page
          rem   (var41),
          rem   high byte in SCRAM (w066/r066)
          dim soundEffectPointer1L = var45 : rem   Moved to SCRAM to avoid conflict with charSelectAnimFrame (z)
          dim soundEffectPointer1H = var46
          rem Sound effect Voice 1 stream position low/high bytes (high
          rem   byte = 0 means inactive) - zero page
          
          rem MUSIC/SOUND FRAME COUNTERS - SCRAM (not pointers, can be
          rem   in SCRAM)
          rem Frame counters are simple counters, not pointers, so SCRAM
          rem   is acceptable
          
          rem Music System Frame Counters (SCRAM - used in Admin Mode)
          rem OPTIMIZED: Moved from w020-w021 to w064-w065 to free space
          rem   for PlayerFrameBuffer (w000-w063)
          rem NOTE: Overlaps with Game Mode playerSubpixelX - safe since
          dim musicVoice0Frame_W = w064 : rem   Admin and Game Mode never run simultaneously
          dim musicVoice0Frame_R = r064
          dim musicVoice0Frame = musicVoice0Frame_W
          dim musicVoice1Frame_W = w065
          dim musicVoice1Frame_R = r065
          dim musicVoice1Frame = musicVoice1Frame_W
          rem Frame counters for current notes on each voice (SCRAM
          rem   acceptable)
          
          rem Music System Current Song ID and Loop Pointers (SCRAM -
          rem   used in Admin Mode)
          rem OPTIMIZED: Moved from w022 to w066 to free space for
          dim currentSongID_W = w066 : rem   PlayerFrameBuffer (w000-w063)
          dim currentSongID_R = r066
          rem Current playing song ID (used to check if Chaotica for
          dim musicVoice0StartPointerL_W = w067 : rem   looping)
          dim musicVoice0StartPointerL_R = r067
          dim musicVoice0StartPointerL = musicVoice0StartPointerL_W
          dim musicVoice0StartPointerH_W = w068
          dim musicVoice0StartPointerH_R = r068
          dim musicVoice0StartPointerH = musicVoice0StartPointerH_W
          dim musicVoice1StartPointerL_W = w069 : rem Initial Voice 0 pointer for looping (Chaotica only)
          dim musicVoice1StartPointerL_R = r069
          dim musicVoice1StartPointerL = musicVoice1StartPointerL_W
          dim musicVoice1StartPointerH_W = w070
          dim musicVoice1StartPointerH_R = r070
          dim musicVoice1StartPointerH = musicVoice1StartPointerH_W
          rem OPTIMIZED: Moved from w030/w033-w035 to w067-w070 to free
          rem   space for PlayerFrameBuffer
          rem Initial Voice 1 pointer for looping (Chaotica only)
          
          rem Music System Envelope State (SCRAM - used in Admin Mode)
          rem OPTIMIZED: Moved from w036-w039 to w071-w074 to free space
          rem   for PlayerFrameBuffer (w000-w063)
          rem NOTE: Overlaps with Game Mode playerSubpixelY - safe since
          dim MusicVoice0TargetAUDV_W = w071 : rem   Admin and Game Mode never run simultaneously
          dim MusicVoice0TargetAUDV_R = r071
          rem Target AUDV value from note data (for envelope
          dim MusicVoice1TargetAUDV_W = w072 : rem   calculation)
          dim MusicVoice1TargetAUDV_R = r072
          rem Target AUDV value from note data (for envelope
          dim MusicVoice0TotalFrames_W = w073 : rem   calculation)
          dim MusicVoice0TotalFrames_R = r073
          rem Total frames (Duration + Delay) when note was loaded (for
          dim MusicVoice1TotalFrames_W = w074 : rem   envelope calculation)
          dim MusicVoice1TotalFrames_R = r074
          rem Total frames (Duration + Delay) when note was loaded (for
          rem   envelope calculation)
          
          rem Sound Effect System Frame Counters (SCRAM - used in Game
          dim soundEffectFrame_W = w046 : rem   Mode)
          dim soundEffectFrame_R = r046
          dim soundEffectFrame = soundEffectFrame_W
          dim soundEffectFrame1_W = w047
          dim soundEffectFrame1_R = r047
          dim soundEffectFrame1 = soundEffectFrame1_W
          rem Moved from w022/w024 to w046/w047 to avoid conflicts
          rem Frame counters for current sound effect notes on each
          rem   voice (SCRAM acceptable)

          rem ADMIN MODE VARIABLES (may be re-used in Game Mode for
          rem
          rem   other purposes)
          rem These variables are ONLY valid on Admin Mode screens
          rem   (GameModes 0-5,7)
          
          rem ADMIN MODE - Standard RAM (a-z) - Sorted Alphabetically
          
          rem ADMIN: Falling animation variables (standard RAM a,b,c,d)
          rem NOTE: These are REDIMMED in Game Mode for missileX[0-3]
          dim fallFrame = a
          dim fallSpeed = b
          dim fallComplete = c
          dim activePlayers = d
          rem ADMIN: Falling animation screen (Mode 4) variables

          rem ADMIN: Character select and title screen animation
          rem   (Standard RAM w,x,t,u,v)
          rem NOTE: w,x are REDIMMED in Game Mode for missile velocities
          rem NOTE: t,u,v are ADMIN-only (not used in Game Mode)
          dim readyCount = x               
          dim charSelectAnimTimer = w : rem ADMIN: Count of locked players
          rem ADMIN: Animation frame counter (REDIM - conflicts with
          dim charSelectAnimState = t : rem   missileVelocityX in Game Mode)
          dim charSelectAnimIndex = u : rem ADMIN: Current animation state (ADMIN-only, no conflict)
          dim charSelectAnimFrame = v : rem ADMIN: Which character animating (ADMIN-only, no conflict)
          rem ADMIN: Current frame in sequence (ADMIN-only, no conflict)
          
          rem ADMIN MODE - Standard RAM (var0-var47) - sorted
          rem   numerically
          
          rem ADMIN: Character selection state (var37-var38)
          rem NOTE: These are REDIMMED in Game Mode for
          dim charSelectCharIndex = var37 : rem   playerAttackCooldown
          rem ADMIN: Currently selected character index (0-15) for
          rem   preview (REDIMMED - Game Mode uses var37 for
          dim charSelectPlayer = var38 : rem   playerAttackCooldown[0])
          rem ADMIN: Which player is currently selecting (1-4) (REDIMMED
          rem   - Game Mode uses var38 for playerAttackCooldown[1])
          
          rem ADMIN: Arena select variables (var24-var27)
          rem NOTE: These are REDIMMED in Game Mode for animationCounter
          dim arenaPreviewData = var24 : rem   (var24-var27)
          rem ADMIN: Arena preview state (REDIMMED - Game Mode uses
          dim arenaScrollOffset = var25 : rem   var24 for animationCounter[0])
          rem ADMIN: Scroll position (REDIMMED - Game Mode uses var25
          dim arenaCursorPos = var26 : rem   for animationCounter[1])
          rem ADMIN: Cursor position (REDIMMED - Game Mode uses var26
          dim arenaConfirmTimer = var27 : rem   for animationCounter[2])
          rem ADMIN: Confirmation timer (REDIMMED - Game Mode uses var27
          rem   for animationCounter[3])

          rem ADMIN: Prelude screen variables (var28-var32)
          rem NOTE: These are REDIMMED in Game Mode for playerVelocityY
          dim preambleTimer = var28 : rem   (8.8 fixed-point, uses var28-var35)
          rem ADMIN: Screen timer (REDIMMED - Game Mode uses var28-var31
          dim preambleState = var29 : rem   for playerVelocityY high bytes)
          rem ADMIN: Which prelude (REDIMMED - Game Mode uses var29 for
          dim musicPlaying = var30 : rem   playerVelocityY[1] high byte)
          rem ADMIN: Music status (REDIMMED - Game Mode uses var30 for
          dim musicPosition = var31 : rem   playerVelocityY[2] high byte)
          rem ADMIN: Current note (REDIMMED - Game Mode uses var31 for
          dim musicTimer = var32 : rem   playerVelocityY[3] high byte)
          rem ADMIN: Music frame counter (REDIMMED - Game Mode uses
          rem   var32-var35 for playerVelocityY low bytes)

          rem ADMIN: Title screen parade (var33-var36)
          rem NOTE: These are REDIMMED in Game Mode for
          rem   currentAnimationSeq (var33-var36, but var37-var40 for
          dim titleParadeTimer = var33 : rem   playerAttackCooldown)
          rem ADMIN: Parade timing (REDIMMED - Game Mode uses var33 for
          dim titleParadeChar = var34 : rem   currentAnimationSeq[0])
          rem ADMIN: Current parade character (REDIMMED - Game Mode uses
          dim titleParadeX = var35 : rem   var34 for currentAnimationSeq[1])
          rem ADMIN: Parade X position (REDIMMED - Game Mode uses var35
          dim titleParadeActive = var36 : rem   for currentAnimationSeq[2])
          rem ADMIN: Parade active flag (REDIMMED - Game Mode uses var36
          rem   for currentAnimationSeq[3])
          
          rem ADMIN: Titlescreen kernel window values (runtime control)
          rem Runtime window values for titlescreen kernel minikernels
          rem   (0=hidden, 42=visible)
          rem These override compile-time constants if kernel supports
          rem   runtime variables
          rem var20-var23 unused in Admin Mode - used for titlescreen
          dim titlescreenWindow1 = var20 : rem   window control
          rem ADMIN: Runtime window value for bmp_48x2_1 (AtariAge) -
          dim titlescreenWindow2 = var21 : rem 0=hidden, 42=visible
          rem ADMIN: Runtime window value for bmp_48x2_2 (AtariAgeText)
          dim titlescreenWindow3 = var22 : rem - 0=hidden, 42=visible
          rem ADMIN: Runtime window value for bmp_48x2_3 (ChaosFight) -
          dim titlescreenWindow4 = var23 : rem 0=hidden, 42=visible
          rem ADMIN: Runtime window value for bmp_48x2_4 (BRP)
          rem   - 0=hidden, 42=visible
          
          rem GAME MODE VARIABLES (may be re-used in Admin Mode for
          rem   other purposes)
          rem These variables are ONLY valid on Game Mode screens
          rem   (GameMode 6)

          rem Player data arrays using batariBasic array syntax
          dim playerX = var0 : rem playerX[0-3] = player1X, player2X, player3X, player4X
          dim player1X = var0
          dim player2X = var1
          dim player3X = var2
          dim player4X = var3
          
          dim playerY = var4 : rem playerY[0-3] = player1Y, player2Y, player3Y, player4Y
          dim player1Y = var4
          dim player2Y = var5
          dim player3Y = var6
          dim player4Y = var7
          
          rem playerState[0-3] = player1State, player2State,
          rem   player3State, player4State
          rem Packed player data: Facing (1 bit), State flags (3 bits),
          rem   Animation (4 bits)
          rem playerState byte format:
          rem   [Animation:4][Recovery:1][Jumping:1][Guarding:1]
          rem   [Facing:1]
          rem   Bit 0: Facing (1=right, 0=left)
          rem   Bit 1: Guarding
          rem   Bit 2: Jumping
          rem   Bit 3: Recovery (hitstun)
          dim playerState = var8 : rem   Bits 4-7: Animation state (0-15)
          dim player1State = var8
          dim player2State = var9
          dim player3State = var10
          dim player4State = var11
          
          rem playerHealth[0-3] = player1Health, player2Health,
          dim playerHealth = var12 : rem   player3Health, player4Health
          dim player1Health = var12
          dim player2Health = var13
          dim player3Health = var14
          dim player4Health = var15

          rem playerRecoveryFrames[0-3] - Recovery/hitstun frame
          dim playerRecoveryFrames = var16 : rem   counters
          dim player1RecoveryFrames = var16
          dim player2RecoveryFrames = var17
          dim player3RecoveryFrames = var18
          dim player4RecoveryFrames = var19
          
          rem playerVelocityX[0-3] = 8.8 fixed-point X velocity
          rem High byte (integer part) in zero-page for fast access
          dim playerVelocityX = var20 : rem   every frame
          dim player1VelocityX = var20
          dim player2VelocityX = var21
          dim player3VelocityX = var22
          dim player4VelocityX = var23
          dim playerVelocityXL = var24 : rem High bytes (integer part) in zero-page var20-var23
          rem Low bytes (fractional part) in zero-page var24-var27
          rem   (freed by moving animation vars)
          rem Access: playerVelocityX[i] = high byte,
          rem   playerVelocityXL[i] = low byte (both in ZPRAM!)
          
          rem playerVelocityY[0-3] = 8.8 fixed-point Y velocity
          rem Both high and low bytes in zero-page for fast access every
          dim playerVelocityY = var28.8.8 : rem   frame
          rem Game Mode: 8.8 fixed-point Y velocity (8 bytes) -
          rem   var28-var35 in zero-page
          rem var28-var31 = high bytes, var32-var35 = low bytes
          rem Array accessible as playerVelocityY[0-3] and
          dim playerVelocityYL = var32 : rem   playerVelocityYL[0-3] (all in ZPRAM!)
          rem Low bytes (fractional part) in zero-page var32-var35
          rem Access: playerVelocityY[i] = high byte (var28-var31),
          rem   playerVelocityYL[i] = low byte (var32-var35) (both in
          rem   ZPRAM!)
          
          rem playerSubpixelX[0-3] = 8.8 fixed-point X position
          rem Updated every frame but accessed less frequently than
          rem   velocity, so SCRAM is acceptable
          rem OPTIMIZED: Moved from w049-w056 to w064-w071 to free space
          rem   for PlayerFrameBuffer (w000-w063)
          rem NOTE: Overlaps with Admin Mode music variables (w064-w079)
          rem -
          dim playerSubpixelX_W = w064.8.8 : rem   safe since Admin and Game Mode never run simultaneously
          dim playerSubpixelX_R = r064.8.8
          rem Game Mode: 8.8 fixed-point X position (8 bytes) - SCRAM
          rem   w064-w071 (write), r064-r071 (read)
          rem Array accessible as playerSubpixelX_W[0-3] and
          rem   playerSubpixelX_WL[0-3] (write ports)
          rem Array accessible as playerSubpixelX_R[0-3] and
          rem   playerSubpixelX_RL[0-3] (read ports)
          dim playerSubpixelX = playerSubpixelX_W : rem Alias for backward compatibility (defaults to write port)
          dim playerSubpixelXL = playerSubpixelX_WL
          
          rem playerSubpixelY[0-3] = 8.8 fixed-point Y position
          rem OPTIMIZED: Moved from w057-w064 to w072-w079 to free space
          rem   for PlayerFrameBuffer (w000-w063)
          rem NOTE: Overlaps with Admin Mode music variables (w064-w079)
          rem -
          dim playerSubpixelY_W = w072.8.8 : rem   safe since Admin and Game Mode never run simultaneously
          dim playerSubpixelY_R = r072.8.8
          rem Game Mode: 8.8 fixed-point Y position (8 bytes) - SCRAM
          rem   w072-w079 (write), r072-r079 (read)
          rem Array accessible as playerSubpixelY_W[0-3] and
          rem   playerSubpixelY_WL[0-3] (write ports)
          rem Array accessible as playerSubpixelY_R[0-3] and
          rem   playerSubpixelY_RL[0-3] (read ports)
          dim playerSubpixelY = playerSubpixelY_W : rem Alias for backward compatibility (defaults to write port)
          dim playerSubpixelYL = playerSubpixelY_WL
          
          rem GAME MODE - Standard RAM (var24-var47) - sorted
          rem   numerically
          
          rem Game Mode: Animation system variables (moved to SCRAM -
          rem   updated at 10fps, not every frame)
          rem NOTE: Animation vars updated at 10fps (every 6 frames), so
          rem   SCRAM access cost is acceptable
          rem Freed var24-var31 and var33-var36 (12 bytes) for physics
          dim animationCounter_W = w077 : rem   variables that update every frame
          dim animationCounter_R = r077
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame
          dim currentAnimationFrame_W = w081 : rem   counter (4 bytes) - SCRAM w077-w080
          dim currentAnimationFrame_R = r081
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in
          dim currentAnimationSeq_W = w085 : rem   sequence (4 bytes) - SCRAM w081-w084
          dim currentAnimationSeq_R = r085
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current
          rem   animation sequence (4 bytes) - SCRAM w085-w088
          
          rem Game Mode: Attack cooldown timers (var37-var40 = 4 bytes)
          rem PERFORMANCE CRITICAL: Checked every frame for attack
          dim playerAttackCooldown = var37 : rem   availability
          rem Array accessible as playerAttackCooldown[0] through
          rem   playerAttackCooldown[3] - ZPRAM for performance
          rem NOTE: var37-var40 used for playerAttackCooldown (Game
          rem   Mode), var37-var38 used for charSelect (Admin Mode)
          
          rem Game Mode: Additional game state variables (moved to SCRAM
          rem   - less performance critical)
          rem NOTE: These are accessed infrequently (elimination/win
          rem   screen only), safe in SCRAM
          rem Moved from var24-var31 to SCRAM to free ZPRAM for
          dim playersRemaining_W = w016 : rem   animation vars
          dim playersRemaining_R = r016
          rem Game Mode: Count of active players (SCRAM - low frequency
          dim gameEndTimer_W = w018 : rem   access)
          dim gameEndTimer_R = r018
          dim eliminationEffectTimer_W = w019 : rem Game Mode: Countdown to game end screen (SCRAM)
          dim eliminationEffectTimer_R = r019
          rem Game Mode: Visual effect timers (single byte, bits for
          dim eliminationOrder_W = w040 : rem   each player) (SCRAM)
          dim eliminationOrder_R = r040
          rem Game Mode: Order players were eliminated [0-3] (packed
          dim eliminationCounter_W = w041 : rem   into 4 bits) (SCRAM)
          dim eliminationCounter_R = r041
          dim winnerPlayerIndex_W = w042 : rem Game Mode: Counter for elimination sequence (SCRAM)
          dim winnerPlayerIndex_R = r042
          dim displayRank_W = w043 : rem Game Mode: Index of winning player (0-3) (SCRAM)
          dim displayRank_R = r043
          dim winScreenTimer_W = w044 : rem Game Mode: Current rank being displayed (1-4) (SCRAM)
          dim winScreenTimer_R = r044
          rem
          rem Game Mode: Win screen display timer (SCRAM)
          
          rem GAME MODE - Standard RAM (a-z) - Sorted Alphabetically
          
          rem Game Mode: Missile active flags - bit-packed into single
          rem   byte (standard RAM)
          rem Format:
          rem   [M4Active:1][M3Active:1][M2Active:1][M1Active:1]
          rem   [unused:4]
          rem Bit 0 = Missile1 active, Bit 1 = Missile2 active, etc.
          dim missileActive = i
          rem Game Mode: Missile active flags (standard RAM)

          rem Game Mode: Missile X positions [0-3] for players 1-4
          rem   (standard RAM a,b,c,d)
          rem NOTE: These are REDIMMED in Admin Mode for fall animation
          dim missileX = a : rem   variables
          rem Array accessible as missileX[0] through missileX[3]

          rem Game Mode: Missile lifetime counters [0-3] - frames
          rem   remaining
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for until
          rem   collision
          rem PERFORMANCE: Moved to SCRAM since accessed less frequently
          rem   than other missile vars
          rem NOTE: console7800Detected (COMMON) uses ’e’ in standard
          dim missileLifetime_W = w045 : rem   RAM, missileLifetime moved to SCRAM to avoid conflict
          dim missileLifetime_R = r045
          rem Game Mode: Missile lifetime array (4 bytes) - SCRAM
          rem   w045-w048 for performance
          rem Array accessible as missileLifetime[0] through
          rem   missileLifetime[3]

          rem Game Mode: Missile velocities [0-3] for X and Y axes
          rem   (standard RAM w,x)
          rem NOTE: These are REDIMMED in Admin Mode for character
          rem   select animation
          rem Stored velocities for bounce calculations and physics
          dim missileVelocityX = w : rem   updates
          rem Game Mode: Missile X velocity array (4 bytes) - REDIM from
          dim missileVelocityY = x : rem   charSelectAnimTimer
          rem Game Mode: Missile Y velocity array (4 bytes) - REDIM from
          rem   charSelectAnimState

          rem Missile momentum stored in temp variables during
          rem   UpdateMissiles subroutine
          rem temp1 = current player index being processed
          rem temp2 = missileX delta (momentum)
          rem temp3 = missileY delta (momentum)
          rem temp4 = scratch for collision checks
          rem These are looked up from character data each frame and
          rem   stored in missileVelocityX/Y

          rem GAME MODE - SCRAM (r000-r127/w000-w127) - sorted
          rem   numerically
          
          rem PlayerFrameBuffer (64-byte contiguous block for sprite
          rem   rendering)
          rem OPTIMIZED: Allocated at w000-w063 (64 bytes) after moving
          rem   variables to higher addresses
          rem This block is used for buffering player sprite data during
          rem   rendering operations
          rem Physical addresses: $F000-$F03F (write ports), $F080-$F0BF
          dim PlayerFrameBuffer_W = w000 : rem   (read ports)
          dim PlayerFrameBuffer_R = r000
          dim PlayerFrameBuffer = PlayerFrameBuffer_W
          rem 64-byte buffer for player frame data (w000-w063)
          rem Array accessible as PlayerFrameBuffer[0] through
          rem   PlayerFrameBuffer[63]
          
          rem Game Mode: Missile Y positions [0-3] - using SCRAM
          rem   (SuperChip RAM)
          rem OPTIMIZED: Moved to w017-w020 to free w000-w063 for
          dim missileY_W = w017 : rem   PlayerFrameBuffer
          dim missileY_R = r017
          rem NOTE: batariBASIC uses array syntax - missileY[0] =
          rem   w017/r017, missileY[1] = w018/r018, etc.
          rem NOTE: Must use missileY_R for reads and missileY_W for
          rem   writes to avoid RMW issues

          rem Game Mode: Player timers array [0-3] - used for guard
          rem   cooldowns and other timers
          rem SCRAM allocated since var44-var47 already used by
          rem   playerAttackCooldown
          rem OPTIMIZED: Moved from w004-w007 to w013-w016 to free space
          dim playerTimers_W = w013 : rem   for PlayerFrameBuffer (w000-w063)
          dim playerTimers_R = r013
          dim playerTimers = playerTimers_W
          rem Game Mode: Player timers array (4 bytes) - SCRAM w013-w016
          rem Array accessible as playerTimers[0] through
          rem   playerTimers[3]

          rem PlayerEliminated[0-3] - Bit flags for eliminated players
          rem Bit 0 = Player 1, Bit 1 = Player 2, Bit 2 = Player 3, Bit
          rem   3 = Player 4
          rem Set when player health reaches 0, prevents respawn/reentry
          rem NOTE: w015 conflicts with fireHoldTimer_W (COMMON Admin
          rem   Mode), but playersEliminated is GAME MODE only
          rem Using proper _W/_R suffixes to follow SCRAM conventions
          dim playersEliminated_W = w015 : rem   despite intentional redim
          dim playersEliminated_R = r015
          dim playersEliminated = playersEliminated_W
          rem GAME: Eliminated player bit flags (SCRAM - low frequency
          rem   access, redimmed with fireHoldTimer_W)

          rem Character-specific state flags for special mechanics
          dim characterStateFlags_W = w013 : rem   (SCRAM)
          dim characterStateFlags_R = r013
          dim characterStateFlags = characterStateFlags_W
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 character state bits (4
          rem   bytes)
          rem Bit 0: RoboTito ceiling latched
          rem Bit 1: Harpy in flight mode
          rem Bit 2: Harpy in dive mode
          rem Bit 3-7: Reserved for future character mechanics

          rem Missile angular velocity for curling stone rotation
          dim missileAngularVel_W = w017 : rem   (SCRAM)
          dim missileAngularVel_R = r017
          dim missileAngularVel = missileAngularVel_W
          rem [0-3] angular velocity for rotation effects (4 bytes,
          rem   reserved for future)

          rem Missile NUSIZ tracking (SCRAM)
          rem Tracks NUSIZ register values for each missile (0-3) to
          dim missileNUSIZ_W = w114 : rem   ensure proper sizing
          dim missileNUSIZ_R = r114
          rem [0-3] NUSIZ values for missiles M0-M3 (4 bytes: w114-w117)
          rem Array accessible as missileNUSIZ[0] through
          rem   missileNUSIZ[3]

          rem RoboTito stretch missile height tracking (SCRAM)
          dim missileStretchHeight_W = w118 : rem Tracks missile height for RoboTito stretch visual effect
          dim missileStretchHeight_R = r118
          rem [0-3] Missile height in scanlines for RoboTito stretch
          rem visual
          rem   (4 bytes: w118-w121)
          rem Height extends downward from player position to ground
          rem level
          rem Array accessible as missileStretchHeight[0] through
          rem   missileStretchHeight[3]

          rem RoboTito stretch permission flags (SCRAM)
          rem Bit-packed: 1 bit per player (0=not grounded, 1=can
          rem stretch)
          dim roboTitoCanStretch_W = w122
          dim roboTitoCanStretch_R = r122
          rem Bit 0: Player 0 can stretch, Bit 1: Player 1, Bit 2:
          rem Player 2,
          rem   Bit 3: Player 3
          rem Set to 1 when RoboTito lands on ground, cleared when hit
          rem or
          rem   stretching upward

          dim harpyFlightEnergy_W = w009 : rem Harpy flight energy/duration counters (SCRAM)
          dim harpyFlightEnergy_R = r009
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 flight energy remaining (4
          rem   bytes: w009-w012)
          rem Decrements on each flap, resets on landing, maximum value
          rem   60 (1 second at 60fps)
          rem Array accessible as harpyFlightEnergy[0] through
          rem   harpyFlightEnergy[3]
          
          dim harpyLastFlapFrame_W = w023 : rem Last flap frame tracker for rapid tap detection (SCRAM)
          dim harpyLastFlapFrame_R = r023
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 last flap frame counter (4
          rem   bytes: w023-w026)
          rem Used to detect rapid UP tapping
          rem Array accessible as harpyLastFlapFrame[0] through
          rem   harpyLastFlapFrame[3]

          rem ADMIN MODE - SCRAM (r000-r127/w000-w127) - sorted
          rem   numerically
          
          rem ADMIN: Random character selection flags (SCRAM - used in
          rem   character select)
          rem OPTIMIZED: Moved from w027 to w075 to free space for
          rem   PlayerFrameBuffer (w000-w063)
          rem NOTE: Overlaps with Game Mode variables - safe since Admin
          dim randomSelectFlags_W = w075 : rem   and Game Mode never run simultaneously
          dim randomSelectFlags_R = r075
          rem Bit 7 = handicap flag (1 if down+fire was held), bits 0-6
          rem   unused
          rem Array accessible as randomSelectFlags[0] through
          rem   randomSelectFlags[3]
          
          rem ADMIN: Character select animation frame counters (SCRAM -
          rem   used in character select)
          rem OPTIMIZED: Moved from w028-w031 to w076-w079 to free space
          rem   for PlayerFrameBuffer (w000-w063)
          rem NOTE: Overlaps with Game Mode playerSubpixelY - safe since
          dim charSelectPlayerAnimFrame_W = w076 : rem   Admin and Game Mode never run simultaneously
          dim charSelectPlayerAnimFrame_R = r076
          rem Frame counters for idle/walk animation cycles in character
          rem   select
          rem Array accessible as charSelectPlayerAnimFrame[0] through
          rem   charSelectPlayerAnimFrame[3]
          
          rem ADMIN: Character select animation sequence flags (SCRAM -
          rem   used in character select)
          rem OPTIMIZED: Moved from w032-w035 to w080-w083 to free space
          rem   for PlayerFrameBuffer (w000-w063)
          rem NOTE: Overlaps with Game Mode variables - safe since Admin
          rem   and Game Mode never run simultaneously
          rem NOTE: Also REDIMMED with selectedChar2/3/4 (w084-w086) -
          rem   selectedChar* are read once at game start before Admin
          dim charSelectPlayerAnimSeq_W = w080 : rem   charSelect anim runs again, so safe overlap
          dim charSelectPlayerAnimSeq_R = r080
          rem
          rem Bit 0: 0=idle, 1=walk. Toggles every 60 frames
          rem Array accessible as charSelectPlayerAnimSeq[0] through
          rem   charSelectPlayerAnimSeq[3]

          rem TODO / FUTURE EXPANSION
          
          rem Note: playerDamage[0-3] now properly allocated in SCRAM
          rem   (w067-w070) - see Common Vars section above
          rem Moved from w050-w053 to avoid conflict with
          rem playerSubpixelX
          
          rem NOTE: var0-3 used by playerX (core gameplay, cannot redim)
          rem NOTE: var4-7 used by playerY (core gameplay, cannot redim)
          rem NOTE: var8-11 used by playerState (core gameplay, cannot
          rem   redim)
          rem NOTE: var12-15 used by playerHealth (core gameplay, cannot
          rem   redim)
          rem NOTE: var16-19 used by playerRecoveryFrames (core
          rem   gameplay, cannot redim)
          rem NOTE: var20-23 used by playerVelocityX (core gameplay,
          rem   cannot redim)
          
          rem GAME: Subpixel position and velocity system - IMPLEMENTED
          rem   using batariBASIC 8.8 fixed-point
          rem NOTE: Using batariBASIC built-in 8.8 fixed-point support:
          rem playerVelocityX: high bytes in ZPRAM (var20-var23), low
          rem   bytes in ZPRAM (var24-var27)
          rem playerVelocityY: both high and low bytes in ZPRAM
          rem   (var28-var35)
          rem playerSubpixelX/Y: in SCRAM (w049-w064, 16 bytes) - less
          rem   frequently accessed
          
          rem TEMPORARY WORKING VARIABLES - SCRAM (for temp7+
          rem   replacements)
          rem These replace invalid temp7+ variables (only temp1-temp6
          rem   exist)
          rem Each variable has a semantically meaningful name based on
          rem   its usage context
          
          dim oldHealthValue_W = w089
          dim oldHealthValue_R = r089
          rem Old health value for byte-safe clamp checks (used in
          rem   damage calculations)
          
          dim recoveryFramesCalc_W = w090
          dim recoveryFramesCalc_R = r090
          rem Recovery frames calculation value (used in fall damage and
          rem   hit processing)
          
          dim playerStateTemp_W = w091
          dim playerStateTemp_R = r091
          rem Temporary player state value for bit manipulation
          rem   operations
          
          dim playfieldRow_W = w092
          dim playfieldRow_R = r092
          rem Playfield row index for collision calculations
          
          dim playfieldColumn_W = w093
          dim playfieldColumn_R = r093
          rem Playfield column index for collision calculations
          
          dim rowYPosition_W = w094
          dim rowYPosition_R = r094
          rem Y position of playfield row (used in gravity calculations)
          
          dim rowCounter_W = w095
          dim rowCounter_R = r095
          rem Loop counter for row calculations
          
          dim characterHeight_W = w096
          dim characterHeight_R = r096
          rem Character height value from CharacterHeights table
          
          dim characterWeight_W = w097
          dim characterWeight_R = r097
          rem Character weight value from CharacterWeights table
          
          dim yDistance_W = w098
          dim yDistance_R = r098
          rem Y distance between players for collision calculations
          
          dim halfHeight1_W = w099
          dim halfHeight1_R = r099
          rem Half height of first player for collision overlap
          rem   calculation
          
          dim halfHeight2_W = w100
          dim halfHeight2_R = r100
          rem Half height of second player for collision overlap
          rem   calculation
          
          dim totalHeight_W = w101
          dim totalHeight_R = r101
          rem Total height for collision overlap check (halfHeight1 +
          rem   halfHeight2)
          
          dim totalWeight_W = w102
          dim totalWeight_R = r102
          rem Total weight of both players for momentum calculations
          
          dim weightDifference_W = w103
          dim weightDifference_R = r103
          rem Weight difference between players for impulse calculation
          
          dim impulseStrength_W = w104
          dim impulseStrength_R = r104
          rem Calculated impulse strength for momentum transfer
          
          dim gravityRate_W = w105
          dim gravityRate_R = r105
          rem Gravity acceleration rate (normal or reduced)
          
          dim damageWeightProduct_W = w106
          dim damageWeightProduct_R = r106
          rem Intermediate value: damage * weight (used in fall damage
          rem   calculations)
          
          dim missileLifetimeValue_W = w107
          dim missileLifetimeValue_R = r107
          rem Missile lifetime value from CharacterMissileLifetime table
          
          dim velocityCalculation_W = w108
          dim velocityCalculation_R = r108
          rem Intermediate velocity calculation (e.g., velocity / 2,
          rem   velocity / 4)
          
          dim missileVelocityXCalc_W = w109
          dim missileVelocityXCalc_R = r109
          rem Missile X velocity for friction calculations (temporary
          rem   calculation variable)
          
          dim soundEffectID_W = w110
          dim soundEffectID_R = r110
          rem Sound effect ID for playback
          
          dim characterIndex_W = w111
          dim characterIndex_R = r111
          rem Character index for table lookups
          
          dim aoeOffset_W = w112
          dim aoeOffset_R = r112
          rem AOE offset value from CharacterAOEOffsets table
          
          dim healthBarRemainder_W = w113
          dim healthBarRemainder_R = r113
          rem Health bar remainder calculation (for displaying partial
          rem   bars)
          
          rem Cached hitbox for current attacker (SCRAM) - calculated
          rem once
          rem   per attacker to avoid redundant calculations
          rem When processing an attacker, we check against 3 defenders,
          rem   so caching saves 2 redundant hitbox calculations per
          rem   attacker
          dim cachedHitboxLeft_W = w124 : rem Uses 4 bytes: left, right, top, bottom for current attacker
          dim cachedHitboxLeft_R = r124
          dim cachedHitboxRight_W = w125
          dim cachedHitboxRight_R = r125
          dim cachedHitboxTop_W = w126
          dim cachedHitboxTop_R = r126
          dim cachedHitboxBottom_W = w127
          dim cachedHitboxBottom_R = r127
          rem Single hitbox cache (4 bytes total) - reused for each
          rem attacker
          
          rem Hitbox calculation variables (global, used in Combat.bas)
          rem These are set by CalculateAttackHitbox and immediately
          rem copied to cached versions
          rem NOTE: Since CalculateAttackHitbox is only called from
          rem ProcessAttackerAttacks,
          rem   and the values are immediately copied to cached
          rem   versions, we can alias
          rem   the hitbox variables directly to the cached versions to
          rem   save memory.
          rem This avoids needing separate storage since they’re never
          rem used simultaneously.
          dim hitboxLeft = cachedHitboxLeft_W
          dim hitboxRight = cachedHitboxRight_W
          dim hitboxTop = cachedHitboxTop_W
          dim hitboxBottom = cachedHitboxBottom_W
          rem Hitbox bounds for attack collision detection (aliased to
          rem cached versions)
          rem NOTE: CalculateAttackHitbox sets these, then
          rem ProcessAttackerAttacks uses them.
          rem   Since they’re immediately copied (no-op since aliased),
          rem   this is safe.
          
          rem       Total: 16 bytes zero-page + 16 bytes SCRAM
          rem Animation vars (var24-var31, var33-var36) moved to SCRAM
          rem   to free zero-page space
          rem batariBASIC automatically handles carry operations for 8.8
          rem   fixed-point arithmetic
