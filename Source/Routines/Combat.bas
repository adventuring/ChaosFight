          rem ChaosFight - Source/Routines/Combat.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem COMBAT SYSTEM - Generic Subroutines Using Player Arrays
          rem

          rem Apply damage from attacker to defender
          rem Inputs: attackerID, defenderID (must be set before
          rem   calling)
          rem Process:
          rem   1. Player begins hurt animation (ActionHit = 5)
          rem 2. Player enters recovery frames count and color dims (or
          rem   magenta on SECAM)
          rem   3. If player health >= damage amount, decrement health
          rem 4. If player health < damage amount, player dies
          rem   (instantly vanishes)
ApplyDamage
          rem Apply damage from attacker to defender
          rem Input: attackerID (global) = attacker player index
          rem        defenderID (global) = defender player index
          rem        playerDamage[] (global array) = player damage values
          rem        playerHealth[] (global array) = player health values
          rem        ActionHit (constant) = hurt animation action
          rem Output: playerHealth[] reduced, playerRecoveryFrames[] set, playerState[] updated,
          rem         animation set to hurt, sound effect played, or player eliminated
          rem Mutates: temp1-temp4 (used for calculations), playerHealth[] (reduced or set to 0),
          rem         playerRecoveryFrames[] (set), playerState[] (recovery flag set),
          rem         currentPlayer (set to defenderID), temp2 (passed to SetPlayerAnimation)
          rem Called Routines: SetPlayerAnimation (bank11) - sets hurt animation,
          rem   CheckPlayerElimination - handles player elimination,
          rem   PlayDamageSound - plays damage sound effect
          rem Constraints: Must be colocated with PlayerDies, PlayDamageSound (called via goto)
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
          gosub SetPlayerAnimation bank11
          
          rem Calculate recovery frames (damage / 2, clamped 10-30)
          let AD_recoveryFrames = AD_damage / 2
          if AD_recoveryFrames < 10 then let AD_recoveryFrames = 10
          if AD_recoveryFrames > 30 then let AD_recoveryFrames = 30
          let playerRecoveryFrames[AD_defenderID] = AD_recoveryFrames
          
          rem Set playerState bit 3 (recovery flag) when recovery frames
          rem   are set
          let playerState[AD_defenderID] = playerState[AD_defenderID] | 8
          
          rem Sound effect
          rem tail call
          goto PlayDamageSound
          

PlayerDies
          rem Player dies - instantly vanish
          rem Input: AD_defenderID (from ApplyDamage) = defender player index
          rem        playerHealth[] (global array) = player health values
          rem Output: playerHealth[] set to 0, player eliminated, sound effect played
          rem Mutates: playerHealth[] (set to 0), currentPlayer (set to defenderID)
          rem Called Routines: CheckPlayerElimination - handles player elimination,
          rem   PlayDamageSound - plays damage sound effect
          rem Constraints: Must be colocated with ApplyDamage, PlayDamageSound
          let playerHealth[AD_defenderID] = 0
          
          rem Trigger elimination immediately (instantly vanish)
          rem CheckPlayerElimination will hide sprite and handle
          rem   elimination effects
          let currentPlayer = AD_defenderID
          gosub CheckPlayerElimination
          
          rem Sound effect
          rem tail call
          goto PlayDamageSound
          

          rem Check if attack hits defender
          rem Inputs: attackerID, defenderID (must be set before
          rem   calling)
          rem Returns: hit (1 = hit, 0 = miss)
          rem Uses cached hitbox values from ProcessAttackerAttacks
          rem   (cached once per attacker, reused for all defenders)
