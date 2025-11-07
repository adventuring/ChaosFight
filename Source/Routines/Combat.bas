ApplyDamage
          rem
          rem ChaosFight - Source/Routines/Combat.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem COMBAT SYSTEM - Generic Subroutines Using Player Arrays
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
          rem Apply damage from attacker to defender
          rem
          rem Input: attackerID (global) = attacker player index
          rem        defenderID (global) = defender player index
          rem        playerDamage[] (global array) = player damage
          rem        values
          rem        playerHealth[] (global array) = player health
          rem        values
          rem        ActionHit (constant) = hurt animation action
          rem
          rem Output: playerHealth[] reduced, playerRecoveryFrames[]
          rem set, playerState[] updated,
          rem         animation set to hurt, sound effect played, or
          rem         player eliminated
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem playerHealth[] (reduced or set to 0),
          rem         playerRecoveryFrames[] (set), playerState[]
          rem         (recovery flag set),
          rem         currentPlayer (set to defenderID), temp2 (passed
          rem         to SetPlayerAnimation)
          rem
          rem Called Routines: SetPlayerAnimation (bank11) - sets hurt
          rem animation,
          rem   CheckPlayerElimination - handles player elimination,
          rem   PlayDamageSound - plays damage sound effect
          rem
          rem Constraints: Must be colocated with PlayerDies,
          rem PlayDamageSound (called via goto)
          dim AD_attackerID = attackerID
          dim AD_defenderID = defenderID
          dim AD_damage = temp1
          dim AD_currentHealth = temp2
          dim AD_willDie = temp3
          dim AD_recoveryFrames = temp4
          
          let AD_damage = playerDamage_R[AD_attackerID] - playerDamage_R[AD_defenderID] : rem Calculate damage (considering defender state)
          if AD_damage < 1 then let AD_damage = 1 : rem Minimum damage

          let AD_currentHealth = playerHealth[AD_defenderID] : rem Check if player will die from this damage
          let AD_willDie = 0
          if AD_currentHealth < AD_damage then let AD_willDie = 1 : rem Will die
          
          if AD_willDie then goto PlayerDies : rem If player will die, instantly vanish (eliminate)
          
          let playerHealth[AD_defenderID] = AD_currentHealth - AD_damage : rem Player survives - apply damage and enter hurt state
          
          let currentPlayer = AD_defenderID : rem Set hurt animation (ActionHit = 5)
          let temp2 = ActionHit
          gosub SetPlayerAnimation bank11
          
          let AD_recoveryFrames = AD_damage / 2 : rem Calculate recovery frames (damage / 2, clamped 10-30)
          if AD_recoveryFrames < 10 then let AD_recoveryFrames = 10
          if AD_recoveryFrames > 30 then let AD_recoveryFrames = 30
          let playerRecoveryFrames[AD_defenderID] = AD_recoveryFrames
          
          rem Set playerState bit 3 (recovery flag) when recovery frames
          let playerState[AD_defenderID] = playerState[AD_defenderID] | 8 : rem   are set
          
          rem Sound effect
          goto PlayDamageSound : rem tail call
          

PlayerDies
          rem Player dies - instantly vanish
          rem
          rem Input: AD_defenderID (from ApplyDamage) = defender player
          rem index
          rem        playerHealth[] (global array) = player health
          rem        values
          rem
          rem Output: playerHealth[] set to 0, player eliminated, sound
          rem effect played
          rem
          rem Mutates: playerHealth[] (set to 0), currentPlayer (set to
          rem defenderID)
          rem
          rem Called Routines: CheckPlayerElimination - handles player
          rem elimination,
          rem   PlayDamageSound - plays damage sound effect
          let playerHealth[AD_defenderID] = 0 : rem Constraints: Must be colocated with ApplyDamage, PlayDamageSound
          
          rem Trigger elimination immediately (instantly vanish)
          rem CheckPlayerElimination will hide sprite and handle
          let currentPlayer = AD_defenderID : rem   elimination effects
          gosub CheckPlayerElimination
          
          rem Sound effect
          goto PlayDamageSound : rem tail call
          

