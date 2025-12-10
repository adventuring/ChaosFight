;;; ChaosFight - Source/Routines/PlayerCollisionResolution.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckAllPlayerCollisions
          ;; Returns: Far (return otherbank)


CheckAllPlayerCollisions


          ;; Check Multi-player Collisions
          ;; Returns: Far (return otherbank)

          ;; Handles player-to-player collisions, resolving positional

          ;; separation and applying impulse forces based on character

          ;; weights. Supports up to four players (Quadtari) with

          ;; dynamic activation.

          lda controllerStatus
          and SetQuadtariDetected
          cmp # 0
          bne skip_7014
                    let temp6 = 2 : goto PCR_SkipElse
skip_7014:

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
          and SetQuadtariDetected
          cmp # 0
          bne skip_3512
          jmp PCR_NextOuter
skip_3512:


          ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextOuter
          lda temp1
          cmp # 2
          bne skip_5726
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_5726
          jmp PCR_NextOuter
skip_5726:

          lda temp1
          cmp # 2
          bne skip_6410
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_6410
          jmp PCR_NextOuter
skip_6410:



          ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextOuter
          lda temp1
          cmp # 3
          bne skip_5117
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_5117
          jmp PCR_NextOuter
skip_5117:

          lda temp1
          cmp # 3
          bne skip_5638
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_5638
          jmp PCR_NextOuter
skip_5638:



.pend

PCR_InnerLoop .proc

          lda temp1
          clc
          adc # 1
          sta temp2

.pend

PCR_CheckPair .proc

          if temp2 >= temp6 then goto PCR_NextOuter
          lda temp2
          cmp temp6

          bcc skip_6297

          jmp skip_6297

          skip_6297:

                    if temp2 >= 2 then PCR_CheckP2Active
          jmp PCR_CheckDista


.pend

PCR_CheckP2Active .proc

          lda controllerStatus
          and SetQuadtariDetected
          cmp # 0
          bne skip_1720
          jmp PCR_NextInner
skip_1720:


          ;; if temp2 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextInner
          lda temp2
          cmp # 2
          bne skip_6991
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_6991
          jmp PCR_NextInner
skip_6991:

          lda temp2
          cmp # 2
          bne skip_6083
          lda 2
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_6083
          jmp PCR_NextInner
skip_6083:



          ;; if temp2 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextInner
          lda temp2
          cmp # 3
          bne skip_9173
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_9173
          jmp PCR_NextInner
skip_9173:

          lda temp2
          cmp # 3
          bne skip_9326
          lda 3
          asl
          tax
          lda playerCharacter,x
          cmp NoCharacter
          bne skip_9326
          jmp PCR_NextInner
skip_9326:



.pend

PCR_CheckDistance .proc

                    if playerHealth[temp1] = 0 then goto PCR_NextInner
          lda temp1
          asl
          tax
          lda playerHealth,x
          bne skip_6722
          jmp PCR_NextInner
skip_6722:

                    if playerHealth[temp2] = 0 then goto PCR_NextInner
          lda temp2
          asl
          tax
          lda playerHealth,x
          bne skip_2348
          jmp PCR_NextInner
skip_2348:

                    let temp3 = playerX[temp2] - playerX[temp1]         
          lda temp2
          asl
          tax
          lda playerX,x
          sta temp3

          ;; ;; if temp3 < 0 then let temp3 = 0 - temp3          lda 0          sec          sbc temp3          sta temp3
          lda temp3
          cmp # 0
          bcs skip_9541
          jmp let_label
skip_9541:

          lda temp3
          cmp # 0
          bcs skip_3442
          jmp let_label
skip_3442:

          lda temp3
          cmp # 0
          bcs skip_8952
          jmp let_label
skip_8952:



          if temp3 >= PlayerCollisionDistance then goto PCR_NextInner
          lda temp3
          cmp PlayerCollisionDista


          bcc skip_3330

          jmp skip_3330

          skip_3330:

                    let temp4 = playerY[temp2] - playerY[temp1]         
          lda temp2
          asl
          tax
          lda playerY,x
          sta temp4

          ;; ;; if temp4 < 0 then let temp4 = 0 - temp4          lda 0          sec          sbc temp4          sta temp4
          lda temp4
          cmp # 0
          bcs skip_2095
          jmp let_label
