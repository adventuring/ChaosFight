          rem ChaosFight - Source/Routines/PlayerCollisionResolution.bas

          rem Copyright © 2025 Bruce-Robert Pocock.



CheckAllPlayerCollisions
          rem Returns: Far (return otherbank)

          asm

CheckAllPlayerCollisions

end

          rem Check Multi-player Collisions
          rem Returns: Far (return otherbank)

          rem Handles player-to-player collisions, resolving positional

          rem separation and applying impulse forces based on character

          rem weights. Supports up to four players (Quadtari) with

          rem dynamic activation.

          if (controllerStatus & SetQuadtariDetected) = 0 then temp6 = 2 : goto PCR_SkipElse

          let temp6 = 4

PCR_SkipElse

          let temp1 = 0

PCR_OuterLoop

          if temp1 >= temp6 then return thisbank

          if temp1 >= 2 then PCR_CheckP1Active

          goto PCR_InnerLoop

PCR_CheckP1Active

          if (controllerStatus & SetQuadtariDetected) = 0 then goto PCR_NextOuter

          if temp1 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextOuter

          if temp1 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextOuter

PCR_InnerLoop

          let temp2 = temp1 + 1

PCR_CheckPair

          if temp2 >= temp6 then goto PCR_NextOuter

          if temp2 >= 2 then PCR_CheckP2Active

          goto PCR_CheckDistance

PCR_CheckP2Active

          if (controllerStatus & SetQuadtariDetected) = 0 then goto PCR_NextInner

          if temp2 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextInner

          if temp2 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextInner

PCR_CheckDistance

          if playerHealth[temp1] = 0 then goto PCR_NextInner

          if playerHealth[temp2] = 0 then goto PCR_NextInner

          let temp3 = playerX[temp2] - playerX[temp1]

          if temp3 < 0 then temp3 = 0 - temp3

          if temp3 >= PlayerCollisionDistance then goto PCR_NextInner

          let temp4 = playerY[temp2] - playerY[temp1]

          if temp4 < 0 then temp4 = 0 - temp4

          rem Use bit shift instead of division (optimized for Atari 2600)

          let characterHeight = CharacterHeights[temp1]

          asm

            lda characterHeight

            lsr

            sta halfHeight1

end

          rem Use bit shift instead of division (optimized for Atari 2600)

          let characterHeight = CharacterHeights[temp2]

          asm

            lda characterHeight

            lsr

            sta halfHeight2

end

          let totalHeight = halfHeight1 + halfHeight2

          if totalHeight = 0 then goto PCR_NextInner

          if temp4 >= totalHeight then goto PCR_NextInner

          let characterWeight = CharacterWeights[temp1]

          let halfHeight1 = characterWeight

          let characterWeight = CharacterWeights[temp2]

          let halfHeight2 = characterWeight

          let totalWeight = halfHeight1 + halfHeight2

          if totalWeight = 0 then goto PCR_NextInner

          if playerX[temp1] < playerX[temp2] then goto PCR_SepLeft

          let weightDifference = halfHeight1 - halfHeight2

          if halfHeight1 < halfHeight2 then weightDifference = halfHeight2 - halfHeight1

          let impulseStrength = weightDifference

          if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseRight

          asm

            lda impulseStrength

            asl

            sta impulseStrength

end

          if totalWeight >= 128 then goto PCR_Div128_1

          if totalWeight >= 64 then goto PCR_Div64_1

          if totalWeight >= 32 then goto PCR_Div32_1

          asm

            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength

end

          goto PCR_ImpulseDone_1

PCR_Div32_1
          rem Returns: Far (return otherbank)

          asm

            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength

end

          goto PCR_ImpulseDone_1

PCR_Div64_1
          rem Returns: Far (return otherbank)

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

          goto PCR_ImpulseDone_1

PCR_Div128_1
          rem Returns: Far (return otherbank)

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

PCR_ImpulseDone_1

          let temp5 = 1

          goto PCR_ApplyImpulse

PCR_ApplyImpulseRight

          let temp5 = 0

PCR_ApplyImpulse

          if impulseStrength = 0 then let impulseStrength = 1

          if temp5 = 0 then goto PCR_ImpulseRightDir

          if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength

          if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4

          if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength

          if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252

          goto PCR_ImpulseDone

PCR_ImpulseRightDir

          if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength

          if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252

          if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength

          if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4

PCR_ImpulseDone

          let playerVelocityXL[temp1] = 0

          let playerVelocityXL[temp2] = 0

          goto PCR_NextInner

PCR_SepLeft

          let weightDifference = halfHeight1 - halfHeight2

          if halfHeight1 < halfHeight2 then weightDifference = halfHeight2 - halfHeight1

          let impulseStrength = weightDifference

          if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseLeft

          asm

            lda impulseStrength

            asl

            sta impulseStrength

end

          if totalWeight >= 128 then goto PCR_Div128_2

          if totalWeight >= 64 then goto PCR_Div64_2

          if totalWeight >= 32 then goto PCR_Div32_2

          asm

            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength

end

          goto PCR_ImpulseDone_2

PCR_Div32_2
          rem Returns: Far (return otherbank)

          asm

            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength

end

          goto PCR_ImpulseDone_2

PCR_Div64_2
          rem Returns: Far (return otherbank)

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

          goto PCR_ImpulseDone_2

PCR_Div128_2
          rem Returns: Far (return otherbank)

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

PCR_ImpulseDone_2

          let temp5 = 0

          goto PCR_ApplyImpulse

PCR_ApplyImpulseLeft

          let temp5 = 1

          goto PCR_ApplyImpulse

PCR_NextInner

          let temp2 = temp2 + 1

          goto PCR_CheckPair

PCR_NextOuter

          let temp1 = temp1 + 1

          if temp1 < temp6 then goto PCR_OuterLoop

          return thisbank