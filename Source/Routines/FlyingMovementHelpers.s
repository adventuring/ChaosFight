;;; ChaosFight - Source/Routines/FlyingMovementHelpers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HFCM_AttemptMoveLeft .proc
          lda currentPlayer
          sta temp1
          ;; Set temp2 = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; Set temp2 = temp2 - ScreenInsetX
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

            lsr temp2
            lsr temp2
          lda temp2
          cmp # 32
          bcc ColumnInRange

          lda # 31
          sta temp2

ColumnInRange:

          ;; If temp2 & $80, set temp2 = 0
          jmp BS_return

          lda temp2
          sec
          sbc # 1
          sta temp3
          ;; Set temp4 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp4
          lda temp4
          sta temp2
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          lda temp2
          sta temp7
          lda temp3
          sta temp1
          lda temp7
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveLeft1-1)
          pha
          lda # <(AfterPlayfieldReadMoveLeft1-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
          ldx # 15
          jmp BS_jsr

AfterPlayfieldReadMoveLeft1:

          jmp BS_return

          lda temp4
          clc
          adc # 16
          sta temp2
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          lda temp2
          sta temp7
          ;; if temp7 >= pfrows then jmp HFCM_ApplyLeft
          lda temp7
          cmp # pfrows

          bcc RowInRange

          jmp HFCM_ApplyLeft

RowInRange:
          lda temp3
          sta temp1
          lda temp7
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveLeft2-1)
          pha
          lda # <(AfterPlayfieldReadMoveLeft2-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
          ldx # 15
          jmp BS_jsr

AfterPlayfieldReadMoveLeft2:

          jmp BS_return
.pend

HFCM_ApplyLeft .proc
          lda currentPlayer
          sta temp1
          ;; Set temp5 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5
          lda temp5
          cmp # 8
          bne CheckDragonOfStormsLeft
          jmp HFCM_LeftMomentum
CheckDragonOfStormsLeft:

          lda temp5
          cmp # 2
          bne HFCM_LeftStandard
          jmp HFCM_LeftDirect
HFCM_LeftStandard:

          ;; let playerVelocityX[temp1] = $ff
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          jmp HFCM_LeftFacing
.pend

HFCM_LeftMomentum .proc
          ;; Set characterMovementSpeed = CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
          ;; let playerVelocityX[temp1] = playerVelocityX[temp1] - characterMovementSpeed
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          jmp HFCM_LeftFacing
.pend

HFCM_LeftDirect .proc
          ;; Dragon of Storms: direct velocity with subpixel accuracy
          ;; Set characterMovementSpeed = CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
          lda # 0
          sta temp2
          ;; Set temp2 = temp2 - characterMovementSpeed          lda temp2          sec          sbc characterMovementSpeed          sta temp2
          lda temp2
          sec
          sbc characterMovementSpeed
          sta temp2

          lda temp2
          sec
          sbc characterMovementSpeed
          sta temp2

          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda 1
          sta playerVelocityXL,x
          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy
.pend

HFCM_LeftFacing .proc
          jmp BS_return
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

          ;; If temp2 < 5, then HFCM_SetFacingLeft
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Left
          jmp HFCM_SetFacingLeft
CheckAnimationState10Left:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10LeftLabel
          jmp HFCM_SetFacingLeft
CheckAnimationState10LeftLabel:


          lda temp2
          cmp # 10
          bcc HFCM_LeftFacingDone
HFCM_LeftFacingDone:

          jmp BS_return
.pend

HFCM_SetFacingLeft .proc
          ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          jmp BS_return
.pend

HFCM_AttemptMoveRight .proc
          lda currentPlayer
          sta temp1
          ;; Set temp2 = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; Set temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc ScreenInsetX
          sta temp2

            lsr temp2
            lsr temp2
          lda temp2
          cmp # 32
          bcc ColumnInRangeRight
          lda # 31
          sta temp2
ColumnInRangeRight:

          ;; If temp2 & $80, set temp2 = 0
          jmp BS_return
          lda temp2
          clc
          adc # 1
          sta temp3
          ;; Set temp4 = playerY[temp1]
          lda temp1
          asl
          tax
          lda playerY,x
          sta temp4
          lda temp4
          sta temp2
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          lda temp2
          sta temp7
          lda temp3
          sta temp1
          lda temp7
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveRight1-1)
          pha
          lda # <(AfterPlayfieldReadMoveRight1-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveRight1:

          jmp BS_return
          lda temp4
          clc
          adc # 16
          sta temp2
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
          lda temp2
          sta temp7
          ;; if temp7 >= pfrows then jmp HFCM_ApplyRight
          lda temp7
          cmp pfrows

          bcc RowInRangeRight

          jmp RowInRangeRight

          RowInRangeRight:
          lda temp3
          sta temp1
          lda temp7
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 16
          lda # >(AfterPlayfieldReadMoveRight2-1)
          pha
          lda # <(AfterPlayfieldReadMoveRight2-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
                    ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveRight2:

          jmp BS_return
.pend

HFCM_ApplyRight .proc
          lda currentPlayer
          sta temp1
          ;; Set temp5 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5
          lda temp5
          cmp # 8
          bne CheckDragonOfStormsRight
          jmp HFCM_RightMomentum
CheckDragonOfStormsRight:

          lda temp5
          cmp # 2
          bne HFCM_RightStandard
          jmp HFCM_RightDirect
HFCM_RightStandard:

          lda temp1
          asl
          tax
          lda 1
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          jmp HFCM_RightFacing
.pend

HFCM_RightMomentum .proc
          ;; Set characterMovementSpeed = CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
                    let playerVelocityX[temp1] = playerVelocityX[temp1] + characterMovementSpeed
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          jmp HFCM_RightFacing
.pend

HFCM_RightDirect .proc
          ;; Dragon of Storms: direct velocity with subpixel accuracy
          ;; Set characterMovementSpeed = CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
          lda temp1
          asl
          tax
          lda characterMovementSpeed
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda 1
          sta playerVelocityXL,x
          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy
.pend

HFCM_RightFacing .proc
          jmp BS_return
          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # >(AfterGetPlayerAnimationStateRight-1)
          pha
          lda # <(AfterGetPlayerAnimationStateRight-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
                    ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateRight:

          ;; If temp2 < 5, then HFCM_SetFacingRight
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right
          jmp HFCM_SetFacingRight
CheckAnimationState10Right:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightLabel
          jmp HFCM_SetFacingRight
CheckAnimationState10RightLabel:


          lda temp2
          cmp # 10
          bcc HFCM_RightFacingDone
HFCM_RightFacingDone:

          jmp BS_return
.pend

HFCM_SetFacingRight .proc
                    let playerState[temp1] = playerState[temp1] | 1
          jmp BS_return


.pend

