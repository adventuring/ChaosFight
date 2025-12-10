;;; ChaosFight - Source/Routines/PlayerCollisionResolution.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckAllPlayerCollisions:
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

          ;; let temp6 = 2 : goto PCR_SkipElse

Use4PlayerMode:

          lda # 4
          sta temp6

PCR_SkipElse .proc
          lda # 0
          sta temp1

.pend

PCR_OuterLoop .proc
          rts

          if temp1 >= 2 then PCR_CheckP1Active

          jmp PCR_InnerLoop

.pend

PCR_CheckP1Active .proc
          lda controllerStatus
          and # SetQuadtariDetected
          cmp # 0
          bne CheckPlayer2Character

          jmp PCR_NextOuter

CheckPlayer2Character:

          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextOuter
          lda temp1
          cmp # 2
          bne CheckPlayer3Character

          lda # 2
          asl
          tax
          lda playerCharacter,x
          cmp # NoCharacter
          bne CheckPlayer3Character

          jmp PCR_NextOuter

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
          jmp PCR_NextOuter
CheckPlayer3Active:



          ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextOuter
          lda temp1
          cmp # 3
          bne PCR_InnerLoop
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne PCR_InnerLoop
          jmp PCR_NextOuter
PCR_InnerLoop:

          lda temp1
          cmp # 3
          bne PCR_CheckPair
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne PCR_CheckPair
          jmp PCR_NextOuter
PCR_CheckPair:



.pend

PCR_InnerLoop .proc

          lda temp1
          clc
          adc # 1
          sta temp2

.pend

PCR_CheckPair .proc

          ;; if temp2 >= temp6 then goto PCR_NextOuter
          lda temp2
          cmp temp6

          bcc PCR_CheckP2Active

          jmp PCR_CheckP2Active

          PCR_CheckP2Active:

                    if temp2 >= 2 then PCR_CheckP2Active
          jmp PCR_CheckDista


.pend

PCR_CheckP2Active .proc

          lda controllerStatus
          and SetQuadtariDetected
          cmp # 0
          bne CheckP2Character
          jmp PCR_NextInner
CheckP2Character:


          ;; if temp2 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextInner
          lda temp2
          cmp # 2
          bne CheckP2Character3
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckP2Character3
          jmp PCR_NextInner
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
          jmp PCR_NextInner
CheckP2CharacterActive:



          ;; if temp2 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextInner
          lda temp2
          cmp # 3
          bne PCR_CheckDistance
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne PCR_CheckDistance
          jmp PCR_NextInner
PCR_CheckDistance:

          lda temp2
          cmp # 3
          bne CheckDistanceActive
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne CheckDistanceActive
          jmp PCR_NextInner
CheckDistanceActive:



.pend

PCR_CheckDistance .proc

          ;; if playerHealth[temp1] = 0 then goto PCR_NextInner
          lda temp1
          asl
          tax
          lda playerHealth,x
          bne CheckPlayer2Health
          jmp PCR_NextInner
CheckPlayer2Health:

          ;; if playerHealth[temp2] = 0 then goto PCR_NextInner
          lda temp2
          asl
          tax
          lda playerHealth,x
          bne CalculateXDistance
          jmp PCR_NextInner
CalculateXDistance:

          ;; let temp3 = playerX[temp2] - playerX[temp1]         
          lda temp2
          asl
          tax
          lda playerX,x
          sta temp3

          ;; ;; if temp3 < 0 then let temp3 = 0 - temp3          lda 0          sec          sbc temp3          sta temp3
          lda temp3
          cmp # 0
          bcs CheckCollisionDistance
          jmp let_label
CheckCollisionDistance:

          lda temp3
          cmp # 0
          bcs CheckDistanceThreshold
          jmp let_label
CheckDistanceThreshold:

          lda temp3
          cmp # 0
          bcs CalculateYDistance
          jmp let_label
CalculateYDistance:



          ;; if temp3 >= PlayerCollisionDistance then goto PCR_NextInner
          lda temp3
          cmp PlayerCollisionDista


          bcc CheckCollisionDistanceThreshold

          jmp CheckCollisionDistanceThreshold

          CheckCollisionDistanceThreshold:

          ;; let temp4 = playerY[temp2] - playerY[temp1]         
          lda temp2
          asl
          tax
          lda playerY,x
          sta temp4

          ;; ;; if temp4 < 0 then let temp4 = 0 - temp4          lda 0          sec          sbc temp4          sta temp4
          lda temp4
          cmp # 0
          bcs CheckTotalHeight
          jmp let_label
CheckTotalHeight:

          lda temp4
          cmp # 0
          bcs CheckHeightThreshold
          jmp let_label
CheckHeightThreshold:

          lda temp4
          cmp # 0
          bcs CalculateWeights
          jmp let_label
CalculateWeights:



          ;; Use bit shift instead of division (optimized for Atari 2600)

                    ;; let characterHeight = CharacterHeights[temp1]
                    lda temp1          asl          tax          lda CharacterHeights,x          sta characterHeight


            lda characterHeight

            lsr

            sta halfHeight1


          ;; Use bit shift instead of division (optimized for Atari 2600)

          ;; let characterHeight = CharacterHeights[temp2]
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


          ;; let totalHeight = halfHeight1 + halfHeight2
          lda totalHeight
          cmp # 0
          bne CheckHeightCollision
          jmp PCR_NextInner
