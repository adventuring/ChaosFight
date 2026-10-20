;;; ChaosFight - Source/Routines/PlayerCollisionResolution.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckAllPlayerCollisions .block
          ;; Returns: Far (return otherbank)

          ;; Check Multi-player Collisions
          ;; Returns: Far (return otherbank)

          ;; Handles player-to-player collisions, resolving positional

          ;; separation and applying impulse forces based on character

          ;; weights. Supports up to four players (Quadtari) with

          ;; dynamic activation.

          lda controllerStatus
          and # SetQuadtariDetected
          bne Use4PlayerMode

          ;; Set temp6 = 2 for 2-player mode
          lda # 2
          sta temp6
          jmp SkipElseCollisionCheck

Use4PlayerMode:

          lda # 4
          sta temp6

SkipElseCollisionCheck:
          lda # 0
          sta temp1

OuterLoopCollisionCheck:
          ;; If temp1 >= 2, then jmp CheckP1ActiveCollision
          lda temp1
          cmp # 2
          bcc SkipCheckP1Active
          jmp CheckP1ActiveCollision
SkipCheckP1Active:

          jmp InnerLoopCollisionCheck

.bend

CheckP1ActiveCollision .block
          lda controllerStatus
          and # SetQuadtariDetected
          bne CheckPlayer2Character

          jmp NextOuterCollisionCheck

CheckPlayer2Character:

          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then jmp NextOuterCollisionCheck
          lda temp1
          cmp # 2
          bne CheckPlayer3Character

          lda # 2
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckPlayer3Character

          jmp NextOuterCollisionCheck

CheckPlayer3Character:

          lda temp1
          cmp # 2
          bne CheckPlayer3Active

          lda # 2
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckPlayer3Active
          jmp NextOuterCollisionCheck
CheckPlayer3Active:



          ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then jmp NextOuterCollisionCheck
          lda temp1
          cmp # 3
          bne InnerLoopCollisionCheck
          lda # 3
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne InnerLoopCollisionCheck
          jmp NextOuterCollisionCheck
InnerLoopCollisionCheck:

          lda temp1
          cmp # 3
          bne CheckPairCollision
          lda # 3
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckPairCollision
          jmp NextOuterCollisionCheck
CheckPairCollision:



.bend

InnerLoopCollisionCheck .block

          lda temp1
          clc
          adc # 1
          sta temp2

.bend

CheckPairCollision .block

          ;; if temp2 >= temp6 then jmp NextOuterCollisionCheck
          lda temp2
          cmp temp6

          bcc CheckP2ActiveCollision

          jmp NextOuterCollisionCheck

          lda temp2
          cmp # 2
          bcc CheckDistanceCollisionP1
          ;; temp2 >= 2: fall through to the global CheckP2ActiveCollision block
CheckDistanceCollisionP1:


.bend

CheckP2ActiveCollision .block

          lda controllerStatus
          and # SetQuadtariDetected
          bne CheckP2Character
          jmp NextInnerCollisionCheck
CheckP2Character:


          ;; if temp2 = 2 && playerCharacter[2] = NoCharacter then jmp NextInnerCollisionCheck
          lda temp2
          cmp # 2
          bne CheckP2Character3
          lda # 2
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckP2Character3
          jmp NextInnerCollisionCheck
CheckP2Character3:

          lda temp2
          cmp # 2
          bne CheckP2CharacterActive
          lda # 2
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckP2CharacterActive
          jmp NextInnerCollisionCheck
CheckP2CharacterActive:



          ;; if temp2 = 3 && playerCharacter[3] = NoCharacter then jmp NextInnerCollisionCheck
          lda temp2
          cmp # 3
          bne CheckDistanceCollisionP2
          lda # 3
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckDistanceCollisionP2
          jmp NextInnerCollisionCheck
CheckDistanceCollisionP2:

          lda temp2
          cmp # 3
          bne CheckDistanceActive
          lda # 3
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckDistanceActive
          jmp NextInnerCollisionCheck
CheckDistanceActive:



.bend

