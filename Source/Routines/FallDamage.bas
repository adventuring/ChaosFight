          rem ChaosFight - Source/Routines/FallDamage.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckFallDamage
          rem Applies character-specific fall damage when players land
          rem Inputs: currentPlayer (global) = player index (0-3), temp2 = landing velocity (positive downward)
          rem         currentCharacter (global hint, refreshed internally), playerCharacter[], playerState[], playerHealth[], playerRecoveryFrames[]
          rem         SafeFallVelocityThresholds[], WeightDividedBy20[]
          rem Outputs: playerHealth[] reduced, playerRecoveryFrames[] set, playerState[] updated, landing SFX queued
          rem Mutates: temp1-temp4, oldHealthValue, currentCharacter
          rem Calls: PlaySoundEffect (bank15)
          rem Constraints: Must remain colocated with fall-damage helpers that reuse temp scratch bytes

          let currentCharacter = playerCharacter[currentPlayer]
          rem Get character type for this player

          rem Issue #1178: Bernie post-fall stun - check before immunity
          rem Bernie is immune to fall damage but still gets stunned from high falls
          if currentCharacter = CharacterBernie then goto CheckBernieStun

          rem Check for fall damage immunity (Frooty, DragonOfStorms)
          if currentCharacter = CharacterFrooty then return
          if currentCharacter = CharacterDragonOfStorms then return

          rem Calculate safe fall velocity threshold
          rem Formula: safe_velocity = 120 ÷ weight
          rem Use lookup table to avoid variable division
          let temp3 = SafeFallVelocityThresholds[currentCharacter]
          rem Pre-computed values in SafeFallVelocityThresholds table
          rem Safe fall velocity threshold

          rem Check if fall velocity exceeds safe threshold

          if temp2 <= temp3 then return
          rem Safe landing, no damage

          rem Check if player is guarding - guard does NOT block fall
          rem   damage
          rem Guard only blocks attack damage (missiles, AOE), not
          rem   environmental damage
          rem Fall damage is environmental, so guard does not protect

          rem Calculate fall damage
          rem Base damage = (velocity - safe_velocity) ×
          rem   base_damage_multiplier
          rem Base damage multiplier: 2 (so 1 extra velocity = 2 × base
          let temp4 = temp2 - temp3
          rem   damage)
          rem Multiply by 2 to double the base damage
          let temp4 = temp4 * 2

          rem Apply weight-based damage multiplier: the bigger they
          rem   are, the harder they fall
          rem Heavy characters take more damage for the same impact
          rem   velocity
          rem Formula: damage_multiplier = weight ÷ 20 (average weight)
          rem Using integer math: damage = damage × (weight ÷ 20)
          rem Use lookup table for weight÷20, then multiply by damage
          rem temp2 = weight ÷ 20 from lookup table
          let temp2 = WeightDividedBy20[currentCharacter]
          rem Apply weight-based damage multiplier (temp2 = 0-5)
          if temp2 = 0 then temp4 = 0 : goto WeightMultDone
          if temp2 = 1 then goto WeightMultDone
          rem temp2 is 2-5: multiply temp4 by temp2 using compact ASM
          asm
            lda temp4
            ldx temp2
            dex
            dex
            beq mult2
            dex
            beq mult3
            dex
            beq mult4
            dex
            beq mult5
            sta temp4
            jmp multdone
mult2:      asl
            sta temp4
            jmp multdone
mult3:      sta temp3
            asl
            clc
            adc temp3
            sta temp4
            jmp multdone
mult4:      asl
            asl
            sta temp4
            jmp multdone
mult5:      sta temp3
            asl
            asl
            clc
            adc temp3
            sta temp4