CheckAttackHit
          rem Check if attack hits defender using AABB collision detection
          rem Input: defenderID (global) = defender player index
          rem        playerX[], playerY[] (global arrays) = player positions
          rem        cachedHitboxLeft_R, cachedHitboxRight_R, cachedHitboxTop_R, cachedHitboxBottom_R (global SCRAM) = cached hitbox bounds
          rem        PlayerSpriteWidth, PlayerSpriteHeight (constants) = sprite dimensions
          rem Output: hit (global) = 1 if hit, 0 if miss
          rem Mutates: hit (set to 1 or 0)
          rem Called Routines: None
          rem Constraints: Must be colocated with NoHit (called via goto)
          rem              Uses cached hitbox values (set in ProcessAttackerAttacks)
          dim CAH_defenderID = defenderID
          rem Use cached hitbox values (set in ProcessAttackerAttacks)
          rem Check if defender bounding box overlaps hitbox (AABB
          rem   collision detection)
          rem playerX/playerY represent sprite top-left corner, sprite
          rem   is 16x16 pixels
          rem Defender bounding box: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          rem Hitbox: [cachedHitboxLeft, cachedHitboxRight] x [cachedHitboxTop,
          rem   cachedHitboxBottom]
          rem Overlap occurs when: defender_right > hitboxLeft AND
          rem   defender_left < hitboxRight
          rem AND defender_bottom > hitboxTop AND defender_top <
          rem   hitboxBottom
          if playerX[CAH_defenderID] + PlayerSpriteWidth <= cachedHitboxLeft_R then NoHit
          rem Defender right edge <= hitbox left edge (no overlap)
          if playerX[CAH_defenderID] >= cachedHitboxRight_R then NoHit
          rem Defender left edge >= hitbox right edge (no overlap)
          if playerY[CAH_defenderID] + PlayerSpriteHeight <= cachedHitboxTop_R then NoHit
          rem Defender bottom edge <= hitbox top edge (no overlap)
          if playerY[CAH_defenderID] >= cachedHitboxBottom_R then NoHit
          rem Defender top edge >= hitbox bottom edge (no overlap)
          
          rem All bounds checked - defender is inside hitbox
          let hit = 1
          return
   
NoHit
          rem Defender is outside hitbox bounds
          rem Input: None (called from CheckAttackHit)
          rem Output: hit set to 0
          rem Mutates: hit (set to 0)
          rem Called Routines: None
          rem Constraints: Must be colocated with CheckAttackHit
          let hit = 0
          return

          rem Calculate attack hitbox based on attacker position and
          rem   facing
          rem Inputs: attackerID (must be set before calling, or use
          rem   CAH_attackerID from CheckAttackHit)
          rem Outputs: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
CalculateAttackHitbox
          rem Calculate attack hitbox based on attacker position and facing
          rem Input: attackerID (global) = attacker player index
          rem        playerX[], playerY[] (global arrays) = player positions
          rem        PlayerAttackType[] (global array) = attack type for each player
          rem        PlayerFacing[] (global array) = facing direction for each player
          rem        PlayerSpriteWidth, PlayerSpriteHeight (constants) = sprite dimensions
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom (global) = hitbox bounds
          rem Mutates: temp1, temp2 (used for attack type and facing), hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
          rem Called Routines: None
          rem Constraints: Must be colocated with MeleeHitbox, ProjectileHitbox, AreaHitbox,
          rem              FacingRight, FacingLeft, FacingUp, FacingDown (all called via on/goto)
          dim CAH_attackerID_calc = attackerID
          rem Set hitbox based on attack type and direction
          rem Use temporary variable to avoid compiler bug with array indexing
          rem   in on statement
          dim CAH_attackType = temp1
          let CAH_attackType = PlayerAttackType[CAH_attackerID_calc]
          on CAH_attackType goto MeleeHitbox, ProjectileHitbox, AreaHitbox
          
MeleeHitbox
          rem Melee hitbox extends PlayerSpriteWidth pixels in facing direction
          rem Input: CAH_attackerID_calc, PlayerFacing[] (from CalculateAttackHitbox)
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom set based on facing direction
          rem Mutates: temp2 (facing direction), hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
          rem Called Routines: None
          rem Constraints: Must be colocated with CalculateAttackHitbox, FacingRight, FacingLeft, FacingUp, FacingDown
          rem Use temporary variable to avoid compiler bug with array indexing
          rem   in on statement
          dim CAH_facing = temp2
          let CAH_facing = PlayerFacing[CAH_attackerID_calc]
          on CAH_facing goto FacingRight, FacingLeft, FacingUp, FacingDown
          
