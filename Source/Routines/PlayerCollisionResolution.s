;;; ChaosFight - Source/Routines/PlayerCollisionResolution.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckAllPlayerCollisions .proc
          ;; Returns: Far (return otherbank)

          ;; Check Multi-player Collisions
          ;; Returns: Far (return otherbank)

          ;; Handles player-to-player collisions, resolving positional

          ;; separation and applying impulse forces based on character

          ;; weights. Supports up to four players (Quadtari) with

          ;; dynamic activation.

          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne Use4PlayerMode

          ;; Set temp6 = 2 jmp SkipElseCollisionCheck

Use4PlayerMode:

          lda # 4
          sta temp6

.pend

SkipElseCollisionCheck .proc
          lda # 0
          sta temp1

.pend

OuterLoopCollisionCheck .proc
          ;; If temp1 >= 2, then jmp CheckP1ActiveCollision
          lda temp1
          cmp # 2
          bcc SkipCheckP1Active
          jmp CheckP1ActiveCollision
SkipCheckP1Active:

          jmp InnerLoopCollisionCheck

.pend

CheckP1ActiveCollision .proc
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer2Character

          jmp NextOuterCollisionCheck

CheckPlayer2Character:

          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then jmp NextOuterCollisionCheck
          lda temp1
          cmp # 2
          bne CheckPlayer3Character

          lda # 2
          asl
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
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckPlayer3Active
          jmp NextOuterCollisionCheck
CheckPlayer3Active:



          ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then jmp NextOuterCollisionCheck
          lda temp1
          cmp # 3
          bne InnerLoopCollisionCheck
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne InnerLoopCollisionCheck
          jmp NextOuterCollisionCheck
InnerLoopCollisionCheck:

          lda temp1
          cmp # 3
          bne CheckPairCollision
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckPairCollision
          jmp NextOuterCollisionCheck
CheckPairCollision:



.pend

InnerLoopCollisionCheck .proc

          lda temp1
          clc
          adc # 1
          sta temp2

.pend

CheckPairCollision .proc

          ;; if temp2 >= temp6 then jmp NextOuterCollisionCheck
          lda temp2
          cmp temp6

          bcc CheckP2ActiveCollision

          jmp CheckP2ActiveCollision

          CheckP2ActiveCollision:

          lda temp2
          cmp # 2
          bcc CheckDistanceCollisionP1
          jmp CheckP2ActiveCollision
CheckDistanceCollisionP1:


.pend

CheckP2ActiveCollision .proc

          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckP2Character
          jmp NextInnerCollisionCheck
CheckP2Character:


          ;; if temp2 = 2 && playerCharacter[2] = NoCharacter then jmp NextInnerCollisionCheck
          lda temp2
          cmp # 2
          bne CheckP2Character3
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckP2Character3
          jmp NextInnerCollisionCheck
CheckP2Character3:

          lda temp2
          cmp # 2
          bne CheckP2CharacterActive
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckP2CharacterActive
          jmp NextInnerCollisionCheck
CheckP2CharacterActive:



          ;; if temp2 = 3 && playerCharacter[3] = NoCharacter then jmp NextInnerCollisionCheck
          lda temp2
          cmp # 3
          bne CheckDistanceCollisionP2
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckDistanceCollisionP2
          jmp NextInnerCollisionCheck
CheckDistanceCollisionP2:

          lda temp2
          cmp # 3
          bne CheckDistanceActive
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckDistanceActive
          jmp NextInnerCollisionCheck
CheckDistanceActive:



.pend

CheckDistanceCollision .proc

          ;; if playerHealth[temp1] = 0 then jmp NextInnerCollisionCheck
          lda temp1
          asl
          tax
          lda playerHealth,x
          bne CheckPlayer2Health
          jmp NextInnerCollisionCheck
CheckPlayer2Health:

          ;; if playerHealth[temp2] = 0 then jmp NextInnerCollisionCheck
          lda temp2
          asl
          tax
          lda playerHealth,x
          bne CalculateXDistance
          jmp NextInnerCollisionCheck
CalculateXDistance:

          ;; Set temp3 = playerX[temp2] - playerX[temp1]
          lda temp2
          asl
          tax
          lda playerX,x
          sta temp3

          ;; ;; If temp3 < 0, set temp3 = 0 - temp3          lda 0          sec          sbc temp3          sta temp3
          lda temp3
          cmp # 0
          bcs CheckCollisionDistance
          lda # 0
          sec
          sbc temp3
          sta temp3
CheckCollisionDistance:

          lda temp3
          cmp # 0
          bcs CheckDistanceThreshold
          lda # 0
          sec
          sbc temp3
          sta temp3
CheckDistanceThreshold:

          lda temp3
          cmp # 0
          bcs CalculateYDistance
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
          asl
          tax
          lda playerY,x
          sta temp4

          ;; ;; If temp4 < 0, set temp4 = 0 - temp4          lda 0          sec          sbc temp4          sta temp4
          lda temp4
          cmp # 0
          bcs CheckTotalHeight
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
          cmp # 0
          bcs CalculateWeights
          lda # 0
          sec
          sbc temp4
          sta temp4
