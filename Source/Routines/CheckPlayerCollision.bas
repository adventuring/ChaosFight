          rem ChaosFight - Source/Routines/CheckPlayerCollision.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckPlayerCollision
          rem
          rem Collision Detection With Subpixel Precision
          rem Check collision between two players using integer
          rem   positions
          rem
          rem Input: temp1 = player 1 index → temp1
          rem        temp2 = player 2 index → temp2
          rem
          rem Output: temp3 = 1 if collision, 0 if not →
          rem temp3
          rem NOTE: Uses integer positions only (subpixel ignored for
          rem   collision)
          rem
          rem MUTATES:
          rem   temp3 = temp3 (return value: 1 if collision, 0 if not)
          rem   temp4-temp13 = Used internally for calculations
          rem WARNING: Callers should read temp3 immediately; helper mutates temps for calculations.
          rem
          rem Input: temp1 = player 1 index (0-3), temp2 = player 2
          rem index (0-3), playerX[], playerY[] (global arrays) = player
          rem positions, playerCharacter[] (global array) = character types,
          rem CharacterHeights[] (global data table) = character heights
          rem
          rem Output: temp3 = 1 if collision, 0 if not
          rem
          rem Mutates: temp3-temp6 (used for calculations, temp4-5
          rem reused after X/Y checks)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Uses integer positions only (subpixel ignored
          rem for collision). Checks X collision (16 pixel width) and Y
          rem collision (using CharacterHeights table). WARNING: temp3 is mutated during the routine; callers must read it immediately.
          rem Uses temp1-temp6 (temp4-5 reused after X/Y checks)

          rem Load player X positions into temporaries
          let temp4 = playerX[temp1]
          let temp5 = playerX[temp2]

          rem Calculate absolute X distance between players
          rem Primary holds player1 X initially
          if temp4 >= temp5 then CalcXDistanceRight
          let temp6 = temp5 - temp4
          goto XDistanceDone
CalcXDistanceRight
          let temp6 = temp4 - temp5
XDistanceDone
          if temp6 >= PlayerSpriteWidth then NoCollision

          rem Load player Y positions (reuse temporaries)
          let temp4 = playerY[temp1]
          let temp5 = playerY[temp2]

          rem Fetch character half-height values using shared SCRAM scratch variables
          let characterIndex = playerCharacter[temp1]
          let characterHeight = CharacterHeights[characterIndex]
          rem Use bit shift instead of division (optimized for Atari 2600)
          asm
            lda characterHeight
            lsr
            sta halfHeight1
end

          let characterIndex = playerCharacter[temp2]
          let characterHeight = CharacterHeights[characterIndex]
          rem Use bit shift instead of division (optimized for Atari 2600)
          asm
            lda characterHeight
            lsr
            sta halfHeight2
end

          rem Compute absolute Y distance between player centers
          if temp4 >= temp5 then CalcYDistanceDown
          let temp6 = temp5 - temp4
          goto YDistanceDone
CalcYDistanceDown
          let temp6 = temp4 - temp5
YDistanceDone
          let totalHeight = halfHeight1 + halfHeight2
          if temp6 >= totalHeight then NoCollision

          let temp3 = 1
          rem Collision detected
          return

NoCollision
          let temp3 = 0
          return