CheckDistanceCollision .block

          ;; if playerHealth[temp1] = 0 then jmp NextInnerCollisionCheck
          lda temp1
          tax
          lda playerHealth,x
          bne CheckPlayer2Health
          jmp NextInnerCollisionCheck
CheckPlayer2Health:

          ;; if playerHealth[temp2] = 0 then jmp NextInnerCollisionCheck
          lda temp2
          tax
          lda playerHealth,x
          bne CalculateXDistance
          jmp NextInnerCollisionCheck
CalculateXDistance:

          ;; Set temp3 = playerX[temp2] - playerX[temp1]
          lda temp2
          tax
          lda playerX,x
          sta temp3

          ;; ;; If temp3 < 0, set temp3 = 0 - temp3          lda 0          sec          sbc temp3          sta temp3
          lda temp3
          bpl CheckCollisionDistance
          lda # 0
          sec
          sbc temp3
          sta temp3
CheckCollisionDistance:

          lda temp3
          bpl CheckDistanceThreshold
          lda # 0
          sec
          sbc temp3
          sta temp3
CheckDistanceThreshold:

          lda temp3
          bpl CalculateYDistance
          lda # 0
          sec
          sbc temp3
          sta temp3
CalculateYDistance:



          ;; if temp3 >= PlayerCollisionDistance then jmp NextInnerCollisionCheck
          lda temp3
          cmp # PlayerCollisionDistance


          bcc CheckCollisionDistanceThreshold

          jmp CheckCollisionDistanceThreshold

          CheckCollisionDistanceThreshold:

          ;; Set temp4 = playerY[temp2] - playerY[temp1]
          lda temp2
          tax
          lda playerY,x
          sta temp4

          ;; ;; If temp4 < 0, set temp4 = 0 - temp4          lda 0          sec          sbc temp4          sta temp4
          lda temp4
          bpl CheckTotalHeight
          lda # 0
          sec
          sbc temp4
          sta temp4
CheckTotalHeight:

          lda temp4
          cmp # 0
          bcs CheckHeightThreshold
          lda # 0
          sec
          sbc temp4
          sta temp4
CheckHeightThreshold:

          lda temp4
          bpl CalculateWeights
          lda # 0
          sec
          sbc temp4
          sta temp4
CalculateWeights:



          ;; Use bit shift instead of division (optimized for Atari 2600)

          ;; Set characterHeight = CharacterHeights[temp1]
          lda temp1
          tax
          lda CharacterHeights,x
          sta characterHeight


            lda characterHeight

            lsr

            sta halfHeight1


          ;; Use bit shift instead of division (optimized for Atari 2600)

          ;; Set characterHeight = CharacterHeights[temp2]
          lda temp2
          tax
          lda CharacterHeights,x
          sta characterHeight
          lda temp2
          tax
          lda CharacterHeights,x
          sta characterHeight


            lda characterHeight

            lsr

            sta halfHeight2


          ;; Set totalHeight = halfHeight1 + halfHeight2
          lda totalHeight
          bne CheckHeightCollision
          jmp NextInnerCollisionCheck
CheckHeightCollision:


          ;; if temp4 >= totalHeight then jmp NextInnerCollisionCheck
          lda temp4
          cmp totalHeight

          bcc CalculateWeights

          jmp CalculateWeightsLabel

CalculateWeightsLabel:
          ;; Set characterWeight = CharacterWeights[temp1]
          lda temp1
          tax
          lda CharacterWeights,x
          sta characterWeight

          lda characterWeight
          sta halfHeight1

          ;; Set characterWeight = CharacterWeights[temp2]
          lda temp2
          tax
          lda CharacterWeights,x
          sta characterWeight
          lda temp2
          tax
          lda CharacterWeights,x
          sta characterWeight

          lda characterWeight
          sta halfHeight2

          ;; Set totalWeight = halfHeight1 + halfHeight2
          lda totalWeight
          bne CalculateWeightDifference
          jmp NextInnerCollisionCheck
