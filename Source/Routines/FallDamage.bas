          rem ChaosFight - Source/Routines/FallDamage.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem ==========================================================
          rem FALL DAMAGE SYSTEM
          rem ==========================================================
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
          rem   - temp4: Fall damage amount
          rem   - temp5: Character type
          rem   - temp6: Character weight
          rem ==========================================================

          rem ==========================================================
          rem CHECK FALL DAMAGE
          rem ==========================================================
          rem Called when a player lands on the ground or platform.
          rem Calculates fall damage based on downward velocity at
          rem   impact.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem temp2 = vertical velocity at landing (positive = downward)

          rem PROCESS:
          rem   1. Get character type and weight
          rem   2. Check for fall damage immunity
          rem   3. Calculate safe fall velocity threshold
          rem   4. Calculate fall damage if exceeded
          rem   5. Apply damage, recovery frames, and color shift
CheckFallDamage
          rem Called when a player lands on the ground or platform - calculates fall damage
          rem Input: temp1 = player index (0-3)
          rem        temp2 = vertical velocity at landing (positive = downward)
          rem        playerChar[] (global array) = player character selections
          rem        SafeFallVelocityThresholds[] (global array) = safe fall velocity thresholds
          rem        WeightDividedBy20[] (global array) = weight/20 lookup table
          rem Output: playerHealth[] reduced, playerRecoveryFrames[] set, playerState[] updated,
          rem         sound effect played
          rem Mutates: temp1-temp6 (used for calculations), playerHealth[] (reduced),
          rem         playerRecoveryFrames[] (set), playerState[] (recovery flag and animation state set),
          rem         oldHealthValue, recoveryFramesCalc, playerStateTemp (temporary calculations)
          rem Called Routines: GetCharacterWeight - accesses temp1, temp2,
          rem   PlaySoundEffect (bank15) - plays landing damage sound
          rem Constraints: None
          dim CFD_playerIndex = temp1
          dim CFD_fallVelocity = temp2
          dim CFD_safeThreshold = temp3
          dim CFD_damage = temp4
          dim CFD_characterType = temp5
          dim CFD_characterWeight = temp6
          rem temp7+ don't exist - using tempWork1 for temporary
          rem   calculations

          rem Get character type for this player
          let CFD_characterType = playerChar[CFD_playerIndex]
          
          rem Check for fall damage immunity
          if CFD_characterType = CharBernie then return 
          rem Bernie: immune
          rem Robo Tito: reduced fall damage (handled after damage calculation)
          if CFD_characterType = CharFrooty then return 
          rem Frooty: no gravity, no falling
          if CFD_characterType = CharDragonOfStorms then return
          rem Dragon of Storms: no gravity, no falling (hovering/flying
          rem   like Frooty)
          
          rem Get character weight from data table
          let temp1 = CFD_characterType 
          rem Character type as index
          gosub GetCharacterWeight
          let CFD_characterWeight = temp2 
          rem Store weight
          
          rem Calculate safe fall velocity threshold
          rem Formula: safe_velocity = 120 / weight
          rem Use lookup table to avoid variable division
          rem Pre-computed values in SafeFallVelocityThresholds table
          let CFD_safeThreshold = SafeFallVelocityThresholds[CFD_characterType] 
          rem Safe fall velocity threshold
          
          rem Check if fall velocity exceeds safe threshold
          if CFD_fallVelocity <= CFD_safeThreshold then return 
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
          rem   damage)
          let CFD_damage = CFD_fallVelocity - CFD_safeThreshold
          rem Multiply by 2 using bit shift left
          asl CFD_damage
          rem CFD_damage = CFD_damage * 2
          
          rem Apply weight-based damage multiplier: the bigger they
          rem   are, the harder they fall
          rem Heavy characters take more damage for the same impact
          rem   velocity
          rem Formula: damage_multiplier = weight / 20 (average weight)
          rem Using integer math: damage = damage * (weight / 20)
          rem Use lookup table for weight/20, then multiply by damage
          rem temp2 = weight / 20 from lookup table
          let temp2 = WeightDividedBy20[CFD_characterType]
          rem Multiply damage by (weight / 20) using assembly
          rem Use Mul macro pattern: if multiplier is 0-15, use
          rem   optimized assembly
          rem For small multipliers (0-15), use lookup table or bit
          rem   shifts
          rem For larger multipliers, use assembly multiplication
          rem   routine
          asm
            lda temp2
            beq MultiplyDone
            rem Multiplier is non-zero, multiply CFD_damage by temp2
            rem Use optimized multiplication based on multiplier value
            rem For multiplier = 1: no change
            rem For multiplier = 2: asl once
            rem For multiplier = 3: asl + add original
            rem For multiplier = 4: asl twice
            rem For multiplier = 5: asl twice + add original
          rem For now, use simple approach: multiply using repeated
          rem   addition
          rem But wait - user said no repeated addition! Use lookup
          rem   table instead
          rem Actually, we can use a lookup table for common damage
          rem   values
            rem Or use assembly with optimized multiplication
            rem Check multiplier value and use appropriate method
            cmp #1
            beq MultiplyDone
            cmp #2
            bne CheckMult3
            rem Multiply by 2: shift left once
            asl CFD_damage
            jmp MultiplyDone
