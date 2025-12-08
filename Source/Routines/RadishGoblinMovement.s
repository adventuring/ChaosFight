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

                    ;; if temp1 & 2 = 0 then goto RGHI_Joy0
          lda joy1left
          bne skip_2716
          jmp RGHI_CheckRight
skip_2716:


          ;; jmp RGHI_Left (duplicate)

.pend

RGHI_Joy0 .proc

          ;; lda joy0left (duplicate)
          ;; bne skip_5517 (duplicate)
          ;; jmp RGHI_CheckRight (duplicate)
skip_5517:


.pend

RGHI_Left .proc

          ;; let temp4 = playerCharacter[temp1]
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda playerCharacter,x (duplicate)
          sta temp4

                    ;; let temp6 = CharacterMovementSpeed[temp4]
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

                    ;; if (playerState[temp1] & 8) then goto RGHI_AfterLeft

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 12
          ;; jmp BS_jsr (duplicate)
return_point:


          ;; ;; if temp2 < 5 then goto RGHI_SPF_No1
          ;; lda temp2 (duplicate)
          cmp 5
          bcs .skip_7968
          ;; jmp (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_25 (duplicate)
          goto_label:

          ;; jmp goto_label (duplicate)
skip_25:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_3287 (duplicate)
          ;; jmp goto_label (duplicate)
skip_3287:

          

          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          bcc skip_6219
skip_6219:


          ;; jmp RGHI_AfterLeft (duplicate)

.pend

RGHI_SPF_No1 .proc

                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)

.pend

RGHI_AfterLeft .proc

.pend

RGHI_CheckRight .proc

                    ;; if temp1 & 2 = 0 then goto RGHI_CheckRightJoy0
          ;; lda temp1 (duplicate)
          and # 2
          ;; bne skip_116 (duplicate)
          ;; jmp RGHI_CheckRightJoy0 (duplicate)
skip_116:

          rts
          ;; jmp RGHI_Right (duplicate)

.pend

RGHI_CheckRightJoy0 .proc

          ;; rts (duplicate)

.pend

RGHI_Right .proc

          ;; let temp4 = playerCharacter[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp4 (duplicate)

                    ;; let temp6 = CharacterMovementSpeed[temp4]
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp4 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)

                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; rts (duplicate)

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(GetPlayerAnimationStateFunction-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 12 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; ;; if temp2 < 5 then goto RGHI_SPF_No2
          ;; lda temp2 (duplicate)
          ;; cmp 5 (duplicate)
          ;; bcs .skip_4322 (duplicate)
          ;; jmp (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_1505 (duplicate)
          ;; jmp goto_label (duplicate)
skip_1505:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_2671 (duplicate)
          ;; jmp goto_label (duplicate)
skip_2671:

          

          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_7248 (duplicate)
skip_7248:


          ;; rts (duplicate)

.pend

RGHI_SPF_No2 .proc

                    ;; let playerState[temp1] = playerState[temp1] | 1

          ;; rts (duplicate)



.pend

RadishGoblinHandleStickDown .proc


          ;; Drop all momentum for Radish Goblin
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = player index (0-3)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityX,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityY,x (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)

          ;; jsr BS_return (duplicate)



.pend

RadishGoblinCheckGroundBounce .proc


          ;; Check for ground contact and apply bounce for Radish Goblin
          ;; Returns: Far (return otherbank)

          ;; Input: currentPlayer = player index (0-3) (global)

          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)

          ;; jsr BS_return (duplicate)

          ;; Convert × to playfield column

          ;; ;; if playerVelocityY[temp1] <= 0 then goto RGBGB_ClearCheck
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityY,x (duplicate)
          beq skip_5806
          bmi skip_5806
          ;; jmp goto_label (duplicate)
skip_5806:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerVelocityY,x (duplicate)
          ;; beq skip_1692 (duplicate)
          ;; bmi skip_1692 (duplicate)
          ;; jmp goto_label (duplicate)
skip_1692:



                    ;; let temp2 = playerX[temp1] - ScreenInsetX         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)

                    ;; if temp2 & $80 then let temp2 = 0


            lsr temp2

            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_4090 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
skip_4090:


          ;; Calculate feet row

          ;; lda temp2 (duplicate)
          ;; sta temp6 (duplicate)

                    ;; let temp2 = playerY[temp1] + PlayerSpriteHeight         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp2 (duplicate)


            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)

            ;; lsr temp2 (duplicate)


          ;; if temp2 >= pfrows then goto RGBGB_ClearCheck
          ;; lda temp2 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_4391 (duplicate)

          ;; jmp skip_4391 (duplicate)

          skip_4391:

          ;; lda temp2 (duplicate)
          clc
          adc # 1
          ;; sta temp5 (duplicate)

          ;; Check ground pixel

          ;; if temp5 >= pfrows then goto RGBGB_ClearCheck
          ;; lda temp5 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_2032 (duplicate)

          ;; jmp skip_2032 (duplicate)

          skip_2032:

          ;; lda temp1 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp6 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ;; ldx # 15 (duplicate)
          ;; jmp BS_jsr (duplicate)
;; return_point: (duplicate)


          ;; lda temp4 (duplicate)
          ;; sta temp1 (duplicate)

          ;; Ground detected - check bounce sta


          ;; lda temp1 (duplicate)
          ;; bne skip_1733 (duplicate)
          ;; jmp RGBGB_ClearCheck (duplicate)