multdone:
end
WeightMultDone
          rem temp4 = damage × (weight ÷ 20) (weight-based multiplier applied)

          rem Apply damage reduction (NinjishGuy, RoboTito: half damage)
          if currentCharacter = CharacterNinjishGuy then temp4 = temp4 / 2
          if currentCharacter = CharacterRoboTito then temp4 = temp4 / 2

          rem Cap maximum fall damage at 50

          if temp4 > 50 then temp4 = 50

          rem Apply fall damage (byte-safe clamp)
          let oldHealthValue = playerHealth[currentPlayer]
          rem Use oldHealthValue for byte-safe clamp check
          let playerHealth[currentPlayer] = playerHealth[currentPlayer] - temp4
          if playerHealth[currentPlayer] > oldHealthValue then let playerHealth[currentPlayer] = 0

          rem Set recovery frames (damage/2, clamped 10-30)
          let temp2 = temp4 / 2
          if temp2 < 10 then temp2 = 10
          if temp2 > 30 then temp2 = 30
          let playerRecoveryFrames[currentPlayer] = temp2

          let playerState[currentPlayer] = playerState[currentPlayer] | 8
          rem Synchronize playerState bit 3 with recovery frames
          rem Set bit 3 (recovery flag) when recovery frames are set

          rem Set animation state to recovering (state 9)
          let temp2 = playerState[currentPlayer] & MaskPlayerStateLower
          let playerState[currentPlayer] = temp2 | MaskAnimationRecovering

          let temp1 = SoundLandingDamage
          gosub PlaySoundEffect bank15

          return

CheckBernieStun
          rem Issue #1178: Bernie post-fall stun animation
          rem Bernie should enter stunned state after falling far enough to trigger fall damage threshold
          rem Stays in "fallen from high" animation for 1 second (frame-rate independent)
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        temp2 = landing velocity (positive downward)
          rem        SafeFallVelocityThresholds[] (global data table)
          rem
          rem Output: playerRecoveryFrames[] set to FramesPerSecond (1 second stun)
          rem        playerState[] updated with recovery flag and fallen animation
          rem
          rem Mutates: temp3 (used for threshold lookup)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Must be colocated with CheckFallDamage
          rem Check if fall velocity exceeds safe threshold (would trigger fall damage)
          let temp3 = SafeFallVelocityThresholds[CharacterBernie]
          rem Bernie’s safe fall velocity threshold
          if temp2 <= temp3 then return
          rem Safe landing, no stun needed
          rem Fall velocity exceeds threshold - trigger stun
          rem Set stun timer to 1 second (frame-rate independent: 60fps NTSC, 50fps PAL/SECAM)
          let playerRecoveryFrames[currentPlayer] = FramesPerSecond
          rem Set recovery flag to prevent movement during stun
          let playerState[currentPlayer] = playerState[currentPlayer] | PlayerStateBitRecovery
          rem Set animation state to "Fallen down" (state 8, shifted = 128)
          let temp3 = playerState[currentPlayer] & MaskPlayerStateFlags
          let playerState[currentPlayer] = temp3 | ActionFallenDownShifted
          rem Animation state 8 (Fallen down) << 4 = 128
          return

FallDamageApplyGravity
          rem
          rem Apply Gravity
          rem Applies gravity acceleration to a player each frame.
          rem Handles character-specific gravity rates and terminal
          rem   velocity.
          rem
          rem INPUT:
          rem   currentPlayer (global) = player index (0-3)
          rem   temp2 = current vertical momentum (positive = down)
          rem
          rem OUTPUT:
          rem   temp2 = updated vertical momentum
          rem Applies gravity acceleration to a player each frame
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        temp2 = current vertical momentum (positive = down)
          rem        playerCharacter[] (global array) = player character
          rem        selections
          rem        TerminalVelocity (constant) = maximum fall velocity
          rem
          rem Output: temp2 = updated vertical momentum
          rem
          rem Mutates: temp2, temp6, currentCharacter
          rem
          rem Called Routines: None
          rem Constraints: None
          let currentCharacter = playerCharacter[currentPlayer]
          rem Get character type

          rem Check for no-gravity characters (Frooty, DragonOfStorms)
          if currentCharacter = CharacterFrooty then return
          if currentCharacter = CharacterDragonOfStorms then return

          rem Apply gravity (default 2, Harpy 1)
          let temp6 = 2
          if currentCharacter = CharacterHarpy then temp6 = 1

          let temp2 = temp2 + temp6
          rem Apply gravity acceleration

          if temp2 > TerminalVelocity then temp2 = TerminalVelocity

          return

