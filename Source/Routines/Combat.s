;;; ChaosFight - Source/Routines/Combat.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; COMBAT SYSTEM - Generic Subroutines Using Player Arrays

GetWeightBasedDamage .proc
          ;; Calculate damage value based on character weight
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Issue #1149: Deduplicated weight-tier calculation
          ;;
          ;; Input: temp1 = character index (0-31)
          ;; CharacterWeights[] (global data table) = character weights
          ;;
          ;; Output: temp2 = damage value (12, 18, or 22)
          ;;
          ;; Mutates: temp3 (used for weight lookup), temp2 (return thisbank value)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with ApplyDamage
          ;; Weight tiers: <=15 = 12 damage, <=25 = 18 damage, >25 = 22 damage
          ;; Set temp3 = CharacterWeights[temp1]
          lda temp1
          asl
          tax
          lda CharacterWeights,x
          sta temp3
          jmp BS_return

          lda # 22
          sta temp2
          jmp BS_return

.pend

ApplyDamage .proc
          ;; Apply damage from attacker to defender
          ;; Returns: Near (return thisbank) - called same-bank
          ;;
          ;; Process:
          ;; 1. Player begins hurt animation (ActionHit = 5)
          ;; 2. Player enters recovery frames count and color dims (or
          ;; magenta on SECAM)
          ;; 3. If player health >= damage amount, decrement health
          ;; 4. If player health < damage amount, player dies
          ;; (instantly vanishes)
          ;;
          ;; Input: attackerID (global) = attacker player index
          ;; defenderID (global) = defender player index
          ;; playerHealth[] (global array) = player health values
          ;; ActionHit (constant) = hurt animation action
          ;;
          ;; Output: playerHealth[] reduced, playerRecoveryFrames[]
          ;; set, playerState[] updated,
          ;; animation set to hurt, sound effect played, or
          ;; player eliminated
          ;;
          ;; Mutates: temp1-temp4 (used for calculations),
          ;; playerHealth[] (reduced or set to 0),
          ;; playerRecoveryFrames[] (set), playerState[]
          ;; (recovery flag set),
          ;; currentPlayer (set to defenderID), temp2 (passed
          ;; to SetPlayerAnimation)
          ;;
          ;; Called Routines: GetWeightBasedDamage (colocated) - obtains base
          ;; damage per character, SetPlayerAnimation (bank12) - sets
          ;; hurt animation, CheckPlayerElimination - handles player
          ;; elimination, PlayDamageSound - plays damage sound effect
          ;;
          ;; Constraints: Must be colocated with PlayerDies,
          ;; PlayDamageSound, GetWeightBasedDamage (called via goto/gosub)

          ;; Issue #1149: Use shared helper instead of duplicated logic
          ;; Set temp1 = playerCharacter[attackerID]
          lda attackerID
          asl
          tax
          lda playerCharacter,x
          sta temp1
          jsr GetWeightBasedDamage

          lda temp2
          sta temp4
          ;; Set temp1 = playerCharacter[defenderID]
          lda defenderID
          asl
          tax
          lda playerCharacter,x
          sta temp1
          ;; Calculate damage (considering defender sta

          jsr GetWeightBasedDamage

          ;; Minimum damage
          ;; Set temp1 = temp4 - temp2
          lda temp4
          sec
          sbc temp2
          sta temp1

          ;; If temp1 < 1, set temp1 = 1
          lda temp1
          cmp # 1
          bcs CheckPlayerWillDie

          lda # 1
          sta temp1

CheckPlayerWillDie:

          ;; Check if player will die from this damage
          ;; Set temp2 = playerHealth[defenderID]
          lda defenderID
          asl
          tax
          lda playerHealth,x
          sta temp2
          ;; Will die
          lda # 0
          sta temp3
          ;; If temp2 < temp1, set temp3 = 1
          lda temp2
          cmp temp1
          bcs CheckPlayerDies
          lda # 1
          sta temp3
CheckPlayerDies:
          ;; If player will die, instantly vanish (eliminate)
          ;; If temp3, then jmp PlayerDies
          lda temp3
          beq ApplyDamageToPlayer

          jmp PlayerDies

ApplyDamageToPlayer:

          ;; Player survives - apply damage and enter hurt sta
          ;; Set playerHealth[defenderID] = temp2 - temp1
          lda defenderID
          asl
          tax
          lda temp2
          sec
          sbc temp1
          sta playerHealth,x

          ;; Set hurt animation (ActionHit = 5)
          lda defenderID
          sta currentPlayer
          lda # ActionHit
          sta temp2
          ;; Cross-bank call to SetPlayerAnimation in bank 12
          lda # >(AfterSetPlayerAnimation-1)
          pha
          lda # <(AfterSetPlayerAnimation-1)
          pha
          lda # >(SetPlayerAnimation-1)
          pha
          lda # <(SetPlayerAnimation-1)
          pha
          ldx # 11
          jmp BS_jsr

AfterSetPlayerAnimation:

          ;; Calculate recovery frames (damage / 2, clamped 10-30)
          ;; Set temp4 = temp1 / 2
          lda temp1
          lsr
          sta temp4

          ;; If temp4 < 10, set temp4 = 10
          lda temp4
          cmp # 10
          bcs CheckMaximumRecovery

          lda # 10
          sta temp4

CheckMaximumRecovery:

          lda temp4
          cmp # 31
          bcc StoreRecoveryFrames

          lda # 30
          sta temp4

StoreRecoveryFrames:

          lda defenderID
          asl
          tax
          lda temp4
          sta playerRecoveryFrames,x

          ;; Set playerState bit 3 (recovery flag) when recovery frames are set
          ;; Set playerState[defenderID] = playerState[defenderID] | 8
          lda defenderID
          asl
          tax
          lda playerState,x
          ora # 8
          sta playerState,x

          ;; Issue #1180: Ursulo uppercut knock-up scaling with target weight
          ;; Ursulo’s punches toss opponents upward with launch height proportional to target weight
          ;; Lighter characters travel higher than heavyweights
          ;; Set temp1 = playerCharacter[attackerID]
          lda attackerID
          asl
          tax
          lda playerCharacter,x
          sta temp1
          lda temp1
          cmp CharacterUrsulo
          bne PlayDamageSound
          jmp ApplyUrsuloKnockUp
PlayDamageSound:


          ;; Sound effect (tail call)
          jmp PlayDamageSound

.pend

ApplyUrsuloKnockUp .proc
          ;; Issue #1180: Apply vertical knockback based on target weight
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Lighter characters get launched higher (inverse relationship: lower weight = higher launch)
          ;;
          ;; Input: defenderID (global) = defender player index
          ;; CharacterWeights[] (global data table) = character weights
          ;; playerVelocityY[], playerVelocityYL[] (global arrays) = vertical velocity
          ;;
          ;; Output: playerVelocityY[] set to upward velocity (negative value)
          ;; Launch height inversely proportional to target weight
          ;;
          ;; Mutates: temp1-temp4 (used for weight lookup and velocity calculation)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with ApplyDamage
          ;; Get defender’s weight
          ;; Weight values range 5-100 (lightest to heaviest)
          ;; Set temp1 = playerCharacter[defenderID]
          lda defenderID
          asl
          tax
          lda playerCharacter,x
          sta temp1
          ;; Calculate upward velocity: lighter = higher launch (inverse relationship)
          ;; Formula: launch_velocity = max_launch - (weight / weight_scale_factor)
          ;; Max launch: 12 pixels/frame upward (244 in signed 8-bit = -12) for lightest
          ;; Min launch: 4 pixels/frame (252 in signed 8-bit = -4) for heaviest
          ;; Weight scale: divide weight by 12 to get velocity reduction (0-8 range)
          ;; Use precomputed lookup table (avoids expensive division on Atari 2600)
          ;; Values already clamped to 0-8 range in lookup table
          ;; Set temp3 = CharacterWeightDiv12[temp1]
          lda temp1
          asl
          tax
          lda CharacterWeightDiv12,x
          sta temp3
          ;; Calculate upward velocity: max_launch - reduction
          ;; 244 = -12 (highest), 245 = -11, ..., 252 = -4 (lowest)
          ;; Clamp to valid range (244-252)
          ;; Set temp4 = 244 + temp3
          ;; Apply upward velocity to defender (negative value = upward)
          lda temp4
          cmp # 253
          bcc ApplyUpwardVelocity
          lda # 252
          sta temp4
ApplyUpwardVelocity:

          lda defenderID
          asl
          tax
          lda temp4
          sta playerVelocityY,x
          ;; Set jumping flag so gravity applies correctly and animation system handles airborne sta

          lda defenderID
          asl
          tax
          lda # 0
          sta playerVelocityYL,x
          ;; Set playerState[defenderID] = playerState[defenderID] | PlayerStateBitJumping
          lda defenderID
          asl
          tax
          lda playerState,x
          ora # PlayerStateBitJumping
          sta playerState,x

          ;; Sound effect (tail call)
          jmp PlayDamageSound

.pend

PlayerDies .proc
          ;; Player dies - instantly vanish
          ;; Returns: Near (return thisbank) - called same-bank
          ;;
          ;; Input: defenderID (from ApplyDamage) = defender player
          ;; index
          ;; playerHealth[] (global array) = player health
          ;; values
          ;;
          ;; Output: playerHealth[] set to 0, player eliminated, sound
          ;; effect played
          ;;
          ;; Mutates: playerHealth[] (set to 0), currentPlayer (set to
          ;; defenderID)
          ;;
          ;; Called Routines: CheckPlayerElimination - handles player
          ;; elimination,
          ;; PlayDamageSound - plays damage sound effect
          ;; Constraints: Must be colocated with ApplyDamage, PlayDamageSound
          lda defenderID
          asl
          tax
          lda # 0
          sta playerHealth,x

          ;; Trigger elimination immediately (instantly vanish)
          ;; CheckPlayerElimination will hide sprite and handle
          ;; elimination effects
          lda defenderID
          sta currentPlayer
          ;; Cross-bank call to CheckPlayerElimination in bank 14
          lda # >(AfterCheckPlayerElimination-1)
          pha
          lda # <(AfterCheckPlayerElimination-1)
          pha
          lda # >(CheckPlayerElimination-1)
          pha
          lda # <(CheckPlayerElimination-1)
          pha
                    ldx # 13
          jmp BS_jsr
AfterCheckPlayerElimination:


          ;; Sound effect
          ;; tail call
          jmp PlayDamageSound

.pend

CheckAttackHit .proc
          ;; Check if attack hits defender
          ;; Inputs: attackerID, defenderID (must be set before
          ;; calling)
          ;;
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Uses cached hitbox values from ProcessAttackerAttacks
          ;; (cached once per attacker, reused for all defenders)
          ;; Check if attack hits defender using AABB collision
          ;; detection
          ;;
          ;; Input: defenderID (global) = defender player index
          ;; playerX[], playerY[] (global arrays) = player
          ;; positions
          ;; cachedHitboxLeft_R, cachedHitboxRight_R,
          ;; cachedHitboxTop_R, cachedHitboxBottom_R (global
          ;; SCRAM) = cached hitbox bounds
          ;; PlayerSpriteWidth, PlayerSpriteHeight (constants) =
          ;; sprite dimensions
          ;;
          ;; Output: hit (global) = 1 if hit, 0 if miss
          ;;
          ;; Mutates: hit (set to 1 or 0)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with NoHit (called via
          ;; goto)
          ;; Uses cached hitbox values (set in ProcessAttackerAttacks)
          ;; Use cached hitbox values (set in ProcessAttackerAttacks)
          ;; Check if defender bounding box overlaps hitbox (AABB
          ;; collision detection)
          ;; playerX/playerY represent sprite top-left corner, sprite
          ;; is 16×16 pixels
          ;; Defender bounding box: [playerX, playerX+16] × [playerY,
          ;; playerY+16]
          ;; Hitbox: [cachedHitboxLeft, cachedHitboxRight] x
          ;; [cachedHitboxTop,
          ;; cachedHitboxBottom]
          ;; Overlap occurs when: defender_right > cachedHitboxLeft_R and
          ;; defender_left < cachedHitboxRight_R
          and defender_bottom > hitboxTop and defender_top <
          ;; hitboxBottom
          ;; Defender right edge <= hitbox left edge (no overlap)
          ;; If playerX[defenderID] + PlayerSpriteWidth <= cachedHitboxLeft_R, then NoHit
          lda defenderID
          asl
          tax
          lda playerX,x
          clc
          adc # PlayerSpriteWidth
          cmp cachedHitboxLeft_R
          bcc NoHit
          beq NoHit

          ;; Defender left edge >= hitbox right edge (no overlap)
                    if playerX[defenderID] >= cachedHitboxRight_R then NoHit
          lda defenderID
          asl
          tax
          lda playerX,x
          sec
          sbc cachedHitboxRight_R
          bcc CheckVerticalOverlap
          jmp NoHit
CheckVerticalOverlap:

          ;; Defender bottom edge <= hitbox top edge (no overlap)
                    if playerY[defenderID] + PlayerSpriteHeight <= cachedHitboxTop_R then NoHit
          lda defenderID
          asl
          tax
          lda playerY,x
          clc
          adc PlayerSpriteHeight
          sta temp6
          lda temp6
          sec
          sbc cachedHitboxTop_R
          bcc NoHit
          beq NoHit
          jmp CheckBottomOverlap
NoHit:
CheckBottomOverlap:

          ;; Defender top edge >= hitbox bottom edge (no overlap)
                    if playerY[defenderID] >= cachedHitboxBottom_R then NoHit
          lda defenderID
          asl
          tax
          lda playerY,x
          sec
          sbc cachedHitboxBottom_R
          bcc HitDetected
          jmp NoHit
HitDetected:

          ;; All bounds checked - defender is inside hitbox
          lda # 1
          sta hit
          rts

.pend

NoHit .proc
          ;; Defender is outside hitbox bounds
          ;; Returns: Near (return thisbank) - called same-bank
          ;;
          ;; Input: None (called from CheckAttackHit)
          ;;
          ;; Output: hit set to 0
          ;;
          ;; Mutates: hit (set to 0)
          ;;
          ;; Called Routines: None
          ;; Constraints: Must be colocated with CheckAttackHit
          lda # 0
          sta hit
          rts
.pend

CalculateAttackHitbox .proc

          ;; Compute attack hitbox bounds from attacker position and facing.
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Inputs: attackerID (global), playerX[], playerY[], playerAttackType_R[],
          ;; playerState[] (for facing direction), PlayerSpriteWidth, PlayerSpriteHeight
          ;; Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          ;; cachedHitboxBottom_W (global hitbox bounds)
          ;; Mutates: temp1, temp2, cachedHitboxLeft_W, cachedHitboxRight_W,
          ;; cachedHitboxTop_W, cachedHitboxBottom_W
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with MeleeHitbox,
          ;; ProjectileHitbox, AreaHitbox,
          ;; FacingRight, FacingLeft (all called via goto)
          ;; Set hitbox based on attack type and direction
          ;; Use temporary variable to avoid compiler bug with array
          ;; indexing
          ;; in on sta

          ;; Set temp1 = playerAttackType_R[attackerID]
          lda attackerID
          asl
          tax
          lda playerAttackType_R,x
          sta temp1
          cmp # 0
          bne CheckProjectileHitbox
          jmp MeleeHitbox
CheckProjectileHitbox:


          lda temp1
          cmp # 1
          bne CheckAreaHitbox
          jmp ProjectileHitbox
CheckAreaHitbox:


          lda temp1
          cmp # 2
          bne CalculateAttackHitboxDone
          jmp AreaHitbox
CalculateAttackHitboxDone:


.pend

MeleeHitbox .proc
          ;; Mêlée hitbox extends PlayerSpriteWidth pixels in facing
          ;; Returns: Near (return thisbank) - called same-bank
          ;; direction
          ;;
          ;; Input: attackerID, playerState[] (from
          ;; CalculateAttackHitbox)
          ;;
          ;; Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          ;; set based on facing direction
          ;;
          ;; Mutates: temp2 (facing direction), cachedHitboxLeft_W,
          ;; cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with CalculateAttackHitbox,
          ;; FacingRight, FacingLeft
          ;; Extract facing from playerState bit 3: 1=right (jmp FacingRight), 0=left (jmp FacingLeft)
          ;; Set temp2 = playerState[attackerID] & PlayerStateBitFacing
          lda attackerID
          asl
          tax
          lda playerState,x
          sta temp2
          ;; if temp2 then jmp FacingRight
          lda temp2
          beq FacingLeft
          jmp FacingRight
FacingLeft:

          jmp FacingLeft

.pend

FacingRight .proc
          ;; Hitbox extends 16 pixels forward from sprite right edge
          ;; Returns: Near (return thisbank) - called same-bank
          ;;
          ;; Input: attackerID, playerX[], playerY[] (from
          ;; MeleeHitbox)
          ;;
          ;; Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          ;; set for right-facing attack
          ;;
          ;; Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with CalculateAttackHitbox,
          ;; MeleeHitbox
          ;; Attacker sprite: [playerX, playerX+16] × [playerY,
          ;; playerY+16]
          ;; Hitbox: [playerX+16, playerX+32] × [playerY, playerY+16]
                    let cachedHitboxLeft_W = playerX[attackerID] + PlayerSpriteWidth          lda attackerID          asl          tax          lda playerX,x          sta cachedHitboxLeft_W
          ;; Set cachedHitboxRight_W = playerX[attackerID] + PlayerSpriteWidth + PlayerSpriteWidth
          lda attackerID
          asl
          tax
          lda playerX,x
          sta cachedHitboxRight_W
          ;; Set cachedHitboxTop_W = playerY[attackerID]
          lda attackerID
          asl
          tax
          lda playerY,x
          sta cachedHitboxTop_W
          ;; Set cachedHitboxBottom_W = playerY[attackerID]
          lda attackerID
          asl
          tax
          lda playerY,x
          sta cachedHitboxBottom_W + PlayerSpriteHeight
          lda attackerID
          asl
          tax
          lda playerY,x
          sta cachedHitboxBottom_W
          rts

.pend

FacingLeft .proc
          ;; Hitbox extends 16 pixels forward from sprite left edge
          ;; Returns: Near (return thisbank) - called same-bank
          ;;
          ;; Input: attackerID, playerX[], playerY[] (from
          ;; MeleeHitbox)
          ;;
          ;; Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          ;; set for left-facing attack
          ;;
          ;; Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with CalculateAttackHitbox,
          ;; MeleeHitbox
          ;; Attacker sprite: [playerX, playerX+16] × [playerY,
          ;; playerY+16]
          ;; Hitbox: [playerX-16, playerX] × [playerY, playerY+16]
                    let cachedHitboxLeft_W = playerX[attackerID] - PlayerSpriteWidth          lda attackerID          asl          tax          lda playerX,x          sta cachedHitboxLeft_W
          ;; Set cachedHitboxRight_W = playerX[attackerID]
          lda attackerID
          asl
          tax
          lda playerX,x
          sta cachedHitboxRight_W
          ;; Set cachedHitboxTop_W = playerY[attackerID]
          lda attackerID
          asl
          tax
          lda playerY,x
          sta cachedHitboxTop_W
          ;; Set cachedHitboxBottom_W = playerY[attackerID]
          lda attackerID
          asl
          tax
          lda playerY,x
          sta cachedHitboxBottom_W + PlayerSpriteHeight
          lda attackerID
          asl
          tax
          lda playerY,x
          sta cachedHitboxBottom_W
          jmp BS_return

.pend

ProjectileHitbox .proc
          ;; Projectile attacks handled by missile collision system
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Issue #1148: Skip projectile hitbox calculation since missiles
          ;; handle their own collisions via MissileCollision routines
          ;;
          ;; Input: attackerID (from CalculateAttackHitbox)
          ;;
          ;; Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          ;; cachedHitboxBottom_W set to invalid bounds (will never match)
          ;;
          ;; Mutates: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          ;; cachedHitboxBottom_W (set to invalid values)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with CalculateAttackHitbox
          ;; Set invalid bounds that will never match any defender
          ;; (ensures CheckAttackHit always returns miss for projectiles)
          lda # 255
          sta cachedHitboxLeft_W
          lda # 0
          sta cachedHitboxRight_W
          lda # 255
          sta cachedHitboxTop_W
          lda # 0
          sta cachedHitboxBottom_W
          jmp BS_return

.pend

AreaHitbox .proc
          ;; Area hitbox covers radius around attacker center
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Issue #1148: Implement radius-based area-of-effect hitbox
          ;;
          ;; Input: attackerID (from CalculateAttackHitbox), playerX[],
          ;; playerY[] (global arrays) = attacker position
          ;;
          ;; Output: cachedHitboxLeft_W, cachedHitboxRight_W, cachedHitboxTop_W,
          ;; cachedHitboxBottom_W set to area bounds (24px radius from center)
          ;;
          ;; Mutates: temp2 (used for center calculation), cachedHitboxLeft_W,
          ;; cachedHitboxRight_W, cachedHitboxTop_W, cachedHitboxBottom_W
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with CalculateAttackHitbox
          ;; Area radius: 24 pixels (1.5× sprite width) centered on attacker
          ;; Calculate attacker center (sprite midpoint)
          ;; Center × = playerX + half sprite width
          ;; Set temp2 = playerX[attackerID] + 8
          lda attackerID
          asl
          tax
          lda playerX,x
          sta temp2
          ;; Left edge: center - radius
          ;; Set cachedHitboxLeft_W = temp2 - 24          lda temp2          sec          sbc # 24          sta cachedHitboxLeft_W
          lda temp2
          sec
          sbc # 24
          sta cachedHitboxLeft_W

          lda temp2
          sec
          sbc # 24
          sta cachedHitboxLeft_W

          ;; Right edge: center + radius
          lda temp2
          clc
          adc # 24
          sta cachedHitboxRight_W
          ;; Center Y = playerY + half sprite height
          ;; Set temp2 = playerY[attackerID] + 8
          lda attackerID
          asl
          tax
          lda playerY,x
          sta temp2
          ;; Top edge: center - radius
          ;; Set cachedHitboxTop_W = temp2 - 24          lda temp2          sec          sbc # 24          sta cachedHitboxTop_W
          lda temp2
          sec
          sbc # 24
          sta cachedHitboxTop_W

          lda temp2
          sec
          sbc # 24
          sta cachedHitboxTop_W

          ;; Bottom edge: center + radius
          lda temp2
          clc
          adc # 24
          sta cachedHitboxBottom_W
          jmp BS_return

.pend

ProcessAttackerAttacks .proc
          ;; Process attacks for one attacker against all defenders.
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Input: attackerID (must be set before calling); facing handled by
          ;; CalculateAttackHitbox which caches bounds once per attacker.
          ;;
          ;; Input: attackerID (global) = attacker player index,
          ;; playerX[], playerY[] (global arrays) = player positions,
          ;; playerAttackType_R[], playerState[] (global arrays) =
          ;; attack type and facing, playerHealth[] (global array) =
          ;; player health values
          ;;
          ;; Output: Attacks processed for all defenders, damage
          ;; applied if hits detected
          ;;
          ;; Mutates: temp1-temp2, cachedHitboxLeft_W/cachedHitboxRight_W/
          ;; cachedHitboxTop_W/cachedHitboxBottom_W (cached bounds),
          ;; defenderID (0-3), hit (CheckAttackHit result),
          ;; playerHealth[], playerRecoveryFrames[], playerState[] (via ApplyDamage)
          ;;
          ;; Called Routines: CalculateAttackHitbox - calculates hitbox
          ;; based on attacker position and facing, CheckAttackHit -
          ;; checks if attack hits defender, ApplyDamage - applies
          ;; damage if hit
          ;;
          ;; Constraints: Must be colocated with NextDefender (called
          ;; via next). Caches hitbox once per attacker to avoid
          ;; recalculating for each defender. Skips attacker as
          ;; defender and dead players
          ;; Issue #1148: Skip ranged attackers (handled by missile system)
          ;; Set temp1 = playerAttackType_R[attackerID]
          lda attackerID
          asl
          tax
          lda playerAttackType_R,x
          sta temp1
          ;; Cache hitbox for this attacker (calculated once, used for
          rts

          ;; all
          ;; defenders)
          jsr CalculateAttackHitbox

          ;; Hitbox values are already written into cachedHitbox*_W via aliasing

          ;; Attack each defender
          ;; TODO: #1310 for defenderID = 0 to 3
          ;; Skip if defender is attacker
          lda defenderID
          cmp attackerID
          bne CheckDefenderHealth
          ;; TODO: #1310 NextDefender
CheckDefenderHealth:


          ;; Skip if defender is dead

          ;; If playerHealth[defenderID] <= 0, then NextDefender
          lda defenderID
          asl
          tax
          lda playerHealth,x
          beq CheckAttackHitDefender
          bmi CheckAttackHitDefender
          jmp NextDefender
CheckAttackHitDefender:

          lda defenderID
          asl
          tax
          lda playerHealth,x
          beq ProcessAttackHit
          bmi ProcessAttackHit
          jmp NextDefender
ProcessAttackHit:



          ;; Check if attack hits (uses cached hitbox)
          jsr CheckAttackHit

          jsr ApplyDamage

NextDefender
          ;; Returns: Near (return thisbank) - called same-bank
.pend

ProcessAllAttacksDone .proc
          jmp BS_return

.pend

ProcessAllAttacks .proc
          ;; Process all attacks for all players
          ;; Returns: Far (return otherbank) - called cross-bank from VblankHandlers
          ;; Process all attacks for all players (orchestrates attack
          ;; processing for all active players)
          ;;
          ;; Input: attackerID (global) = attacker index (set to 0-3),
          ;; playerHealth[] (global array) = player health values
          ;;
          ;; Output: All attacks processed for all active players
          ;;
          ;; Mutates: attackerID (global) = attacker index (set to
          ;; 0-3), all attack processing state (via
          ;; ProcessAttackerAttacks)
          ;;
          ;; Called Routines: ProcessAttackerAttacks - processes
          ;; attacks for one attacker against all defenders
          ;;
          ;; Constraints: Must be colocated with NextAttacker (called
          ;; via next). Skips dead attackers
          ;; TODO: #1310 for attackerID = 0 to 3
          ;; Skip if attacker is dead
          ;; If playerHealth[attackerID] <= 0, then NextAttacker
          lda attackerID
          asl
          tax
          lda playerHealth,x
          beq CheckAttackState
          bmi CheckAttackState
          jmp NextAttacker
CheckAttackState:

          lda attackerID
          asl
          tax
          lda playerHealth,x
          beq CheckAttackWindow
          bmi CheckAttackWindow
          jmp NextAttacker
CheckAttackWindow:



          ;; Issue #1147: Only evaluate live attacks (windup-through-recovery window)
          ;; Set temp1 = playerState[attackerID] & MaskPlayerStateAnimation
          lda attackerID
          asl
          tax
          lda playerState,x
          sta temp1
                    if temp1 < ActionAttackWindupShifted then NextAttacker

                    if temp1 > ActionAttackRecoveryShifted then NextAttacker
          lda temp1
          sec
          sbc # ActionAttackRecoveryShifted
          bcc ProcessAttackerAttacksLabel
          beq ProcessAttackerAttacksLabel
          jmp NextAttacker
ProcessAttackerAttacksLabel:
          jsr ProcessAttackerAttacks

.pend

NextAttacker .proc
          ;; Helper: End of attacker loop iteration (label only)
          ;; Returns: Near (return thisbank) - called same-bank
.pend

ProcessAllAttacksDone2 .proc
          jmp BS_return
          ;; Input: None (label only)
          ;;
          ;; Output: None (label only)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Internal label for ProcessAllAttacks FOR loop
.pend

;; CombatShowDamageIndicator .proc (no matching .pend)
          ;; Damage indicator system (handled inline)
          ;; Returns: Far (return otherbank)
          jmp BS_return

;; PlayDamageSound .proc (no matching .pend)
          ;; Damage sound effect handler
          ;; Returns: Far (return otherbank)
          ;;
          ;; Input: SoundAttackHit (global constant) = sound effect ID
          ;;
          ;; Output: Sound effect played (if implemented)
          ;;
          ;; Mutates: None
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Damage indicators handled inline in damage calculation
          ;; Visual feedback now handled inline in damage calculation
          ;;
          ;; Input: SoundAttackHit (global constant) = sound effect ID
          ;;
          ;; Output: Sound effect played
          ;;
          ;; Mutates: temp1 (set to sound ID)
          ;;
          ;; Called Routines: PlaySoundEffect (bank15) - plays sound
          ;; effect
          ;; Constraints: None
          lda SoundAttackHit
          sta temp1
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(AfterPlaySoundEffect-1)
          pha
          lda # <(AfterPlaySoundEffect-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterPlaySoundEffect:


          jmp BS_return

