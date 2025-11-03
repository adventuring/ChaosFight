          rem ChaosFight - Source/Routines/Physics.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem =================================================================
          rem PHYSICS SYSTEM - Weight-based wall collisions and movement
          rem =================================================================

          rem Handle weight-based wall collision for a player
          rem Input: HWC_playerID = participant array index (0-3 maps to participants 1-4)
          rem Modifies: Player momentum based on character weight
          rem Weight affects: wall bounce coefficient (heavier = less bounce)
HandleWallCollision
          rem Define local variable aliases for clarity
          dim HWC_playerID = temp1
          dim HWC_bouncedMomentum = temp2
          dim HWC_characterWeight = temp3
          dim HWC_characterType = temp4
          dim HWC_playerMomentum = temp4  rem Note: temp4 reused sequentially for character type then momentum
          
          rem Get character type for this player using direct array access
          let HWC_characterType = PlayerChar[HWC_playerID]

          rem Get character weight using direct array access
          let HWC_characterWeight = CharacterWeights[HWC_characterType]

          rem Weight is now in HWC_characterWeight (0-40)
          rem Calculate bounce coefficient: higher weight = lower bounce
          rem Formula: bounce = 50 - weight / 2
          rem Lighter characters bounce more, heavier characters bounce less
          rem Example weights: 12 (light) = 44 bounce, 40 (heavy) = 30 bounce

          rem Get player momentum using direct array access (temp4 now reused for momentum)
          let HWC_playerMomentum = PlayerMomentumX[HWC_playerID]

          rem Calculate bounced momentum: momentum = momentum * bounce / 50
          rem Using integer math: momentum = (momentum * bounce) / 50
          let HWC_bouncedMomentum = HWC_playerMomentum * (50 - HWC_characterWeight / 2) / 50
          if !HWC_bouncedMomentum && HWC_playerMomentum then let HWC_bouncedMomentum = 1
          rem Ensure at least 1 if was moving
          let PlayerMomentumX[HWC_playerID] = HWC_bouncedMomentum
          return

          rem Check if player hit left wall and needs weight-based bounce
          rem Input: CLWC_playerID = participant array index (0-3 maps to participants 1-4)
CheckLeftWallCollision
          rem Define local variable aliases for clarity
          dim CLWC_playerID = temp1
          dim CLWC_playerX = temp4
          
          let CLWC_playerX = PlayerX[CLWC_playerID]
          if CLWC_playerX < 10 then let HWC_playerID = CLWC_playerID : gosub HandleWallCollision : let CLWC_playerX = PlayerX[CLWC_playerID] : if CLWC_playerX < 10 then let PlayerX[CLWC_playerID] = 10
          return

          rem Check if player hit right wall and needs weight-based bounce
          rem Input: CRWC_playerID = participant array index (0-3 maps to participants 1-4)
CheckRightWallCollision
          rem Define local variable aliases for clarity
          dim CRWC_playerID = temp1
          dim CRWC_playerX = temp4
          
          let CRWC_playerX = PlayerX[CRWC_playerID]
          if CRWC_playerX > 150 then let HWC_playerID = CRWC_playerID : gosub HandleWallCollision : let CRWC_playerX = PlayerX[CRWC_playerID] : if CRWC_playerX > 150 then let PlayerX[CRWC_playerID] = 150
          return

          rem Note: GetPlayerMomentumSub and SetPlayerMomentumSub removed
          rem Now using direct array access: PlayerMomentumX[playerID]

          rem =================================================================
          rem CHARACTER WEIGHTS DATA
          rem =================================================================
          rem Reference to weights from CharacterDefinitions.bas
          rem This is just for documentation - actual weights are read from CharacterWeights array

          rem Character weights affect:
          rem   - Wall bounce coefficient (heavier = less bounce)
          rem   - Movement speed resistance
          rem   - Impact resistance

          rem Character order (IDs 0..15) must match CharacterDefinitions.bas:
          rem 0 Bernie, 1 Curler, 2 Dragon of Storms, 3 Zoe Ryen,
          rem 4 Fat Tony, 5 Megax, 6 Harpy, 7 Knight Guy,
          rem 8 Frooty, 9 Nefertem, 10 Ninjish Guy, 11 Pork Chop,
          rem 12 Radish Goblin, 13 Robo Tito, 14 Ursulo, 15 Shamone