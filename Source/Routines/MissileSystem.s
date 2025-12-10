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
                    let temp6 = BitMask[temp1]         
          lda temp1
          asl
          tax
          lda BitMask,x
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
          INPUT:
          ;; temp1 = player index (0-3)
          PROCESS:
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
          bit mask
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
                    let temp5 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp5

          ;; Read missile emission height from character data table
                    let temp6 = CharacterMissileEmissionHeights[temp5]
          lda temp5
          asl
          tax
          lda CharacterMissileEmissionHeights,x
          sta temp6
          lda temp5
          asl
          tax
          lda CharacterMissileEmissionHeights,x
          sta temp6

          ;; Calculate initial missile position based on player
          ;; position and facing
          ;; Facing is stored in playerState bit 0: 0=left, 1=right
          ;; Get facing direction
                    let temp4 = playerState[temp1] & PlayerStateBitFacing         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp4

          ;; Set missile position using array access (write to _W port)
                    let missileX[temp1] = playerX[temp1]
                    let missileY_W[temp1] = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          lda temp1
          asl
          tax
          sta missileY_W,x + temp6
          ;; Facing left, spawn left
          lda temp4
          cmp # 0
          bne skip_8091
                    let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetLeft[temp5]
skip_8091:

          ;; Facing right, spawn right
          lda temp4
          cmp # 1
          bne skip_3827
                    let missileX[temp1] = missileX[temp1] + CharacterMissileSpawnOffsetRight[temp5]
skip_3827:


          ;; Set active bit for this player missile
          bit 0 = P1, bit 1 = P2, bit 2 = P3, bit 3 = P4
          ;; Calculate bit flag: 1, 2, 4, 8 for players 0, 1, 2, 3
          jsr GetPlayerMissileBitFlag
          lda missileActive
          ora temp6
          sta missileActive

          ;; Initialize lifetime counter from character data table
                    let missileLifetimeValue = CharacterMissileLifetime[temp5]          lda temp5          asl          tax          lda CharacterMissileLifetime,x          sta missileLifetimeValue

          ;; Store lifetime in player-specific variable
          ;; Using individual variables for each player missile
          ;; lifetime
          lda temp1
          asl
          tax
          lda missileLifetimeValue
          sta missileLifetime_W,x

          ;; Cache missile flags at spawn to avoid per-frame lookups
          ;; Flags are immutable per character, so cache once at spawn
          let temp2 = CharacterMissileFlags[temp5]
          lda temp5
          asl
          tax
          lda CharacterMissileFlags,x
          sta temp2
          ;; Store flags for use in UpdateOneMissile
          lda temp1
          asl
          tax
          lda temp2
          sta missileFlags_W,x

          ;; Initialize velocity from character data for friction
          ;; physics
                    let temp6 = CharacterMissileMomentumX[temp5]
          lda temp5
          asl
          tax
          lda CharacterMissileMomentumX,x
          sta temp6
          lda temp5
          asl
          tax
          lda CharacterMissileMomentumX,x
          sta temp6
          ;; Get base X velocity
          lda temp4
          cmp # 0
          bne skip_35
          ;; let temp6 = 0 - temp6          lda 0          sec          sbc temp6          sta temp6
          lda 0
          sec
          sbc temp6
          sta temp6

          lda 0
          sec
          sbc temp6
          sta temp6

skip_35:

          ;; Apply facing direction (left = negative)
          lda temp1
          asl
          tax
          lda temp6
          sta missileVelocityX,x

          ;; Optimized: Use precomputed NUSIZ table instead of arithmetic
          ;; NUSIZ values precomputed in CharacterMissileNUSIZ table
                    let missileNUSIZ_W[temp1] = CharacterMissileNUSIZ[temp5]

          ;; Get Y velocity
                    let temp6 = CharacterMissileMomentumY[temp5]         
          lda temp5
          asl
          tax
          lda CharacterMissileMomentumY,x
          sta temp6

          ;; Apply Harpy dive velocity bonus if in dive mode
          ;; Handler extracted to MissileCharacterHandlers.bas
          lda temp5
          cmp # 6
          bne skip_7121
          jmp HarpyCheckDiveVelocity
skip_7121:

          ;; VelocityDone label is in MissileCharacterHandlers.bas
          jmp VelocityDone

          jsr BS_return

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
          jsr UpdateOneMissile