CheckAttackHit
          rem Check if attack hits defender
          rem Inputs: attackerID, defenderID (must be set before
          rem   calling)
          rem
          rem Returns: hit (1 = hit, 0 = miss)
          rem Uses cached hitbox values from ProcessAttackerAttacks
          rem   (cached once per attacker, reused for all defenders)
          rem Check if attack hits defender using AABB collision
          rem detection
          rem
          rem Input: defenderID (global) = defender player index
          rem        playerX[], playerY[] (global arrays) = player
          rem        positions
          rem        cachedHitboxLeft_R, cachedHitboxRight_R,
          rem        cachedHitboxTop_R, cachedHitboxBottom_R (global
          rem        SCRAM) = cached hitbox bounds
          rem        PlayerSpriteWidth, PlayerSpriteHeight (constants) =
          rem        sprite dimensions
          rem
          rem Output: hit (global) = 1 if hit, 0 if miss
          rem
          rem Mutates: hit (set to 1 or 0)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with NoHit (called via
          rem goto)
          dim CAH_defenderID = defenderID : rem              Uses cached hitbox values (set in ProcessAttackerAttacks)
          rem Use cached hitbox values (set in ProcessAttackerAttacks)
          rem Check if defender bounding box overlaps hitbox (AABB
          rem   collision detection)
          rem playerX/playerY represent sprite top-left corner, sprite
          rem   is 16x16 pixels
          rem Defender bounding box: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          rem Hitbox: [cachedHitboxLeft, cachedHitboxRight] x
          rem [cachedHitboxTop,
          rem   cachedHitboxBottom]
          rem Overlap occurs when: defender_right > cachedHitboxLeft_R AND
          rem   defender_left < cachedHitboxRight_R
          rem AND defender_bottom > hitboxTop AND defender_top <
          if playerX[CAH_defenderID] + PlayerSpriteWidth <= cachedHitboxLeft_R then NoHit : rem   hitboxBottom
          rem Defender right edge <= hitbox left edge (no overlap)
          if playerX[CAH_defenderID] >= cachedHitboxRight_R then NoHit
          rem Defender left edge >= hitbox right edge (no overlap)
          if playerY[CAH_defenderID] + PlayerSpriteHeight <= cachedHitboxTop_R then NoHit
          rem Defender bottom edge <= hitbox top edge (no overlap)
          if playerY[CAH_defenderID] >= cachedHitboxBottom_R then NoHit
          rem Defender top edge >= hitbox bottom edge (no overlap)
          
          let hit = 1 : rem All bounds checked - defender is inside hitbox
          return
   
NoHit
          rem Defender is outside hitbox bounds
          rem
          rem Input: None (called from CheckAttackHit)
          rem
          rem Output: hit set to 0
          rem
          rem Mutates: hit (set to 0)
          rem
          rem Called Routines: None
          let hit = 0 : rem Constraints: Must be colocated with CheckAttackHit
          return

CalculateAttackHitbox
          rem Calculate attack hitbox based on attacker position and
          rem   facing
          rem Inputs: attackerID (must be set before calling, or use
          rem   CAH_attackerID from CheckAttackHit)
          rem Outputs: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem Calculate attack hitbox based on attacker position and
          rem facing
          rem
          rem Input: attackerID (global) = attacker player index
          rem        playerX[], playerY[] (global arrays) = player
          rem        positions
          rem        PlayerAttackType[] (global array) = attack type for
          rem        each player
          rem        PlayerFacing[] (global array) = facing direction
          rem        for each player
          rem        PlayerSpriteWidth, PlayerSpriteHeight (constants) =
          rem        sprite dimensions
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem (global) = hitbox bounds
          rem
          rem Mutates: temp1, temp2 (used for attack type and facing),
          rem cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with MeleeHitbox,
          rem ProjectileHitbox, AreaHitbox,
          rem              FacingRight, FacingLeft, FacingUp, FacingDown
          rem              (all called via on/goto)
          dim CAH_attackerID_calc = attackerID
          rem Set hitbox based on attack type and direction
          rem Use temporary variable to avoid compiler bug with array
          rem indexing
          dim CAH_attackType = temp1 : rem   in on statement
          let CAH_attackType = PlayerAttackType[CAH_attackerID_calc]
          if CAH_attackType = 0 then goto MeleeHitbox
          if CAH_attackType = 1 then goto ProjectileHitbox
          if CAH_attackType = 2 then goto AreaHitbox
          
MeleeHitbox
          rem Melee hitbox extends PlayerSpriteWidth pixels in facing
          rem direction
          rem
          rem Input: CAH_attackerID_calc, PlayerFacing[] (from
          rem CalculateAttackHitbox)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem set based on facing direction
          rem
          rem Mutates: temp2 (facing direction), cachedHitboxLeft_W,
          rem cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CalculateAttackHitbox,
          rem FacingRight, FacingLeft, FacingUp, FacingDown
          rem Use temporary variable to avoid compiler bug with array
          rem indexing
          dim CAH_facing = temp2 : rem   in on statement
          let CAH_facing = PlayerFacing[CAH_attackerID_calc]
          if CAH_facing = 0 then goto FacingRight
          if CAH_facing = 1 then goto FacingLeft
          if CAH_facing = 2 then goto FacingUp
          if CAH_facing = 3 then goto FacingDown
          
