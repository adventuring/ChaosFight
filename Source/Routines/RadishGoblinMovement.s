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

          jmp BS_return

          ;; if temp1 & 2 = 0 then jmp CheckJoy0RadishGoblin
          lda joy1left
          bne MoveLeftRadishGoblin

          jmp CheckRightRadishGoblin

MoveLeftRadishGoblin:

          jmp MoveLeftRadishGoblin

.pend

CheckJoy0RadishGoblin .proc
          lda joy0left
          bne MoveLeftRadishGoblinLabel

          jmp CheckRightRadishGoblin

MoveLeftRadishGoblinLabel:

.pend

MoveLeftRadishGoblin .proc
          ;; Set temp4 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; Set temp6 = CharacterMovementSpeed[temp4]
          lda temp4
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6

          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc temp6
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

          ;; If (playerState[temp1] & 8), then jmp AfterLeftRadishGoblin
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq AfterLeftRadishGoblinSkip
          jmp AfterLeftRadishGoblin
AfterLeftRadishGoblinSkip:

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateLeft-1)
          pha
          lda # <(AfterGetPlayerAnimationStateLeft-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateLeft:


          ;; if temp2 < 5 then jmp SkipSetFacingLeftRadishGoblin
          lda temp2
          cmp # 5
          bcs .skip_7968
          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationFrame10
          goto_label:

          jmp goto_label
CheckAnimationFrame10:

          lda temp2
          cmp # 5
          bcs CheckAnimationFrame10Label
          jmp goto_label
CheckAnimationFrame10Label:

          

          lda temp2
          cmp # 10
          bcc AfterLeftRadishGoblin
AfterLeftRadishGoblin:


          jmp AfterLeftRadishGoblin

.pend

SkipSetFacingLeftRadishGoblin .proc
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitFacing)
          sta playerState,x

.pend

AfterLeftRadishGoblin .proc

.pend

CheckRightRadishGoblin .proc

          ;; if temp1 & 2 = 0 then jmp CheckRightJoy0RadishGoblin
          lda temp1
          and # 2
          bne MoveRightRadishGoblin
          jmp CheckRightJoy0RadishGoblin
MoveRightRadishGoblin:

          rts
          jmp MoveRightRadishGoblin

.pend

CheckRightJoy0RadishGoblin .proc

          rts

.pend

MoveRightRadishGoblin .proc

          ;; Set temp4 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp4

          ;; Set temp6 = CharacterMovementSpeed[temp4]
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

          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          clc
          adc temp6
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x

          rts

          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateLeft-1)
          pha
          lda # <(AfterGetPlayerAnimationStateLeft-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateLeft:


          ;; if temp2 < 5 then jmp SkipSetFacingRightRadishGoblin
          lda temp2
          cmp # 5
          bcs .CheckAnimationFrame10Right
          jmp
          lda temp2
          cmp # 5
          bcs CheckAnimationFrame10Right
          jmp goto_label
CheckAnimationFrame10Right:

          lda temp2
          cmp # 5
          bcs CheckAnimationFrame10RightLabel
          jmp goto_label
CheckAnimationFrame10RightLabel:

          

          lda temp2
          cmp # 10
          bcc AfterRightRadishGoblin
AfterRightRadishGoblin:


          rts

.pend

SkipSetFacingRightRadishGoblin .proc

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

          jmp BS_return



.pend

RadishGoblinCheckGroundBounce .proc


          ;; Check for ground contact and apply bounce for Radish Goblin
          ;; Returns: Far (return otherbank)

          ;; Input: currentPlayer = player index (0-3) (global)

          lda currentPlayer
          sta temp1

          jmp BS_return

          ;; Convert × to playfield column

          ;; if playerVelocityY[temp1] <= 0 then jmp RGBGB_ClearCheck
          lda temp1
          asl
          tax
          lda playerVelocityY,x
          beq ClearCheckRadishGoblinBounce
          bmi ClearCheckRadishGoblinBounce
          jmp goto_label
ClearCheckRadishGoblinBounce:

          lda temp1
          asl
          tax
          lda playerVelocityY,x
          beq ConvertXToColumn
          bmi ConvertXToColumn
          jmp goto_label
ConvertXToColumn:



          ;; Set temp2 = playerX[temp1] - ScreenInsetX
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2

          ;; If temp2 & $80, set temp2 = 0
          lda temp2
          and # $80
          beq CheckTemp2RangeRadishGoblin
          lda # 0
          sta temp2
CheckTemp2RangeRadishGoblin:

            lsr temp2

            lsr temp2
          lda temp2
          cmp # 32
          bcc CalculateFeetRow
          lda # 31
          sta temp2
CalculateFeetRow:


          ;; Calculate feet row

          lda temp2
          sta temp6

          ;; Set temp2 = playerY[temp1] + PlayerSpriteHeight
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2


            lsr temp2

            lsr temp2

            lsr temp2

            lsr temp2


          ;; if temp2 >= pfrows then jmp ClearCheckRadishGoblinBounce
          lda temp2
          cmp pfrows

          bcc CheckRowBelow

          jmp ClearCheckRadishGoblinBounce

          CheckRowBelow:

          lda temp2
          clc
          adc # 1
          sta temp5

          ;; Check ground pixel

          ;; if temp5 >= pfrows then jmp ClearCheckRadishGoblinBounce
          lda temp5
          cmp pfrows

          bcc CheckGroundPixel

          jmp ClearCheckRadishGoblinBounce

          CheckGroundPixel:

          lda temp1
          sta temp4

          lda temp6
          sta temp1

          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadRadishGoblin-1)
          pha
          lda # <(AfterPlayfieldReadRadishGoblin-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadRadishGoblin:


          lda temp4
          sta temp1

          ;; Ground detected - check bounce sta


          lda temp1
          bne CheckBounceState
          jmp ClearCheckRadishGoblinBounce
