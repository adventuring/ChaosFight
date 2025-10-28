          rem ChaosFight - Source/Common/Variables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem VARIABLE MEMORY LAYOUT - DUAL CONTEXT SYSTEM
          rem =================================================================
          rem
          rem ChaosFight uses TWO memory contexts that never overlap:
          rem   1. ADMIN context: Title, preambles, character select, level select
          rem   2. GAME context: Active gameplay
          rem
          rem This allows us to REDIM the same memory locations for different
          rem purposes depending on which screen we''re on, maximizing our limited RAM!
          rem
          rem =================================================================
          rem STANDARD RAM (Available everywhere):
          rem   a-z = 26 variables
          rem
          rem SUPERCHIP RAM AVAILABILITY:
          rem   ADMIN screens (pfres=32): var0-var47 available (48 bytes)
          rem   GAME screens (pfres=8):   var0-var23 available (24 bytes)
          rem
          rem SHARED VARIABLES (needed in both contexts):
          rem   - PlayerChar[0-3], PlayerLocked[0-3]
          rem   - SelectedChar1-4, SelectedLevel
          rem   - QuadtariDetected
          rem   - temp1-4, qtcontroller, frame (built-ins)
          rem
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
          dim GameState = g     : rem 0 = normal play, 1 = paused
          dim QuadtariDetected = h  : rem Set during ADMIN, read during GAME
          
          rem Character selection results (set during ADMIN, read during GAME)
          dim PlayerChar = j     : rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using j,k,l,m
          dim PlayerLocked = n   : rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 using n,o,p,q
          dim SelectedChar1 = r
          dim SelectedChar2 = s
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
          dim ReadyCount = i                : rem ADMIN: Count of locked players
          dim CharSelectAnimTimer = w       : rem ADMIN: Animation frame counter
          dim CharSelectAnimState = x       : rem ADMIN: Current animation state
          dim CharSelectAnimIndex = y       : rem ADMIN: Which character animating
          dim CharSelectAnimFrame = z       : rem ADMIN: Current frame in sequence
          
          rem ADMIN: Title screen parade (SuperChip RAM var28-var47)
          dim TitleParadeTimer = var28      : rem ADMIN: Parade timing
          dim TitleParadeChar = var29       : rem ADMIN: Current parade character
          dim TitleParadeX = var30          : rem ADMIN: Parade X position
          dim TitleParadeActive = var31     : rem ADMIN: Parade active flag
          
          rem ADMIN: Level select variables (SuperChip RAM var0-var23)
          dim LevelPreviewData = var0       : rem ADMIN: Level preview state
          dim LevelScrollOffset = var1      : rem ADMIN: Scroll position
          dim LevelCursorPos = var2         : rem ADMIN: Cursor position
          dim LevelConfirmTimer = var3      : rem ADMIN: Confirmation timer
          
          rem ADMIN: Preamble screen variables (SuperChip RAM var4-var7)
          dim PreambleTimer = var4          : rem ADMIN: Screen timer
          dim PreambleState = var5          : rem ADMIN: Which preamble
          dim MusicPlaying = var6           : rem ADMIN: Music status
          dim MusicPosition = var7          : rem ADMIN: Current note
          
          rem =================================================================
          rem GAMEPLAY VARIABLES (SuperChip RAM - var0-var23 ONLY!)
          rem =================================================================
          rem CRITICAL: With pfres=8, playfield occupies var24-var95!
          rem We MUST stay within var0-var23 during gameplay or we''ll corrupt
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
          
          rem PlayerRecoveryFrames[0-3] - Recovery/hitstun frame counters (was part of PlayerTimers)
          dim PlayerRecoveryFrames = var16
          dim Player1RecoveryFrames = var16
          dim Player2RecoveryFrames = var17
          dim Player3RecoveryFrames = var18
          dim Player4RecoveryFrames = var19
          
          rem PlayerMomentumX[0-3] = Player1MomentumX, Player2MomentumX, Player3MomentumX, Player4MomentumX
          rem Horizontal momentum for knockback and physics
          dim PlayerMomentumX = var20
          dim Player1MomentumX = var20
          dim Player2MomentumX = var21
          dim Player3MomentumX = var22
          dim Player4MomentumX = var23
          
          rem =================================================================
          rem REDIMMED VARIABLES - GAME CONTEXT ONLY  
          rem =================================================================
          rem These variables REDIM the same memory used by ADMIN variables
          rem They are ONLY valid during active gameplay!
          rem =================================================================
          
          rem GAME: Attack cooldown timers (redim ADMIN level select vars)
          rem Format: Counts down from 15-20 frames, 0 = can attack
          dim PlayerAttackCooldown = var0
          dim Player1AttackCooldown = var0   : rem GAME: reuses LevelPreviewData
          dim Player2AttackCooldown = var1   : rem GAME: reuses LevelScrollOffset
          dim Player3AttackCooldown = var2   : rem GAME: reuses LevelCursorPos
          dim Player4AttackCooldown = var3   : rem GAME: reuses LevelConfirmTimer
          
          rem GAME: Base damage per hit for each player (redim ADMIN preamble vars)
          rem Calculated from character type at game start, then stored here
          dim PlayerDamage = var4
          dim Player1Damage = var4           : rem GAME: reuses PreambleTimer
          dim Player2Damage = var5           : rem GAME: reuses PreambleState
          dim Player3Damage = var6           : rem GAME: reuses MusicPlaying
          dim Player4Damage = var7           : rem GAME: reuses MusicPosition
          
          rem =================================================================
          rem MISSILE SYSTEM VARIABLES (4 missiles, one per player)
          rem =================================================================
          rem Each player can have one active missile/attack visual at a time.
          rem This includes both ranged projectiles AND melee attack visuals
          rem (e.g., sword sprite that appears briefly during attack).
          rem
          rem We can reuse ADMIN variables during gameplay:
          rem   - w-z: char select animation vars (4 bytes)
          rem   - i: ready count (1 byte)
          rem   - a-e: various ADMIN counters (5 bytes)
          rem =================================================================
          
          rem GAME: Missile X positions [0-3] for players 1-4
          dim MissileX = a                   : rem GAME: reuses temp ADMIN vars
          dim Missile1X = a                  : rem Player 1''s missile X
          dim Missile2X = b                  : rem Player 2''s missile X
          dim Missile3X = c                  : rem Player 3''s missile X
          dim Missile4X = d                  : rem Player 4''s missile X
          
          rem GAME: Missile Y positions [0-3] for players 1-4
          dim MissileY = w                   : rem GAME: reuses CharSelectAnimTimer
          dim Missile1Y = w                  : rem Player 1''s missile Y
          dim Missile2Y = x                  : rem Player 2''s missile Y (reuses CharSelectAnimState)
          dim Missile3Y = y                  : rem Player 3''s missile Y (reuses CharSelectAnimIndex)
          dim Missile4Y = z                  : rem Player 4''s missile Y (reuses CharSelectAnimFrame)
          
          rem GAME: Missile active flags - bit-packed into single byte
          rem Format: [M4Active:1][M3Active:1][M2Active:1][M1Active:1][unused:4]
          rem Bit 0 = Missile1 active, Bit 1 = Missile2 active, etc.
          dim MissileActive = i              : rem GAME: reuses ReadyCount
          
          rem GAME: Missile lifetime counters [0-3] - frames remaining
          rem For melee attacks: small value (2-8 frames)
          rem For ranged attacks: larger value or 255 for "until collision"
          rem Stored in var8-var11 (shared with PlayerX during gameplay)
          rem NOTE: These overlap with PlayerX intentionally - we''ll use bit-shifting
          rem in MissileActive to determine which missile slots are in use
          rem Actually, let''s use e and some SuperChip vars we can spare
          dim MissileLifetime = e            : rem GAME: Uses 4 nibbles, packed
          rem High nibble = P1/P2 lifetimes (4 bits each = 0-15 frames)
          rem Low nibble = P3/P4 lifetimes (4 bits each = 0-15 frames)
          rem For longer-lived missiles, use special value 15 = "until collision"
          
          rem Missile momentum stored in temp variables during UpdateMissiles subroutine
          rem temp1 = current player index being processed
          rem temp2 = MissileX delta (momentum)
          rem temp3 = MissileY delta (momentum)
          rem temp4 = scratch for collision checks
          rem These are looked up from character data each frame as needed