CheckGroundCollision
          rem
          rem Check Ground Collision
          rem Checks if player has landed on ground or platform.
          rem Calls CheckFallDamage if landing detected.
          rem
          rem INPUT:
          rem   currentPlayer (global) = player index (0-3)
          rem   temp2 = vertical momentum before position update
          rem This routine should be called AFTER vertical position
          rem   update
          rem but BEFORE momentum is cleared, so we can detect the
          rem   landing
          rem velocity for fall damage calculation.
          rem Checks if player has landed on ground or platform
          rem
          rem Input: currentPlayer (global) = player index (0-3)
          rem        temp2 = vertical momentum before position update
          rem        playerY[] (global array) = player Y positions
          rem
          rem Output: playerY[] clamped to ground if landed,
          rem CheckFallDamage called if moving downward
          rem
          rem Mutates: temp2, temp3 (used for calculations),
          rem playerY[] (clamped to 176 if landed), currentCharacter
          rem
          rem Called Routines: CheckFallDamage - accesses currentPlayer, temp2,
          rem playerCharacter[], playerHealth[],
          rem   playerRecoveryFrames[], playerState[], PlaySoundEffect
          rem   (bank15)
          rem
          rem Constraints: Tail call to CheckFallDamage
          rem              Should be called AFTER vertical position
          rem              update but BEFORE momentum is cleared
          let currentPlayer = temp1
          let currentCharacter = playerCharacter[currentPlayer]
          let temp3 = playerY[currentPlayer]
          rem Get player Y position

          if temp3 < 176 then return
          let playerY[currentPlayer] = 176
          if temp2 <= 0 then return
          goto CheckFallDamage

          return

HandleFrootyVertical
          rem
          rem Handle Frooty Vertical Control
          rem Frooty has no gravity and can move up/down freely.
          rem Down button moves down (no guard action).
          rem
          rem INPUT:
          rem   currentPlayer (global) = player index (0-3, but should only be called for
          rem   Frooty)
          rem This should be called from PlayerInput.bas when processing
          rem joystick up/down for Frooty.
          let currentPlayer = temp1
          let currentCharacter = playerCharacter[currentPlayer]
          rem Check character type to confirm
          if currentCharacter = CharacterFrooty then goto FrootyFallDamage
          return
FrootyFallDamage
          rem Frooty fall damage

          rem Get joystick state
          rem This needs to be integrated with PlayerInput.bas
          rem Fall damage calculation based on character weight

          rem If joyup pressed: move up
          rem playerY[currentPlayer] = playerY[currentPlayer] - 2

          rem If joydown pressed: move down (replaces guard action)
          rem playerY[currentPlayer] = playerY[currentPlayer] + 2

          rem Clamp to screen bounds
          rem Byte-safe clamp: if wrapped below 0, the new value will
          let oldHealthValue = playerY[currentPlayer]
          rem   exceed the old
          rem Reuse oldHealthValue for byte-safe clamp check (not
          rem actually health, but same pattern)
          if playerY[currentPlayer] > oldHealthValue then let playerY[currentPlayer] = 0
          if playerY[currentPlayer] > 176 then let playerY[currentPlayer] = 176

          return

HandleHarpySwoopAttack
          rem
          rem Handle Harpy Swoop Attack
          rem Harpy attack causes an instant redirection into a rapid
          rem downward diagonal strike at ~45° to the facing direction.
          rem
          rem INPUT:
          rem   currentPlayer (global) = player index (0-3, but should only be called for
          rem   Harpy)
          rem
          rem OUTPUT:
          rem Sets player momentum for diagonal downward swoop
          let currentPlayer = temp1
          let currentCharacter = playerCharacter[currentPlayer]
          rem Check character type to confirm
          if currentCharacter = CharacterHarpy then goto HarpyDive
          return