CheckMult3
            cmp #3
            bne CheckMult4
            rem Multiply by 3: damage * 2 + damage
            lda CFD_damage
            asl a
            clc
            adc CFD_damage
            sta CFD_damage
            jmp MultiplyDone
CheckMult4
            cmp #4
            bne CheckMult5
            rem Multiply by 4: shift left twice
            asl CFD_damage
            asl CFD_damage
            jmp MultiplyDone
CheckMult5
            rem For 5: multiply by 4 + add original
            lda CFD_damage
            asl a
            asl a
            clc
            adc CFD_damage
            sta CFD_damage
MultiplyDone
end
          rem CFD_damage = damage * (weight / 20) (weight-based
          rem   multiplier applied)
          
          rem Apply damage reduction for characters with fall damage
          rem   resistance (after weight multiplier)
          if CFD_characterType = CharNinjishGuy then lsr CFD_damage
          rem Ninjish Guy: 1/2 damage (divide by 2 using bit shift
          rem   right)
          if CFD_characterType = CharRoboTito then lsr CFD_damage
          rem Robo Tito: 1/2 damage (divide by 2 using bit shift
          rem   right)
          
          rem Cap maximum fall damage at 50
          if CFD_damage > 50 then let CFD_damage = 50
          
          rem Apply fall damage (byte-safe clamp)
          rem Use oldHealthValue for byte-safe clamp check
          let oldHealthValue = playerHealth[CFD_playerIndex]
          let playerHealth[CFD_playerIndex] = playerHealth[CFD_playerIndex] - CFD_damage
          if playerHealth[CFD_playerIndex] > oldHealthValue then let playerHealth[CFD_playerIndex] = 0
          
          rem Set recovery frames (proportional to damage, min 10, max
          rem   30)
          rem Use recoveryFramesCalc for recovery frames calculation
          let recoveryFramesCalc = CFD_damage
          lsr recoveryFramesCalc
          rem Divide by 2 using bit shift right
          if recoveryFramesCalc < 10 then let recoveryFramesCalc = 10
          if recoveryFramesCalc > 30 then let recoveryFramesCalc = 30
          let playerRecoveryFrames[CFD_playerIndex] = recoveryFramesCalc
          
          rem Synchronize playerState bit 3 with recovery frames
          let playerState[CFD_playerIndex] = playerState[CFD_playerIndex] | 8
          rem Set bit 3 (recovery flag) when recovery frames are set
          
          rem Set animation state to recovering from fall
          rem This is animation state 9 in the character animation
          rem   sequences
          rem playerState bits:
          rem   [7:animation][4:attacking][2:jumping]
          rem   [1:guarding][0:facing]
          rem Set bits 7-5 to 9 (recovering animation)
          rem Use playerStateTemp for state manipulation
          let playerStateTemp = playerState[CFD_playerIndex] & MaskPlayerStateLower 
          rem Keep lower 5 bits
          let playerStateTemp = playerStateTemp | MaskAnimationRecovering 
          rem Set animation to 9 (1001 in bits 7-4)
          let playerState[CFD_playerIndex] = playerStateTemp
          
          rem Play fall damage sound effect
          let temp1 = SoundLandingDamage
          gosub PlaySoundEffect bank15
          
          rem Trigger color shift to darker shade (damage visual
          rem   feedback)
          rem This is handled by PlayerRendering.bas using
          rem   playerRecoveryFrames
          
          return

          rem ==========================================================
          rem APPLY GRAVITY
          rem ==========================================================
          rem Applies gravity acceleration to a player each frame.
          rem Handles character-specific gravity rates and terminal
          rem   velocity.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = current vertical momentum (positive = down)

          rem OUTPUT:
          rem   temp2 = updated vertical momentum
