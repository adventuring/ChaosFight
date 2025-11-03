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
          rem   - Ninjish Guy (10): 1/2 fall damage (reduced)
          rem   - Harpy (6): Reduced gravity (1/2 rate) when falling
          rem   - Dragon of Storms (2): Reduced gravity (1/2 rate) when falling

          rem GRAVITY CONSTANTS:
          rem   - Normal gravity: 2 pixels/frame acceleration
          rem   - Reduced gravity (Harpy/Dragon of Storms): 1 pixel/frame
          rem   - Terminal velocity: 8 pixels/frame (cap on fall speed)

          rem VARIABLES USED:
          rem   - playerY[0-3]: Vertical position
          rem   - PlayerMomentumY (temporary): Vertical velocity
          rem   - playerRecoveryFrames[0-3]: Hitstun/recovery timer
          rem   - playerHealth[0-3]: Health to reduce
          rem   - currentPlayer: Player index
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
          rem   currentPlayer = player index (0-3)
          rem   temp2 = vertical velocity at landing (positive = downward)

          rem PROCESS:
          rem   1. Get character type and weight
          rem   2. Check for fall damage immunity
          rem   3. Calculate safe fall velocity threshold
          rem   4. Calculate fall damage if exceeded
          rem   5. Apply damage, recovery frames, and color shift
CheckFallDamage
          rem Get character type for this player
          temp5 = playerChar[currentPlayer]
          
          rem Check for fall damage immunity
          if temp5 = 0 then return 
          rem Bernie: immune
          if temp5 = 13 then return
          rem Robo Tito: immune
          if temp5 = 8 then return 
          rem Frooty: no gravity, no falling
          
          rem Get character weight from data table
          currentPlayer = temp5 
          rem Character type as index
          gosub GetCharacterWeight
          temp6 = temp2 
          rem Store weight
          
          rem Calculate safe fall velocity threshold
          rem Formula: safe_velocity = base_safe_velocity * (average_weight / character_weight)
          rem Base safe velocity for average weight (20): ~6 pixels/frame
          rem This corresponds to falling ~1/3 screen height (64 pixels)
          rem Using simplified calculation: safe_velocity = 120 / weight
          rem Average (20): 120/20 = 6
          rem Light (10): 120/10 = 12 (can fall farther)
          rem Heavy (30): 120/30 = 4 (takes damage sooner)
          temp3 = 120 / temp6 
          rem Safe fall velocity threshold
          
          rem Check if fall velocity exceeds safe threshold
          if temp2 <= temp3 then return 
          rem Safe landing, no damage
          
          rem Calculate fall damage
          rem Damage = (velocity - safe_velocity) * damage_multiplier
          rem Damage multiplier: 2 (so 1 extra velocity = 2 damage)
          temp4 = temp2 - temp3
          temp4 = temp4 * 2
          
          rem Apply damage reduction for Ninjish Guy
          if temp5 = 10 then temp4 = temp4 / 2 
          rem Ninjish Guy: 1/2 damage
          
          rem Cap maximum fall damage at 50
          if temp4 > 50 then temp4 = 50
          
          rem Apply fall damage (byte-safe clamp)
          temp6 = playerHealth[currentPlayer]
          let playerHealth[currentPlayer] = playerHealth[currentPlayer] - temp4
          if playerHealth[currentPlayer] > temp6 then playerHealth[currentPlayer] = 0
          
          rem Set recovery frames (proportional to damage, min 10, max 30)
          temp5 = temp4 / 2
          if temp5 < 10 then temp5 = 10
          if temp5 > 30 then temp5 = 30
          let playerRecoveryFrames[currentPlayer] = temp5
          
          rem Set animation state to "recovering from fall"
          rem This is animation state 9 in the character animation sequences
          rem playerState bits: [7:animation][4:attacking][2:jumping][1:guarding][0:facing]
          rem Set bits 7-5 to 9 (recovering animation)
          temp6 = playerState[currentPlayer] & %00011111 
          rem Keep lower 5 bits
          temp6 = temp6 | %10010000 
          rem Set animation to 9 (1001 in bits 7-4)
          let playerState[currentPlayer] = temp6
          
          rem Play fall damage sound effect
          currentPlayer = SoundFall
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
          rem   currentPlayer = player index (0-3)
          rem   temp2 = current vertical momentum (positive = down)

          rem OUTPUT:
          rem   temp2 = updated vertical momentum
FallDamageApplyGravity
          rem Get character type
          temp5 = playerChar[currentPlayer]
          
          rem Check for no-gravity characters
          if temp5 = 8 then return 
          rem Frooty: no gravity
          
          rem Check for reduced gravity characters
          rem Harpy (6) and Dragon of Storms (2): 1/2 gravity when falling
          temp6 = 2 
          rem Default gravity: 2 pixels/frame²
          if temp5 = 6 then temp6 = 1 
          rem Harpy: reduced gravity
          if temp5 = 2 then temp6 = 1 
          rem Dragon of Storms: reduced gravity
          
          rem Apply gravity acceleration
          temp2 = temp2 + temp6
          
          rem Cap at terminal velocity (8 pixels/frame)
          if temp2 > 8 then temp2 = 8
          
          return

          rem =================================================================
          rem CHECK GROUND COLLISION
          rem =================================================================
          rem Checks if player has landed on ground or platform.
          rem Calls CheckFallDamage if landing detected.

          rem INPUT:
          rem   currentPlayer = player index (0-3)
          rem   temp2 = vertical momentum before position update

          rem This routine should be called AFTER vertical position update
          rem but BEFORE momentum is cleared, so we can detect the landing
          rem velocity for fall damage calculation.
