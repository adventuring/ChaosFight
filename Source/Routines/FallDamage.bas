          rem ChaosFight - Source/Routines/FallDamage.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          
          rem =================================================================
          rem FALL DAMAGE SYSTEM
          rem =================================================================
          rem Handles fall damage detection and application based on:
          rem   - Vertical velocity at landing
          rem   - Character weight (heavier = shorter safe fall distance)
          rem   - Character-specific immunities and reductions

          rem FALL DAMAGE RULES:
          rem   - Safe fall distance inversely proportional to weight
          rem   - Average-weight character: ~64 pixels (1/3 of 192 screen height)
          rem   - Fall damage proportional to distance beyond safe threshold
          rem   - Triggers damage recovery animation and color shift (darker)

          rem CHARACTER EXCEPTIONS:
          rem   - Bernie (0): NO fall damage (immune)
          rem   - Robo Tito (13): NO fall damage (immune)
          rem   - Frooty (8): NO gravity (no falling)
          rem   - Dragon of Storms (2): NO gravity (no falling, hovering/flying like Frooty)
          rem   - Ninjish Guy (10): 1/2 fall damage (reduced)
          rem   - Harpy (6): Reduced gravity (1/2 rate) when falling

          rem GRAVITY CONSTANTS:
          rem   - Defined in Constants.bas as tunable constants:
          rem     GravityNormal (0.1 px/frame²), GravityReduced (0.05 px/frame²), TerminalVelocity (8 px/frame)
          rem   - Scale: 16px = 2m (character height), so 1px = 0.125m = 12.5cm

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
          rem =================================================================

          rem =================================================================
          rem CHECK FALL DAMAGE
          rem =================================================================
          rem Called when a player lands on the ground or platform.
          rem Calculates fall damage based on downward velocity at impact.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = vertical velocity at landing (positive = downward)

          rem PROCESS:
          rem   1. Get character type and weight
          rem   2. Check for fall damage immunity
          rem   3. Calculate safe fall velocity threshold
          rem   4. Calculate fall damage if exceeded
          rem   5. Apply damage, recovery frames, and color shift