FacingRight
          rem Hitbox extends 16 pixels forward from sprite right edge
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from MeleeHitbox)
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom set for right-facing attack
          rem Mutates: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
          rem Called Routines: None
          rem Constraints: Must be colocated with CalculateAttackHitbox, MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          rem Hitbox: [playerX+16, playerX+32] x [playerY, playerY+16]
          let hitboxLeft = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let hitboxRight = playerX[CAH_attackerID_calc] + PlayerSpriteWidth + PlayerSpriteWidth
          let hitboxTop = playerY[CAH_attackerID_calc]
          let hitboxBottom = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          return
          
FacingLeft
          rem Hitbox extends 16 pixels forward from sprite left edge
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from MeleeHitbox)
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom set for left-facing attack
          rem Mutates: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
          rem Called Routines: None
          rem Constraints: Must be colocated with CalculateAttackHitbox, MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          rem Hitbox: [playerX-16, playerX] x [playerY, playerY+16]
          let hitboxLeft = playerX[CAH_attackerID_calc] - PlayerSpriteWidth
          let hitboxRight = playerX[CAH_attackerID_calc]
          let hitboxTop = playerY[CAH_attackerID_calc]
          let hitboxBottom = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          return
          
FacingUp
          rem Hitbox extends 16 pixels upward from sprite top edge
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from MeleeHitbox)
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom set for up-facing attack
          rem Mutates: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
          rem Called Routines: None
          rem Constraints: Must be colocated with CalculateAttackHitbox, MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          rem Hitbox: [playerX, playerX+16] x [playerY-16, playerY]
          let hitboxLeft = playerX[CAH_attackerID_calc]
          let hitboxRight = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let hitboxTop = playerY[CAH_attackerID_calc] - PlayerSpriteHeight
          let hitboxBottom = playerY[CAH_attackerID_calc]
          return
          
FacingDown
          rem Hitbox extends 16 pixels downward from sprite bottom edge
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from MeleeHitbox)
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom set for down-facing attack
          rem Mutates: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom
          rem Called Routines: None
          rem Constraints: Must be colocated with CalculateAttackHitbox, MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          rem Hitbox: [playerX, playerX+16] x [playerY+16, playerY+32]
          let hitboxLeft = playerX[CAH_attackerID_calc]
          let hitboxRight = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let hitboxTop = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          let hitboxBottom = playerY[CAH_attackerID_calc] + PlayerSpriteHeight + PlayerSpriteHeight
          return
          
ProjectileHitbox
          rem Projectile hitbox is at current missile position (to be implemented)
          rem Input: None (placeholder)
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom set to 0 (placeholder)
          rem Mutates: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom (set to 0)
          rem Called Routines: None
          rem Constraints: Must be colocated with CalculateAttackHitbox
          let hitboxLeft = 0
          let hitboxRight = 0
          let hitboxTop = 0
          let hitboxBottom = 0
          return
          
AreaHitbox
          rem Area hitbox covers radius around attacker (to be implemented)
          rem Input: None (placeholder)
          rem Output: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom set to 0 (placeholder)
          rem Mutates: hitboxLeft, hitboxRight, hitboxTop, hitboxBottom (set to 0)
          rem Called Routines: None
          rem Constraints: Must be colocated with CalculateAttackHitbox
          let hitboxLeft = 0
          let hitboxRight = 0
          let hitboxTop = 0
          let hitboxBottom = 0
          return

          rem Process attack for one attacker against all defenders
          rem Input: attackerID (must be set before calling)
          rem Processes attacks in all directions (facing handled by
          rem   CalculateAttackHitbox)
          rem Caches hitbox once per attacker to avoid recalculating for
          rem   each defender
