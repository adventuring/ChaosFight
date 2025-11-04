rem ChaosFight - Source/Routines/Combat.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
rem COMBAT SYSTEM - Generic subroutines using player arrays
          rem =================================================================

rem Apply damage from attacker to defender
rem Inputs: attacker_id, defender_id
ApplyDamage
  rem Calculate damage (considering defender state)
  let temp1 = playerDamage[attacker_id] - playerDamage[defender_id]
  if temp1 < 1 then let temp1 = 1  rem Minimum damage
  
  rem Apply damage
  playerHealth[defender_id] = playerHealth[defender_id] - temp1
  
  rem Visual feedback (to be implemented)
  gosub ShowDamageIndicator defender_id, temp1
  
  rem Sound effect (to be implemented)
  gosub PlayDamageSound temp1
  
  return

rem Check if attack hits defender
rem Inputs: attacker_id, defender_id
rem Returns: hit (1 = hit, 0 = miss)
CheckAttackHit
  rem Calculate attack hitbox based on attacker facing and attack type
  gosub CalculateAttackHitbox
  
  rem Check if defender bounding box overlaps hitbox (AABB collision detection)
  rem playerX/playerY represent sprite top-left corner, sprite is 16x16 pixels
  rem Defender bounding box: [playerX, playerX+16] x [playerY, playerY+16]
  rem Hitbox: [hitbox_left, hitbox_right] x [hitbox_top, hitbox_bottom]
  rem Overlap occurs when: defender_right > hitbox_left AND defender_left < hitbox_right
  rem                      AND defender_bottom > hitbox_top AND defender_top < hitbox_bottom
          if playerX[defender_id] + PlayerSpriteWidth <= hitbox_left then NoHit
          rem Defender right edge <= hitbox left edge (no overlap)
          if playerX[defender_id] >= hitbox_right then NoHit
          rem Defender left edge >= hitbox right edge (no overlap)
          if playerY[defender_id] + PlayerSpriteHeight <= hitbox_top then NoHit
          rem Defender bottom edge <= hitbox top edge (no overlap)
          if playerY[defender_id] >= hitbox_bottom then NoHit
          rem Defender top edge >= hitbox bottom edge (no overlap)
  
  rem All bounds checked - defender is inside hitbox
          let hit = 1
          return
  
NoHit
  rem Defender is outside hitbox bounds
          let hit = 0
          return

          rem Calculate attack hitbox based on attacker position and facing
rem Inputs: attacker_id
rem Outputs: hitbox_left, hitbox_right, hitbox_top, hitbox_bottom
CalculateAttackHitbox
  rem Set hitbox based on attack type and direction
  on PlayerAttackType[attacker_id] goto MeleeHitbox, ProjectileHitbox, AreaHitbox
  
MeleeHitbox
    rem Melee hitbox extends PlayerSpriteWidth pixels in facing direction
    on PlayerFacing[attacker_id] goto FacingRight, FacingLeft, FacingUp, FacingDown
    
FacingRight
      rem Hitbox extends 16 pixels forward from sprite right edge
      rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
      rem Hitbox: [playerX+16, playerX+32] x [playerY, playerY+16]
      let hitbox_left = playerX[attacker_id] + PlayerSpriteWidth
      let hitbox_right = playerX[attacker_id] + PlayerSpriteWidth + PlayerSpriteWidth
      let hitbox_top = playerY[attacker_id]
      let hitbox_bottom = playerY[attacker_id] + PlayerSpriteHeight
      return
      
FacingLeft
      rem Hitbox extends 16 pixels forward from sprite left edge
      rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
      rem Hitbox: [playerX-16, playerX] x [playerY, playerY+16]
      let hitbox_left = playerX[attacker_id] - PlayerSpriteWidth
      let hitbox_right = playerX[attacker_id]
      let hitbox_top = playerY[attacker_id]
      let hitbox_bottom = playerY[attacker_id] + PlayerSpriteHeight
      return
      
FacingUp
      rem Hitbox extends 16 pixels upward from sprite top edge
      rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
      rem Hitbox: [playerX, playerX+16] x [playerY-16, playerY]
      let hitbox_left = playerX[attacker_id]
      let hitbox_right = playerX[attacker_id] + PlayerSpriteWidth
      let hitbox_top = playerY[attacker_id] - PlayerSpriteHeight
      let hitbox_bottom = playerY[attacker_id]
      return
      
FacingDown
      rem Hitbox extends 16 pixels downward from sprite bottom edge
      rem Attacker sprite: [playerX, playerX+16] x [playerY, playerY+16]
      rem Hitbox: [playerX, playerX+16] x [playerY+16, playerY+32]
      let hitbox_left = playerX[attacker_id]
      let hitbox_right = playerX[attacker_id] + PlayerSpriteWidth
      let hitbox_top = playerY[attacker_id] + PlayerSpriteHeight
      let hitbox_bottom = playerY[attacker_id] + PlayerSpriteHeight + PlayerSpriteHeight
      return
  
ProjectileHitbox
    rem Projectile hitbox is at current missile position (to be implemented)
    let hitbox_left = 0
    let hitbox_right = 0
    let hitbox_top = 0
    let hitbox_bottom = 0
    return
    
AreaHitbox
    rem Area hitbox covers radius around attacker (to be implemented)
    let hitbox_left = 0
    let hitbox_right = 0
    let hitbox_top = 0
    let hitbox_bottom = 0
    return

rem Process attack for one attacker against all defenders
rem Input: attacker_id
ProcessAttackerAttacks
  rem Check if attacker is facing right (PlayerStateFacing = bit 0)
  temp1 = playerState[attacker_id]
  if temp1{0} = 0 then return
  
  rem Attack each defender
  for defender = 0 to 3
    rem Skip if defender is attacker
    if defender = attacker_id then NextDefender
    
    rem Skip if defender is dead
    if playerHealth[defender] <= 0 then NextDefender
    
    rem Check if attack hits
    gosub CheckAttackHit attacker_id, defender
          if hit then gosub ApplyDamage attacker_id, defender
    
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
rem NOTE: VisualEffects.bas was phased out - damage indicators handled inline
CombatShowDamageIndicator
  rem Visual feedback now handled inline in damage calculation
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
rem   temp1 = attacker player index (0-3)
PerformMeleeAttack
  rem Spawn missile visual for this attack
  gosub bank7 SpawnMissile
  
  rem Set animation state to attacking
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << 4)
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
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | (AnimAttackExecute << 4)
          rem Set animation state 14 (attack execution)
  
  return

rem Process guard for a player
rem DEPRECATED: This function has syntax errors and conflicts with GuardEffects.bas
rem Guard restrictions are now handled in PlayerInput.bas (movement/attack blocking)
rem Guard timer updates are handled by UpdateGuardTimers in GuardEffects.bas
rem Input: player_id
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