CheckFallDamage
          dim CFD_playerIndex = temp1
          dim CFD_fallVelocity = temp2
          dim CFD_safeThreshold = temp3
          dim CFD_damage = temp4
          dim CFD_characterType = temp5
          dim CFD_characterWeight = temp6
          rem temp7+ don't exist - using tempWork1 for temporary calculations

          rem Get character type for this player
          let CFD_characterType = playerChar[CFD_playerIndex]
          
          rem Check for fall damage immunity
          if CFD_characterType = CharBernie then return 
          rem Bernie: immune
          if CFD_characterType = CharRoboTito then return
          rem Robo Tito: immune
          if CFD_characterType = CharFrooty then return 
          rem Frooty: no gravity, no falling
          if CFD_characterType = CharDragonOfStorms then return
          rem Dragon of Storms: no gravity, no falling (hovering/flying like Frooty)
          
          rem Get character weight from data table
          let temp1 = CFD_characterType 
          rem Character type as index
          gosub GetCharacterWeight
          let CFD_characterWeight = temp2 
          rem Store weight
          
          rem Calculate safe fall velocity threshold
          rem Formula: safe_velocity = base_safe_velocity * (average_weight / character_weight)
          rem Base safe velocity for average weight (20): ~6 pixels/frame
          rem This corresponds to falling ~1/3 screen height (64 pixels)
          rem Using simplified calculation: safe_velocity = 120 / weight
          rem Average (20): 120/20 = 6
          rem Light (10): 120/10 = 12 (can fall farther)
          rem Heavy (30): 120/30 = 4 (takes damage sooner)
          rem Divide 120 by character weight using repeated subtraction
          let temp2 = 120
          let temp3 = CFD_characterWeight
          gosub DivideByVariable
          let CFD_safeThreshold = temp2 
          rem Safe fall velocity threshold
          
          rem Check if fall velocity exceeds safe threshold
          if CFD_fallVelocity <= CFD_safeThreshold then return 
          rem Safe landing, no damage
          
          rem Check if player is guarding - guard does NOT block fall damage
          rem Guard only blocks attack damage (missiles, AOE), not environmental damage
          rem Fall damage is environmental, so guard does not protect
          
          rem Calculate fall damage
          rem Base damage = (velocity - safe_velocity) * base_damage_multiplier
          rem Base damage multiplier: 2 (so 1 extra velocity = 2 base damage)
          let CFD_damage = CFD_fallVelocity - CFD_safeThreshold
          rem Multiply by 2 using bit shift left
          asl CFD_damage
          rem CFD_damage = CFD_damage * 2
          
          rem Apply weight-based damage multiplier: "the bigger they are, the harder they fall"
          rem Heavy characters take more damage for the same impact velocity
          rem Formula: damage_multiplier = weight / 20 (average weight)
          rem Light (10): 10/20 = 0.5x damage, Average (20): 20/20 = 1.0x, Heavy (30): 30/20 = 1.5x
          rem Using integer math: damage = damage * weight / 20
          rem Use damageWeightProduct for intermediate calculation
          rem Multiply damage by weight using repeated addition
          let temp2 = CFD_damage
          let temp3 = CFD_characterWeight
          gosub MultiplyByVariable
          let damageWeightProduct = temp2
          rem damageWeightProduct = damage * weight
          rem Divide by 20 using helper
          let temp2 = damageWeightProduct
          gosub DivideBy20
          let CFD_damage = temp2
          rem CFD_damage = damage * weight / 20 (weight-based multiplier applied)
          
          rem Apply damage reduction for Ninjish Guy (after weight multiplier)
          if CFD_characterType = CharNinjishGuy then lsr CFD_damage
          rem Ninjish Guy: 1/2 damage (divide by 2 using bit shift right)
          
          rem Cap maximum fall damage at 50
          if CFD_damage > 50 then let CFD_damage = 50
          
          rem Apply fall damage (byte-safe clamp)
          rem Use oldHealthValue for byte-safe clamp check
          let oldHealthValue = playerHealth[CFD_playerIndex]
          let playerHealth[CFD_playerIndex] = playerHealth[CFD_playerIndex] - CFD_damage
          if playerHealth[CFD_playerIndex] > oldHealthValue then playerHealth[CFD_playerIndex] = 0
          
          rem Set recovery frames (proportional to damage, min 10, max 30)
          rem Use recoveryFramesCalc for recovery frames calculation
          let recoveryFramesCalc = CFD_damage
          lsr recoveryFramesCalc
          rem Divide by 2 using bit shift right
          if recoveryFramesCalc < 10 then recoveryFramesCalc = 10
          if recoveryFramesCalc > 30 then recoveryFramesCalc = 30
          playerRecoveryFrames[CFD_playerIndex] = recoveryFramesCalc
          
          rem Synchronize playerState bit 3 with recovery frames
          playerState[CFD_playerIndex] = playerState[CFD_playerIndex] | 8
          rem Set bit 3 (recovery flag) when recovery frames are set
          
          rem Set animation state to "recovering from fall"
          rem This is animation state 9 in the character animation sequences
          rem playerState bits: [7:animation][4:attacking][2:jumping][1:guarding][0:facing]
          rem Set bits 7-5 to 9 (recovering animation)
          rem Use playerStateTemp for state manipulation
          let playerStateTemp = playerState[CFD_playerIndex] & MaskPlayerStateLower 
          rem Keep lower 5 bits
          let playerStateTemp = playerStateTemp | MaskAnimationRecovering 
          rem Set animation to 9 (1001 in bits 7-4)
          playerState[CFD_playerIndex] = playerStateTemp
          
          rem Play fall damage sound effect
          temp1 = SoundFall
          gosub bank15 PlaySoundEffect
          
          rem Trigger color shift to darker shade (damage visual feedback)
          rem This is handled by PlayerRendering.bas using playerRecoveryFrames
          
          return

          rem =================================================================
          rem APPLY GRAVITY
          rem =================================================================
          rem Applies gravity acceleration to a player each frame.
          rem Handles character-specific gravity rates and terminal velocity.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = current vertical momentum (positive = down)

          rem OUTPUT:
          rem   temp2 = updated vertical momentum
FallDamageApplyGravity
          rem Get character type
          temp5 = playerChar[temp1]
          
          rem Check for no-gravity characters
          if temp5 = CharFrooty then return 
          rem Frooty: no gravity
          if temp5 = CharDragonOfStorms then return
          rem Dragon of Storms: no gravity (hovering/flying like Frooty)
          
          rem Check for reduced gravity characters
          rem Harpy (6): 1/2 gravity when falling
          temp6 = 2 
          rem Default gravity: 2 pixels/frame²
          if temp5 = CharHarpy then temp6 = 1 
          rem Harpy: reduced gravity
          
          rem Apply gravity acceleration
          temp2 = temp2 + temp6
          
          rem Cap at terminal velocity (uses tunable constant from Constants.bas)
          if temp2 > TerminalVelocity then temp2 = TerminalVelocity
          
          return

          rem =================================================================
          rem CHECK GROUND COLLISION
          rem =================================================================
          rem Checks if player has landed on ground or platform.
          rem Calls CheckFallDamage if landing detected.

          rem INPUT:
          rem   temp1 = player index (0-3)
          rem   temp2 = vertical momentum before position update

          rem This routine should be called AFTER vertical position update
          rem but BEFORE momentum is cleared, so we can detect the landing
          rem velocity for fall damage calculation.
