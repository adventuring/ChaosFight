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
          rem   are available at all times!
          rem NOTE: Multisprite playfield is symmetrical
          rem   (repeated/reflected), not asymmetrical

          rem ==========================================================
          rem VARIABLE MEMORY LAYOUT - DUAL CONTEXT SYSTEM
          rem ==========================================================
          
          rem ChaosFight uses TWO memory contexts that never overlap:
          rem 1. Admin Mode: Title, preambles, character select, falling
          rem   in, arena select, winner (GameModes 0,1,2,3,4,5,7)
          rem   2. Game Mode: Gameplay only (GameMode 6)
          rem
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
          
          rem ==========================================================
          rem STANDARD RAM (Available everywhere):
          rem   a-z = 26 variables
          
          rem SUPERCHIP RAM AVAILABILITY (SCRAM - accessed via separate
          rem   read/write ports):
          rem Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z
          rem   ($d4-$ed) = 26 bytes = 74 bytes always available
          rem SuperChip RAM (SCRAM): r000-r127/w000-w127 ($1000-$107F
          rem   physical RAM) = 128 bytes
          rem     - r000-r127: read ports at $F080-$F0FF
          rem     - w000-w127: write ports at $F000-$F07F
          rem - NOTE: r000-r127 and w000-w127 map to SAME physical
          rem   128-byte SCRAM!
          rem - NOTE: There is NO var48-var127! SuperChip RAM accessed
          rem   via r000-r127/w000-w127 only!
          rem   
          rem   MULTISPRITE KERNEL BEHAVIOR:
          rem - Playfield data is stored in ROM (ROMpf=1), NOT in RAM
          rem - Playfield uses ZERO bytes of SCRAM - ALL 128 bytes are
          rem   available!
          rem - Playfield is symmetrical (repeated/reflected), not
          rem   asymmetrical like standard kernel
          rem - This applies to ALL screens (Admin Mode and Game Mode)
          rem
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
          rem - var24-var27: Arena select (Admin) or playerVelocityX_lo
          rem   (Game) - ZPRAM for physics
          rem - var28-var35: Preamble/music (Admin) or playerVelocityY
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
          rem   to SCRAM w045 to avoid conflict
          rem - selectedArena: Moved from w to w014 (SCRAM) to avoid
          rem   redim conflict
          rem ==========================================================
          
          rem ==========================================================
          rem COMMON VARS (Used in BOTH Admin Mode and Game Mode)
          rem ==========================================================
          rem These variables maintain their values across context
          rem   switches
          rem NOTE: All Common vars use earliest letters/digits (a, b,
          rem   c, ..., var0, var1, var2, ...)
          rem ==========================================================
          
          rem Built-in variables (NO DIM NEEDED - already exist in
          rem   batariBasic):
          rem temp1, temp2, temp3, temp4, temp5, temp6 - temporary
          rem   storage
          rem   qtcontroller - Quadtari multiplexing state (0 or 1)
          rem   frame - frame counter (increments every frame)
          
          rem ==========================================================
          rem COMMON VARS - Standard RAM (a-z) - sorted alphabetically
          rem ==========================================================

          rem Game state and system flags (consolidated to save RAM)
          dim gameMode = p
          rem Game mode index (0-8): ModePublisherPreamble, ModeAuthorPreamble, etc.
          dim systemFlags = f
          rem System flags (packed byte):
          rem   Bit 7: 7800 console detected (SystemFlag7800 = $80)
          rem   Bit 6: Color/B&W override active (SystemFlagColorBWOverride = $40, 7800 only)
          rem   Bit 5: Pause button previous state (SystemFlagPauseButtonPrev = $20)
          rem   Bit 4: Game state paused (SystemFlagGameStatePaused = $10, 0=normal, 1=paused)
          rem   Bit 3: Game state ending (SystemFlagGameStateEnding = $08, 0=normal, 1=ending)
          rem   Bits 0-2: Reserved for future use
          rem NOTE: Previously separate variables (console7800Detected, colorBWOverride,
          rem   pauseButtonPrev, gameState) are now consolidated into this byte
          dim controllerStatus = h
          rem Packed controller status bits: $80=Quadtari,
          rem   $01=LeftGenesis, $02=LeftJoy2b+, $04=RightGenesis,
          rem   $08=RightJoy2b+
          rem HandicapMode - defined locally in CharacterSelect.bas as
          rem   temp1 (local scope only)
          
          rem Character selection results (set during ADMIN, read during
          rem   GAME)
          dim playerChar = j    
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using j,k,l,m
          dim playerDamage_W = w050
          dim playerDamage_R = r050
          dim playerDamage = playerDamage_W
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 base damage per player
          rem (4 bytes: w050-w053) - SCRAM for low-frequency access
          rem Array accessible as playerDamage[0] through playerDamage[3]
          dim playerLocked = e
          rem Bit-packed: 2 bits per player (4 players × 2 bits = 8 bits = 1 byte)
          rem Bits 0-1: Player 0 locked state (0=unlocked, 1=normal, 2=handicap)
          rem Bits 2-3: Player 1 locked state
          rem Bits 4-5: Player 2 locked state
          rem Bits 6-7: Player 3 locked state
          rem NOTE: Use helper functions GetPlayerLocked/SetPlayerLocked to access
          rem   (see Source/Routines/PlayerLockedHelpers.bas)
          rem Previously used 4 bytes (n,o,p,q) - now consolidated to 1 byte (e)
          dim selectedChar1 = s
          rem selectedChar2, selectedChar3, and selectedChar4 moved to
          rem   SuperChip RAM to avoid conflicts
          rem NOTE: missileY uses w000-w003 in Game Mode, but
          rem   selectedChar2 is COMMON (both modes)
          rem Using w003 is safe since missileY[3] (w003) is only used
          rem   in Game Mode
          dim selectedChar2_W = w003
          dim selectedChar2_R = r003
          dim selectedChar3_W = w001
          dim selectedChar3_R = r001
          dim selectedChar4_W = w002
          dim selectedChar4_R = r002
          rem ==========================================================
          rem COMMON VARS - SCRAM (r000-r127/w000-w127) - sorted
          rem   numerically
          rem ==========================================================
          
          rem Console switch handling (used in both Admin Mode and Game
          rem   Mode)
          dim colorBWPrevious_W = w008
          dim colorBWPrevious_R = r008
          
          rem Arena selection (COMMON - used in both Admin and Game
          rem   Mode)
          rem NOTE: Must be in SCRAM since w is REDIMMED between
          rem   Admin/Game modes
          rem NOTE: w010 is used by harpyFlightEnergy array, so using
          rem   w014 instead
          dim selectedArena_W = w014
          dim selectedArena_R = r014
          
          rem Arena Select fire button hold timer (COMMON - used in
          rem   Admin Mode)
          dim fireHoldTimer_W = w015
          dim fireHoldTimer_R = r015
          
          rem ==========================================================
          rem MUSIC/SOUND POINTERS - Zero Page Memory (standard RAM)
          rem ==========================================================
          rem CRITICAL: 16-bit pointers MUST be in zero page for
          rem   indirect addressing
          rem Music and Sound never run simultaneously, so pointers can
          rem   be shared
          rem Used in Admin Mode (music) and Game Mode (sound effects)
          rem ==========================================================
          
          rem Music System Pointers (Admin Mode: gameMode 0-2, 7)
          rem NOTE: Music only runs in Admin Mode, so safe to use
          rem   var39-var44
          dim SongPointerL = var39
          dim SongPointerH = var40
          rem Song data pointer low/high bytes (in Songs bank) - zero
          rem   page
          dim MusicVoice0PointerL = var41
          dim MusicVoice0PointerH = var42
          rem Voice 0 stream position low/high bytes (high byte = 0
          rem   means inactive) - zero page
          dim MusicVoice1PointerL = var43
          dim MusicVoice1PointerH = var44
          rem Voice 1 stream position low/high bytes (high byte = 0
          rem   means inactive) - zero page
          
          rem Sound Effect System Pointers (Game Mode: gameMode 6)
          rem NOTE: Must avoid var40 (currentAnimationSeq) and var44
          rem   (playerAttackCooldown[0])
          rem Uses var39, var41 (shared with Music), y,z,var45,var46
          rem Voice 0: var39+var41 (shared), y+z for pointers
          rem Voice 1: var45+var46 for pointers (zero page)
          dim SoundPointerL = var39
          dim SoundPointerH = y
          rem Sound data pointer low/high bytes (in Sounds bank) - zero
          rem   page (y is available in Game Mode)
          dim SoundEffectPointerL = var41
          dim SoundEffectPointerH = z
          rem Sound effect Voice 0 stream position low/high bytes (high
          rem   byte = 0 means inactive) - zero page (z is available in
          rem   Game Mode)
          dim SoundEffectPointer1L = var45
          dim SoundEffectPointer1H = var46
          rem Sound effect Voice 1 stream position low/high bytes (high
          rem   byte = 0 means inactive) - zero page
          
          rem ==========================================================
          rem MUSIC/SOUND FRAME COUNTERS - SCRAM (not pointers, can be
          rem   in SCRAM)
          rem ==========================================================
          rem Frame counters are simple counters, not pointers, so SCRAM
          rem   is acceptable
          rem ==========================================================
          
          rem Music System Frame Counters (SCRAM - used in Admin Mode)
          dim MusicVoice0Frame_W = w020
          dim MusicVoice0Frame_R = r020
          dim MusicVoice0Frame = MusicVoice0Frame_W
          dim MusicVoice1Frame_W = w021
          dim MusicVoice1Frame_R = r021
          dim MusicVoice1Frame = MusicVoice1Frame_W
          rem Frame counters for current notes on each voice (SCRAM
          rem   acceptable)
          
          rem Music System Current Song ID and Loop Pointers (SCRAM -
          rem   used in Admin Mode)
          dim CurrentSongID_W = w022
          dim CurrentSongID_R = r022
          rem NOTE: w022 now free for CurrentSongID (SoundEffectFrame
          rem   moved to w046)
          rem Current playing song ID (used to check if Chaotica for
          rem   looping)
          dim MusicVoice0StartPointerL_W = w033
          dim MusicVoice0StartPointerL_R = r033
          dim MusicVoice0StartPointerL = MusicVoice0StartPointerL_W
          dim MusicVoice0StartPointerH_W = w034
          dim MusicVoice0StartPointerH_R = r034
          dim MusicVoice0StartPointerH = MusicVoice0StartPointerH_W
          rem Initial Voice 0 pointer for looping (Chaotica only)
          dim MusicVoice1StartPointerL_W = w035
          dim MusicVoice1StartPointerL_R = r035
          dim MusicVoice1StartPointerL = MusicVoice1StartPointerL_W
          dim MusicVoice1StartPointerH_W = w030
          dim MusicVoice1StartPointerH_R = r030
          dim MusicVoice1StartPointerH = MusicVoice1StartPointerH_W
          rem Moved from w023-w026 to w030/w033-w035 to avoid conflict
          rem   with harpyLastFlapFrame_W (w023-w026)
          rem Initial Voice 1 pointer for looping (Chaotica only)
          
          rem Music System Envelope State (SCRAM - used in Admin Mode)
          dim MusicVoice0TargetAUDV_W = w036
          dim MusicVoice0TargetAUDV_R = r036
          rem Target AUDV value from note data (for envelope
          rem   calculation)
          dim MusicVoice1TargetAUDV_W = w037
          dim MusicVoice1TargetAUDV_R = r037
          rem Target AUDV value from note data (for envelope
          rem   calculation)
          dim MusicVoice0TotalFrames_W = w038
          dim MusicVoice0TotalFrames_R = r038
          rem Total frames (Duration + Delay) when note was loaded (for
          rem   envelope calculation)
          dim MusicVoice1TotalFrames_W = w039
          dim MusicVoice1TotalFrames_R = r039
          rem Total frames (Duration + Delay) when note was loaded (for
          rem   envelope calculation)
          
          rem Sound Effect System Frame Counters (SCRAM - used in Game
          rem   Mode)
          dim SoundEffectFrame_W = w046
          dim SoundEffectFrame_R = r046
          dim SoundEffectFrame = SoundEffectFrame_W
          dim SoundEffectFrame1_W = w047
          dim SoundEffectFrame1_R = r047
          dim SoundEffectFrame1 = SoundEffectFrame1_W
          rem Moved from w022/w024 to w046/w047 to avoid conflicts
          rem Frame counters for current sound effect notes on each
          rem   voice (SCRAM acceptable)

          rem ==========================================================
          rem ADMIN MODE VARIABLES (may be re-used in Game Mode for
          rem   other purposes)
          rem ==========================================================
          rem These variables are ONLY valid on Admin Mode screens
          rem   (GameModes 0-5,7)
          rem ==========================================================
          
          rem ==========================================================
          rem ADMIN MODE - Standard RAM (a-z) - sorted alphabetically
          rem ==========================================================
          
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
          rem ADMIN: Count of locked players
          dim charSelectAnimTimer = w      
          rem ADMIN: Animation frame counter (REDIM - conflicts with
          rem   missileVelocityX in Game Mode)
          dim charSelectAnimState = t      
          rem ADMIN: Current animation state (ADMIN-only, no conflict)
          dim charSelectAnimIndex = u      
          rem ADMIN: Which character animating (ADMIN-only, no conflict)
          dim charSelectAnimFrame = v      
          rem ADMIN: Current frame in sequence (ADMIN-only, no conflict)
          
          rem ==========================================================
          rem ADMIN MODE - Standard RAM (var0-var47) - sorted
          rem   numerically
          rem ==========================================================
          
          rem ADMIN: Character selection state (var37-var38)
          rem NOTE: These are REDIMMED in Game Mode for
          rem   playerAttackCooldown
          dim charSelectCharIndex = var37   
          rem ADMIN: Currently selected character index (0-15) for
          rem   preview (REDIMMED - Game Mode uses var37 for
          rem   playerAttackCooldown[0])
          dim charSelectPlayer = var38      
          rem ADMIN: Which player is currently selecting (1-4) (REDIMMED
          rem   - Game Mode uses var38 for playerAttackCooldown[1])
          
          rem ADMIN: Arena select variables (var24-var27)
          rem NOTE: These are REDIMMED in Game Mode for animationCounter
          rem   (var24-var27)
          dim levelPreviewData = var24      
          rem ADMIN: Arena preview state (REDIMMED - Game Mode uses
          rem   var24 for animationCounter[0])
          dim levelScrollOffset = var25     
          rem ADMIN: Scroll position (REDIMMED - Game Mode uses var25
          rem   for animationCounter[1])
          dim levelCursorPos = var26        
          rem ADMIN: Cursor position (REDIMMED - Game Mode uses var26
          rem   for animationCounter[2])
          dim levelConfirmTimer = var27     
          rem ADMIN: Confirmation timer (REDIMMED - Game Mode uses var27
          rem   for animationCounter[3])

          rem ADMIN: Preamble screen variables (var28-var32)
          rem NOTE: These are REDIMMED in Game Mode for playerVelocityY
          rem   (8.8 fixed-point, uses var28-var35)
          dim preambleTimer = var28         
          rem ADMIN: Screen timer (REDIMMED - Game Mode uses var28-var31
          rem   for playerVelocityY high bytes)
          dim preambleState = var29         
          rem ADMIN: Which preamble (REDIMMED - Game Mode uses var29 for
          rem   playerVelocityY[1] high byte)
          dim musicPlaying = var30          
          rem ADMIN: Music status (REDIMMED - Game Mode uses var30 for
          rem   playerVelocityY[2] high byte)
          dim musicPosition = var31         
          rem ADMIN: Current note (REDIMMED - Game Mode uses var31 for
          rem   playerVelocityY[3] high byte)
          dim musicTimer = var32            
          rem ADMIN: Music frame counter (REDIMMED - Game Mode uses
          rem   var32-var35 for playerVelocityY low bytes)

          rem ADMIN: Title screen parade (var33-var36)
          rem NOTE: These are REDIMMED in Game Mode for
          rem   currentAnimationSeq (var33-var36, but var37-var40 for
          rem   playerAttackCooldown)
          dim titleParadeTimer = var33     
          rem ADMIN: Parade timing (REDIMMED - Game Mode uses var33 for
          rem   currentAnimationSeq[0])
          dim titleParadeChar = var34      
          rem ADMIN: Current parade character (REDIMMED - Game Mode uses
          rem   var34 for currentAnimationSeq[1])
          dim titleParadeX = var35         
          rem ADMIN: Parade X position (REDIMMED - Game Mode uses var35
          rem   for currentAnimationSeq[2])
          dim titleParadeActive = var36    
          rem ADMIN: Parade active flag (REDIMMED - Game Mode uses var36
          rem   for currentAnimationSeq[3])
          
          rem ADMIN: Titlescreen kernel window values (runtime control)
          rem Runtime window values for titlescreen kernel minikernels
          rem   (0=hidden, 42=visible)
          rem These override compile-time constants if kernel supports
          rem   runtime variables
          rem var20-var23 unused in Admin Mode - used for titlescreen
          rem   window control
          dim titlescreenWindow1 = var20
          rem ADMIN: Runtime window value for bmp_48x2_1 (AtariAge) -
          rem   0=hidden, 42=visible
          dim titlescreenWindow2 = var21
          rem ADMIN: Runtime window value for bmp_48x2_2 (Interworldly)
          rem   - 0=hidden, 42=visible
          dim titlescreenWindow3 = var22
          rem ADMIN: Runtime window value for bmp_48x2_3 (ChaosFight) -
          rem   0=hidden, 42=visible
          dim titlescreenWindow4 = var23
          rem ADMIN: Runtime window value for bmp_48x2_4 (Interworldly)
          rem   - 0=hidden, 42=visible
          
          rem ==========================================================
          rem GAME MODE VARIABLES (may be re-used in Admin Mode for
          rem   other purposes)
          rem ==========================================================
          rem These variables are ONLY valid on Game Mode screens
          rem   (GameMode 6)
          rem ==========================================================

          rem Player data arrays using batariBasic array syntax
          rem playerX[0-3] = player1X, player2X, player3X, player4X
          dim playerX = var0
          dim player1X = var0
          dim player2X = var1
          dim player3X = var2
          dim player4X = var3
          
          rem playerY[0-3] = player1Y, player2Y, player3Y, player4Y
          dim playerY = var4
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
          rem   Bits 4-7: Animation state (0-15)
          dim playerState = var8
          dim player1State = var8
          dim player2State = var9
          dim player3State = var10
          dim player4State = var11
          
          rem playerHealth[0-3] = player1Health, player2Health,
          rem   player3Health, player4Health
          dim playerHealth = var12
          dim player1Health = var12
          dim player2Health = var13
          dim player3Health = var14
          dim player4Health = var15

          rem playerRecoveryFrames[0-3] - Recovery/hitstun frame
          rem   counters
          dim playerRecoveryFrames = var16
          dim player1RecoveryFrames = var16
          dim player2RecoveryFrames = var17
          dim player3RecoveryFrames = var18
          dim player4RecoveryFrames = var19
          
          rem playerVelocityX[0-3] = 8.8 fixed-point X velocity
          rem High byte (integer part) in zero-page for fast access
          rem   every frame
          dim playerVelocityX = var20
          dim player1VelocityX = var20
          dim player2VelocityX = var21
          dim player3VelocityX = var22
          dim player4VelocityX = var23
          rem High bytes (integer part) in zero-page var20-var23
          dim playerVelocityX_lo = var24
          rem Low bytes (fractional part) in zero-page var24-var27
          rem   (freed by moving animation vars)
          rem Access: playerVelocityX[i] = high byte,
          rem   playerVelocityX_lo[i] = low byte (both in ZPRAM!)
          
          rem playerVelocityY[0-3] = 8.8 fixed-point Y velocity
          rem Both high and low bytes in zero-page for fast access every
          rem   frame
          dim playerVelocityY = var28.8.8
          rem Game Mode: 8.8 fixed-point Y velocity (8 bytes) -
          rem   var28-var35 in zero-page
          rem var28-var31 = high bytes, var32-var35 = low bytes
          rem Array accessible as playerVelocityY[0-3] and
          rem   playerVelocityY_lo[0-3] (all in ZPRAM!)
          
          rem playerSubpixelX[0-3] = 8.8 fixed-point X position
          rem Updated every frame but accessed less frequently than
          rem   velocity, so SCRAM is acceptable
          dim playerSubpixelX_W = w049.8.8
          dim playerSubpixelX_R = r049.8.8
          rem Game Mode: 8.8 fixed-point X position (8 bytes) - SCRAM
          rem   w049-w056 (write), r049-r056 (read)
          rem Array accessible as playerSubpixelX_W[0-3] and
          rem   playerSubpixelX_W_lo[0-3] (write ports)
          rem Array accessible as playerSubpixelX_R[0-3] and
          rem   playerSubpixelX_R_lo[0-3] (read ports)
          rem Alias for backward compatibility (defaults to write port)
          dim playerSubpixelX = playerSubpixelX_W
          dim playerSubpixelX_lo = playerSubpixelX_W_lo
          
          rem playerSubpixelY[0-3] = 8.8 fixed-point Y position
          dim playerSubpixelY_W = w057.8.8
          dim playerSubpixelY_R = r057.8.8
          rem Game Mode: 8.8 fixed-point Y position (8 bytes) - SCRAM
          rem   w057-w064 (write), r057-r064 (read)
          rem Array accessible as playerSubpixelY_W[0-3] and
          rem   playerSubpixelY_W_lo[0-3] (write ports)
          rem Array accessible as playerSubpixelY_R[0-3] and
          rem   playerSubpixelY_R_lo[0-3] (read ports)
          rem Alias for backward compatibility (defaults to write port)
          dim playerSubpixelY = playerSubpixelY_W
          dim playerSubpixelY_lo = playerSubpixelY_W_lo
          
          rem ==========================================================
          rem GAME MODE - Standard RAM (var24-var47) - sorted
          rem   numerically
          rem ==========================================================
          
          rem Game Mode: Animation system variables (moved to SCRAM -
          rem   updated at 10fps, not every frame)
          rem NOTE: Animation vars updated at 10fps (every 6 frames), so
          rem   SCRAM access cost is acceptable
          rem Freed var24-var31 and var33-var36 (12 bytes) for physics
          rem   variables that update every frame
          dim animationCounter_W = w077
          dim animationCounter_R = r077
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame
          rem   counter (4 bytes) - SCRAM w077-w080
          dim currentAnimationFrame_W = w081
          dim currentAnimationFrame_R = r081
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in
          rem   sequence (4 bytes) - SCRAM w081-w084
          dim currentAnimationSeq_W = w085
          dim currentAnimationSeq_R = r085
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current
          rem   animation sequence (4 bytes) - SCRAM w085-w088
          
          rem Game Mode: Attack cooldown timers (var37-var40 = 4 bytes)
          rem PERFORMANCE CRITICAL: Checked every frame for attack
          rem   availability
          dim playerAttackCooldown = var37
          rem Array accessible as playerAttackCooldown[0] through
          rem   playerAttackCooldown[3] - ZPRAM for performance
          rem NOTE: var37-var40 used for playerAttackCooldown (Game
          rem   Mode), var37-var38 used for charSelect (Admin Mode)
          
          rem Game Mode: Additional game state variables (moved to SCRAM
          rem   - less performance critical)
          rem NOTE: These are accessed infrequently (elimination/win
          rem   screen only), safe in SCRAM
          rem Moved from var24-var31 to SCRAM to free ZPRAM for
          rem   animation vars
          dim playersRemaining_W = w016
          dim playersRemaining_R = r016
          rem Game Mode: Count of active players (SCRAM - low frequency
          rem   access)
          dim gameEndTimer_W = w018
          dim gameEndTimer_R = r018
          rem Game Mode: Countdown to game end screen (SCRAM)
          dim eliminationEffectTimer_W = w019
          dim eliminationEffectTimer_R = r019
          rem Game Mode: Visual effect timers (single byte, bits for
          rem   each player) (SCRAM)
          dim eliminationOrder_W = w040
          dim eliminationOrder_R = r040
          rem Game Mode: Order players were eliminated [0-3] (packed
          rem   into 4 bits) (SCRAM)
          dim eliminationCounter_W = w041
          dim eliminationCounter_R = r041
          rem Game Mode: Counter for elimination sequence (SCRAM)
          dim winnerPlayerIndex_W = w042
          dim winnerPlayerIndex_R = r042
          rem Game Mode: Index of winning player (0-3) (SCRAM)
          dim displayRank_W = w043
          dim displayRank_R = r043
          rem Game Mode: Current rank being displayed (1-4) (SCRAM)
          dim winScreenTimer_W = w044
          dim winScreenTimer_R = r044
          rem Game Mode: Win screen display timer (SCRAM)
          
          rem ==========================================================
          rem GAME MODE - Standard RAM (a-z) - sorted alphabetically
          rem ==========================================================
          
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
          rem   variables
          dim missileX = a                  
          rem Array accessible as missileX[0] through missileX[3]

          rem Game Mode: Missile lifetime counters [0-3] - frames
          rem   remaining
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for "until
          rem   collision"
          rem PERFORMANCE: Moved to SCRAM since accessed less frequently
          rem   than other missile vars
          rem NOTE: console7800Detected (COMMON) uses ’e’ in standard
          rem   RAM, missileLifetime moved to SCRAM to avoid conflict
          dim missileLifetime_W = w045
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
          rem   updates
          dim missileVelocityX = w
          rem Game Mode: Missile X velocity array (4 bytes) - REDIM from
          rem   charSelectAnimTimer
          dim missileVelocityY = x
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

          rem ==========================================================
          rem GAME MODE - SCRAM (r000-r127/w000-w127) - sorted
          rem   numerically
          rem ==========================================================
          
          rem Game Mode: Missile Y positions [0-3] - using SCRAM
          rem   (SuperChip RAM)
          rem Stored in w000-w003 for players 1-4
          rem Using SCRAM allows all 4 missile Y positions
          dim missileY_W = w000
          dim missileY_R = r000
          rem NOTE: batariBASIC uses array syntax - missileY[0] =
          rem   w000/r000, missileY[1] = w001/r001, etc.
          rem NOTE: Must use missileY_R for reads and missileY_W for
          rem   writes to avoid RMW issues

          rem Game Mode: Player timers array [0-3] - used for guard
          rem   cooldowns and other timers
          rem SCRAM allocated since var44-var47 already used by
          rem   playerAttackCooldown
          dim playerTimers_W = w004
          dim playerTimers_R = r004
          dim playerTimers = playerTimers_W
          rem Game Mode: Player timers array (4 bytes) - SCRAM w004-w007
          rem Array accessible as playerTimers[0] through
          rem   playerTimers[3]

          rem PlayerEliminated[0-3] - Bit flags for eliminated players
          rem Bit 0 = Player 1, Bit 1 = Player 2, Bit 2 = Player 3, Bit
          rem   3 = Player 4
          rem Set when player health reaches 0, prevents respawn/reentry
          rem NOTE: w015 conflicts with fireHoldTimer_W (COMMON Admin
          rem   Mode), but playersEliminated is GAME MODE only
          rem Using proper _W/_R suffixes to follow SCRAM conventions
          rem   despite intentional redim
          dim playersEliminated_W = w015
          dim playersEliminated_R = r015
          dim playersEliminated = playersEliminated_W
          rem GAME: Eliminated player bit flags (SCRAM - low frequency
          rem   access, redimmed with fireHoldTimer_W)

          rem Character-specific state flags for special mechanics
          rem   (SCRAM)
          dim characterStateFlags_W = w013
          dim characterStateFlags_R = r013
          dim characterStateFlags = characterStateFlags_W
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 character state bits (4
          rem   bytes)
          rem Bit 0: RoboTito ceiling latched
          rem Bit 1: Harpy in flight mode
          rem Bit 2: Harpy in dive mode
          rem Bit 3-7: Reserved for future character mechanics

          rem Missile angular velocity for curling stone rotation
          rem   (SCRAM)
          dim missileAngularVel_W = w017
          dim missileAngularVel_R = r017
          dim missileAngularVel = missileAngularVel_W
          rem [0-3] angular velocity for rotation effects (4 bytes,
          rem   reserved for future)

          rem Missile NUSIZ tracking (SCRAM)
          rem Tracks NUSIZ register values for each missile (0-3) to
          rem   ensure proper sizing
          dim missileNUSIZ_W = w114
          dim missileNUSIZ_R = r114
          rem [0-3] NUSIZ values for missiles M0-M3 (4 bytes: w114-w117)
          rem Array accessible as missileNUSIZ[0] through
          rem   missileNUSIZ[3]

          rem RoboTito stretch missile height tracking (SCRAM)
          rem Tracks missile height for RoboTito stretch visual effect
          dim missileStretchHeight_W = w118
          dim missileStretchHeight_R = r118
          rem [0-3] Missile height in scanlines for RoboTito stretch visual
          rem   (4 bytes: w118-w121)
          rem Height extends downward from player position to ground level
          rem Array accessible as missileStretchHeight[0] through
          rem   missileStretchHeight[3]

          rem RoboTito stretch permission flags (SCRAM)
          rem Bit-packed: 1 bit per player (0=not grounded, 1=can stretch)
          dim roboTitoCanStretch_W = w122
          dim roboTitoCanStretch_R = r122
          rem Bit 0: Player 0 can stretch, Bit 1: Player 1, Bit 2: Player 2,
          rem   Bit 3: Player 3
          rem Set to 1 when RoboTito lands on ground, cleared when hit or
          rem   stretching upward

          rem Harpy flight energy/duration counters (SCRAM)
          dim harpyFlightEnergy_W = w009
          dim harpyFlightEnergy_R = r009
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 flight energy remaining (4
          rem   bytes: w009-w012)
          rem Decrements on each flap, resets on landing, maximum value
          rem   60 (1 second at 60fps)
          rem Array accessible as harpyFlightEnergy[0] through
          rem   harpyFlightEnergy[3]
          
          rem Last flap frame tracker for rapid tap detection (SCRAM)
          dim harpyLastFlapFrame_W = w023
          dim harpyLastFlapFrame_R = r023
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 last flap frame counter (4
          rem   bytes: w023-w026)
          rem Used to detect rapid UP tapping
          rem Array accessible as harpyLastFlapFrame[0] through
          rem   harpyLastFlapFrame[3]

          rem ==========================================================
          rem ADMIN MODE - SCRAM (r000-r127/w000-w127) - sorted
          rem   numerically
          rem ==========================================================
          
          rem ADMIN: Random character selection flags (SCRAM - used in
          rem   character select)
          dim randomSelectFlags_W = w027
          dim randomSelectFlags_R = r027
          rem Bit 7 = handicap flag (1 if down+fire was held), bits 0-6
          rem   unused
          rem Array accessible as randomSelectFlags[0] through
          rem   randomSelectFlags[3]
          
          rem ADMIN: Character select animation frame counters (SCRAM -
          rem   used in character select)
          dim charSelectPlayerAnimFrame_W = w028
          dim charSelectPlayerAnimFrame_R = r028
          rem Frame counters for idle/walk animation cycles in character
          rem   select
          rem Array accessible as charSelectPlayerAnimFrame[0] through
          rem   charSelectPlayerAnimFrame[3]
          
          rem ADMIN: Character select animation sequence flags (SCRAM -
          rem   used in character select)
          dim charSelectPlayerAnimSeq_W = w032
          dim charSelectPlayerAnimSeq_R = r032
          rem Bit 0: 0=idle, 1=walk. Toggles every 60 frames
          rem Array accessible as charSelectPlayerAnimSeq[0] through
          rem   charSelectPlayerAnimSeq[3]

          rem ==========================================================
          rem TODO / FUTURE EXPANSION
          rem ==========================================================
          
          rem Note: playerDamage[0-3] now properly allocated in SCRAM
          rem   (w050-w053) - see Common Vars section above
          
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
          
          rem ==========================================================
          rem TEMPORARY WORKING VARIABLES - SCRAM (for temp7+
          rem   replacements)
          rem ==========================================================
          rem These replace invalid temp7+ variables (only temp1-temp6
          rem   exist)
          rem Each variable has a semantically meaningful name based on
          rem   its usage context
          rem ==========================================================
          
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
          rem       Total: 16 bytes zero-page + 16 bytes SCRAM
          rem Animation vars (var24-var31, var33-var36) moved to SCRAM
          rem   to free zero-page space
          rem batariBASIC automatically handles carry operations for 8.8
          rem   fixed-point arithmetic
