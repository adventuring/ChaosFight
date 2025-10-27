          rem ChaosFight - Source/Common/Variables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem VARIABLE MEMORY LAYOUT
          rem =================================================================
          rem
          rem STANDARD RAM (Available everywhere):
          rem   a-z = 26 variables
          rem
          rem SUPERCHIP RAM (Available everywhere with SuperChip):
          rem   var0-var47 = 48 variables (playfield space freed)
          rem
          rem SUPERCHIP PLAYFIELD RAM:
          rem   Title/Preambles (pfres=12): uses var48-var95 (48 vars), leaves var0-var47 free
          rem   Gameplay (pfres=8): uses var24-var95 (72 vars), leaves var0-var23 free
          rem   - Note: Playfield always ends at r/w127 regardless of pfres
          rem
          rem TOTAL AVAILABLE:
          rem   Title/Preambles: 26 (a-z) + 48 (var0-var47) = 74 variables
          rem   Gameplay: 26 (a-z) + 24 (var0-var23) = 50 variables

          rem =================================================================
          rem STANDARD VARIABLES (Available in All Screens) - a through i
          rem =================================================================
          
          dim temp1 = a
          dim temp2 = b
          dim temp3 = c
          dim temp4 = d
          dim QtController = e
          dim frame = f
          dim gameState = g  : rem 0 = normal play, 1 = paused
          dim QuadtariDetected = h
          dim ReadyCount = i
          
          rem =================================================================
          rem CHARACTER SELECTION VARIABLES (Available in All Screens) - j through s
          rem =================================================================

          dim PlayerChar = j, k, l, m  : rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 (4 vars)
          dim PlayerLocked = n, o, p, q : rem [0]=P1, [1]=P2, [2]=P3, [3]=P4 (4 vars)
          dim SelectedChar1 = r
          dim SelectedChar2 = s
          dim SelectedChar3 = t
          dim SelectedChar4 = u
          dim SelectedLevel = v
          
          rem =================================================================
          rem CHARACTER SELECT ANIMATION VARIABLES (Standard RAM - w through z)
          rem =================================================================
          
          dim CharSelectAnimTimer = w  : rem Animation frame counter for character select
          dim CharSelectAnimState = x  : rem Current animation state (0=idle, 1=running, 2=attacking)
          dim CharSelectCharIndex = y  : rem Which character is currently animating
          dim CharSelectAnimFrame = z  : rem Current frame within animation sequence
          
          rem =================================================================
          rem TITLE SCREEN PARADE VARIABLES (SuperChip RAM - var28-var31)
          rem =================================================================
          
          dim TitleParadeTimer = var28     : rem Timer for character parade timing
          dim TitleParadeChar = var29      : rem Current character in parade
          dim TitleParadeX = var30         : rem X position of parade character
          dim TitleParadeActive = var31    : rem 1=parade active, 0=waiting
          
          rem =================================================================
          rem GAMEPLAY VARIABLES (SuperChip RAM - var0-var23, Gameplay Only)
          rem =================================================================

          rem Player data arrays using batariBasic array syntax
          rem PlayerX[0-3] = Player1X, Player2X, Player3X, Player4X
          dim PlayerX = var0, var1, var2, var3
          dim Player1X = var0
          dim Player2X = var1
          dim Player3X = var2
          dim Player4X = var3
          
          rem PlayerY[0-3] = Player1Y, Player2Y, Player3Y, Player4Y
          dim PlayerY = var4, var5, var6, var7
          dim Player1Y = var4
          dim Player2Y = var5
          dim Player3Y = var6
          dim Player4Y = var7
          
          rem PlayerState[0-3] = Player1State, Player2State, Player3State, Player4State
          rem Packed player data: Facing (2 bits), State flags (4 bits), Attack type (2 bits)
          rem PlayerState byte format: [Facing:2][Attacking:1][Guarding:1][Jumping:1][Recovery:1][AttackType:2]
          dim PlayerState = var8, var9, var10, var11
          dim Player1State = var8
          dim Player2State = var9
          dim Player3State = var10
          dim Player4State = var11
          
          rem PlayerHealth[0-3] = Player1Health, Player2Health, Player3Health, Player4Health
          dim PlayerHealth = var12, var13, var14, var15
          dim Player1Health = var12
          dim Player2Health = var13
          dim Player3Health = var14
          dim Player4Health = var15
          
          rem PlayerTimers[0-3] = Player1Timers, Player2Timers, Player3Timers, Player4Timers
          rem Packed timers/cooldowns: Low nibble = AttackCooldown (0-15), High nibble = RecoveryFrames (0-15)
          dim PlayerTimers = var16, var17, var18, var19
          dim Player1Timers = var16
          dim Player2Timers = var17
          dim Player3Timers = var18
          dim Player4Timers = var19
          
          rem PlayerDamage[0-3] = Player1Damage, Player2Damage, Player3Damage, Player4Damage
          dim PlayerDamage = var20, var21, var22, var23
          dim Player1Damage = var20
          dim Player2Damage = var21
          dim Player3Damage = var22
          dim Player4Damage = var23
          
          rem PlayerMomentumX[0-3] = Player1MomentumX, Player2MomentumX, Player3MomentumX, Player4MomentumX
          dim PlayerMomentumX = var24, var25, var26, var27
          dim Player1MomentumX = var24
          dim Player2MomentumX = var25
          dim Player3MomentumX = var26
          dim Player4MomentumX = var27
          
          rem =================================================================
          rem MISSILE SYSTEM VARIABLES (SuperChip RAM - var32-var47)
          rem =================================================================
          
          rem Missile 1 data
          dim Missile1X = var32
          dim Missile1Y = var33
          dim Missile1Active = var34
          dim Missile1Target = var35
          dim Missile1MomentumX = var36
          dim Missile1MomentumY = var37
          dim Missile1Flags = var38
          
          rem Missile 2 data
          dim Missile2X = var39
          dim Missile2Y = var40
          dim Missile2Active = var41
          dim Missile2Target = var42
          dim Missile2MomentumX = var43
          dim Missile2MomentumY = var44
          dim Missile2Flags = var45
          
          rem Game constants
          dim RecoveryFrameCount = var46
          dim KnockbackDistance = var47