.pend

next_label_1_L280:.proc
          jsr BS_return

UpdateOneMissile
          ;; Returns: Near (return thisbank)
UpdateOneMissile
          ;;
          ;; Returns: Near (return thisbank)
          ;; Update One Missile
          ;; Updates a single player missile.
          ;; Handles movement, gravity, collisions, and lifetime.
          ;;
          INPUT:
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
          jsr GetPlayerMissileBitFlag
          lda missileActive
          and temp6
          sta temp4
          ;; Not active, skip
          rts

          ;; Preserve player index since GetMissileFlags uses temp1
          ;; Use temp6 temporarily to save player index (temp6 is used
          ;; for bit flags)
          lda temp1
          sta temp6
          ;; Save player index temporarily

          ;; Get current velocities from stored arrays
                    let temp2 = missileVelocityX[temp1]          lda temp1          asl          tax          lda missileVelocityX,x          sta temp2
          ;; X velocity (already facing-adjusted from spawn)
          let temp3 = missileVelocityY[temp1]
          lda temp1
          asl
          tax
          lda missileVelocityY,x
          sta temp3
          ;; Y velocity

          ;; Use cached missile flags (set at spawn) instead of lookup
          ;; This avoids two CharacterMissileFlags lookups per frame
          ;; Get cached flags (set at spawn time)
                    let temp5 = missileFlags_R[temp1]
          lda temp1
          asl
          tax
          lda missileFlags_R,x
          sta temp5
          lda temp1
          asl
          tax
          lda missileFlags_R,x
          sta temp5

          ;; Restore player index
          lda temp6
          sta temp1

          ;; Issue #1188: Character handler dispatch - look up character ID for special handlers
          ;; Special handling for Megax (character 5): stationary fire breath visual
          ;; Megax missile stays adjacent to player during attack, no movement
          ;; Handler extracted to MissileCharacterHandlers.bas
          ;; Get character ID for handler dispatch
                    let temp6 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          lda temp6
          cmp CharacterMegax
          bne skip_3745
          jmp HandleMegaxMissile
skip_3745:


          ;; Special handling for Knight Guy (character 7): sword swing visual
          ;; Knight Guy missile appears overlapping, moves away, returns, then vanishes
          ;; Handler extracted to MissileCharacterHandlers.bas
          lda temp6
          cmp CharacterKnightGuy
          bne skip_6589
          jmp HandleKnightGuyMissile
skip_6589:


          ;; Apply gravity if flag is set

          lda temp5
          and MissileFlagGravity
          cmp # 0
          bne skip_4156
          jmp GravityDone
skip_4156:

                    let temp3 = temp3 + GravityPerFrame
          ;; Add gravity (1 pixel/frame down)
          lda temp1
          asl
          tax
          lda temp3
          sta missileVelocityY,x
GravityDone
          ;; Update stored Y velocity
          ;; Returns: Far (return otherbank)

          ;; Issue #1188: Apply friction if flag is set (curling stone deceleration)
          ;; Consolidated friction calculation - handles both positive and negative velocities
          lda temp5
          and MissileFlagFriction
          cmp # 0
          bne skip_4219
          jmp FrictionDone
skip_4219:

          ;; Get current X velocity
                    let missileVelocityXCalc = missileVelocityX[temp1]         
          lda temp1
          asl
          tax
          lda missileVelocityX,x
          sta missileVelocityXCalc
          ;; Zero velocity, no friction to apply
          lda missileVelocityXCalc
          cmp # 0
          bne skip_3181
          jmp FrictionDone
skip_3181:


          ;; Apply ice-like friction: reduce by CurlingFrictionCoefficient/256 per frame
          CurlingFrictionCoefficient = 4, so reduction = velocity / 64 (1.56% per frame)
          ;; Issue #1188: Consolidated calculation - works for both positive and negative
          ;; Calculate reduction amount (velocity / 64 using 6-bit shift)
          lda missileVelocityXCalc
          sta velocityCalculation
            lda velocityCalculation
          ;; TODO: bpl FrictionPositive
            eor #$FF
            adc # 0