skip_2095:

          lda temp4
          cmp # 0
          bcs skip_858
          jmp let_label
skip_858:

          lda temp4
          cmp # 0
          bcs skip_2874
          jmp let_label
skip_2874:



          ;; Use bit shift instead of division (optimized for Atari 2600)

                    let characterHeight = CharacterHeights[temp1]          lda temp1          asl          tax          lda CharacterHeights,x          sta characterHeight


            lda characterHeight

            lsr

            sta halfHeight1


          ;; Use bit shift instead of division (optimized for Atari 2600)

                    let characterHeight = CharacterHeights[temp2]
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


                    let totalHeight = halfHeight1 + halfHeight2
          lda totalHeight
          cmp # 0
          bne skip_6830
          jmp PCR_NextInner
skip_6830:


          if temp4 >= totalHeight then goto PCR_NextInner
          lda temp4
          cmp totalHeight

          bcc skip_4825

          jmp skip_4825

          skip_4825:

                    let characterWeight = CharacterWeights[temp1]          lda temp1          asl          tax          lda CharacterWeights,x          sta characterWeight

          lda characterWeight
          sta halfHeight1

                    let characterWeight = CharacterWeights[temp2]
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

                    let totalWeight = halfHeight1 + halfHeight2
          lda totalWeight
          cmp # 0
          bne skip_8818
          jmp PCR_NextInner
skip_8818:


                    if playerX[temp1] < playerX[temp2] then goto PCR_SepLeft

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

          if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseRight
          lda halfHeight1
          cmp halfHeight2

          bcc skip_3823

          jmp skip_3823

          skip_3823:


            lda impulseStrength

            asl

            sta impulseStrength


          if totalWeight >= 128 then goto PCR_Div128_1
          lda totalWeight
          cmp 128

          bcc skip_8448

          jmp skip_8448

          skip_8448:

          if totalWeight >= 64 then goto PCR_Div64_1
          lda totalWeight
          cmp 64

          bcc skip_9025

          jmp skip_9025

          skip_9025:

          if totalWeight >= 32 then goto PCR_Div32_1
          lda totalWeight
          cmp 32

          bcc skip_6860

          jmp skip_6860

          skip_6860:


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
          bne skip_7839
          lda # 1
          sta impulseStrength
skip_7839:


          lda temp5
          cmp # 0
          bne skip_9808
          jmp PCR_ImpulseRightDir
skip_9808:


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
          bcs skip_5956
          lda playerVelocityX,x
          sec
          sbc impulseStrength
          sta playerVelocityX,x
skip_5956:

                    if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc 252
          bcc skip_7440
          beq skip_7440
          lda 252
          sta playerVelocityX,x
skip_7440:
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
          bcc skip_4743
          beq skip_4743
          lda 252
          sta playerVelocityX,x
skip_4743:

                    if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          cmp 4
          bcs skip_9126
          lda playerVelocityX
          sta playerVelocityX,x
skip_9126:[temp2] + impulseStrength

                    if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          lda temp2
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc 4
          bcc skip_6614
          beq skip_6614
          lda 4
          sta playerVelocityX,x
skip_6614:

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

          if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseLeft
          lda halfHeight1
          cmp halfHeight2

          bcc skip_4531

          jmp skip_4531

          skip_4531:


            lda impulseStrength

            asl

            sta impulseStrength


          if totalWeight >= 128 then goto PCR_Div128_2
          lda totalWeight
          cmp 128

          bcc skip_8021

          jmp skip_8021

          skip_8021:

          if totalWeight >= 64 then goto PCR_Div64_2
          lda totalWeight
          cmp 64

          bcc skip_3486

          jmp skip_3486

          skip_3486:

          if totalWeight >= 32 then goto PCR_Div32_2
          lda totalWeight
          cmp 32

          bcc skip_2933

          jmp skip_2933

          skip_2933:


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

                    if temp1 < temp6 then goto PCR_OuterLoop
          lda temp1
          cmp temp6
          bcs skip_7180
          jmp PCR_OuterLoop
skip_7180:

          

          rts
.pend

