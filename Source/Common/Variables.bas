          rem ChaosFight - Source/Common/Variables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem MEMORY LAYOUT - MULTISPRITE KERNEL WITH SUPERCHIP:
          rem - Standard RAM: var0-var47 ($A4-$D3) = 48 bytes, a-z ($d4-$ed) = 26 bytes = 74 bytes always available
          rem - SuperChip RAM (SCRAM): Accessed via r000-r127/w000-w127 ($1000-$107F physical RAM) = 128 bytes
          rem   NOTE: There is NO var48-var127! SuperChip RAM is accessed via r000-r127/w000-w127 only!
          rem - MULTISPRITE KERNEL: Playfield data is stored in ROM (not RAM), so playfield uses ZERO bytes of RAM
          rem   This means ALL 128 bytes of SCRAM (r000-r127/w000-w127) are available at all times!
          rem   NOTE: Multisprite playfield is symmetrical (repeated/reflected), not asymmetrical
          rem - Variable reuse: w-z used for CharSelectAnim* during select, Missile* during gameplay

          rem =================================================================
          rem VARIABLE MEMORY LAYOUT - DUAL CONTEXT SYSTEM
          rem =================================================================
          
          rem ChaosFight uses TWO memory contexts that never overlap:
          rem   1. Admin Mode: Title, preambles, level select (GameModes 0,1,2,5)
          rem   2. Game Mode: Character select, falling animation, gameplay, winner (GameModes 3,4,6,7)
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
          rem   - var0-var23: Different in Admin Mode vs Game Mode
          rem   - w-z: Animation vars (Admin Mode) or Missile positions (Game Mode)
          rem   - i: readyCount (Admin Mode) or MissilePackedData (Game Mode)
          rem =================================================================
          
          rem =================================================================
          rem COMMON VARS (Used in BOTH Admin Mode and Game Mode)
          rem =================================================================
          rem These variables maintain their values across context switches
          rem =================================================================
          
          rem Built-in variables (NO DIM NEEDED - already exist in batariBasic):
          rem   temp1, temp2, temp3, temp4, temp5, temp6 - temporary storage
          rem   qtcontroller - Quadtari multiplexing state (0 or 1)
          rem   frame - frame counter (increments every frame)
          
          rem =================================================================
          rem COMMON VARS - Standard RAM (a-z)
          rem =================================================================
          
          rem Fall animation variables (used during falling animation screen)
          dim fallFrame = a
          dim fallSpeed = b
          dim fallComplete = c
          dim activePlayers = d

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
#ifndef TV_SECAM
          dim colorBWOverride = q     
          rem 7800 only: manual Color/B&W override (not used in SECAM)
