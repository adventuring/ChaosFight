;;; ChaosFight - Source/Routines/MissileSystem.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; MISSILE SYSTEM - 4-player MISSILE MANAGEMENT
;;; Manages up to 4 simultaneous missiles/attack visuals (one
;;; per player).
          ;; Each player can have ONE active missile at a time, which
          ;; can be:


GetPlayerMissileBitFlag .proc
          ;; - Ranged projectile (bullet, arrow, magic spell)
          ;; Returns: Near (return thisbank) - called same-bank
          ;; - Mêlée attack visual (sword, fist, kick sprite)
          ;; MISSILE VARIABLES (from Variables.bas):
          ;; missileX[0-3] (a-d) - X positions
          ;; missileY[0-3] (SCRAM w097-w100) - Y positions
          ;; missileActive (i) - bit flags for which missiles are
          ;; active
          ;; missileLifetime (e,f) - Packed nybble counters
          ;; e{7:4} = Player 1 lifetime, e{3:0} = Player 2 lifetime
          ;; f{7:4} = Player 3 lifetime, f{3:0} = Player 4 lifetime
          ;; Values: 0-13 = frame count, 14 = until collision, 15 =
          ;; until off-screen
          ;; TEMP VARIABLE USAGE:
          ;; temp1 = player index (0-3) being processed
          ;; temp2 = missileX delta (momentum/velocity)
          ;; temp3 = missileY delta (momentum/velocity)
          ;; temp4 = scratch for collision checks / flags / target
          ;;
          ;; player
          ;; temp5 = scratch for character data lookups / missile flags
          ;; temp6 = scratch for bit manipulation / collision bounds
          ;; Get Player Missile bit Flag
          ;; Input: temp1 = player index (0-3)
          ;; Output: temp6 = bit flag (1, 2, 4, or 8)
          ;; Mutates: temp6 (return otherbank value)
          ;;
          ;; Called Routines: None
          ;; Constraints: None
          ;; Calculate bit flag using O(1) array lookup:
          ;; BitMask[playerIndex] (1, 2, 4, 8)
                    ;; let temp6 = BitMask[temp1]         
          lda temp1
          asl
          tax
          ;; lda BitMask,x (duplicate)
          sta temp6
          rts

.pend

SpawnMissile .proc

          ;;
          ;; Returns: Far (return otherbank)
          ;; Spawn Missile
          ;; Creates a new missile/attack visual for a player.
          ;; Called when player presses attack button.
          ;;
          ;; INPUT:
          ;; temp1 = player index (0-3)
          ;; PROCESS:
          ;; 1. Look up character type for this player
          ;; 2. Read missile properties from character data
          ;; 3. Set missile X/Y based on player position, facing, and
          ;; emission height
          ;; 4. Set active bit for this player missile
          ;; 5. Initialize lifetime counter from character data
          ;; Creates a new missile/attack visual for a player at spawn
          ;; position with initial velocity
          ;;
          ;; Input: temp1 = player index (0-3), playerCharacter[] (global
          ;; array) = character types, playerX[], playerY[] (global
          ;; arrays) = player positions, playerState[] (global array) =
          ;; player states (facing direction),
          ;; CharacterMissileEmissionHeights[],
          ;; CharacterMissileSpawnOffsetLeft[],
          ;; CharacterMissileSpawnOffsetRight[],
          ;; CharacterMissileLifetime[], CharacterMissileMomentumX[],
          ;; CharacterMissileMomentumY[], CharacterMissileWidths[]
          ;; (global data tables) = missile properties,
          ;; characterStateFlags_R[] (global SCRAM array) = character
          ;; state flags (for Harpy dive mode), CharacterMissileSpawnOffsetLeft[],
          ;; CharacterMissileSpawnOffsetRight[] = spawn
          ;; offsets, PlayerStateBitFacing (global constant) = facing
          ;; bit mask
          ;;
          ;; Output: Missile spawned at correct position with initial
          ;; velocity and lifetime
          ;;
          ;; Mutates: temp1-temp6 (used for calculations), missileX[],
          ;; missileY_W[] (global arrays) = missile positions,
          ;; missileActive (global) = missile active flags,
          ;; missileLifetime[] (global array) = missile lifetime
          ;; counters, missileVelocityX[], missileVelocityY[] (global
          ;; arrays) = missile velocities, missileNUSIZ[] (global
          ;; array) = missile size registers
          ;;
          ;; Called Routines: GetPlayerMissileBitFlag - calculates bit
          ;; flag for missile active tracking
          ;;
          ;; Constraints: Only one missile per player at a time. Harpy
          ;; dive mode increases downward velocity by 50%
          ;; Get character type for this player
                    ;; let temp5 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp5

          ;; Read missile emission height from character data table
                    ;; let temp6 = CharacterMissileEmissionHeights[temp5]
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileEmissionHeights,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileEmissionHeights,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; Calculate initial missile position based on player
          ;; position and facing
          ;; Facing is stored in playerState bit 0: 0=left, 1=right
          ;; Get facing direction
                    ;; let temp4 = playerState[temp1] & PlayerStateBitFacing         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; Set missile position using array access (write to _W port)
                    ;; let missileX[temp1] = playerX[temp1]
                    ;; let missileY_W[temp1] = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta missileY_W,x + temp6 (duplicate)
          ;; Facing left, spawn left
          ;; lda temp4 (duplicate)
          cmp # 0
          bne skip_8091
                    ;; let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetLeft[temp5]
skip_8091:

          ;; Facing right, spawn right
          ;; lda temp4 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_3827 (duplicate)
                    ;; let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetRight[temp5]
