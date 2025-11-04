         rem ChaosFight - Source/Routines/Combat.bas
         rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem COMBAT SYSTEM - Generic subroutines using player arrays
          rem =================================================================

          rem Apply damage from attacker to defender
          rem Inputs: attackerID, defenderID (must be set before calling)
          rem Process:
          rem   1. Player begins "hurt" animation (ActionHit = 5)
          rem   2. Player enters recovery frames count and color dims (or magenta on SECAM)
          rem   3. If player health >= damage amount, decrement health
          rem   4. If player health < damage amount, player dies (instantly vanishes)
ApplyDamage
          dim AD_attackerID = attackerID
          dim AD_defenderID = defenderID
          dim AD_damage = temp1
          dim AD_currentHealth = temp2
          dim AD_willDie = temp3
          dim AD_recoveryFrames = temp4
          
          rem Calculate damage (considering defender state)
          let AD_damage = playerDamage[AD_attackerID] - playerDamage[AD_defenderID]
          if AD_damage < 1 then let AD_damage = 1 : rem Minimum damage

          rem Check if player will die from this damage
          let AD_currentHealth = playerHealth[AD_defenderID]
          let AD_willDie = 0
          if AD_currentHealth < AD_damage then let AD_willDie = 1 : rem Will die
          
          rem If player will die, instantly vanish (eliminate)
          if AD_willDie then goto PlayerDies
          
          rem Player survives - apply damage and enter hurt state
          let playerHealth[AD_defenderID] = AD_currentHealth - AD_damage
          
          rem Set hurt animation (ActionHit = 5)
          let currentPlayer = AD_defenderID
          let temp2 = ActionHit
          gosub SetPlayerAnimation
          
          rem Calculate recovery frames (damage / 2, clamped 10-30)
          let AD_recoveryFrames = AD_damage / 2
          if AD_recoveryFrames < 10 then let AD_recoveryFrames = 10
          if AD_recoveryFrames > 30 then let AD_recoveryFrames = 30
          let playerRecoveryFrames[AD_defenderID] = AD_recoveryFrames
          
          rem Set playerState bit 3 (recovery flag) when recovery frames are set
          let playerState[AD_defenderID] = playerState[AD_defenderID] | 8
          
          rem Sound effect
          gosub PlayDamageSound
          
          return

PlayerDies
          rem Player dies - instantly vanish
          let playerHealth[AD_defenderID] = 0
          
          rem Trigger elimination immediately (instantly vanish)
          rem CheckPlayerElimination will hide sprite and handle elimination effects
          let temp1 = AD_defenderID
          gosub CheckPlayerElimination
          
          rem Sound effect
          gosub PlayDamageSound
          
          return

          rem Check if attack hits defender
          rem Inputs: attackerID, defenderID (must be set before calling)
          rem Returns: hit (1 = hit, 0 = miss)
CheckAttackHit
          dim CAH_attackerID = attackerID
          dim CAH_defenderID = defenderID
          rem Calculate attack hitbox based on attacker facing and attack type
          gosub CalculateAttackHitbox
          
          rem Check if defender bounding box overlaps hitbox (AABB collision detection)
          rem playerX/playerY represent sprite top-left corner, sprite is 16x16 pixels
          rem Defender bounding box: [playerX, playerX+16] x [playerY, playerY+16]
          rem Hitbox: [hitboxLeft, hitboxRight] x [hitboxTop, hitboxBottom]
          rem Overlap occurs when: defender_right > hitboxLeft AND defender_left < hitboxRight
          rem                      AND defender_bottom > hitboxTop AND defender_top < hitboxBottom
          if playerX[CAH_defenderID] + PlayerSpriteWidth <= hitboxLeft then NoHit
          rem Defender right edge <= hitbox left edge (no overlap)
          if playerX[CAH_defenderID] >= hitboxRight then NoHit
          rem Defender left edge >= hitbox right edge (no overlap)
          if playerY[CAH_defenderID] + PlayerSpriteHeight <= hitboxTop then NoHit
          rem Defender bottom edge <= hitbox top edge (no overlap)
          if playerY[CAH_defenderID] >= hitboxBottom then NoHit
          rem Defender top edge >= hitbox bottom edge (no overlap)
          
          rem All bounds checked - defender is inside hitbox
          let hit = 1
          return
   
NoHit
          rem Defender is outside hitbox bounds
          let hit = 0
          return

          rem Calculate attack hitbox based on attacker position and facing
          rem Inputs: attackerID (must be set before calling, or use CAH_attackerID from CheckAttackHit)
          rem Outputs: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
CalculateAttackHitbox
          dim CAH_attackerID_calc = attackerID
          rem Set hitbox based on attack type and direction
          on PlayerAttackType[CAH_attackerID_calc] goto MeleeHitbox, ProjectileHitbox, AreaHitbox
          
MeleeHitbox
          rem Melee hitbox extends PlayerSpriteWidth pixels in facing direction
          on PlayerFacing[CAH_attackerID_calc] goto FacingRight, FacingLeft, FacingUp, FacingDown
          
FacingRight
          rem Hitbox extends 16 pixels forward from sprite right edge
          rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
          rem Hitbox: [playerX+16, playerX+32] x [playerY, playerY+16]
          let hitboxLeft = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let hitboxRight = playerX[CAH_attackerID_calc] + PlayerSpriteWidth + PlayerSpriteWidth
          let hitboxTop = playerY[CAH_attackerID_calc]
          let hitboxBottom = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          return
          