CalculateWeights:



          ;; Use bit shift instead of division (optimized for Atari 2600)

          ;; Set characterHeight = CharacterHeights[temp1]
          lda temp1
          asl
          tax
          lda CharacterHeights,x
          sta characterHeight


            lda characterHeight

            lsr

            sta halfHeight1


          ;; Use bit shift instead of division (optimized for Atari 2600)

          ;; Set characterHeight = CharacterHeights[temp2]
          lda temp2
          asl
          tax
          lda CharacterHeights,x
          sta characterHeight
          lda temp2
          asl
          tax
          lda CharacterHeights,x
          sta characterHeight


            lda characterHeight

            lsr

            sta halfHeight2


          ;; Set totalHeight = halfHeight1 + halfHeight2
          lda totalHeight
          cmp # 0
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
          asl
          tax
          lda CharacterWeights,x
          sta characterWeight

          lda characterWeight
          sta halfHeight1

          ;; Set characterWeight = CharacterWeights[temp2]
          lda temp2
          asl
          tax
          lda CharacterWeights,x
          sta characterWeight
          lda temp2
          asl
          tax
          lda CharacterWeights,x
          sta characterWeight

          lda characterWeight
          sta halfHeight2

          ;; Set totalWeight = halfHeight1 + halfHeight2
          lda totalWeight
          cmp # 0
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
          cmp 128

          bcc CheckDiv64

          jmp CheckDiv64

          CheckDiv64:

          ;; if totalWeight >= 64 then jmp PCR_Div64_1
          lda totalWeight
          cmp 64

          bcc CheckDiv32

          jmp CheckDiv32

          CheckDiv32:

          ;; if totalWeight >= 32 then jmp PCR_Div32_1
          lda totalWeight
          cmp 32

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

.pend

Div32ImpulseStrength .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp ImpulseDoneFirst

.pend

Div64ImpulseStrength .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp ImpulseDoneFirst

.pend

Div128ImpulseStrength .proc
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


ImpulseDoneFirst

          lda # 1
          sta temp5

          jmp ApplyImpulseCollision

.pend

ApplyImpulseRightCollision .proc

          lda # 0
          sta temp5

.pend

ApplyImpulseCollision .proc

          lda impulseStrength
          cmp # 0
          bne CheckImpulseDirection
          lda # 1
          sta impulseStrength
CheckImpulseDirection:


          lda temp5
          cmp # 0
          bne ApplyImpulseLeft
          jmp ImpulseRightDirection
ApplyImpulseLeft:


                    if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength

                    if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc 4
          bcc skip_4706
          beq ImpulseDoneCollision
          lda # 4
          sta playerVelocityX,x
ImpulseDoneCollision:

                    if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          cmp # 253
          bcs ClampPlayer2VelocityMax
          lda playerVelocityX,x
          sec
          sbc impulseStrength
          sta playerVelocityX,x
ClampPlayer2VelocityMax:

                    if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc # 252
          bcc ImpulseDoneCollisionLeft
          beq ImpulseDoneCollisionLeft
          lda # 252
          sta playerVelocityX,x
ImpulseDoneCollisionLeft:
          jmp NextInnerCollisionCheck

.pend

ImpulseRightDirection .proc

                    if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength

                    if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc # 252
          bcc ClampPlayer1VelocityMax
          beq ClampPlayer1VelocityMax
          lda # 252
          sta playerVelocityX,x
ClampPlayer1VelocityMax:

                    if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX[temp2] + impulseStrength
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          cmp # 4
          bcs ClampPlayer2Velocity
          lda playerVelocityX,x
          clc
          adc impulseStrength
          sta playerVelocityX,x
ClampPlayer2Velocity:

                    if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          lda temp2
          asl
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
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

          lda temp2
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

          jmp NextInnerCollisionCheck

.pend

SepLeftCollision .proc

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
          cmp 128

          bcc CheckDiv64Left

          jmp CheckDiv64Left

          CheckDiv64Left:

          ;; if totalWeight >= 64 then jmp PCR_Div64_2
          lda totalWeight
          cmp 64

          bcc CheckDiv32Left

          jmp CheckDiv32Left

          CheckDiv32Left:

          ;; if totalWeight >= 32 then jmp PCR_Div32_2
          lda totalWeight
          cmp 32

          bcc DivBy16Left

          jmp DivBy16Left

          DivBy16Left:


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp ImpulseDoneSecond

.pend

Div32ImpulseStrength2 .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp ImpulseDoneSecond

.pend

Div64ImpulseStrength2 .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp ImpulseDoneSecond

.pend

Div128ImpulseStrength2 .proc
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

.pend

ApplyImpulseLeftCollision .proc

          lda # 1
          sta temp5

          jmp ApplyImpulseCollision

.pend

NextInnerCollisionCheck .proc

          inc temp2

          jmp CheckPairCollision

.pend

NextOuterCollisionCheck .proc

          inc temp1

          ;; if temp1 < temp6 then jmp OuterLoopCollisionCheck
          lda temp1
          cmp temp6
          bcs NextOuterCollisionCheckDone
          jmp OuterLoopCollisionCheck
NextOuterCollisionCheckDone:

          

          jmp BS_return

.pend

