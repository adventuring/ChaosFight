          rem ChaosFight - Source/Routines/GameLoop.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

GameLoop
          const pfres = 8
          rem SuperChip variables var0-var15 available in gameplay
          
          rem Player state flags:
          rem Bit 0: Attacking (1 = attacking, 0 = not)
          rem Bit 1: Guarding (1 = guarding, 0 = not)
          rem Bit 2: Jumping (1 = jumping, 0 = not)
          rem Bit 3: Recovery (1 = in recovery, 0 = normal)
          rem Bits 4-7: Animation state (0-15 for different animation states)

          rem Animation states enumeration:
          rem 0 = Standing still facing right
          rem 1 = Idle (resting)
          rem 2 = Standing still guarding right
          rem 3 = Walking/running right
          rem 4 = Coming to stop from running right
          rem 5 = Taking a hit (hurt)
          rem 6 = Falling backwards (facing right while moving left)
          rem 7 = Falling down
          rem 8 = Fallen down
          rem 9 = Recovering to standing from fallen
          rem 10 = Jumping
          rem 11 = Falling after jumping/walking off cliff
          rem 12 = Landing from height and recovering
          rem 13-15 = Reserved

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

          rem Missile variables for ranged attacks
          dim Missile1X = o
          dim Missile1Y = p
          dim Missile1Active = q
          dim Missile1Target = r

          dim Missile2X = s
          dim Missile2Y = t
          dim Missile2Active = u
          dim Missile2Target = v

          rem Character attack types: 0 = melee, 1 = ranged
          rem Character 0: Basic melee fighter (damage: 15-25)
          rem Character 1: Archer (damage: 20-30, ranged)
          rem Character 2: Swordsman (damage: 25-35, melee)
          rem Character 3: Mage (damage: 30-40, ranged)
          rem Character 4: Tank (damage: 10-20, melee, high health)
          rem Characters 5-15: Various balanced characters

          rem Initialize player positions and stats
          Player1X = 40
          Player1Y = 80
          Player1Facing = 1
          Player1Jumping = 0
          Player1Guarding = 0
          Player1Attacking = 0
          Player1Health = 100
          Player1AttackCooldown = 0
          Player1RecoveryFrames = 0
          Player1MomentumX = 0
          gosub SetPlayer1Character

          Player2X = 120
          Player2Y = 80
          Player2Facing = 0
          Player2Jumping = 0
          Player2Guarding = 0
          Player2Attacking = 0
          Player2Health = 100
          Player2AttackCooldown = 0
          Player2RecoveryFrames = 0
          Player2MomentumX = 0
          gosub SetPlayer2Character

          rem Initialize players 3 & 4 if Quadtari detected and characters selected
          if QuadtariDetected && SelectedChar3 != 0 then
                    Player3X = 80
                    Player3Y = 80
                    Player3Facing = 1
                    Player3Jumping = 0
                    Player3Guarding = 0
                    Player3Attacking = 0
                    Player3Health = 100
                    Player3AttackCooldown = 0
                    Player3RecoveryFrames = 0
                    Player3MomentumX = 0
                    gosub SetPlayer3Character

          if QuadtariDetected && SelectedChar4 != 0 then
                    Player4X = 100
                    Player4Y = 80
                    Player4Facing = 0
                    Player4Jumping = 0
                    Player4Guarding = 0
                    Player4Attacking = 0
                    Player4Health = 100
                    Player4AttackCooldown = 0
                    Player4RecoveryFrames = 0
                    Player4MomentumX = 0
                    gosub SetPlayer4Character

          rem Initialize missiles
          Missile1Active = 0
          Missile2Active = 0

          rem Initialize frame counter
          dim frame = o
          frame = 0

          rem Initialize game state
          dim gameState = p
          gameState = 0 : rem 0 = normal play, 1 = paused

          gosub LoadLevel

          rem Bit flag helper functions
          rem Bit 0: Attacking, Bit 1: Guarding, Bit 2: Jumping, Bit 3: Recovery
          rem Bits 4-7: Animation state (0-15)

          def SetPlayerAttacking(playerState) = playerState | 1
          def SetPlayerGuarding(playerState) = playerState | 2
          def SetPlayerJumping(playerState) = playerState | 4
          def SetPlayerRecovery(playerState) = playerState | 8

          def ClearPlayerAttacking(playerState) = playerState & ~1
          def ClearPlayerGuarding(playerState) = playerState & ~2
          def ClearPlayerJumping(playerState) = playerState & ~4
          def ClearPlayerRecovery(playerState) = playerState & ~8

          def IsPlayerAttacking(playerState) = playerState & 1
          def IsPlayerGuarding(playerState) = playerState & 2
          def IsPlayerJumping(playerState) = playerState & 4
          def IsPlayerRecovery(playerState) = playerState & 8

          def GetPlayerAnimState(playerState) = (playerState >> 4) & 15
          def SetPlayerAnimState(playerState, animState) = (playerState & ~240) | (animState << 4)