FrictionPositive
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta velocityCalculation
          ;; Apply reduction: subtract for positive, add for negative (both reduce magnitude)
          lda missileVelocityXCalc
          cmp # 128
          bcc skip_7223
          ;; let missileVelocityXCalc = missileVelocityXCalc + velocityCalculation else let missileVelocityXCalc = missileVelocityXCalc - velocityCalculation          lda missileVelocityXCalc          sec          sbc velocityCalculation          sta missileVelocityXCalc
          lda missileVelocityXCalc
          sec
          sbc velocityCalculation
          sta missileVelocityXCalc

          lda missileVelocityXCalc
          sec
          sbc velocityCalculation
          sta missileVelocityXCalc

skip_7223:

          lda temp1
          asl
          tax
          lda missileVelocityXCalc
          sta missileVelocityX,x
          ;; Update temp2 for position calculation
          lda missileVelocityXCalc
          sta temp2
          ;; Check if velocity dropped below threshold
                    if missileVelocityXCalc < MinimumVelocityThreshold && missileVelocityXCalc > -MinimumVelocityThreshold then goto DeactivateMissile
FrictionDone

          ;; Issue #1188: Update missile position and check bounds (consolidated)
          ;; Update X position
          ;; Update Y position (Read-Modify-Write)
                    let missileX[temp1] = missileX[temp1]
          lda temp1
          asl
          tax
          lda missileX,x
          lda temp1
          asl
          tax
          sta missileX,x + temp2
                    let temp4 = missileY_R[temp1] + temp3         
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta temp4
          lda temp1
          asl
          tax
          lda temp4
          sta missileY_W,x

          ;; Issue #1177: Frooty lollipop ricochet - check before wrap/deactivate
          ;; Frooty’s projectile bounces off arena bounds instead of wrapping/deactivating
                    let temp6 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          lda temp6
          cmp CharacterFrooty
          bne skip_761
          jmp FrootyRicochetCheck
skip_761:


          ;; Wrap around horizontally using shared player thresholds
                    let temp2 = missileX[temp1]         
          lda temp1
          asl
          tax
          lda missileX,x
          sta temp2
                    if temp2 < PlayerLeftWrapThreshold then let missileX[temp1] = PlayerRightEdge : let temp2 = PlayerRightEdge
                    if temp2 > PlayerRightWrapThreshold then let missileX[temp1] = PlayerLeftEdge : let temp2 = PlayerLeftEdge
          lda temp2
          sec
          sbc PlayerRightWrapThreshold
          bcc skip_3001
          beq skip_3001
          lda temp1
          asl
          tax
          lda PlayerLeftEdge
          sta missileX,x
          lda PlayerLeftEdge
          sta temp2
skip_3001:

          ;; Check vertical bounds (deactivate if off-screen)
          lda temp4
          sta temp3
          ;; if temp3 > ScreenBottom then goto DeactivateMissile
          lda temp3
          sec
          sbc ScreenBottom
          bcc skip_8760
          beq skip_8760
          jmp DeactivateMissile
skip_8760:

          lda temp3
          sec
          sbc ScreenBottom
          bcc skip_8334
          beq skip_8334
          jmp DeactivateMissile
skip_8334:


          ;; if temp3 > ScreenTopWrapThreshold then goto DeactivateMissile
          lda temp3
          sec
          sbc ScreenTopWrapThreshold
          bcc skip_5438
          beq skip_5438
          jmp DeactivateMissile
skip_5438:

          lda temp3
          sec
          sbc ScreenTopWrapThreshold
          bcc skip_354
          beq skip_354
          jmp DeactivateMissile
skip_354:


          jmp BoundsCheckDone

.pend

FrootyRicochetCheck .proc
          ;; Issue #1177: Frooty lollipop ricochets off arena bounds
          ;; Returns: Far (return otherbank)
          ;; Check horizontal bounds and reverse X velocity
                    let temp2 = missileX[temp1]         
          lda temp1
          asl
          tax
          lda missileX,x
          sta temp2
                    if temp2 < PlayerLeftWrapThreshold then goto FrootyRicochetLeft
          lda temp2
          cmp PlayerLeftWrapThreshold
          bcs skip_8063
          jmp FrootyRicochetLeft
skip_8063:
          
          ;; if temp2 > PlayerRightWrapThreshold then goto FrootyRicochetRight
          lda temp2
          sec
          sbc PlayerRightWrapThreshold
          bcc skip_4449
          beq skip_4449
          jmp FrootyRicochetRight
