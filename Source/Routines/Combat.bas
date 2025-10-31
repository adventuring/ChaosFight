rem ChaosFight - Source/Routines/Combat.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
rem COMBAT SYSTEM - Generic subroutines using player arrays
          rem =================================================================

rem Apply damage from attacker to defender
rem Inputs: attacker_id, defender_id
ApplyDamage
  dim damage = a
  
  rem Calculate damage (considering defender state)
  damage = PlayerDamage(attacker_id) - PlayerDamage(defender_id)
  if damage < 1 then damage = 1  rem Minimum damage
  
  rem Apply damage
  PlayerHealth[defender_id) = PlayerHealth[defender_id] - damage
  
  rem Visual feedback (to be implemented)
  gosub ShowDamageIndicator defender_id, damage
  
  rem Sound effect (to be implemented)
  gosub PlayDamageSound damage
  
  return

rem Check if attack hits defender
rem Inputs: attacker_id, defender_id
rem Returns: hit (1 = hit, 0 = miss)
CheckAttackHit
  dim hit = a
  dim hitbox_left = b
  dim hitbox_right = c
  dim hitbox_top = d
  dim hitbox_bottom = e
  
  rem Calculate attack hitbox based on attacker facing and attack type
  gosub CalculateAttackHitbox attacker_id
  
  rem Check if defender is in hitbox
          if PlayerX[defender_id] < hitbox_left then goto HitboxCheckDone
          if PlayerX[defender_id] > hitbox_right then goto HitboxCheckDone
          if PlayerY[defender_id] < hitbox_top then goto HitboxCheckDone
          if PlayerY[defender_id] > hitbox_bottom then goto HitboxCheckDone
    hit = 1
          goto HitboxCheckDone
HitboxCheckDone
          if hit = 0 then goto NoHit
    hit = 0
NoHit
  
  return

          rem Calculate attack hitbox based on attacker position and facing
rem Inputs: attacker_id
rem Outputs: hitbox_left, hitbox_right, hitbox_top, hitbox_bottom
CalculateAttackHitbox
  rem Set hitbox based on attack type and direction
  on PlayerAttackType(attacker_id) goto MeleeHitbox, ProjectileHitbox, AreaHitbox
  
MeleeHitbox
    rem Melee hitbox extends 16 pixels in facing direction
    on PlayerFacing(attacker_id) goto FacingRight, FacingLeft, FacingUp, FacingDown
    
FacingRight
      hitbox_left = PlayerX[attacker_id] + 8
      hitbox_right = PlayerX[attacker_id] + 24
      hitbox_top = PlayerY[attacker_id] - 8
      hitbox_bottom = PlayerY[attacker_id] + 8
      return
      
FacingLeft
      hitbox_left = PlayerX[attacker_id] - 24
      hitbox_right = PlayerX[attacker_id] - 8
      hitbox_top = PlayerY[attacker_id] - 8
      hitbox_bottom = PlayerY[attacker_id] + 8
      return
      
FacingUp
      hitbox_left = PlayerX[attacker_id] - 8
      hitbox_right = PlayerX[attacker_id] + 8
      hitbox_top = PlayerY[attacker_id] - 24
      hitbox_bottom = PlayerY[attacker_id] - 8
      return
      
FacingDown
      hitbox_left = PlayerX[attacker_id] - 8
      hitbox_right = PlayerX[attacker_id] + 8
      hitbox_top = PlayerY[attacker_id] + 8
      hitbox_bottom = PlayerY[attacker_id] + 24
      return
  
ProjectileHitbox
    rem Projectile hitbox is at current missile position (to be implemented)
    hitbox_left = 0
    hitbox_right = 0
    hitbox_top = 0
    hitbox_bottom = 0
    return
    
AreaHitbox
    rem Area hitbox covers radius around attacker (to be implemented)
    hitbox_left = 0
    hitbox_right = 0
    hitbox_top = 0
    hitbox_bottom = 0
    return

rem Process attack for one attacker against all defenders
rem Input: attacker_id
ProcessAttackerAttacks
  dim defender = a
  
  rem Check if attacker is attacking
  if (PlayerState[attacker_id) & %00000001] = 0 then return
  
  rem Attack each defender
  for defender = 0 to 3
    rem Skip if defender is attacker
    if defender = attacker_id then goto NextDefender
    
    rem Skip if defender is dead
    if PlayerHealth[defender] <= 0 then goto NextDefender
    
    rem Check if attack hits
    gosub CheckAttackHit attacker_id, defender
          if hit then gosub ApplyDamage attacker_id, defender
    
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
ShowDamageIndicator
  gosub bank0 ShowDamageIndicator
  return

rem Damage sound system
PlayDamageSound
  temp1 = SoundHit
  gosub PlaySoundEffect
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
  gosub bank3 SpawnMissile
  
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
rem   temp1 = attacker player index (0-3)
PerformRangedAttack
  rem Spawn projectile missile for this attack
  gosub bank3 SpawnMissile
  
  rem Set animation state to attacking
          PlayerState[temp1] = (PlayerState[temp1] & %00001111) | (14 << 4) 
          rem Set animation state 14 (attack execution)
  
  return

rem Process guard for a player
rem Input: player_id
ProcessPlayerGuard
  rem Check if player is guarding
  if (PlayerState[player_id) & %00000010] = 0 then return
  
  rem Guard prevents movement
  PlayerMomentumX[player_id] = 0
  
  rem Guard prevents attacks
  PlayerState[player_id) = PlayerState[player_id] & %11111110
  
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