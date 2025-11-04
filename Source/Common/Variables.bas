          rem ChaosFight - Source/Common/Variables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem MEMORY LAYOUT - MULTISPRITE KERNEL WITH SUPERCHIP:
          rem - Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z ($d4-$ed) = 26 bytes = 74 bytes always available
          rem - SuperChip RAM (SCRAM): Accessed via r000-r127/w000-w127 ($1000-$107F physical RAM) = 128 bytes
          rem   NOTE: There is NO var48-var127! SuperChip RAM is accessed via r000-r127/w000-w127 only!
          rem - MULTISPRITE KERNEL: Playfield data is stored in ROM (not RAM), so playfield uses ZERO bytes of RAM
          rem   This means ALL 128 bytes of SCRAM (r000-r127/w000-w127) are available at all times!
          rem   NOTE: Multisprite playfield is symmetrical (repeated/reflected), not asymmetrical

          rem =================================================================
          rem VARIABLE MEMORY LAYOUT - DUAL CONTEXT SYSTEM
          rem =================================================================
          
          rem ChaosFight uses TWO memory contexts that never overlap:
          rem   1. Admin Mode: Title, preambles, character select, falling in, level select, winner (GameModes 0,1,2,3,4,5,7)
          rem   2. Game Mode: Gameplay only (GameMode 6)
          rem
          rem CRITICAL KERNEL LIMITATION:
          rem   batariBASIC sets kernel at COMPILE TIME - cannot switch at runtime!
          rem   Current setting: multisprite kernel (required for 4-player gameplay)
          rem   This means ADMIN screens must work with multisprite kernel limitations:
          rem     - Playfield is symmetrical (repeated/reflected), not asymmetrical
          rem     - Can still use 4-player sprite capability even on ADMIN screens

          rem This allows us to REDIM the same memory locations for different
          rem purposes depending on which screen we are on, maximizing our limited RAM!
          
          rem =================================================================
          rem STANDARD RAM (Available everywhere):
          rem   a-z = 26 variables
          
          rem SUPERCHIP RAM AVAILABILITY (SCRAM - accessed via separate read/write ports):
          rem   Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z ($d4-$ed) = 26 bytes = 74 bytes always available
          rem   SuperChip RAM (SCRAM): r000-r127/w000-w127 ($1000-$107F physical RAM) = 128 bytes
          rem     - r000-r127: read ports at $F080-$F0FF
          rem     - w000-w127: write ports at $F000-$F07F
          rem     - NOTE: r000-r127 and w000-w127 map to SAME physical 128-byte SCRAM!
          rem     - NOTE: There is NO var48-var127! SuperChip RAM accessed via r000-r127/w000-w127 only!
          rem   
          rem   MULTISPRITE KERNEL BEHAVIOR:
          rem     - Playfield data is stored in ROM (ROMpf=1), NOT in RAM
          rem     - Playfield uses ZERO bytes of SCRAM - ALL 128 bytes are available!
          rem     - Playfield is symmetrical (repeated/reflected), not asymmetrical like standard kernel
          rem     - This applies to ALL screens (Admin Mode and Game Mode)
          rem
          rem   TOTAL AVAILABLE RAM:
          rem     - Standard RAM: 74 bytes (var0-var47, a-z)
          rem     - SCRAM: 128 bytes (r000-r127/w000-w127) - ALL available!
          rem     - TOTAL: 202 bytes available at all times!
          
          rem Common Vars (needed in both contexts):
          rem   - playerChar[0-3], playerLocked[0-3]
          rem   - selectedChar1-4, selectedArena
          rem   - QuadtariDetected
          rem   - temp1-4, qtcontroller, frame (built-ins)
          
          rem REDIMMED VARIABLES (different meaning per context):
          rem   - var24-var40: Shared between Admin Mode and Game Mode (intentional redim)
          rem     - var24-var27: Level select (Admin) or playerVelocityX_lo (Game) - ZPRAM for physics
          rem     - var28-var35: Preamble/music (Admin) or playerVelocityY 8.8 (Game, var28-var31=high, var32-var35=low) - ZPRAM for physics
          rem     - var37-var40: Character select (Admin) or playerAttackCooldown (Game) - ZPRAM
          rem NOTE: Animation vars (animationCounter, currentAnimationFrame, currentAnimationSeq) moved to SCRAM
          rem       to free zero-page space (var24-var31, var33-var36) for frequently-accessed physics variables
          rem   - a,b,c,d: Fall animation vars (Admin Mode) or MissileX (Game Mode)
          rem   - w-z: Animation vars (Admin Mode) or Missile velocities (Game Mode)
          rem   - e: console7800Detected (COMMON) - missileLifetime moved to SCRAM w045 to avoid conflict
          rem   - selectedArena: Moved from w to w014 (SCRAM) to avoid redim conflict
          rem =================================================================
          
          rem =================================================================
          rem COMMON VARS (Used in BOTH Admin Mode and Game Mode)
          rem =================================================================
          rem These variables maintain their values across context switches
          rem NOTE: All Common vars use earliest letters/digits (a, b, c, ..., var0, var1, var2, ...)
          rem =================================================================
          
          rem Built-in variables (NO DIM NEEDED - already exist in batariBasic):
          rem   temp1, temp2, temp3, temp4, temp5, temp6 - temporary storage
          rem   qtcontroller - Quadtari multiplexing state (0 or 1)
          rem   frame - frame counter (increments every frame)
          
          rem =================================================================
          rem COMMON VARS - Standard RAM (a-z) - sorted alphabetically
          rem =================================================================
          
          rem Game state variables
          dim gameState = g
          dim gameMode = p
          rem 0 = normal play, 1 = paused
          
          rem Console and controller detection (set during ADMIN, read during GAME)
          dim console7800Detected = e
          rem 1 if running on Atari 7800
          dim systemFlags = f
          rem System flags: $80=7800 console, other bits reserved
          dim controllerStatus = h
          rem Packed controller status bits: $80=Quadtari, $01=LeftGenesis, $02=LeftJoy2b+, $04=RightGenesis, $08=RightJoy2b+
          rem HandicapMode - defined locally in CharacterSelect.bas as temp1 (local scope only)
          dim pauseButtonPrev = r
          rem Previous frame pause button state
          
