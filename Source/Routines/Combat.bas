rem ChaosFight - Source/Routines/Combat.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
rem COMBAT SYSTEM - Generic subroutines using player arrays
          rem =================================================================

rem Apply damage from attacker to defender
rem Inputs: attackerId, defenderId
ApplyDamage
  dim damage = a
  
  rem Calculate damage (considering defender state)
  damage = PlayerDamage(attackerId) - PlayerDamage(defenderId)
  if damage < 1 then damage = 1  rem Minimum damage
  
  rem Apply damage
  PlayerHealth[defenderId] = PlayerHealth[defenderId] - damage
  
  rem Visual feedback (to be implemented)
  gosub ShowDamageIndicator defenderId, damage
  
  rem Sound effect (to be implemented)
  gosub PlayDamageSound damage
  
  return

rem Check if attack hits defender
rem Inputs: attackerId, defenderId
rem Returns: hit (1 = hit, 0 = miss)
CheckAttackHit
  dim hit = a
  dim hitboxLeft = b
  dim hitboxRight = c
  dim hitboxTop = d
  dim hitboxBottom = e
  
  rem Calculate attack hitbox based on attacker facing and attack type
  gosub CalculateAttackHitbox attackerId
  
  rem Check if defender is in hitbox
  rem Initialize hit to 0 (miss)
          hit = 0
          if PlayerX[defenderId] < hitboxLeft then goto NoHit
          if PlayerX[defenderId] > hitboxRight then goto NoHit
          if PlayerY[defenderId] < hitboxTop then goto NoHit
          if PlayerY[defenderId] > hitboxBottom then goto NoHit
          rem All bounds checks passed - hit detected
          hit = 1
          return
NoHit
  rem No hit - hit is already 0
  return

          rem Calculate attack hitbox based on attacker position and facing
rem Inputs: attackerId
rem Outputs: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
CalculateAttackHitbox
  rem Set hitbox based on attack type and direction
  on PlayerAttackType(attackerId) goto MeleeHitbox, ProjectileHitbox, AreaHitbox
  
MeleeHitbox
    rem Melee hitbox extends 16 pixels in facing direction
    on PlayerFacing(attackerId) goto FacingRight, FacingLeft, FacingUp, FacingDown
    
FacingRight
      hitboxLeft = PlayerX[attackerId] + 8
      hitboxRight = PlayerX[attackerId] + 24
      hitboxTop = PlayerY[attackerId] - 8
      hitboxBottom = PlayerY[attackerId] + 8
      return
      
FacingLeft
      hitboxLeft = PlayerX[attackerId] - 24
      hitboxRight = PlayerX[attackerId] - 8
      hitboxTop = PlayerY[attackerId] - 8
      hitboxBottom = PlayerY[attackerId] + 8
      return
      
FacingUp
      hitboxLeft = PlayerX[attackerId] - 8
      hitboxRight = PlayerX[attackerId] + 8
      hitboxTop = PlayerY[attackerId] - 24
      hitboxBottom = PlayerY[attackerId] - 8
      return
      
FacingDown
      hitboxLeft = PlayerX[attackerId] - 8
      hitboxRight = PlayerX[attackerId] + 8
      hitboxTop = PlayerY[attackerId] + 8
      hitboxBottom = PlayerY[attackerId] + 24
      return
  
ProjectileHitbox
    rem Projectile hitbox is at current missile position (to be implemented)
    hitboxLeft = 0
    hitboxRight = 0
    hitboxTop = 0
    hitboxBottom = 0
    return
    
AreaHitbox
    rem Area hitbox covers radius around attacker (to be implemented)
    hitboxLeft = 0
    hitboxRight = 0
    hitboxTop = 0
    hitboxBottom = 0
    return

rem Process attack for one attacker against all defenders
rem Input: attackerId
ProcessAttackerAttacks
  dim defender = a
  
  rem Check if attacker is attacking
  if (PlayerState[attackerId] & %00000001) = 0 then return
  
  rem Attack each defender
  for defender = 0 to 3
    rem Skip if defender is attacker
    if defender = attackerId then goto NextDefender
    
    rem Skip if defender is dead
    if PlayerHealth[defender] <= 0 then goto NextDefender
    
    rem Check if attack hits
    gosub CheckAttackHit attackerId, defender
    if hit then gosub ApplyDamage attackerId, defender
    
NextDefender
  next
  
  return

rem Process all attacks for all players
ProcessAllAttacks
  dim attacker = a
  
  for attacker = 0 to 3
    rem Skip if attacker is dead
    if PlayerHealth[attacker] <= 0 then goto NextAttacker
    
    gosub ProcessAttackerAttacks attacker
    
NextAttacker
  next
  
  return

rem Damage indicator system
CombatShowDamageIndicator
  gosub bank8 VisualShowDamageIndicator
  return

rem Damage sound system
PlayDamageSound
  temp1 = SoundHit
  gosub bank15 PlaySoundEffect
  return

rem =================================================================
rem PERFORM MELEE ATTACK
rem =================================================================
rem Executes a melee attack for the specified player.
rem Spawns a brief missile visual (sword, fist, etc.) and checks for hits.

rem INPUT:
rem   temp1 = attacker participant array index (0-3 maps to participants 1-4)
PerformMeleeAttack
  rem Spawn missile visual for this attack
  gosub bank15 SpawnMissile
  
  rem Set animation state to attacking
          PlayerState[temp1] = (PlayerState[temp1] & %00001111) | (14 << 4)
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
rem   temp1 = attacker participant array index (0-3 maps to participants 1-4)
PerformRangedAttack
  rem Spawn projectile missile for this attack
  gosub bank15 SpawnMissile
  
  rem Set animation state to attacking
          PlayerState[temp1] = (PlayerState[temp1] & %00001111) | (14 << 4)
          rem Set animation state 14 (attack execution)
  
  return

rem Process guard for a player
rem Input: player_id
ProcessPlayerGuard
  rem Check if player is guarding
  if (PlayerState[player_id] & %00000010) = 0 then return
  
  rem Guard prevents movement
  PlayerMomentumX[player_id] = 0
  
  rem Guard prevents attacks
  PlayerState[player_id] = PlayerState[player_id] & %11111110
  
  return

rem Update player guard state
rem Input: player_id
UpdatePlayerGuard
  dim guard_timer = a
  
  rem Decrement guard timer if active (1 second maximum = 60 frames)
          if (PlayerState[player_id] & %00000010) = 0 then goto SkipGuardUpdate
          guard_timer = guard_timer - 1
          if guard_timer <= 0 then PlayerState[player_id] = PlayerState[player_id] & %11111101
    rem Guard visual effect: flashing light cyan ColCyan(12) NTSC/PAL, Cyan SECAM
    rem Player color alternates between normal and cyan every few frames
    rem This matches manual specification: "Character flashes to indicate guard is active"
SkipGuardUpdate
  
  return