skip_4449:

          lda temp2
          sec
          sbc PlayerRightWrapThreshold
          bcc skip_6866
          beq skip_6866
          jmp FrootyRicochetRight
skip_6866:


          jmp FrootyRicochetVerticalCheck
.pend

FrootyRicochetLeft .proc
          ;; Hit left wall - reverse X velocity and clamp position
          ;; Returns: Far (return otherbank)
          lda temp1
          asl
          tax
          lda PlayerLeftWrapThreshold
          sta missileX,x
                    let missileVelocityX[temp1] = 0 - missileVelocityX[temp1]
          jmp FrootyRicochetVerticalCheck
.pend

FrootyRicochetRight .proc
          ;; Hit right wall - reverse X velocity and clamp position
          ;; Returns: Far (return otherbank)
          lda temp1
          asl
          tax
          lda PlayerRightWrapThreshold
          sta missileX,x
                    let missileVelocityX[temp1] = 0 - missileVelocityX[temp1]
.pend

FrootyRicochetVerticalCheck .proc
          ;; Check vertical bounds and reverse Y velocity
          ;; Returns: Far (return otherbank)
          ;; Screen top is around 20 (visible area), bottom is 192
          lda temp4
          sta temp3
          ;; if temp3 < 20 then goto FrootyRicochetTop          lda temp3          cmp 20          bcs .skip_6296          jmp
          lda temp3
          cmp # 20
          bcs skip_214
          goto_label:

          jmp goto_label
skip_214:

          lda temp3
          cmp # 20
          bcs skip_3130
          jmp goto_label
skip_3130:

          
          ;; if temp3 > ScreenBottom then goto FrootyRicochetBottom
          lda temp3
          sec
          sbc ScreenBottom
          bcc skip_2992
          beq skip_2992
          jmp FrootyRicochetBottom
skip_2992:

          lda temp3
          sec
          sbc ScreenBottom
          bcc skip_8640
          beq skip_8640
          jmp FrootyRicochetBottom
skip_8640:


          jmp BoundsCheckDone
.pend

FrootyRicochetTop .proc
          ;; Hit top wall - reverse Y velocity and clamp position
          ;; Returns: Far (return otherbank)
          lda temp1
          asl
          tax
          lda 20
          sta missileY_W,x
                    let missileVelocityY[temp1] = 0 - missileVelocityY[temp1]
          jmp BoundsCheckDone
.pend

FrootyRicochetBottom .proc
          ;; Hit bottom wall - reverse Y velocity and clamp position
          ;; Returns: Far (return otherbank)
          lda temp1
          asl
          tax
          lda ScreenBottom
          sta missileY_W,x
                    let missileVelocityY[temp1] = 0 - missileVelocityY[temp1]
BoundsCheckDone

          ;; Check collision with playfield if flag is set
          ;; Reload cached missile flags (temp5 was overwritten with Y position above)
          ;; Get cached flags again (restore after temp5 was used for Y position)
                    let temp5 = missileFlags_R[temp1]         
          lda temp1
          asl
          tax
          lda missileFlags_R,x
          sta temp5
          lda temp5
          and MissileFlagHitBackground
          cmp # 0
          bne skip_8110
          jmp PlayfieldCollisionDone
skip_8110:

          ;; Cross-bank call to MissileCollPF in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(MissileCollPF-1)
          pha
          lda # <(MissileCollPF-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:

          ;; Issue #1188: Collision detected - check if should bounce or deactivate
          lda temp4
          bne skip_1997
          jmp PlayfieldCollisionDone
skip_1997:

          jsr HandleMissileBounce
          jmp DeactivateMissile
PlayfieldCollisionDone
          ;; No bounce - deactivate on background hit
          ;; Returns: Far (return otherbank)

          ;; Check collision with players
          ;; This handles both visible missiles and AOE attacks
          ;; Cross-bank call to CheckAllMissileCollisions in bank 8
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(CheckAllMissileCollisions-1)
          pha
          lda # <(CheckAllMissileCollisions-1)
          pha
                    ldx # 7
          jmp BS_jsr
return_point:

          ;; Check if hit was found (temp4 ≠ MissileHitNotFound)
          lda temp4
          cmp MissileHitNotFound
          bne skip_8749
          jmp MissileSystemNoHit
