;;; ChaosFight - Source/Routines/ProcessStandardMovement.bas
;;; Copyright © 2025 Bruce-Robert Pocock.


ProcessStandardMovement .proc
          ;; Returns: Far (return otherbank)
          ;; Shared Standard Movement Handler
          ;; Handles left/right movement for standard (non-flying) characters
          ;; Uses temp1 & 2 pattern to select joy0 vs joy1 (same as HandleFlyingCharacterMovement)
          ;; INPUT: temp1 = player index (0-3)
          ;; Uses: joy0left/joy0right for players 0,2; joy1left/joy1right for players 1,3
          ;; OUTPUT: Movement applied to playerVelocityX[] or playerX[]
          ;; Mutates: temp2, temp3, temp6, playerVelocityX[], playerVelocityXL[],
          ;; playerX[], playerState[]
          ;; Called Routines: GetPlayerAnimationStateFunction
          ;; Constraints: Must be colocated with PSM_UseJoy0, PSM_CheckLeftJoy0,
          ;; PSM_CheckRightJoy0 helpers
          ;; Check if player is guarding - guard blocks movement (right port only)
          ;; Left port does not check guard here (may be bug, but preserving behavior)
          ;; Right port handler should check guard before calling this
          ;; Determine which joy port to use based on player index
          ;; Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          ;; Players 1,3 use joy1
          ;; if temp1 & 2 = 0 then jmp PSM_UseJoy0
          lda temp1
          and # 2
          beq PSM_UseJoy0Label
          jmp PSM_CheckJoy1
PSM_UseJoy0Label:
          jmp PSM_UseJoy0
PSM_CheckJoy1:
          ;; Left movement: set negative velocity (joy1)
          lda SWCHA
          and # $08
          beq PSM_ApplyLeftJoy1Label
          jmp PSM_CheckRightJoy1
PSM_ApplyLeftJoy1Label:
          jmp PSM_ApplyLeftJoy1

PSM_ApplyLeftJoy1:
          ;; Check if playerCharacter[temp1] = CharacterFrooty
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterFrooty
          beq PSM_LeftMomentum1
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda # 0
          sta temp2
          ;; Set temp2 = temp2 - temp6
          lda temp2
          sec
          sbc temp6
          sta temp2

          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp PSM_AfterLeftSet1

.pend

PSM_LeftMomentum1 .proc
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
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

.pend

PSM_AfterLeftSet1 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
          ;; Check if (playerState[temp1] & 8) then PSM_InlineYesLeft
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq PSM_InlineNoLeft
          jmp PSM_InlineYesLeft
          ;; Set temp2 = playerState[temp1] / 16
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; If temp2 < 5, then PSM_InlineNoLeft
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Left
          jmp PSM_InlineNoLeft
CheckAnimationState10Left:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10LeftLabel
          jmp PSM_InlineNoLeft
CheckAnimationState10LeftLabel:


          lda temp2
          cmp # 10
          bcc PSM_InlineDoneLeftSkip
          jmp PSM_InlineDoneLeft
PSM_InlineDoneLeftSkip:
          jmp PSM_InlineDoneLeft

.pend

PSM_InlineDoneLeft:

PSM_InlineYesLeft .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneLeft

.pend

PSM_InlineNoLeft .proc
          lda # 0
          sta temp3

PSM_InlineDoneLeftCheck
          lda temp3
          bne PSM_InlineDoneLeftApply
          jmp PSM_InlineDoneLeftApply
PSM_InlineDoneLeftApply:
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitFacing)
          sta playerState,x


.pend

PSM_CheckRightJoy1 .proc
          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)
          ;; Check if playerCharacter[temp1] = CharacterFrooty
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterFrooty
          beq PSM_RightMomentum1
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp1
          asl
          tax
          lda temp6
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp PSM_AfterRightSet1

.pend

PSM_RightMomentum1 .proc
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
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

.pend

PSM_AfterRightSet1 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
          ;; Check if (playerState[temp1] & 8) then PSM_InlineYesRight1
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq PSM_InlineNoRight1
          jmp PSM_InlineYesRight1
          ;; Set temp2 = playerState[temp1] / 16
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; If temp2 < 5, then PSM_InlineNoRight1
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right1
          jmp PSM_InlineNoRight1
CheckAnimationState10Right1:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right1Label
          jmp PSM_InlineNoRight1
CheckAnimationState10Right1Label:


          lda temp2
          cmp # 10
          bcc PSM_InlineDoneRight1
          jmp PSM_InlineDoneRight1

.pend

PSM_InlineDoneRight1:

PSM_InlineYesRight1 .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneRight1

.pend

PSM_InlineNoRight1 .proc
          lda # 0
          sta temp3

PSM_InlineDoneRight1Check
          lda temp3
          bne PSM_InlineDoneRight1Apply
          jmp PSM_InlineDoneRight1Apply
PSM_InlineDoneRight1Apply:
          ;; Set playerState[temp1] = playerState[temp1] | 1
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 1
          sta playerState,x

          jmp BS_return

.pend

PSM_UseJoy0 .proc
          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)
          ;; Left movement: set negative velocity (joy0)
          lda SWCHA
          and # $80
          beq PSM_ApplyLeftJoy0
          jmp PSM_CheckRightJoy0
          jmp PSM_CheckRightJoy0
PSM_ApplyLeftJoy0:

          ;; Check if playerCharacter[temp1] = CharacterFrooty
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterFrooty
          beq PSM_LeftMomentum0
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda # 0
          sta temp2
          ;; Set temp2 = temp2 - temp6
          lda temp2
          sec
          sbc temp6
          sta temp2
          lda temp2
          sec
          sbc temp6
          sta temp2

          lda temp2
          sec
          sbc temp6
          sta temp2

          lda temp1
          asl
          tax
          lda temp2
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp PSM_AfterLeftSet0

.pend

PSM_LeftMomentum0 .proc
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
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

.pend

PSM_AfterLeftSet0 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
          ;; Check if (playerState[temp1] & 8) then PSM_InlineYesLeft0
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq PSM_InlineNoLeft0
          jmp PSM_InlineYesLeft0
          ;; Set temp2 = playerState[temp1] / 16
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; If temp2 < 5, then PSM_InlineNoLeft0
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Left0
          jmp PSM_InlineNoLeft0
CheckAnimationState10Left0:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10Left0Label
          jmp PSM_InlineNoLeft0
CheckAnimationState10Left0Label:


          lda temp2
          cmp # 10
          bcc PSM_InlineDoneLeft0
          jmp PSM_InlineDoneLeft0

.pend

PSM_InlineDoneLeft0:

PSM_InlineYesLeft0 .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneLeft0

.pend

PSM_InlineNoLeft0 .proc
          lda # 0
          sta temp3

PSM_InlineDoneLeft0Check
          lda temp3
          bne PSM_InlineDoneLeft0Apply
          jmp PSM_InlineDoneLeft0Apply
PSM_InlineDoneLeft0Apply:
          ;; Set playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          lda temp1
          asl
          tax
          lda playerState,x
          and # (255 - PlayerStateBitFacing)
          sta playerState,x


.pend

PSM_CheckRightJoy0 .proc
          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)
          ;; Check if playerCharacter[temp1] = CharacterFrooty
          lda temp1
          asl
          tax
          lda playerCharacter,x
          cmp # CharacterFrooty
          beq PSM_RightMomentum0
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp1
          asl
          tax
          lda temp6
          sta playerVelocityX,x
          lda temp1
          asl
          tax
          lda # 0
          sta playerVelocityXL,x
          jmp PSM_AfterRightSet0

.pend

PSM_RightMomentum0 .proc
          ;; Set temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; Set temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp6
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

.pend

PSM_AfterRightSet0 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
          ;; Check if (playerState[temp1] & 8) then PSM_InlineYesRight0
          lda temp1
          asl
          tax
          lda playerState,x
          and # 8
          beq PSM_InlineNoRight0
          jmp PSM_InlineYesRight0
          ;; Set temp2 = playerState[temp1] / 16
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; If temp2 < 5, then PSM_InlineNoRight0
          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right0
          jmp PSM_InlineNoRight0
CheckAnimationState10Right0:

          lda temp2
          cmp # 5
          bcs CheckAnimationState10Right0Label
          jmp PSM_InlineNoRight0
CheckAnimationState10Right0Label:


          lda temp2
          cmp # 10
          bcc PSM_InlineDoneRight0
          jmp PSM_InlineDoneRight0

.pend

PSM_InlineDoneRight0:

PSM_InlineYesRight0 .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneRight0

.pend

PSM_InlineNoRight0 .proc
          lda # 0
          sta temp3

PSM_InlineDoneRight0Check
          lda temp3
          bne PSM_InlineDoneRight0Apply
          jmp PSM_InlineDoneRight0Apply
PSM_InlineDoneRight0Apply:
          ;; Set playerState[temp1] = playerState[temp1] | 1
          lda temp1
          asl
          tax
          lda playerState,x
          ora # 1
          sta playerState,x

          jmp BS_return

.pend

