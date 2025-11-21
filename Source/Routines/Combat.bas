          rem ChaosFight - Source/Routines/Combat.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem COMBAT SYSTEM - Generic Subroutines Using Player Arrays
ApplyDamage
          asm
ApplyDamage

end
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
          rem        playerHealth[] (global array) = player health values
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
          rem Called Routines: GetCharacterDamage (bank12) - obtains base
          rem   damage per character, SetPlayerAnimation (bank11) - sets
          rem   hurt animation, CheckPlayerElimination - handles player
          rem   elimination, PlayDamageSound - plays damage sound effect
          rem
          rem Constraints: Must be colocated with PlayerDies,
          rem PlayDamageSound (called via goto)

          let temp1 = playerCharacter[attackerID]
          rem GetCharacterDamage inlined - weight-based damage calculation
          let temp3 = CharacterWeights[temp1]
          if temp3 <= 15 then temp2 = 12 : goto AttackerDamageDone
          if temp3 <= 25 then temp2 = 18 : goto AttackerDamageDone
          let temp2 = 22
AttackerDamageDone
          let temp4 = temp2
          let temp1 = playerCharacter[defenderID]
          rem GetCharacterDamage inlined - weight-based damage calculation
          let temp3 = CharacterWeights[temp1]
          if temp3 <= 15 then temp2 = 12 : goto DefenderDamageDone
          if temp3 <= 25 then temp2 = 18 : goto DefenderDamageDone
          let temp2 = 22
DefenderDamageDone
          let temp1 = temp4 - temp2
          rem Calculate damage (considering defender state)
          rem Minimum damage
          if temp1 < 1 then temp1 = 1

          let temp2 = playerHealth[defenderID]
          rem Check if player will die from this damage
          let temp3 = 0
          rem Will die
          if temp2 < temp1 then temp3 = 1

          rem If player will die, instantly vanish (eliminate)

          if temp3 then goto PlayerDies

          let playerHealth[defenderID] = temp2 - temp1
          rem Player survives - apply damage and enter hurt state

          let currentPlayer = defenderID
          rem Set hurt animation (ActionHit = 5)
          let temp2 = ActionHit
          gosub SetPlayerAnimation bank11

          let temp4 = temp1 / 2
          rem Calculate recovery frames (damage / 2, clamped 10-30)
          if temp4 < 10 then temp4 = 10
          if temp4 > 30 then temp4 = 30
          let playerRecoveryFrames[defenderID] = temp4

          rem Set playerState bit 3 (recovery flag) when recovery frames
          let playerState[defenderID] = playerState[defenderID] | 8
          rem   are set

          rem Sound effect
          goto PlayDamageSound
          rem tail call


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
          let currentPlayer = defenderID
          rem   elimination effects
          gosub CheckPlayerElimination bank14

          rem Sound effect
          goto PlayDamageSound
          rem tail call


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
          if playerX[defenderID] + PlayerSpriteWidth <= cachedHitboxLeft_R then NoHit
          rem Defender right edge <= hitbox left edge (no overlap)
          if playerX[defenderID] >= cachedHitboxRight_R then NoHit
          rem Defender left edge >= hitbox right edge (no overlap)
          if playerY[defenderID] + PlayerSpriteHeight <= cachedHitboxTop_R then NoHit
          rem Defender bottom edge <= hitbox top edge (no overlap)
          if playerY[defenderID] >= cachedHitboxBottom_R then NoHit
          rem Defender top edge >= hitbox bottom edge (no overlap)

          let hit = 1
          rem All bounds checked - defender is inside hitbox
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
          rem Constraints: Must be colocated with CheckAttackHit
          let hit = 0
          return

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
          rem              FacingRight, FacingLeft, FacingUp, FacingDown
          rem              (all called via on/goto)
          rem Set hitbox based on attack type and direction
          rem Use temporary variable to avoid compiler bug with array
          rem indexing
          rem in on statement
          let temp1 = playerAttackType_R[attackerID]
          if temp1 = 0 then goto MeleeHitbox
          if temp1 = 1 then goto ProjectileHitbox
          if temp1 = 2 then goto AreaHitbox