skip_8749:


          ;; Issue #1188: Check if hit player is guarding before handling hit
                    let temp6 = playerState[temp4] & 2         
          lda temp4
          asl
          tax
          lda playerState,x
          sta temp6
          ;; Guarding - bounce instead of damage
          lda temp6
          cmp # 0
          bne skip_1567
          jmp HandleMissileDamage
skip_1567:

          ;; Guard bounce: play sound, invert velocity, reduce by 25%
          lda SoundGuardBlock
          sta soundEffectID_W
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
return_point:

          ;; Invert X velocity (bounce back)
          ;; let temp6 = 0 - missileVelocityX[temp1]
          lda 0
          sec
          sbc missileVelocityX
          sta temp6

          lda 0
          sec
          sbc missileVelocityX
          sta temp6

          ;; Reduce by 25% (divide by 4, then subtract)
            lda temp6
            lsr
            lsr
            sta velocityCalculation
                    let missileVelocityX[temp1] = temp6 - velocityCalculation
          ;; Continue without deactivating - missile bounces
          jmp MissileSystemNoHit

.pend

HandleMissileDamage .proc
          ;; HandleMissileHit applies damage and effects
          ;; Returns: Far (return otherbank)
          jsr HandleMissileHit
          ;; tail call
          jmp DeactivateMissile
.pend

MissileSystemNoHit .proc
          ;; Missile disappears after hitting player
          ;; Returns: Far (return otherbank)

          ;; Decrement lifetime counter and check expiration
          ;; Retrieve current lifetime for this missile
                    let missileLifetimeValue = missileLifetime_R[temp1]         
          lda temp1
          asl
          tax
          lda missileLifetime_R,x
          sta missileLifetimeValue

          ;; Decrement if not set to infinite (infinite until
          ;; collision)
          lda missileLifetimeValue
          cmp MissileLifetimeInfinite
          bne skip_8726
                    goto MissileUpdateComplete
skip_8726:

          dec missileLifetimeValue
          lda missileLifetimeValue
          cmp # 0
          bne skip_1561
          jmp DeactivateMissile
skip_1561:

          ;; tail call
          dec missileLifetimeValue
          lda missileLifetimeValue
          cmp # 0
          bne skip_1561
          jmp DeactivateMissile
skip_1561:

          lda temp1
          asl
          tax
          lda missileLifetimeValue
          sta missileLifetime_W,x
MissileUpdateComplete

          rts
          ;; Character handlers extracted to MissileCharacterHandlers.bas

.pend

MissileSysPF .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Missile-playfield Collision
          ;; Checks if missile hit the playfield (walls, obstacles).
          ;; Uses pfread to check playfield pixel at missile position.
          ;;
          INPUT:
          ;; temp1 = player index (0-3)
          ;;
          OUTPUT:
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
                    let temp2 = missileX[temp1]          lda temp1          asl          tax          lda missileX,x          sta temp2
                    let temp3 = missileY_R[temp1]
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta temp3
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta temp3

          ;; Convert X/Y to playfield coordinates
          ;; Playfield is 32 quad-width pixels covering 128 pixels
          ;; (from X=16 to X=144), 192 pixels tall
          ;; pfread uses playfield coordinates: column (0-31), row
          ;; (0-7)
          ;; Convert × pixel to playfield column: subtract ScreenInsetX (16),
          then divide by 4 (each quad-width pixel is 4 pixels wide)
          ;; Save original × in temp6 after removing screen inset
          lda temp2
          sta temp6
          ;; Divide by 4 using bit shift (2 right shifts)
          ;; let temp6 = temp6 - ScreenInsetX          lda temp6          sec          sbc ScreenInsetX          sta temp6
          lda temp6
          sec
          sbc ScreenInsetX
          sta temp6

          lda temp6
          sec
          sbc ScreenInsetX
          sta temp6

          ;; temp6 = playfield column (0-31)
          ;; let temp6 = temp6 / 4          lda temp6          lsr          lsr          sta temp6
          lda temp6
          lsr
          lsr
          sta temp6

          lda temp6
          lsr
          lsr
          sta temp6

          ;; Clamp column to valid range
          ;; Check for wraparound: if subtraction wrapped negative, result ≥ 128
                    if temp6 & $80 then let temp6 = 0
          ;; temp3 is already in pixel coordinates, pfread will handle
          lda temp6
          cmp # 32
          bcc skip_5047
          lda # 31
          sta temp6