skip_3827:


          ;; Set active bit for this player missile
          ;; bit 0 = P1, bit 1 = P2, bit 2 = P3, bit 3 = P4
          ;; Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          jsr GetPlayerMissileBitFlag
          ;; lda missileActive (duplicate)
          ora temp6
          ;; sta missileActive (duplicate)

          ;; Initialize lifetime counter from character data table
                    ;; let missileLifetimeValue = CharacterMissileLifetime[temp5]          lda temp5          asl          tax          lda CharacterMissileLifetime,x          sta missileLifetimeValue

          ;; Store lifetime in player-specific variable
          ;; Using individual variables for each player missile
          ;; lifetime
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileLifetimeValue (duplicate)
          ;; sta missileLifetime_W,x (duplicate)

          ;; Cache missile flags at spawn to avoid per-frame lookups
          ;; Flags are immutable per character, so cache once at spawn
          ;; let temp2 = CharacterMissileFlags[temp5]
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileFlags,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; Store flags for use in UpdateOneMissile
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta missileFlags_W,x (duplicate)

          ;; Initialize velocity from character data for friction
          ;; physics
                    ;; let temp6 = CharacterMissileMomentumX[temp5]
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileMomentumX,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileMomentumX,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; Get base X velocity
          ;; lda temp4 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_35 (duplicate)
          ;; ;; let temp6 = 0 - temp6          lda 0          sec          sbc temp6          sta temp6
          ;; lda 0 (duplicate)
          sec
          sbc temp6
          ;; sta temp6 (duplicate)

          ;; lda 0 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp6 (duplicate)

skip_35:

          ;; Apply facing direction (left = negative)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta missileVelocityX,x (duplicate)

          ;; Optimized: Use precomputed NUSIZ table instead of arithmetic
          ;; NUSIZ values precomputed in CharacterMissileNUSIZ table
                    ;; let missileNUSIZ_W[temp1] = CharacterMissileNUSIZ[temp5]

          ;; Get Y velocity
                    ;; let temp6 = CharacterMissileMomentumY[temp5]         
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMissileMomentumY,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; Apply Harpy dive velocity bonus if in dive mode
          ;; Handler extracted to MissileCharacterHandlers.bas
          ;; lda temp5 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bne skip_7121 (duplicate)
          jmp HarpyCheckDiveVelocity
skip_7121:

          ;; VelocityDone label is in MissileCharacterHandlers.bas
          ;; jmp VelocityDone (duplicate)

          ;; jsr BS_return (duplicate)

.pend

UpdateAllMissiles .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Update All Missiles
          ;; Called once per frame to update all active missiles.
          ;; Updates position, checks collisions, handles lifetime.
          ;; Updates all active missiles (called once per frame)
          ;;
          ;; Input: None (processes all players 0-3)
          ;;
          ;; Output: All active missiles updated (position, velocity,
          ;; lifetime, collisions)
          ;;
          ;; Mutates: All missile state (via UpdateOneMissile for each
          ;; player)
          ;;
          ;; Called Routines: UpdateOneMissile (for each player 0-3)
          ;;
          ;; Constraints: None
          ;; Optimized: Loop through all player missiles instead of individual calls
          ;; TODO: for temp1 = 0 to 3
          ;; jsr UpdateOneMissile (duplicate)
.pend

next_label_1_L280:.proc
          ;; jsr BS_return (duplicate)

UpdateOneMissile
          ;; Returns: Near (return thisbank)
