;;; ChaosFight - Source/Routines/FallDamage.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


CheckFallDamage .proc
;;; Applies character-specific fall damage when players land
          ;; Returns: Far (return otherbank)
          ;; Inputs: currentPlayer (global) = player index (0-3), temp2 = landing velocity (positive downward)
          ;; currentCharacter (global hint, refreshed internally), playerCharacter[], playerState[], playerHealth[], playerRecoveryFrames[]
          ;; SafeFallVelocityThresholds[], WeightDividedBy20[]
          ;; Outputs: playerHealth[] reduced, playerRecoveryFrames[] set, playerState[] updated, landing SFX queued
          ;; Mutates: temp1-temp4, oldHealthValue, currentCharacter
          ;; Calls: PlaySoundEffect (bank15)
          ;; Constraints: Must remain colocated with fall-damage helpers that reuse temp scratch bytes

          ;; Get character type for this player
                    ;; let currentCharacter = playerCharacter[currentPlayer]         
          lda currentPlayer
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          sta currentCharacter

          ;; Issue #1178: Bernie post-fall stun - check before immunity
          ;; Bernie is immune to fall damage but still gets stunned from high falls
          ;; lda currentCharacter (duplicate)
          cmp CharacterBernie
          bne skip_9340
          jmp CheckBernieStun
