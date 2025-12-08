;;; ChaosFight - Source/Routines/PlayerCollisionResolution.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



CheckAllPlayerCollisions
          ;; Returns: Far (return otherbank)


;; CheckAllPlayerCollisions (duplicate)


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
                    ;; let temp6 = 2 : goto PCR_SkipElse
skip_7014:

          ;; lda # 4 (duplicate)
          sta temp6


PCR_SkipElse .proc

          ;; lda # 0 (duplicate)
          ;; sta temp1 (duplicate)

.pend

PCR_OuterLoop .proc

          rts

                    ;; if temp1 >= 2 then PCR_CheckP1Active
          jmp PCR_InnerLoop

.pend

PCR_CheckP1Active .proc

          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_3512 (duplicate)
          ;; jmp PCR_NextOuter (duplicate)
skip_3512:


          ;; ;; if temp1 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextOuter
          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_5726 (duplicate)
          ;; lda 2 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_5726 (duplicate)
          ;; jmp PCR_NextOuter (duplicate)
skip_5726:

          ;; lda temp1 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6410 (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_6410 (duplicate)
          ;; jmp PCR_NextOuter (duplicate)
skip_6410:



          ;; ;; if temp1 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextOuter
          ;; lda temp1 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_5117 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_5117 (duplicate)
          ;; jmp PCR_NextOuter (duplicate)
skip_5117:

          ;; lda temp1 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_5638 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_5638 (duplicate)
          ;; jmp PCR_NextOuter (duplicate)
skip_5638:



.pend

PCR_InnerLoop .proc

          ;; lda temp1 (duplicate)
          clc
          adc # 1
          ;; sta temp2 (duplicate)

.pend

PCR_CheckPair .proc

          ;; if temp2 >= temp6 then goto PCR_NextOuter
          ;; lda temp2 (duplicate)
          ;; cmp temp6 (duplicate)

          bcc skip_6297

          ;; jmp skip_6297 (duplicate)

          skip_6297:

                    ;; if temp2 >= 2 then PCR_CheckP2Active
          ;; jmp PCR_CheckDista (duplicate)


.pend

PCR_CheckP2Active .proc

          ;; lda controllerStatus (duplicate)
          ;; and SetQuadtariDetected (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_1720 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_1720:


          ;; ;; if temp2 = 2 && playerCharacter[2] = NoCharacter then goto PCR_NextInner
          ;; lda temp2 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6991 (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_6991 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_6991:

          ;; lda temp2 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_6083 (duplicate)
          ;; lda 2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_6083 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_6083:



          ;; ;; if temp2 = 3 && playerCharacter[3] = NoCharacter then goto PCR_NextInner
          ;; lda temp2 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_9173 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_9173 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_9173:

          ;; lda temp2 (duplicate)
          ;; cmp # 3 (duplicate)
          ;; bne skip_9326 (duplicate)
          ;; lda 3 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; cmp NoCharacter (duplicate)
          ;; bne skip_9326 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_9326:



.pend

PCR_CheckDistance .proc

                    ;; if playerHealth[temp1] = 0 then goto PCR_NextInner
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_6722 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_6722:

                    ;; if playerHealth[temp2] = 0 then goto PCR_NextInner
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerHealth,x (duplicate)
          ;; bne skip_2348 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_2348:

                    ;; let temp3 = playerX[temp2] - playerX[temp1]         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp3 (duplicate)

          ;; ;; ;; if temp3 < 0 then let temp3 = 0 - temp3          lda 0          sec          sbc temp3          sta temp3
          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          bcs skip_9541
          ;; jmp let_label (duplicate)
skip_9541:

          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bcs skip_3442 (duplicate)
          ;; jmp let_label (duplicate)
skip_3442:

          ;; lda temp3 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bcs skip_8952 (duplicate)
          ;; jmp let_label (duplicate)
skip_8952:



          ;; if temp3 >= PlayerCollisionDistance then goto PCR_NextInner
          ;; lda temp3 (duplicate)
          ;; cmp PlayerCollisionDista (duplicate)


          ;; bcc skip_3330 (duplicate)

          ;; jmp skip_3330 (duplicate)

          skip_3330:

                    ;; let temp4 = playerY[temp2] - playerY[temp1]         
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp4 (duplicate)

          ;; ;; ;; if temp4 < 0 then let temp4 = 0 - temp4          lda 0          sec          sbc temp4          sta temp4
          ;; lda temp4 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bcs skip_2095 (duplicate)
          ;; jmp let_label (duplicate)
skip_2095:

          ;; lda temp4 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bcs skip_858 (duplicate)
          ;; jmp let_label (duplicate)
skip_858:

          ;; lda temp4 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bcs skip_2874 (duplicate)
          ;; jmp let_label (duplicate)
skip_2874:



          ;; Use bit shift instead of division (optimized for Atari 2600)

                    ;; let characterHeight = CharacterHeights[temp1]          lda temp1          asl          tax          lda CharacterHeights,x          sta characterHeight


            ;; lda characterHeight (duplicate)

            lsr

            ;; sta halfHeight1 (duplicate)


          ;; Use bit shift instead of division (optimized for Atari 2600)

                    ;; let characterHeight = CharacterHeights[temp2]
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterHeights,x (duplicate)
          ;; sta characterHeight (duplicate)
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterHeights,x (duplicate)
          ;; sta characterHeight (duplicate)


            ;; lda characterHeight (duplicate)

            ;; lsr (duplicate)

            ;; sta halfHeight2 (duplicate)


                    ;; let totalHeight = halfHeight1 + halfHeight2
          ;; lda totalHeight (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_6830 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_6830:


          ;; if temp4 >= totalHeight then goto PCR_NextInner
          ;; lda temp4 (duplicate)
          ;; cmp totalHeight (duplicate)

          ;; bcc skip_4825 (duplicate)

          ;; jmp skip_4825 (duplicate)

          skip_4825:

                    ;; let characterWeight = CharacterWeights[temp1]          lda temp1          asl          tax          lda CharacterWeights,x          sta characterWeight

          ;; lda characterWeight (duplicate)
          ;; sta halfHeight1 (duplicate)

                    ;; let characterWeight = CharacterWeights[temp2]
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWeights,x (duplicate)
          ;; sta characterWeight (duplicate)
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterWeights,x (duplicate)
          ;; sta characterWeight (duplicate)

          ;; lda characterWeight (duplicate)
          ;; sta halfHeight2 (duplicate)

                    ;; let totalWeight = halfHeight1 + halfHeight2
          ;; lda totalWeight (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_8818 (duplicate)
          ;; jmp PCR_NextInner (duplicate)
skip_8818:


                    ;; if playerX[temp1] < playerX[temp2] then goto PCR_SepLeft

          ;; ;; let weightDifference = halfHeight1 - halfHeight2          lda halfHeight1          sec          sbc halfHeight2          sta weightDifference
          ;; lda halfHeight1 (duplicate)
          sec
          sbc halfHeight2
          ;; sta weightDifference (duplicate)

          ;; lda halfHeight1 (duplicate)
          ;; sec (duplicate)
          ;; sbc halfHeight2 (duplicate)
          ;; sta weightDifference (duplicate)


          ;;           ;; if halfHeight1 < halfHeight2 then let weightDifference = halfHeight2 - halfHeight1          lda halfHeight2          sec          sbc halfHeight1          sta weightDifference
          ;; lda weightDifference (duplicate)
          ;; sta impulseStrength (duplicate)

          ;; if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseRight
          ;; lda halfHeight1 (duplicate)
          ;; cmp halfHeight2 (duplicate)

          ;; bcc skip_3823 (duplicate)

          ;; jmp skip_3823 (duplicate)

          skip_3823:


            ;; lda impulseStrength (duplicate)

            ;; asl (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; if totalWeight >= 128 then goto PCR_Div128_1
          ;; lda totalWeight (duplicate)
          ;; cmp 128 (duplicate)

          ;; bcc skip_8448 (duplicate)

          ;; jmp skip_8448 (duplicate)

          skip_8448:

          ;; if totalWeight >= 64 then goto PCR_Div64_1
          ;; lda totalWeight (duplicate)
          ;; cmp 64 (duplicate)

          ;; bcc skip_9025 (duplicate)

          ;; jmp skip_9025 (duplicate)

          skip_9025:

          ;; if totalWeight >= 32 then goto PCR_Div32_1
          ;; lda totalWeight (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_6860 (duplicate)

          ;; jmp skip_6860 (duplicate)

          skip_6860:


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; jmp PCR_ImpulseDone_1 (duplicate)

.pend

PCR_Div32_1 .proc
          ;; Returns: Far (return otherbank)


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; jmp PCR_ImpulseDone_1 (duplicate)

.pend

PCR_Div64_1 .proc
          ;; Returns: Far (return otherbank)


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; jmp PCR_ImpulseDone_1 (duplicate)

.pend

PCR_Div128_1 .proc
          ;; Returns: Far (return otherbank)


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


PCR_ImpulseDone_1

          ;; lda # 1 (duplicate)
          ;; sta temp5 (duplicate)

          ;; jmp PCR_ApplyImpulse (duplicate)

.pend

PCR_ApplyImpulseRight .proc

          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)

.pend

PCR_ApplyImpulse .proc

          ;; lda impulseStrength (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_7839 (duplicate)
          ;; lda # 1 (duplicate)
          ;; sta impulseStrength (duplicate)
skip_7839:


          ;; lda temp5 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_9808 (duplicate)
          ;; jmp PCR_ImpulseRightDir (duplicate)
skip_9808:


                    ;; if playerVelocityX[temp1] < 4 then let playerVelocityX[temp1] = playerVelocityX[temp1] + impulseStrength

                    ;; if playerVelocityX[temp1] > 4 then let playerVelocityX[temp1] = 4
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 4 (duplicate)
          ;; bcc skip_4706 (duplicate)
          beq skip_4706
          ;; lda 4 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
skip_4706:

                    ;; if playerVelocityX[temp2] <= 252 then let playerVelocityX[temp2] = playerVelocityX[temp2] - impulseStrength
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; cmp # 253 (duplicate)
          ;; bcs skip_5956 (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc impulseStrength (duplicate)
          ;; sta playerVelocityX,x (duplicate)
skip_5956:

                    ;; if playerVelocityX[temp2] > 252 then let playerVelocityX[temp2] = 252
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 252 (duplicate)
          ;; bcc skip_7440 (duplicate)
          ;; beq skip_7440 (duplicate)
          ;; lda 252 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
skip_7440:
          ;; jmp PCR_ImpulseDone (duplicate)

.pend

PCR_ImpulseRightDir .proc

                    ;; if playerVelocityX[temp1] <= 252 then let playerVelocityX[temp1] = playerVelocityX[temp1] - impulseStrength

                    ;; if playerVelocityX[temp1] > 252 then let playerVelocityX[temp1] = 252
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 252 (duplicate)
          ;; bcc skip_4743 (duplicate)
          ;; beq skip_4743 (duplicate)
          ;; lda 252 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
skip_4743:

                    ;; if playerVelocityX[temp2] < 4 then let playerVelocityX[temp2] = playerVelocityX
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; cmp 4 (duplicate)
          ;; bcs skip_9126 (duplicate)
          ;; lda playerVelocityX (duplicate)
          ;; sta playerVelocityX,x (duplicate)
skip_9126:[temp2] + impulseStrength

                    ;; if playerVelocityX[temp2] > 4 then let playerVelocityX[temp2] = 4
          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityX,x (duplicate)
          ;; sec (duplicate)
          ;; sbc 4 (duplicate)
          ;; bcc skip_6614 (duplicate)
          ;; beq skip_6614 (duplicate)
          ;; lda 4 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
skip_6614:

PCR_ImpulseDone
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; lda temp2 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; jmp PCR_NextInner (duplicate)

.pend

PCR_SepLeft .proc

          ;; ;; let weightDifference = halfHeight1 - halfHeight2          lda halfHeight1          sec          sbc halfHeight2          sta weightDifference
          ;; lda halfHeight1 (duplicate)
          ;; sec (duplicate)
          ;; sbc halfHeight2 (duplicate)
          ;; sta weightDifference (duplicate)

          ;; lda halfHeight1 (duplicate)
          ;; sec (duplicate)
          ;; sbc halfHeight2 (duplicate)
          ;; sta weightDifference (duplicate)


          ;;           ;; if halfHeight1 < halfHeight2 then let weightDifference = halfHeight2 - halfHeight1          lda halfHeight2          sec          sbc halfHeight1          sta weightDifference
          ;; lda weightDifference (duplicate)
          ;; sta impulseStrength (duplicate)

          ;; if halfHeight1 >= halfHeight2 then goto PCR_ApplyImpulseLeft
          ;; lda halfHeight1 (duplicate)
          ;; cmp halfHeight2 (duplicate)

          ;; bcc skip_4531 (duplicate)

          ;; jmp skip_4531 (duplicate)

          skip_4531:


            ;; lda impulseStrength (duplicate)

            ;; asl (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; if totalWeight >= 128 then goto PCR_Div128_2
          ;; lda totalWeight (duplicate)
          ;; cmp 128 (duplicate)

          ;; bcc skip_8021 (duplicate)

          ;; jmp skip_8021 (duplicate)

          skip_8021:

          ;; if totalWeight >= 64 then goto PCR_Div64_2
          ;; lda totalWeight (duplicate)
          ;; cmp 64 (duplicate)

          ;; bcc skip_3486 (duplicate)

          ;; jmp skip_3486 (duplicate)

          skip_3486:

          ;; if totalWeight >= 32 then goto PCR_Div32_2
          ;; lda totalWeight (duplicate)
          ;; cmp 32 (duplicate)

          ;; bcc skip_2933 (duplicate)

          ;; jmp skip_2933 (duplicate)

          skip_2933:


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; jmp PCR_ImpulseDone_2 (duplicate)

.pend

PCR_Div32_2 .proc
          ;; Returns: Far (return otherbank)


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; jmp PCR_ImpulseDone_2 (duplicate)

.pend

PCR_Div64_2 .proc
          ;; Returns: Far (return otherbank)


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


          ;; jmp PCR_ImpulseDone_2 (duplicate)

.pend

PCR_Div128_2 .proc
          ;; Returns: Far (return otherbank)


            ;; lda impulseStrength (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; lsr (duplicate)

            ;; sta impulseStrength (duplicate)


PCR_ImpulseDone_2

          ;; lda # 0 (duplicate)
          ;; sta temp5 (duplicate)

          ;; jmp PCR_ApplyImpulse (duplicate)

.pend

PCR_ApplyImpulseLeft .proc

          ;; lda # 1 (duplicate)
          ;; sta temp5 (duplicate)

          ;; jmp PCR_ApplyImpulse (duplicate)

.pend

PCR_NextInner .proc

          inc temp2

          ;; jmp PCR_CheckPair (duplicate)

.pend

PCR_NextOuter .proc

          ;; inc temp1 (duplicate)

                    ;; if temp1 < temp6 then goto PCR_OuterLoop
          ;; lda temp1 (duplicate)
          ;; cmp temp6 (duplicate)
          ;; bcs skip_7180 (duplicate)
          ;; jmp PCR_OuterLoop (duplicate)
skip_7180:

          

          ;; rts (duplicate)
.pend

