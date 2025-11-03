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
          rem   - PlayerChar[0-3], PlayerLocked[0-3]
          rem   - selectedChar1-4, selectedArena
          rem   - QuadtariDetected
          rem   - temp1-4, qtcontroller, frame (built-ins)
          
          rem REDIMMED VARIABLES (different meaning per context):
          rem   - var0-var23: Different in Admin Mode vs Game Mode
          rem   - w-z: Animation vars (Admin Mode) or Missile positions (Game Mode)
          rem   - i: ReadyCount (Admin Mode) or MissilePackedData (Game Mode)
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
          dim FallFrame = a
          dim FallSpeed = b
          dim FallComplete = c
          dim ActivePlayers = d

          rem Game state variables
          dim GameState = g
          dim GameMode = p
          rem 0 = normal play, 1 = paused
          
          rem Console and controller detection (set during ADMIN, read during GAME)
          dim Console7800Detected = e
          rem 1 if running on Atari 7800
          dim SystemFlags = f
          rem System flags: $80=7800 console, other bits reserved
          dim ControllerStatus = h
          rem Packed controller status bits: $80=Quadtari, $01=LeftGenesis, $02=LeftJoy2b+, $04=RightGenesis, $08=RightJoy2b+
          rem HandicapMode - defined locally in CharacterSelect.bas as temp1 (local scope only)
#ifndef TV_SECAM
          dim ColorBWOverride = q     
          rem 7800 only: manual Color/B&W override (not used in SECAM)
