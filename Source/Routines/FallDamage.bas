CheckFallDamage
          rem
          rem ChaosFight - Source/Routines/FallDamage.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Fall Damage System
          rem Handles fall damage detection and application based on:
          rem   - Vertical velocity at landing
          rem - Character weight (heavier = shorter safe fall distance)
          rem   - Character-specific immunities and reductions
          rem FALL DAMAGE RULES:
          rem   - Safe fall distance inversely proportional to weight
          rem - Average-weight character: ~64 pixels (1/3 of 192 screen
          rem   height)
          rem - Fall damage proportional to distance beyond safe
          rem   threshold
          rem - Triggers damage recovery animation and color shift
          rem   (darker)
          rem CHARACTER EXCEPTIONS:
          rem   - Bernie (0): NO fall damage (immune)
          rem   - Robo Tito (13): 1/2 fall damage (reduced)
          rem   - Frooty (8): NO gravity (no falling)
          rem - Dragon of Storms (2): NO gravity (no falling,
          rem   hovering/flying like Frooty)
          rem   - Ninjish Guy (10): 1/2 fall damage (reduced)
          rem   - Harpy (6): Reduced gravity (1/2 rate) when falling
          rem GRAVITY CONSTANTS:
          rem   - Defined in Constants.bas as tunable constants:
          rem GravityNormal (0.1 px/frame²), GravityReduced (0.05
          rem   px/frame²), TerminalVelocity (8 px/frame)
          rem - Scale: 16px = 2m (character height), so 1px = 0.125m =
          rem   12.5cm
          rem VARIABLES USED:
          rem   - playerY[0-3]: Vertical position
          rem   - PlayerMomentumY (temporary): Vertical velocity
          rem   - playerRecoveryFrames[0-3]: Hitstun/recovery timer
          rem   - playerHealth[0-3]: Health to reduce
          rem   - temp1: Player index
          rem   - temp2: Fall velocity at impact
          rem   - temp3: Safe fall distance threshold
          rem
          rem   - temp4: Fall damage amount
          rem   - temp5: Character type
          rem   - temp6: Character weight
          rem Check Fall Damage
          rem Called when a player lands on the ground or platform.
          rem Calculates fall damage based on downward velocity at
          rem   impact.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem temp2 = vertical velocity at landing (positive = downward)
          rem PROCESS:
          rem   1. Get character type and weight
          rem   2. Check for fall damage immunity
          rem   3. Calculate safe fall velocity threshold
          rem   4. Calculate fall damage if exceeded
          rem   5. Apply damage, recovery frames, and color shift
          rem Called when a player lands on the ground or platform -
          rem calculates fall damage
          rem
          rem Input: temp1 = player index (0-3)
          rem        temp2 = vertical velocity at landing (positive =
          rem        downward)
          rem        playerCharacter[] (global array) = player character
          rem        selections
          rem        SafeFallVelocityThresholds[] (global array) = safe
          rem        fall velocity thresholds
          rem        WeightDividedBy20[] (global array) = weight/20
          rem        lookup table
          rem
          rem Output: playerHealth[] reduced, playerRecoveryFrames[]
          rem set, playerState[] updated,
          rem         sound effect played
          rem
          rem Mutates: temp1-temp6 (used for calculations),
          rem playerHealth[] (reduced),
          rem         playerRecoveryFrames[] (set), playerState[]
          rem         (recovery flag and animation state set),
          rem         oldHealthValue, recoveryFramesCalc,
          rem         playerStateTemp (temporary calculations)
          rem
          rem Called Routines: GetCharacterWeight - accesses temp1,
          rem temp2,
          rem   PlaySoundEffect (bank15) - plays landing damage sound
          rem Constraints: None
          rem temp7+ don’t exist - using tempWork1 for temporary
          rem   calculations

          let temp5 = playerCharacter[temp1] : rem Get character type for this player
          
          if temp5 = CharacterBernie then return : rem Check for fall damage immunity
          rem Bernie: immune
          if temp5 = CharacterFrooty then return : rem Robo Tito: reduced fall damage (handled after damage calculation)
          if temp5 = CharacterDragonOfStorms then return : rem Frooty: no gravity, no falling
          rem Dragon of Storms: no gravity, no falling (hovering/flying
          rem   like Frooty)
          
          let temp1 = temp5 : rem Get character weight from data table
          gosub GetCharacterWeight : rem Character type as index
          let temp6 = temp2 
          rem Store weight
          
          rem Calculate safe fall velocity threshold
          rem Formula: safe_velocity = 120 / weight
          rem Use lookup table to avoid variable division
          let temp3 = SafeFallVelocityThresholds[temp5] : rem Pre-computed values in SafeFallVelocityThresholds table
          rem Safe fall velocity threshold
          
          if temp2 <= temp3 then return : rem Check if fall velocity exceeds safe threshold
          rem Safe landing, no damage
          
          rem Check if player is guarding - guard does NOT block fall
          rem   damage
          rem Guard only blocks attack damage (missiles, AOE), not
          rem   environmental damage
          rem Fall damage is environmental, so guard does not protect
          
          rem Calculate fall damage
          rem Base damage = (velocity - safe_velocity) *
          rem   base_damage_multiplier
          rem Base damage multiplier: 2 (so 1 extra velocity = 2 base
          let temp4 = temp2 - temp3 : rem   damage)
          rem Multiply by 2 using bit shift left
          asl temp4
          rem temp4 = temp4 * 2
          
          rem Apply weight-based damage multiplier: the bigger they
          rem   are, the harder they fall
          rem Heavy characters take more damage for the same impact
          rem   velocity
          rem Formula: damage_multiplier = weight / 20 (average weight)
          rem Using integer math: damage = damage * (weight / 20)
          rem Use lookup table for weight/20, then multiply by damage
          rem temp2 = weight / 20 from lookup table
          let temp2 = WeightDividedBy20[temp5]
          rem Multiply damage by (weight / 20) using assembly
          rem Use Mul macro pattern: if multiplier is 0-15, use
          rem   optimized assembly
          rem For small multipliers (0-15), use lookup table or bit
          rem   shifts
          rem For larger multipliers, use assembly multiplication
          asm
          ; rem   routine
            lda temp2
            beq MultiplyDone
            ; rem Multiplier is non-zero, multiply temp4 by temp2
            ; rem Use optimized multiplication based on multiplier value
            ; rem For multiplier = 1: no change
            ; rem For multiplier = 2: asl once
            ; rem For multiplier = 3: asl + add original
            ; rem For multiplier = 4: asl twice
            ; rem For multiplier = 5: asl twice + add original
          ; rem For now, use simple approach: multiply using repeated
          ; rem   addition
          ; rem But wait - user said no repeated addition! Use lookup
          ; rem   table instead
          ; rem Actually, we can use a lookup table for common damage
          ; rem   values
            ; rem Or use assembly with optimized multiplication
            ; rem Check multiplier value and use appropriate method
            cmp #1
            beq MultiplyDone
            cmp #2
            bne CheckMult3
            ; rem Multiply by 2: shift left once
            asl temp4
            jmp MultiplyDone
