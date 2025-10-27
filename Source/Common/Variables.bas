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

          rem Most frequently accessed gameplay data in SuperChip RAM
          rem Player positions (frequently accessed)
          dim Player1X = var0
          dim Player1Y = var1
          dim Player2X = var2
          dim Player2Y = var3
          
          rem Health and state for P1/P2 (frequently accessed in combat)
          rem Allocate remaining letters if needed - but note aa-z monthly assignments need different approach
          
          rem =================================================================
          rem GAMEPLAY VARIABLES (SuperChip - var0-var23, Gameplay Only)
          rem =================================================================
          
          rem Player 3 & 4 positions (when Quadtari detected)
          dim Player3X = var4
          dim Player3Y = var5
          dim Player4X = var6
          dim Player4Y = var7
          
          rem Packed player data: Facing (2 bits), State flags (4 bits), Attack type (2 bits)
          rem PlayerState byte format: [Facing:2][Attacking:1][Guarding:1][Jumping:1][Recovery:1][AttackType:2]
          dim Player1State = var8  : rem State flags for Player 1
          dim Player2State = var9  : rem State flags for Player 2
          dim Player3State = var10 : rem State flags for Player 3
          dim Player4State = var11 : rem State flags for Player 4
          
          rem Player health (8 bits each, 0-255)
          dim Player1Health = var12
          dim Player2Health = var13
          dim Player3Health = var14
          dim Player4Health = var15
          
          rem Packed timers/cooldowns: Low nibble = AttackCooldown (0-15), High nibble = RecoveryFrames (0-15)
          dim Player1Timers = var16  : rem [AttackCooldown:4][RecoveryFrames:4]
          dim Player2Timers = var17
          dim Player3Timers = var18
          dim Player4Timers = var19
          
          rem Additional player data (damage, momentum, animation)
          dim Player1Damage = var20
          dim Player2Damage = var21
          dim Player3Damage = var22
          dim Player4Damage = var23
          dim Player1MomentumX = var24
          dim Player2MomentumX = var25
          dim Player3MomentumX = var26
          dim Player4MomentumX = var27
          
          rem Additional gameplay variables needed
          rem NOTE: These will need to be allocated to available RAM slots
          rem For now, GameLoop.bas needs to reference these even if some will be consolidated later