CalculateWeightDifference:


          ;; If playerX[temp1] < playerX[temp2] then jmp SepLeftCollision

          ;; Set weightDifference = halfHeight1 - halfHeight2          lda halfHeight1          sec          sbc halfHeight2          sta weightDifference
          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference

          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference


          ;; if halfHeight1 < halfHeight2, set weightDifference = halfHeight2 - halfHeight1          lda halfHeight2          sec          sbc halfHeight1          sta weightDifference
          lda weightDifference
          sta impulseStrength

          ;; if halfHeight1 >= halfHeight2 then jmp ApplyImpulseRightCollision
          lda halfHeight1
          cmp halfHeight2

          bcc DoubleImpulseStrength

          jmp DoubleImpulseStrength

          DoubleImpulseStrength:


            lda impulseStrength

            asl

            sta impulseStrength


          ;; if totalWeight >= 128 then jmp PCR_Div128_1
          lda totalWeight
          cmp # 128

          bcc CheckDiv64

          jmp CheckDiv64

          CheckDiv64:

          ;; if totalWeight >= 64 then jmp PCR_Div64_1
          lda totalWeight
          cmp # 64

          bcc CheckDiv32

          jmp CheckDiv32

          CheckDiv32:

          ;; if totalWeight >= 32 then jmp PCR_Div32_1
          lda totalWeight
          cmp # 32

          bcc DivBy16

          jmp DivBy16

          DivBy16:


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp PCR_ImpulseDone_1

PCR_ImpulseDone_1:
          lda # 1
          sta temp5
          jmp ApplyImpulseCollision

.bend

Div32ImpulseStrength .block
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp Div128ImpulseStrength.ImpulseDoneFirst

.bend

Div64ImpulseStrength .block
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp Div128ImpulseStrength.ImpulseDoneFirst

.bend

Div128ImpulseStrength .block
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          ;; end of div paths
          jmp CheckDistanceCollision.PCR_ImpulseDone_1
PCR_ImpulseDone_1a:
ImpulseDoneFirst:
          lda # 1
          sta temp5
          jmp ApplyImpulseCollision

.bend

ApplyImpulseRightCollision .block

          lda # 0
          sta temp5

.bend

ApplyImpulseCollision .block

          lda impulseStrength
          bne CheckImpulseDirection
          lda # 1
          sta impulseStrength
CheckImpulseDirection:


          lda temp5
          bne ApplyImpulseLeft
          jmp ImpulseRightDirection
ApplyImpulseLeft:
          ;; If playerVelocityX[temp1] < 4, then set playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength
          lda temp1
          tax
          lda playerVelocityX,x
          cmp # 4
          bcs ClampPlayer1VelocityMin
          lda playerVelocityX,x
          clc
          adc impulseStrength
          sta playerVelocityX,x
ClampPlayer1VelocityMin:
          ;; If playerVelocityX[temp1] > 4, then set playerVelocityX[temp1] = 4
          lda temp1
          tax
          lda playerVelocityX,x
          cmp # 4
          beq ImpulseDoneCollision
          bcc ImpulseDoneCollision
          lda # 4
          sta playerVelocityX,x
ImpulseDoneCollision:

          ;; if playerVelocityX[temp2] <= 252 then playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          lda temp2
          tax
          lda playerVelocityX,x
          cmp # 253
          bcs ClampPlayer2VelocityMax
          lda playerVelocityX,x
          sec
          sbc impulseStrength
          sta playerVelocityX,x
ClampPlayer2VelocityMax:

          ;; If playerVelocityX[temp2] > 252, then set playerVelocityX[temp2] = 252
          lda temp2
          tax
          lda playerVelocityX,x
          cmp # 252
          bcc ImpulseDoneCollisionLeft
          beq ImpulseDoneCollisionLeft
          lda # 252
          sta playerVelocityX,x
ImpulseDoneCollisionLeft:
          jmp NextInnerCollisionCheck

.bend

ImpulseRightDirection .block
          ;; If playerVelocityX[temp1] <= 252, then set playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength
          lda temp1
          tax
          lda playerVelocityX,x
          cmp # 253
          bcs ClampPlayer1VelocityMaxRight
          lda playerVelocityX,x
          sec
          sbc impulseStrength
          sta playerVelocityX,x