GameMainLoop
          rem Handle console switches
          gosub HandleConsoleSwitches

          rem Handle Player 1 input (disabled during recovery)
          if !Player1RecoveryFrames then
                    if joy0left then Player1X = Player1X - 1 : Player1Facing = 0 : Player1MomentumX = -1
                    if joy0right then Player1X = Player1X + 1 : Player1Facing = 1 : Player1MomentumX = 1
                    if joy0up && !Player1Jumping then Player1Jumping = 1 : Player1Y = Player1Y - 10
                    if joy0down then Player1Guarding = 1 else Player1Guarding = 0
          endif
          if joy0fire && !Player1AttackCooldown then gosub PerformPlayer1Attack

          rem Handle Player 2 input (disabled during recovery)
          if !Player2RecoveryFrames then
                    if joy1left then Player2X = Player2X - 1 : Player2Facing = 0 : Player2MomentumX = -1
                    if joy1right then Player2X = Player2X + 1 : Player2Facing = 1 : Player2MomentumX = 1
                    if joy1up && !Player2Jumping then Player2Jumping = 1 : Player2Y = Player2Y - 10
                    if joy1down then Player2Guarding = 1 else Player2Guarding = 0
          if joy1fire && !Player2AttackCooldown then gosub PerformPlayer2Attack

          rem Handle Player 3 input (Quadtari only, disabled during recovery)
          if QuadtariDetected && SelectedChar3 != 0 && !Player3RecoveryFrames then
                    if joy2left then Player3X = Player3X - 1 : Player3Facing = 0 : Player3MomentumX = -1
                    if joy2right then Player3X = Player3X + 1 : Player3Facing = 1 : Player3MomentumX = 1
                    if joy2up && !Player3Jumping then Player3Jumping = 1 : Player3Y = Player3Y - 10
                    if joy2down then Player3Guarding = 1 else Player3Guarding = 0
          if QuadtariDetected && SelectedChar3 != 0 && joy2fire && !Player3AttackCooldown then gosub PerformPlayer3Attack

          rem Handle Player 4 input (Quadtari only, disabled during recovery)
          if QuadtariDetected && SelectedChar4 != 0 && !Player4RecoveryFrames then
                    if joy3left then Player4X = Player4X - 1 : Player4Facing = 0 : Player4MomentumX = -1
                    if joy3right then Player4X = Player4X + 1 : Player4Facing = 1 : Player4MomentumX = 1
                    if joy3up && !Player4Jumping then Player4Jumping = 1 : Player4Y = Player4Y - 10
                    if joy3down then Player4Guarding = 1 else Player4Guarding = 0
          if QuadtariDetected && SelectedChar4 != 0 && joy3fire && !Player4AttackCooldown then gosub PerformPlayer4Attack

          rem Apply gravity and momentum to all jumping players
          if IsPlayerJumping(Player1State) then Player1Y = Player1Y + 1 : if Player1Y >= 80 then Player1Y = 80 : Player1State = ClearPlayerJumping(Player1State)
          if IsPlayerJumping(Player2State) then Player2Y = Player2Y + 1 : if Player2Y >= 80 then Player2Y = 80 : Player2State = ClearPlayerJumping(Player2State)
          if QuadtariDetected && SelectedChar3 != 0 then
                    if IsPlayerJumping(Player3State) then Player3Y = Player3Y + 1 : if Player3Y >= 80 then Player3Y = 80 : Player3State = ClearPlayerJumping(Player3State)
          if QuadtariDetected && SelectedChar4 != 0 then
                    if IsPlayerJumping(Player4State) then Player4Y = Player4Y + 1 : if Player4Y >= 80 then Player4Y = 80 : Player4State = ClearPlayerJumping(Player4State)

          rem Apply momentum and recovery effects
          gosub ApplyMomentumAndRecovery

          rem Boundary collision detection for all players
          gosub CheckPlayer1Collisions
          gosub CheckPlayer2Collisions
          if QuadtariDetected && SelectedChar3 != 0 then gosub CheckPlayer3Collisions
          if QuadtariDetected && SelectedChar4 != 0 then gosub CheckPlayer4Collisions

          rem Multi-player collision detection
          gosub CheckAllPlayerCollisions

          rem Set sprite positions for active players
          rem In 2-player mode: player0 = Player1, player1 = Player2
          rem In 4-player mode: player0 = Player1/Player3, player1 = Player2/Player4
          rem Players 3&4 use missile/ball sprites when active

          player0x = Player1X
          player0y = Player1Y
          player1x = Player2X
          player1y = Player2Y

          rem Set missile/ball positions for players 3 & 4 in 4-player mode
          if QuadtariDetected && SelectedChar3 != 0 then
                    missile1x = Player3X : missile1y = Player3Y : ENAM1 = 1
          else
                    ENAM1 = 0
          endif

          if QuadtariDetected && SelectedChar4 != 0 then
                    ballx = Player4X : bally = Player4Y : ENABL = 1
          else
                    ENABL = 0
          endif

          rem Set missile positions (using missile sprites for projectiles)
          if Missile1Active then
                    missile0x = Missile1X
                    missile0y = Missile1Y
                    ENAM0 = 1
          else
                    ENAM0 = 0
          endif

          if Missile2Active then
                    missile1x = Missile2X
                    missile1y = Missile2Y
                    ENAM1 = 1
          else
                    ENAM1 = 0
          endif

          rem Set sprite graphics based on state
          gosub SetPlayerSprites

          rem Display health information (simplified)
          gosub DisplayHealth

          rem Update frame counter
          frame = frame + 1

          drawscreen
          goto GameMainLoop

          rem Collision detection for Player 1
CheckPlayer1Collisions
          if Player1X < 10 then Player1X = 10
          if Player1X > 150 then Player1X = 150
          if Player1Y < 20 then Player1Y = 20
          if Player1Y > 80 then Player1Y = 80
          return

          rem Collision detection for Player 2
