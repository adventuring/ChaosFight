          rem ChaosFight - Source/Routines/PlayerCollisionResolution.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckAllPlayerCollisions
          asm
CheckAllPlayerCollisions

end
          rem Check Multi-player Collisions
          rem Handles player-to-player collisions, resolving positional
          rem separation and applying impulse forces based on character
          rem weights. Supports up to four players (Quadtari) with
          rem dynamic activation.
          if (controllerStatus & SetQuadtariDetected) = 0 then temp6 = 2 : goto CollisionSkipElse
          let temp6 = 4
CollisionSkipElse
          let temp1 = 0
CollisionOuterLoop
          if temp1 >= temp6 then return
          if temp1 >= 2 then CollisionCheckP1Active
          goto CollisionInnerLoop
CollisionCheckP1Active
          if (controllerStatus & SetQuadtariDetected) = 0 then goto CollisionNextOuter
          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto CollisionNextOuter
          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto CollisionNextOuter
CollisionInnerLoop
          let temp2 = temp1 + 1
CollisionCheckPair
          if temp2 >= temp6 then goto CollisionNextOuter
          if temp2 >= 2 then CollisionCheckP2Active
          goto CollisionCheckDistance
CollisionCheckP2Active
          if (controllerStatus & SetQuadtariDetected) = 0 then goto CollisionNextInner
          if temp2 = 2 && playerCharacter[2] = NoCharacter then goto CollisionNextInner
          if temp2 = 3 && playerCharacter[3] = NoCharacter then goto CollisionNextInner
CollisionCheckDistance
          if playerHealth[temp1] = 0 then goto CollisionNextInner
          if playerHealth[temp2] = 0 then goto CollisionNextInner
          rem Optimized: Calculate absolute X distance directly
          let temp3 = playerX[temp2] - playerX[temp1]
          if temp3 < 0 then temp3 = 0 - temp3
          if temp3 >= PlayerCollisionDistance then goto CollisionNextInner
          rem Optimized: Calculate absolute Y distance directly
          let temp4 = playerY[temp2] - playerY[temp1]
          if temp4 < 0 then temp4 = 0 - temp4
          let characterHeight = CharacterHeights[temp1]
          let halfHeight1 = characterHeight / 2
          let characterHeight = CharacterHeights[temp2]
          let halfHeight2 = characterHeight / 2
          let totalHeight = halfHeight1 + halfHeight2
          if totalHeight = 0 then goto CollisionNextInner
          if temp4 >= totalHeight then goto CollisionNextInner
          let characterWeight = CharacterWeights[temp1]
          let halfHeight1 = characterWeight
          let characterWeight = CharacterWeights[temp2]
          let halfHeight2 = characterWeight
          let totalWeight = halfHeight1 + halfHeight2
          if totalWeight = 0 then goto CollisionNextInner
          rem Long branch - use goto (generates JMP) instead of if-then (generates branch)
          if playerX[temp1] < playerX[temp2] then goto CollisionSepLeft
          let weightDifference = halfHeight1 - halfHeight2
          if halfHeight1 >= halfHeight2 then CalcWeightDiff1Heavier
          let impulseStrength = weightDifference
          goto ApplyImpulseRight
CalcWeightDiff1Heavier
          let weightDifference = halfHeight1 - halfHeight2
          let impulseStrength = weightDifference
ApplyImpulseRight
          rem Long branch - use goto (generates JMP) instead of if-then (generates branch)
          if halfHeight1 < halfHeight2 then goto ApplyImpulse1Heavier
          asm
            lda impulseStrength
            asl
            sta impulseStrength
end
          if totalWeight >= 128 then goto ApproxDivBy128_1
          if totalWeight >= 64 then goto ApproxDivBy64_1
          if totalWeight >= 32 then goto ApproxDivBy32_1
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy32_1
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy64_1
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_1
ApproxDivBy128_1
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
ApproxDivDone_1
          if impulseStrength = 0 then let impulseStrength = 1
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
CollisionSepLeft
          let characterWeight = CharacterWeights[temp4]
          let halfHeight2 = CharacterWeights[temp5]
          let totalWeight = characterWeight + halfHeight2
          if totalWeight = 0 then goto CollisionNextInner
          if characterWeight >= halfHeight2 then CalcWeightDiff1HeavierLeft
          let weightDifference = halfHeight2 - characterWeight
          let impulseStrength = weightDifference
          goto ApplyImpulseLeft
CalcWeightDiff1HeavierLeft
          let weightDifference = characterWeight - halfHeight2
          let impulseStrength = weightDifference
ApplyImpulseLeft
          rem Long branch - use goto (generates JMP) instead of if-then (generates branch)
          if characterWeight >= halfHeight2 then goto ApplyImpulse1HeavierLeft
          asm
            lda impulseStrength
            asl
            sta impulseStrength
end
          if totalWeight >= 128 then goto ApproxDivBy128_3
          if totalWeight >= 64 then goto ApproxDivBy64_3
          if totalWeight >= 32 then goto ApproxDivBy32_3
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy32_3
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy64_3
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_3
ApproxDivBy128_3
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
ApproxDivDone_3
          if impulseStrength = 0 then let impulseStrength = 1
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApplyImpulse1Heavier
          let impulseStrength = weightDifference
          if impulseStrength = 0 then let impulseStrength = 1
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApplyImpulse1HeavierLeft
          let impulseStrength = weightDifference
          if impulseStrength = 0 then let impulseStrength = 1
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApproxDivBy128_2
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy64_2
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone_2
ApproxDivBy32_2
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          rem fall through to ApproxDivDone_2
ApproxDivDone_2
          if impulseStrength = 0 then let impulseStrength = 1
          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          goto CollisionNextInner
ApproxDivBy32
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone
ApproxDivBy64
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
          goto ApproxDivDone
ApproxDivBy128
          asm
            lda impulseStrength
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            lsr
            sta impulseStrength
end
ApproxDivDone
          if impulseStrength = 0 then let impulseStrength = 1
          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          let playerVelocityXL[temp1] = 0
          let playerVelocityXL[temp2] = 0
          rem fall through to CollisionNextInner
CollisionNextInner
          let temp2 = temp2 + 1
          goto CollisionCheckPair
CollisionNextOuter
          let temp1 = temp1 + 1
          if temp1 < temp6 then goto CollisionOuterLoop
          return