#endif
          dim pauseButtonPrev = r
          rem Previous frame pause button state
          
          rem Console switch handling (used in both Admin Mode and Game Mode)
          dim colorBWPrevious_W = w008
          dim colorBWPrevious_R = r008
          rem Previous state of Color/B&W switch (for detecting changes) - SCRAM since low frequency use
          
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
          rem REDIMMED VARIABLES - ADMIN MODE ONLY
          rem =================================================================
          rem These variables are ONLY valid on title/preamble/select screens!
          rem They get REDIMMED for different purposes during gameplay.
          rem =================================================================
          
          rem Admin Mode: Character select and title screen animation (Standard RAM)
          rem REDIM variables w,x,y,z for character select animation
          dim readyCount = x               
          rem ADMIN: Count of locked players
          dim charSelectAnimTimer = w      
          rem ADMIN: Animation frame counter (REDIM - conflicts with selectedLevel in SHARED)
          dim charSelectAnimState = x      
          rem ADMIN: Current animation state (REDIM - conflicts with readyCount, but readyCount only used in character select)
          dim charSelectAnimIndex = y      
          rem ADMIN: Which character animating (REDIM - available in ADMIN)
          dim charSelectAnimFrame = z      
          rem ADMIN: Current frame in sequence (REDIM - available in ADMIN)
          
          rem ADMIN: Character selection state (standard RAM)
          dim charSelectCharIndex = var37   
          rem ADMIN: Currently selected character index (0-15) for preview
          dim charSelectPlayer = var38      
          rem ADMIN: Which player is currently selecting (1-4)
          
          rem ADMIN: Level select variables (standard RAM var0-var23)
          dim levelPreviewData = var24      
          rem ADMIN: Level preview state (standard RAM var24)
          dim levelScrollOffset = var25     
          rem ADMIN: Scroll position (standard RAM var25)
          dim levelCursorPos = var26        
          rem ADMIN: Cursor position (standard RAM var26)
          dim levelConfirmTimer = var27     
          rem ADMIN: Confirmation timer (standard RAM var27)
          
          rem ADMIN: Preamble screen variables (standard RAM var28-var31)
          dim preambleTimer = var28         
          rem ADMIN: Screen timer (standard RAM var28)
          dim preambleState = var29         
          rem ADMIN: Which preamble (standard RAM var29)
          dim musicPlaying = var30          
          rem ADMIN: Music status (standard RAM var30)
          dim musicPosition = var31         
          rem ADMIN: Current note (standard RAM var31)
          dim musicTimer = var32            
          rem ADMIN: Music frame counter (standard RAM var32)
          
          rem ADMIN: Title screen parade (standard RAM var33-var36)
          dim titleParadeTimer = var33     
          rem ADMIN: Parade timing (standard RAM var33)
          dim titleParadeChar = var34      
          rem ADMIN: Current parade character (standard RAM var34)
          dim titleParadeX = var35         
          rem ADMIN: Parade X position (standard RAM var35)
          dim titleParadeActive = var36    
          rem ADMIN: Parade active flag (standard RAM var36)
          
          rem =================================================================
          rem GAME MODE VARIABLES (Standard RAM + ALL SCRAM)
          rem =================================================================
          rem Available during gameplay (and all screens):
          rem   - Standard RAM: var0-var47, a-z (74 bytes) - always available
          rem   - SCRAM: r000-r127/w000-w127 (128 bytes) - ALL available (playfield in ROM!)
          rem   - TOTAL: 202 bytes available
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
          
          rem playerDamage[0-3] = Player1Damage, Player2Damage, Player3Damage, Player4Damage
          rem Base damage per player (used in combat calculations)
          rem NOTE: Need to find available space - currently using k,l,m,n which conflict with playerChar
          rem Temporary solution: Use temp variables during combat calculations
          rem TODO: Allocate proper array space for playerDamage
          
          rem PlayerEliminated[0-3] - Bit flags for eliminated players
          rem Bit 0 = Player 1, Bit 1 = Player 2, Bit 2 = Player 3, Bit 3 = Player 4
          rem Set when player health reaches 0, prevents respawn/reentry
          dim playersEliminated = i           
          rem GAME: Eliminated player bit flags (standard RAM, REDIM from pauseButtonPrev)
          
          rem playerRecoveryFrames[0-3] - Recovery/hitstun frame counters
          dim playerRecoveryFrames = var16
          dim player1RecoveryFrames = var16
          dim player2RecoveryFrames = var17
          dim player3RecoveryFrames = var18
          dim player4RecoveryFrames = var19
          
          rem NOTE: var0-3 used by playerX (core gameplay, cannot redim)
          rem NOTE: var4-7 used by playerY (core gameplay, cannot redim)
          rem NOTE: var8-11 used by playerState (core gameplay, cannot redim)
          rem NOTE: var12-15 used by playerHealth (core gameplay, cannot redim)
          rem NOTE: var16-19 used by playerRecoveryFrames (core gameplay, cannot redim)
          rem NOTE: var20-23 available for additional gameplay variables
          
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
          rem GAME MODE VARIABLES - Standard RAM (var24-var47 and REDIMMED a-z)
          rem =================================================================
          rem All Game Mode variables must use standard RAM only!
          rem var0-var23 used by core player arrays (cannot redim)
          rem var24-var47 available for additional gameplay variables
          rem a-z can be REDIMMED from Admin Mode use
          rem =================================================================
          
          rem Game Mode: Additional game state variables (standard RAM var24-var31)
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
          
          rem Game Mode: Animation system variables (standard RAM var32-var43 = 12 bytes)
          rem 10fps character animation with platform-specific timing
          dim animationCounter = var32
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame counter (4 bytes)
          dim currentAnimationFrame = var36
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in sequence (4 bytes)
          dim currentAnimationSeq = var40
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current animation sequence (4 bytes)
          
          rem GAME: Subpixel position system - TOO LARGE for standard RAM (32 bytes needed)
          rem NOTE: PlayerSubpixelX, PlayerSubpixelY, PlayerVelocityX, PlayerVelocityY
          rem These require 32 bytes total but only 16 bytes available (var44-var47 = 4 bytes left)
          rem SOLUTION: Use playerX/playerY directly (8-bit) and calculate subpixel/velocity in temp vars
          rem OR: Store only high bytes in var44-var47 and calculate low bytes on-the-fly
          rem Current implementation uses temp variables during movement calculations
          
          rem Game Mode: Attack cooldown timers (standard RAM var44-var47 = 4 bytes)
          dim playerAttackCooldown = var44
          rem Array accessible as playerAttackCooldown[0] through playerAttackCooldown[3]
          
          
          rem Game Mode: Player timers array [0-3] - used for guard cooldowns and other timers
          rem NOTE: Must be declared after playerAttackCooldown if we want to use array syntax
          rem Currently playerAttackCooldown uses individual vars, so playerTimers can reuse them
          rem Using alias: playerTimers = playerAttackCooldown (same 4 bytes)
          rem Actually, playerTimers needs its own space - using remaining standard RAM
          rem But we're at var44-var47 already used... need to check what's available
          rem SOLUTION: playerTimers[0-3] uses SCRAM w004-w007
          dim playerTimers = w004
          rem Game Mode: Player timers array [0]=P1, [1]=P2, [2]=P3, [3]=P4 (SCRAM w004-w007)
          rem NOTE: batariBASIC uses array syntax - playerTimers[0] = w004, playerTimers[1] = w005, etc.
          
          rem Game Mode: Base damage per hit - calculated from character data, stored temporarily
          rem NOTE: Can be looked up from character data tables rather than stored persistently
          rem Using temp variables during damage calculation if needed
          
          rem =================================================================
          rem MISSILE SYSTEM VARIABLES (4 missiles, one per player)
          rem =================================================================
          rem Each player can have one active missile/attack visual at a time.
          rem This includes both ranged projectiles AND melee attack visuals
          rem (e.g., sword sprite that appears briefly during attack).

          rem Game Mode: Missile X positions [0-3] for players 1-4 (standard RAM - REDIMMED from Admin Mode)
          rem Using standard RAM variables that are REDIMMED from Admin Mode use
          dim missileX = a                  
          rem Array accessible as missileX[0] through missileX[3] - reuses fallFrame, fallSpeed, fallComplete, activePlayers
          
          rem Game Mode: Missile Y positions [0-3] - using SCRAM (SuperChip RAM)
          rem Stored in w000-w003 (r000-r003 read ports) for players 1-4
          rem Using SCRAM allows all 4 missile Y positions
          dim missileY = w000
          rem Game Mode: Missile Y position array (4 bytes) - SCRAM w000-w003
          rem NOTE: batariBASIC uses array syntax - missileY[0] = w000, missileY[1] = w001, etc.
          
          rem Game Mode: Missile active flags - bit-packed into single byte (standard RAM)
          rem Format: [M4Active:1][M3Active:1][M2Active:1][M1Active:1][unused:4]
          rem Bit 0 = Missile1 active, Bit 1 = Missile2 active, etc.
          dim missileActive = i             
          rem Game Mode: REDIM - reuses pauseButtonPrev (standard RAM)
          
          rem Game Mode: Missile lifetime counters [0-3] - frames remaining (standard RAM - REDIMMED)
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for "until collision"
          rem Packed into 2 bytes: high nybble = P1/P2, low nybble = P3/P4
          dim missileLifetime = e           
          rem Game Mode: REDIM - reuses console7800Detected (standard RAM)
          rem Using nybble packing: missileLifetime[0] = P1/P2, missileLifetime[1] = P3/P4
          
          rem Game Mode: Missile velocities [0-3] for X and Y axes (standard RAM - REDIMMED)
          rem Stored velocities for bounce calculations and physics updates
          rem Using remaining standard RAM variables
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