CheckPlayer2Collisions
          if Player2X < 10 then Player2X = 10
          if Player2X > 150 then Player2X = 150
          if Player2Y < 20 then Player2Y = 20
          if Player2Y > 80 then Player2Y = 80
          return

          rem Collision detection for Player 3
CheckPlayer3Collisions
          if Player3X < 10 then Player3X = 10
          if Player3X > 150 then Player3X = 150
          if Player3Y < 20 then Player3Y = 20
          if Player3Y > 80 then Player3Y = 80
          return

          rem Collision detection for Player 4
CheckPlayer4Collisions
          if Player4X < 10 then Player4X = 10
          if Player4X > 150 then Player4X = 150
          if Player4Y < 20 then Player4Y = 20
          if Player4Y > 80 then Player4Y = 80
          return

          rem Update attack cooldowns
          gosub UpdateAttackCooldowns

          rem Update missiles
          gosub UpdateMissiles

          rem Check missile collisions
          gosub CheckMissileCollisions

          rem Multi-player collision detection
CheckAllPlayerCollisions
          rem Check Player 1 vs Player 2
          dim Distance = a
          Distance = Player1X - Player2X
          if Distance < 0 then Distance = -Distance
          if Distance < 16 then
                    if Player1X < Player2X then Player1X = Player1X - 1 : Player2X = Player2X + 1 else Player1X = Player1X + 1 : Player2X = Player2X - 1
          return

          rem Set sprite graphics based on state
SetPlayerSprites
          rem Set Player 1 color and sprite
          rem Normal state (not hurt): Use XCF artwork colors in color mode, player-based colors in B&W mode
          rem Hurt state: Luminance $6 with player-based color
          if Player1RecoveryFrames > 0 then
                    rem Hurt state - use dark player-based color
                    COLUP0 = ColIndigo(6)  : rem Dark indigo for hurt
          else
                    rem Normal state - use appropriate color mode
                    if switchbw then
                              rem B&W mode - bright player-based color
                              COLUP0 = ColIndigo(12)  : rem Bright indigo
                    else
                              rem Color mode - use XCF artwork colors (would be loaded from art data)
                              rem For now, use bright player-based color as placeholder
                              COLUP0 = ColIndigo(12)
                    endif
          endif

          player0:
          %00011000
          %00111100
          %01111110
          %00011000
          %00011000
          %00011000
          %00011000
          %00011000
          end

          rem Set Player 2 color and sprite
          if Player2RecoveryFrames > 0 then
                    rem Hurt state - use dark player-based color
                    COLUP1 = ColRed(6)  : rem Dark red for hurt
          else
                    rem Normal state - use appropriate color mode
                    if switchbw then
                              rem B&W mode - bright player-based color
                              COLUP1 = ColRed(12)  : rem Bright red
                    else
                              rem Color mode - use XCF artwork colors (would be loaded from art data)
                              rem For now, use bright player-based color as placeholder
                              COLUP1 = ColRed(12)
                    endif
          endif

          player1:
          %00011000
          %00111100
          %01111110
          %00011000
          %00011000
          %00011000
          %00011000
          %00011000
          end

          rem Set colors for Players 3 & 4 (using ball and missile sprites)
          if QuadtariDetected && SelectedChar3 != 0 then
                    if Player3RecoveryFrames > 0 then
                              rem Hurt state - use dark player-based color
                              COLUPF = ColYellow(6)  : rem Dark yellow for hurt
                    else
                              rem Normal state - use appropriate color mode
                              if switchbw then
                                        rem B&W mode - bright player-based color
                                        COLUPF = ColYellow(12)  : rem Bright yellow
                              else
                                        rem Color mode - use XCF artwork colors (would be loaded from art data)
                                        rem For now, use bright player-based color as placeholder
                                        COLUPF = ColYellow(12)
                              endif
                    endif
          endif

          if QuadtariDetected && SelectedChar4 != 0 then
                    if Player4RecoveryFrames > 0 then
                              rem Hurt state - use dark player-based color
                              COLUBK = ColGreen(6)  : rem Dark green for hurt
                    else
                              rem Normal state - use appropriate color mode
                              if switchbw then
                                        rem B&W mode - bright player-based color
                                        COLUBK = ColGreen(12)  : rem Bright green
                              else
                                        rem Color mode - use XCF artwork colors (would be loaded from art data)
                                        rem For now, use bright player-based color as placeholder
                                        COLUBK = ColGreen(12)
                              endif
                    endif
          endif
          return

          rem Character setup functions
SetPlayer1Character
          rem Set character-specific stats based on selected character
          rem Default balanced character
          Player1AttackType = 0 : rem melee
          Player1Damage = 22

          if SelectedChar1 = 0 then
                    rem Basic melee fighter
                    Player1AttackType = 0 : rem melee
                    Player1Damage = 20
          endif

          if SelectedChar1 = 1 then
                    rem Archer (ranged)
                    Player1AttackType = 1 : rem ranged
                    Player1Damage = 25
          endif

          if SelectedChar1 = 2 then
                    rem Swordsman (melee)
                    Player1AttackType = 0 : rem melee
                    Player1Damage = 30
          endif

          if SelectedChar1 = 3 then
                    rem Mage (ranged)
                    Player1AttackType = 1 : rem ranged
                    Player1Damage = 35
          endif

          if SelectedChar1 = 4 then
                    rem Tank (melee, high health)
                    Player1AttackType = 0 : rem melee
                    Player1Damage = 15
                    Player1Health = 150
          endif
          return

