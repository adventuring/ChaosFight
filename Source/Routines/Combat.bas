rem ChaosFight - Source/Routines/Combat.bas
rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
rem COMBAT SYSTEM - Generic subroutines using player arrays
          rem =================================================================

rem Apply damage from attacker to defender
rem Inputs: attackerId, defenderId
ApplyDamage
          rem Calculate damage (considering defender state)
          let damage = PlayerDamage(attackerId) - PlayerDamage(defenderId)
          if damage < 1 then let damage = 1  rem Minimum damage
          
          rem Apply damage
          let PlayerHealth[defenderId] = PlayerHealth[defenderId] - damage
          
          rem Visual feedback (to be implemented)
          gosub ShowDamageIndicator defenderId, damage
          
          rem Sound effect (to be implemented)
          gosub PlayDamageSound damage
          
          return

rem Check if attack hits defender
rem Inputs: attackerId, defenderId
rem Returns: hit (1 = hit, 0 = miss)
CheckAttackHit
          rem Calculate attack hitbox based on attacker facing and attack type
          gosub CalculateAttackHitbox attackerId
          
          rem Check if defender is in hitbox
          rem Initialize hit to 0 (miss)
          let hit = 0
          if PlayerX[defenderId] < hitboxLeft then goto NoHit
          if PlayerX[defenderId] > hitboxRight then goto NoHit
          if PlayerY[defenderId] < hitboxTop then goto NoHit
          if PlayerY[defenderId] > hitboxBottom then goto NoHit
          rem All bounds checks passed - hit detected
          let hit = 1
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
          let hitboxLeft = PlayerX[attackerId] + 8
          let hitboxRight = PlayerX[attackerId] + 24
          let hitboxTop = PlayerY[attackerId] - 8
          let hitboxBottom = PlayerY[attackerId] + 8
          return
          
FacingLeft
          let hitboxLeft = PlayerX[attackerId] - 24
          let hitboxRight = PlayerX[attackerId] - 8
          let hitboxTop = PlayerY[attackerId] - 8
          let hitboxBottom = PlayerY[attackerId] + 8
          return
          
FacingUp
          let hitboxLeft = PlayerX[attackerId] - 8
          let hitboxRight = PlayerX[attackerId] + 8
          let hitboxTop = PlayerY[attackerId] - 24
          let hitboxBottom = PlayerY[attackerId] - 8
          return
          
FacingDown
          let hitboxLeft = PlayerX[attackerId] - 8
          let hitboxRight = PlayerX[attackerId] + 8
          let hitboxTop = PlayerY[attackerId] + 8
          let hitboxBottom = PlayerY[attackerId] + 24
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
rem Input: attackerId
ProcessAttackerAttacks
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
          let temp1 = SoundHit
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
          let PlayerState[temp1] = (PlayerState[temp1] & %00001111) | (14 << 4)
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
          let PlayerState[temp1] = (PlayerState[temp1] & %00001111) | (14 << 4)
          rem Set animation state 14 (attack execution)
          
          return

rem Process guard for a player
rem DEPRECATED: This function has syntax errors and conflicts with GuardEffects.bas
rem Guard restrictions are now handled in PlayerInput.bas (movement/attack blocking)
rem Guard timer updates are handled by UpdateGuardTimers in GuardEffects.bas
rem Input: playerId
ProcessPlayerGuard
          rem This function is deprecated - guard restrictions are handled elsewhere
          rem Guard prevents movement - handled in PlayerInput.bas
          rem Guard prevents attacks - handled in PlayerInput.bas
          return

rem Update player guard state
rem DEPRECATED: This function is deprecated - use UpdateGuardTimers in GuardEffects.bas instead
rem Guard timer updates are handled by UpdateGuardTimers in GuardEffects.bas
rem Input: playerId
UpdatePlayerGuard
          rem This function is deprecated - use UpdateGuardTimers in GuardEffects.bas instead
          return