skip_9340:


          ;; Check for fall damage immunity (Frooty, DragonOfStorms)
          jsr BS_return

          ;; jsr BS_return (duplicate)

          ;; Calculate safe fall velocity threshold
          ;; Formula: safe_velocity = 120 ÷ weight
          ;; Use lookup table to avoid variable division
          ;; Pre-computed values in SafeFallVelocityThresholds table
                    ;; let temp3 = SafeFallVelocityThresholds[currentCharacter]         
          ;; lda currentCharacter (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SafeFallVelocityThresholds,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; Safe fall velocity threshold

          ;; Check if fall velocity exceeds safe threshold

          ;; Safe landing, no damage
          ;; jsr BS_return (duplicate)

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
          ;; ;; let temp4 = temp2 - temp3          lda temp2          sec          sbc temp3          sta temp4
          ;; lda temp2 (duplicate)
          sec
          sbc temp3
          ;; sta temp4 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp3 (duplicate)
          ;; sta temp4 (duplicate)

          ;; Multiply by 2 to double the base damage
                    ;; let temp4 = temp4 * 2

          ;; Apply weight-based damage multiplier: the bigger they
          ;; are, the harder they fall
          ;; Heavy characters take more damage for the same impact
          ;; velocity
          ;; Formula: damage_multiplier = weight / 20 (average weight)
          ;; Using integer math: damage = damage × (weight / 20)
          ;; Use lookup table for weight/20, then multiply by damage
          ;; temp2 = weight / 20 from lookup table
          ;; Apply weight-based damage multiplier (temp2 = 0-5)
                    ;; let temp2 = WeightDividedBy20[currentCharacter]         
          ;; lda currentCharacter (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda WeightDividedBy20,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_7704 (duplicate)
                    ;; let temp4 = 0 : goto WeightMultDone
skip_7704:


          ;; temp2 is 2-5: multiply temp4 by temp2 using compact ASM
          ;; lda temp2 (duplicate)
          ;; cmp # 1 (duplicate)
          ;; bne skip_6573 (duplicate)
          ;; jmp WeightMultDone (duplicate)
skip_6573:


            ;; lda temp4 (duplicate)
                    ldx temp2
            dex
            ;; dex (duplicate)
            beq mult2
            ;; dex (duplicate)
            ;; beq mult3 (duplicate)
            ;; dex (duplicate)
            ;; beq mult4 (duplicate)
            ;; dex (duplicate)
            ;; beq mult5 (duplicate)
            ;; sta temp4 (duplicate)
            ;; jmp multdone (duplicate)
mult2:

          ;; asl (duplicate)

            ;; sta temp4 (duplicate)
            ;; jmp multdone (duplicate)
mult3:

          ;; sta (duplicate)

            ;; asl (duplicate)
            clc
            adc temp3
            ;; sta temp4 (duplicate)
            ;; jmp multdone (duplicate)
mult4:

          ;; asl (duplicate)

            ;; asl (duplicate)
            ;; sta temp4 (duplicate)
            ;; jmp multdone (duplicate)
mult5:

          ;; sta (duplicate)

            ;; asl (duplicate)
            ;; asl (duplicate)
            ;; clc (duplicate)
            ;; adc temp3 (duplicate)
            ;; sta temp4 (duplicate)
multdone:

WeightMultDone
          ;; temp4 = damage × (weight / 20) (weight-based multiplier applied)
          ;; Returns: Far (return otherbank)

          ;; Apply damage reduction (NinjishGuy, RoboTito: half damage)
          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterNinjishGuy (duplicate)
          ;; bne skip_7713 (duplicate)
          ;; ;; let temp4 = temp4 / 2          lda temp4          lsr          sta temp4
          ;; lda temp4 (duplicate)
          lsr
          ;; sta temp4 (duplicate)

          ;; lda temp4 (duplicate)
          ;; lsr (duplicate)
          ;; sta temp4 (duplicate)

skip_7713:


          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_2723 (duplicate)
          ;; ;; let temp4 = temp4 / 2          lda temp4          lsr          sta temp4
          ;; lda temp4 (duplicate)
          ;; lsr (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp4 (duplicate)
          ;; lsr (duplicate)
          ;; sta temp4 (duplicate)

skip_2723:


          ;; Cap maximum fall damage at 50
          ;; lda temp4 (duplicate)
          ;; cmp # 51 (duplicate)
          bcc skip_6992
          ;; lda # 50 (duplicate)
          ;; sta temp4 (duplicate)
skip_6992:


          ;; Apply fall damage (byte-safe clamp)
          ;; Use oldHealthValue for byte-safe clamp check
                    ;; let oldHealthValue = playerHealth[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sta oldHealthValue (duplicate)
                    ;; let playerHealth[currentPlayer] = playerHealth[currentPlayer] - temp4
                    ;; if playerHealth[currentPlayer] > oldHealthValue then let playerHealth[currentPlayer] = 0
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; sec (duplicate)
          ;; sbc oldHealthValue (duplicate)
          ;; bcc skip_819 (duplicate)
          ;; beq skip_819 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta playerHealth,x (duplicate)
skip_819:

          ;; Set recovery frames (damage/2, clamped 10-30)
          ;; ;; let temp2 = temp4 / 2          lda temp4          lsr          sta temp2
          ;; lda temp4 (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp4 (duplicate)
          ;; lsr (duplicate)
          ;; sta temp2 (duplicate)

          ;; ;; if temp2 < 10 then let temp2 = 10
          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          bcs skip_1297
          ;; jmp let_label (duplicate)
skip_1297:

          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcs skip_425 (duplicate)
          ;; jmp let_label (duplicate)
skip_425:



          ;; lda temp2 (duplicate)
          ;; cmp # 31 (duplicate)
          ;; bcc skip_1266 (duplicate)
          ;; lda # 30 (duplicate)
          ;; sta temp2 (duplicate)
skip_1266:


          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerRecoveryFrames,x (duplicate)

          ;; Synchronize playerState bit 3 with recovery frames
                    ;; let playerState[currentPlayer] = playerState[currentPlayer] | 8
          ;; Set bit 3 (recovery flag) when recovery frames are set

          ;; Set animation state to recovering (state 9)
                    ;; let temp2 = playerState[currentPlayer] & MaskPlayerStateLower         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)
                    ;; let playerState[currentPlayer] = temp2 | MaskAnimationRecovering
          ;; lda SoundLandingDamage (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to PlaySoundEffect in bank 15
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlaySoundEffect-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 14 (duplicate)
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; jsr BS_return (duplicate)

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
                    ;; let temp3 = SafeFallVelocityThresholds[CharacterBernie]         
          ;; lda CharacterBernie (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SafeFallVelocityThresholds,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; Safe landing, no stun needed
          ;; jsr BS_return (duplicate)

          ;; Fall velocity exceeds threshold - trigger stun
          ;; Set stun timer to 1 second (frame-rate independent: 60fps NTSC, 50fps PAL/SECAM)
          ;; Set recovery flag to prevent movement during stun
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda FramesPerSecond (duplicate)
          ;; sta playerRecoveryFrames,x (duplicate)
          ;; Set animation state to ’Fallen down’ (state 8, shifted = 128)
                    ;; let playerState[currentPlayer] = playerState[currentPlayer] | PlayerStateBitRecovery
                    ;; let temp3 = playerState[currentPlayer] & MaskPlayerStateFlags         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; Animation state 8 (Fallen down) << 4 = 128
                    ;; let playerState[currentPlayer] = temp3 | ActionFallenDownShifted
          ;; jsr BS_return (duplicate)

.pend

FallDamageApplyGravity .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Apply Gravity
          ;; Applies gravity acceleration to a player each frame.
          ;; Handles character-specific gravity rates and terminal
          ;; velocity.
          ;;
          ;; INPUT:
          ;; currentPlayer (global) = player index (0-3)
          ;; temp2 = current vertical momentum (positive = down)
          ;;
          ;; OUTPUT:
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
                    ;; let currentCharacter = playerCharacter[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)

          ;; Check for no-gravity characters (Frooty, DragonOfStorms)
          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; Apply gravity (default 2, Harpy 1)
          ;; lda # 2 (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_8668 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta temp6 (duplicate)
skip_8668:


          ;; Apply gravity acceleration
                    ;; let temp2 = temp2 + temp6

                    ;; if temp2 > TerminalVelocity then let temp2 = TerminalVelocity
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc TerminalVelocity (duplicate)
          ;; bcc skip_2372 (duplicate)
          ;; beq skip_2372 (duplicate)
          ;; lda TerminalVelocity (duplicate)
          ;; sta temp2 (duplicate)
skip_2372:
          ;; jsr BS_return (duplicate)

CheckGroundCollision
          ;;
          ;; Returns: Far (return otherbank)
          ;; Check Ground Collision
          ;; Checks if player has landed on ground or platform.
          ;; Calls CheckFallDamage if landing detected.
          ;;
          ;; INPUT:
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
          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)
                    ;; let currentCharacter = playerCharacter[currentPlayer]          lda currentPlayer          asl          tax          lda playerCharacter,x          sta currentCharacter
          ;; Get player Y position
                    ;; let temp3 = playerY[currentPlayer]
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; jsr BS_return (duplicate)

          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 176 (duplicate)
          ;; sta playerY,x (duplicate)
          ;; jsr BS_return (duplicate)

          ;; jmp CheckFallDamage (duplicate)

.pend

HandleFrootyVertical .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Handle Frooty Vertical Control
          ;; Frooty has no gravity and can move up/down freely.
          ;; Down button moves down (no guard action).
          ;;
          ;; INPUT:
          ;; currentPlayer (global) = player index (0-3, but should only be called for
          ;; Frooty)
          ;; This should be called from PlayerInput.bas when processing
          ;; joystick up/down for Frooty.
          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; Check character type to confirm
                    ;; let currentCharacter = playerCharacter[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_155 (duplicate)
          ;; jmp FrootyFallDamage (duplicate)
skip_155:


          ;; jsr BS_return (duplicate)

.pend

FrootyFallDamage .proc
          ;; Frooty fall damage
          ;; Returns: Far (return otherbank)

          ;; Get joystick sta

          ;; This needs to be integrated with PlayerInput.bas
          ;; Fall damage calculation based on character weight

          ;; If joyup pressed: move up
          ;; playerY[currentPlayer] = playerY[currentPlayer] - 2

          ;; If joydown pressed: move down (replaces guard action)
          ;; playerY[currentPlayer] = playerY[currentPlayer] + 2

          ;; Clamp to screen bounds
          ;; Byte-safe clamp: if wrapped below 0, the new value will
          ;; exceed the old
                    ;; let oldHealthValue = playerY[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta oldHealthValue (duplicate)
          ;; Reuse oldHealthValue for byte-safe clamp check (not
          ;; actually health, but same pattern)
                    ;; if playerY[currentPlayer] > oldHealthValue then let playerY[currentPlayer] = 0

                    ;; if playerY[currentPlayer] > 176 then let playerY[currentPlayer] = 176
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 176 (duplicate)
          ;; bcc skip_1739 (duplicate)
          ;; beq skip_1739 (duplicate)
          ;; lda 176 (duplicate)
          ;; sta playerY,x (duplicate)
skip_1739:
          ;; jsr BS_return (duplicate)

.pend

HandleHarpySwoopAttack .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Handle Harpy Swoop Attack
          ;; Harpy attack causes an instant redirection into a rapid
          ;; downward diagonal strike at ~45° to the facing direction.
          ;;
          ;; INPUT:
          ;; currentPlayer (global) = player index (0-3, but should only be called for
          ;; Harpy)
          ;;
          ;; OUTPUT:
          ;; Sets player momentum for diagonal downward swoop
          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)
          ;; Check character type to confirm
                    ;; let currentCharacter = playerCharacter[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)
          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterHarpy (duplicate)
          ;; bne skip_6023 (duplicate)
          ;; jmp HarpyDive (duplicate)
skip_6023:


          ;; jsr BS_return (duplicate)

.pend

HarpyDive .proc
          ;; Harpy dive
          ;; Returns: Far (return otherbank)

          ;; Get facing direction from playerState bit 0
                    ;; let temp6 = playerState[currentPlayer] & PlayerStateBitFacing         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp6 (duplicate)

          ;; Set diagonal momentum at ~45° angle
          ;; Horizontal: 4 pixels/frame (in facing direction)
          ;; Vertical: 4 pixels/frame (downward)
          ;; Facing left: set negative momentum (252 = -4 in signed
          ;; lda temp6 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_9112 (duplicate)
          ;; jmp SetHorizontalMomentumRight (duplicate)
skip_9112:


          ;; 8-bit)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 252 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; jmp SetVerticalMomentum (duplicate)

SetHorizontalMomentumRight
          ;; Facing right: set positive momentum
          ;; Returns: Far (return otherbank)
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 4 (duplicate)
          ;; sta playerVelocityX,x (duplicate)

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
                    ;; let temp6 = playerState[currentPlayer] & MaskPlayerStateLower         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
          ora MaskAnimationFalling
          ;; sta temp6 (duplicate)
          ;; Animation state 10
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta playerState,x (duplicate)

          ;; Spawn mêlée attack missile for swoop hit detection
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
          ;; Cross-bank call to SpawnMissile in bank 7
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(SpawnMissile-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(SpawnMissile-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 6 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; jsr BS_return (duplicate)

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
          ;; TODO: ; rem DivideBy20: compute floor(A / 20) using optimized assembly
          ;; TODO: ; rem
          ;; TODO: ; rem INPUT: A register = dividend (temp2)
          ;; TODO: ; rem
          ;; TODO: ; rem OUTPUT: A register = quotient (result in temp2)
          ;; TODO: ; rem Uses 18 bytes, 32 cycles
            ;; lda temp2 (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta temp6 (duplicate)
            ;; lsr (duplicate)
            ;; adc temp6 (duplicate)
            ror
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; adc temp6 (duplicate)
            ;; ror (duplicate)
            ;; adc temp6 (duplicate)
            ;; ror (duplicate)
            ;; lsr (duplicate)
            ;; lsr (duplicate)
            ;; sta temp2 (duplicate)
          ;; jsr BS_return (duplicate)

.pend

DivideBy100 .proc
          ;; DivideBy100: compute floor(temp2 ÷ 100) using range check
          ;; Returns: Far (return otherbank)
          ;;
          ;; INPUT: temp2 = dividend
          ;;
          ;; OUTPUT: temp2 = quotient (0, 1, or 2)
          ;; Fast approximation for values 0-255
          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)

          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; jsr BS_return (duplicate)

.pend

CalculateSafeFallDistance .proc
          ;;
          ;; Returns: Far (return otherbank)
          ;; Calculate Safe Fall Dista

          ;; Utility routine to calculate safe fall distance for a
          ;; character.
          ;; Used for AI and display purposes.
          ;;
          ;; INPUT:
          ;; currentPlayer (global) = player index (0-3)
          ;;
          ;; OUTPUT:
          ;; temp2 = safe fall distance in pixels
          ;; Get character type and weight
          ;; lda temp1 (duplicate)
          ;; sta currentPlayer (duplicate)
                    ;; let currentCharacter = playerCharacter[currentPlayer]         
          ;; lda currentPlayer (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta currentCharacter (duplicate)

          ;; Check for fall damage immunity
          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterBernie (duplicate)
          ;; bne skip_5834 (duplicate)
          ;; jmp SetInfiniteFallDista (duplicate)

skip_5834:


          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterRoboTito (duplicate)
          ;; bne skip_8991 (duplicate)
          ;; jmp SetInfiniteFallDista (duplicate)

skip_8991:


          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterFrooty (duplicate)
          ;; bne skip_9478 (duplicate)
          ;; jmp SetInfiniteFallDista (duplicate)

skip_9478:


          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterDragonOfStorms (duplicate)
          ;; bne skip_6876 (duplicate)
          ;; jmp SetInfiniteFallDista (duplicate)

skip_6876:


          ;; jmp CalculateFallDistanceNormal (duplicate)

.pend

SetInfiniteFallDistance .proc
          ;; lda InfiniteFallDista (duplicate)

          ;; sta temp2 (duplicate)
          ;; jsr BS_return (duplicate)

.pend

CalculateFallDistanceNormal .proc
                    ;; let temp3 = SafeFallVelocityThresholds[currentCharacter]          lda currentCharacter          asl          tax          lda SafeFallVelocityThresholds,x          sta temp3
          ;; lda temp3 (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta temp4 (duplicate)
                    ;; let temp2 = SquareTable[temp4]
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SquareTable,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda SquareTable,x (duplicate)
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda currentCharacter (duplicate)
          ;; cmp CharacterNinjishGuy (duplicate)
          ;; bne skip_4750 (duplicate)
                    ;; let temp2 = temp2 * 2
skip_4750:

          ;; jsr BS_return (duplicate)

.pend

