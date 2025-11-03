rem ChaosFight - Source/Routines/Combat.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
rem COMBAT SYSTEM - Generic subroutines using player arrays
          rem =================================================================

rem Apply damage from attacker to defender
rem Inputs: attackerId, defenderId
ApplyDamage
  rem Calculate damage (considering defender state)
<<<<<<< HEAD
  let temp1 = playerDamage(attacker_id) - playerDamage(defender_id)
  if temp1 < 1 then let temp1 = 1  rem Minimum damage
  
  rem Apply damage
  playerHealth[defender_id] = playerHealth[defender_id] - temp1
  
  rem Visual feedback (to be implemented)
  gosub ShowDamageIndicator defender_id, temp1
=======
  damage = PlayerDamage(attackerId) - PlayerDamage(defenderId)
  if damage < 1 then damage = 1  rem Minimum damage
  
  rem Apply damage
  PlayerHealth[defenderId] = PlayerHealth[defenderId] - damage
  
  rem Visual feedback (to be implemented)
  gosub ShowDamageIndicator defenderId, damage
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
  
  rem Sound effect (to be implemented)
  gosub PlayDamageSound temp1
  
  return

rem Check if attack hits defender
rem Inputs: attackerId, defenderId
rem Returns: hit (1 = hit, 0 = miss)
CheckAttackHit
<<<<<<< HEAD
=======
  dim hit = a
  dim hitboxLeft = b
  dim hitboxRight = c
  dim hitboxTop = d
  dim hitboxBottom = e
  
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
  rem Calculate attack hitbox based on attacker facing and attack type
  gosub CalculateAttackHitbox attackerId
  
  rem Check if defender is in hitbox
<<<<<<< HEAD
          if playerX[defender_id] < hitbox_left then HitboxCheckDone
          if playerX[defender_id] > hitbox_right then HitboxCheckDone
          if playerY[defender_id] < hitbox_top then HitboxCheckDone
          if playerY[defender_id] > hitbox_bottom then HitboxCheckDone
    let hit = 1
          goto HitboxCheckDone
HitboxCheckDone
          if hit  = 0 then NoHit
    let hit = 0
=======
  rem Initialize hit to 0 (miss)
          hit = 0
          if PlayerX[defenderId] < hitboxLeft then goto NoHit
          if PlayerX[defenderId] > hitboxRight then goto NoHit
          if PlayerY[defenderId] < hitboxTop then goto NoHit
          if PlayerY[defenderId] > hitboxBottom then goto NoHit
          rem All bounds checks passed - hit detected
          hit = 1
          return
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
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
<<<<<<< HEAD
  rem Check if attacker is facing right (PlayerStateFacing = bit 0)
  temp1 = playerState[attacker_id]
  if temp1{0} = 0 then return
=======
  dim defender = a
  
  rem Check if attacker is attacking
  if (PlayerState[attackerId] & %00000001) = 0 then return
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
  
  rem Attack each defender
  for defender = 0 to 3
    rem Skip if defender is attacker
<<<<<<< HEAD
    if defender = attacker_id then NextDefender
=======
    if defender = attackerId then goto NextDefender
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
    
    rem Skip if defender is dead
    if playerHealth[defender] <= 0 then NextDefender
    
    rem Check if attack hits
    gosub CheckAttackHit attackerId, defender
    if hit then gosub ApplyDamage attackerId, defender
    
NextDefender
  next
  
  return

rem Process all attacks for all players
ProcessAllAttacks
  for attacker = 0 to 3
    rem Skip if attacker is dead
    if playerHealth[attacker] <= 0 then NextAttacker
    
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
  gosub bank7 SpawnMissile
  
  rem Set animation state to attacking
<<<<<<< HEAD
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << 4)
=======
          PlayerState[temp1] = (PlayerState[temp1] & %00001111) | (14 << 4)
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
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
  gosub bank7 SpawnMissile
  
  rem Set animation state to attacking
<<<<<<< HEAD
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << 4)
=======
          PlayerState[temp1] = (PlayerState[temp1] & %00001111) | (14 << 4)
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
          rem Set animation state 14 (attack execution)
  
  return

rem Process guard for a player
rem DEPRECATED: This function has syntax errors and conflicts with GuardEffects.bas
rem Guard restrictions are now handled in PlayerInput.bas (movement/attack blocking)
rem Guard timer updates are handled by UpdateGuardTimers in GuardEffects.bas
rem Input: player_id
ProcessPlayerGuard
<<<<<<< HEAD
  rem This function is deprecated - guard restrictions are handled elsewhere
  rem Guard prevents movement - handled in PlayerInput.bas
  rem Guard prevents attacks - handled in PlayerInput.bas
=======
  rem Check if player is guarding
  if (PlayerState[player_id] & %00000010) = 0 then return
  
  rem Guard prevents movement
  PlayerMomentumX[player_id] = 0
  
  rem Guard prevents attacks
  PlayerState[player_id] = PlayerState[player_id] & %11111110
  
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
  return

rem Update player guard state
rem DEPRECATED: This function uses undefined guard_timer variable and conflicts with GuardEffects.bas
rem Guard timer updates are handled by UpdateGuardTimers in GuardEffects.bas
rem Input: player_id
UpdatePlayerGuard
<<<<<<< HEAD
  rem This function is deprecated - use UpdateGuardTimers in GuardEffects.bas instead
=======
  dim guard_timer = a
  
  rem Decrement guard timer if active (1 second maximum = 60 frames)
          if (PlayerState[player_id] & %00000010) = 0 then goto SkipGuardUpdate
          guard_timer = guard_timer - 1
          if guard_timer <= 0 then PlayerState[player_id] = PlayerState[player_id] & %11111101
    rem Guard visual effect: flashing light cyan ColCyan(12) NTSC/PAL, Cyan SECAM
    rem Player color alternates between normal and cyan every few frames
    rem This matches manual specification: "Character flashes to indicate guard is active"
SkipGuardUpdate
  
>>>>>>> 32165c2 (Fix terminology: Clarify participant numbers (1-4) vs sprite indices (P0-P3))
  return