skip_1733:


          ;; Check if moved away from contact

                    ;; if radishGoblinBounceState_R[temp1] = 1 then goto RGBGB_ClearCheck

          ;; let temp2 = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp2 (duplicate)

                    ;; let temp3 = radishGoblinLastContactY_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda radishGoblinLastContactY_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda radishGoblinLastContactY_R,x (duplicate)
          ;; sta temp3 (duplicate)

                    ;; if temp2 < temp3 then goto RGBGB_ClearState
          ;; lda temp2 (duplicate)
          ;; cmp temp3 (duplicate)
          ;; bcs skip_7054 (duplicate)
          ;; jmp RGBGB_ClearState (duplicate)
skip_7054:
          

          ;; ;; let temp4 = temp2 - temp3
          ;; lda temp2 (duplicate)
          sec
          sbc temp3
          ;; sta temp4 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp3 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp3 (duplicate)
          ;; sta temp4 (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp # 9 (duplicate)
          ;; bcc skip_7304 (duplicate)
skip_7304:


          ;; jmp RGBGB_CalcBounce (duplicate)

.pend

RGBGB_ClearState .proc

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta radishGoblinBounceState_W,x (duplicate)

.pend

RGBGB_CalcBounce .proc

          ;; Calculate bounce height
          ;; Returns: Far (return otherbank)

          ;; lda RadishGoblinBounceNormal (duplicate)
          ;; sta temp2 (duplicate)

          ;; Check jump button (enhanced button or stick up)

                    ;; if playerVelocityY[temp1] >= TerminalVelocity then let temp2 = RadishGoblinBounceHighSpeed
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

          ;; if temp1 >= 2 then goto RGBGB_CheckStick
          ;; lda temp1 (duplicate)
          ;; cmp 2 (duplicate)

          ;; bcc skip_696 (duplicate)

          ;; jmp skip_696 (duplicate)

          skip_696:

          ;; lda temp1 (duplicate)
          ;; cmp # 0 (duplicate)
          ;; bne skip_5562 (duplicate)
          ;; jmp RGBGB_CheckEnhanced0 (duplicate)
skip_5562:


                    ;; if (enhancedButtonStates_R & 2) then let temp3 = 1
          ;; jmp RGBGB_CheckStick (duplicate)

.pend

RGBGB_CheckEnhanced0 .proc

                    ;; if (enhancedButtonStates_R & 1) then let temp3 = 1

.pend

RGBGB_CheckStick .proc

                    ;; if temp1 & 2 = 0 then RGBGB_StickJoy0
          ;; lda temp1 (duplicate)
          ;; and # 2 (duplicate)
          ;; bne skip_5425 (duplicate)
          ;; jmp RGBGB_StickJoy0 (duplicate)
skip_5425:

                    ;; if joy1up then let temp3 = 1
          ;; lda joy1up (duplicate)
          ;; beq skip_7169 (duplicate)
          ;; lda 1 (duplicate)
          ;; sta temp3 (duplicate)
skip_7169:
          ;; jmp RGBGB_Apply (duplicate)

.pend

RGBGB_StickJoy0 .proc

          ;; if joy0up then let temp3 = 1
          ;; lda joy0up (duplicate)
          ;; beq skip_1443 (duplicate)
skip_1443:
          ;; jmp skip_1443 (duplicate)

.pend

RGBGB_Apply .proc
          ;; lda temp3 (duplicate)
          ;; bne skip_4524 (duplicate)
skip_4524:



            ;; asl temp2 (duplicate)


RGBGB_DoneApply

                    ;; let playerVelocityY[temp1] = 0 - temp2
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)

                    ;; let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta radishGoblinBounceState_W,x (duplicate)

                    ;; let radishGoblinLastContactY_W[temp1] = playerY[temp1]

          ;; rts (duplicate)

.pend

RGBGB_ClearCheck .proc

          ;; rts (duplicate)

          ;; let temp2 = playerY[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp2 (duplicate)

                    ;; let temp3 = radishGoblinLastContactY_R[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda radishGoblinLastContactY_R,x (duplicate)
          ;; sta temp3 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda radishGoblinLastContactY_R,x (duplicate)
          ;; sta temp3 (duplicate)

                    ;; if temp2 < temp3 then goto RGBGB_ClearState2
          ;; lda temp2 (duplicate)
          ;; cmp temp3 (duplicate)
          ;; bcs skip_7229 (duplicate)
          ;; jmp RGBGB_ClearState2 (duplicate)
skip_7229:
          

          ;; ;; let temp4 = temp2 - temp3
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp3 (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp3 (duplicate)
          ;; sta temp4 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp3 (duplicate)
          ;; sta temp4 (duplicate)


          ;; lda temp4 (duplicate)
          ;; cmp # 9 (duplicate)
          ;; bcc skip_6603 (duplicate)
skip_6603:


          ;; rts (duplicate)

.pend

RGBGB_ClearState2 .proc

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta radishGoblinBounceState_W,x (duplicate)

          ;; rts (duplicate)



.pend

RadishGoblinCheckWallBounce .proc


          ;; Check for wall bounce collision (horizontal only)
          ;; Returns: Far (return otherbank)

          ;; Input: currentPlayer = player index (0-3) (global)

          ;; jsr BS_return (duplicate)

          ;; jsr BS_return (duplicate)



.pend

RadishGoblinHandleStickDownRelease .proc


          ;; Handle stick down release for Radish Goblin (short bounce if on ground)
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = player index (0-3)

          ;; jsr BS_return (duplicate)

                    ;; let playerVelocityY[temp1] = 0 - RadishGoblinBounceShort
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityYL,x (duplicate)

                    ;; let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta radishGoblinBounceState_W,x (duplicate)

          ;; jsr BS_return (duplicate)

.pend