CheckBounceState:


          ;; Check if moved away from contact

          ;; if radishGoblinBounceState_R[temp1] = 1 then jmp ClearCheckRadishGoblinBounce

          ;; Set temp2 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2

          ;; Set temp3 = radishGoblinLastContactY_R[temp1]
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

          ;; if temp2 < temp3 then jmp ClearStateRadishGoblinBounce
          lda temp2
          cmp temp3
          bcs CalculateDistanceFromContact
          jmp ClearStateRadishGoblinBounce
CalculateDistanceFromContact:
          

          ;; Set temp4 = temp2 - temp3
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
          bcc CalcBounceRadishGoblin
CalcBounceRadishGoblin:


          jmp CalcBounceRadishGoblin

.pend

ClearStateRadishGoblinBounce .proc

          lda temp1
          asl
          tax
          lda # 0
          sta radishGoblinBounceState_W,x

.pend

CalcBounceRadishGoblin .proc

          ;; Calculate bounce height
          ;; Returns: Far (return otherbank)

          lda RadishGoblinBounceNormal
          sta temp2

          ;; Check jump button (enhanced button or stick up)
          ;; If playerVelocityY[temp1] >= TerminalVelocity, set temp2 = RadishGoblinBounceHighSpeed
          lda temp1
          asl
          tax
          lda playerVelocityY,x
          cmp # TerminalVelocity
          bcc CheckTerminalVelocityDone
          lda # RadishGoblinBounceHighSpeed
          sta temp2
CheckTerminalVelocityDone:
          lda # 0
          sta temp3

          ;; if temp1 >= 2 then jmp CheckStickRadishGoblin
          lda temp1
          cmp # 2

          bcc CheckPlayerIndex

          jmp CheckStickRadishGoblin

          CheckPlayerIndex:

          lda temp1
          cmp # 0
          bne CheckStickRadishGoblinProc
          jmp CheckEnhanced0RadishGoblin
CheckStickRadishGoblinProc .proc:
          ;; If (enhancedButtonStates_R & 2), set temp3 = 1
          lda enhancedButtonStates_R
          and # 2
          beq CheckEnhancedButtonStatesDone
          lda # 1
          sta temp3
CheckEnhancedButtonStatesDone:
          jmp ApplyBounceRadishGoblin

.pend

CheckEnhanced0RadishGoblin .proc
          ;; If (enhancedButtonStates_R & 1), set temp3 = 1
          lda enhancedButtonStates_R
          and # 1
          beq CheckEnhancedButtonStates0Done
          lda # 1
          sta temp3
CheckEnhancedButtonStates0Done:

.pend

CheckStickRadishGoblinLabel .proc
          ;; If temp1 & 2 = 0, then StickJoy0RadishGoblin
          lda temp1
          and # 2
          bne CheckJoy1Up
          jmp StickJoy0RadishGoblin
CheckJoy1Up:
          ;; If joy1up, set temp3 = 1
          lda joy1up
          beq CheckJoy1UpDone
          lda # 1
          sta temp3
CheckJoy1UpDone:
          lda joy1up
          beq ApplyBounceRadishGoblin
          lda # 1
          sta temp3
ApplyBounceRadishGoblin:
          jmp ApplyBounceRadishGoblin

.pend

StickJoy0RadishGoblin .proc

          if joy0up then let temp3 = 1
          lda joy0up
          beq ApplyBounceRadishGoblinLabel
          lda # 1
          sta temp3
ApplyBounceRadishGoblinLabel:
          jmp ApplyBounceRadishGoblinLabel

.pend

ApplyBounceRadishGoblin .proc
          lda temp3
          bne DoubleBounceHeight
DoubleBounceHeight:



            asl temp2


DoneApplyBounceRadishGoblin

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

ClearCheckRadishGoblinBounce .proc

          rts

          ;; Set temp2 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp2

          ;; Set temp3 = radishGoblinLastContactY_R[temp1]
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

          ;; if temp2 < temp3 then jmp ClearState2RadishGoblinBounce
          lda temp2
          cmp temp3
          bcs CalculateDistanceFromContact2
          jmp ClearState2RadishGoblinBounce
CalculateDistanceFromContact2:
          

          ;; Set temp4 = temp2 - temp3
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
          bcc ClearCheckRadishGoblinBounceDone
ClearCheckRadishGoblinBounceDone:


          rts

.pend

ClearState2RadishGoblinBounce .proc

          lda temp1
          asl
          tax
          lda # 0
          sta radishGoblinBounceState_W,x

          rts



.pend

RadishGoblinCheckWallBounce .proc


          ;; Check for wall bounce collision (horizontal only)
          ;; Returns: Far (return otherbank)

          ;; Input: currentPlayer = player index (0-3) (global)

          jmp BS_return

          jmp BS_return



.pend

RadishGoblinHandleStickDownRelease .proc


          ;; Handle stick down release for Radish Goblin (short bounce if on ground)
          ;; Returns: Far (return otherbank)

          ;; Input: temp1 = player index (0-3)

          jmp BS_return

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

          jmp BS_return

.pend