FacingRight
          rem Hitbox extends 16 pixels forward from sprite right edge
          rem
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from
          rem MeleeHitbox)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem set for right-facing attack
          rem
          rem Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CalculateAttackHitbox,
          rem MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          let cachedHitboxLeft_W = playerX[CAH_attackerID_calc] + PlayerSpriteWidth : rem Hitbox: [playerX+16, playerX+32] x [playerY, playerY+16]
          let cachedHitboxRight_W = playerX[CAH_attackerID_calc] + PlayerSpriteWidth + PlayerSpriteWidth
          let cachedHitboxTop_W = playerY[CAH_attackerID_calc]
          let cachedHitboxBottom_W = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          return
          
FacingLeft
          rem Hitbox extends 16 pixels forward from sprite left edge
          rem
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from
          rem MeleeHitbox)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem set for left-facing attack
          rem
          rem Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CalculateAttackHitbox,
          rem MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          let cachedHitboxLeft_W = playerX[CAH_attackerID_calc] - PlayerSpriteWidth : rem Hitbox: [playerX-16, playerX] x [playerY, playerY+16]
          let cachedHitboxRight_W = playerX[CAH_attackerID_calc]
          let cachedHitboxTop_W = playerY[CAH_attackerID_calc]
          let cachedHitboxBottom_W = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          return
          
FacingUp
          rem Hitbox extends 16 pixels upward from sprite top edge
          rem
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from
          rem MeleeHitbox)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem set for up-facing attack
          rem
          rem Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CalculateAttackHitbox,
          rem MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          let cachedHitboxLeft_W = playerX[CAH_attackerID_calc] : rem Hitbox: [playerX, playerX+16] x [playerY-16, playerY]
          let cachedHitboxRight_W = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let cachedHitboxTop_W = playerY[CAH_attackerID_calc] - PlayerSpriteHeight
          let cachedHitboxBottom_W = playerY[CAH_attackerID_calc]
          return
          
FacingDown
          rem Hitbox extends 16 pixels downward from sprite bottom edge
          rem
          rem Input: CAH_attackerID_calc, playerX[], playerY[] (from
          rem MeleeHitbox)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem set for down-facing attack
          rem
          rem Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CalculateAttackHitbox,
          rem MeleeHitbox
          rem Attacker sprite: [playerX, playerX+16] x [playerY,
          rem   playerY+16]
          let cachedHitboxLeft_W = playerX[CAH_attackerID_calc] : rem Hitbox: [playerX, playerX+16] x [playerY+16, playerY+32]
          let cachedHitboxRight_W = playerX[CAH_attackerID_calc] + PlayerSpriteWidth
          let cachedHitboxTop_W = playerY[CAH_attackerID_calc] + PlayerSpriteHeight
          let cachedHitboxBottom_W = playerY[CAH_attackerID_calc] + PlayerSpriteHeight + PlayerSpriteHeight
          return
          
ProjectileHitbox
          rem Projectile hitbox is at current missile position (to be
          rem implemented)
          rem
          rem Input: None (placeholder)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem set to 0 (placeholder)
          rem
          rem Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem (set to 0)
          rem
          rem Called Routines: None
          let cachedHitboxLeft_W = 0 : rem Constraints: Must be colocated with CalculateAttackHitbox
          let cachedHitboxRight_W = 0
          let cachedHitboxTop_W = 0
          let cachedHitboxBottom_W = 0
          return
          
AreaHitbox
          rem Area hitbox covers radius around attacker (to be
          rem implemented)
          rem
          rem Input: None (placeholder)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem set to 0 (placeholder)
          rem
          rem Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem (set to 0)
          rem
          rem Called Routines: None
          let cachedHitboxLeft_W = 0 : rem Constraints: Must be colocated with CalculateAttackHitbox
          let cachedHitboxRight_W = 0
          let cachedHitboxTop_W = 0
          let cachedHitboxBottom_W = 0
          return

