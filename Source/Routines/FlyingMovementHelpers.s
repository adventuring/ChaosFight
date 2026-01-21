;;; ChaosFight - Source/Routines/FlyingMovementHelpers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HandleFlyingCharacterMovementAttemptMoveLeft .proc
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
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveLeft1-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveLeft1 hi (encoded)]
          lda # <(AfterPlayfieldReadMoveLeft1-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveLeft1 hi (encoded)] [SP+0: AfterPlayfieldReadMoveLeft1 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveLeft1 hi (encoded)] [SP+1: AfterPlayfieldReadMoveLeft1 lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveLeft1 hi (encoded)] [SP+2: AfterPlayfieldReadMoveLeft1 lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
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
          ;; if temp7 >= pfrows then jmp HandleFlyingCharacterMovementApplyLeft
          lda temp7
          cmp # pfrows

          bcc RowInRange

          jmp HandleFlyingCharacterMovementApplyLeft

RowInRange:
          lda temp3
          sta temp1
          lda temp7
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveLeft2-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveLeft2 hi (encoded)]
          lda # <(AfterPlayfieldReadMoveLeft2-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveLeft2 hi (encoded)] [SP+0: AfterPlayfieldReadMoveLeft2 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveLeft2 hi (encoded)] [SP+1: AfterPlayfieldReadMoveLeft2 lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveLeft2 hi (encoded)] [SP+2: AfterPlayfieldReadMoveLeft2 lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
          ldx # 15
          jmp BS_jsr

AfterPlayfieldReadMoveLeft2:

          jmp BS_return
.pend

HandleFlyingCharacterMovementApplyLeft .proc
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
          jmp HandleFlyingCharacterMovementLeftMomentum
CheckDragonOfStormsLeft:

          lda temp5
          cmp # 2
          bne HandleFlyingCharacterMovementLeftStandard
          jmp HandleFlyingCharacterMovementLeftDirect
HandleFlyingCharacterMovementLeftStandard:

          ;; Set playerVelocityX[temp1] = $ff
          lda temp1
          asl
          tax
          lda # $ff
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp HandleFlyingCharacterMovementLeftFacing
.pend

HandleFlyingCharacterMovementLeftMomentum .proc
          ;; Set characterMovementSpeed = CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] - characterMovementSpeed
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          sec
          sbc characterMovementSpeed
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp HandleFlyingCharacterMovementLeftFacing
.pend

HandleFlyingCharacterMovementLeftDirect .proc
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
          lda # 1
          sta playerVelocityXL,x
          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy
.pend

HandleFlyingCharacterMovementLeftFacing .proc
          jmp BS_return
          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 12
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterGetPlayerAnimationStateLeft-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerAnimationStateLeft hi (encoded)]
          lda # <(AfterGetPlayerAnimationStateLeft-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerAnimationStateLeft hi (encoded)] [SP+0: AfterGetPlayerAnimationStateLeft lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerAnimationStateLeft hi (encoded)] [SP+1: AfterGetPlayerAnimationStateLeft lo] [SP+0: GetPlayerAnimationStateFunction hi (raw)]
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerAnimationStateLeft hi (encoded)] [SP+2: AfterGetPlayerAnimationStateLeft lo] [SP+1: GetPlayerAnimationStateFunction hi (raw)] [SP+0: GetPlayerAnimationStateFunction lo]
          ldx # 12
          jmp BS_jsr
AfterGetPlayerAnimationStateLeft:

          ;; If temp2 < 5, then HandleFlyingCharacterMovementSetFacingLeft
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Left
          jmp HandleFlyingCharacterMovementSetFacingLeft
CheckAnimationState10Left:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10LeftLabel
          jmp HandleFlyingCharacterMovementSetFacingLeft
CheckAnimationState10LeftLabel:


          lda temp2
          cmp # 10
          bcc HandleFlyingCharacterMovementLeftFacingDone
HandleFlyingCharacterMovementLeftFacingDone:

          jmp BS_return
.pend

HandleFlyingCharacterMovementSetFacingLeft .proc
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitFacing)
          sta playerState,x
          jmp BS_return
.pend