CheckMult3
            cmp #3
            bne CheckMult4
            ; rem Multiply by 3: damage * 2 + damage
            lda temp4
            asl a
            clc
            adc temp4
            sta temp4
            jmp MultiplyDone
CheckMult4
            cmp #4
            bne CheckMult5
            ; rem Multiply by 4: shift left twice
            asl temp4
            asl temp4
            jmp MultiplyDone
CheckMult5
            ; rem For 5: multiply by 4 + add original
            lda temp4
            asl a
            asl a
            clc
            adc temp4
            sta temp4
MultiplyDone
end
          rem temp4 = damage * (weight / 20) (weight-based
          rem   multiplier applied)
          
          rem Apply damage reduction for characters with fall damage
          if temp5 = CharacterNinjishGuy then lsr temp4 : rem   resistance (after weight multiplier)
          rem Ninjish Guy: 1/2 damage (divide by 2 using bit shift
          if temp5 = CharacterRoboTito then lsr temp4 : rem   right)
          rem Robo Tito: 1/2 damage (divide by 2 using bit shift
          rem   right)
          
          if temp4 > 50 then let temp4 = 50 : rem Cap maximum fall damage at 50
          
          rem Apply fall damage (byte-safe clamp)
          let oldHealthValue_W = playerHealth[temp1] : rem Use oldHealthValue for byte-safe clamp check
          let playerHealth[temp1] = playerHealth[temp1] - temp4
          if playerHealth[temp1] > oldHealthValue_R then let playerHealth[temp1] = 0
          
          rem Set recovery frames (proportional to damage, min 10, max
          rem   30)
          let temp2 = temp4 : rem Use temp2 for recovery frames calculation
          lsr temp2
          if temp2 < 10 then let temp2 = 10 : rem Divide by 2 using bit shift right
          if temp2 > 30 then let temp2 = 30
          let recoveryFramesCalc_W = temp2
          let playerRecoveryFrames[temp1] = temp2
          
          let playerState[temp1] = playerState[temp1] | 8 : rem Synchronize playerState bit 3 with recovery frames
          rem Set bit 3 (recovery flag) when recovery frames are set
          
          rem Set animation state to recovering from fall
          rem This is animation state 9 in the character animation
          rem   sequences
          rem playerState bits:
          rem   [7:animation][4:attacking][2:jumping]
          rem   [1:guarding][0:facing]
          rem Set bits 7-5 to 9 (recovering animation)
          let temp2 = playerState[temp1] & MaskPlayerStateLower : rem Use temp2 for state manipulation
          let temp2 = temp2 | MaskAnimationRecovering : rem Keep lower 5 bits
          let playerStateTemp_W = temp2
          let playerState[temp1] = temp2 : rem Set animation to 9 (1001 in bits 7-4)
          
          let temp1 = SoundLandingDamage : rem Play fall damage sound effect
          gosub PlaySoundEffect bank15
          
          rem Trigger color shift to darker shade (damage visual
          rem   feedback)
          rem This is handled by PlayerRendering.bas using
          rem   playerRecoveryFrames
          
          return

