          rem ChaosFight - Source/Routines/Physics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem PHYSICS SYSTEM - Weight-based wall collisions and movement
          rem =================================================================

          rem Handle weight-based wall collision for a player
          rem Input: player index (in temp1)
          rem Modifies: Player momentum based on character weight
          rem Weight affects: wall bounce coefficient (heavier = less bounce)
HandleWallCollision
          rem Get character type for this player using direct array access
          rem temp1 contains player index (0-3)
          temp4 = PlayerChar[temp1]
          
          rem Get character weight using direct array access
          temp3 = CharacterWeights[temp4]
          
          rem Weight is now in temp3 (0-40)
          rem Calculate bounce coefficient: higher weight = lower bounce
          rem Formula: bounce = 50 - weight / 2
          rem Lighter characters bounce more, heavier characters bounce less
          rem Example weights: 12 (light) = 44 bounce, 40 (heavy) = 30 bounce
          
          rem Get player momentum using direct array access
          temp4 = PlayerMomentumX[temp1]
          
          rem Calculate bounced momentum: momentum = momentum * bounce / 50
          rem Using integer math: momentum = (momentum * bounce) / 50
          temp2 = temp4 * (50 - temp3 / 2) / 50
          if temp2 = 0 && temp4 <> 0 then temp2 = 1
          rem Ensure at least 1 if was moving
          PlayerMomentumX[temp1] = temp2
          return

          rem Check if player hit left wall and needs weight-based bounce
          rem Input: player index (in temp1)
CheckLeftWallCollision
          temp4 = PlayerX[temp1]
          if temp4 < 10 then gosub HandleWallCollision : temp4 = PlayerX[temp1] : if temp4 < 10 then PlayerX[temp1] = 10
          return

          rem Check if player hit right wall and needs weight-based bounce
          rem Input: player index (in temp1)
CheckRightWallCollision
          temp4 = PlayerX[temp1]
          if temp4 > 150 then gosub HandleWallCollision : temp4 = PlayerX[temp1] : if temp4 > 150 then PlayerX[temp1] = 150
          return

          rem Note: GetPlayerMomentumSub and SetPlayerMomentumSub removed
          rem Now using direct array access: PlayerMomentumX[temp1]

          rem =================================================================
          rem CHARACTER WEIGHTS DATA
          rem =================================================================
          rem Reference to weights from CharacterDefinitions.bas
          rem This is just for documentation - actual weights are read from CharacterWeights array

          rem Character weights affect:
          rem   - Wall bounce coefficient (heavier = less bounce)
          rem   - Movement speed resistance
          rem   - Impact resistance

          rem Weight values (from CharacterDefinitions.bas):
          rem Bernie: 21, Curling: 25, Dragonet: 20, EXO Pilot: 23
          rem Fat Tony: 22, Megax: 20, Harpy: 19, Knight Guy: 12
          rem Magical Faerie: 17, Mystery Man: 18, Ninjish Guy: 40, Pork Chop: 15
          rem Radish Goblin: 19, Robo Tito: 18, Ursulo: 16, Veg Dog: 17