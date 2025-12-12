;;; ChaosFight - Source/Routines/FallDamage.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CheckFallDamage .proc
          ;; Applies character-specific fall damage when players land
          ;; Returns: Far (return otherbank)
          ;; Inputs: currentPlayer (global) = player index (0-3), temp2 = landing velocity (positive downward)
          ;; currentCharacter (global hint, refreshed internally), playerCharacter[], playerState[], playerHealth[], playerRecoveryFrames[]
          ;; SafeFallVelocityThresholds[], WeightDividedBy20[]
          ;; Outputs: playerHealth[] reduced, playerRecoveryFrames[] set, playerState[] updated, landing SFX queued
          ;; Mutates: temp1-temp4, oldHealthValue, currentCharacter
          ;; Calls: PlaySoundEffect (bank15)
          ;; Constraints: Must remain colocated with fall-damage helpers that reuse temp scratch bytes

          ;; Get character type for this player
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter

          ;; Issue #1178: Bernie post-fall stun - check before immunity
          ;; Bernie is immune to fall damage but still gets stunned from high falls
          lda currentCharacter
          cmp # CharacterBernie
          bne CheckFallDamageImmunity

          jmp CheckBernieStun

CheckFallDamageImmunity:

          ;; Check for fall damage immunity (Frooty, DragonOfStorms)
          jmp BS_return

          ;; Calculate safe fall velocity threshold
          ;; Formula: safe_velocity = 120 ÷ weight
          ;; Use lookup table to avoid variable division
          ;; Pre-computed values in SafeFallVelocityThresholds table
          ;; Set temp3 = SafeFallVelocityThresholds[currentCharacter]
          lda currentCharacter
          asl
          tax
          lda SafeFallVelocityThresholds,x
          sta temp3
          ;; Safe fall velocity threshold

          ;; Check if fall velocity exceeds safe threshold

          ;; Safe landing, no damage
          jmp BS_return

          ;; Check if player is guarding - guard does NOT block fall
          ;; damage
          ;; Guard only blocks attack damage (missiles, AOE), not
          ;; environmental damage
          ;; Fall damage is environmental, so guard does not protect

          ;; Calculate fall damage
          ;; Base damage = (velocity - safe_velocity) ×
          ;; base_damage_multiplier
          ;; Base damage multiplier: 2 (so 1 extra velocity = 2 × base
          ;; damage)
          ;; Set temp4 = temp2 - temp3
          lda temp2
          sec
          sbc temp3
          sta temp4

          ;; Multiply by 2 to double the base damage
          ;; Set temp4 = temp4 * 2
          ;; Apply weight-based damage multiplier: the bigger they
          ;; are, the harder they fall
          ;; Heavy characters take more damage for the same impact
          ;; velocity
          ;; Formula: damage_multiplier = weight / 20 (average weight)
          ;; Using integer math: damage = damage × (weight / 20)
          ;; Use lookup table for weight/20, then multiply by damage
          ;; temp2 = weight / 20 from lookup table
          ;; Apply weight-based damage multiplier (temp2 = 0-5)
          ;; Set temp2 = WeightDividedBy20[currentCharacter]
          lda currentCharacter
          asl
          tax
          lda WeightDividedBy20,x
          sta temp2
          lda temp2
          cmp # 0
          bne CheckWeightMultiplier
          ;; Set temp4 = 0 jmp WeightMultDone
CheckWeightMultiplier:


          ;; temp2 is 2-5: multiply temp4 by temp2 using compact ASM
          lda temp2
          cmp # 1
          bne ApplyWeightMultiplier
          jmp WeightMultDone
ApplyWeightMultiplier:


            lda temp4
                    ldx temp2
            dex
            dex
            beq MultiplyBy2
            dex
            beq MultiplyBy3
            dex
            beq MultiplyBy4
            dex
            beq MultiplyBy5
            sta temp4
            jmp MultiplyDone
MultiplyBy2:

          asl

            sta temp4
            jmp MultiplyDone
MultiplyBy3:

          sta

            asl
            clc
            adc temp3
            sta temp4
            jmp MultiplyDone
MultiplyBy4:

          asl

            asl
            sta temp4
            jmp MultiplyDone
MultiplyBy5:

          sta

            asl
            asl
            clc
            adc temp3
            sta temp4
MultiplyDone:

WeightMultDone:
          ;; temp4 = damage × (weight / 20) (weight-based multiplier applied)
          ;; Returns: Far (return otherbank)

          ;; Apply damage reduction (NinjishGuy, RoboTito: half damage)
          lda currentCharacter
          cmp CharacterNinjishGuy
          bne CheckRoboTitoReduction
          ;; Set temp4 = temp4 / 2          lda temp4          lsr          sta temp4
          lda temp4
          lsr
          sta temp4

          lda temp4
          lsr
          sta temp4

CheckRoboTitoReduction:


          lda currentCharacter
          cmp CharacterRoboTito
          bne CapMaximumDamage
          ;; Set temp4 = temp4 / 2          lda temp4          lsr          sta temp4
          lda temp4
          lsr
          sta temp4

          lda temp4
          lsr
          sta temp4

CapMaximumDamage:


          ;; Cap maximum fall damage at 50
          lda temp4
          cmp # 51
          bcc ApplyFallDamage
          lda # 50
          sta temp4
ApplyFallDamage:


          ;; Apply fall damage (byte-safe clamp)
          ;; Use oldHealthValue for byte-safe clamp check
          ;; Set oldHealthValue = playerHealth[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          sta oldHealthValue
                    let playerHealth[currentPlayer] = playerHealth[currentPlayer] - temp4
                    if playerHealth[currentPlayer] > oldHealthValue then let playerHealth[currentPlayer] = 0
          lda currentPlayer
          asl
          tax
          lda playerHealth,x
          sec
          sbc oldHealthValue
          bcc SetRecoveryFrames
          beq SetRecoveryFrames
          lda currentPlayer
          asl
          tax
          lda # 0
          sta playerHealth,x
SetRecoveryFrames:

          ;; Set recovery frames (damage/2, clamped 10-30)
          ;; Set temp2 = temp4 / 2          lda temp4          lsr          sta temp2
          lda temp4
          lsr
          sta temp2

          lda temp4
          lsr
          sta temp2

          ;; If temp2 < 10, set temp2 = 10
          lda temp2
          cmp # 10
          bcs CheckMaximumRecovery
          jmp let_label
CheckMaximumRecovery:

          lda temp2
          cmp # 10
          bcs ClampRecoveryFrames
          jmp let_label
ClampRecoveryFrames:



          lda temp2
          cmp # 31
          bcc StoreRecoveryFrames
          lda # 30
          sta temp2
StoreRecoveryFrames:


          lda currentPlayer
          asl
          tax
          lda temp2
          sta playerRecoveryFrames,x

          ;; Synchronize playerState bit 3 with recovery frames
                    let playerState[currentPlayer] = playerState[currentPlayer] | 8
          ;; Set bit 3 (recovery flag) when recovery frames are set

          ;; Set animation state to recovering (state 9)
          ;; Set temp2 = playerState[currentPlayer] & MaskPlayerStateLower
          lda currentPlayer
          asl
          tax
          lda playerState,x
          sta temp2
                    let playerState[currentPlayer] = temp2 | MaskAnimationRecovering
          lda SoundLandingDamage
          sta temp1
          ;; Cross-bank call to PlaySoundEffect in bank 15
          lda # >(AfterPlaySoundEffectFallDamage-1)
          pha
          lda # <(AfterPlaySoundEffectFallDamage-1)
          pha
          lda # >(PlaySoundEffect-1)
          pha
          lda # <(PlaySoundEffect-1)
          pha
                    ldx # 14
          jmp BS_jsr
AfterPlaySoundEffectFallDamage:


          jmp BS_return

.pend

CheckBernieStun .proc
          ;; Issue #1178: Bernie post-fall stun animation
          ;; Returns: Far (return otherbank)
          ;; Bernie should enter stunned state after falling far enough to trigger fall damage threshold
          ;; Stays in ’fallen from high’ animation for 1 second (frame-rate independent)
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; temp2 = landing velocity (positive downward)
          ;; SafeFallVelocityThresholds[] (global data table)
          ;;
          ;; Output: playerRecoveryFrames[] set to FramesPerSecond (1 second stun)
          ;; playerState[] updated with recovery flag and fallen animation
          ;;
          ;; Mutates: temp3 (used for threshold lookup)
          ;;
          ;; Called Routines: None
          ;;
          ;; Constraints: Must be colocated with CheckFallDamage
          ;; Check if fall velocity exceeds safe threshold (would trigger fall damage)
          ;; Bernie’s safe fall velocity threshold
          ;; Set temp3 = SafeFallVelocityThresholds[CharacterBernie]
          lda CharacterBernie
          asl
          tax
          lda SafeFallVelocityThresholds,x
          sta temp3
          ;; Safe landing, no stun needed
          jmp BS_return

          ;; Fall velocity exceeds threshold - trigger stun
          ;; Set stun timer to 1 second (frame-rate independent: 60fps NTSC, 50fps PAL/SECAM)
          ;; Set recovery flag to prevent movement during stun
          lda currentPlayer
          asl
          tax
          lda FramesPerSecond
          sta playerRecoveryFrames,x
          ;; Set animation state to ’Fallen down’ (state 8, shifted = 128)
                    let playerState[currentPlayer] = playerState[currentPlayer] | PlayerStateBitRecovery
          ;; Set temp3 = playerState[currentPlayer] & MaskPlayerStateFlags
          lda currentPlayer
          asl
          tax
          lda playerState,x
          sta temp3
          ;; Animation state 8 (Fallen down) << 4 = 128
                    let playerState[currentPlayer] = temp3 | ActionFallenDownShifted
          jmp BS_return

.pend

FallDamageApplyGravity .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Apply Gravity
          ;; Applies gravity acceleration to a player each frame.
          ;; Handles character-specific gravity rates and terminal
          ;; velocity.
          ;;
          INPUT:
          ;; currentPlayer (global) = player index (0-3)
          ;; temp2 = current vertical momentum (positive = down)
          ;;
          OUTPUT:
          ;; temp2 = updated vertical momentum
          ;; Applies gravity acceleration to a player each frame
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; temp2 = current vertical momentum (positive = down)
          ;; playerCharacter[] (global array) = player character
          ;; selections
          ;; TerminalVelocity (constant) = maximum fall velocity
          ;;
          ;; Output: temp2 = updated vertical momentum
          ;;
          ;; Mutates: temp2, temp6, currentCharacter
          ;;
          ;; Called Routines: None
          ;; Constraints: None
          ;; Get character type
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter

          ;; Check for no-gravity characters (Frooty, DragonOfStorms)
          jmp BS_return

          jmp BS_return

          ;; Apply gravity (default 2, Harpy 1)
          lda # 2
          sta temp6
          lda currentCharacter
          cmp CharacterHarpy
          bne ApplyGravityAcceleration
          lda # 1
          sta temp6
ApplyGravityAcceleration:


          ;; Apply gravity acceleration
          ;; Set temp2 = temp2 + temp6
                    if temp2 > TerminalVelocity then let temp2 = TerminalVelocity
          lda temp2
          sec
          sbc TerminalVelocity
          bcc FallDamageApplyGravityDone
          beq FallDamageApplyGravityDone
          lda TerminalVelocity
          sta temp2
FallDamageApplyGravityDone:
          jmp BS_return

CheckGroundCollision:
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Ground Collision
          ;; Checks if player has landed on ground or platform.
          ;; Calls CheckFallDamage if landing detected.
          ;;
          INPUT:
          ;; currentPlayer (global) = player index (0-3)
          ;; temp2 = vertical momentum before position update
          ;; This routine should be called AFTER vertical position
          ;; update
          ;; but BEFORE momentum is cleared, so we can detect the
          ;; landing
          ;; velocity for fall damage calculation.
          ;; Checks if player has landed on ground or platform
          ;;
          ;; Input: currentPlayer (global) = player index (0-3)
          ;; temp2 = vertical momentum before position update
          ;; playerY[] (global array) = player Y positions
          ;;
          ;; Output: playerY[] clamped to ground if landed,
          ;; CheckFallDamage called if moving downward
          ;;
          ;; Mutates: temp2, temp3 (used for calculations),
          ;; playerY[] (clamped to 176 if landed), currentCharacter
          ;;
          ;; Called Routines: CheckFallDamage - accesses currentPlayer, temp2,
          ;; playerCharacter[], playerHealth[],
          ;; playerRecoveryFrames[], playerState[], PlaySoundEffect
          ;; (bank15)
          ;;
          ;; Constraints: Tail call to CheckFallDamage
          ;; Should be called AFTER vertical position
          ;; update but BEFORE momentum is cleared
          lda temp1
          sta currentPlayer
                    ;; Set currentCharacter = playerCharacter[currentPlayer]
                    lda currentPlayer          asl          tax          lda playerCharacter,x          sta currentCharacter
          ;; Get player Y position
          ;; Set temp3 = playerY[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp3
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta temp3

          jmp BS_return

          lda currentPlayer
          asl
          tax
          lda # 176
          sta playerY,x
          jmp BS_return

          jmp CheckFallDamage

.pend

HandleFrootyVertical .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Handle Frooty Vertical Control
          ;; Frooty has no gravity and can move up/down freely.
          ;; Down button moves down (no guard action).
          ;;
          INPUT:
          ;; currentPlayer (global) = player index (0-3, but should only be called for
          ;; Frooty)
          ;; This should be called from PlayerInput.bas when processing
          ;; joystick up/down for Frooty.
          lda temp1
          sta currentPlayer
          ;; Check character type to confirm
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda currentCharacter
          cmp CharacterFrooty
          bne HandleFrootyVerticalDone
          jmp FrootyFallDamage
HandleFrootyVerticalDone:


          jmp BS_return

.pend

FrootyFallDamage .proc
          ;; Frooty fall damage
          ;; Returns: Far (return otherbank)

          ;; Get joystick sta

          ;; This needs to be integrated with PlayerInput.bas
          ;; Fall damage calculation based on character weight

          If joyup pressed: move up
          ;; playerY[currentPlayer] = playerY[currentPlayer] - 2

          If joydown pressed: move down (replaces guard action)
          ;; playerY[currentPlayer] = playerY[currentPlayer] + 2

          ;; Clamp to screen bounds
          ;; Byte-safe clamp: if wrapped below 0, the new value will
          ;; exceed the old
          ;; Set oldHealthValue = playerY[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sta oldHealthValue
          ;; Reuse oldHealthValue for byte-safe clamp check (not
          ;; actually health, but same pattern)
                    if playerY[currentPlayer] > oldHealthValue then let playerY[currentPlayer] = 0

                    if playerY[currentPlayer] > 176 then let playerY[currentPlayer] = 176
          lda currentPlayer
          asl
          tax
          lda playerY,x
          sec
          sbc # 176
          bcc FrootyFallDamageDone
          beq FrootyFallDamageDone
          lda # 176
          sta playerY,x
FrootyFallDamageDone:
          jmp BS_return

.pend

HandleHarpySwoopAttack .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Handle Harpy Swoop Attack
          ;; Harpy attack causes an instant redirection into a rapid
          ;; downward diagonal strike at ~45° to the facing direction.
          ;;
          INPUT:
          ;; currentPlayer (global) = player index (0-3, but should only be called for
          ;; Harpy)
          ;;
          OUTPUT:
          ;; Sets player momentum for diagonal downward swoop
          lda temp1
          sta currentPlayer
          ;; Check character type to confirm
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda currentCharacter
          cmp CharacterHarpy
          bne HandleHarpySwoopAttackDone
          jmp HarpyDive
HandleHarpySwoopAttackDone:


          jmp BS_return

.pend

HarpyDive .proc
          ;; Harpy dive
          ;; Returns: Far (return otherbank)

          ;; Get facing direction from playerState bit 0
          ;; Set temp6 = playerState[currentPlayer] & PlayerStateBitFacing
          lda currentPlayer
          asl
          tax
          lda playerState,x
          sta temp6

          ;; Set diagonal momentum at ~45° angle
          ;; Horizontal: 4 pixels/frame (in facing direction)
          ;; Vertical: 4 pixels/frame (downward)
          ;; Facing left: set negative momentum (252 = -4 in signed
          lda temp6
          cmp # 0
          bne SetHorizontalMomentumRight
          jmp SetHorizontalMomentumRight
SetHorizontalMomentumRight:


          ;; 8-bit)
          lda currentPlayer
          asl
          tax
          lda # 252
          sta playerVelocityX,x
          jmp SetVerticalMomentum

SetHorizontalMomentumRight:
          ;; Facing right: set positive momentum
          ;; Returns: Far (return otherbank)
          lda currentPlayer
          asl
          tax
          lda # 4
          sta playerVelocityX,x

.pend

SetVerticalMomentum .proc
          ;; Set downward momentum (using temp variable for now)
          ;; Returns: Far (return otherbank)
          ;; Integrate with vertical momentum system
          ;; This is handled by PlayerPhysicsGravity.bas
          ;; This needs to override normal gravity temporarily
          ;; Suggest adding PlayerMomentumY variable or state flag

          ;; Set animation state to swooping attack
          ;; This could be animation state 10 or special attack
          ;; animation
          ;; Set temp6 = playerState[currentPlayer] & MaskPlayerStateLower
          lda currentPlayer
          asl
          tax
          lda playerState,x
          sta temp6
          lda temp6
          ora MaskAnimationFalling
          sta temp6
          ;; Animation state 10
          lda currentPlayer
          asl
          tax
          lda temp6
          sta playerState,x

          ;; Spawn mêlée attack missile for swoop hit detection
          lda currentPlayer
          sta temp1
          ;; Cross-bank call to SpawnMissile in bank 7
          lda # >(AfterSpawnMissileHarpy-1)
          pha
          lda # <(AfterSpawnMissileHarpy-1)
          pha
          lda # >(SpawnMissile-1)
          pha
          lda # <(SpawnMissile-1)
          pha
                    ldx # 6
          jmp BS_jsr
AfterSpawnMissileHarpy:


          jmp BS_return

.pend

DivideBy20 .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Division/multiplication HELPERS (no Mul/div Support)
          ;; Helper routines using optimized assembly for fast
          ;; division/multiplication
          ;; Based on Omegamatrix’s optimized 6502 routines from
          ;; AtariAge forums
          ;; These routines use bit manipulation and carry-based
          ;; arithmetic for speed
          ;; Thanks to Omegamatrix and AtariAge forum contributors for
          ;; these routines
          ;; TODO: #1311 ; rem DivideBy20: compute floor(A / 20) using optimized assembly
          ;; TODO: #1311 ; rem
          ;; TODO: #1311 ; rem INPUT: A register = dividend (temp2)
          ;; TODO: #1311 ; rem
          ;; TODO: #1311 ; rem OUTPUT: A register = quotient (result in temp2)
          ;; TODO: #1311 ; rem Uses 18 bytes, 32 cycles
            lda temp2
            lsr
            lsr
            sta temp6
            lsr
            adc temp6
            ror
            lsr
            lsr
            adc temp6
            ror
            adc temp6
            ror
            lsr
            lsr
            sta temp2
          jmp BS_return

.pend

DivideBy100 .proc
          ;; DivideBy100: compute floor(temp2 ÷ 100) using range check
          ;; Returns: Far (return otherbank)
          ;;
          ;; INPUT: temp2 = dividend
          ;;
          ;; OUTPUT: temp2 = quotient (0, 1, or 2)
          ;; Fast approximation for values 0-255
          jmp BS_return

          jmp BS_return

          lda # 0
          sta temp2
          jmp BS_return

.pend

CalculateSafeFallDistance .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Calculate Safe Fall Dista

          ;; Utility routine to calculate safe fall distance for a
          ;; character.
          ;; Used for AI and display purposes.
          ;;
          INPUT:
          ;; currentPlayer (global) = player index (0-3)
          ;;
          OUTPUT:
          ;; temp2 = safe fall distance in pixels
          ;; Get character type and weight
          lda temp1
          sta currentPlayer
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter

          ;; Check for fall damage immunity
          lda currentCharacter
          cmp CharacterBernie
          bne CheckRoboTitoImmunity
          jmp SetInfiniteFallDista

CheckRoboTitoImmunity:


          lda currentCharacter
          cmp CharacterRoboTito
          bne CheckFrootyImmunity
          jmp SetInfiniteFallDista

CheckFrootyImmunity:


          lda currentCharacter
          cmp CharacterFrooty
          bne CheckDragonOfStormsImmunity
          jmp SetInfiniteFallDista

CheckDragonOfStormsImmunity:


          lda currentCharacter
          cmp CharacterDragonOfStorms
          bne CalculateFallDistanceNormal
          jmp SetInfiniteFallDista

CalculateFallDistanceNormal:


          jmp CalculateFallDistanceNormal

.pend

SetInfiniteFallDistance .proc
          lda InfiniteFallDista

          sta temp2
          jmp BS_return

.pend

CalculateFallDistanceNormal .proc
                    ;; Set temp3 = SafeFallVelocityThresholds[currentCharacter]
                    lda currentCharacter          asl          tax          lda SafeFallVelocityThresholds,x          sta temp3
          lda temp3
          sec
          sbc # 1
          sta temp4
          ;; Set temp2 = SquareTable[temp4]
          lda temp4
          asl
          tax
          lda SquareTable,x
          sta temp2
          lda temp4
          asl
          tax
          lda SquareTable,x
          sta temp2
            lsr temp2
            lsr temp2
          lda currentCharacter
          cmp CharacterNinjishGuy
          bne CalculateFallDistanceNormalDone
          ;; Set temp2 = temp2 * 2
CalculateFallDistanceNormalDone:

          jmp BS_return

.pend