FallDamageApplyGravity
          rem
          rem Apply Gravity
          rem Applies gravity acceleration to a player each frame.
          rem Handles character-specific gravity rates and terminal
          rem   velocity.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = current vertical momentum (positive = down)
          rem
          rem OUTPUT:
          rem   temp2 = updated vertical momentum
          rem Applies gravity acceleration to a player each frame
          rem
          rem Input: temp1 = player index (0-3)
          rem        temp2 = current vertical momentum (positive = down)
          rem        playerCharacter[] (global array) = player character
          rem        selections
          rem        TerminalVelocity (constant) = maximum fall velocity
          rem
          rem Output: temp2 = updated vertical momentum
          rem
          rem Mutates: temp1, temp2, temp5, temp6 (used for
          rem calculations)
          rem
          rem Called Routines: None
          rem Constraints: None
          let temp5 = playerCharacter[temp1] : rem Get character type
          
          if temp5 = CharacterFrooty then return : rem Check for no-gravity characters
          if temp5 = CharacterDragonOfStorms then return : rem Frooty: no gravity
          rem Dragon of Storms: no gravity (hovering/flying like Frooty)
          
          rem Check for reduced gravity characters
          let temp6 = 2 : rem Harpy (6): 1/2 gravity when falling
          if temp5 = CharacterHarpy then let temp6 = 1 : rem Default gravity: 2 pixels/frame²
          rem Harpy: reduced gravity
          
          let temp2 = temp2 + temp6 : rem Apply gravity acceleration
          
          rem Cap at terminal velocity (uses tunable constant from
          if temp2 > TerminalVelocity then let temp2 = TerminalVelocity : rem   Constants.bas)
          
          return