FallDamageApplyGravity
          rem Applies gravity acceleration to a player each frame
          rem Input: temp1 = player index (0-3)
          rem        temp2 = current vertical momentum (positive = down)
          rem        playerChar[] (global array) = player character selections
          rem        TerminalVelocity (constant) = maximum fall velocity
          rem Output: temp2 = updated vertical momentum
          rem Mutates: temp1, temp2, temp5, temp6 (used for calculations)
          rem Called Routines: None
          rem Constraints: None
          dim FDAG_playerIndex = temp1
          dim FDAG_momentum = temp2
          dim FDAG_characterType = temp5
          dim FDAG_gravityRate = temp6
          rem Get character type
          let FDAG_characterType = playerChar[FDAG_playerIndex]
          
          rem Check for no-gravity characters
          if FDAG_characterType = CharFrooty then return 
          rem Frooty: no gravity
          if FDAG_characterType = CharDragonOfStorms then return
          rem Dragon of Storms: no gravity (hovering/flying like Frooty)
          
          rem Check for reduced gravity characters
          rem Harpy (6): 1/2 gravity when falling
          let FDAG_gravityRate = 2 
          rem Default gravity: 2 pixels/frame²
          if FDAG_characterType = CharHarpy then let FDAG_gravityRate = 1 
          rem Harpy: reduced gravity
          
          rem Apply gravity acceleration
          let FDAG_momentum = FDAG_momentum + FDAG_gravityRate
          
          rem Cap at terminal velocity (uses tunable constant from
          rem   Constants.bas)
          if FDAG_momentum > TerminalVelocity then let FDAG_momentum = TerminalVelocity
          let temp2 = FDAG_momentum
          
          return

          rem ==========================================================
          rem CHECK GROUND COLLISION
          rem ==========================================================
          rem Checks if player has landed on ground or platform.
          rem Calls CheckFallDamage if landing detected.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = vertical momentum before position update

          rem This routine should be called AFTER vertical position
          rem   update
          rem but BEFORE momentum is cleared, so we can detect the
          rem   landing
          rem velocity for fall damage calculation.
CheckGroundCollision
          rem Checks if player has landed on ground or platform
          rem Input: temp1 = player index (0-3)
          rem        temp2 = vertical momentum before position update
          rem        playerY[] (global array) = player Y positions
          rem Output: playerY[] clamped to ground if landed, CheckFallDamage called if moving downward
          rem Mutates: temp1, temp2, temp3 (used for calculations), playerY[] (clamped to 176 if landed)
          rem Called Routines: CheckFallDamage - accesses temp1, temp2, playerChar[], playerHealth[],
          rem   playerRecoveryFrames[], playerState[], PlaySoundEffect (bank15)
          rem Constraints: Tail call to CheckFallDamage
          rem              Should be called AFTER vertical position update but BEFORE momentum is cleared
          dim CGC_playerIndex = temp1
          dim CGC_momentum = temp2
          dim CGC_playerY = temp3
          rem Get player Y position
          let CGC_playerY = playerY[CGC_playerIndex]
          
          rem Check if player is at or below ground level
          rem Ground level is at Y = 176 (bottom of playfield, leaving
          rem   room for sprite)
          if CGC_playerY >= 176 then
          rem Player hit ground
          rem Clamp position to ground
          let playerY[CGC_playerIndex] = 176
          
          rem Check fall damage if moving downward
          if CGC_momentum > 0 then
          rem momentum contains downward velocity
          let temp1 = CGC_playerIndex
          let temp2 = CGC_momentum
          rem tail call
          goto CheckFallDamage
          
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

          rem ==========================================================
          rem HANDLE FROOTY VERTICAL CONTROL
          rem ==========================================================
          rem Frooty has no gravity and can move up/down freely.
          rem Down button moves down (no guard action).

          rem INPUT:
          rem temp1 = player index (0-3, but should only be called for
          rem   Frooty)

          rem This should be called from PlayerInput.bas when processing
          rem joystick up/down for Frooty.