HarpyDive
          rem Harpy dive

          let temp6 = playerState[currentPlayer] & PlayerStateBitFacing
          rem Get facing direction from playerState bit 0

          rem Set diagonal momentum at ~45° angle
          rem Horizontal: 4 pixels/frame (in facing direction)
          rem Vertical: 4 pixels/frame (downward)
          if temp6 = 0 then goto SetHorizontalMomentumRight
          rem Facing left: set negative momentum (252 = -4 in signed
          let playerVelocityX[currentPlayer] = 252
          rem   8-bit)
          goto SetVerticalMomentum
SetHorizontalMomentumRight
          let playerVelocityX[currentPlayer] = 4
          rem Facing right: set positive momentum
SetVerticalMomentum
          rem Set downward momentum (using temp variable for now)
          rem Integrate with vertical momentum system
          rem This is handled by PlayerPhysicsGravity.bas
          rem This needs to override normal gravity temporarily
          rem Suggest adding PlayerMomentumY variable or state flag

          rem Set animation state to swooping attack
          rem This could be animation state 10 or special attack
          let temp6 = playerState[currentPlayer] & MaskPlayerStateLower
          rem   animation
          let temp6 = temp6 | MaskAnimationFalling
          let playerState[currentPlayer] = temp6
          rem Animation state 10

          rem Spawn mêlée attack missile for swoop hit detection
          let temp1 = currentPlayer
          gosub SpawnMissile bank12

          return

DivideBy20
          rem
          rem Division/multiplication HELPERS (no Mul/div Support)
          rem Helper routines using optimized assembly for fast
          rem   division/multiplication
          rem Based on Omegamatrix’s optimized 6502 routines from
          rem   AtariAge forums
          rem These routines use bit manipulation and carry-based
          rem   arithmetic for speed
          rem Thanks to Omegamatrix and AtariAge forum contributors for
          rem   these routines
          asm
          ; rem DivideBy20: compute floor(A ÷ 20) using optimized assembly
          ; rem
          ; rem INPUT: A register = dividend (temp2)
          ; rem
          ; rem OUTPUT: A register = quotient (result in temp2)
          ; rem Uses 18 bytes, 32 cycles
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
end
          return

DivideBy100
          rem DivideBy100: compute floor(temp2 ÷ 100) using range check
          rem
          rem INPUT: temp2 = dividend
          rem
          rem OUTPUT: temp2 = quotient (0, 1, or 2)
          rem Fast approximation for values 0-255
          if temp2 > 200 then temp2 = 2 : return
          if temp2 > 100 then temp2 = 1 : return
          let temp2 = 0
          return

CalculateSafeFallDistance
          rem
          rem Calculate Safe Fall Distance
          rem Utility routine to calculate safe fall distance for a
          rem   character.
          rem Used for AI and display purposes.
          rem
          rem INPUT:
          rem   currentPlayer (global) = player index (0-3)
          rem
          rem OUTPUT:
          rem   temp2 = safe fall distance in pixels
          rem Get character type and weight
          let currentPlayer = temp1
          let currentCharacter = playerCharacter[currentPlayer]

          rem Check for fall damage immunity
          if currentCharacter = CharacterBernie then goto SetInfiniteFallDistance
          if currentCharacter = CharacterRoboTito then goto SetInfiniteFallDistance
          if currentCharacter = CharacterFrooty then goto SetInfiniteFallDistance
          if currentCharacter = CharacterDragonOfStorms then goto SetInfiniteFallDistance
          goto CalculateFallDistanceNormal
SetInfiniteFallDistance
          let temp2 = InfiniteFallDistance
          return
CalculateFallDistanceNormal

          let temp3 = SafeFallVelocityThresholds[currentCharacter]
          let temp4 = temp3 - 1
          let temp2 = SquareTable[temp4]
          asm
            lsr temp2
            lsr temp2
end
          if currentCharacter = CharacterNinjishGuy then temp2 = temp2 * 2

          return