SetPlayer2Character
          rem Default balanced character
          Player2AttackType = 0 : rem melee
          Player2Damage = 22

          if SelectedChar2 = 0 then
                    Player2AttackType = 0
                    Player2Damage = 20
          endif

          if SelectedChar2 = 1 then
                    Player2AttackType = 1
                    Player2Damage = 25
          endif

          if SelectedChar2 = 2 then
                    Player2AttackType = 0
                    Player2Damage = 30
          endif

          if SelectedChar2 = 3 then
                    Player2AttackType = 1
                    Player2Damage = 35
          endif

          if SelectedChar2 = 4 then
                    Player2AttackType = 0
                    Player2Damage = 15
                    Player2Health = 150
          endif
          return

SetPlayer3Character
          rem Default balanced character
          Player3AttackType = 0 : rem melee
          Player3Damage = 22

          if SelectedChar3 = 0 then
                    Player3AttackType = 0
                    Player3Damage = 20
          endif

          if SelectedChar3 = 1 then
                    Player3AttackType = 1
                    Player3Damage = 25
          endif

          if SelectedChar3 = 2 then
                    Player3AttackType = 0
                    Player3Damage = 30
          endif

          if SelectedChar3 = 3 then
                    Player3AttackType = 1
                    Player3Damage = 35
          endif

          if SelectedChar3 = 4 then
                    Player3AttackType = 0
                    Player3Damage = 15
                    Player3Health = 150
          endif
          return

SetPlayer4Character
          rem Default balanced character
          Player4AttackType = 0 : rem melee
          Player4Damage = 22

          if SelectedChar4 = 0 then
                    Player4AttackType = 0
                    Player4Damage = 20
          endif

          if SelectedChar4 = 1 then
                    Player4AttackType = 1
                    Player4Damage = 25
          endif

          if SelectedChar4 = 2 then
                    Player4AttackType = 0
                    Player4Damage = 30
          endif

          if SelectedChar4 = 3 then
                    Player4AttackType = 1
                    Player4Damage = 35
          endif

          if SelectedChar4 = 4 then
                    Player4AttackType = 0
                    Player4Damage = 15
                    Player4Health = 150
          endif
          return

          rem Attack functions
PerformPlayer1Attack
          Player1AttackCooldown = 30 : rem 30 frames cooldown
          gosub PerformAttack
          return

PerformPlayer2Attack
          Player2AttackCooldown = 30
          gosub PerformAttack
          return

PerformPlayer3Attack
          Player3AttackCooldown = 30
          gosub PerformAttack
          return

PerformPlayer4Attack
          Player4AttackCooldown = 30
          gosub PerformAttack
          return

          rem Common attack subroutine
PerformAttack
          rem This subroutine performs the attack based on the attacking player's character
          rem Uses Player1 variables as source for the attack logic
          dim AttackerX = a
          dim AttackerY = b
          dim AttackerFacing = c
          dim AttackerDamage = d
          dim AttackerAttackType = e

          rem Set attacker stats based on which player is attacking
          if Player1Attacking then
                    AttackerX = Player1X
                    AttackerY = Player1Y
                    AttackerFacing = Player1Facing
                    AttackerDamage = Player1Damage
                    AttackerAttackType = Player1AttackType
          endif

          if Player2Attacking then
                    AttackerX = Player2X
                    AttackerY = Player2Y
                    AttackerFacing = Player2Facing
                    AttackerDamage = Player2Damage
                    AttackerAttackType = Player2AttackType
          endif

          if Player3Attacking then
                    AttackerX = Player3X
                    AttackerY = Player3Y
                    AttackerFacing = Player3Facing
                    AttackerDamage = Player3Damage
                    AttackerAttackType = Player3AttackType
          endif

          if Player4Attacking then
                    AttackerX = Player4X
                    AttackerY = Player4Y
                    AttackerFacing = Player4Facing
                    AttackerDamage = Player4Damage
                    AttackerAttackType = Player4AttackType
          endif

          if AttackerAttackType = 0 then
                    rem Melee attack
                    gosub PerformMeleeAttack
          else
                    rem Ranged attack
                    gosub PerformRangedAttack
          return

          rem Melee attack function
PerformMeleeAttack
          dim TargetX = a
          dim TargetY = b
          dim Distance = c
          dim Damage = d

          rem Calculate random damage variation
          Damage = AttackerDamage + (rand & 7) - 4

          rem Check for targets in melee range (adjacent)
          rem Check Player 1 vs Player 2
          if Player1Attacking then
                    TargetX = Player2X : TargetY = Player2Y
          endif

          if Player2Attacking then
                    TargetX = Player1X : TargetY = Player1Y
          endif

          if Player3Attacking then
                    rem Check vs Player 1
                    Distance = AttackerX - Player1X
                    if Distance < 0 then Distance = -Distance
                    if Distance < 20 then gosub DealDamage
                    rem Check vs Player 2
                    Distance = AttackerX - Player2X
                    if Distance < 0 then Distance = -Distance
                    if Distance < 20 then gosub DealDamage
                    rem Check vs Player 4
                    if SelectedChar4 != 0 then
                              Distance = AttackerX - Player4X
                              if Distance < 0 then Distance = -Distance
                              if Distance < 20 then gosub DealDamage
                    endif
                    return
          endif

          if Player4Attacking then
                    rem Check vs Player 1
                    Distance = AttackerX - Player1X
                    if Distance < 0 then Distance = -Distance
                    if Distance < 20 then gosub DealDamage
                    rem Check vs Player 2
                    Distance = AttackerX - Player2X
                    if Distance < 0 then Distance = -Distance
                    if Distance < 20 then gosub DealDamage
                    rem Check vs Player 3
                    if SelectedChar3 != 0 then
                              Distance = AttackerX - Player3X
                              if Distance < 0 then Distance = -Distance
                              if Distance < 20 then gosub DealDamage
                    endif
                    return
          endif

          rem Deal damage to target with recovery and knockback