ProcessAttackerAttacks
          rem Process attack for one attacker against all defenders (caches hitbox once per attacker)
          rem Input: attackerID (global) = attacker player index, playerX[], playerY[] (global arrays) = player positions, PlayerAttackType[], PlayerFacing[] (global arrays) = attack type and facing, playerHealth[] (global array) = player health values
          rem Output: Attacks processed for all defenders, damage applied if hits detected
          rem Mutates: temp1-temp2 (used for calculations), hitboxLeft, hitboxRight, hitboxTop, hitboxBottom (global) = hitbox bounds (calculated), cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W (global SCRAM) = cached hitbox bounds (stored), defenderID (global) = defender index (set to 0-3), hit (global) = hit result (set by CheckAttackHit), playerHealth[], playerRecoveryFrames[], playerState[] (via ApplyDamage)
          rem Called Routines: CalculateAttackHitbox - calculates hitbox based on attacker position and facing, CheckAttackHit - checks if attack hits defender, ApplyDamage - applies damage if hit
          rem Constraints: Must be colocated with NextDefender (called via next). Caches hitbox once per attacker to avoid recalculating for each defender. Skips attacker as defender and dead players
          dim PAA_attackerID = attackerID
          rem Cache hitbox for this attacker (calculated once, used for all
          rem   defenders)
          gosub CalculateAttackHitbox
          let cachedHitboxLeft_W = hitboxLeft
          let cachedHitboxRight_W = hitboxRight
          let cachedHitboxTop_W = hitboxTop
          let cachedHitboxBottom_W = hitboxBottom
          
          rem Attack each defender
          for defenderID = 0 to 3
              rem Skip if defender is attacker
              if defenderID = PAA_attackerID then NextDefender
          
              rem Skip if defender is dead
              if playerHealth[defenderID] <= 0 then NextDefender
          
              rem Check if attack hits (uses cached hitbox)
              gosub CheckAttackHit
              if hit then gosub ApplyDamage
          
NextDefender
          rem Helper: End of defender loop iteration (label only)
          rem Input: None (label only)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Internal label for ProcessAttackerAttacks FOR loop
          next
          
          return

          rem Process all attacks for all players
ProcessAllAttacks
          rem Process all attacks for all players (orchestrates attack processing for all active players)
          rem Input: attackerID (global) = attacker index (set to 0-3), playerHealth[] (global array) = player health values
          rem Output: All attacks processed for all active players
          rem Mutates: attackerID (global) = attacker index (set to 0-3), all attack processing state (via ProcessAttackerAttacks)
          rem Called Routines: ProcessAttackerAttacks - processes attacks for one attacker against all defenders
          rem Constraints: Must be colocated with NextAttacker (called via next). Skips dead attackers
          for attackerID = 0 to 3
              rem Skip if attacker is dead
              if playerHealth[attackerID] <= 0 then NextAttacker
          
              gosub ProcessAttackerAttacks
          
NextAttacker
          rem Helper: End of attacker loop iteration (label only)
          rem Input: None (label only)
          rem Output: None (label only)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: Internal label for ProcessAllAttacks FOR loop
          next
          
          return

          rem Damage indicator system
          rem NOTE: VisualEffects.bas was phased out - damage indicators
          rem   handled inline
CombatShowDamageIndicator
          rem Damage indicator system (phased out - visual feedback now handled inline)
          rem Input: None
          rem Output: None (no-op)
          rem Mutates: None
          rem Called Routines: None
          rem Constraints: VisualEffects.bas was phased out - damage indicators handled inline in damage calculation
          rem Visual feedback now handled inline in damage calculation
          return

PlayDamageSound
          rem Play damage sound effect (attack hit sound)
          rem Input: SoundAttackHit (global constant) = sound effect ID
          rem Output: Sound effect played
          rem Mutates: temp1 (set to sound ID)
          rem Called Routines: PlaySoundEffect (bank15) - plays sound effect
          rem Constraints: None
          dim PDS_soundId = temp1
          let PDS_soundId = SoundAttackHit
          gosub PlaySoundEffect bank15
          return