HandleFrootyVertical
          dim HFV_playerIndex = temp1
          dim HFV_characterType = temp5
          dim HFV_playerY = temp1
          rem Check character type to confirm
          let HFV_characterType = playerChar[HFV_playerIndex]
          if !(HFV_characterType = CharFrooty) then return 
          rem Not Frooty
          
          rem Get joystick state
          rem This needs to be integrated with PlayerInput.bas
          rem Fall damage calculation based on character weight
          
          rem If joyup pressed: move up
          rem playerY[HFV_playerIndex] = playerY[HFV_playerIndex] - 2
          
          rem If joydown pressed: move down (replaces guard action)
          rem playerY[HFV_playerIndex] = playerY[HFV_playerIndex] + 2
          
          rem Clamp to screen bounds
          rem Byte-safe clamp: if wrapped below 0, the new value will
          rem   exceed the old
          let oldHealthValue = playerY[HFV_playerIndex]
          rem Reuse oldHealthValue for byte-safe clamp check (not
          rem   actually health, but same pattern)
          if playerY[HFV_playerIndex] > oldHealthValue then let playerY[HFV_playerIndex] = 0
          if playerY[HFV_playerIndex] > 176 then let playerY[HFV_playerIndex] = 176
          
          return

          rem ==========================================================
          rem HANDLE HARPY SWOOP ATTACK
          rem ==========================================================
          rem Harpy attack causes an instant redirection into a rapid
          rem downward diagonal strike at ~45° to the facing direction.

          rem INPUT:
          rem temp1 = player index (0-3, but should only be called for
          rem   Harpy)

          rem OUTPUT:
          rem   Sets player momentum for diagonal downward swoop
HandleHarpySwoopAttack
          dim HHSA_playerIndex = temp1
          dim HHSA_characterType = temp5
          dim HHSA_facing = temp6
          dim HHSA_playerState = temp6
          rem Check character type to confirm
          let HHSA_characterType = playerChar[HHSA_playerIndex]
          if !(HHSA_characterType = CharHarpy) then return 
          rem Not Harpy
          
          rem Get facing direction from playerState bit 0
          let HHSA_facing = playerState[HHSA_playerIndex] & PlayerStateBitFacing
          
          rem Set diagonal momentum at ~45° angle
          rem Horizontal: 4 pixels/frame (in facing direction)
          rem Vertical: 4 pixels/frame (downward)
          if HHSA_facing = 0 then SetHorizontalMomentumRight
          rem Facing left: set negative momentum (252 = -4 in signed
          rem   8-bit)
          let playerVelocityX[HHSA_playerIndex] = 252
          goto SetVerticalMomentum
SetHorizontalMomentumRight
          rem Facing right: set positive momentum
          let playerVelocityX[HHSA_playerIndex] = 4
SetVerticalMomentum
          
          rem Set downward momentum (using temp variable for now)
          rem Integrate with vertical momentum system
          rem This is handled by PlayerPhysics.bas
          rem This needs to override normal gravity temporarily
          rem Suggest adding PlayerMomentumY variable or state flag
          
          rem Set animation state to swooping attack
          rem This could be animation state 10 or special attack
          rem   animation
          let HHSA_playerState = playerState[HHSA_playerIndex] & MaskPlayerStateLower
          let HHSA_playerState = HHSA_playerState | MaskAnimationFalling 
          rem Animation state 10
          let playerState[HHSA_playerIndex] = HHSA_playerState
          
          rem Spawn melee attack missile for swoop hit detection
          let temp1 = HHSA_playerIndex
          gosub SpawnMissile bank7
          
          return

          rem ==========================================================
          rem DIVISION/MULTIPLICATION HELPERS (NO MUL/DIV SUPPORT)
          rem ==========================================================
          rem Helper routines using optimized assembly for fast
          rem   division/multiplication
          rem Based on Omegamatrix’s optimized 6502 routines from
          rem   AtariAge forums
          rem These routines use bit manipulation and carry-based
          rem   arithmetic for speed
          rem Thanks to Omegamatrix and AtariAge forum contributors for
          rem   these routines
          
          rem DivideBy20: compute floor(A / 20) using optimized assembly
          rem INPUT: A register = dividend (temp2)
          rem OUTPUT: A register = quotient (result in temp2)
          rem Uses 18 bytes, 32 cycles