#ifndef TV_SECAM
          dim colorBWOverride = q     
          rem 7800 only: manual Color/B&W override (not used in SECAM)
#endif
          
          rem Character selection results (set during ADMIN, read during GAME)
          dim playerChar = j    
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using j,k,l,m
          dim playerDamage = k   
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using k,l,m (base damage per player)
          rem NOTE: Shares k,l,m with playerChar[1-3] - must be recalculated when needed
          dim playerLocked = n  
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using n,o,p,q (p,q may be used by colorBWOverride)
          dim selectedChar1 = s
          dim selectedChar2 = t
          dim selectedChar3 = u
          dim selectedChar4 = v
          
          rem =================================================================
          rem COMMON VARS - SCRAM (r000-r127/w000-w127) - sorted numerically
          rem =================================================================
          
          rem Console switch handling (used in both Admin Mode and Game Mode)
          dim colorBWPrevious_W = w008
          dim colorBWPrevious_R = r008
          rem Previous state of Color/B&W switch (for detecting changes) - SCRAM since low frequency use
          
          rem Arena selection (COMMON - used in both Admin and Game Mode)
          rem NOTE: Must be in SCRAM since w is REDIMMED between Admin/Game modes
          rem NOTE: w010 is used by harpyFlightEnergy array, so using w014 instead
          dim selectedArena_W = w014
          dim selectedArena_R = r014
          dim selectedArena = w014
          rem Selected arena (SCRAM w014, read via r014) - COMMON variable, cannot be in redimmed location
          
          rem =================================================================
          rem MUSIC/SOUND POINTERS - Zero Page Memory (standard RAM)
          rem =================================================================
          rem CRITICAL: 16-bit pointers MUST be in zero page for indirect addressing
          rem Music and Sound never run simultaneously, so pointers can be shared
          rem Used in Admin Mode (music) and Game Mode (sound effects)
          rem =================================================================
          
          rem Music System Pointers (Admin Mode: gameMode 0-2, 7)
          rem NOTE: Music only runs in Admin Mode, so safe to use var39-var44
          dim SongPointerL = var39
          dim SongPointerH = var40
          rem Song data pointer low/high bytes (in Songs bank) - zero page
          dim MusicVoice0PointerL = var41
          dim MusicVoice0PointerH = var42
          rem Voice 0 stream position low/high bytes (high byte = 0 means inactive) - zero page
          dim MusicVoice1PointerL = var43
          dim MusicVoice1PointerH = var44
          rem Voice 1 stream position low/high bytes (high byte = 0 means inactive) - zero page
          
          rem Sound Effect System Pointers (Game Mode: gameMode 6)
          rem NOTE: Must avoid var40 (currentAnimationSeq) and var44 (playerAttackCooldown[0])
          rem Uses var39, var41 (shared with Music), y,z,var45,var46
          rem Voice 0: var39+var41 (shared), y+z for pointers
          rem Voice 1: var45+var46 for pointers (zero page)
          dim SoundPointerL = var39
          dim SoundPointerH = y
          rem Sound data pointer low/high bytes (in Sounds bank) - zero page (y is available in Game Mode)
          dim SoundEffectPointerL = var41
          dim SoundEffectPointerH = z
          rem Sound effect Voice 0 stream position low/high bytes (high byte = 0 means inactive) - zero page (z is available in Game Mode)
          dim SoundEffectPointer1L = var45
          dim SoundEffectPointer1H = var46
          rem Sound effect Voice 1 stream position low/high bytes (high byte = 0 means inactive) - zero page
          
          rem =================================================================
          rem MUSIC/SOUND FRAME COUNTERS - SCRAM (not pointers, can be in SCRAM)
          rem =================================================================
          rem Frame counters are simple counters, not pointers, so SCRAM is acceptable
          rem =================================================================
          
          rem Music System Frame Counters (SCRAM - used in Admin Mode)
          dim MusicVoice0Frame = w020
          dim MusicVoice1Frame = w021
          rem Frame counters for current notes on each voice (SCRAM acceptable)
          
          rem Music System Envelope State (SCRAM - used in Admin Mode)
          dim MusicVoice0TargetAUDV_W = w036
          dim MusicVoice0TargetAUDV_R = r036
          dim MusicVoice0TargetAUDV = w036
          rem Target AUDV value from note data (for envelope calculation)
          dim MusicVoice1TargetAUDV_W = w037
          dim MusicVoice1TargetAUDV_R = r037
          dim MusicVoice1TargetAUDV = w037
          rem Target AUDV value from note data (for envelope calculation)
          dim MusicVoice0TotalFrames_W = w038
          dim MusicVoice0TotalFrames_R = r038
          dim MusicVoice0TotalFrames = w038
          rem Total frames (Duration + Delay) when note was loaded (for envelope calculation)
          dim MusicVoice1TotalFrames_W = w039
          dim MusicVoice1TotalFrames_R = r039
          dim MusicVoice1TotalFrames = w039
          rem Total frames (Duration + Delay) when note was loaded (for envelope calculation)
          
          rem Sound Effect System Frame Counters (SCRAM - used in Game Mode)
          dim SoundEffectFrame = w022
          dim SoundEffectFrame1 = w024
          rem Frame counters for current sound effect notes on each voice (SCRAM acceptable)

          rem =================================================================
          rem ADMIN MODE VARIABLES (may be re-used in Game Mode for other purposes)
          rem =================================================================
          rem These variables are ONLY valid on Admin Mode screens (GameModes 0-5,7)
          rem =================================================================
          
          rem =================================================================
          rem ADMIN MODE - Standard RAM (a-z) - sorted alphabetically
          rem =================================================================
          
          rem ADMIN: Falling animation variables (standard RAM a,b,c,d)
          rem NOTE: These are REDIMMED in Game Mode for missileX[0-3]
          dim fallFrame = a
          dim fallSpeed = b
          dim fallComplete = c
          dim activePlayers = d
          rem ADMIN: Falling animation screen (Mode 4) variables

          rem ADMIN: Character select and title screen animation (Standard RAM w,x,y,z)
          rem NOTE: These are REDIMMED in Game Mode for missile velocities
          dim readyCount = x               
          rem ADMIN: Count of locked players
          dim charSelectAnimTimer = w      
          rem ADMIN: Animation frame counter (REDIM - conflicts with missileVelX in Game Mode)
          dim charSelectAnimState = x      
          rem ADMIN: Current animation state (REDIM - conflicts with readyCount, but readyCount only used in character select)
          dim charSelectAnimIndex = y      
          rem ADMIN: Which character animating (REDIM - available in ADMIN)
          dim charSelectAnimFrame = z      
          rem ADMIN: Current frame in sequence (REDIM - available in ADMIN)

          rem =================================================================
          rem ADMIN MODE - Standard RAM (var0-var47) - sorted numerically
          rem =================================================================
          
          rem ADMIN: Character selection state (var37-var38)
          rem NOTE: These are REDIMMED in Game Mode for playerAttackCooldown
          dim charSelectCharIndex = var37   
          rem ADMIN: Currently selected character index (0-15) for preview (REDIMMED - Game Mode uses var37 for playerAttackCooldown[0])
          dim charSelectPlayer = var38      
          rem ADMIN: Which player is currently selecting (1-4) (REDIMMED - Game Mode uses var38 for playerAttackCooldown[1])
          
          rem ADMIN: Level select variables (var24-var27)
          rem NOTE: These are REDIMMED in Game Mode for animationCounter (var24-var27)
          dim levelPreviewData = var24      
          rem ADMIN: Level preview state (REDIMMED - Game Mode uses var24 for animationCounter[0])
          dim levelScrollOffset = var25     
          rem ADMIN: Scroll position (REDIMMED - Game Mode uses var25 for animationCounter[1])
          dim levelCursorPos = var26        
          rem ADMIN: Cursor position (REDIMMED - Game Mode uses var26 for animationCounter[2])
          dim levelConfirmTimer = var27     
          rem ADMIN: Confirmation timer (REDIMMED - Game Mode uses var27 for animationCounter[3])

          rem ADMIN: Preamble screen variables (var28-var32)
          rem NOTE: These are REDIMMED in Game Mode for playerVelocityY (8.8 fixed-point, uses var28-var35)
          dim preambleTimer = var28         
          rem ADMIN: Screen timer (REDIMMED - Game Mode uses var28-var31 for playerVelocityY high bytes)
          dim preambleState = var29         
          rem ADMIN: Which preamble (REDIMMED - Game Mode uses var29 for playerVelocityY[1] high byte)
          dim musicPlaying = var30          
          rem ADMIN: Music status (REDIMMED - Game Mode uses var30 for playerVelocityY[2] high byte)
          dim musicPosition = var31         
          rem ADMIN: Current note (REDIMMED - Game Mode uses var31 for playerVelocityY[3] high byte)
          dim musicTimer = var32            
          rem ADMIN: Music frame counter (REDIMMED - Game Mode uses var32-var35 for playerVelocityY low bytes)

          rem ADMIN: Title screen parade (var33-var36)
          rem NOTE: These are REDIMMED in Game Mode for currentAnimationSeq (var33-var36, but var37-var40 for playerAttackCooldown)
          dim titleParadeTimer = var33     
          rem ADMIN: Parade timing (REDIMMED - Game Mode uses var33 for currentAnimationSeq[0])
          dim titleParadeChar = var34      
          rem ADMIN: Current parade character (REDIMMED - Game Mode uses var34 for currentAnimationSeq[1])
          dim titleParadeX = var35         
          rem ADMIN: Parade X position (REDIMMED - Game Mode uses var35 for currentAnimationSeq[2])
          dim titleParadeActive = var36    
          rem ADMIN: Parade active flag (REDIMMED - Game Mode uses var36 for currentAnimationSeq[3])

          rem =================================================================
          rem GAME MODE VARIABLES (may be re-used in Admin Mode for other purposes)
          rem =================================================================
          rem These variables are ONLY valid on Game Mode screens (GameMode 6)
          rem =================================================================
          
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
          
          rem playerState[0-3] = player1State, player2State, player3State, player4State
          rem Packed player data: Facing (1 bit), State flags (3 bits), Animation (4 bits)
          rem playerState byte format: [Animation:4][Recovery:1][Jumping:1][Guarding:1][Facing:1]
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
          
          rem playerHealth[0-3] = player1Health, player2Health, player3Health, player4Health
          dim playerHealth = var12
          dim player1Health = var12
          dim player2Health = var13
          dim player3Health = var14
          dim player4Health = var15

          rem playerRecoveryFrames[0-3] - Recovery/hitstun frame counters
          dim playerRecoveryFrames = var16
          dim player1RecoveryFrames = var16
          dim player2RecoveryFrames = var17
          dim player3RecoveryFrames = var18
          dim player4RecoveryFrames = var19
          
          rem playerVelocityX[0-3] = 8.8 fixed-point X velocity
          rem High byte (integer part) in zero-page for fast access every frame
          dim playerVelocityX = var20
          dim player1VelocityX = var20
          dim player2VelocityX = var21
          dim player3VelocityX = var22
          dim player4VelocityX = var23
          rem High bytes (integer part) in zero-page var20-var23
          dim playerVelocityX_lo = var24
          rem Low bytes (fractional part) in zero-page var24-var27 (freed by moving animation vars)
          rem Access: playerVelocityX[i] = high byte, playerVelocityX_lo[i] = low byte (both in ZPRAM!)
          
          rem playerVelocityY[0-3] = 8.8 fixed-point Y velocity
          rem Both high and low bytes in zero-page for fast access every frame
          dim playerVelocityY = var28.8.8
          rem Game Mode: 8.8 fixed-point Y velocity (8 bytes) - var28-var35 in zero-page
          rem var28-var31 = high bytes, var32-var35 = low bytes
          rem Array accessible as playerVelocityY[0-3] and playerVelocityY_lo[0-3] (all in ZPRAM!)
          
          rem playerSubpixelX[0-3] = 8.8 fixed-point X position
          rem Updated every frame but accessed less frequently than velocity, so SCRAM is acceptable
          dim playerSubpixelX = w049.8.8
          rem Game Mode: 8.8 fixed-point X position (8 bytes) - SCRAM w049-w056
          rem Array accessible as playerSubpixelX[0-3] and playerSubpixelX_lo[0-3]
          
          rem playerSubpixelY[0-3] = 8.8 fixed-point Y position
          dim playerSubpixelY = w057.8.8
          rem Game Mode: 8.8 fixed-point Y position (8 bytes) - SCRAM w057-w064
          rem Array accessible as playerSubpixelY[0-3] and playerSubpixelY_lo[0-3]
          
          rem =================================================================
          rem GAME MODE - Standard RAM (var24-var47) - sorted numerically
          rem =================================================================
          
          rem Game Mode: Animation system variables (moved to SCRAM - updated at 10fps, not every frame)
          rem NOTE: Animation vars updated at 10fps (every 6 frames), so SCRAM access cost is acceptable
          rem Freed var24-var31 and var33-var36 (12 bytes) for physics variables that update every frame
          dim animationCounter_W = w077
          dim animationCounter_R = r077
          dim animationCounter = w077
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame counter (4 bytes) - SCRAM w077-w080
          dim currentAnimationFrame_W = w081
          dim currentAnimationFrame_R = r081
          dim currentAnimationFrame = w081
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in sequence (4 bytes) - SCRAM w081-w084
          dim currentAnimationSeq_W = w085
          dim currentAnimationSeq_R = r085
          dim currentAnimationSeq = w085
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current animation sequence (4 bytes) - SCRAM w085-w088
          
          rem Game Mode: Attack cooldown timers (var37-var40 = 4 bytes)
          rem PERFORMANCE CRITICAL: Checked every frame for attack availability
          dim playerAttackCooldown = var37
          rem Array accessible as playerAttackCooldown[0] through playerAttackCooldown[3] - ZPRAM for performance
          rem NOTE: var37-var40 used for playerAttackCooldown (Game Mode), var37-var38 used for charSelect (Admin Mode)
          
          rem Game Mode: Additional game state variables (moved to SCRAM - less performance critical)
          rem NOTE: These are accessed infrequently (elimination/win screen only), safe in SCRAM
          rem Moved from var24-var31 to SCRAM to free ZPRAM for animation vars
          dim playersRemaining_W = w016
          dim playersRemaining_R = r016
          dim playersRemaining = w016
          rem Game Mode: Count of active players (SCRAM - low frequency access)
          dim gameEndTimer_W = w018
          dim gameEndTimer_R = r018
          dim gameEndTimer = w018
          rem Game Mode: Countdown to game end screen (SCRAM)
          dim eliminationEffectTimer_W = w019
          dim eliminationEffectTimer_R = r019
          dim eliminationEffectTimer = w019
          rem Game Mode: Visual effect timers (single byte, bits for each player) (SCRAM)
          dim eliminationOrder_W = w040
          dim eliminationOrder_R = r040
          dim eliminationOrder = w040
          rem Game Mode: Order players were eliminated [0-3] (packed into 4 bits) (SCRAM)
          dim eliminationCounter_W = w041
          dim eliminationCounter_R = r041
          dim eliminationCounter = w041
          rem Game Mode: Counter for elimination sequence (SCRAM)
          dim winnerPlayerIndex_W = w042
          dim winnerPlayerIndex_R = r042
          dim winnerPlayerIndex = w042
          rem Game Mode: Index of winning player (0-3) (SCRAM)
          dim displayRank_W = w043
          dim displayRank_R = r043
          dim displayRank = w043
          rem Game Mode: Current rank being displayed (1-4) (SCRAM)
          dim winScreenTimer_W = w044
          dim winScreenTimer_R = r044
          dim winScreenTimer = w044
          rem Game Mode: Win screen display timer (SCRAM)
          
          rem =================================================================
          rem GAME MODE - Standard RAM (a-z) - sorted alphabetically
          rem =================================================================
          
          rem Game Mode: Missile active flags - bit-packed into single byte (standard RAM)
          rem Format: [M4Active:1][M3Active:1][M2Active:1][M1Active:1][unused:4]
          rem Bit 0 = Missile1 active, Bit 1 = Missile2 active, etc.
          dim missileActive = i
          rem Game Mode: Missile active flags (standard RAM)

          rem Game Mode: Missile X positions [0-3] for players 1-4 (standard RAM a,b,c,d)
          rem NOTE: These are REDIMMED in Admin Mode for fall animation variables
          dim missileX = a                  
          rem Array accessible as missileX[0] through missileX[3]

          rem Game Mode: Missile lifetime counters [0-3] - frames remaining
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for "until collision"
          rem PERFORMANCE: Moved to SCRAM since accessed less frequently than other missile vars
          rem NOTE: console7800Detected (COMMON) uses ’e’ in standard RAM, missileLifetime moved to SCRAM to avoid conflict
          dim missileLifetime_W = w045
          dim missileLifetime_R = r045
          dim missileLifetime = w045
          rem Game Mode: Missile lifetime array (4 bytes) - SCRAM w045-w048 for performance
          rem Array accessible as missileLifetime[0] through missileLifetime[3]

          rem Game Mode: Missile velocities [0-3] for X and Y axes (standard RAM w,x)
          rem NOTE: These are REDIMMED in Admin Mode for character select animation
          rem Stored velocities for bounce calculations and physics updates
          dim missileVelX = w
          rem Game Mode: Missile X velocity array (4 bytes) - REDIM from charSelectAnimTimer
          dim missileVelY = x
          rem Game Mode: Missile Y velocity array (4 bytes) - REDIM from charSelectAnimState

          rem Missile momentum stored in temp variables during UpdateMissiles subroutine
          rem temp1 = current player index being processed
          rem temp2 = missileX delta (momentum)
          rem temp3 = missileY delta (momentum)
          rem temp4 = scratch for collision checks
          rem These are looked up from character data each frame and stored in missileVelX/Y

          rem =================================================================
          rem GAME MODE - SCRAM (r000-r127/w000-w127) - sorted numerically
          rem =================================================================
          
          rem Game Mode: Missile Y positions [0-3] - using SCRAM (SuperChip RAM)
          rem Stored in w000-w003 for players 1-4
          rem Using SCRAM allows all 4 missile Y positions
          dim missileY = w000
          rem Game Mode: Missile Y position array (4 bytes) - SCRAM w000-w003
          rem NOTE: batariBASIC uses array syntax - missileY[0] = w000, missileY[1] = w001, etc.

          rem Game Mode: Player timers array [0-3] - used for guard cooldowns and other timers
          rem SCRAM allocated since var44-var47 already used by playerAttackCooldown
          dim playerTimers = w004
          rem Game Mode: Player timers array (4 bytes) - SCRAM w004-w007
          rem Array accessible as playerTimers[0] through playerTimers[3]

          rem PlayerEliminated[0-3] - Bit flags for eliminated players
          rem Bit 0 = Player 1, Bit 1 = Player 2, Bit 2 = Player 3, Bit 3 = Player 4
          rem Set when player health reaches 0, prevents respawn/reentry
          rem NOTE: w012 is used by harpyFlightEnergy array, so using w015 instead
          dim playersEliminated = w015
          rem GAME: Eliminated player bit flags (SCRAM - low frequency access)

          rem Character-specific state flags for special mechanics (SCRAM)
          dim characterStateFlags = w013
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 character state bits (4 bytes)
          rem Bit 0: RoboTito ceiling latched
          rem Bit 1: Harpy in flight mode
          rem Bit 2: Harpy in dive mode
          rem Bit 3-7: Reserved for future character mechanics

          rem Missile angular velocity for curling stone rotation (SCRAM)
          dim missileAngularVel = w017
          rem [0-3] angular velocity for rotation effects (4 bytes, reserved for future)

          rem Harpy flight energy/duration counters (SCRAM)
          dim harpyFlightEnergy_W = w009
          dim harpyFlightEnergy_R = r009
          dim harpyFlightEnergy = w009
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 flight energy remaining (4 bytes: w009-w012)
          rem Decrements on each flap, resets on landing, maximum value 60 (1 second at 60fps)
          rem Array accessible as harpyFlightEnergy[0] through harpyFlightEnergy[3]
          
          rem Last flap frame tracker for rapid tap detection (SCRAM)
          dim harpyLastFlapFrame_W = w023
          dim harpyLastFlapFrame_R = r023
          dim harpyLastFlapFrame = w023
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 last flap frame counter (4 bytes: w023-w026)
          rem Used to detect rapid UP tapping
          rem Array accessible as harpyLastFlapFrame[0] through harpyLastFlapFrame[3]

          rem =================================================================
          rem ADMIN MODE - SCRAM (r000-r127/w000-w127) - sorted numerically
          rem =================================================================
          
          rem ADMIN: Random character selection flags (SCRAM - used in character select)
          dim randomSelectFlags_W = w027
          dim randomSelectFlags_R = r027
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 random selection in progress flags (4 bytes: w027-w030)
          rem Bit 7 = handicap flag (1 if down+fire was held), bits 0-6 unused
          rem Array accessible as randomSelectFlags[0] through randomSelectFlags[3]
          
          rem ADMIN: Character select animation frame counters (SCRAM - used in character select)
          dim charSelectPlayerAnimFrame_W = w028
          dim charSelectPlayerAnimFrame_R = r028
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame counters (4 bytes: w028-w031)
          rem Frame counters for idle/walk animation cycles in character select
          rem Array accessible as charSelectPlayerAnimFrame[0] through charSelectPlayerAnimFrame[3]
          
          rem ADMIN: Character select animation sequence flags (SCRAM - used in character select)
          dim charSelectPlayerAnimSeq_W = w032
          dim charSelectPlayerAnimSeq_R = r032
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation sequence flags (4 bytes: w032-w035)
          rem Bit 0: 0=idle, 1=walk. Toggles every 60 frames
          rem Array accessible as charSelectPlayerAnimSeq[0] through charSelectPlayerAnimSeq[3]

          rem =================================================================
          rem TODO / FUTURE EXPANSION
          rem =================================================================
          
          rem playerDamage[0-3] = Player1Damage, Player2Damage, Player3Damage, Player4Damage
          rem Base damage per player (used in combat calculations)
          rem NOTE: Currently shares k,l,m with playerChar - must be recalculated when needed
          rem TODO: Allocate proper array space for playerDamage
          
          rem NOTE: var0-3 used by playerX (core gameplay, cannot redim)
          rem NOTE: var4-7 used by playerY (core gameplay, cannot redim)
          rem NOTE: var8-11 used by playerState (core gameplay, cannot redim)
          rem NOTE: var12-15 used by playerHealth (core gameplay, cannot redim)
          rem NOTE: var16-19 used by playerRecoveryFrames (core gameplay, cannot redim)
          rem NOTE: var20-23 used by playerVelocityX (core gameplay, cannot redim)
          
          rem GAME: Subpixel position and velocity system - IMPLEMENTED using batariBASIC 8.8 fixed-point
          rem NOTE: Using batariBASIC built-in 8.8 fixed-point support:
          rem       playerVelocityX: high bytes in ZPRAM (var20-var23), low bytes in ZPRAM (var24-var27)
          rem       playerVelocityY: both high and low bytes in ZPRAM (var28-var35)
          rem       playerSubpixelX/Y: in SCRAM (w049-w064, 16 bytes) - less frequently accessed
          
          rem =================================================================
          rem TEMPORARY WORKING VARIABLES - SCRAM (for temp7+ replacements)
          rem =================================================================
          rem These replace invalid temp7+ variables (only temp1-temp6 exist)
          rem Each variable has a semantically meaningful name based on its usage context
          rem =================================================================
          
          dim oldHealthValue_W = w089
          dim oldHealthValue_R = r089
          dim oldHealthValue = w089
          rem Old health value for byte-safe clamp checks (used in damage calculations)
          
          dim recoveryFramesCalc_W = w090
          dim recoveryFramesCalc_R = r090
          dim recoveryFramesCalc = w090
          rem Recovery frames calculation value (used in fall damage and hit processing)
          
          dim playerStateTemp_W = w091
          dim playerStateTemp_R = r091
          dim playerStateTemp = w091
          rem Temporary player state value for bit manipulation operations
          
          dim playfieldRow_W = w092
          dim playfieldRow_R = r092
          dim playfieldRow = w092
          rem Playfield row index for collision calculations
          
          dim playfieldCol_W = w093
          dim playfieldCol_R = r093
          dim playfieldCol = w093
          rem Playfield column index for collision calculations
          
          dim rowYPosition_W = w094
          dim rowYPosition_R = r094
          dim rowYPosition = w094
          rem Y position of playfield row (used in gravity calculations)
          
          dim rowCounter_W = w095
          dim rowCounter_R = r095
          dim rowCounter = w095
          rem Loop counter for row calculations
          
          dim characterHeight_W = w096
          dim characterHeight_R = r096
          dim characterHeight = w096
          rem Character height value from CharacterHeights table
          
          dim characterWeight_W = w097
          dim characterWeight_R = r097
          dim characterWeight = w097
          rem Character weight value from CharacterWeights table
          
          dim yDistance_W = w098
          dim yDistance_R = r098
          dim yDistance = w098
          rem Y distance between players for collision calculations
          
          dim halfHeight1_W = w099
          dim halfHeight1_R = r099
          dim halfHeight1 = w099
          rem Half height of first player for collision overlap calculation
          
          dim halfHeight2_W = w100
          dim halfHeight2_R = r100
          dim halfHeight2 = w100
          rem Half height of second player for collision overlap calculation
          
          dim totalHeight_W = w101
          dim totalHeight_R = r101
          dim totalHeight = w101
          rem Total height for collision overlap check (halfHeight1 + halfHeight2)
          
          dim totalWeight_W = w102
          dim totalWeight_R = r102
          dim totalWeight = w102
          rem Total weight of both players for momentum calculations
          
          dim weightDifference_W = w103
          dim weightDifference_R = r103
          dim weightDifference = w103
          rem Weight difference between players for impulse calculation
          
          dim impulseStrength_W = w104
          dim impulseStrength_R = r104
          dim impulseStrength = w104
          rem Calculated impulse strength for momentum transfer
          
          dim gravityRate_W = w105
          dim gravityRate_R = r105
          dim gravityRate = w105
          rem Gravity acceleration rate (normal or reduced)
          
          dim damageWeightProduct_W = w106
          dim damageWeightProduct_R = r106
          dim damageWeightProduct = w106
          rem Intermediate value: damage * weight (used in fall damage calculations)
          rem       Total: 16 bytes zero-page + 16 bytes SCRAM
          rem Animation vars (var24-var31, var33-var36) moved to SCRAM to free zero-page space
          rem batariBASIC automatically handles carry operations for 8.8 fixed-point arithmetic
