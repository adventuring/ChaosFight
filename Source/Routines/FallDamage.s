;;; ChaosFight - Source/Routines/FallDamage.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CheckFallDamage .block
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
          lda currentPlayer
          tax
          lda playerCharacter,x
          sta currentCharacter

          ;; Issue #1178: Bernie post-fall stun - check before immunity
          lda currentCharacter
          cmp # CharacterBernie
          bne CheckFallDamageImmunity
          jmp CheckBernieStun

CheckFallDamageImmunity:
          ;; Check for fall damage immunity (Frooty, DragonOfStorms)
          lda currentCharacter
          cmp # CharacterFrooty
          beq _ret_fd1
          lda currentCharacter
          cmp # CharacterDragonOfStorms
          beq _ret_fd1
_ret_fd1:
          jmp BS_return

          ;; Calculate safe fall velocity threshold
          lda currentCharacter
          tax
          lda SafeFallVelocityThresholds,x
          sta temp3

          ;; Check if fall velocity exceeds safe threshold
          lda temp2
          cmp temp3
          bcc _ret_fd2
          beq _ret_fd2
_ret_fd2:
          jmp BS_return

          ;; Calculate safe fall velocity threshold
          ;; Formula: safe_velocity = 120 ÷ weight
          ;; Use lookup table to avoid variable division
          ;; Pre-computed values in SafeFallVelocityThresholds table
          ;; Set temp3 = SafeFallVelocityThresholds[currentCharacter]
          lda currentCharacter
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
          lda temp4
          asl
          sta temp4

          ;; Apply weight-based damage multiplier
          lda currentCharacter
          tax
          lda WeightDividedBy20,x
          sta temp2
          lda temp2
          beq _zero_weight
          cmp # 1
          beq WeightMultDone
          jmp ApplyWeightMultiplier

_zero_weight:
          lda # 0
          sta temp4
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
          sta temp3
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
          sta temp3
          asl
          asl
          clc
          adc temp3
          sta temp4
MultiplyDone:

WeightMultDone:
          ;; Apply damage reduction (NinjishGuy, RoboTito: half damage)
          lda currentCharacter
          cmp # CharacterNinjishGuy
          bne CheckRoboTitoReduction
          lda temp4
          lsr
          sta temp4

CheckRoboTitoReduction:
          lda currentCharacter
          cmp # CharacterRoboTito
          bne CapMaximumDamage
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
          lda currentPlayer
          tax
          lda playerHealth,x
          sta oldHealthValue
          ;; Subtract damage
          sec
          sbc temp4
          bcc _damage_overflow
          sta playerHealth,x
          jmp SetRecoveryFrames
_damage_overflow:
          lda # 0
          sta playerHealth,x
SetRecoveryFrames:

          ;; Set recovery frames (damage/2, clamped 10-30)
          lda temp4
          lsr
          sta temp2

          lda temp2
          cmp # 10
          bcs CheckMaximumRecovery
          lda # 10
          sta temp2
          jmp ClampRecoveryFrames

CheckMaximumRecovery:
          lda temp2
          cmp # 31
          bcc StoreRecoveryFrames
          lda # 30
          sta temp2

ClampRecoveryFrames:
StoreRecoveryFrames:
          lda currentPlayer
          tax
          lda temp2
          sta playerRecoveryFrames,x

          ;; Synchronize playerState bit 3 with recovery frames
          lda currentPlayer
          tax
          lda playerState,x
          ora # 8
          sta playerState,x

          ;; Set animation state to recovering (state 9)
          lda currentPlayer
          tax
          lda playerState,x
          and #MaskPlayerStateLower
          ora #MaskAnimationRecovering
          sta playerState,x
          lda # SoundLandingDamage
          sta temp1
          ;; Cross-bank call to PlaySoundEffect in bank 14
          lda # ((>(AfterPlaySoundEffectFallDamage-1)) & $0f) | $70
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



.bend

CheckBernieStun .block
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
          lda # CharacterBernie
          tax
          lda SafeFallVelocityThresholds,x
          sta temp3
          ;; Safe landing, no stun needed
          lda temp2
          cmp temp3
          bcc _bernie_return
          beq _bernie_return
          jmp _bernie_stun

_bernie_return:
          jmp BS_return

_bernie_stun:

          ;; Fall velocity exceeds threshold - trigger stun
          ;; Set stun timer to 1 second (frame-rate independent: 60fps NTSC, 50fps PAL/SECAM)
          ;; Set recovery flag to prevent movement during stun
          lda currentPlayer
          tax
          lda #FramesPerSecond
          sta playerRecoveryFrames,x
          ;; Set animation state to ’Fallen down’ (state 8, shifted = 128)
          lda currentPlayer
          tax
          lda playerState,x
          ora # PlayerStateBitRecovery
          sta playerState,x
          ;; Set temp3 = playerState[currentPlayer] & MaskPlayerStateFlags
          lda currentPlayer
          tax
          lda playerState,x
          and # MaskPlayerStateFlags
          ora # ActionFallenDownShifted
          sta playerState,x
          jmp BS_return

.bend

FallDamageApplyGravity .block
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
          cmp # CharacterHarpy
          bne ApplyGravityAcceleration
          lda # 1
          sta temp6
ApplyGravityAcceleration:
          clc
          lda temp2
          adc temp6
          sta temp2
          cmp # TerminalVelocity
          bcc FallDamageApplyGravityDone
          beq FallDamageApplyGravityDone
          lda # TerminalVelocity
          sta temp2
