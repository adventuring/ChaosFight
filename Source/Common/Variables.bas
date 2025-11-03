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
          rem   - selectedChar1-4, selectedLevel
          rem   - QuadtariDetected
          rem   - temp1-4, qtcontroller, frame (built-ins)
          
          rem REDIMMED VARIABLES (different meaning per context):
          rem   - var24-var36: Shared between Admin Mode and Game Mode (intentional redim)
          rem   - a,b,c,d: Fall animation vars (Admin Mode) or MissileX (Game Mode)
          rem   - w-z: Animation vars (Admin Mode) or Missile velocities (Game Mode)
          rem   - e: console7800Detected (COMMON) or missileLifetime (Game Mode)
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
          dim selectedLevel = w
          
          rem =================================================================
          rem COMMON VARS - SCRAM (r000-r127/w000-w127) - sorted numerically
          rem =================================================================
          
          rem Console switch handling (used in both Admin Mode and Game Mode)
          dim colorBWPrevious_W = w008
          dim colorBWPrevious_R = r008
          rem Previous state of Color/B&W switch (for detecting changes) - SCRAM since low frequency use
          
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
          rem ADMIN: Animation frame counter (REDIM - conflicts with selectedLevel in COMMON)
          dim charSelectAnimState = x      
          rem ADMIN: Current animation state (REDIM - conflicts with readyCount, but readyCount only used in character select)
          dim charSelectAnimIndex = y      
          rem ADMIN: Which character animating (REDIM - available in ADMIN)
          dim charSelectAnimFrame = z      
          rem ADMIN: Current frame in sequence (REDIM - available in ADMIN)

          rem =================================================================
          rem ADMIN MODE - Standard RAM (var0-var47) - sorted numerically
          rem =================================================================
          
          rem ADMIN: Character selection state
          dim charSelectCharIndex = var37   
          rem ADMIN: Currently selected character index (0-15) for preview
          dim charSelectPlayer = var38      
          rem ADMIN: Which player is currently selecting (1-4)
          
          rem ADMIN: Level select variables (var24-var27)
          rem NOTE: These are REDIMMED in Game Mode for game state variables
          dim levelPreviewData = var24      
          rem ADMIN: Level preview state
          dim levelScrollOffset = var25     
          rem ADMIN: Scroll position
          dim levelCursorPos = var26        
          rem ADMIN: Cursor position
          dim levelConfirmTimer = var27     
          rem ADMIN: Confirmation timer

          rem ADMIN: Preamble screen variables (var28-var32)
          rem NOTE: These are REDIMMED in Game Mode for game state variables
          dim preambleTimer = var28         
          rem ADMIN: Screen timer
          dim preambleState = var29         
          rem ADMIN: Which preamble
          dim musicPlaying = var30          
          rem ADMIN: Music status
          dim musicPosition = var31         
          rem ADMIN: Current note
          dim musicTimer = var32            
          rem ADMIN: Music frame counter

          rem ADMIN: Title screen parade (var33-var36)
          rem NOTE: These are REDIMMED in Game Mode for animation variables
          dim titleParadeTimer = var33     
          rem ADMIN: Parade timing
          dim titleParadeChar = var34      
          rem ADMIN: Current parade character
          dim titleParadeX = var35         
          rem ADMIN: Parade X position
          dim titleParadeActive = var36    
          rem ADMIN: Parade active flag

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
          
          rem playerMomentumX[0-3] = Horizontal momentum for knockback and physics
          dim playerMomentumX = var20
          dim player1MomentumX = var20
          dim player2MomentumX = var21
          dim player3MomentumX = var22
          dim player4MomentumX = var23
          
          rem PlayerMomentumY[0-3] - Stored in temp variables during physics update (not persistent)
          rem Positive = downward, negative = upward
          rem Used by ApplyGravity and CheckFallDamage routines
          rem Values calculated and used within frame, not stored persistently
          
          rem =================================================================
          rem GAME MODE - Standard RAM (var24-var47) - sorted numerically
          rem =================================================================
          
          rem Game Mode: Additional game state variables (var24-var31)
          rem NOTE: These are REDIMMED in Admin Mode for level select, preamble, music
          dim playersRemaining = var24
          rem Game Mode: Count of active players
          dim gameEndTimer = var25
          rem Game Mode: Countdown to game end screen
          dim eliminationEffectTimer = var26
          rem Game Mode: Visual effect timers (single byte, bits for each player)
          dim eliminationOrder = var27
          rem Game Mode: Order players were eliminated [0-3] (packed into 4 bits)
          dim eliminationCounter = var28
          rem Game Mode: Counter for elimination sequence
          dim winnerPlayerIndex = var29
          rem Game Mode: Index of winning player (0-3)
          dim displayRank = var30
          rem Game Mode: Current rank being displayed (1-4)
          dim winScreenTimer = var31
          rem Game Mode: Win screen display timer
          
          rem Game Mode: Animation system variables (var32, var36, var40)
          rem NOTE: These are REDIMMED in Admin Mode for music timer and parade
          rem 10fps character animation with platform-specific timing
          dim animationCounter = var32
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame counter (4 bytes)
          dim currentAnimationFrame = var36
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in sequence (4 bytes)
          dim currentAnimationSeq = var40
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current animation sequence (4 bytes)
          
          rem Game Mode: Attack cooldown timers (var44-var47 = 4 bytes)
          dim playerAttackCooldown = var44
          rem Array accessible as playerAttackCooldown[0] through playerAttackCooldown[3]
          
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

          rem Game Mode: Missile lifetime counters [0-3] - frames remaining (standard RAM e)
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for "until collision"
          rem Packed into 2 bytes: high nybble = P1/P2, low nybble = P3/P4
          dim missileLifetime = e           
          rem Game Mode: REDIM - reuses console7800Detected (COMMON)
          rem Using nybble packing: missileLifetime[0] = P1/P2, missileLifetime[1] = P3/P4

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
          dim playersEliminated = w012
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
          rem NOTE: var20-23 used by playerMomentumX (core gameplay, cannot redim)
          
          rem GAME: Subpixel position system - TOO LARGE for standard RAM (32 bytes needed)
          rem NOTE: PlayerSubpixelX, PlayerSubpixelY, PlayerVelocityX, PlayerVelocityY
          rem These require 32 bytes total but only 16 bytes available (var44-var47 = 4 bytes left)
          rem SOLUTION: Use playerX/playerY directly (8-bit) and calculate subpixel/velocity in temp vars
          rem OR: Store only high bytes in var44-var47 and calculate low bytes on-the-fly
          rem Current implementation uses temp variables during movement calculations