HandleFlyingCharacterMovementAttemptMoveRight .proc
          lda currentPlayer
          sta temp1
          ;; Set temp2 = playerX[temp1]
          lda temp1
          asl
          tax
          lda playerX,x
          sta temp2
          ;; Set temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc # ScreenInsetX          sta temp2
          lda temp2
          sec
          sbc # ScreenInsetX
          sta temp2

          lda temp2
          sec
          sbc # ScreenInsetX
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
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveRight1-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveRight1 hi (encoded)]
          lda # <(AfterPlayfieldReadMoveRight1-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveRight1 hi (encoded)] [SP+0: AfterPlayfieldReadMoveRight1 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveRight1 hi (encoded)] [SP+1: AfterPlayfieldReadMoveRight1 lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveRight1 hi (encoded)] [SP+2: AfterPlayfieldReadMoveRight1 lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
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
          ;; if temp7 >= pfrows then jmp HandleFlyingCharacterMovementApplyRight
          lda temp7
          cmp pfrows

          bcc RowInRangeRight

          jmp RowInRangeRight

          RowInRangeRight:
          lda temp3
          sta temp1
          lda temp7
          sta temp2
          ;; Cross-bank call to PlayfieldRead in bank 15
          ;; Return address: ENCODED with caller bank 6 ($60) for BS_return to decode
          lda # ((>(AfterPlayfieldReadMoveRight2-1)) & $0f) | $60  ;;; Encode bank 6 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayfieldReadMoveRight2 hi (encoded)]
          lda # <(AfterPlayfieldReadMoveRight2-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayfieldReadMoveRight2 hi (encoded)] [SP+0: AfterPlayfieldReadMoveRight2 lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayfieldReadMoveRight2 hi (encoded)] [SP+1: AfterPlayfieldReadMoveRight2 lo] [SP+0: PlayfieldRead hi (raw)]
          lda # <(PlayfieldRead-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayfieldReadMoveRight2 hi (encoded)] [SP+2: AfterPlayfieldReadMoveRight2 lo] [SP+1: PlayfieldRead hi (raw)] [SP+0: PlayfieldRead lo]
          ldx # 15
          jmp BS_jsr
AfterPlayfieldReadMoveRight2:

          jmp BS_return
.pend

HandleFlyingCharacterMovementApplyRight .proc
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
          jmp HandleFlyingCharacterMovementRightMomentum
CheckDragonOfStormsRight:

          lda temp5
          cmp # 2
          bne HandleFlyingCharacterMovementRightStandard
          jmp HandleFlyingCharacterMovementRightDirect
HandleFlyingCharacterMovementRightStandard:

          lda temp1
          asl
          tax
          lda # 1
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp HandleFlyingCharacterMovementRightFacing
.pend

HandleFlyingCharacterMovementRightMomentum .proc
          ;; Set characterMovementSpeed = CharacterMovementSpeed[temp5]
          lda temp5
          asl
          tax
          lda CharacterMovementSpeed,x
          sta characterMovementSpeed
          ;; Set playerVelocityX[temp1] = playerVelocityX[temp1] + characterMovementSpeed
          lda temp1
          asl
          tax
          lda playerVelocityX,x
          clc
          adc characterMovementSpeed
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp HandleFlyingCharacterMovementRightFacing
.pend

HandleFlyingCharacterMovementRightDirect .proc
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
          lda # 1
          sta playerVelocityXL,x
          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy
.pend

HandleFlyingCharacterMovementRightFacing .proc
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

          ;; If temp2 < 5, then HandleFlyingCharacterMovementSetFacingRight
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right
          jmp HandleFlyingCharacterMovementSetFacingRight
CheckAnimationState10Right:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10RightLabel
          jmp HandleFlyingCharacterMovementSetFacingRight
CheckAnimationState10RightLabel:


          lda temp2
          cmp # 10
          bcc HandleFlyingCharacterMovementRightFacingDone
HandleFlyingCharacterMovementRightFacingDone:

          jmp BS_return
.pend

HandleFlyingCharacterMovementSetFacingRight .proc
          ;; Set playerState[temp1] = playerState[temp1] | 1
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 1
          sta playerState,x
          jmp BS_return


.pend