CheckGroundCollision
          rem
          rem Check Ground Collision
          rem Checks if player has landed on ground or platform.
          rem Calls CheckFallDamage if landing detected.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = vertical momentum before position update
          rem This routine should be called AFTER vertical position
          rem   update
          rem but BEFORE momentum is cleared, so we can detect the
          rem   landing
          rem velocity for fall damage calculation.
          rem Checks if player has landed on ground or platform
          rem
          rem Input: temp1 = player index (0-3)
          rem        temp2 = vertical momentum before position update
          rem        playerY[] (global array) = player Y positions
          rem
          rem Output: playerY[] clamped to ground if landed,
          rem CheckFallDamage called if moving downward
          rem
          rem Mutates: temp1, temp2, temp3 (used for calculations),
          rem playerY[] (clamped to 176 if landed)
          rem
          rem Called Routines: CheckFallDamage - accesses temp1, temp2,
          rem playerCharacter[], playerHealth[],
          rem   playerRecoveryFrames[], playerState[], PlaySoundEffect
          rem   (bank15)
          rem
          rem Constraints: Tail call to CheckFallDamage
          rem              Should be called AFTER vertical position
          rem              update but BEFORE momentum is cleared
          let temp3 = playerY[temp1] : rem Get player Y position
          
          rem Check if player is at or below ground level
          rem Ground level is at Y = 176 (bottom of playfield, leaving
          if temp3 < 176 then return
          rem Player hit ground (room for sprite)
          let playerY[temp1] = 176 : rem Clamp position to ground
          
          if temp2 <= 0 then return
          rem Check fall damage if moving downward
          rem momentum contains downward velocity
          goto CheckFallDamage : rem tail call
          
          rem Stop vertical momentum
          rem Note: This assumes vertical momentum is being tracked
          rem In current implementation, this might need integration
          rem with PlayerPhysics.bas
          
          rem Check collision with platforms/playfield
          rem This is handled by the main collision detection system
          rem Use pfread to detect solid ground beneath player
          rem Convert player X/Y to playfield coordinates
          rem If standing on platform, perform same landing logic
          
          return

HandleFrootyVertical
          rem
          rem Handle Frooty Vertical Control
          rem Frooty has no gravity and can move up/down freely.
          rem Down button moves down (no guard action).
          rem
          rem INPUT:
          rem temp1 = player index (0-3, but should only be called for
          rem   Frooty)
          rem This should be called from PlayerInput.bas when processing
          rem joystick up/down for Frooty.
          let temp5 = playerCharacter[temp1] : rem Check character type to confirm
          if !(temp5 = CharacterFrooty) then return 
          rem Not Frooty
          
          rem Get joystick state
          rem This needs to be integrated with PlayerInput.bas
          rem Fall damage calculation based on character weight
          
          rem If joyup pressed: move up
          rem playerY[temp1] = playerY[temp1] - 2
          
          rem If joydown pressed: move down (replaces guard action)
          rem playerY[temp1] = playerY[temp1] + 2
          
          rem Clamp to screen bounds
          rem Byte-safe clamp: if wrapped below 0, the new value will
          let oldHealthValue_W = playerY[temp1] : rem   exceed the old
          rem Reuse oldHealthValue for byte-safe clamp check (not
          if playerY[temp1] > oldHealthValue_R then let playerY[temp1] = 0 : rem   actually health, but same pattern)
          if playerY[temp1] > 176 then let playerY[temp1] = 176
          
          return

HandleHarpySwoopAttack
          rem
          rem Handle Harpy Swoop Attack
          rem Harpy attack causes an instant redirection into a rapid
          rem downward diagonal strike at ~45° to the facing direction.
          rem
          rem INPUT:
          rem temp1 = player index (0-3, but should only be called for
          rem   Harpy)
          rem
          rem OUTPUT:
          rem Sets player momentum for diagonal downward swoop
          let temp5 = playerCharacter[temp1] : rem Check character type to confirm
          if !(temp5 = CharacterHarpy) then return 
          rem Not Harpy
          
          let temp6 = playerState[temp1] & PlayerStateBitFacing : rem Get facing direction from playerState bit 0
          
          rem Set diagonal momentum at ~45° angle
          rem Horizontal: 4 pixels/frame (in facing direction)
          if temp6 = 0 then SetHorizontalMomentumRight : rem Vertical: 4 pixels/frame (downward)
          rem Facing left: set negative momentum (252 = -4 in signed
          let playerVelocityX[temp1] = 252 : rem   8-bit)
          goto SetVerticalMomentum
SetHorizontalMomentumRight
          let playerVelocityX[temp1] = 4 : rem Facing right: set positive momentum
SetVerticalMomentum
          
          rem Set downward momentum (using temp variable for now)
          rem Integrate with vertical momentum system
          rem This is handled by PlayerPhysics.bas
          rem This needs to override normal gravity temporarily
          rem Suggest adding PlayerMomentumY variable or state flag
          
          rem Set animation state to swooping attack
          rem This could be animation state 10 or special attack
          let temp6 = playerState[temp1] & MaskPlayerStateLower : rem   animation
          let temp6 = temp6 | MaskAnimationFalling 
          let playerState[temp1] = temp6 : rem Animation state 10
          
          rem Spawn melee attack missile for swoop hit detection
          gosub SpawnMissile bank7
          
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
          ; rem DivideBy20: compute floor(A / 20) using optimized assembly
          ; rem
          ; rem INPUT: A register = dividend (temp2)
          ; rem
          ; rem OUTPUT: A register = quotient (result in temp2)
          ; rem Uses 18 bytes, 32 cycles
            lda temp2
            lsr a
            lsr a
            sta temp6
            lsr a
            adc temp6
            ror
            lsr a
            lsr a
            adc temp6
            ror
            adc temp6
            ror
            lsr a
            lsr a
            sta temp2
end
          return
          
DivideBy100
          rem DivideBy100: compute floor(temp2 / 100) using range check
          rem
          rem INPUT: temp2 = dividend
          rem
          rem OUTPUT: temp2 = quotient (0, 1, or 2)
          rem Fast approximation for values 0-255
          if temp2 > 200 then goto DivideBy100Two
          if temp2 > 100 then goto DivideBy100One
          let temp2 = 0
          return
DivideBy100One
          let temp2 = 1
          return
DivideBy100Two
          let temp2 = 2
          return

DivideByPfrowheight
          rem DivideByPfrowheight: compute value / pfrowheight using bit
          rem   shifts
          rem
          rem INPUT: temp2 = dividend (Y position value)
          rem
          rem OUTPUT: temp2 = quotient (row index)
          rem pfrowheight is either 8 (admin) or 16 (game), both powers
          rem   of 2
          rem Uses conditional bit shifts based on runtime value
          if pfrowheight = 8 then DBPF_DivideBy8 : rem Check if pfrowheight is 8 or 16
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          return
DBPF_DivideBy8
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
end
          return
          
CalculateSafeFallDistance
          rem
          rem Calculate Safe Fall Distance
          rem Utility routine to calculate safe fall distance for a
          rem   character.
          rem Used for AI and display purposes.
          rem
          rem INPUT:
          rem   temp1 = player index (0-3)
          rem
          rem OUTPUT:
          rem   temp2 = safe fall distance in pixels
          rem Get character type and weight
          temp5 = playerCharacter[temp1]
          
          if temp5 = CharacterBernie then SetInfiniteFallDistance : rem Check for fall damage immunity
          if temp5 = CharacterRoboTito then SetInfiniteFallDistance : rem Bernie: infinite
          if temp5 = CharacterFrooty then SetInfiniteFallDistance : rem Robo Tito: infinite
          if temp5 = CharacterDragonOfStorms then SetInfiniteFallDistance : rem Frooty: no falling
          goto CalculateFallDistanceNormal : rem Dragon of Storms: no falling (hovering/flying like Frooty)
SetInfiniteFallDistance
          temp2 = InfiniteFallDistance
          return
CalculateFallDistanceNormal
          
          rem Get character weight
          temp1 = temp5 
          gosub GetCharacterWeight : rem Character type as index
          temp6 = temp2 
          rem Store weight
          
          rem Calculate safe fall velocity (from CheckFallDamage logic)
          let temp3 = SafeFallVelocityThresholds[temp5] : rem Use lookup table to avoid variable division
          rem temp3 = Safe velocity threshold
          
          rem Convert velocity to distance
          rem Using kinematic equation: v² = 2 * g * d
          rem Rearranged: d = v² / (2 * g)
          rem With g = 2: d = v² / 4
          rem Square temp3 using lookup table (temp3 is 1-24)
          rem SquareTable is 0-indexed, so index = temp3 - 1
          let temp4 = temp3 - 1
          let temp2 = SquareTable[temp4] : rem temp4 = index into SquareTable (0-23)
          rem temp2 = temp3 * temp3 (v²)
          rem Divide by 4 using bit shift right twice
          asm
            lsr temp2
            lsr temp2
end
          rem temp2 = v² / 4
          
          if temp5 = CharacterNinjishGuy then asl temp2 : rem Apply Ninjish Guy bonus (can fall farther)
          rem Multiply by 2 using bit shift left
          
          return

