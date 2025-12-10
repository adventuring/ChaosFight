;;; ChaosFight - Source/Routines/RadishGoblinMovement.bas

;;; Copyright © 2025 Bruce-Robert Pocock.



          ;; Radish Goblin Bounce Movement System (Optimized)

          ;; Complete replacement of standard movement for Radish Goblin character




RadishGoblinHandleInput .proc


          ;; Handle joystick input for Radish Goblin bounce movement
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = player index (0-3)

          ;; Output: Horizontal momentum added based on stick direction (only when on ground)

          ;; Determine joy port (temp1 & 2 = 0 for players 0,2 use joy0)

          jsr BS_return

                    if temp1 & 2 = 0 then goto RGHI_Joy0
          lda joy1left
          bne skip_2716
          jmp RGHI_CheckRight
skip_2716:


          jmp RGHI_Left

.pend

RGHI_Joy0 .proc

          lda joy0left
          bne skip_5517
          jmp RGHI_CheckRight
skip_5517:


.pend

RGHI_Left .proc

          let temp4 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

                    let temp6 = CharacterMovementSpeed[temp4]
          lda temp4
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp4
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

                    let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

                    if (playerState[temp1] & 8) then goto RGHI_AfterLeft

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          ;; if temp2 < 5 then goto RGHI_SPF_No1
          lda temp2
          cmp 5
          bcs .skip_7968
          jmp
          lda temp2
          cmp # 5
          bcs skip_25
          goto_label:

          jmp goto_label
skip_25:

          lda temp2
          cmp # 5
          bcs skip_3287
          jmp goto_label
skip_3287:

          

          lda temp2
          cmp # 10
          bcc skip_6219
skip_6219:


          jmp RGHI_AfterLeft

.pend

RGHI_SPF_No1 .proc

                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)

.pend

RGHI_AfterLeft .proc

.pend

RGHI_CheckRight .proc

                    if temp1 & 2 = 0 then goto RGHI_CheckRightJoy0
          lda temp1
          and # 2
          bne skip_116
          jmp RGHI_CheckRightJoy0
skip_116:

          rts
          jmp RGHI_Right

.pend

RGHI_CheckRightJoy0 .proc

          rts

.pend

RGHI_Right .proc

          let temp4 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

                    let temp6 = CharacterMovementSpeed[temp4]
          lda temp4
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp4
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

                    let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          rts

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
return_point:


          ;; if temp2 < 5 then goto RGHI_SPF_No2
          lda temp2
          cmp 5
          bcs .skip_4322
          jmp
          lda temp2
          cmp # 5
          bcs skip_1505
          jmp goto_label
skip_1505:

          lda temp2
          cmp # 5
          bcs skip_2671
          jmp goto_label
skip_2671:

          

          lda temp2
          cmp # 10
          bcc skip_7248
skip_7248:


          rts

.pend

RGHI_SPF_No2 .proc

                    let playerState[temp1] = playerState[temp1] | 1

          rts



.pend

RadishGoblinHandleStickDown .proc


          ;; Drop all momentum for Radish Goblin
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = player index (0-3)
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityX,x

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityY,x

          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

          jsr BS_return



.pend

RadishGoblinCheckGroundBounce .proc


          ;; Check for ground contact and apply bounce for Radish Goblin
          ;; Returns: Far (return otherbank)

          ;; Input: currentPlayer = player index (0-3) (global)

          lda currentPlayer
          sta temp1

          jsr BS_return

          ;; Convert × to playfield column

          ;; if playerVelocityY[temp1] <= 0 then goto RGBGB_ClearCheck
          lda temp1
          asl
          tax
          lda playerVelocityY,x
          beq skip_5806
          bmi skip_5806
          jmp goto_label
skip_5806:

          lda temp1
          asl
          tax
          lda playerVelocityY,x
          beq skip_1692
          bmi skip_1692
          jmp goto_label
skip_1692:



                    let temp2 = playerX[temp1] - ScreenInsetX         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

                    if temp2 & $80 then let temp2 = 0


            lsr temp2

            lsr temp2
          lda temp2
          cmp # 32
          bcc skip_4090
          lda # 31
          sta temp2
skip_4090:


          ;; Calculate feet row

          lda temp2
          sta temp6

                    let temp2 = playerY[temp1] + PlayerSpriteHeight         
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2


            lsr temp2

            lsr temp2

            lsr temp2

            lsr temp2


          if temp2 >= pfrows then goto RGBGB_ClearCheck
          lda temp2
          cmp pfrows

          bcc skip_4391

          jmp skip_4391

          skip_4391:

          lda temp2
          clc
          adc # 1
          sta temp5

          ;; Check ground pixel

          if temp5 >= pfrows then goto RGBGB_ClearCheck
          lda temp5
          cmp pfrows

          bcc skip_2032

          jmp skip_2032

          skip_2032:

          lda temp1
          sta temp4

          lda temp6
          sta temp1

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(return_point-1)
          pha
          lda # <(return_point-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
