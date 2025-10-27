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
          rem GAMEPLAY VARIABLES (Standard RAM - All 26 vars used: a-z)
          rem =================================================================

          rem Most frequently accessed gameplay data in RIOT RAM for speed
          rem First 4 positions: w-z (from above section)
          dim Player1X = w
          dim Player1Y = x
          dim Player2X = y
          dim Player2Y = z
          
          rem Health and state for P1/P2 (frequently accessed in combat)
          rem Allocate remaining letters if needed - but note aa-z monthly assignments need different approach
          
          rem =================================================================
          rem GAMEPLAY VARIABLES (SuperChip - var0-var23, Gameplay Only)
          rem =================================================================
          
          rem Player 3 & 4 positions (when Quadtari detected)
          dim Player3X = var0
          dim Player3Y = var1
          dim Player4X = var2
          dim Player4Y = var3
          
          rem Packed player data: Facing (2 bits), State flags (4 bits), Attack type (2 bits)
          rem PlayerState byte format: [Facing:2][Attacking:1][Guarding:1][Jumping:1][Recovery:1][AttackType:2]
          dim Player1State = var4  : rem State flags for Player 1
          dim Player2State = var5  : rem State flags for Player 2
          rem Player3State and Player4State need allocation
          
          rem Player health (8 bits each, 0-255)
          dim Player1Health = var6
          dim Player2Health = var7
          dim Player3Health = var8
          dim Player4Health = var9
          
          rem Packed timers/cooldowns: Low nibble = AttackCooldown (0-15), High nibble = RecoveryFrames (0-15)
          dim Player1Timers = var10  : rem [AttackCooldown:4][RecoveryFrames:4]
          dim Player2Timers = var11
          dim Player3Timers = var12
          dim Player4Timers = var13
          
          rem Additional player data (damage, momentum, animation)
          dim Player1Damage = var14
          dim Player2Damage = var15
          dim Player3Damage = var16
          dim Player4Damage = var17
          dim Player1MomentumX = var18
          dim Player2MomentumX = var19
          dim Player3MomentumX = var20
          dim Player3State = var21  : rem State flags for Player 3
          dim Player4MomentumX = var22
          dim Player4State = var23  : rem State flags for Player 4
          
          rem Additional gameplay variables needed
          rem NOTE: These will need to be allocated to available RAM slots
          rem For now, GameLoop.bas needs to reference these even if some will be consolidated later