ProcessAttackerAttacks
          rem Process attack for one attacker against all defenders
          rem
          rem Input: attackerID (must be set before calling)
          rem Processes attacks in all directions (facing handled by
          rem   CalculateAttackHitbox)
          rem Caches hitbox once per attacker to avoid recalculating for
          rem   each defender
          rem Process attack for one attacker against all defenders
          rem (caches hitbox once per attacker)
          rem
          rem Input: attackerID (global) = attacker player index,
          rem playerX[], playerY[] (global arrays) = player positions,
          rem PlayerAttackType[], PlayerFacing[] (global arrays) =
          rem attack type and facing, playerHealth[] (global array) =
          rem player health values
          rem
          rem Output: Attacks processed for all defenders, damage
          rem applied if hits detected
          rem
          rem Mutates: temp1-temp2 (used for calculations), cachedHitboxLeft_W,
          rem cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W (global) = hitbox
          rem bounds (calculated), cachedHitboxLeft_W,
          rem cachedHitboxRight_W, cachedHitboxTop_W,
          rem cachedHitboxBottom_W (global SCRAM) = cached hitbox bounds
          rem (stored), defenderID (global) = defender index (set to
          rem 0-3), hit (global) = hit result (set by CheckAttackHit),
          rem playerHealth[], playerRecoveryFrames[], playerState[] (via
          rem ApplyDamage)
          rem
          rem Called Routines: CalculateAttackHitbox - calculates hitbox
          rem based on attacker position and facing, CheckAttackHit -
          rem checks if attack hits defender, ApplyDamage - applies
          rem damage if hit
          rem
          rem Constraints: Must be colocated with NextDefender (called
          rem via next). Caches hitbox once per attacker to avoid
          rem recalculating for each defender. Skips attacker as
          rem defender and dead players
          dim PAA_attackerID = attackerID
          rem Cache hitbox for this attacker (calculated once, used for
          rem all
          gosub CalculateAttackHitbox : rem   defenders)
          rem Hitbox values are already written into cachedHitbox*_W via aliasing
          
          for defenderID = 0 to 3 : rem Attack each defender
              if defenderID = PAA_attackerID then NextDefender : rem Skip if defender is attacker
          
              if playerHealth[defenderID] <= 0 then NextDefender : rem Skip if defender is dead
          
              gosub CheckAttackHit : rem Check if attack hits (uses cached hitbox)
              if hit then gosub ApplyDamage
          
NextDefender
          next
          rem Helper: End of defender loop iteration (label only)
          return
          rem Input: None (label only)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal label for ProcessAttackerAttacks FOR
          rem loop

ProcessAllAttacks
          rem Process all attacks for all players
          rem Process all attacks for all players (orchestrates attack
          rem processing for all active players)
          rem
          rem Input: attackerID (global) = attacker index (set to 0-3),
          rem playerHealth[] (global array) = player health values
          rem
          rem Output: All attacks processed for all active players
          rem
          rem Mutates: attackerID (global) = attacker index (set to
          rem 0-3), all attack processing state (via
          rem ProcessAttackerAttacks)
          rem
          rem Called Routines: ProcessAttackerAttacks - processes
          rem attacks for one attacker against all defenders
          rem
          rem Constraints: Must be colocated with NextAttacker (called
          rem via next). Skips dead attackers
          for attackerID = 0 to 3
              if playerHealth[attackerID] <= 0 then NextAttacker : rem Skip if attacker is dead
          
              gosub ProcessAttackerAttacks
          
NextAttacker
          next
          rem Helper: End of attacker loop iteration (label only)
          return
          rem Input: None (label only)
          rem
          rem Output: None (label only)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Internal label for ProcessAllAttacks FOR loop

CombatShowDamageIndicator
          rem Damage indicator system
          rem NOTE: VisualEffects.bas was phased out - damage indicators
          rem   handled inline
          return
PlayDamageSound
          rem Damage indicator system (phased out - visual feedback now
          rem handled inline)
          rem
          rem Input: None
          rem
          rem Output: None (no-op)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: VisualEffects.bas was phased out - damage
          rem indicators handled inline in damage calculation
          rem Visual feedback now handled inline in damage calculation
          rem Play damage sound effect (attack hit sound)
          rem
          rem Input: SoundAttackHit (global constant) = sound effect ID
          rem
          rem Output: Sound effect played
          rem
          rem Mutates: temp1 (set to sound ID)
          rem
          rem Called Routines: PlaySoundEffect (bank15) - plays sound
          rem effect
          dim PDS_soundId = temp1 : rem Constraints: None
          let PDS_soundId = SoundAttackHit
          gosub PlaySoundEffect bank15
          return

