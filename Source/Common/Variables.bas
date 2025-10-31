          rem ChaosFight - Source/Common/Variables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem MEMORY LAYOUT - CRITICAL FOR PLAYFIELD COMPATIBILITY:
          rem - During gameplay (pfres=8): var24-var95 are used by playfield data
          rem - Only var0-var23 are available for game variables during gameplay
          rem - During title screens (pfres=12/32): var48+ used by playfield data
          rem - Standard RAM (a-z): 26 bytes always available
          rem - Variable reuse: w-z used for CharSelectAnim* during select, Missile* during gameplay

          rem =================================================================
          rem VARIABLE MEMORY LAYOUT - DUAL CONTEXT SYSTEM
          rem =================================================================

          rem ChaosFight uses TWO memory contexts that never overlap:
          rem   1. ADMIN context: Title, preambles, character select, level select
          rem   2. GAME context: Active gameplay

          rem This allows us to REDIM the same memory locations for different
          rem purposes depending on which screen we are on, maximizing our limited RAM!

          rem =================================================================
          rem STANDARD RAM (Available everywhere):
          rem   a-z = 26 variables

          rem SUPERCHIP RAM AVAILABILITY (with separate read/write ports):
          rem   SuperChip provides 128 bytes additional RAM ($1000-$107F)
          rem   Variables: var0-var127 (128 total)
          rem   Playfield storage at HIGH END, shifts based on pfres setting:

          rem   ADMIN screens (pfres=32): 
          rem     - Playfield uses top 128 bytes: var0-var127 (all 128 bytes!)
          rem     - Available during ADMIN: None from SuperChip (use standard RAM a-z)

          rem   GAME screens (pfres=8):
          rem     - Playfield uses top 32 bytes: var96-var127 (8 rows * 4 bytes)
          rem     - Available during GAME: var0-var95 (96 variables!)

          rem SHARED VARIABLES (needed in both contexts):
          rem   - PlayerChar[0-3], PlayerLocked[0-3]
          rem   - SelectedChar1-4, SelectedLevel
          rem   - QuadtariDetected
          rem   - temp1-4, qtcontroller, frame (built-ins)

          rem REDIMMED VARIABLES (different meaning per context):
          rem   - var0-var23: Different in ADMIN vs GAME
          rem   - w-z: Animation vars (ADMIN) or Missile positions (GAME)
          rem   - i: ReadyCount (ADMIN) or MissilePackedData (GAME)
          rem =================================================================

          rem =================================================================
          rem SHARED VARIABLES (Used in BOTH ADMIN and GAME contexts)
          rem =================================================================
          rem These variables maintain their values across context switches
          rem =================================================================
          
          rem Built-in variables (NO DIM NEEDED - already exist in batariBasic):
          rem   temp1, temp2, temp3, temp4, temp5, temp6 - temporary storage
          rem   qtcontroller - Quadtari multiplexing state (0 or 1)
          rem   frame - frame counter (increments every frame)
          
          rem Our variables (need dim):
          dim GameState = g    
          dim GameMode = p
          rem 0 = normal play, 1 = paused
          rem Console and controller detection (set during ADMIN, read during GAME)
          dim Console7800Detected = a 
          rem 1 if running on Atari 7800
          dim SystemFlags = c
          rem System flags: $80=7800 console, other bits reserved
          dim ControllerStatus = b
          rem Packed controller status bits: $80=Quadtari, $01=LeftGenesis, $02=LeftJoy2b+, $04=RightGenesis, $08=RightJoy2b+
#ifndef TV_SECAM
          dim ColorBWOverride = h     
          rem 7800 only: manual Color/B&W override (not used in SECAM)