FallDamageApplyGravityDone:
          jmp BS_return

CheckGroundCollision:
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Ground Collision
          ;; Checks if player has landed on ground or platform.
          ;; Calls CheckFallDamage if landing detected.
          lda temp1
          sta currentPlayer
          lda currentPlayer
          tax
          lda playerCharacter,x
          sta currentCharacter
          ;; Get player Y position
          lda currentPlayer
          tax
          lda playerY,x
          sta temp3

          jmp BS_return

          lda currentPlayer
          tax
          lda # 176
          sta playerY,x
          jmp BS_return

          jmp CheckFallDamage

.bend

HandleFrootyVertical .block
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
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda currentCharacter
          cmp # CharacterFrooty
          bne HandleFrootyVerticalDone
          jmp FrootyFallDamage
HandleFrootyVerticalDone:


          jmp BS_return

.bend

FrootyFallDamage .block
          ;; Frooty fall damage
          ;; Returns: Far (return otherbank)

          ;; Clamp to screen bounds
          ;; Byte-safe clamp: if wrapped below 0, the new value will
          ;; exceed the old
          lda currentPlayer
          tax
          lda playerY,x
          sta oldHealthValue
          ;; Handle vertical movement if needed (from input context) - simplified
          ;; Clamp to screen bounds
          lda currentPlayer
          tax
          lda playerY,x
          cmp # 176
          bcc _frooty_ok_upper
          lda # 176
          sta playerY,x
_frooty_ok_upper:
          ;; already clamped above if needed
FrootyFallDamageDone:
          jmp BS_return

.bend

HandleHarpySwoopAttack .block
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
          tax
          lda playerCharacter,x
          sta currentCharacter
          lda currentCharacter
          cmp # CharacterHarpy
          bne HandleHarpySwoopAttackDone
          jmp HarpyDive
HandleHarpySwoopAttackDone:


          jmp BS_return

.bend

HarpyDive .block
          ;; Harpy dive
          ;; Returns: Far (return otherbank)

          ;; Get facing direction from playerState bit 0
          ;; Set temp6 = playerState[currentPlayer] & PlayerStateBitFacing
          lda currentPlayer
          tax
          lda playerState,x
          sta temp6

          ;; Set diagonal momentum at ~45° angle
          ;; Horizontal: 4 pixels/frame (in facing direction)
          ;; Vertical: 4 pixels/frame (downward)
          ;; Facing left: set negative momentum (252 = -4 in signed
          lda temp6
          bne SetHorizontalMomentumRight
          ;; Facing left
          lda currentPlayer
          tax
          lda # 252
          sta playerVelocityX,x
          jmp SetVerticalMomentum

SetHorizontalMomentumRight:
          ;; Facing right
          lda currentPlayer
          tax
          lda # 4
          sta playerVelocityX,x

.bend

SetVerticalMomentum .block
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
          tax
          lda playerState,x
          sta temp6
          lda temp6
          ora #MaskAnimationFalling
          sta temp6
          ;; Animation state 10
          lda currentPlayer
          tax
          lda temp6
          sta playerState,x

          ;; Spawn mêlée attack missile for swoop hit detection
          lda currentPlayer
          sta temp1
          ;; Cross-bank call to SpawnMissile in bank 6
          ;; Return address: ENCODED with caller bank 7 ($70) for BS_return to decode
          lda # ((>(AfterSpawnMissileHarpy-1)) & $0f) | $70
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

.bend

DivideBy20 .block
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
          ;; DivideBy20: compute floor(A / 20) using optimized assembly
          ;;
          ;; INPUT: A register = dividend (temp2)
          ;;
          ;; OUTPUT: A register = quotient (result in temp2)
          ;; Uses 18 bytes, 32 cycles
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

.bend

CalculateSafeFallDistance .block
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
          tax
          lda playerCharacter,x
          sta currentCharacter

          ;; Check for fall damage immunity
          lda currentCharacter
          cmp # CharacterBernie
          bne CheckRoboTitoImmunity
          jmp SetInfiniteFallDistance

CheckRoboTitoImmunity:
          lda currentCharacter
          cmp # CharacterRoboTito
          bne CheckFrootyImmunity
          jmp SetInfiniteFallDistance

CheckFrootyImmunity:
          lda currentCharacter
          cmp # CharacterFrooty
          bne CheckDragonOfStormsImmunity
          jmp SetInfiniteFallDistance

CheckDragonOfStormsImmunity:
          lda currentCharacter
          cmp # CharacterDragonOfStorms
          bne CalculateFallDistanceNormal
          jmp SetInfiniteFallDistance

CalculateFallDistanceNormal:


          jmp CalculateFallDistanceNormal

.bend

SetInfiniteFallDistance .block
          lda # InfiniteFallDistance
          sta temp2
          jmp BS_return

.bend

CalculateFallDistanceNormal .block
          lda currentCharacter
          tax
          lda SafeFallVelocityThresholds,x
          sta temp3
          lda temp3
          sec
          sbc # 1
          sta temp4
          lda temp4
          tax
          lda SquareTable,x
          sta temp2
          lsr temp2
          lsr temp2
          lda currentCharacter
          cmp # CharacterNinjishGuy
          bne CalculateFallDistanceNormalDone
          asl temp2
CalculateFallDistanceNormalDone:
          jmp BS_return

.bend