FacingLeft
          rem Hitbox extends 16 pixels forward from sprite left edge
          rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
          rem Hitbox: [playerX-16, playerX] x [playerY, playerY+16]
          let hitboxLeft = playerX[CAH_attackerID_calc] - PlayerSpriteWidth
          let hitboxRight = playerX[CAH_attackerID_calc]
          let hitboxTop = playerY[CAH_attackerID_calc]
          let hitboxBottom = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          return
          
FacingUp
          rem Hitbox extends 16 pixels upward from sprite top edge
          rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
          rem Hitbox: [playerX, playerX+16] x [playerY-16, playerY]
          let hitboxLeft = playerX[CAH_attackerID_calc]
          let hitboxRight = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let hitboxTop = playerY[CAH_attackerID_calc] - PlayerSpriteHeight
          let hitboxBottom = playerY[CAH_attackerID_calc]
          return
          
FacingDown
          rem Hitbox extends 16 pixels downward from sprite bottom edge
          rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
          rem Hitbox: [playerX, playerX+16] x [playerY+16, playerY+32]
          let hitboxLeft = playerX[CAH_attackerID_calc]
          let hitboxRight = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let hitboxTop = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          let hitboxBottom = playerY[CAH_attackerID_calc] + PlayerSpriteHeight + PlayerSpriteHeight
          return
          
ProjectileHitbox
          rem Projectile hitbox is at current missile position (to be implemented)
          let hitboxLeft = 0
          let hitboxRight = 0
          let hitboxTop = 0
          let hitboxBottom = 0
          return
          
AreaHitbox
          rem Area hitbox covers radius around attacker (to be implemented)
          let hitboxLeft = 0
          let hitboxRight = 0
          let hitboxTop = 0
          let hitboxBottom = 0
          return

          rem Process attack for one attacker against all defenders
          rem Input: attackerID (must be set before calling)
          rem Processes attacks in all directions (facing handled by CalculateAttackHitbox)
ProcessAttackerAttacks
          dim PAA_defender = temp2
          dim PAA_attackerID = attackerID
          rem Attack each defender
          for defender = 0 to 3
          rem Skip if defender is attacker
          if defender = PAA_attackerID then NextDefender
          
          rem Skip if defender is dead
          if playerHealth[defender] <= 0 then NextDefender
          
          rem Set defenderID before calling functions
          let PAA_defender = defender
          let defenderID = PAA_defender
          
          rem Check if attack hits
          gosub CheckAttackHit
          if hit then gosub ApplyDamage
          
NextDefender
          next
          
          return

          rem Process all attacks for all players
ProcessAllAttacks
          dim PAA_attacker = temp1
          for attacker = 0 to 3
          rem Skip if attacker is dead
          if playerHealth[attacker] <= 0 then NextAttacker
          
          rem Set attackerID before calling ProcessAttackerAttacks
          let PAA_attacker = attacker
          let attackerID = PAA_attacker
          gosub ProcessAttackerAttacks
          
NextAttacker
          next
          
          return

          rem Damage indicator system
          rem NOTE: VisualEffects.bas was phased out - damage indicators handled inline
CombatShowDamageIndicator
          rem Visual feedback now handled inline in damage calculation
          return

rem Damage sound system
PlayDamageSound
          dim PDS_soundId = temp1
          let PDS_soundId = SoundHit
          gosub bank15 PlaySoundEffect
          return

rem =================================================================
rem PERFORM MELEE ATTACK
rem =================================================================
rem Executes a melee attack for the specified player.
rem Spawns a brief missile visual (sword, fist, etc.) and checks for hits.

rem INPUT:
          rem   temp1 = attacker player index (0-3)
PerformMeleeAttack
          rem Spawn missile visual for this attack
          gosub bank7 SpawnMissile
          
          rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << 4)
          rem Set animation state 14 (attack execution)
          
          rem Check immediate collision with other players in melee range
          rem This is handled by the main collision detection system
          rem For now, collision will be handled in UpdateAllMissiles
          
          return

rem =================================================================
rem PERFORM RANGED ATTACK
rem =================================================================
rem Executes a ranged attack for the specified player.
rem Spawns a projectile missile that travels across the screen.

rem INPUT:
          rem   temp1 = attacker player index (0-3)
PerformRangedAttack
          rem Spawn projectile missile for this attack
          gosub bank7 SpawnMissile
          
          rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (ActionAttackExecute << 4)
          rem Set animation state 14 (attack execution)
          
          return

          rem Process guard for a player
          rem DEPRECATED: This function has syntax errors and conflicts with GuardEffects.bas
          rem Guard restrictions are now handled in PlayerInput.bas (movement/attack blocking)
          rem Guard timer updates are handled by UpdateGuardTimers in GuardEffects.bas
          rem Input: playerID
ProcessPlayerGuard
          rem This function is deprecated - guard restrictions are handled elsewhere
          rem Guard prevents movement - handled in PlayerInput.bas
          rem Guard prevents attacks - handled in PlayerInput.bas
          return

          rem Update player guard state
          rem DEPRECATED: This function uses undefined guard_timer variable and conflicts with GuardEffects.bas
          rem Guard timer updates are handled by UpdateGuardTimers in GuardEffects.bas
          rem Input: player_id
UpdatePlayerGuard
          rem This function is deprecated - use UpdateGuardTimers in GuardEffects.bas instead
          return