DivideBy20
          asm
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
          
          rem DivideBy100: compute floor(temp2 / 100) using range check
          rem INPUT: temp2 = dividend
          rem OUTPUT: temp2 = quotient (0, 1, or 2)
          rem Fast approximation for values 0-255
DivideBy100
          dim DB100_dividend = temp2
          if DB100_dividend > 200 then goto DivideBy100Two
          if DB100_dividend > 100 then goto DivideBy100One
          let DB100_dividend = 0
          return
DivideBy100One
          let DB100_dividend = 1
          return
DivideBy100Two
          let DB100_dividend = 2
          return

          rem DivideByPfrowheight: compute value / pfrowheight using bit
          rem   shifts
          rem INPUT: temp2 = dividend (Y position value)
          rem OUTPUT: temp2 = quotient (row index)
          rem pfrowheight is either 8 (admin) or 16 (game), both powers
          rem   of 2
          rem Uses conditional bit shifts based on runtime value
DivideByPfrowheight
          dim DBPF_value = temp2
          rem Check if pfrowheight is 8 or 16
          if pfrowheight = 8 then DBPF_DivideBy8
          rem pfrowheight is 16, divide by 16 (4 right shifts)
          asm
            lsr DBPF_value
            lsr DBPF_value
            lsr DBPF_value
            lsr DBPF_value
end
          return
DBPF_DivideBy8
          rem pfrowheight is 8, divide by 8 (3 right shifts)
          asm
            lsr DBPF_value
            lsr DBPF_value
            lsr DBPF_value
end
          return
          
          rem ==========================================================
          rem CALCULATE SAFE FALL DISTANCE
          rem ==========================================================
          rem Utility routine to calculate safe fall distance for a
          rem   character.
          rem Used for AI and display purposes.

          rem INPUT:
          rem   temp1 = player index (0-3)

          rem OUTPUT:
          rem   temp2 = safe fall distance in pixels
CalculateSafeFallDistance
          rem Get character type and weight
          temp5 = playerChar[temp1]
          
          rem Check for fall damage immunity
          if temp5 = CharBernie then SetInfiniteFallDistance
          rem Bernie: infinite
          if temp5 = CharRoboTito then SetInfiniteFallDistance
          rem Robo Tito: infinite
          if temp5 = CharFrooty then SetInfiniteFallDistance 
          rem Frooty: no falling
          if temp5 = CharDragonOfStorms then SetInfiniteFallDistance
          rem Dragon of Storms: no falling (hovering/flying like Frooty)
          goto CalculateFallDistanceNormal
SetInfiniteFallDistance
          temp2 = InfiniteFallDistance
          return
CalculateFallDistanceNormal
          
          rem Get character weight
          temp1 = temp5 
          rem Character type as index
          gosub GetCharacterWeight
          temp6 = temp2 
          rem Store weight
          
          rem Calculate safe fall velocity (from CheckFallDamage logic)
          rem Use lookup table to avoid variable division
          let temp3 = SafeFallVelocityThresholds[temp5]
          rem temp3 = Safe velocity threshold
          
          rem Convert velocity to distance
          rem Using kinematic equation: v² = 2 * g * d
          rem Rearranged: d = v² / (2 * g)
          rem With g = 2: d = v² / 4
          rem Square temp3 using lookup table (temp3 is 1-24)
          rem SquareTable is 0-indexed, so index = temp3 - 1
          let temp4 = temp3 - 1
          rem temp4 = index into SquareTable (0-23)
          let temp2 = SquareTable[temp4]
          rem temp2 = temp3 * temp3 (v²)
          rem Divide by 4 using bit shift right twice
          asm
            lsr temp2
            lsr temp2
end
          rem temp2 = v² / 4
          
          rem Apply Ninjish Guy bonus (can fall farther)
          if temp5 = CharNinjishGuy then asl temp2
          rem Multiply by 2 using bit shift left
          
          return