CheckGroundCollision
          rem Get player Y position
          temp3 = playerY[currentPlayer]
          
          rem Check if player is at or below ground level
          rem Ground level is at Y = 176 (bottom of playfield, leaving room for sprite)
          if temp3 >= 176 then
                    rem Player hit ground
                    rem Clamp position to ground
                    let playerY[currentPlayer] = 176
                    
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
          rem   currentPlayer = player index (0-3, but should only be called for Frooty)

          rem This should be called from PlayerInput.bas when processing
          rem joystick up/down for Frooty.
HandleFrootyVertical
          rem Check character type to confirm
          temp5 = playerChar[currentPlayer]
          if temp5 <> 8 then return 
          rem Not Frooty
          
          rem Get joystick state
          rem This needs to be integrated with PlayerInput.bas
          rem Fall damage calculation based on character weight
          
          rem If joyup pressed: move up
          rem playerY[currentPlayer] = playerY[currentPlayer] - 2
          
          rem If joydown pressed: move down (replaces guard action)
          rem playerY[currentPlayer] = playerY[currentPlayer] + 2
          
          rem Clamp to screen bounds
          rem Byte-safe clamp: if wrapped below 0, the new value will exceed the old
          let temp7 = playerY[currentPlayer]
          if playerY[currentPlayer] > temp7 then playerY[currentPlayer] = 0
          if playerY[currentPlayer] > 176 then playerY[currentPlayer] = 176
          
          return

          rem =================================================================
          rem HANDLE HARPY SWOOP ATTACK
          rem =================================================================
          rem Harpy attack causes an instant redirection into a rapid
          rem downward diagonal strike at ~45° to the facing direction.

          rem INPUT:
          rem   currentPlayer = player index (0-3, but should only be called for Harpy)

          rem OUTPUT:
          rem   Sets player momentum for diagonal downward swoop
HandleHarpySwoopAttack
          rem Check character type to confirm
          temp5 = playerChar[currentPlayer]
          if temp5 <> 6 then return 
          rem Not Harpy
          
          rem Get facing direction from playerState bit 0
          temp6 = playerState[currentPlayer] & 1
          
          rem Set diagonal momentum at ~45° angle
          rem Horizontal: 4 pixels/frame (in facing direction)
          rem Vertical: 4 pixels/frame (downward)
          if temp6 = 0 then playerMomentumX[currentPlayer] = 252 : goto SetVerticalMomentum
                    rem Facing right
                    let playerMomentumX[currentPlayer] = 4
SetVerticalMomentum
          
          
          rem Set downward momentum (using temp variable for now)
          rem Integrate with vertical momentum system
          rem This is handled by PlayerPhysics.bas
          rem This needs to override normal gravity temporarily
          rem Suggest adding PlayerMomentumY variable or state flag
          
          rem Set animation state to "swooping attack"
          rem This could be animation state 10 or special attack animation
          temp6 = playerState[currentPlayer] & %00011111
          temp6 = temp6 | %10100000 
          rem Animation state 10
          let playerState[currentPlayer] = temp6
          
          rem Spawn melee attack missile for swoop hit detection
          gosub bank15 SpawnMissile
          
          return

          rem =================================================================
          rem CALCULATE SAFE FALL DISTANCE
          rem =================================================================
          rem Utility routine to calculate safe fall distance for a character.
          rem Used for AI and display purposes.

          rem INPUT:
          rem   currentPlayer = player index (0-3)

          rem OUTPUT:
          rem   temp2 = safe fall distance in pixels
CalculateSafeFallDistance
          rem Get character type and weight
          temp5 = playerChar[currentPlayer]
          
          rem Check for fall damage immunity
          if temp5 = 0 then temp2 = 255 : return 
          rem Bernie: infinite
          if temp5 = 13 then temp2 = 255 : return
          rem Robo Tito: infinite
          if temp5 = 8 then temp2 = 255 : return 
          rem Frooty: no falling
          
          rem Get character weight
          currentPlayer = temp5 
          rem Character type as index
          gosub GetCharacterWeight
          temp6 = temp2 
          rem Store weight
          
          rem Calculate safe fall velocity (from CheckFallDamage logic)
          temp3 = 120 / temp6 
          rem Safe velocity threshold
          
          rem Convert velocity to distance
          rem Using kinematic equation: v² = 2 * g * d
          rem Rearranged: d = v² / (2 * g)
          rem With g = 2: d = v² / 4
          temp2 = temp3 * temp3
          temp2 = temp2 / 4
          
          rem Apply Ninjish Guy bonus (can fall farther)
          if temp5 = 10 then temp2 = temp2 * 2
          
          return

