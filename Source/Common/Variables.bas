          rem ChaosFight - Source/Common/Variables.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem PLAYER STATE VARIABLES
          rem =================================================================

          rem Player state flags:
          rem Bit 0: Attacking (1 = attacking, 0 = not)
          rem Bit 1: Guarding (1 = guarding, 0 = not)
          rem Bit 2: Jumping (1 = jumping, 0 = not)
          rem Bit 3: Recovery (1 = in recovery, 0 = normal)
          rem Bits 4-7: Animation state (0-15 for different animation states)

          rem Player 1 variables
          dim Player1X = a
          dim Player1Y = b
          dim Player1Facing = c
          dim Player1State = d  : rem Bit flags for Player 1 state
          dim Player1Health = e
          dim Player1AttackType = f
          dim Player1Damage = g
          dim Player1AttackCooldown = h
          dim Player1RecoveryFrames = i
          dim Player1MomentumX = j
          dim Player1AnimState = k  : rem Current animation state (0-15)
          dim Player1AnimFrame = l  : rem Current frame in animation (0-7)
          dim Player1AnimTimer = m  : rem Timer for animation frame progression

          rem Player 2 variables
          dim Player2X = n
          dim Player2Y = o
          dim Player2Facing = p
          dim Player2State = q  : rem Bit flags for Player 2 state
          dim Player2Health = r
          dim Player2AttackType = s
          dim Player2Damage = t
          dim Player2AttackCooldown = u
          dim Player2RecoveryFrames = v
          dim Player2MomentumX = w
          dim Player2AnimState = x  : rem Current animation state (0-15)
          dim Player2AnimFrame = y  : rem Current frame in animation (0-7)
          dim Player2AnimTimer = z  : rem Timer for animation frame progression

          rem Player 3 variables (Quadtari only)
          dim Player3X = aa
          dim Player3Y = ab
          dim Player3Facing = ac
          dim Player3State = ad  : rem Bit flags for Player 3 state
          dim Player3Health = ae
          dim Player3AttackType = af
          dim Player3Damage = ag
          dim Player3AttackCooldown = ah
          dim Player3RecoveryFrames = ai
          dim Player3MomentumX = aj
          dim Player3AnimState = ak  : rem Current animation state (0-15)
          dim Player3AnimFrame = al  : rem Current frame in animation (0-7)
          dim Player3AnimTimer = am  : rem Timer for animation frame progression

          rem Player 4 variables (Quadtari only)
          dim Player4X = an
          dim Player4Y = ao
          dim Player4Facing = ap
          dim Player4State = aq  : rem Bit flags for Player 4 state
          dim Player4Health = ar
          dim Player4AttackType = as
          dim Player4Damage = at
          dim Player4AttackCooldown = au
          dim Player4RecoveryFrames = av
          dim Player4MomentumX = aw
          dim Player4AnimState = ax  : rem Current animation state (0-15)
          dim Player4AnimFrame = ay  : rem Current frame in animation (0-7)
          dim Player4AnimTimer = az  : rem Timer for animation frame progression

          rem =================================================================
          rem CHARACTER SELECTION VARIABLES
          rem =================================================================

          dim Player1Char = ba
          dim Player2Char = bb
          dim Player3Char = bc
          dim Player4Char = bd
          dim Player1Locked = be
          dim Player2Locked = bf
          dim Player3Locked = bg
          dim Player4Locked = bh
          dim QuadtariDetected = bi
          dim SelectedChar1 = bj
          dim SelectedChar2 = bk
          dim SelectedChar3 = bl
          dim SelectedChar4 = bm

          rem =================================================================
          rem GAME STATE VARIABLES
          rem =================================================================

          dim SelectedLevel = bn
          dim gameState = bo  : rem 0 = normal play, 1 = paused
          dim frame = bp  : rem Frame counter for animations and timing

          rem =================================================================
          rem MISSILE VARIABLES
          rem =================================================================

          dim Missile1X = bq
          dim Missile1Y = br
          dim Missile1Active = bs
          dim Missile1Target = bt

          dim Missile2X = bu
          dim Missile2Y = bv
          dim Missile2Active = bw
          dim Missile2Target = bx

          rem =================================================================
          rem TEMPORARY VARIABLES
          rem =================================================================

          rem Temporary variables for calculations
          dim temp1 = by
          dim temp2 = bz
          dim temp3 = ca
          dim temp4 = cb