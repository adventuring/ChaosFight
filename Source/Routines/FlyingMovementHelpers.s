;;; ChaosFight - Source/Routines/FlyingMovementHelpers.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


HFCM_AttemptMoveLeft .proc
          lda currentPlayer
          sta temp1
                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          asl
          tax
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          sec
          sbc ScreenInsetX
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

            lsr temp2
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          cmp # 32
          bcc skip_520
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
skip_520:

                    ;; if temp2 & $80 then let temp2 = 0
          jsr BS_return
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc # 1 (duplicate)
          ;; sta temp3 (duplicate)
                    ;; let temp4 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp7 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp7 (duplicate)
          ;; sta temp2 (duplicate)
          ;; Cross-bank call to PlayfieldRead in bank 16
          ;; lda # >(return_point-1) (duplicate)
          pha
          ;; lda # <(return_point-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # >(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
          ;; lda # <(PlayfieldRead-1) (duplicate)
          ;; pha (duplicate)
                    ldx # 15
          jmp BS_jsr
return_point:

          ;; jsr BS_return (duplicate)
          ;; lda temp4 (duplicate)
          clc
          adc # 16
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp7 (duplicate)
          ;; if temp7 >= pfrows then goto HFCM_ApplyLeft
          ;; lda temp7 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_1152 (duplicate)

          ;; jmp skip_1152 (duplicate)

skip_1152:
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp7 (duplicate)
          ;; sta temp2 (duplicate)
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

          ;; jsr BS_return (duplicate)
.pend

HFCM_ApplyLeft .proc
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
                    ;; let temp5 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp5 (duplicate)
          ;; cmp # 8 (duplicate)
          bne skip_4757
          ;; jmp HFCM_LeftMomentum (duplicate)
skip_4757:

          ;; lda temp5 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_4970 (duplicate)
          ;; jmp HFCM_LeftDirect (duplicate)
skip_4970:

                    ;; let playerVelocityX[temp1] = $ff
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp HFCM_LeftFacing (duplicate)
.pend

HFCM_LeftMomentum .proc
                    ;; let characterMovementSpeed = CharacterMovementSpeed[temp5]         
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta characterMovementSpeed (duplicate)
                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] - characterMovementSpeed
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp HFCM_LeftFacing (duplicate)
.pend

HFCM_LeftDirect .proc
          ;; Dragon of Storms: direct velocity with subpixel accuracy
                    ;; let characterMovementSpeed = CharacterMovementSpeed[temp5]         
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta characterMovementSpeed (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 - characterMovementSpeed          lda temp2          sec          sbc characterMovementSpeed          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc characterMovementSpeed (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc characterMovementSpeed (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy
.pend

HFCM_LeftFacing .proc
          ;; jsr BS_return (duplicate)
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

          ;; ;; if temp2 < 5 then HFCM_SetFacingLeft
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          bcs skip_4100
          ;; jmp HFCM_SetFacingLeft (duplicate)
skip_4100:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_7239 (duplicate)
          ;; jmp HFCM_SetFacingLeft (duplicate)
skip_7239:


          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_3320 (duplicate)
skip_3320:

          ;; jsr BS_return (duplicate)
.pend

HFCM_SetFacingLeft .proc
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          ;; jsr BS_return (duplicate)
.pend

HFCM_AttemptMoveRight .proc
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
                    ;; let temp2 = playerX[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerX,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 - ScreenInsetX          lda temp2          sec          sbc ScreenInsetX          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc ScreenInsetX (duplicate)
          ;; sta temp2 (duplicate)

            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; cmp # 32 (duplicate)
          ;; bcc skip_520 (duplicate)
          ;; lda # 31 (duplicate)
          ;; sta temp2 (duplicate)
;; skip_520: (duplicate)

                    ;; if temp2 & $80 then let temp2 = 0
          ;; jsr BS_return (duplicate)
          ;; lda temp2 (duplicate)
          ;; clc (duplicate)
          ;; adc # 1 (duplicate)
          ;; sta temp3 (duplicate)
                    ;; let temp4 = playerY[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerY,x (duplicate)
          ;; sta temp4 (duplicate)
          ;; lda temp4 (duplicate)
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp7 (duplicate)
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp7 (duplicate)
          ;; sta temp2 (duplicate)
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

          ;; jsr BS_return (duplicate)
          ;; lda temp4 (duplicate)
          ;; clc (duplicate)
          ;; adc # 16 (duplicate)
          ;; sta temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
            ;; lsr temp2 (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta temp7 (duplicate)
          ;; if temp7 >= pfrows then goto HFCM_ApplyRight
          ;; lda temp7 (duplicate)
          ;; cmp pfrows (duplicate)

          ;; bcc skip_7847 (duplicate)

          ;; jmp skip_7847 (duplicate)

          skip_7847:
          ;; lda temp3 (duplicate)
          ;; sta temp1 (duplicate)
          ;; lda temp7 (duplicate)
          ;; sta temp2 (duplicate)
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

          ;; jsr BS_return (duplicate)
.pend

HFCM_ApplyRight .proc
          ;; lda currentPlayer (duplicate)
          ;; sta temp1 (duplicate)
                    ;; let temp5 = playerCharacter[temp1]         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp5 (duplicate)
          ;; lda temp5 (duplicate)
          ;; cmp # 8 (duplicate)
          ;; bne skip_7311 (duplicate)
          ;; jmp HFCM_RightMomentum (duplicate)
skip_7311:

          ;; lda temp5 (duplicate)
          ;; cmp # 2 (duplicate)
          ;; bne skip_5774 (duplicate)
          ;; jmp HFCM_RightDirect (duplicate)
skip_5774:

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp HFCM_RightFacing (duplicate)
.pend

HFCM_RightMomentum .proc
                    ;; let characterMovementSpeed = CharacterMovementSpeed[temp5]         
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta characterMovementSpeed (duplicate)
                    ;; let playerVelocityX[temp1] = playerVelocityX[temp1] + characterMovementSpeed
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp HFCM_RightFacing (duplicate)
.pend

HFCM_RightDirect .proc
          ;; Dragon of Storms: direct velocity with subpixel accuracy
                    ;; let characterMovementSpeed = CharacterMovementSpeed[temp5]         
          ;; lda temp5 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta characterMovementSpeed (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda characterMovementSpeed (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 1 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; Subpixel: 1 = 1/256 pixel for subpixel accuracy
.pend

HFCM_RightFacing .proc
          ;; jsr BS_return (duplicate)
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

          ;; ;; if temp2 < 5 then HFCM_SetFacingRight
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_6152 (duplicate)
          ;; jmp HFCM_SetFacingRight (duplicate)
skip_6152:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_9641 (duplicate)
          ;; jmp HFCM_SetFacingRight (duplicate)
skip_9641:


          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_8619 (duplicate)
skip_8619:

          ;; jsr BS_return (duplicate)
.pend

HFCM_SetFacingRight .proc
                    ;; let playerState[temp1] = playerState[temp1] | 1
          ;; jsr BS_return (duplicate)


.pend