ClampPlayer1VelocityMaxRight:
          ;; If playerVelocityX[temp1] > 252, then set playerVelocityX[temp1] = 252
          lda temp1
          tax
          lda playerVelocityX,x
          sec
          sbc # 252
          bcc ClampPlayer1VelocityMax
          beq ClampPlayer1VelocityMax
          lda # 252
          sta playerVelocityX,x
ClampPlayer1VelocityMax:

          ;; If playerVelocityX[temp2] < 4, then set playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          lda temp2
          tax
          lda playerVelocityX,x
          cmp # 4
          bcs ClampPlayer2Velocity
          lda playerVelocityX,x
          clc
          adc impulseStrength
          sta playerVelocityX,x
ClampPlayer2Velocity:

          ;; If playerVelocityX[temp2] > 4, then set playerVelocityX[temp2] = 4
          lda temp2
          tax
          lda playerVelocityX,x
          sec
          sbc # 4
          bcc ImpulseDoneCollisionRight
          beq ImpulseDoneCollisionRight
          lda # 4
          sta playerVelocityX,x
ImpulseDoneCollisionRight:

          lda temp1
          tax
          lda # 0
          sta playerVelocityXL,x

          lda temp2
          tax
          lda # 0
          sta playerVelocityXL,x

          jmp NextInnerCollisionCheck

.bend

SepLeftCollision .block

          ;; Set weightDifference = halfHeight1 - halfHeight2          lda halfHeight1          sec          sbc halfHeight2          sta weightDifference
          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference

          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference


          ;; If halfHeight1 < halfHeight2, set weightDifference = halfHeight2 - halfHeight1          lda halfHeight2          sec          sbc halfHeight1          sta weightDifference
          lda weightDifference
          sta impulseStrength

          ;; if halfHeight1 >= halfHeight2 then jmp ApplyImpulseLeftCollision
          lda halfHeight1
          cmp halfHeight2

          bcc DoubleImpulseStrengthLeft

          jmp DoubleImpulseStrengthLeft

          DoubleImpulseStrengthLeft:


            lda impulseStrength

            asl

            sta impulseStrength


          ;; if totalWeight >= 128 then jmp PCR_Div128_2
          lda totalWeight
          cmp # 128

          bcc CheckDiv64Left

          jmp CheckDiv64Left

          CheckDiv64Left:

          ;; if totalWeight >= 64 then jmp PCR_Div64_2
          lda totalWeight
          cmp # 64

          bcc CheckDiv32Left

          jmp CheckDiv32Left

          CheckDiv32Left:

          ;; if totalWeight >= 32 then jmp PCR_Div32_2
          lda totalWeight
          cmp # 32

          bcc DivBy16Left

          jmp DivBy16Left

          DivBy16Left:


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


ImpulseDoneSecond:

          lda # 0
          sta temp5
          jmp ApplyImpulseCollision

.bend

Div32ImpulseStrength2 .block
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp Div128ImpulseStrength2.ImpulseDoneSecond

ImpulseDoneSecond2:
          lda # 0
          sta temp5
          jmp ApplyImpulseCollision

.bend

Div64ImpulseStrength2 .block
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp Div128ImpulseStrength2.ImpulseDoneSecond

ImpulseDoneSecond3:
          lda # 0
          sta temp5
          jmp ApplyImpulseCollision

.bend

Div128ImpulseStrength2 .block
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


ImpulseDoneSecond:

          lda # 0
          sta temp5
          jmp ApplyImpulseCollision

.bend

ApplyImpulseLeftCollision .block

          lda # 1
          sta temp5

          jmp ApplyImpulseCollision

.bend

NextInnerCollisionCheck .block

          inc temp2

          jmp CheckPairCollision

.bend

NextOuterCollisionCheck .block

          inc temp1

          ;; if temp1 < temp6 then jmp OuterLoopCollisionCheck
          lda temp1
          cmp temp6
          bcs NextOuterCollisionCheckDone
          jmp CheckAllPlayerCollisions.OuterLoopCollisionCheck
NextOuterCollisionCheckDone:

          

          jmp BS_return

.bend