CheckHeightCollision:


          ;; if temp4 >= totalHeight then goto PCR_NextInner
          lda temp4
          cmp totalHeight

          bcc CalculateWeights

          jmp CalculateWeights

          CalculateWeights:

                    ;; let characterWeight = CharacterWeights[temp1]
                    lda temp1          asl          tax          lda CharacterWeights,x          sta characterWeight

          lda characterWeight
          sta halfHeight1

          ;; let characterWeight = CharacterWeights[temp2]
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

          ;; let totalWeight = halfHeight1 + halfHeight2
          lda totalWeight
          cmp # 0
          bne CalculateWeightDifference
          jmp PCR_NextInner
CalculateWeightDifference:


          ;; if playerX[temp1] < playerX[temp2] then goto PCR_SepLeft

          ;; let weightDifference = halfHeight1 - halfHeight2          lda halfHeight1          sec          sbc halfHeight2          sta weightDifference
          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference

          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference


          ;; if halfHeight1 < halfHeight2 then let weightDifference = halfHeight2 - halfHeight1          lda halfHeight2          sec          sbc halfHeight1          sta weightDifference
          lda weightDifference
          sta impulseStrength

          ;; if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseRight
          lda halfHeight1
          cmp halfHeight2

          bcc DoubleImpulseStrength

          jmp DoubleImpulseStrength

          DoubleImpulseStrength:


            lda impulseStrength

            asl

            sta impulseStrength


          ;; if totalWeight >= 128 then goto PCR_Div128_1
          lda totalWeight
          cmp 128

          bcc CheckDiv64

          jmp CheckDiv64

          CheckDiv64:

          ;; if totalWeight >= 64 then goto PCR_Div64_1
          lda totalWeight
          cmp 64

          bcc CheckDiv32

          jmp CheckDiv32

          CheckDiv32:

          ;; if totalWeight >= 32 then goto PCR_Div32_1
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

PCR_Div32_1 .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp PCR_ImpulseDone_1

.pend

PCR_Div64_1 .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp PCR_ImpulseDone_1

.pend

PCR_Div128_1 .proc
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


PCR_ImpulseDone_1

          lda # 1
          sta temp5

          jmp PCR_ApplyImpulse

.pend

PCR_ApplyImpulseRight .proc

          lda # 0
          sta temp5

.pend

PCR_ApplyImpulse .proc

          lda impulseStrength
          cmp # 0
          bne CheckImpulseDirection
          lda # 1
          sta impulseStrength
CheckImpulseDirection:


          lda temp5
          cmp # 0
          bne ApplyImpulseLeft
          jmp PCR_ImpulseRightDir
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
          beq skip_4706
          lda 4
          sta playerVelocityX,x
skip_4706:

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
          sbc 252
          bcc PCR_ImpulseDone
          beq PCR_ImpulseDone
          lda 252
          sta playerVelocityX,x
PCR_ImpulseDone:
          jmp PCR_ImpulseDone

.pend

PCR_ImpulseRightDir .proc

                    if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength

                    if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc 252
          bcc ClampPlayer1VelocityMax
          beq ClampPlayer1VelocityMax
          lda 252
          sta playerVelocityX,x
ClampPlayer1VelocityMax:

                    if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          cmp 4
          bcs ClampPlayer2Velocity
          lda playerVelocityX
          sta playerVelocityX,x
ClampPlayer2Velocity:[temp2] + impulseStrength

                    if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc 4
          bcc PCR_ImpulseDone
          beq PCR_ImpulseDone
          lda 4
          sta playerVelocityX,x
PCR_ImpulseDone:

PCR_ImpulseDone
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          lda temp2
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          jmp PCR_NextInner

.pend

PCR_SepLeft .proc

          ;; let weightDifference = halfHeight1 - halfHeight2          lda halfHeight1          sec          sbc halfHeight2          sta weightDifference
          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference

          lda halfHeight1
          sec
          sbc halfHeight2
          sta weightDifference


          ;; if halfHeight1 < halfHeight2 then let weightDifference = halfHeight2 - halfHeight1          lda halfHeight2          sec          sbc halfHeight1          sta weightDifference
          lda weightDifference
          sta impulseStrength

          ;; if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseLeft
          lda halfHeight1
          cmp halfHeight2

          bcc DoubleImpulseStrengthLeft

          jmp DoubleImpulseStrengthLeft

          DoubleImpulseStrengthLeft:


            lda impulseStrength

            asl

            sta impulseStrength


          ;; if totalWeight >= 128 then goto PCR_Div128_2
          lda totalWeight
          cmp 128

          bcc CheckDiv64Left

          jmp CheckDiv64Left

          CheckDiv64Left:

          ;; if totalWeight >= 64 then goto PCR_Div64_2
          lda totalWeight
          cmp 64

          bcc CheckDiv32Left

          jmp CheckDiv32Left

          CheckDiv32Left:

          ;; if totalWeight >= 32 then goto PCR_Div32_2
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


          jmp PCR_ImpulseDone_2

.pend

PCR_Div32_2 .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp PCR_ImpulseDone_2

.pend

PCR_Div64_2 .proc
          ;; Returns: Far (return otherbank)


            lda impulseStrength

            lsr

            lsr

            lsr

            lsr

            lsr

            lsr

            sta impulseStrength


          jmp PCR_ImpulseDone_2

.pend

PCR_Div128_2 .proc
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


PCR_ImpulseDone_2

          lda # 0
          sta temp5

          jmp PCR_ApplyImpulse

.pend

PCR_ApplyImpulseLeft .proc

          lda # 1
          sta temp5

          jmp PCR_ApplyImpulse

.pend

PCR_NextInner .proc

          inc temp2

          jmp PCR_CheckPair

.pend

PCR_NextOuter .proc

          inc temp1

          ;; if temp1 < temp6 then goto PCR_OuterLoop
          lda temp1
          cmp temp6
          bcs PCR_NextOuterDone
          jmp PCR_OuterLoop
PCR_NextOuterDone:

          

          rts
.pend

