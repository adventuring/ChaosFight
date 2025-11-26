          rem ChaosFight - Source/Routines/Combat.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem COMBAT SYSTEM - Generic Subroutines Using Player Arrays
GetWeightBasedDamage
          asm
GetWeightBasedDamage
end
          rem Calculate damage value based on character weight
          rem Issue #1149: Deduplicated weight-tier calculation
          rem
          rem Input: temp1 = character index (0-31)
          rem        CharacterWeights[] (global data table) = character weights
          rem
          rem Output: temp2 = damage value (12, 18, or 22)
          rem
          rem Mutates: temp3 (used for weight lookup), temp2 (return value)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with ApplyDamage
          rem Weight tiers: <=15 = 12 damage, <=25 = 18 damage, >25 = 22 damage
          let temp3 = CharacterWeights[temp1]
          if temp3 <= 15 then temp2 = 12 : return
          if temp3 <= 25 then temp2 = 18 : return
          let temp2 = 22
          return thisbank
ApplyDamage
          asm
ApplyDamage

end
          rem Apply damage from attacker to defender
          rem
          rem Process:
          rem   1. Player begins hurt animation (ActionHit = 5)
          rem   2. Player enters recovery frames count and color dims (or
          rem      magenta on SECAM)
          rem   3. If player health >= damage amount, decrement health
          rem   4. If player health < damage amount, player dies
          rem      (instantly vanishes)
          rem
          rem Input: attackerID (global) = attacker player index
          rem        defenderID (global) = defender player index
          rem        playerHealth[] (global array) = player health values
          rem        ActionHit (constant) = hurt animation action
          rem
          rem Output: playerHealth[] reduced, playerRecoveryFrames[]
          rem         set, playerState[] updated,
          rem         animation set to hurt, sound effect played, or
          rem         player eliminated
          rem
          rem Mutates: temp1-temp4 (used for calculations),
          rem         playerHealth[] (reduced or set to 0),
          rem         playerRecoveryFrames[] (set), playerState[]
          rem         (recovery flag set),
          rem         currentPlayer (set to defenderID), temp2 (passed
          rem         to SetPlayerAnimation)
          rem
          rem Called Routines: GetCharacterDamage (bank12) - obtains base
          rem   damage per character, SetPlayerAnimation (bank12) - sets
          rem   hurt animation, CheckPlayerElimination - handles player
          rem   elimination, PlayDamageSound - plays damage sound effect
          rem
          rem Constraints: Must be colocated with PlayerDies,
          rem         PlayDamageSound, GetWeightBasedDamage (called via goto/gosub)

          rem Issue #1149: Use shared helper instead of duplicated logic
          let temp1 = playerCharacter[attackerID]
          gosub GetWeightBasedDamage
          let temp4 = temp2
          let temp1 = playerCharacter[defenderID]
          rem Calculate damage (considering defender state)
          gosub GetWeightBasedDamage
          rem Minimum damage
          let temp1 = temp4 - temp2
          if temp1 < 1 then temp1 = 1

          rem Check if player will die from this damage
          let temp2 = playerHealth[defenderID]
          rem Will die
          let temp3 = 0
          if temp2 < temp1 then temp3 = 1

          rem If player will die, instantly vanish (eliminate)

          if temp3 then goto PlayerDies

          rem Player survives - apply damage and enter hurt state
          let playerHealth[defenderID] = temp2 - temp1

          rem Set hurt animation (ActionHit = 5)
          let currentPlayer = defenderID
          let temp2 = ActionHit
          gosub SetPlayerAnimation bank12

          rem Calculate recovery frames (damage ÷ 2, clamped 10-30)
          let temp4 = temp1 / 2
          if temp4 < 10 then temp4 = 10
          if temp4 > 30 then temp4 = 30
          let playerRecoveryFrames[defenderID] = temp4

          rem Set playerState bit 3 (recovery flag) when recovery frames are set
          let playerState[defenderID] = playerState[defenderID] | 8

          rem Issue #1180: Ursulo uppercut knock-up scaling with target weight
          rem Ursulo’s punches toss opponents upward with launch height proportional to target weight
          rem Lighter characters travel higher than heavyweights
          let temp1 = playerCharacter[attackerID]
          if temp1 = CharacterUrsulo then goto ApplyUrsuloKnockUp

          rem Sound effect (tail call)
          goto PlayDamageSound