;; UpdateOneMissile (duplicate)
          ;;
          ;; Returns: Near (return thisbank)
          ;; Update One Missile
          ;; Updates a single player missile.
          ;; Handles movement, gravity, collisions, and lifetime.
          ;;
          ;; INPUT:
          ;; temp1 = player index (0-3)
          ;; Updates a single player missile (movement, gravity,
          ;; friction, collisions, lifetime)
          ;;
          ;; Input: temp1 = player index (0-3), missileActive (global)
          ;; = missile active flags, missileVelocityX[],
          ;; missileVelocityY[] (global arrays) = missile velocities,
          ;; missileX[], missileY_R[] (global arrays) = missile
          ;; positions, playerCharacter[] (global array) = character types,
          ;; playerState[] (global array) = player states, playerX[],
          ;; playerY[] (global arrays) = player positions, BitMask[]
          ;; (global data table) = bit masks, MissileFlagGravity,
          ;; MissileFlagFriction, MissileFlagHitBackground,
          ;; MissileFlagBounce (global constants) = missile flags,
          ;; GravityPerFrame, CurlingFrictionCoefficient,
          ;; MinimumVelocityThreshold (global constants) = physics
          ;; constants, ScreenBottom, ScreenTopWrapThreshold (global
          ;; constants) = screen bounds, MissileLifetimeInfinite,
          ;; MissileHitNotFound (global constants) = missile consta

          ;; CharacterMegax, CharacterKnightGuy (global constants) = character
          ;; indices, SoundGuardBlock (global constant) = sound effect
          ;; ID
          ;;
          ;; Output: Missile updated (position, velocity, lifetime),
          ;; collisions checked, missile deactivated if expired or
          ;; off-screen
          ;;
          ;; Mutates: temp1-temp6 (used for calculations), missileX[],
          ;; missileY_W[] (global arrays) = missile positions,
          ;; missileVelocityX[], missileVelocityY[] (global arrays) =
          ;; missile velocities, missileActive (global) = missile
          ;; active flags (via DeactivateMissile), missileLifetime[]
          ;; (global array) = missile lifetime counters, soundEffectID
          ;; (global) = sound effect ID (via guard bounce)
          ;;
          ;; Called Routines: GetPlayerMissileBitFlag - calculates bit
          ;; flag, CharacterMissileFlags[] (global table) - missile flags
          ;; cached at spawn, HandleMegaxMissile - handles Megax sta

          ;; missile, HandleKnightGuyMissile - handles Knight Guy sword swing,
          ;; MissileCollPF (bank8) - checks playfield collision,
          ;; CheckAllMissileCollisions (bank8) - checks player
          ;; collisions, PlaySoundEffect (bank15) - plays guard bounce
          ;; sound, HandleMissileBounce (same-bank) - handles bounce physics,
          ;; HandleMissileHit - handles damage application,
          ;; DeactivateMissile - deactivates missile
          ;;
          ;; Constraints: Special handling for Megax (stationary) and
          ;; Knight Guy (sword swing). Missiles wrap horizontally,
          ;; deactivate if off-screen vertically. Guard bounce reduces
          ;; velocity by 25%
          ;; Check if this missile is active
          ;; jsr GetPlayerMissileBitFlag (duplicate)
          ;; lda missileActive (duplicate)
          and temp6
          ;; sta temp4 (duplicate)
          ;; Not active, skip
          ;; rts (duplicate)

          ;; Preserve player index since GetMissileFlags uses temp1
          ;; Use temp6 temporarily to save player index (temp6 is used
          ;; for bit flags)
          ;; lda temp1 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Save player index temporarily

          ;; Get current velocities from stored arrays
                    ;; let temp2 = missileVelocityX[temp1]          lda temp1          asl          tax          lda missileVelocityX,x          sta temp2
          ;; X velocity (already facing-adjusted from spawn)
          ;; let temp3 = missileVelocityY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileVelocityY,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; Y velocity

          ;; Use cached missile flags (set at spawn) instead of lookup
          ;; This avoids two CharacterMissileFlags lookups per frame
          ;; Get cached flags (set at spawn time)
                    ;; let temp5 = missileFlags_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileFlags_R,x (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileFlags_R,x (duplicate)
          ;; sta temp5 (duplicate)

          ;; Restore player index
          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Issue #1188: Character handler dispatch - look up character ID for special handlers
          ;; Special handling for Megax (character 5): stationary fire breath visual
          ;; Megax missile stays adjacent to player during attack, no movement
          ;; Handler extracted to MissileCharacterHandlers.bas
          ;; Get character ID for handler dispatch
                    ;; let temp6 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; cmp CharacterMegax (duplicate)
          ;; bne skip_3745 (duplicate)
          ;; jmp HandleMegaxMissile (duplicate)
skip_3745:


          ;; Special handling for Knight Guy (character 7): sword swing visual
          ;; Knight Guy missile appears overlapping, moves away, returns, then vanishes
          ;; Handler extracted to MissileCharacterHandlers.bas
          ;; lda temp6 (duplicate)
          ;; cmp CharacterKnightGuy (duplicate)
          ;; bne skip_6589 (duplicate)
          ;; jmp HandleKnightGuyMissile (duplicate)
skip_6589:


          ;; Apply gravity if flag is set

          ;; lda temp5 (duplicate)
          ;; and MissileFlagGravity (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4156 (duplicate)
          ;; jmp GravityDone (duplicate)
skip_4156:

                    ;; let temp3 = temp3 + GravityPerFrame
          ;; Add gravity (1 pixel/frame down)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta missileVelocityY,x (duplicate)
GravityDone
          ;; Update stored Y velocity
          ;; Returns: Far (return otherbank)

          ;; Issue #1188: Apply friction if flag is set (curling stone deceleration)
          ;; Consolidated friction calculation - handles both positive and negative velocities
          ;; lda temp5 (duplicate)
          ;; and MissileFlagFriction (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_4219 (duplicate)
          ;; jmp FrictionDone (duplicate)
skip_4219:

          ;; Get current X velocity
                    ;; let missileVelocityXCalc = missileVelocityX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileVelocityX,x (duplicate)
          ;; sta missileVelocityXCalc (duplicate)
          ;; Zero velocity, no friction to apply
          ;; lda missileVelocityXCalc (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3181 (duplicate)
          ;; jmp FrictionDone (duplicate)
skip_3181:


          ;; Apply ice-like friction: reduce by CurlingFrictionCoefficient/256 per frame
          ;; CurlingFrictionCoefficient = 4, so reduction = velocity / 64 (1.56% per frame)
          ;; Issue #1188: Consolidated calculation - works for both positive and negative
          ;; Calculate reduction amount (velocity / 64 using 6-bit shift)
          ;; lda missileVelocityXCalc (duplicate)
          ;; sta velocityCalculation (duplicate)
            ;; lda velocityCalculation (duplicate)
          ;; TODO: bpl FrictionPositive
            eor #$FF
            adc # 0
FrictionPositive
            lsr
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta velocityCalculation (duplicate)
          ;; Apply reduction: subtract for positive, add for negative (both reduce magnitude)
          ;; lda missileVelocityXCalc (duplicate)
          ;; cmp # 128 (duplicate)
          bcc skip_7223
          ;; ;; let missileVelocityXCalc = missileVelocityXCalc + velocityCalculation else let missileVelocityXCalc = missileVelocityXCalc - velocityCalculation          lda missileVelocityXCalc          sec          sbc velocityCalculation          sta missileVelocityXCalc
          ;; lda missileVelocityXCalc (duplicate)
          ;; sec (duplicate)
          ;; sbc velocityCalculation (duplicate)
          ;; sta missileVelocityXCalc (duplicate)

          ;; lda missileVelocityXCalc (duplicate)
          ;; sec (duplicate)
          ;; sbc velocityCalculation (duplicate)
          ;; sta missileVelocityXCalc (duplicate)

skip_7223:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileVelocityXCalc (duplicate)
          ;; sta missileVelocityX,x (duplicate)
          ;; Update temp2 for position calculation
          ;; lda missileVelocityXCalc (duplicate)
          ;; sta temp2 (duplicate)
          ;; Check if velocity dropped below threshold
                    ;; if missileVelocityXCalc < MinimumVelocityThreshold && missileVelocityXCalc > -MinimumVelocityThreshold then goto DeactivateMissile
FrictionDone

          ;; Issue #1188: Update missile position and check bounds (consolidated)
          ;; Update X position
          ;; Update Y position (Read-Modify-Write)
                    ;; let missileX[temp1] = missileX[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta missileX,x + temp2 (duplicate)
                    ;; let temp4 = missileY_R[temp1] + temp3         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta missileY_W,x (duplicate)

          ;; Issue #1177: Frooty lollipop ricochet - check before wrap/deactivate
          ;; Frooty’s projectile bounces off arena bounds instead of wrapping/deactivating
                    ;; let temp6 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_761 (duplicate)
          ;; jmp FrootyRicochetCheck (duplicate)
skip_761:


          ;; Wrap around horizontally using shared player thresholds
                    ;; let temp2 = missileX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileX,x (duplicate)
          ;; sta temp2 (duplicate)
                    ;; if temp2 < PlayerLeftWrapThreshold then let missileX[temp1] = PlayerRightEdge : let temp2 = PlayerRightEdge
                    ;; if temp2 > PlayerRightWrapThreshold then let missileX[temp1] = PlayerLeftEdge : let temp2 = PlayerLeftEdge
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc PlayerRightWrapThreshold (duplicate)
          ;; bcc skip_3001 (duplicate)
          beq skip_3001
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda PlayerLeftEdge (duplicate)
          ;; sta missileX,x (duplicate)
          ;; lda PlayerLeftEdge (duplicate)
          ;; sta temp2 (duplicate)
skip_3001:

          ;; Check vertical bounds (deactivate if off-screen)
          ;; lda temp4 (duplicate)
          ;; sta temp3 (duplicate)
          ;; ;; if temp3 > ScreenBottom then goto DeactivateMissile
          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenBottom (duplicate)
          ;; bcc skip_8760 (duplicate)
          ;; beq skip_8760 (duplicate)
          ;; jmp DeactivateMissile (duplicate)
skip_8760:

          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenBottom (duplicate)
          ;; bcc skip_8334 (duplicate)
          ;; beq skip_8334 (duplicate)
          ;; jmp DeactivateMissile (duplicate)
skip_8334:


          ;; ;; if temp3 > ScreenTopWrapThreshold then goto DeactivateMissile
          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenTopWrapThreshold (duplicate)
          ;; bcc skip_5438 (duplicate)
          ;; beq skip_5438 (duplicate)
          ;; jmp DeactivateMissile (duplicate)
skip_5438:

          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenTopWrapThreshold (duplicate)
          ;; bcc skip_354 (duplicate)
          ;; beq skip_354 (duplicate)
          ;; jmp DeactivateMissile (duplicate)
skip_354:


          ;; jmp BoundsCheckDone (duplicate)

.pend

FrootyRicochetCheck .proc
          ;; Issue #1177: Frooty lollipop ricochets off arena bounds
          ;; Returns: Far (return otherbank)
          ;; Check horizontal bounds and reverse X velocity
                    ;; let temp2 = missileX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileX,x (duplicate)
          ;; sta temp2 (duplicate)
                    ;; if temp2 < PlayerLeftWrapThreshold then goto FrootyRicochetLeft
          ;; lda temp2 (duplicate)
          ;; cmp PlayerLeftWrapThreshold (duplicate)
          bcs skip_8063
          ;; jmp FrootyRicochetLeft (duplicate)
skip_8063:
          
          ;; ;; if temp2 > PlayerRightWrapThreshold then goto FrootyRicochetRight
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc PlayerRightWrapThreshold (duplicate)
          ;; bcc skip_4449 (duplicate)
          ;; beq skip_4449 (duplicate)
          ;; jmp FrootyRicochetRight (duplicate)
skip_4449:

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc PlayerRightWrapThreshold (duplicate)
          ;; bcc skip_6866 (duplicate)
          ;; beq skip_6866 (duplicate)
          ;; jmp FrootyRicochetRight (duplicate)
skip_6866:


          ;; jmp FrootyRicochetVerticalCheck (duplicate)
.pend

FrootyRicochetLeft .proc
          ;; Hit left wall - reverse X velocity and clamp position
          ;; Returns: Far (return otherbank)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda PlayerLeftWrapThreshold (duplicate)
          ;; sta missileX,x (duplicate)
                    ;; let missileVelocityX[temp1] = 0 - missileVelocityX[temp1]
          ;; jmp FrootyRicochetVerticalCheck (duplicate)
.pend

FrootyRicochetRight .proc
          ;; Hit right wall - reverse X velocity and clamp position
          ;; Returns: Far (return otherbank)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda PlayerRightWrapThreshold (duplicate)
          ;; sta missileX,x (duplicate)
                    ;; let missileVelocityX[temp1] = 0 - missileVelocityX[temp1]
.pend

FrootyRicochetVerticalCheck .proc
          ;; Check vertical bounds and reverse Y velocity
          ;; Returns: Far (return otherbank)
          ;; Screen top is around 20 (visible area), bottom is 192
          ;; lda temp4 (duplicate)
          ;; sta temp3 (duplicate)
          ;; ;; if temp3 < 20 then goto FrootyRicochetTop          lda temp3          cmp 20          bcs .skip_6296          jmp
          ;; lda temp3 (duplicate)
          ;; cmp # 20 (duplicate)
          ;; bcs skip_214 (duplicate)
          goto_label:

          ;; jmp goto_label (duplicate)
skip_214:

          ;; lda temp3 (duplicate)
          ;; cmp # 20 (duplicate)
          ;; bcs skip_3130 (duplicate)
          ;; jmp goto_label (duplicate)
skip_3130:

          
          ;; ;; if temp3 > ScreenBottom then goto FrootyRicochetBottom
          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenBottom (duplicate)
          ;; bcc skip_2992 (duplicate)
          ;; beq skip_2992 (duplicate)
          ;; jmp FrootyRicochetBottom (duplicate)
skip_2992:

          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenBottom (duplicate)
          ;; bcc skip_8640 (duplicate)
          ;; beq skip_8640 (duplicate)
          ;; jmp FrootyRicochetBottom (duplicate)
skip_8640:


          ;; jmp BoundsCheckDone (duplicate)
.pend

FrootyRicochetTop .proc
          ;; Hit top wall - reverse Y velocity and clamp position
          ;; Returns: Far (return otherbank)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 20 (duplicate)
          ;; sta missileY_W,x (duplicate)
                    ;; let missileVelocityY[temp1] = 0 - missileVelocityY[temp1]
          ;; jmp BoundsCheckDone (duplicate)
.pend

FrootyRicochetBottom .proc
          ;; Hit bottom wall - reverse Y velocity and clamp position
          ;; Returns: Far (return otherbank)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda ScreenBottom (duplicate)
          ;; sta missileY_W,x (duplicate)
                    ;; let missileVelocityY[temp1] = 0 - missileVelocityY[temp1]
BoundsCheckDone

          ;; Check collision with playfield if flag is set
          ;; Reload cached missile flags (temp5 was overwritten with Y position above)
          ;; Get cached flags again (restore after temp5 was used for Y position)
                    ;; let temp5 = missileFlags_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileFlags_R,x (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp5 (duplicate)
          ;; and MissileFlagHitBackground (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8110 (duplicate)
          ;; jmp PlayfieldCollisionDone (duplicate)
skip_8110:

          ;; Cross-bank call to MissileCollPF in bank 8
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(MissileCollPF-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(MissileCollPF-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 7
          ;; jmp BS_jsr (duplicate)
return_point:

          ;; Issue #1188: Collision detected - check if should bounce or deactivate
          ;; lda temp4 (duplicate)
          ;; bne skip_1997 (duplicate)
          ;; jmp PlayfieldCollisionDone (duplicate)
skip_1997:

          ;; jsr HandleMissileBounce (duplicate)
          ;; jmp DeactivateMissile (duplicate)
PlayfieldCollisionDone
          ;; No bounce - deactivate on background hit
          ;; Returns: Far (return otherbank)

          ;; Check collision with players
          ;; This handles both visible missiles and AOE attacks
          ;; Cross-bank call to CheckAllMissileCollisions in bank 8
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(CheckAllMissileCollisions-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(CheckAllMissileCollisions-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 7 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; Check if hit was found (temp4 ≠ MissileHitNotFound)
          ;; lda temp4 (duplicate)
          ;; cmp MissileHitNotFound (duplicate)
          ;; bne skip_8749 (duplicate)
          ;; jmp MissileSystemNoHit (duplicate)
skip_8749:


          ;; Issue #1188: Check if hit player is guarding before handling hit
                    ;; let temp6 = playerState[temp4] & 2         
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; Guarding - bounce instead of damage
          ;; lda temp6 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1567 (duplicate)
          ;; jmp HandleMissileDamage (duplicate)
skip_1567:

          ;; Guard bounce: play sound, invert velocity, reduce by 25%
          ;; lda SoundGuardBlock (duplicate)
          ;; sta soundEffectID_W (duplicate)
          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; Invert X velocity (bounce back)
          ;; ;; let temp6 = 0 - missileVelocityX[temp1]
          ;; lda 0 (duplicate)
          ;; sec (duplicate)
          ;; sbc missileVelocityX (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda 0 (duplicate)
          ;; sec (duplicate)
          ;; sbc missileVelocityX (duplicate)
          ;; sta temp6 (duplicate)

          ;; Reduce by 25% (divide by 4, then subtract)
            ;; lda temp6 (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta velocityCalculation (duplicate)
                    ;; let missileVelocityX[temp1] = temp6 - velocityCalculation
          ;; Continue without deactivating - missile bounces
          ;; jmp MissileSystemNoHit (duplicate)

.pend

HandleMissileDamage .proc
          ;; HandleMissileHit applies damage and effects
          ;; Returns: Far (return otherbank)
          ;; jsr HandleMissileHit (duplicate)
          ;; tail call
          ;; jmp DeactivateMissile (duplicate)
.pend

MissileSystemNoHit .proc
          ;; Missile disappears after hitting player
          ;; Returns: Far (return otherbank)

          ;; Decrement lifetime counter and check expiration
          ;; Retrieve current lifetime for this missile
                    ;; let missileLifetimeValue = missileLifetime_R[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileLifetime_R,x (duplicate)
          ;; sta missileLifetimeValue (duplicate)

          ;; Decrement if not set to infinite (infinite until
          ;; collision)
          ;; lda missileLifetimeValue (duplicate)
          ;; cmp MissileLifetimeInfinite (duplicate)
          ;; bne skip_8726 (duplicate)
                    ;; goto MissileUpdateComplete
skip_8726:

          dec missileLifetimeValue
          ;; lda missileLifetimeValue (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1561 (duplicate)
          ;; jmp DeactivateMissile (duplicate)
skip_1561:

          ;; tail call
          ;; dec missileLifetimeValue (duplicate)
          ;; lda missileLifetimeValue (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1561 (duplicate)
          ;; jmp DeactivateMissile (duplicate)
;; skip_1561: (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileLifetimeValue (duplicate)
          ;; sta missileLifetime_W,x (duplicate)
MissileUpdateComplete

          ;; rts (duplicate)
          ;; Character handlers extracted to MissileCharacterHandlers.bas

.pend

MissileSysPF .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Missile-playfield Collision
          ;; Checks if missile hit the playfield (walls, obstacles).
          ;; Uses pfread to check playfield pixel at missile position.
          ;;
          ;; INPUT:
          ;; temp1 = player index (0-3)
          ;;
          ;; OUTPUT:
          ;; temp4 = 1 if hit playfield, 0 if clear
          ;; Checks if missile hit the playfield (walls, obsta

          ;; using pfread
          ;;
          ;; Input: temp1 = player index (0-3), missileX[] (global
          ;; array) = missile X positions, missileY_R[] (global SCRAM
          ;; array) = missile Y positions
          ;;
          ;; Output: temp4 = 1 if hit playfield, 0 if clear, temp6 =
          ;; playfield column (0-31)
          ;;
          ;; Mutates: temp2-temp6 (used for calculations)
          ;;
          ;; Called Routines: None (uses inline bit shifts for division)
          ;;
          ;; Constraints: Uses pfread to check playfield pixel at
          ;; missile position. X coordinate converted to playfield column
          ;; (0-31) by subtracting ScreenInsetX and dividing by 4.
          ;; Get missile X/Y position (read from _R port)
                    ;; let temp2 = missileX[temp1]          lda temp1          asl          tax          lda missileX,x          sta temp2
                    ;; let temp3 = missileY_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; Convert X/Y to playfield coordinates
          ;; Playfield is 32 quad-width pixels covering 128 pixels
          ;; (from X=16 to X=144), 192 pixels tall
          ;; pfread uses playfield coordinates: column (0-31), row
          ;; (0-7)
          ;; Convert × pixel to playfield column: subtract ScreenInsetX (16),
          ;; then divide by 4 (each quad-width pixel is 4 pixels wide)
          ;; Save original × in temp6 after removing screen inset
          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Divide by 4 using bit shift (2 right shifts)
          ;; ;; let temp6 = temp6 - ScreenInsetX          lda temp6          sec          sbc ScreenInsetX          sta temp6
          ;; lda temp6 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp6 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp6 (duplicate)

          ;; temp6 = playfield column (0-31)
          ;; ;; let temp6 = temp6 / 4          lda temp6          lsr          lsr          sta temp6
          ;; lda temp6 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda temp6 (duplicate)
          ;; lsr (duplicate)
          ;; lsr (duplicate)
          ;; sta temp6 (duplicate)

          ;; Clamp column to valid range
          ;; Check for wraparound: if subtraction wrapped negative, result ≥ 128
                    ;; if temp6 & $80 then let temp6 = 0
          ;; temp3 is already in pixel coordinates, pfread will handle
          ;; lda temp6 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_5047 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp6 (duplicate)
skip_5047:

          ;; it

          ;; Check if playfield pixel is set
          ;; lda # 0 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)

          ;; Default: no collision detected
          ;; jsr BS_return (duplicate)
          ;; jsr BS_return (duplicate)
CheckMissilePlayerCollision
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Missile-player Collision
          ;; Checks if a missile hit any player (except the owner).
          ;; Uses axis-aligned bounding box (AABB) collision detection.
          ;;
          ;; INPUT:
          ;; temp1 = missile owner player index (0-3)
          ;;
          ;; OUTPUT:
          ;; temp4 = hit player index (0-3), or 255 if no hit
          ;; Checks if missile hit any player (except owner) using AABB
          ;; collision detection
          ;;
          ;; Input: temp1 = missile owner player index (0-3),
          ;; missileX[] (global array) = missile X positions,
          ;; missileY_R[] (global SCRAM array) = missile Y positions,
          ;; playerX[], playerY[] (global arrays) = player positions,
          ;; playerHealth[] (global array) = player health,
          ;; MissileAABBSize, PlayerSpriteHalfWidth, PlayerSpriteHeight
          ;; (global constants) = collision bounds, MissileHitNotFound
          ;; (global constant) = no hit value (255)
          ;;
          ;; Output: temp4 = hit player index (0-3), or
          ;; MissileHitNotFound (255) if no hit
          ;;
          ;; Mutates: temp2-temp4 (used for calculations)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Skips owner player and eliminated players
          ;; (health = 0). Uses axis-aligned bounding box (AABB)
          ;; collision detection
          ;; Get missile X/Y position (read from _R port)
                    ;; let temp2 = missileX[temp1]          lda temp1          asl          tax          lda missileX,x          sta temp2
                    ;; let temp3 = missileY_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileY_R,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; Missile bounding box
          ;; temp2 = missile left, temp2+MissileAABBSize = missile
          ;; right
          ;; temp3 = missile top, temp3+MissileAABBSize = missile
          ;; bottom

          ;; Check collision with each player (except owner)
          ;; lda MissileHitNotFound (duplicate)
          ;; sta temp4 (duplicate)
          ;; Default: no hit

          ;; Optimized: Loop through all players instead of copy-paste code
          ;; This reduces ROM footprint by ~150 bytes
          ;; Skip owner player
          ;; TODO: for temp6 = 0 to 3
          ;; Skip eliminated players
          ;; lda temp6 (duplicate)
          ;; cmp temp1 (duplicate)
          ;; bne skip_3102 (duplicate)
          ;; jmp MissileCheckNextPlayer (duplicate)
skip_3102:

          ;; AABB collision check: missile vs player bounding box
                    ;; if playerHealth[temp6] = 0 then goto MissileCheckNextPlayer
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_1475 (duplicate)
          ;; jmp MissileCheckNextPlayer (duplicate)
skip_1475:
                    ;; if temp2 >= playerX[temp6] + PlayerSpriteHalfWidth then goto MissileCheckNextPlayer
                    ;; if temp2 + MissileAABBSize <= playerX[temp6] then goto MissileCheckNextPlayer
          ;; lda temp2 (duplicate)
          clc
          ;; adc MissileAABBSize (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; bcc skip_6361 (duplicate)
          ;; beq skip_6361 (duplicate)
          ;; jmp MissileCheckNextPlayer (duplicate)
skip_6361:
                    ;; if temp3 >= playerY[temp6] + PlayerSpriteHeight then goto MissileCheckNextPlayer
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; clc (duplicate)
          ;; adc PlayerSpriteHeight (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; bcc skip_690 (duplicate)
          ;; jmp MissileCheckNextPlayer (duplicate)
skip_690:
          ;; Collision detected - return otherbank hit player index
                    ;; if temp3 + MissileAABBSize <= playerY[temp6] then goto MissileCheckNextPlayer
          ;; lda temp3 (duplicate)
          ;; clc (duplicate)
          ;; adc MissileAABBSize (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; bcc skip_8688 (duplicate)
          ;; beq skip_8688 (duplicate)
          ;; jmp MissileCheckNextPlayer (duplicate)
skip_8688:
          ;; lda temp6 (duplicate)
          ;; sta temp4 (duplicate)
          ;; jmp MissileCollisionReturn (duplicate)
.pend

MissileCheckNextPlayer .proc
.pend

;; next_label_2 .proc (duplicate)
MissileCollisionReturn
          ;; jsr BS_return (duplicate)
;; .pend (no matching .proc)

HandleMissileHit .proc
          ;;
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Handle Missile Hit
          ;; Processes a missile hitting a player.
          ;; Applies damage, knockback, and visual/audio feedback.
          ;;
          ;; INPUT:
          ;; temp1 = attacker player index (0-3, missile owner)
          ;; temp4 = defender player index (0-3, hit player)
          ;; Processes missile hitting a player (damage, knockback,
          ;; hitstun, sound)
          ;;
          ;; Input: temp1 = attacker player index (0-3, missile owner),
          ;; temp4 = defender player index (0-3, hit player),
          ;; playerCharacter[] (global array) = character types,
          ;; characterStateFlags_R[] (global SCRAM array) = character
          ;; state flags (for Harpy dive mode), missileX[] (global
          ;; array) = missile X positions, playerX[], playerY[] (global
          ;; arrays) = player positions, CharacterWeights[] (global
          ;; data table) = character weights, KnockbackImpulse,
          ;; HitstunFrames (global constants) = physics consta

          ;; SoundAttackHit (global constant) = sound effect ID
          ;;
          ;; Output: Damage applied, knockback applied (weight-based),
          ;; hitstun set, sound played
          ;;
          ;; Mutates: temp1-temp6 (used for calculations),
          ;; playerHealth[] (global array) = player health
          ;; (decremented), playerVelocityX[], playerVelocityXL[]
          ;; (global arrays) = player velocities (knockback applied),
          ;; playerRecoveryFrames[] (global array) = recovery frames
          ;; (set to HitstunFrames), playerState[] (global array) =
          ;; player states (recovery flag set), soundEffectID (global)
          ;; = sound effect ID
          ;;
          ;; Called Routines: GetCharacterDamage (bank12) - obtains base
          ;; damage per character, PlaySoundEffect (bank15) - plays hit
          ;; sound
          ;;
          ;; Constraints: Harpy dive mode increases damage by 50%.
          ;; Knockback scales with character weight (heavier = less
          ;; knockback). Minimum 1 pixel knockback even for heaviest
          ;; characters
          ;; Get character type for damage calculation
                    ;; let temp5 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp5

          ;; Apply damage from attacker to defender
          ;; lda temp1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; GetCharacterDamage inlined - weight-based damage calculation
          ;; lda temp5 (duplicate)
          ;; sta temp1 (duplicate)
                    ;; let temp3 = CharacterWeights[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWeights,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWeights,x (duplicate)
          ;; sta temp3 (duplicate)
                    ;; if temp3 <= 15 then let temp2 = 12 : goto MissileDamageDone
                    ;; if temp3 <= 25 then let temp2 = 18 : goto MissileDamageDone
          ;; lda temp3 (duplicate)
          ;; cmp # 26 (duplicate)
          ;; bcs skip_5549 (duplicate)
          ;; lda # 18 (duplicate)
          ;; sta temp2 (duplicate)
          ;; jmp MissileDamageDone (duplicate)
skip_5549:
          ;; lda # 22 (duplicate)
          ;; sta temp2 (duplicate)
MissileDamageDone
          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)
          ;; Base damage derived from character definition
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Apply dive damage bonus for Harpy

          ;; lda temp5 (duplicate)
          ;; cmp # 6 (duplicate)
          ;; bne skip_3235 (duplicate)
          ;; jmp HarpyCheckDive (duplicate)
skip_3235:

          ;; jmp DiveCheckDone (duplicate)
.pend

HarpyCheckDive .proc
          ;; Check if Harpy is in dive mode
          ;; Returns: Far (return otherbank)
          ;; Not diving, skip bonus
          ;; lda characterStateFlags_R[temp1] (duplicate)
          ;; and 4 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6724 (duplicate)
          ;; jmp DiveCheckDone (duplicate)
skip_6724:

          ;; Apply 1.5× damage for diving attacks (temp6 + temp6 ÷ 2 =
          ;; 1.5 × temp6)
          ;; lda temp6 (duplicate)
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta velocityCalculation (duplicate)
                    ;; let temp6 = temp6 + velocityCalculation
DiveCheckDone

          ;; Guard check is handled before HandleMissileHit is called
          ;; This function only handles damage application

          ;; Apply damage
                    ;; let oldHealthValue = playerHealth[temp4]         
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sta oldHealthValue (duplicate)
                    ;; let playerHealth[temp4] = playerHealth[temp4] - temp6
                    ;; if playerHealth[temp4] > oldHealthValue then let playerHealth[temp4] = 0
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sec (duplicate)
          ;; sbc oldHealthValue (duplicate)
          ;; bcc skip_9990 (duplicate)
          ;; beq skip_9990 (duplicate)
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerHealth,x (duplicate)
skip_9990:

          ;; Apply knockback (weight-based scaling - heavier characters
          ;; resist more)
          ;; Calculate direction: if missile moving right, push
          ;; defender right
                    ;; let temp2 = missileX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileX,x (duplicate)
          ;; sta temp2 (duplicate)

          ;; Issue #1188: Weight-based knockback scaling (simplified)
          ;; Heavier characters resist knockback more (weight 5-100)
                    ;; let temp6 = playerCharacter[temp4]         
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; Light characters (weight < 50): full knockback
                    ;; let characterWeight = CharacterWeights[temp6]         
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWeights,x (duplicate)
          ;; sta characterWeight (duplicate)
          ;; if characterWeight >= 50 then goto WeightBasedKnockbackScale
          ;; lda characterWeight (duplicate)
          ;; cmp 50 (duplicate)

          ;; bcc skip_5458 (duplicate)

          ;; jmp skip_5458 (duplicate)

          skip_5458:
          ;; lda KnockbackImpulse (duplicate)
          ;; sta impulseStrength (duplicate)
          ;; jmp WeightBasedKnockbackApply (duplicate)
.pend

WeightBasedKnockbackScale .proc
          ;; Heavy characters: reduced knockback (4 × (100-weight) / 100)
          ;; Returns: Far (return otherbank)
          ;; ;; let velocityCalculation = 100 - characterWeight          lda 100          sec          sbc characterWeight          sta velocityCalculation
          ;; lda 100 (duplicate)
          ;; sec (duplicate)
          ;; sbc characterWeight (duplicate)
          ;; sta velocityCalculation (duplicate)

          ;; lda 100 (duplicate)
          ;; sec (duplicate)
          ;; sbc characterWeight (duplicate)
          ;; sta velocityCalculation (duplicate)

            ;; lda velocityCalculation (duplicate)
            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; sta impulseStrength (duplicate)
          ;; lda impulseStrength (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 201 (duplicate)
          ;; bcc skip_4019 (duplicate)
                    ;; let impulseStrength = 2 : goto WeightBasedKnockbackApply
skip_4019:

          ;; lda temp2 (duplicate)
          ;; cmp # 101 (duplicate)
          ;; bcc skip_4159 (duplicate)
                    ;; let impulseStrength = 1 : goto WeightBasedKnockbackApply
skip_4159:

          ;; lda # 0 (duplicate)
          ;; sta impulseStrength (duplicate)
          ;; lda impulseStrength (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_7646 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta impulseStrength (duplicate)
skip_7646:

.pend

WeightBasedKnockbackApply .proc
          ;; Apply knockback: missile from left pushes right, from right pushes left
          ;; Returns: Far (return otherbank)
                    ;; if temp2 >= playerX[temp4] then goto KnockbackRight
                    ;; let playerVelocityX[temp4] = playerVelocityX[temp4]
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; sta playerVelocityX,x + impulseStrength (duplicate)
          ;; jmp KnockbackDone (duplicate)
.pend

KnockbackRight .proc
                    ;; let playerVelocityX[temp4] = playerVelocityX[temp4] - impulseStrength
KnockbackDone
          ;; Zero subpixel when applying knockback impulse
          ;; Returns: Far (return otherbank)
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; Set recovery/hitstun frames
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda HitstunFrames (duplicate)
          ;; sta playerRecoveryFrames,x (duplicate)
          ;; 10 frames of hitstun

          ;; Synchronize playerState bit 3 with recovery frames
                    ;; let playerState[temp4] = playerState[temp4] | 8
          ;; Set bit 3 (recovery flag) when recovery frames are set

          ;; Play hit sound effect
          ;; lda SoundAttackHit (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; Spawn damage indicator visual (handled inline)

          ;; rts (duplicate)
.pend

HandleMissileBounce .proc

          ;;
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Handle Missile Bounce
          ;; Handles wall bounce for missiles with bounce flag set.
          ;;
          ;; INPUT:
          ;; temp1 = player index (0-3)
          ;; temp5 = missile flags
          ;; Handles wall bounce for missiles with bounce flag set
          ;; (inverts X velocity, applies friction damping)
          ;;
          ;; Input: temp1 = player index (0-3), temp5 = missile flags,
          ;; missileVelocityX[] (global array) = missile × velocities,
          ;; MissileFlagFriction (global constant) = friction flag,
          ;; MaxByteValue (global constant) = 255
          ;;
          ;; Output: X velocity inverted (bounced), friction damping
          ;; applied if flag set
          ;;
          ;; Mutates: temp2, temp6 (used for calculations),
          ;; missileVelocityX[] (global array) = missile X velocity
          ;; (inverted and dampened)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Velocity inverted using two’s complement. If
          ;; friction flag set, velocity reduced by 50% (half). Missile
          ;; continues bouncing (not deactivated)
          ;; Get current X velocity
                    ;; let missileVelocityXCalc = missileVelocityX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileVelocityX,x (duplicate)
          ;; sta missileVelocityXCalc (duplicate)
          ;; Invert velocity (bounce back) using twos complement
          ;; Split calculation to avoid sbc #256 (256 > 255)
          ;; ;; let temp6 = MaxByteValue - missileVelocityXCalc          lda MaxByteValue          sec          sbc missileVelocityXCalc          sta temp6
          ;; lda MaxByteValue (duplicate)
          ;; sec (duplicate)
          ;; sbc missileVelocityXCalc (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda MaxByteValue (duplicate)
          ;; sec (duplicate)
          ;; sbc missileVelocityXCalc (duplicate)
          ;; sta temp6 (duplicate)

          ;; tempCalc = 255 - velocity
          ;; lda temp6 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta missileVelocityXCalc (duplicate)
          ;; velocity = (255 - velocity) + 1 = 256 - velocity (twos
          ;; complement)

          ;; Apply friction damping if friction flag is set

          ;; Reduce velocity by half (bit shift right by 1)
          ;; lda temp5 (duplicate)
          ;; and MissileFlagFriction (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_9352 (duplicate)
          ;; jmp BounceDone (duplicate)
skip_9352:

          ;; Use bit shift instead of division to avoid complexity
          ;; issues
          ;; Subtraction works for both positive and negative values:
          ;; Positive: velocity - (velocity >> 1) = 0.5 velocity
          ;; (reduces)
          ;; Negative: velocity - (velocity >> 1) = 0.5 velocity
          ;; (reduces magnitude)
          ;; Divide by 2 using bit shift right (LSR) - direct memory
          ;; lda missileVelocityXCalc (duplicate)
          ;; sta temp2 (duplicate)
          ;; mode
            ;; lsr temp2 (duplicate)
          ;; ;; let missileVelocityXCalc = missileVelocityXCalc - temp2          lda missileVelocityXCalc          sec          sbc temp2          sta missileVelocityXCalc
          ;; lda missileVelocityXCalc (duplicate)
          ;; sec (duplicate)
          ;; sbc temp2 (duplicate)
          ;; sta missileVelocityXCalc (duplicate)

          ;; lda missileVelocityXCalc (duplicate)
          ;; sec (duplicate)
          ;; sbc temp2 (duplicate)
          ;; sta missileVelocityXCalc (duplicate)

BounceDone
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda missileVelocityXCalc (duplicate)
          ;; sta missileVelocityX,x (duplicate)

          ;; Continue bouncing (do not deactivate)
          ;; rts (duplicate)
.pend

;; DeactivateMissile .proc (no matching .pend)
          ;;
          ;; Returns: Far (return otherbank)
          ;; Deactivate Missile
          ;; Removes a missile from active sta

          ;;
          ;; INPUT:
          ;; temp1 = player index (0-3)
          ;; Removes a missile from active status (clears active bit)
          ;;
          ;; Input: temp1 = player index (0-3), BitMask[] (global data
          ;; table) = bit masks, MaxByteValue (global constant) = 255,
          ;; missileActive (global) = missile active flags
          ;;
          ;; Output: Missile deactivated (active bit cleared)
          ;;
          ;; Mutates: temp6 (used for bit manipulation), missileActive
          ;; (global) = missile active flags (bit cleared)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: None
          ;; Clear active bit for this player missile
                    ;; let temp6 = BitMask[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda BitMask,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; ;; let temp6 = MaxByteValue - temp6          lda MaxByteValue          sec          sbc temp6          sta temp6
          ;; lda MaxByteValue (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp6 (duplicate)

          ;; lda MaxByteValue (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp6 (duplicate)

          ;; Invert bits
          ;; lda missileActive (duplicate)
          ;; and temp6 (duplicate)
          ;; sta missileActive (duplicate)
          ;; jsr BS_return (duplicate)


;; .pend (extra - no matching .proc)