DealDamage
          dim KnockbackDirection = a

          if Player1Attacking then
                    if TargetX = Player2X && TargetY = Player2Y then
                              rem Deal damage to Player 2
                              Player2Health = Player2Health - Damage
                              Player2RecoveryFrames = RecoveryFrameCount
                              rem Apply knockback
                              KnockbackDirection = Player1Facing
                              if KnockbackDirection then Player2MomentumX = KnockbackDistance else Player2MomentumX = -KnockbackDistance
                              Player2MomentumX = Player2MomentumX + Player2MomentumX  : rem Double knockback
                              gosub TriggerPlayer2Recovery
                    endif
          endif

          if Player2Attacking then
                    if TargetX = Player1X && TargetY = Player1Y then
                              rem Deal damage to Player 1
                              Player1Health = Player1Health - Damage
                              Player1RecoveryFrames = RecoveryFrameCount
                              rem Apply knockback
                              KnockbackDirection = Player2Facing
                              if KnockbackDirection then Player1MomentumX = KnockbackDistance else Player1MomentumX = -KnockbackDistance
                              Player1MomentumX = Player1MomentumX + Player1MomentumX  : rem Double knockback
                              gosub TriggerPlayer1Recovery
                    endif
          endif

          rem Check damage to Player 3
          if QuadtariDetected && SelectedChar3 != 0 && Player3Attacking then
                    if TargetX = Player1X && TargetY = Player1Y then
                              Player1Health = Player1Health - Damage
                              Player1RecoveryFrames = RecoveryFrameCount
                              KnockbackDirection = Player3Facing
                              if KnockbackDirection then Player1MomentumX = KnockbackDistance else Player1MomentumX = -KnockbackDistance
                              gosub TriggerPlayer1Recovery
                    endif
                    if TargetX = Player2X && TargetY = Player2Y then
                              Player2Health = Player2Health - Damage
                              Player2RecoveryFrames = RecoveryFrameCount
                              KnockbackDirection = Player3Facing
                              if KnockbackDirection then Player2MomentumX = KnockbackDistance else Player2MomentumX = -KnockbackDistance
                              gosub TriggerPlayer2Recovery
                    endif
                    if SelectedChar4 != 0 && TargetX = Player4X && TargetY = Player4Y then
                              Player4Health = Player4Health - Damage
                              Player4RecoveryFrames = RecoveryFrameCount
                              KnockbackDirection = Player3Facing
                              if KnockbackDirection then Player4MomentumX = KnockbackDistance else Player4MomentumX = -KnockbackDistance
                              gosub TriggerPlayer4Recovery
                    endif
          endif

          rem Check damage to Player 4
          if QuadtariDetected && SelectedChar4 != 0 && Player4Attacking then
                    if TargetX = Player1X && TargetY = Player1Y then
                              Player1Health = Player1Health - Damage
                              Player1RecoveryFrames = RecoveryFrameCount
                              KnockbackDirection = Player4Facing
                              if KnockbackDirection then Player1MomentumX = KnockbackDistance else Player1MomentumX = -KnockbackDistance
                              gosub TriggerPlayer1Recovery
                    endif
                    if TargetX = Player2X && TargetY = Player2Y then
                              Player2Health = Player2Health - Damage
                              Player2RecoveryFrames = RecoveryFrameCount
                              KnockbackDirection = Player4Facing
                              if KnockbackDirection then Player2MomentumX = KnockbackDistance else Player2MomentumX = -KnockbackDistance
                              gosub TriggerPlayer2Recovery
                    endif
                    if SelectedChar3 != 0 && TargetX = Player3X && TargetY = Player3Y then
                              Player3Health = Player3Health - Damage
                              Player3RecoveryFrames = RecoveryFrameCount
                              KnockbackDirection = Player4Facing
                              if KnockbackDirection then Player3MomentumX = KnockbackDistance else Player3MomentumX = -KnockbackDistance
                              gosub TriggerPlayer3Recovery
                    endif
          endif
          return

          rem Ranged attack function
PerformRangedAttack
          rem Find nearest target in line of fire
          dim NearestDistance = a
          dim TargetPlayer = b
          NearestDistance = 200 : rem Large number

          if Player1Attacking then
                    rem Find target for Player 1
                    Distance = Player1X - Player2X
                    if Distance < 0 then Distance = -Distance
                    if Distance < NearestDistance then NearestDistance = Distance : TargetPlayer = 2
                    if SelectedChar3 != 0 then
                              Distance = Player1X - Player3X
                              if Distance < 0 then Distance = -Distance
                              if Distance < NearestDistance then NearestDistance = Distance : TargetPlayer = 3
                    if SelectedChar4 != 0 then
                              Distance = Player1X - Player4X
                              if Distance < 0 then Distance = -Distance
                              if Distance < NearestDistance then NearestDistance = Distance : TargetPlayer = 4
          else
                    if Player2Attacking then
                    rem Find target for Player 2
                    Distance = Player2X - Player1X
                    if Distance < 0 then Distance = -Distance
                    if Distance < NearestDistance then NearestDistance = Distance : TargetPlayer = 1
                    if SelectedChar3 != 0 then
                              Distance = Player2X - Player3X
                              if Distance < 0 then Distance = -Distance
                              if Distance < NearestDistance then NearestDistance = Distance : TargetPlayer = 3
                    if SelectedChar4 != 0 then
                              Distance = Player2X - Player4X
                              if Distance < 0 then Distance = -Distance
                              if Distance < NearestDistance then NearestDistance = Distance : TargetPlayer = 4

          rem Fire missile if target found
          if NearestDistance < 200 then gosub FireMissile
          return

          rem Fire missile function