CheckGroundCollision
          rem Get player Y position
          temp3 = playerY[temp1]
          
          rem Check if player is at or below ground level
          rem Ground level is at Y = 176 (bottom of playfield, leaving room for sprite)
          if temp3 >= 176 then
                    rem Player hit ground
                    rem Clamp position to ground
                    playerY[temp1] = 176
                    
                    rem Check fall damage if moving downward
                    if temp2 > 0 then
                              rem temp2 contains downward velocity
                              gosub CheckFallDamage
          
                    
                    rem Stop vertical momentum
                    rem Note: This assumes vertical momentum is being tracked
                    rem In current implementation, this might need integration
                    rem with PlayerPhysics.bas
                    return
          
          
          rem Check collision with platforms/playfield
          rem This is handled by the main collision detection system
          rem Use pfread to detect solid ground beneath player
          rem Convert player X/Y to playfield coordinates
          rem If standing on platform, perform same landing logic
          
          return

          rem =================================================================
          rem HANDLE FROOTY VERTICAL CONTROL
          rem =================================================================
          rem Frooty has no gravity and can move up/down freely.
          rem Down button moves down (no guard action).

          rem INPUT:
          rem   temp1 = player index (0-3, but should only be called for Frooty)

          rem This should be called from PlayerInput.bas when processing
          rem joystick up/down for Frooty.
HandleFrootyVertical
          rem Check character type to confirm
          temp5 = playerChar[temp1]
          if !(temp5 = CharFrooty) then return 
          rem Not Frooty
          
          rem Get joystick state
          rem This needs to be integrated with PlayerInput.bas
          rem Fall damage calculation based on character weight
          
          rem If joyup pressed: move up
          rem playerY[temp1] = playerY[temp1] - 2
          
          rem If joydown pressed: move down (replaces guard action)
          rem playerY[temp1] = playerY[temp1] + 2
          
          rem Clamp to screen bounds
          rem Byte-safe clamp: if wrapped below 0, the new value will exceed the old
          oldHealthValue = playerY[temp1]
          rem Reuse oldHealthValue for byte-safe clamp check (not actually health, but same pattern)
          if playerY[temp1] > oldHealthValue then playerY[temp1] = 0
          if playerY[temp1] > 176 then playerY[temp1] = 176
          
          return

          rem =================================================================
          rem HANDLE HARPY SWOOP ATTACK
          rem =================================================================
          rem Harpy attack causes an instant redirection into a rapid
          rem downward diagonal strike at ~45° to the facing direction.

          rem INPUT:
          rem   temp1 = player index (0-3, but should only be called for Harpy)

          rem OUTPUT:
          rem   Sets player momentum for diagonal downward swoop
HandleHarpySwoopAttack
          rem Check character type to confirm
          temp5 = playerChar[temp1]
          if !(temp5 = CharHarpy) then return 
          rem Not Harpy
          
          rem Get facing direction from playerState bit 0
          temp6 = playerState[temp1] & 1
          
          rem Set diagonal momentum at ~45° angle
          rem Horizontal: 4 pixels/frame (in facing direction)
          rem Vertical: 4 pixels/frame (downward)
          if temp6 = 0 then SetHorizontalMomentumRight
          rem Facing left: set negative momentum (252 = -4 in signed 8-bit)
          playerVelocityX[temp1] = 252
          goto SetVerticalMomentum
SetHorizontalMomentumRight
          rem Facing right: set positive momentum
          playerVelocityX[temp1] = 4
SetVerticalMomentum
          
          
          rem Set downward momentum (using temp variable for now)
          rem Integrate with vertical momentum system
          rem This is handled by PlayerPhysics.bas
          rem This needs to override normal gravity temporarily
          rem Suggest adding PlayerMomentumY variable or state flag
          
          rem Set animation state to "swooping attack"
          rem This could be animation state 10 or special attack animation
          temp6 = playerState[temp1] & MaskPlayerStateLower
          temp6 = temp6 | MaskAnimationFalling 
          rem Animation state 10
          playerState[temp1] = temp6
          
          rem Spawn melee attack missile for swoop hit detection
          gosub bank7 SpawnMissile
          
          return

          rem =================================================================
          rem DIVISION/MULTIPLICATION HELPERS (NO MUL/DIV SUPPORT)
          rem =================================================================
          rem Helper routines using optimized assembly for fast division/multiplication
          rem Based on Omegamatrix's optimized 6502 routines from AtariAge forums
          rem These routines use bit manipulation and carry-based arithmetic for speed
          rem Thanks to Omegamatrix and AtariAge forum contributors for these routines
          
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
          
          rem =================================================================
          rem CALCULATE SAFE FALL DISTANCE
          rem =================================================================
          rem Utility routine to calculate safe fall distance for a character.
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
          rem Divide 120 by weight using repeated subtraction
          let temp2 = 120
          let temp3 = temp6
          gosub DivideByVariable
          let temp3 = temp2
          rem temp3 = Safe velocity threshold
          
          rem Convert velocity to distance
          rem Using kinematic equation: v² = 2 * g * d
          rem Rearranged: d = v² / (2 * g)
          rem With g = 2: d = v² / 4
          rem Multiply temp3 by temp3 (square) using repeated addition
          let temp2 = temp3
          let temp4 = temp3
          gosub MultiplyByVariable
          rem temp2 = temp3 * temp3 (v²)
          rem Divide by 4 using bit shift right twice
          lsr temp2
          lsr temp2
          rem temp2 = v² / 4
          
          rem Apply Ninjish Guy bonus (can fall farther)
          if temp5 = CharNinjishGuy then asl temp2
          rem Multiply by 2 using bit shift left
          
          return