#endif
          dim PauseButtonPrev = r
          rem Previous frame pause button state
          
          rem Console switch handling (used in both Admin Mode and Game Mode)
          dim ColorBWPrevious = w001
          rem Previous state of Color/B&W switch (for detecting changes) - SCRAM since low frequency use
          
          rem Character selection results (set during ADMIN, read during GAME)
          dim PlayerChar = j    
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using j,k,l,m
          dim PlayerDamage = k   
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using k,l,m (base damage per player)
          rem NOTE: Shares k,l,m with PlayerChar[1-3] - must be recalculated when needed
          dim PlayerLocked = n  
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using n,o,p,q (p,q may be used by ColorBWOverride)
          rem selectedChar1-4/Level all in SCRAM - infrequently accessed (only during mode transitions)
          dim selectedChar1 = w011
          rem ADMIN/GAME: Player 1 character selection (SCRAM w011, read via r011)
          dim selectedChar2 = w012
          rem ADMIN/GAME: Player 2 character selection (SCRAM w012, read via r012)
          dim selectedChar3 = w008
          rem ADMIN/GAME: Player 3 character selection (SCRAM w008, read via r008)
          dim selectedChar4 = w009
          rem ADMIN/GAME: Player 4 character selection (SCRAM w009, read via r009)
          dim selectedArena = w010
          rem ADMIN/GAME: Selected arena (SCRAM w010, read via r010)

          rem Font rendering temporary variables (Common - used in Admin and Game mode)
          rem NOTE: These reuse temp variables where possible, separate vars when needed
          dim DigitOffset = temp6
          rem Font: Byte offset into font data (digit * 16) - uses temp6
          dim fontRow = var47
          rem Font: Current row being rendered (0-15) - using var47 as scratch
          dim fontDataIndex = var46
          rem Font: Current data index into font table - using var46 as scratch
          
          rem =================================================================
          rem REDIMMED VARIABLES - ADMIN MODE ONLY
          rem =================================================================
          rem These variables are ONLY valid on title/preamble/select screens!
          rem They get REDIMMED for different purposes during gameplay.
          rem =================================================================
          
          rem Admin Mode: Character select and title screen animation (Standard RAM)
          rem REDIM variables w,x,y,z for character select animation
          dim ReadyCount = x               
          rem ADMIN: Count of locked players
          dim CharSelectAnimTimer = w      
          rem ADMIN: Animation frame counter (REDIM - conflicts with selectedArena in SHARED)
          dim CharSelectAnimState = x      
          rem ADMIN: Current animation state (REDIM - conflicts with ReadyCount, but ReadyCount only used in character select)
          dim CharSelectAnimIndex = y      
          rem ADMIN: Which character animating (REDIM - available in ADMIN)
          dim CharSelectAnimFrame = z      
          rem ADMIN: Current frame in sequence (REDIM - available in ADMIN)
          
          rem ADMIN: Character selection state (standard RAM)
          dim CharSelectCharIndex = var37   
          rem ADMIN: Currently selected character index (0-15) for preview
          dim CharSelectPlayer = var38      
          rem ADMIN: Which player is currently selecting (1-4)
          
          rem ADMIN: Level select variables (standard RAM var0-var23)
          dim LevelPreviewData = var24      
          rem ADMIN: Level preview state (standard RAM var24)
          dim LevelScrollOffset = var25     
          rem ADMIN: Scroll position (standard RAM var25)
          dim LevelCursorPos = var26        
          rem ADMIN: Cursor position (standard RAM var26)
          dim LevelConfirmTimer = var27     
          rem ADMIN: Confirmation timer (standard RAM var27)
          dim LevelSelectHoldTimer = w014   
          rem ADMIN: Fire button hold timer for return to character select (SCRAM w014, read via r014)
          
          rem ADMIN: Preamble screen variables (standard RAM var28-var31)
          dim PreambleTimer = var28         
          rem ADMIN: Screen timer (standard RAM var28)
          dim PreambleState = var29         
          rem ADMIN: Which preamble (standard RAM var29)
          dim MusicPlaying = var30          
          rem ADMIN: Music status (standard RAM var30)
          dim MusicPosition = var31         
          rem ADMIN: Current note (standard RAM var31)
          dim MusicTimer = var32            
          rem ADMIN: Music frame counter (standard RAM var32)
          
          rem ADMIN: Title screen parade (standard RAM var33-var36)
          dim TitleParadeTimer = var33     
          rem ADMIN: Parade timing (standard RAM var33)
          dim TitleParadeChar = var34      
          rem ADMIN: Current parade character (standard RAM var34)
          dim TitleParadeX = var35         
          rem ADMIN: Parade X position (standard RAM var35)
          dim TitleParadeActive = var36    
          rem ADMIN: Parade active flag (standard RAM var36)
          dim TitleCopyrightTimer = w013   
          rem ADMIN: Copyright display timer (SCRAM w013, read via r013) - disappears at 5 seconds (300 frames)
          
          rem =================================================================
          rem GAME MODE VARIABLES (Standard RAM + ALL SCRAM)
          rem =================================================================
          rem Available during gameplay (and all screens):
          rem   - Standard RAM: var0-var47, a-z (74 bytes) - always available
          rem   - SCRAM: r000-r127/w000-w127 (128 bytes) - ALL available (playfield in ROM!)
          rem   - TOTAL: 202 bytes available
          rem =================================================================

          rem Player data arrays using batariBasic array syntax
          rem PlayerX[0-3] = Player1X, Player2X, Player3X, Player4X
          dim PlayerX = var0
          dim Player1X = var0
          dim Player2X = var1
          dim Player3X = var2
          dim Player4X = var3
          
          rem PlayerY[0-3] = Player1Y, Player2Y, Player3Y, Player4Y
          dim PlayerY = var4
          dim Player1Y = var4
          dim Player2Y = var5
          dim Player3Y = var6
          dim Player4Y = var7
          
          rem PlayerState[0-3] = Player1State, Player2State, Player3State, Player4State
          rem Packed player data: Facing (2 bits), State flags (4 bits), Attack type (2 bits)
          rem PlayerState byte format: [Facing:2][Attacking:1][Guarding:1][Jumping:1][Recovery:1][AttackType:2]
          dim PlayerState = var8
          dim Player1State = var8
          dim Player2State = var9
          dim Player3State = var10
          dim Player4State = var11
          
          rem PlayerHealth[0-3] = Player1Health, Player2Health, Player3Health, Player4Health
          dim PlayerHealth = var12
          dim Player1Health = var12
          dim Player2Health = var13
          dim Player3Health = var14
          dim Player4Health = var15
          
          rem PlayerDamage[0-3] = Player1Damage, Player2Damage, Player3Damage, Player4Damage
          rem Base damage per player (used in combat calculations)
          rem NOTE: Need to find available space - currently using k,l,m,n which conflict with PlayerChar
          rem Temporary solution: Use temp variables during combat calculations
          rem TODO: Allocate proper array space for PlayerDamage
          
          rem PlayerEliminated[0-3] - Bit flags for eliminated players
          rem Bit 0 = Player 1, Bit 1 = Player 2, Bit 2 = Player 3, Bit 3 = Player 4
          rem Set when player health reaches 0, prevents respawn/reentry
          dim PlayersEliminated = i           
          rem GAME: Eliminated player bit flags (standard RAM, REDIM from PauseButtonPrev)
          
          rem PlayerRecoveryFrames[0-3] - Recovery/hitstun frame counters
          dim PlayerRecoveryFrames = var16
          dim Player1RecoveryFrames = var16
          dim Player2RecoveryFrames = var17
          dim Player3RecoveryFrames = var18
          dim Player4RecoveryFrames = var19
          
          rem NOTE: var0-3 used by PlayerX (core gameplay, cannot redim)
          rem NOTE: var4-7 used by PlayerY (core gameplay, cannot redim)
          rem NOTE: var8-11 used by PlayerState (core gameplay, cannot redim)
          rem NOTE: var12-15 used by PlayerHealth (core gameplay, cannot redim)
          rem NOTE: var16-19 used by PlayerRecoveryFrames (core gameplay, cannot redim)
          rem NOTE: var20-23 available for additional gameplay variables
          
          rem PlayerMomentumX[0-3] = Horizontal momentum for knockback and physics
          dim PlayerMomentumX = var20
          dim Player1MomentumX = var20
          dim Player2MomentumX = var21
          dim Player3MomentumX = var22
          dim Player4MomentumX = var23
          
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
          dim PlayersRemaining = var24
          rem Game Mode: Count of active players
          dim GameEndTimer = var25
          rem Game Mode: Countdown to game end screen
          dim EliminationEffectTimer = var26
          rem Game Mode: Visual effect timers (single byte, bits for each player)
          dim EliminationOrder = var27
          rem Game Mode: Order players were eliminated [0-3] (packed into 4 bits)
          dim EliminationCounter = var28
          rem Game Mode: Counter for elimination sequence
          dim WinnerPlayerIndex = var29
          rem Game Mode: Index of winning player (0-3)
          dim DisplayRank = var30
          rem Game Mode: Current rank being displayed (1-4)
          dim WinScreenTimer = var31
          rem Game Mode: Win screen display timer
          
          rem Game Mode: Animation system variables (standard RAM var32-var43 = 12 bytes)
          rem 10fps character animation with platform-specific timing
          dim AnimationCounter = var32
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame counter (4 bytes)
          dim CurrentAnimationFrame = var36
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in sequence (4 bytes)
          dim CurrentAnimationSeq = var40
          rem Game Mode: [0]=P1, [1]=P2, [2]=P3, [3]=P4 current animation sequence (4 bytes)
          
          rem GAME: Subpixel position system - TOO LARGE for standard RAM (32 bytes needed)
          rem NOTE: PlayerSubpixelX, PlayerSubpixelY, PlayerVelocityX, PlayerVelocityY
          rem These require 32 bytes total but only 16 bytes available (var44-var47 = 4 bytes left)
          rem SOLUTION: Use PlayerX/PlayerY directly (8-bit) and calculate subpixel/velocity in temp vars
          rem OR: Store only high bytes in var44-var47 and calculate low bytes on-the-fly
          rem Current implementation uses temp variables during movement calculations
          
          rem Game Mode: Attack cooldown timers (standard RAM var44-var47 = 4 bytes)
          dim PlayerAttackCooldown = var44
          dim Player1AttackCooldown = var44
          dim Player2AttackCooldown = var45
          dim Player3AttackCooldown = var46
          dim Player4AttackCooldown = var47
          
          
          rem Game Mode: Player timers array [0-3] - used for guard cooldowns and other timers
          rem NOTE: Must be declared after PlayerAttackCooldown if we want to use array syntax
          rem Currently PlayerAttackCooldown uses individual vars, so PlayerTimers can reuse them
          rem Using alias: PlayerTimers = PlayerAttackCooldown (same 4 bytes)
          rem Actually, PlayerTimers needs its own space - using remaining standard RAM
          rem But we're at var44-var47 already used... need to check what's available
          rem SOLUTION: PlayerTimers[0-3] uses SCRAM (r004-r007, w004-w007)
          dim PlayerTimers = w004
          rem Game Mode: Player timers array [0]=P1, [1]=P2, [2]=P3, [3]=P4 (SCRAM w004-w007)
          
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
          dim MissileX = a                  
          dim Missile1X = a                 
          dim Missile2X = b                 
          dim Missile3X = c                 
          dim Missile4X = d                 
          rem Game Mode: REDIM - reuses FallFrame, FallSpeed, FallComplete, ActivePlayers
          
          rem Game Mode: Missile Y positions [0-3] - using SCRAM (SuperChip RAM)
          rem Stored in w000-w003 (r000-r003 read ports) for players 1-4
          rem Using SCRAM allows all 4 missile Y positions
          dim MissileY = w000
          rem Game Mode: Missile Y position array (4 bytes) - SCRAM w000-w003 (r000-r003)
          
          rem Game Mode: Missile active flags - bit-packed into single byte (standard RAM)
          rem Format: [M4Active:1][M3Active:1][M2Active:1][M1Active:1][unused:4]
          rem Bit 0 = Missile1 active, Bit 1 = Missile2 active, etc.
          dim MissileActive = i             
          rem Game Mode: REDIM - reuses PauseButtonPrev (standard RAM)
          
          rem Game Mode: Missile lifetime counters [0-3] - frames remaining (standard RAM - REDIMMED)
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for "until collision"
          rem Packed into 2 bytes: high nybble = P1/P2, low nybble = P3/P4
          dim MissileLifetime = e           
          rem Game Mode: REDIM - reuses Console7800Detected (standard RAM)
          rem Using nybble packing: MissileLifetime[0] = P1/P2, MissileLifetime[1] = P3/P4
          
          rem Game Mode: Missile velocities [0-3] for X and Y axes (standard RAM - REDIMMED)
          rem Stored velocities for bounce calculations and physics updates
          rem Using remaining standard RAM variables
          dim MissileVelX = w
          rem Game Mode: Missile X velocity array (4 bytes) - REDIM from CharSelectAnimTimer
          dim MissileVelY = x
          rem Game Mode: Missile Y velocity array (4 bytes) - REDIM from CharSelectAnimState

          rem Missile momentum stored in temp variables during UpdateMissiles subroutine
          rem temp1 = current player index being processed
          rem temp2 = MissileX delta (momentum)
          rem temp3 = MissileY delta (momentum)
          rem temp4 = scratch for collision checks
          rem These are looked up from character data each frame and stored in MissileVelX/Y

          rem Combat system temporary variables (Game Mode only - separate from missile variables)
          rem NOTE: These use dedicated variables l,m,o,y,z,var47 to avoid conflicts with missile system
          dim damage = l
          rem Combat: Damage value
          dim hit = m
          rem Combat: Hit result (1 = hit, 0 = miss)
          dim hitboxLeft = o
          rem Combat: Hitbox left edge
          dim hitboxRight = y
          rem Combat: Hitbox right edge
          dim hitboxTop = z
          rem Combat: Hitbox top edge
          dim hitboxBottom = var47
          rem Combat: Hitbox bottom edge (using var47 as scratch)
          dim defender = l
          rem Combat: Defender player index (reuses l)
          dim attacker = l
          rem Combat: Attacker player index (reuses l)
          dim guardTimer = l
          rem Combat: Guard timer value (reuses l)
          rem NOTE: defender, attacker, guardTimer, and damage all reuse variable 'l'
          rem This is safe because they are used sequentially in different subroutines