ApplyUrsuloKnockUp
          rem Issue #1180: Apply vertical knockback based on target weight
          rem Lighter characters get launched higher (inverse relationship: lower weight = higher launch)
          rem
          rem Input: defenderID (global) = defender player index
          rem        CharacterWeights[] (global data table) = character weights
          rem        playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity
          rem
          rem Output: playerVelocityY[] set to upward velocity (negative value)
          rem        Launch height inversely proportional to target weight
          rem
          rem Mutates: temp1-temp4 (used for weight lookup and velocity calculation)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with ApplyDamage
          rem Get defender’s weight
          rem Weight values range 5-100 (lightest to heaviest)
          let temp1 = playerCharacter[defenderID]
          rem Calculate upward velocity: lighter = higher launch (inverse relationship)
          rem Formula: launch_velocity = max_launch - (weight / weight_scale_factor)
          rem Max launch: 12 pixels/frame upward (244 in signed 8-bit = -12) for lightest
          rem Min launch: 4 pixels/frame (252 in signed 8-bit = -4) for heaviest
          rem Weight scale: divide weight by 12 to get velocity reduction (0-8 range)
          rem Use precomputed lookup table (avoids expensive division on Atari 2600)
          rem Values already clamped to 0-8 range in lookup table
          let temp3 = CharacterWeightDiv12[temp1]
          rem Calculate upward velocity: max_launch - reduction
          rem 244 = -12 (highest), 245 = -11, ..., 252 = -4 (lowest)
          rem Clamp to valid range (244-252)
          let temp4 = 244 + temp3
          rem Apply upward velocity to defender (negative value = upward)
          if temp4 > 252 then temp4 = 252
          let playerVelocityY[defenderID] = temp4
          rem Set jumping flag so gravity applies correctly and animation system handles airborne state
          let playerVelocityYL[defenderID] = 0
          let playerState[defenderID] = playerState[defenderID] | PlayerStateBitJumping

          rem Sound effect (tail call)
          goto PlayDamageSound


PlayerDies
          rem Player dies - instantly vanish
          rem
          rem Input: defenderID (from ApplyDamage) = defender player
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
          rem Constraints: Must be colocated with ApplyDamage, PlayDamageSound
          let playerHealth[defenderID] = 0

          rem Trigger elimination immediately (instantly vanish)
          rem CheckPlayerElimination will hide sprite and handle
          rem   elimination effects
          let currentPlayer = defenderID
          gosub CheckPlayerElimination bank14

          rem Sound effect
          rem tail call
          goto PlayDamageSound


CheckAttackHit
          asm
CheckAttackHit
end
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
          rem Uses cached hitbox values (set in ProcessAttackerAttacks)
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
          rem hitboxBottom
          rem Defender right edge <= hitbox left edge (no overlap)
          if playerX[defenderID] + PlayerSpriteWidth <= cachedHitboxLeft_R then NoHit
          rem Defender left edge >= hitbox right edge (no overlap)
          if playerX[defenderID] >= cachedHitboxRight_R then NoHit
          rem Defender bottom edge <= hitbox top edge (no overlap)
          if playerY[defenderID] + PlayerSpriteHeight <= cachedHitboxTop_R then NoHit
          rem Defender top edge >= hitbox bottom edge (no overlap)
          if playerY[defenderID] >= cachedHitboxBottom_R then NoHit

          rem All bounds checked - defender is inside hitbox
          let hit = 1
          return thisbank
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
          rem Constraints: Must be colocated with CheckAttackHit
          let hit = 0
          return thisbank