FireMissile
          if !Missile1Active then
                    rem Use missile 1
                    Missile1X = AttackerX
                    Missile1Y = AttackerY
                    Missile1Active = 1
                    if TargetPlayer = 1 then Missile1Target = 1
                    if TargetPlayer = 2 then Missile1Target = 2
                    if TargetPlayer = 3 then Missile1Target = 3
                    if TargetPlayer = 4 then Missile1Target = 4
          else
                    if !Missile2Active then
                    rem Use missile 2
                    Missile2X = AttackerX
                    Missile2Y = AttackerY
                    Missile2Active = 1
                    if TargetPlayer = 1 then Missile2Target = 1
                    if TargetPlayer = 2 then Missile2Target = 2
                    if TargetPlayer = 3 then Missile2Target = 3
                    if TargetPlayer = 4 then Missile2Target = 4
          return

          rem Update attack cooldowns
UpdateAttackCooldowns
          if Player1AttackCooldown > 0 then Player1AttackCooldown = Player1AttackCooldown - 1
          if Player2AttackCooldown > 0 then Player2AttackCooldown = Player2AttackCooldown - 1
          if QuadtariDetected && SelectedChar3 != 0 then
                    if Player3AttackCooldown > 0 then Player3AttackCooldown = Player3AttackCooldown - 1
          if QuadtariDetected && SelectedChar4 != 0 then
                    if Player4AttackCooldown > 0 then Player4AttackCooldown = Player4AttackCooldown - 1
          return

          rem Update missiles
UpdateMissiles
          if Missile1Active then
                    rem Move missile 1 towards target
                    if Missile1Target = 1 then
                              if Missile1X < Player1X then Missile1X = Missile1X + 2 else if Missile1X > Player1X then Missile1X = Missile1X - 2
                              if Missile1Y < Player1Y then Missile1Y = Missile1Y + 2 else if Missile1Y > Player1Y then Missile1Y = Missile1Y - 2
                    else
                              if Missile1Target = 2 then
                              if Missile1X < Player2X then Missile1X = Missile1X + 2 else if Missile1X > Player2X then Missile1X = Missile1X - 2
                              if Missile1Y < Player2Y then Missile1Y = Missile1Y + 2 else if Missile1Y > Player2Y then Missile1Y = Missile1Y - 2
                    else
                              if Missile1Target = 3 then
                              if Missile1X < Player3X then Missile1X = Missile1X + 2 else if Missile1X > Player3X then Missile1X = Missile1X - 2
                              if Missile1Y < Player3Y then Missile1Y = Missile1Y + 2 else if Missile1Y > Player3Y then Missile1Y = Missile1Y - 2
                    else
                              if Missile1Target = 4 then
                              if Missile1X < Player4X then Missile1X = Missile1X + 2 else if Missile1X > Player4X then Missile1X = Missile1X - 2
                              if Missile1Y < Player4Y then Missile1Y = Missile1Y + 2 else if Missile1Y > Player4Y then Missile1Y = Missile1Y - 2

                    rem Check if missile hit target or went off screen
                    if Missile1Target = 1 && Missile1X = Player1X && Missile1Y = Player1Y then gosub MissileHit
                    if Missile1Target = 2 && Missile1X = Player2X && Missile1Y = Player2Y then gosub MissileHit
                    if Missile1Target = 3 && Missile1X = Player3X && Missile1Y = Player3Y then gosub MissileHit
                    if Missile1Target = 4 && Missile1X = Player4X && Missile1Y = Player4Y then gosub MissileHit
                    if Missile1X < 0 || Missile1X > 160 || Missile1Y < 0 || Missile1Y > 100 then Missile1Active = 0

          if Missile2Active then
                    rem Move missile 2 towards target
                    if Missile2Target = 1 then
                              if Missile2X < Player1X then Missile2X = Missile2X + 2 else if Missile2X > Player1X then Missile2X = Missile2X - 2
                              if Missile2Y < Player1Y then Missile2Y = Missile2Y + 2 else if Missile2Y > Player1Y then Missile2Y = Missile2Y - 2
                    else
                              if Missile2Target = 2 then
                              if Missile2X < Player2X then Missile2X = Missile2X + 2 else if Missile2X > Player2X then Missile2X = Missile2X - 2
                              if Missile2Y < Player2Y then Missile2Y = Missile2Y + 2 else if Missile2Y > Player2Y then Missile2Y = Missile2Y - 2
                    else
                              if Missile2Target = 3 then
                              if Missile2X < Player3X then Missile2X = Missile2X + 2 else if Missile2X > Player3X then Missile2X = Missile2X - 2
                              if Missile2Y < Player3Y then Missile2Y = Missile2Y + 2 else if Missile2Y > Player3Y then Missile2Y = Missile2Y - 2
                    else
                              if Missile2Target = 4 then
                              if Missile2X < Player4X then Missile2X = Missile2X + 2 else if Missile2X > Player4X then Missile2X = Missile2X - 2
                              if Missile2Y < Player4Y then Missile2Y = Missile2Y + 2 else if Missile2Y > Player4Y then Missile2Y = Missile2Y - 2

                    rem Check if missile hit target or went off screen
                    if Missile2Target = 1 && Missile2X = Player1X && Missile2Y = Player1Y then gosub MissileHit
                    if Missile2Target = 2 && Missile2X = Player2X && Missile2Y = Player2Y then gosub MissileHit
                    if Missile2Target = 3 && Missile2X = Player3X && Missile2Y = Player3Y then gosub MissileHit
                    if Missile2Target = 4 && Missile2X = Player4X && Missile2Y = Player4Y then gosub MissileHit
                    if Missile2X < 0 || Missile2X > 160 || Missile2Y < 0 || Missile2Y > 100 then Missile2Active = 0
          return

          rem Missile hit function
