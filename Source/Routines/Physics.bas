HandleWallCollision
          rem
          rem ChaosFight - Source/Routines/Physics.bas
          rem Copyright (c) 2025 Interworldly Adventuring, LLC.
          rem PHYSICS SYSTEM - Weight-based Wall Collisions And Movement
          rem Handle weight-based wall collision for a player
          rem
          rem Input: player index (in temp1)
          rem Modifies: Player momentum based on character weight
          rem Weight affects: wall bounce coefficient (heavier = less
          rem   bounce)
          rem Handle weight-based wall collision for a player (modifies
          rem momentum based on character weight)
          rem
          rem Input: temp1 = player index (0-3), playerCharacter[] (global
          rem array) = character types, playerVelocityX[] (global array)
          rem = X velocities, CharacterWeights[] (global data table) =
          rem character weights
          rem
          rem Output: X velocity adjusted based on weight-based bounce
          rem coefficient
          rem
          rem Mutates: temp2-temp4 (used for calculations),
          rem playerVelocityX[] (global array) = X velocity (adjusted
          rem for bounce)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Weight affects wall bounce coefficient
          rem (heavier = less bounce). Formula: bounce = 50 - weight /
          rem 2. Ensures at least 1 pixel/frame velocity if was moving
          rem Get character type for this player using direct array
          rem   access
          rem temp1 contains player index (0-3)
          temp4 = playerCharacter[temp1]
          
          rem Get character weight using direct array access
          temp3 = CharacterWeights[temp4]
          
          rem Weight is now in temp3 (0-40)
          rem Calculate bounce coefficient: higher weight = lower bounce
          rem Formula: bounce = 50 - weight / 2
          rem Lighter characters bounce more, heavier characters bounce
          rem   less
          rem Example weights: 12 (light) = 44 bounce, 40 (heavy) = 30
          rem   bounce
          
          rem Get player velocity using direct array access
          temp4 = playerVelocityX[temp1]
          
          rem Calculate bounced velocity: velocity = velocity * bounce /
          rem   50
          rem Using integer math: velocity = (velocity * bounce) / 50
          temp2 = temp4 * (50 - temp3 / 2) / 50
          if temp2 = 0 && temp4 then temp2 = 1
          rem Ensure at least 1 if was moving
          let playerVelocityX[temp1] = temp2
          return

CheckLeftWallCollision
          rem Check if player hit left wall; apply weight-based bounce.
          rem Input: temp1 = player index (0-3), playerX[], playerCharacter[],
          rem        playerVelocityX[], CharacterWeights[]
          rem
          rem Output: Player bounced if hit left wall (X < PlayerLeftEdge),
          rem position clamped to PlayerLeftEdge if still out of bounds
          rem
          rem Mutates: temp4 (used for calculations), playerX[] (global
          rem array) = player X position (clamped to PlayerLeftEdge if needed),
          rem playerVelocityX[] (global array) = X velocity (adjusted
          rem via HandleWallCollision)
          rem
          rem Called Routines: HandleWallCollision - applies
          rem weight-based bounce
          rem
          rem Constraints: Left wall boundary is X = PlayerLeftEdge
          temp4 = playerX[temp1]
          if temp4 < PlayerLeftEdge then gosub HandleWallCollision : temp4 = playerX[temp1] : if temp4 < PlayerLeftEdge then let playerX[temp1] = PlayerLeftEdge
          return

CheckRightWallCollision
          rem Check if player hit right wall; apply weight-based bounce.
          rem Input: temp1 = player index (0-3), playerX[], playerCharacter[],
          rem        playerVelocityX[], CharacterWeights[]
          rem
          rem Output: Player bounced if hit right wall (X > PlayerRightEdge),
          rem position clamped to PlayerRightEdge if still out of bounds
          rem
          rem Mutates: temp4 (used for calculations), playerX[] (global
          rem array) = player X position (clamped to PlayerRightEdge if needed),
          rem playerVelocityX[] (global array) = X velocity (adjusted
          rem via HandleWallCollision)
          rem
          rem Called Routines: HandleWallCollision - applies
          rem weight-based bounce
          rem
          rem Constraints: Right wall boundary is X = PlayerRightEdge
          temp4 = playerX[temp1]
          if temp4 > PlayerRightEdge then gosub HandleWallCollision : temp4 = playerX[temp1] : if temp4 > PlayerRightEdge then let playerX[temp1] = PlayerRightEdge
          return

          rem
          rem Note: GetPlayerVelocitySub and SetPlayerVelocitySub
          rem   removed
          rem Now using direct array access: playerVelocityX[temp1]

          rem Character Weights Data
          rem Reference to weights from CharacterDefinitions.bas
          rem This is just for documentation - actual weights are read
          rem   from CharacterWeights array

          rem Character weights affect:
          rem   - Wall bounce coefficient (heavier = less bounce)
          rem   - Movement speed resistance
          rem   - Impact resistance

          rem Character order (IDs 0..15) must match
          rem   CharacterDefinitions.bas:
          rem 0 Bernie, 1 Curler, 2 Dragon of Storms, 3 Zoe Ryen,
          rem 4 Fat Tony, 5 Megax, 6 Harpy, 7 Knight Guy,
          rem 8 Frooty, 9 Nefertem, 10 Ninjish Guy, 11 Pork Chop,
          rem 12 Radish Goblin, 13 Robo Tito, 14 Ursulo, 15 Shamone