#endif
          dim PauseButtonPrev = i     
          rem Previous frame pause button state
          
          rem Character selection results (set during ADMIN, read during GAME)
          dim PlayerChar = j    
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using j,k,l,m
          dim PlayerLocked = n  
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using n,o,p,q
          dim SelectedChar1 = r
          dim SelectedChar2 = s
          
          rem =================================================================
          rem ANIMATION SYSTEM VARIABLES
          rem =================================================================
          rem 10fps character animation with platform-specific timing
          dim AnimationCounter = t    
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 animation frame counter
          dim CurrentAnimationFrame = u
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 current frame in sequence
          dim CurrentAnimationSeq = v  
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 current animation sequence
          
          rem =================================================================
          rem SUBPIXEL POSITION SYSTEM
          rem =================================================================
          rem 16-bit subpixel positions for smooth movement
          rem Upper 8 bits = integer sprite position, Lower 8 bits = fractional
          dim PlayerSubpixelX = w     
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 16-bit X position
          dim PlayerSubpixelY = x     
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 16-bit Y position
          dim PlayerVelocityX = y     
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 16-bit X velocity
          dim PlayerVelocityY = z     
          rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 16-bit Y velocity
          dim SelectedChar3 = t
          dim SelectedChar4 = u
          dim SelectedLevel = v
          
          rem =================================================================
          rem REDIMMED VARIABLES - ADMIN CONTEXT ONLY
          rem =================================================================
          rem These variables are ONLY valid on title/preamble/select screens!
          rem They get REDIMMED for different purposes during gameplay.
          rem =================================================================
          
          rem ADMIN: Character select and title screen animation (Standard RAM)
          dim ReadyCount = i               
          rem ADMIN: Count of locked players
          dim CharSelectAnimTimer = w      
          rem ADMIN: Animation frame counter
          dim CharSelectAnimState = x      
          rem ADMIN: Current animation state
          dim CharSelectAnimIndex = y      
          rem ADMIN: Which character animating
          dim CharSelectAnimFrame = z      
          rem ADMIN: Current frame in sequence
          
          rem ADMIN: Title screen parade (SuperChip RAM var28-var47)
          dim TitleParadeTimer = var28     
          rem ADMIN: Parade timing
          dim TitleParadeChar = var29      
          rem ADMIN: Current parade character
          dim TitleParadeX = var30         
          rem ADMIN: Parade X position
          dim TitleParadeActive = var31    
          rem ADMIN: Parade active flag
          
          rem ADMIN: Level select variables (SuperChip RAM var0-var23)
          dim LevelPreviewData = var0      
          rem ADMIN: Level preview state
          dim LevelScrollOffset = var1     
          rem ADMIN: Scroll position
          dim LevelCursorPos = var2        
          rem ADMIN: Cursor position
          dim LevelConfirmTimer = var3     
          rem ADMIN: Confirmation timer
          
          rem ADMIN: Preamble screen variables (SuperChip RAM var4-var7)
          dim PreambleTimer = var4         
          rem ADMIN: Screen timer
          dim PreambleState = var5         
          rem ADMIN: Which preamble
          dim MusicPlaying = var6          
          rem ADMIN: Music status
          dim MusicPosition = var7         
          rem ADMIN: Current note
          dim MusicTimer = var8            
          rem ADMIN: Music frame counter
          
          rem =================================================================
          rem GAMEPLAY VARIABLES (SuperChip RAM - var0-var23 ONLY!)
          rem =================================================================
          rem CRITICAL: With pfres=8, playfield occupies var24-var95!
          rem We MUST stay within var0-var23 during gameplay or we will corrupt
          rem the playfield graphics!
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
          
          rem PlayerEliminated[0-3] - Bit flags for eliminated players
          rem Bit 0 = Player 1, Bit 1 = Player 2, Bit 2 = Player 3, Bit 3 = Player 4
          rem Set when player health reaches 0, prevents respawn/reentry
          dim PlayersEliminated = f           
          rem GAME: Eliminated player bit flags
          dim PlayersRemaining = var28         
          rem GAME: Count of active players  
          dim GameEndTimer = var29             
          rem GAME: Countdown to game end screen
          dim EliminationEffectTimer = var30   
          rem GAME: Visual effect timers [0-3]
          
          rem Elimination order tracking (1=first eliminated, 2=second, etc.)
          dim EliminationOrder = var31         
          rem GAME: Order players were eliminated [0-3]
          dim EliminationCounter = var32       
          rem GAME: Counter for elimination sequence
          
          rem Win screen variables
          dim WinnerPlayerIndex = var33        
          rem GAME: Index of winning player (0-3)
          dim DisplayRank = var34              
          rem GAME: Current rank being displayed (1-4)
          dim WinScreenTimer = var35           
          rem GAME: Win screen display timer
          
          rem PlayerRecoveryFrames[0-3] - Recovery/hitstun frame counters (was part of PlayerTimers)
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
          rem NOTE: var20-27 available for momentum (with pfres=8, have var0-95!)
          
          rem PlayerMomentumX[0-3] = Horizontal momentum for knockback and physics
          dim PlayerMomentumX = var20
          dim Player1MomentumX = var20
          dim Player2MomentumX = var21
          dim Player3MomentumX = var22
          dim Player4MomentumX = var23
          
          rem PlayerMomentumY[0-3] = Vertical momentum for gravity, jumping, and fall damage
          rem Positive = downward, negative = upward
          rem Used by PhysicsApplyGravity and CheckFallDamage routines
          dim PlayerMomentumY = var24
          dim Player1MomentumY = var24
          dim Player2MomentumY = var25
          dim Player3MomentumY = var26
          dim Player4MomentumY = var27
          
          rem =================================================================
          rem ADDITIONAL GAMEPLAY VARIABLES
          rem =================================================================
          rem These use the remaining var24+ space which is NOT used by
          rem playfield during gameplay (pfres=8 only uses var24-95 for playfield,
          rem but we stay within var0-23 for safety)

          rem Actually wait - var24+ conflicts with playfield!
          rem We need to use standard RAM (a-z) or find other redim opportunities
          rem =================================================================
          
          rem GAME: Vertical momentum - Using standard RAM since SuperChip is full
          rem Stored in temporary variables during physics update
          rem PlayerMomentumY values calculated and used within frame, not persistent
          rem Can use temp variables during PhysicsApplyGravity/CheckFallDamage routines
          
          rem =================================================================
          rem REDIMMED VARIABLES - GAME CONTEXT ONLY  
          rem =================================================================
          rem These variables REDIM memory used by ADMIN screens
          rem They are ONLY valid during active gameplay!
          rem NOTE: We cannot redim var0-19 (used by core player arrays)
          rem but we CAN redim var20-23 since we moved PlayerMomentumX there
          rem =================================================================
          
          rem GAME: Attack cooldown timers - Use f, g, h, i (standard RAM)
          rem Format: Counts down from 15-20 frames, 0 = can attack
          rem Note: i is used by MissileActive, so we use f,g,h and j for cooldowns
          dim PlayerAttackCooldown = f
          dim Player1AttackCooldown = f
          dim Player2AttackCooldown = g
          dim Player3AttackCooldown = h
          dim Player4AttackCooldown = j
          
          rem GAME: Base damage per hit for each player
          rem Calculated from character type at game start, then stored
          rem Using k, l, m, n (standard RAM)
          dim PlayerDamage = k
          dim Player1Damage = k
          dim Player2Damage = l
          dim Player3Damage = m
          dim Player4Damage = n
          
          rem =================================================================
          rem MISSILE SYSTEM VARIABLES (4 missiles, one per player)
          rem =================================================================
          rem Each player can have one active missile/attack visual at a time.
          rem This includes both ranged projectiles AND melee attack visuals
          rem (e.g., sword sprite that appears briefly during attack).

          rem We can reuse ADMIN variables during gameplay:
          rem   - w-z: char select animation vars (4 bytes)
          rem   - i: ready count (1 byte)
          rem   - a-f: various ADMIN counters (6 bytes)
          rem =================================================================
          
          rem GAME: Missile X positions [0-3] for players 1-4
          dim MissileX = a                  
          rem GAME: reuses temp ADMIN vars
          dim Missile1X = a                 
          rem Player 1 missile X
          dim Missile2X = b                 
          rem Player 2 missile X
          dim Missile3X = c                 
          rem Player 3 missile X
          dim Missile4X = d                 
          rem Player 4 missile X
          
          rem GAME: Missile Y positions [0-3] for players 1-4
          dim MissileY = var0               
          rem GAME: missile Y position
          dim Missile1Y = var0              
          rem Player 1 missile Y
          dim Missile2Y = var1              
          rem Player 2 missile Y
          dim Missile3Y = var2              
          rem Player 3 missile Y
          dim Missile4Y = var3              
          rem Player 4 missile Y
          
          rem GAME: Missile active flags - bit-packed into single byte
          rem Format: [M4Active:1][M3Active:1][M2Active:1][M1Active:1][unused:4]
          rem Bit 0 = Missile1 active, Bit 1 = Missile2 active, etc.
          dim MissileActive = i             
          rem GAME: reuses ReadyCount
          
          rem GAME: Missile lifetime counters [0-3] - frames remaining
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for "until collision"
          rem Actually, let us use e and some SuperChip vars we can spare
          dim MissileLifetime = e           
          rem GAME: Uses 4 nybbles, packed into 2 bytes sequentially
          rem MissileLifetime[0]{5:8} = Missile for P1 lifetime, MissileLifetime[0]{0:3} = M2 lifetime
          rem High nybble = P1/P2 lifetimes (4 bits each = 0-13 frames)
          rem Low nybble = P3/P4 lifetimes (4 bits each = 0-13 frames)
          rem For longer-lived missiles, use special values 14 = "until collision",
          rem 15 = "until leave screen (no playfield cx)"

          rem Missile momentum stored in temp variables during UpdateMissiles subroutine
          rem temp1 = current player index being processed
          rem temp2 = MissileX delta (momentum)
          rem temp3 = MissileY delta (momentum)
          rem temp4 = scratch for collision checks
          rem These are looked up from character data each frame as needed