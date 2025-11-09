          rem ChaosFight - Source/Routines/PlayerCollisionResolution.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckAllPlayerCollisions
          rem Check Multi-player Collisions
          rem Handles player-to-player collisions, resolving positional
          rem separation and applying impulse forces based on character
          rem weights. Supports up to four players (Quadtari) with
          rem dynamic activation.
          if !(controllerStatus & SetQuadtariDetected) then let temp6 = 2 else let temp6 = 4
          let temp1 = 0
CollisionOuterLoop
          if temp1 >= temp6 then return
          if temp1 >= 2 then CollisionCheckP1Active
          goto CollisionInnerLoop
CollisionCheckP1Active
          if !(controllerStatus & SetQuadtariDetected) then goto CollisionNextOuter
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto CollisionNextOuter
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto CollisionNextOuter
CollisionInnerLoop
          let temp2 = temp1 + 1
CollisionCheckPair
          if temp2 >= temp6 then goto CollisionNextOuter
          if temp2 >= 2 then CollisionCheckP2Active
          goto CollisionCheckDistance
CollisionCheckP2Active
          if !(controllerStatus & SetQuadtariDetected) then goto CollisionNextInner
          if temp2 = 2 && playerCharacter[2] = NoCharacter then goto CollisionNextInner
          if temp2 = 3 && playerCharacter[3] = NoCharacter then goto CollisionNextInner
CollisionCheckDistance
          if playerHealth[temp1] = 0 then goto CollisionNextInner
          if playerHealth[temp2] = 0 then goto CollisionNextInner
          rem Optimized: Calculate absolute X distance directly
          let temp3 = playerX[temp2] - playerX[temp1]
          if temp3 < 0 then let temp3 = 0 - temp3
          if temp3 >= PlayerCollisionDistance then goto CollisionNextInner
          rem Optimized: Calculate absolute Y distance directly
          let temp4 = playerY[temp2] - playerY[temp1]
          if temp4 < 0 then let temp4 = 0 - temp4
          let characterHeight_W = CharacterHeights[temp1]
          let halfHeight1_W = characterHeight_R / 2
          let characterHeight_W = CharacterHeights[temp2]
          let halfHeight2_W = characterHeight_R / 2
          let totalHeight_W = halfHeight1_R + halfHeight2_R
          if totalHeight_R = 0 then goto CollisionNextInner
          if temp4 >= totalHeight_R then goto CollisionNextInner
          let characterWeight_W = CharacterWeights[temp1]
          let halfHeight1_W = characterWeight_R
          let characterWeight_W = CharacterWeights[temp2]
          let halfHeight2_W = characterWeight_R
          let totalWeight_W = halfHeight1_R + halfHeight2_R
          if totalWeight_R = 0 then goto CollisionNextInner
          if playerX[temp1] < playerX[temp2] then CollisionSepLeft
          let weightDifference_W = halfHeight1_R - halfHeight2_R
          if halfHeight1_R >= halfHeight2_R then CalcWeightDiff1Heavier
          let impulseStrength_W = weightDifference_R
          goto ApplyImpulseRight
CalcWeightDiff1Heavier
          let weightDifference_W = halfHeight1_R - halfHeight2_R
          let impulseStrength_W = weightDifference_R
ApplyImpulseRight
          if halfHeight1_R < halfHeight2_R then ApplyImpulse1Heavier
          asm
            lda impulseStrength_R
            asl
            sta impulseStrength_W
end
          if totalWeight_R >= 128 then goto ApproxDivBy128_1
          if totalWeight_R >= 64 then goto ApproxDivBy64_1
          if totalWeight_R >= 32 then goto ApproxDivBy32_1
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_1
ApproxDivBy32_1
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_1
ApproxDivBy64_1
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_1
ApproxDivBy128_1
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
ApproxDivDone_1
          if impulseStrength_R = 0 then let impulseStrength_W = 1
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength_R
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength_R
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
CollisionSepLeft
          let characterWeight_W = CharacterWeights[temp4]
          let halfHeight2_W = CharacterWeights[temp5]
          let totalWeight_W = characterWeight_R + halfHeight2_R
          if totalWeight_R = 0 then goto CollisionNextInner
          if characterWeight_R >= halfHeight2_R then CalcWeightDiff1HeavierLeft
          let weightDifference_W = halfHeight2_R - characterWeight_R
          let impulseStrength_W = weightDifference_R
          goto ApplyImpulseLeft
CalcWeightDiff1HeavierLeft
          let weightDifference_W = characterWeight_R - halfHeight2_R
          let impulseStrength_W = weightDifference_R
ApplyImpulseLeft
          if characterWeight_R >= halfHeight2_R then ApplyImpulse1HeavierLeft
          asm
            lda impulseStrength_R
            asl
            sta impulseStrength_W
end
          if totalWeight_R >= 128 then goto ApproxDivBy128_3
          if totalWeight_R >= 64 then goto ApproxDivBy64_3
          if totalWeight_R >= 32 then goto ApproxDivBy32_3
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_3
ApproxDivBy32_3
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_3
ApproxDivBy64_3
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_3
ApproxDivBy128_3
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
ApproxDivDone_3
          if impulseStrength_R = 0 then let impulseStrength_W = 1
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength_R
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength_R
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApplyImpulse1Heavier
          let impulseStrength_W = weightDifference_R
          if impulseStrength_R = 0 then let impulseStrength_W = 1
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength_R
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength_R
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApplyImpulse1HeavierLeft
          let impulseStrength_W = weightDifference_R
          if impulseStrength_R = 0 then let impulseStrength_W = 1
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength_R
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength_R
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApproxDivBy128_2
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_2
ApproxDivBy64_2
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_2
ApproxDivBy32_2
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone_2
ApproxDivDone_2
          if impulseStrength_R = 0 then let impulseStrength_W = 1
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength_R
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength_R
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApproxDivBy32
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone
ApproxDivBy64
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
          goto ApproxDivDone
ApproxDivBy128
          asm
            lda impulseStrength_R
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength_W
end
ApproxDivDone
          if impulseStrength_R = 0 then let impulseStrength_W = 1
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength_R
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength_R
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
CollisionNextInner
          let temp2 = temp2 + 1
          goto CollisionCheckPair
CollisionNextOuter
          let temp1 = temp1 + 1
          if temp1 < temp6 then goto CollisionOuterLoop
          return