return_point:


          lda temp4
          sta temp1

          ;; Ground detected - check bounce sta


          lda temp1
          bne skip_1733
          jmp RGBGB_ClearCheck
skip_1733:


          ;; Check if moved away from contact

                    if radishGoblinBounceState_R[temp1] = 1 then goto RGBGB_ClearCheck

          let temp2 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2

                    let temp3 = radishGoblinLastContactY_R[temp1]
          lda temp1
          asl
          tax
          lda radishGoblinLastContactY_R,x
          sta temp3
          lda temp1
          asl
          tax
          lda radishGoblinLastContactY_R,x
          sta temp3

                    if temp2 < temp3 then goto RGBGB_ClearState
          lda temp2
          cmp temp3
          bcs skip_7054
          jmp RGBGB_ClearState
skip_7054:
          

          ;; let temp4 = temp2 - temp3
          lda temp2
          sec
          sbc temp3
          sta temp4
          lda temp2
          sec
          sbc temp3
          sta temp4

          lda temp2
          sec
          sbc temp3
          sta temp4


          lda temp4
          cmp # 9
          bcc skip_7304
skip_7304:


          jmp RGBGB_CalcBounce

.pend

RGBGB_ClearState .proc

          lda temp1
          asl
          tax
          lda 0
          sta radishGoblinBounceState_W,x

.pend

RGBGB_CalcBounce .proc

          ;; Calculate bounce height
          ;; Returns: Far (return otherbank)

          lda RadishGoblinBounceNormal
          sta temp2

          ;; Check jump button (enhanced button or stick up)

                    if playerVelocityY[temp1] >= TerminalVelocity then let temp2 = RadishGoblinBounceHighSpeed
          lda # 0
          sta temp3

          if temp1 >= 2 then goto RGBGB_CheckStick
          lda temp1
          cmp 2

          bcc skip_696

          jmp skip_696

          skip_696:

          lda temp1
          cmp # 0
          bne skip_5562
          jmp RGBGB_CheckEnhanced0
skip_5562:


                    if (enhancedButtonStates_R & 2) then let temp3 = 1
          jmp RGBGB_CheckStick

.pend

RGBGB_CheckEnhanced0 .proc

                    if (enhancedButtonStates_R & 1) then let temp3 = 1

.pend

RGBGB_CheckStick .proc

                    if temp1 & 2 = 0 then RGBGB_StickJoy0
          lda temp1
          and # 2
          bne skip_5425
          jmp RGBGB_StickJoy0
skip_5425:

                    if joy1up then let temp3 = 1
          lda joy1up
          beq skip_7169
          lda 1
          sta temp3
skip_7169:
          jmp RGBGB_Apply

.pend

RGBGB_StickJoy0 .proc

          if joy0up then let temp3 = 1
          lda joy0up
          beq skip_1443
skip_1443:
          jmp skip_1443

.pend

RGBGB_Apply .proc
          lda temp3
          bne skip_4524
skip_4524:



            asl temp2


RGBGB_DoneApply

                    let playerVelocityY[temp1] = 0 - temp2
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

                    let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          lda temp1
          asl
          tax
          lda 1
          sta radishGoblinBounceState_W,x

                    let radishGoblinLastContactY_W[temp1] = playerY[temp1]

          rts

.pend

RGBGB_ClearCheck .proc

          rts

          let temp2 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2

                    let temp3 = radishGoblinLastContactY_R[temp1]
          lda temp1
          asl
          tax
          lda radishGoblinLastContactY_R,x
          sta temp3
          lda temp1
          asl
          tax
          lda radishGoblinLastContactY_R,x
          sta temp3

                    if temp2 < temp3 then goto RGBGB_ClearState2
          lda temp2
          cmp temp3
          bcs skip_7229
          jmp RGBGB_ClearState2
skip_7229:
          

          ;; let temp4 = temp2 - temp3
          lda temp2
          sec
          sbc temp3
          sta temp4
          lda temp2
          sec
          sbc temp3
          sta temp4

          lda temp2
          sec
          sbc temp3
          sta temp4


          lda temp4
          cmp # 9
          bcc skip_6603
skip_6603:


          rts

.pend

RGBGB_ClearState2 .proc

          lda temp1
          asl
          tax
          lda 0
          sta radishGoblinBounceState_W,x

          rts



.pend

RadishGoblinCheckWallBounce .proc


          ;; Check for wall bounce collision (horizontal only)
          ;; Returns: Far (return otherbank)

          ;; Input: currentPlayer = player index (0-3) (global)

          jsr BS_return

          jsr BS_return



.pend

RadishGoblinHandleStickDownRelease .proc


          ;; Handle stick down release for Radish Goblin (short bounce if on ground)
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = player index (0-3)

          jsr BS_return

                    let playerVelocityY[temp1] = 0 - RadishGoblinBounceShort
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityYL,x

                    let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          lda temp1
          asl
          tax
          lda 0
          sta radishGoblinBounceState_W,x

          jsr BS_return

.pend

