;;; ChaosFight - Source/Routines/FlyingMovementHelpers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HFCM_AttemptMoveLeft .proc
          lda currentPlayer
          sta temp1
                    let temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
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
          bcc skip_520
          lda # 31
          sta temp2
skip_520:

                    if temp2 & $80 then let temp2 = 0
          jsr BS_return
          lda temp2
          sec
          sbc # 1
          sta temp3
                    let temp4 = playerY[temp1]         
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

          jsr BS_return
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
          if temp7 >= pfrows then goto HFCM_ApplyLeft
          lda temp7
          cmp pfrows

          bcc skip_1152

          jmp skip_1152

skip_1152:
          lda temp3
          sta temp1
          lda temp7
          sta temp2
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

          jsr BS_return
.pend

HFCM_ApplyLeft .proc
          lda currentPlayer
          sta temp1
                    let temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5
          lda temp5
          cmp # 8
          bne skip_4757
          jmp HFCM_LeftMomentum
skip_4757:

          lda temp5
          cmp # 2
          bne skip_4970
          jmp HFCM_LeftDirect
skip_4970:

                    let playerVelocityX[temp1] = $ff
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          jmp HFCM_LeftFacing
.pend

HFCM_LeftMomentum .proc
                    let characterMovementSpeed = CharacterMovementSpeed[temp5]         
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
                    let playerVelocityX[temp1] = playerVelocityX[temp1] - characterMovementSpeed
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x
          jmp HFCM_LeftFacing
.pend

HFCM_LeftDirect .proc
          ;; Dragon of Storms: direct velocity with subpixel accuracy
                    let characterMovementSpeed = CharacterMovementSpeed[temp5]         
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
          lda # 0
          sta temp2
          ;; let temp2 = temp2 - characterMovementSpeed          lda temp2          sec          sbc characterMovementSpeed          sta temp2
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
          jsr BS_return
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

          ;; if temp2 < 5 then HFCM_SetFacingLeft
          lda temp2
          cmp # 5
          bcs skip_4100
          jmp HFCM_SetFacingLeft
skip_4100:

          lda temp2
          cmp # 5
          bcs skip_7239
          jmp HFCM_SetFacingLeft
skip_7239:


          lda temp2
          cmp # 10
          bcc skip_3320
skip_3320:

          jsr BS_return
.pend

HFCM_SetFacingLeft .proc
                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          jsr BS_return
.pend

HFCM_AttemptMoveRight .proc
          lda currentPlayer
          sta temp1
                    let temp2 = playerX[temp1]         
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
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
          bcc skip_520
          lda # 31
          sta temp2
skip_520:

                    if temp2 & $80 then let temp2 = 0
          jsr BS_return
          lda temp2
          clc
          adc # 1
          sta temp3
                    let temp4 = playerY[temp1]         
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

          jsr BS_return
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
          if temp7 >= pfrows then goto HFCM_ApplyRight
          lda temp7
          cmp pfrows

          bcc skip_7847

          jmp skip_7847

          skip_7847:
          lda temp3
          sta temp1
          lda temp7
          sta temp2
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

          jsr BS_return
.pend

HFCM_ApplyRight .proc
          lda currentPlayer
          sta temp1
                    let temp5 = playerCharacter[temp1]         
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp5
          lda temp5
          cmp # 8
          bne skip_7311
          jmp HFCM_RightMomentum
skip_7311:

          lda temp5
          cmp # 2
          bne skip_5774
          jmp HFCM_RightDirect
skip_5774:

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
                    let characterMovementSpeed = CharacterMovementSpeed[temp5]         
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
                    let characterMovementSpeed = CharacterMovementSpeed[temp5]         
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
          jsr BS_return
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

          ;; if temp2 < 5 then HFCM_SetFacingRight
          lda temp2
          cmp # 5
          bcs skip_6152
          jmp HFCM_SetFacingRight
skip_6152:

          lda temp2
          cmp # 5
          bcs skip_9641
          jmp HFCM_SetFacingRight
skip_9641:


          lda temp2
          cmp # 10
          bcc skip_8619
skip_8619:

          jsr BS_return
.pend

HFCM_SetFacingRight .proc
                    let playerState[temp1] = playerState[temp1] | 1
          jsr BS_return


.pend