MissileHit
          dim Damage = a
          dim KnockbackDirection = b
          Damage = AttackerDamage + (rand & 7) - 4

          if Missile1Target = 1 then
                    Player1Health = Player1Health - Damage
                    Player1RecoveryFrames = RecoveryFrameCount
                    rem Apply knockback away from attacker
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player1MomentumX = KnockbackDistance else Player1MomentumX = -KnockbackDistance
                    Player1MomentumX = Player1MomentumX + Player1MomentumX  : rem Double knockback for ranged
                    gosub TriggerPlayer1Recovery
                    Missile1Active = 0

          if Missile1Target = 2 then
                    Player2Health = Player2Health - Damage
                    Player2RecoveryFrames = RecoveryFrameCount
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player2MomentumX = KnockbackDistance else Player2MomentumX = -KnockbackDistance
                    Player2MomentumX = Player2MomentumX + Player2MomentumX
                    gosub TriggerPlayer2Recovery
                    Missile1Active = 0

          if Missile1Target = 3 then
                    Player3Health = Player3Health - Damage
                    Player3RecoveryFrames = RecoveryFrameCount
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player3MomentumX = KnockbackDistance else Player3MomentumX = -KnockbackDistance
                    Player3MomentumX = Player3MomentumX + Player3MomentumX
                    gosub TriggerPlayer3Recovery
                    Missile1Active = 0

          if Missile1Target = 4 then
                    Player4Health = Player4Health - Damage
                    Player4RecoveryFrames = RecoveryFrameCount
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player4MomentumX = KnockbackDistance else Player4MomentumX = -KnockbackDistance
                    Player4MomentumX = Player4MomentumX + Player4MomentumX
                    gosub TriggerPlayer4Recovery
                    Missile1Active = 0

          if Missile2Target = 1 then
                    Player1Health = Player1Health - Damage
                    Player1RecoveryFrames = RecoveryFrameCount
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player1MomentumX = KnockbackDistance else Player1MomentumX = -KnockbackDistance
                    Player1MomentumX = Player1MomentumX + Player1MomentumX
                    gosub TriggerPlayer1Recovery
                    Missile2Active = 0

          if Missile2Target = 2 then
                    Player2Health = Player2Health - Damage
                    Player2RecoveryFrames = RecoveryFrameCount
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player2MomentumX = KnockbackDistance else Player2MomentumX = -KnockbackDistance
                    Player2MomentumX = Player2MomentumX + Player2MomentumX
                    gosub TriggerPlayer2Recovery
                    Missile2Active = 0

          if Missile2Target = 3 then
                    Player3Health = Player3Health - Damage
                    Player3RecoveryFrames = RecoveryFrameCount
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player3MomentumX = KnockbackDistance else Player3MomentumX = -KnockbackDistance
                    Player3MomentumX = Player3MomentumX + Player3MomentumX
                    gosub TriggerPlayer3Recovery
                    Missile2Active = 0

          if Missile2Target = 4 then
                    Player4Health = Player4Health - Damage
                    Player4RecoveryFrames = RecoveryFrameCount
                    KnockbackDirection = AttackerFacing
                    if KnockbackDirection then Player4MomentumX = KnockbackDistance else Player4MomentumX = -KnockbackDistance
                    Player4MomentumX = Player4MomentumX + Player4MomentumX
                    gosub TriggerPlayer4Recovery
                    Missile2Active = 0
          return

          rem Check missile collisions with players
