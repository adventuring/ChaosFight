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
          ;; if temp1 & 2 = 0 then goto PSM_UseJoy0
          ;; Left movement: set negative velocity
          lda joy1left
          bne PSM_ApplyLeftJoy1
          jmp PSM_CheckRightJoy1
PSM_ApplyLeftJoy1:

                    if playerCharacter[temp1] = CharacterFrooty then PSM_LeftMomentum1
                    ;; let temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda # 0
          sta temp2
          ;; let temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
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
          lda 0
          sta playerVelocityXL,x
          jmp PSM_AfterLeftSet1

.pend

PSM_LeftMomentum1 .proc
          ;; let temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
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
                    let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

.pend

PSM_AfterLeftSet1 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    if (playerState[temp1] & 8) then PSM_InlineYesLeft
          ;; let temp2 = playerState[temp1] / 16         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; if temp2 < 5 then PSM_InlineNoLeft
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
          bcc PSM_InlineDoneLeft
PSM_InlineDoneLeft:


.pend

PSM_InlineYesLeft .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneLeft

.pend

PSM_InlineNoLeft .proc
          lda # 0
          sta temp3

PSM_InlineDoneLeft
          lda temp3
          bne PSM_InlineDoneLeft
                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
PSM_InlineDoneLeft:


.pend

PSM_CheckRightJoy1 .proc
          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)
          jsr BS_return
                    if playerCharacter[temp1] = CharacterFrooty then PSM_RightMomentum1
                    ;; let temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
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
          lda 0
          sta playerVelocityXL,x
          jmp PSM_AfterRightSet1

.pend

PSM_RightMomentum1 .proc
          ;; let temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
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
                    let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

.pend

PSM_AfterRightSet1 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    if (playerState[temp1] & 8) then PSM_InlineYesRight1
          ;; let temp2 = playerState[temp1] / 16         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; if temp2 < 5 then PSM_InlineNoRight1
          lda temp2
          cmp # 5
          bcs skip_7591
          jmp PSM_InlineNoRight1
skip_7591:

          lda temp2
          cmp # 5
          bcs skip_8982
          jmp PSM_InlineNoRight1
skip_8982:


          lda temp2
          cmp # 10
          bcc skip_6455
skip_6455:


.pend

PSM_InlineYesRight1 .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneRight1

.pend

PSM_InlineNoRight1 .proc
          lda # 0
          sta temp3

PSM_InlineDoneRight1
          lda temp3
          bne skip_7724
                    let playerState[temp1] = playerState[temp1] | 1
skip_7724:

          jsr BS_return

.pend

PSM_UseJoy0 .proc
          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)
          ;; Left movement: set negative velocity
          lda joy0left
          bne skip_4909
          jmp PSM_CheckRightJoy0
skip_4909:

                    if playerCharacter[temp1] = CharacterFrooty then PSM_LeftMomentum0
                    ;; let temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
          lda temp6
          asl
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda # 0
          sta temp2
          ;; let temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
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
          lda 0
          sta playerVelocityXL,x
          jmp PSM_AfterLeftSet0

.pend

PSM_LeftMomentum0 .proc
          ;; let temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
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
                    let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

.pend

PSM_AfterLeftSet0 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    if (playerState[temp1] & 8) then PSM_InlineYesLeft0
          ;; let temp2 = playerState[temp1] / 16         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; if temp2 < 5 then PSM_InlineNoLeft0
          lda temp2
          cmp # 5
          bcs skip_6394
          jmp PSM_InlineNoLeft0
skip_6394:

          lda temp2
          cmp # 5
          bcs skip_7814
          jmp PSM_InlineNoLeft0
skip_7814:


          lda temp2
          cmp # 10
          bcc skip_7761
skip_7761:


.pend

PSM_InlineYesLeft0 .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneLeft0

.pend

PSM_InlineNoLeft0 .proc
          lda # 0
          sta temp3

PSM_InlineDoneLeft0
          lda temp3
          bne PSM_InlineDoneLeft
                    let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
PSM_InlineDoneLeft:


.pend

PSM_CheckRightJoy0 .proc
          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)
          jsr BS_return
                    if playerCharacter[temp1] = CharacterFrooty then PSM_RightMomentum0
                    ;; let temp6 = playerCharacter[temp1]
                    lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
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
          lda 0
          sta playerVelocityXL,x
          jmp PSM_AfterRightSet0

.pend

PSM_RightMomentum0 .proc
          ;; let temp6 = playerCharacter[temp1]
          lda temp1
          asl
          tax
          lda playerCharacter,x
          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
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
                    let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          lda temp1
          asl
          tax
          lda 0
          sta playerVelocityXL,x

.pend

PSM_AfterRightSet0 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    if (playerState[temp1] & 8) then PSM_InlineYesRight0
          ;; let temp2 = playerState[temp1] / 16         
          lda temp1
          asl
          tax
          lda playerState,x
          sta temp2
          ;; if temp2 < 5 then PSM_InlineNoRight0
          lda temp2
          cmp # 5
          bcs skip_9727
          jmp PSM_InlineNoRight0
skip_9727:

          lda temp2
          cmp # 5
          bcs skip_3799
          jmp PSM_InlineNoRight0
skip_3799:


          lda temp2
          cmp # 10
          bcc skip_9364
skip_9364:


.pend

PSM_InlineYesRight0 .proc
          lda # 1
          sta temp3
          jmp PSM_InlineDoneRight0

.pend

PSM_InlineNoRight0 .proc
          lda # 0
          sta temp3

PSM_InlineDoneRight0
          lda temp3
          bne skip_7724
                    let playerState[temp1] = playerState[temp1] | 1
skip_7724:

          jsr BS_return

.pend

