HandleWallCollision
          rem
          rem ChaosFight - Source/Routines/Physics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem PHYSICS SYSTEM - Weight-based Wall Collisions And Movement
          rem Handle weight-based wall collision for a player
          rem Input: player index (in temp1)
          rem Modifies: Player momentum based on character weight
          rem Weight affects: wall bounce coefficient (heavier = less
          rem   bounce)
          rem Handle weight-based wall collision for a player (modifies momentum based on character weight)
          rem Input: temp1 = player index (0-3), playerChar[] (global array) = character types, playerVelocityX[] (global array) = X velocities, CharacterWeights[] (global data table) = character weights
          rem Output: X velocity adjusted based on weight-based bounce coefficient
          rem Mutates: temp2-temp4 (used for calculations), playerVelocityX[] (global array) = X velocity (adjusted for bounce)
          rem Called Routines: None
          rem Constraints: Weight affects wall bounce coefficient (heavier = less bounce). Formula: bounce = 50 - weight / 2. Ensures at least 1 pixel/frame velocity if was moving
          rem Get character type for this player using direct array
          rem   access
          let temp4 = playerChar[temp1] : rem temp1 contains player index (0-3)
          
          let temp3 = CharacterWeights[temp4] : rem Get character weight using direct array access
          
          rem Weight is now in temp3 (0-40)
          rem Calculate bounce coefficient: higher weight = lower bounce
          rem Formula: bounce = 50 - weight / 2
          rem Lighter characters bounce more, heavier characters bounce
          rem   less
          rem Example weights: 12 (light) = 44 bounce, 40 (heavy) = 30
          rem   bounce
          
          let temp4 = playerVelocityX[temp1] : rem Get player velocity using direct array access
          
          rem Calculate bounced velocity: velocity = velocity * bounce /
          rem   50
          rem Using integer math: velocity = (velocity * bounce) / 50
          let temp2 = temp4 * (50 - temp3 / 2) / 50
          if temp2 = 0 && temp4 then let temp2 = 1
          let playerVelocityX[temp1] = temp2 : rem Ensure at least 1 if was moving
          return

CheckLeftWallCollision
          rem Check if player hit left wall and needs weight-based
          rem   bounce
          rem Input: player index (in temp1)
          rem Check if player hit left wall and needs weight-based bounce
          rem Input: temp1 = player index (0-3), playerX[] (global array) = player X positions, playerChar[] (global array) = character types, playerVelocityX[] (global array) = X velocities, CharacterWeights[] (global data table) = character weights
          rem Output: Player bounced if hit left wall (X < 10), position clamped to 10 if still out of bounds
          rem Mutates: temp4 (used for calculations), playerX[] (global array) = player X position (clamped to 10 if needed), playerVelocityX[] (global array) = X velocity (adjusted via HandleWallCollision)
          rem Called Routines: HandleWallCollision - applies weight-based bounce
          rem Constraints: Left wall boundary is X = 10
          let temp4 = playerX[temp1]
          if temp4 < 10 then gosub HandleWallCollision : let temp4 = playerX[temp1] : if temp4 < 10 then let playerX[temp1] = 10
          return

CheckRightWallCollision
          rem Check if player hit right wall and needs weight-based
          rem   bounce
          rem Input: player index (in temp1)
          rem Check if player hit right wall and needs weight-based bounce
          rem Input: temp1 = player index (0-3), playerX[] (global array) = player X positions, playerChar[] (global array) = character types, playerVelocityX[] (global array) = X velocities, CharacterWeights[] (global data table) = character weights
          rem Output: Player bounced if hit right wall (X > 150), position clamped to 150 if still out of bounds
          rem Mutates: temp4 (used for calculations), playerX[] (global array) = player X position (clamped to 150 if needed), playerVelocityX[] (global array) = X velocity (adjusted via HandleWallCollision)
          rem Called Routines: HandleWallCollision - applies weight-based bounce
          rem Constraints: Right wall boundary is X = 150
          let temp4 = playerX[temp1]
          if temp4 > 150 then gosub HandleWallCollision : let temp4 = playerX[temp1] : if temp4 > 150 then let playerX[temp1] = 150
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