CheckMissileCollisions
          if Missile1Active then
                    rem Check missile 1 collision with all players
                    if Missile1Target != 1 then
                              if Missile1X >= Player1X - 8 && Missile1X <= Player1X + 8 && Missile1Y >= Player1Y - 8 && Missile1Y <= Player1Y + 8 then gosub MissileHit
                    if Missile1Target != 2 then
                              if Missile1X >= Player2X - 8 && Missile1X <= Player2X + 8 && Missile1Y >= Player2Y - 8 && Missile1Y <= Player2Y + 8 then gosub MissileHit
                    if QuadtariDetected && SelectedChar3 != 0 && Missile1Target != 3 then
                              if Missile1X >= Player3X - 8 && Missile1X <= Player3X + 8 && Missile1Y >= Player3Y - 8 && Missile1Y <= Player3Y + 8 then gosub MissileHit
                    if QuadtariDetected && SelectedChar4 != 0 && Missile1Target != 4 then
                              if Missile1X >= Player4X - 8 && Missile1X <= Player4X + 8 && Missile1Y >= Player4Y - 8 && Missile1Y <= Player4Y + 8 then gosub MissileHit

          if Missile2Active then
                    rem Check missile 2 collision with all players
                    if Missile2Target != 1 then
                              if Missile2X >= Player1X - 8 && Missile2X <= Player1X + 8 && Missile2Y >= Player1Y - 8 && Missile2Y <= Player1Y + 8 then gosub MissileHit
                    if Missile2Target != 2 then
                              if Missile2X >= Player2X - 8 && Missile2X <= Player2X + 8 && Missile2Y >= Player2Y - 8 && Missile2Y <= Player2Y + 8 then gosub MissileHit
                    if QuadtariDetected && SelectedChar3 != 0 && Missile2Target != 3 then
                              if Missile2X >= Player3X - 8 && Missile2X <= Player3X + 8 && Missile2Y >= Player3Y - 8 && Missile2Y <= Player3Y + 8 then gosub MissileHit
                    if QuadtariDetected && SelectedChar4 != 0 && Missile2Target != 4 then
                              if Missile2X >= Player4X - 8 && Missile2X <= Player4X + 8 && Missile2Y >= Player4Y - 8 && Missile2Y <= Player4Y + 8 then gosub MissileHit
          return

          rem Display health information
DisplayHealth
          rem Display health bars or numbers for active players
          rem This would use the score or playfield to show health
          rem For now, simplified visual feedback

          rem Flash sprites if health is low (but not during recovery)
          if Player1Health < 25 && !Player1RecoveryFrames then
                    rem Flash Player 1 sprite
                    if frame & 8 then player0x = 200 : rem Hide sprite

          if Player2Health < 25 && !Player2RecoveryFrames then
                    rem Flash Player 2 sprite
                    if frame & 8 then player1x = 200 : rem Hide sprite

          if QuadtariDetected && SelectedChar3 != 0 && Player3Health < 25 && !Player3RecoveryFrames then
                    rem Flash Player 3 sprite
                    if frame & 8 then missile1x = 200

          if QuadtariDetected && SelectedChar4 != 0 && Player4Health < 25 && !Player4RecoveryFrames then
                    rem Flash Player 4 sprite
                    if frame & 8 then ballx = 200
          return

          rem Recovery trigger functions
TriggerPlayer1Recovery
          rem Set Player 1 to recovery color (Indigo)
          return

TriggerPlayer2Recovery
          rem Set Player 2 to recovery color (Red)
          return

TriggerPlayer3Recovery
          rem Set Player 3 to recovery color (Yellow)
          return

TriggerPlayer4Recovery
          rem Set Player 4 to recovery color (Green)
          return

          rem Apply momentum and update recovery frames
ApplyMomentumAndRecovery
          rem Update recovery frames for all players
          if Player1RecoveryFrames > 0 then
                    Player1RecoveryFrames = Player1RecoveryFrames - 1
                    rem Apply momentum during recovery (no input control)
                    Player1X = Player1X + Player1MomentumX
                    rem Reduce momentum over time
                    if Player1MomentumX > 0 then Player1MomentumX = Player1MomentumX - 1 else if Player1MomentumX < 0 then Player1MomentumX = Player1MomentumX + 1

          if Player2RecoveryFrames > 0 then
                    Player2RecoveryFrames = Player2RecoveryFrames - 1
                    Player2X = Player2X + Player2MomentumX
                    if Player2MomentumX > 0 then Player2MomentumX = Player2MomentumX - 1 else if Player2MomentumX < 0 then Player2MomentumX = Player2MomentumX + 1

          if QuadtariDetected && SelectedChar3 != 0 && Player3RecoveryFrames > 0 then
                    Player3RecoveryFrames = Player3RecoveryFrames - 1
                    Player3X = Player3X + Player3MomentumX
                    if Player3MomentumX > 0 then Player3MomentumX = Player3MomentumX - 1 else if Player3MomentumX < 0 then Player3MomentumX = Player3MomentumX + 1

          if QuadtariDetected && SelectedChar4 != 0 && Player4RecoveryFrames > 0 then
                    Player4RecoveryFrames = Player4RecoveryFrames - 1
                    Player4X = Player4X + Player4MomentumX
                    if Player4MomentumX > 0 then Player4MomentumX = Player4MomentumX - 1 else if Player4MomentumX < 0 then Player4MomentumX = Player4MomentumX + 1
          return

          rem Handle console switches
HandleConsoleSwitches
          rem Game Reset switch - return to character selection
          if switchreset then goto CharacterSelect

          rem Color/B&W switch - adjust character colors
          gosub HandleColorSwitch

          rem Game Select switch - toggle pause mode
          if switchselect then
                    if gameState = 0 then gameState = 1 else gameState = 0
          endif

          return

          rem Handle Color/B&W switch (this function is now handled in SetPlayerSprites)
HandleColorSwitch
          rem Color/B&W switch logic is now handled in SetPlayerSprites function
          rem This ensures consistent color handling across all game states
          return

          rem Display paused screen
DisplayPausedScreen
          rem Display "PAUSED" message or just show characters on black background
          rem For now, just keep characters visible on black background
          return

LoadLevel
          if SelectedLevel = 0 then
                    dim RandomLevel = a
                    RandomLevel = rand
                    RandomLevel = RandomLevel & 1
                    if RandomLevel = 0 then gosub Level1Data
                    if RandomLevel = 1 then gosub Level2Data
          else if SelectedLevel = 1 then gosub Level1Data
          else if SelectedLevel = 2 then gosub Level2Data
          endif
          return