skip_5047:

          ;; it

          ;; Check if playfield pixel is set
          lda # 0
          sta temp4
          lda temp6
          sta temp1
          lda temp3
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:

          ;; Default: no collision detected
          jsr BS_return
          jsr BS_return
CheckMissilePlayerCollision
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Missile-player Collision
          ;; Checks if a missile hit any player (except the owner).
          ;; Uses axis-aligned bounding box (AABB) collision detection.
          ;;
          INPUT:
          ;; temp1 = missile owner player index (0-3)
          ;;
          OUTPUT:
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
                    let temp2 = missileX[temp1]          lda temp1          asl          tax          lda missileX,x          sta temp2
                    let temp3 = missileY_R[temp1]
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta temp3
          lda temp1
          asl
          tax
          lda missileY_R,x
          sta temp3

          ;; Missile bounding box
          ;; temp2 = missile left, temp2+MissileAABBSize = missile
          ;; right
          ;; temp3 = missile top, temp3+MissileAABBSize = missile
          ;; bottom

          ;; Check collision with each player (except owner)
          lda MissileHitNotFound
          sta temp4
          ;; Default: no hit

          ;; Optimized: Loop through all players instead of copy-paste code
          ;; This reduces ROM footprint by ~150 bytes
          ;; Skip owner player
          ;; TODO: for temp6 = 0 to 3
          ;; Skip eliminated players
          lda temp6
          cmp temp1
          bne skip_3102
          jmp MissileCheckNextPlayer
skip_3102:

          ;; AABB collision check: missile vs player bounding box
                    if playerHealth[temp6] = 0 then goto MissileCheckNextPlayer
          lda temp6
          asl
          tax
          lda playerHealth,x
          bne skip_1475
          jmp MissileCheckNextPlayer
skip_1475:
                    if temp2 >= playerX[temp6] + PlayerSpriteHalfWidth then goto MissileCheckNextPlayer
                    if temp2 + MissileAABBSize <= playerX[temp6] then goto MissileCheckNextPlayer
          lda temp2
          clc
          adc MissileAABBSize
          sta temp6
          lda temp6
          asl
          tax
          lda playerX,x
          sec
          sbc temp6
          bcc skip_6361
          beq skip_6361
          jmp MissileCheckNextPlayer
skip_6361:
                    if temp3 >= playerY[temp6] + PlayerSpriteHeight then goto MissileCheckNextPlayer
          lda temp6
          asl
          tax
          lda playerY,x
          clc
          adc PlayerSpriteHeight
          sta temp6
          lda temp3
          sec
          sbc temp6
          bcc skip_690
          jmp MissileCheckNextPlayer
skip_690:
          ;; Collision detected - return otherbank hit player index
                    if temp3 + MissileAABBSize <= playerY[temp6] then goto MissileCheckNextPlayer
          lda temp3
          clc
          adc MissileAABBSize
          sta temp6
          lda temp6
          asl
          tax
          lda playerY,x
          sec
          sbc temp6
          bcc skip_8688
          beq skip_8688
          jmp MissileCheckNextPlayer
skip_8688:
          lda temp6
          sta temp4
          jmp MissileCollisionReturn
.pend

MissileCheckNextPlayer .proc
.pend

next_label_2 .proc
MissileCollisionReturn
          jsr BS_return
.pend (no matching .proc)

HandleMissileHit .proc
          ;;
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Handle Missile Hit
          ;; Processes a missile hitting a player.
          ;; Applies damage, knockback, and visual/audio feedback.
          ;;
          INPUT:
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
          data table) = character weights, KnockbackImpulse,
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
                    let temp5 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp5

          ;; Apply damage from attacker to defender
          lda temp1
          sta temp3
          ;; GetCharacterDamage inlined - weight-based damage calculation
          lda temp5
          sta temp1
                    let temp3 = CharacterWeights[temp1]
          lda temp1
          asl
          tax
          lda CharacterWeights,x
          sta temp3
          lda temp1
          asl
          tax
          lda CharacterWeights,x
          sta temp3
                    if temp3 <= 15 then let temp2 = 12 : goto MissileDamageDone
                    if temp3 <= 25 then let temp2 = 18 : goto MissileDamageDone
          lda temp3
          cmp # 26
          bcs skip_5549
          lda # 18
          sta temp2
          jmp MissileDamageDone