MeleeHitbox
          rem Melee hitbox extends PlayerSpriteWidth pixels in facing
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
          rem FacingRight, FacingLeft, FacingUp, FacingDown
          rem Extract facing from playerState bit 3: 1=right (goto FacingRight), 0=left (goto FacingLeft)
          rem FacingUp and FacingDown are unreachable (no up/down facing in game)
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
          let cachedHitboxLeft_W = playerX[attackerID] + PlayerSpriteWidth
          rem Hitbox: [playerX+16, playerX+32] x [playerY, playerY+16]
          let cachedHitboxRight_W = playerX[attackerID] + PlayerSpriteWidth + PlayerSpriteWidth
          let cachedHitboxTop_W = playerY[attackerID]
          let cachedHitboxBottom_W = playerY[attackerID] + PlayerSpriteHeight
          return

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
          let cachedHitboxLeft_W = playerX[attackerID] - PlayerSpriteWidth
          rem Hitbox: [playerX-16, playerX] x [playerY, playerY+16]
          let cachedHitboxRight_W = playerX[attackerID]
          let cachedHitboxTop_W = playerY[attackerID]
          let cachedHitboxBottom_W = playerY[attackerID] + PlayerSpriteHeight
          return

FacingUp
          rem Hitbox extends 16 pixels upward from sprite top edge
          rem
          rem Input: attackerID, playerX[], playerY[] (from
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
          let cachedHitboxLeft_W = playerX[attackerID]
          rem Hitbox: [playerX, playerX+16] x [playerY-16, playerY]
          let cachedHitboxRight_W = playerX[attackerID] + PlayerSpriteWidth
          let cachedHitboxTop_W = playerY[attackerID] - PlayerSpriteHeight
          let cachedHitboxBottom_W = playerY[attackerID]
          return

FacingDown
          rem Hitbox extends 16 pixels downward from sprite bottom edge
          rem
          rem Input: attackerID, playerX[], playerY[] (from
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
          let cachedHitboxLeft_W = playerX[attackerID]
          rem Hitbox: [playerX, playerX+16] x [playerY+16, playerY+32]
          let cachedHitboxRight_W = playerX[attackerID] + PlayerSpriteWidth
          let cachedHitboxTop_W = playerY[attackerID] + PlayerSpriteHeight
          let cachedHitboxBottom_W = playerY[attackerID] + PlayerSpriteHeight + PlayerSpriteHeight
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
          rem Constraints: Must be colocated with CalculateAttackHitbox
          let cachedHitboxLeft_W = 0
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
          rem Constraints: Must be colocated with CalculateAttackHitbox
          let cachedHitboxLeft_W = 0
          let cachedHitboxRight_W = 0
          let cachedHitboxTop_W = 0
          let cachedHitboxBottom_W = 0
          return

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
          rem Cache hitbox for this attacker (calculated once, used for
          rem all
          gosub CalculateAttackHitbox
          rem   defenders)
          rem Hitbox values are already written into cachedHitbox*_W via aliasing

          for defenderID = 0 to 3
          rem Attack each defender
              rem Skip if defender is attacker
          if defenderID = attackerID then NextDefender

              rem Skip if defender is dead

          if playerHealth[defenderID] <= 0 then NextDefender

          gosub CheckAttackHit
          rem Check if attack hits (uses cached hitbox)
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

          let temp1 = playerState[attackerID] & MaskPlayerStateAnimation
          rem Issue #1147: Only evaluate live attacks (windup-through-recovery window)
          if temp1 < ActionAttackWindupShifted then NextAttacker
          if temp1 > ActionAttackRecoveryShifted then NextAttacker

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
          rem Damage indicator system (handled inline)
          return
PlayDamageSound
          rem Damage sound effect handler (no-op placeholder)
          rem
          rem Input: None
          rem
          rem Output: None (no-op)
          rem
          rem Mutates: None
          rem
          rem Called Routines: None
          rem
          rem Constraints: Damage indicators handled inline in damage calculation
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
          rem Constraints: None
          let temp1 = SoundAttackHit
          gosub PlaySoundEffect bank15
          return