CalculateAttackHitbox
          asm
CalculateAttackHitbox

end
          rem Compute attack hitbox bounds from attacker position and facing.
          rem Inputs: attackerID (global), playerX[], playerY[], playerAttackType_R[],
          rem        playerState[] (for facing direction), PlayerSpriteWidth, PlayerSpriteHeight
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          rem         cachedHitboxBottom_W (global hitbox bounds)
          rem Mutates: temp1, temp2, cachedHitboxLeft_W, cachedHitboxRight_W,
          rem         cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with MeleeHitbox,
          rem ProjectileHitbox, AreaHitbox,
          rem              FacingRight, FacingLeft (all called via goto)
          rem Set hitbox based on attack type and direction
          rem Use temporary variable to avoid compiler bug with array
          rem indexing
          rem in on statement
          let temp1 = playerAttackType_R[attackerID]
          if temp1 = 0 then goto MeleeHitbox
          if temp1 = 1 then goto ProjectileHitbox
          if temp1 = 2 then goto AreaHitbox

MeleeHitbox
          rem Mêlée hitbox extends PlayerSpriteWidth pixels in facing
          rem direction
          rem
          rem Input: attackerID, playerState[] (from
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
          rem FacingRight, FacingLeft
          rem Extract facing from playerState bit 3: 1=right (goto FacingRight), 0=left (goto FacingLeft)
          let temp2 = playerState[attackerID] & PlayerStateBitFacing
          if temp2 then goto FacingRight
          goto FacingLeft

FacingRight
          rem Hitbox extends 16 pixels forward from sprite right edge
          rem
          rem Input: attackerID, playerX[], playerY[] (from
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
          rem Hitbox: [playerX+16, playerX+32] x [playerY, playerY+16]
          let cachedHitboxLeft_W = playerX[attackerID] + PlayerSpriteWidth
          let cachedHitboxRight_W = playerX[attackerID] + PlayerSpriteWidth + PlayerSpriteWidth
          let cachedHitboxTop_W = playerY[attackerID]
          let cachedHitboxBottom_W = playerY[attackerID] + PlayerSpriteHeight
          return thisbank
FacingLeft
          rem Hitbox extends 16 pixels forward from sprite left edge
          rem
          rem Input: attackerID, playerX[], playerY[] (from
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
          rem Hitbox: [playerX-16, playerX] x [playerY, playerY+16]
          let cachedHitboxLeft_W = playerX[attackerID] - PlayerSpriteWidth
          let cachedHitboxRight_W = playerX[attackerID]
          let cachedHitboxTop_W = playerY[attackerID]
          let cachedHitboxBottom_W = playerY[attackerID] + PlayerSpriteHeight
          return thisbank
ProjectileHitbox
          rem Projectile attacks handled by missile collision system
          rem Issue #1148: Skip projectile hitbox calculation since missiles
          rem handle their own collisions via MissileCollision routines
          rem
          rem Input: attackerID (from CalculateAttackHitbox)
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          rem cachedHitboxBottom_W set to invalid bounds (will never match)
          rem
          rem Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          rem cachedHitboxBottom_W (set to invalid values)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CalculateAttackHitbox
          rem Set invalid bounds that will never match any defender
          rem (ensures CheckAttackHit always returns miss for projectiles)
          let cachedHitboxLeft_W = 255
          let cachedHitboxRight_W = 0
          let cachedHitboxTop_W = 255
          let cachedHitboxBottom_W = 0
          return thisbank
AreaHitbox
          rem Area hitbox covers radius around attacker center
          rem Issue #1148: Implement radius-based area-of-effect hitbox
          rem
          rem Input: attackerID (from CalculateAttackHitbox), playerX[],
          rem playerY[] (global arrays) = attacker position
          rem
          rem Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          rem cachedHitboxBottom_W set to area bounds (24px radius from center)
          rem
          rem Mutates: temp2 (used for center calculation), cachedHitboxLeft_W,
          rem cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CalculateAttackHitbox
          rem Area radius: 24 pixels (1.5× sprite width) centered on attacker
          rem Calculate attacker center (sprite midpoint)
          rem Center X = playerX + half sprite width
          let temp2 = playerX[attackerID] + 8
          rem Left edge: center - radius
          let cachedHitboxLeft_W = temp2 - 24
          rem Right edge: center + radius
          let cachedHitboxRight_W = temp2 + 24
          rem Center Y = playerY + half sprite height
          let temp2 = playerY[attackerID] + 8
          rem Top edge: center - radius
          let cachedHitboxTop_W = temp2 - 24
          rem Bottom edge: center + radius
          let cachedHitboxBottom_W = temp2 + 24
          return thisbank
ProcessAttackerAttacks
          asm
ProcessAttackerAttacks
end
          rem Process attacks for one attacker against all defenders.
          rem Input: attackerID (must be set before calling); facing handled by
          rem        CalculateAttackHitbox which caches bounds once per attacker.
          rem
          rem Input: attackerID (global) = attacker player index,
          rem playerX[], playerY[] (global arrays) = player positions,
          rem playerAttackType_R[], playerState[] (global arrays) =
          rem attack type and facing, playerHealth[] (global array) =
          rem player health values
          rem
          rem Output: Attacks processed for all defenders, damage
          rem applied if hits detected
          rem
          rem Mutates: temp1-temp2, cachedHitboxLeft_W/cachedHitboxRight_W/
          rem         cachedHitboxTop_W/cachedHitboxBottom_W (cached bounds),
          rem         defenderID (0-3), hit (CheckAttackHit result),
          rem         playerHealth[], playerRecoveryFrames[], playerState[] (via ApplyDamage)
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
          rem Issue #1148: Skip ranged attackers (handled by missile system)
          let temp1 = playerAttackType_R[attackerID]
          rem Cache hitbox for this attacker (calculated once, used for
          if temp1 = RangedAttack then return
          rem all
          rem   defenders)
          gosub CalculateAttackHitbox
          rem Hitbox values are already written into cachedHitbox*_W via aliasing

          rem Attack each defender
          for defenderID = 0 to 3
              rem Skip if defender is attacker
          if defenderID = attackerID then NextDefender

              rem Skip if defender is dead

          if playerHealth[defenderID] <= 0 then NextDefender

          rem Check if attack hits (uses cached hitbox)
          gosub CheckAttackHit
          if hit then gosub ApplyDamage

NextDefender
          next
          return thisbank        
ProcessAllAttacks
          asm
ProcessAllAttacks
end
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
              rem Skip if attacker is dead
          if playerHealth[attackerID] <= 0 then NextAttacker

          rem Issue #1147: Only evaluate live attacks (windup-through-recovery window)
          let temp1 = playerState[attackerID] & MaskPlayerStateAnimation
          if temp1 < ActionAttackWindupShifted then NextAttacker
          if temp1 > ActionAttackRecoveryShifted then NextAttacker

          gosub ProcessAttackerAttacks

NextAttacker
          rem Helper: End of attacker loop iteration (label only)
          next
          return otherbank
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
          rem Damage indicator system (handled inline)
          return otherbank
PlayDamageSound
          rem Damage sound effect handler
          rem
          rem Input: SoundAttackHit (global constant) = sound effect ID
          rem
          rem Output: Sound effect played (if implemented)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Damage indicators handled inline in damage calculation
          rem Visual feedback now handled inline in damage calculation
          rem
          rem Input: SoundAttackHit (global constant) = sound effect ID
          rem
          rem Output: Sound effect played
          rem
          rem Mutates: temp1 (set to sound ID)
          rem
          rem Called Routines: PlaySoundEffect (bank15) - plays sound
          rem effect
          rem Constraints: None
          let temp1 = SoundAttackHit
          gosub PlaySoundEffect bank15
          return otherbank