skip_5549:
          lda # 22
          sta temp2
MissileDamageDone
          lda temp2
          sta temp6
          ;; Base damage derived from character definition
          lda temp3
          sta temp1

          ;; Apply dive damage bonus for Harpy

          lda temp5
          cmp # 6
          bne skip_3235
          jmp HarpyCheckDive
skip_3235:

          jmp DiveCheckDone
.pend

HarpyCheckDive .proc
          ;; Check if Harpy is in dive mode
          ;; Returns: Far (return otherbank)
          ;; Not diving, skip bonus
          lda characterStateFlags_R[temp1]
          and 4
          cmp # 0
          bne skip_6724
          jmp DiveCheckDone
skip_6724:

          ;; Apply 1.5× damage for diving attacks (temp6 + temp6 ÷ 2 =
          ;; 1.5 × temp6)
          lda temp6
          sta temp2
            lsr temp2
          lda temp2
          sta velocityCalculation
                    let temp6 = temp6 + velocityCalculation
DiveCheckDone

          ;; Guard check is handled before HandleMissileHit is called
          ;; This function only handles damage application

          ;; Apply damage
                    let oldHealthValue = playerHealth[temp4]         
          lda temp4
          asl
          tax
          lda playerHealth,x
          sta oldHealthValue
                    let playerHealth[temp4] = playerHealth[temp4] - temp6
                    if playerHealth[temp4] > oldHealthValue then let playerHealth[temp4] = 0
          lda temp4
          asl
          tax
          lda playerHealth,x
          sec
          sbc oldHealthValue
          bcc skip_9990
          beq skip_9990
          lda temp4
          asl
          tax
          lda # 0
          sta playerHealth,x
skip_9990:

          ;; Apply knockback (weight-based scaling - heavier characters
          ;; resist more)
          ;; Calculate direction: if missile moving right, push
          ;; defender right
                    let temp2 = missileX[temp1]         
          lda temp1
          asl
          tax
          lda missileX,x
          sta temp2

          ;; Issue #1188: Weight-based knockback scaling (simplified)
          ;; Heavier characters resist knockback more (weight 5-100)
                    let temp6 = playerCharacter[temp4]         
          lda temp4
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Light characters (weight < 50): full knockback
                    let characterWeight = CharacterWeights[temp6]         
          lda temp6
          asl
          tax
          lda CharacterWeights,x
          sta characterWeight
          if characterWeight >= 50 then goto WeightBasedKnockbackScale
          lda characterWeight
          cmp 50

          bcc skip_5458

          jmp skip_5458

          skip_5458:
          lda KnockbackImpulse
          sta impulseStrength
          jmp WeightBasedKnockbackApply
.pend

WeightBasedKnockbackScale .proc
          ;; Heavy characters: reduced knockback (4 × (100-weight) / 100)
          ;; Returns: Far (return otherbank)
          ;; let velocityCalculation = 100 - characterWeight          lda 100          sec          sbc characterWeight          sta velocityCalculation
          lda 100
          sec
          sbc characterWeight
          sta velocityCalculation

          lda 100
          sec
          sbc characterWeight
          sta velocityCalculation

            lda velocityCalculation
            asl
            asl
            sta impulseStrength
          lda impulseStrength
          sta temp2
          lda temp2
          cmp # 201
          bcc skip_4019
                    let impulseStrength = 2 : goto WeightBasedKnockbackApply
skip_4019:

          lda temp2
          cmp # 101
          bcc skip_4159
                    let impulseStrength = 1 : goto WeightBasedKnockbackApply
skip_4159:

          lda # 0
          sta impulseStrength
          lda impulseStrength
          cmp # 0
          bne skip_7646
          lda # 1
          sta impulseStrength
skip_7646:

.pend

WeightBasedKnockbackApply .proc
          ;; Apply knockback: missile from left pushes right, from right pushes left
          ;; Returns: Far (return otherbank)
                    if temp2 >= playerX[temp4] then goto KnockbackRight
                    let playerVelocityX[temp4] = playerVelocityX[temp4]
          lda temp4
          asl
          tax
          lda playerVelocityX,x
          lda temp4
          asl
          tax
          sta playerVelocityX,x + impulseStrength
          jmp KnockbackDone
.pend

KnockbackRight .proc
                    let playerVelocityX[temp4] = playerVelocityX[temp4] - impulseStrength
KnockbackDone
          ;; Zero subpixel when applying knockback impulse
          ;; Returns: Far (return otherbank)
          lda temp4
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          ;; Set recovery/hitstun frames
          lda temp4
          asl
          tax
          lda HitstunFrames
          sta playerRecoveryFrames,x
          ;; 10 frames of hitstun

          ;; Synchronize playerState bit 3 with recovery frames
                    let playerState[temp4] = playerState[temp4] | 8
          ;; Set bit 3 (recovery flag) when recovery frames are set

          ;; Play hit sound effect
          lda SoundAttackHit
          sta temp1
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
return_point:


          ;; Spawn damage indicator visual (handled inline)

          rts
.pend

HandleMissileBounce .proc

          ;;
          ;; Returns: Near (return thisbank) - called same-bank
          ;; Handle Missile Bounce
          ;; Handles wall bounce for missiles with bounce flag set.
          ;;
          INPUT:
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
                    let missileVelocityXCalc = missileVelocityX[temp1]         
          lda temp1
          asl
          tax
          lda missileVelocityX,x
          sta missileVelocityXCalc
          ;; Invert velocity (bounce back) using twos complement
          ;; Split calculation to avoid sbc #256 (256 > 255)
          ;; let temp6 = MaxByteValue - missileVelocityXCalc          lda MaxByteValue          sec          sbc missileVelocityXCalc          sta temp6
          lda MaxByteValue
          sec
          sbc missileVelocityXCalc
          sta temp6

          lda MaxByteValue
          sec
          sbc missileVelocityXCalc
          sta temp6

          ;; tempCalc = 255 - velocity
          lda temp6
          clc
          adc # 1
          sta missileVelocityXCalc
          ;; velocity = (255 - velocity) + 1 = 256 - velocity (twos
          ;; complement)

          ;; Apply friction damping if friction flag is set

          ;; Reduce velocity by half (bit shift right by 1)
          lda temp5
          and MissileFlagFriction
          cmp # 0
          bne skip_9352
          jmp BounceDone
skip_9352:

          ;; Use bit shift instead of division to avoid complexity
          ;; issues
          ;; Subtraction works for both positive and negative values:
          ;; Positive: velocity - (velocity >> 1) = 0.5 velocity
          ;; (reduces)
          ;; Negative: velocity - (velocity >> 1) = 0.5 velocity
          ;; (reduces magnitude)
          ;; Divide by 2 using bit shift right (LSR) - direct memory
          lda missileVelocityXCalc
          sta temp2
          ;; mode
            lsr temp2
          ;; let missileVelocityXCalc = missileVelocityXCalc - temp2          lda missileVelocityXCalc          sec          sbc temp2          sta missileVelocityXCalc
          lda missileVelocityXCalc
          sec
          sbc temp2
          sta missileVelocityXCalc

          lda missileVelocityXCalc
          sec
          sbc temp2
          sta missileVelocityXCalc

BounceDone
          lda temp1
          asl
          tax
          lda missileVelocityXCalc
          sta missileVelocityX,x

          ;; Continue bouncing (do not deactivate)
          rts
.pend

;; DeactivateMissile .proc (no matching .pend)
          ;;
          ;; Returns: Far (return otherbank)
          ;; Deactivate Missile
          ;; Removes a missile from active sta

          ;;
          INPUT:
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
                    let temp6 = BitMask[temp1]         
          lda temp1
          asl
          tax
          lda BitMask,x
          sta temp6
          ;; let temp6 = MaxByteValue - temp6          lda MaxByteValue          sec          sbc temp6          sta temp6
          lda MaxByteValue
          sec
          sbc temp6
          sta temp6

          lda MaxByteValue
          sec
          sbc temp6
          sta temp6

          ;; Invert bits
          lda missileActive
          and temp6
          sta missileActive
          jsr BS_return


.pend (extra - no matching .proc)

