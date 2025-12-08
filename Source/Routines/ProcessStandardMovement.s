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
          bne skip_4227
          jmp PSM_CheckRightJoy1
skip_4227:

                    ;; if playerCharacter[temp1] = CharacterFrooty then PSM_LeftMomentum1
                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          asl
          tax
          ;; lda CharacterMovementSpeed,x (duplicate)
          sta temp6
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
          ;; lda temp2 (duplicate)
          sec
          sbc temp6
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp PSM_AfterLeftSet1 (duplicate)

.pend

PSM_LeftMomentum1 .proc
          ;; let temp6 = playerCharacter[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
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

.pend

PSM_AfterLeftSet1 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    ;; if (playerState[temp1] & 8) then PSM_InlineYesLeft
                    ;; let temp2 = playerState[temp1] / 16         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; if temp2 < 5 then PSM_InlineNoLeft
          ;; lda temp2 (duplicate)
          cmp # 5
          bcs skip_2509
          ;; jmp PSM_InlineNoLeft (duplicate)
skip_2509:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_7662 (duplicate)
          ;; jmp PSM_InlineNoLeft (duplicate)
skip_7662:


          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          bcc skip_2790
skip_2790:


.pend

PSM_InlineYesLeft .proc
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; jmp PSM_InlineDoneLeft (duplicate)

.pend

PSM_InlineNoLeft .proc
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

PSM_InlineDoneLeft
          ;; lda temp3 (duplicate)
          ;; bne skip_6938 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
skip_6938:


.pend

PSM_CheckRightJoy1 .proc
          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)
          jsr BS_return
                    ;; if playerCharacter[temp1] = CharacterFrooty then PSM_RightMomentum1
                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp PSM_AfterRightSet1 (duplicate)

.pend

PSM_RightMomentum1 .proc
          ;; let temp6 = playerCharacter[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
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

.pend

PSM_AfterRightSet1 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    ;; if (playerState[temp1] & 8) then PSM_InlineYesRight1
                    ;; let temp2 = playerState[temp1] / 16         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; if temp2 < 5 then PSM_InlineNoRight1
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_7591 (duplicate)
          ;; jmp PSM_InlineNoRight1 (duplicate)
skip_7591:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_8982 (duplicate)
          ;; jmp PSM_InlineNoRight1 (duplicate)
skip_8982:


          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_6455 (duplicate)
skip_6455:


.pend

PSM_InlineYesRight1 .proc
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; jmp PSM_InlineDoneRight1 (duplicate)

.pend

PSM_InlineNoRight1 .proc
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

PSM_InlineDoneRight1
          ;; lda temp3 (duplicate)
          ;; bne skip_7724 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] | 1
skip_7724:

          ;; jsr BS_return (duplicate)

.pend

PSM_UseJoy0 .proc
          ;; Players 0,2 use joy0
          ;; Returns: Far (return otherbank)
          ;; Left movement: set negative velocity
          ;; lda joy0left (duplicate)
          ;; bne skip_4909 (duplicate)
          ;; jmp PSM_CheckRightJoy0 (duplicate)
skip_4909:

                    ;; if playerCharacter[temp1] = CharacterFrooty then PSM_LeftMomentum0
                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda # 0 (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; let temp2 = temp2 - temp6          lda temp2          sec          sbc temp6          sta temp2
          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp2 (duplicate)
          ;; sec (duplicate)
          ;; sbc temp6 (duplicate)
          ;; sta temp2 (duplicate)

          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp2 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp PSM_AfterLeftSet0 (duplicate)

.pend

PSM_LeftMomentum0 .proc
          ;; let temp6 = playerCharacter[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
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

.pend

PSM_AfterLeftSet0 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    ;; if (playerState[temp1] & 8) then PSM_InlineYesLeft0
                    ;; let temp2 = playerState[temp1] / 16         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; if temp2 < 5 then PSM_InlineNoLeft0
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_6394 (duplicate)
          ;; jmp PSM_InlineNoLeft0 (duplicate)
skip_6394:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_7814 (duplicate)
          ;; jmp PSM_InlineNoLeft0 (duplicate)
skip_7814:


          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_7761 (duplicate)
skip_7761:


.pend

PSM_InlineYesLeft0 .proc
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; jmp PSM_InlineDoneLeft0 (duplicate)

.pend

PSM_InlineNoLeft0 .proc
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

PSM_InlineDoneLeft0
          ;; lda temp3 (duplicate)
          ;; bne skip_6938 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
;; skip_6938: (duplicate)


.pend

PSM_CheckRightJoy0 .proc
          ;; Right movement: set positive velocity
          ;; Returns: Far (return otherbank)
          ;; jsr BS_return (duplicate)
                    ;; if playerCharacter[temp1] = CharacterFrooty then PSM_RightMomentum0
                    ;; let temp6 = playerCharacter[temp1]          lda temp1          asl          tax          lda playerCharacter,x          sta temp6
          ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda temp6 (duplicate)
          ;; sta playerVelocityX,x (duplicate)
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda 0 (duplicate)
          ;; sta playerVelocityXL,x (duplicate)
          ;; jmp PSM_AfterRightSet0 (duplicate)

.pend

PSM_RightMomentum0 .proc
          ;; let temp6 = playerCharacter[temp1]
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerCharacter,x (duplicate)
          ;; sta temp6 (duplicate)
                    ;; let temp6 = CharacterMovementSpeed[temp6]
          ;; lda temp6 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda CharacterMovementSpeed,x (duplicate)
          ;; sta temp6 (duplicate)
          ;; lda temp6 (duplicate)
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

.pend

PSM_AfterRightSet0 .proc
          ;; Inline ShouldPreserveFacing logic
          ;; Returns: Far (return otherbank)
                    ;; if (playerState[temp1] & 8) then PSM_InlineYesRight0
                    ;; let temp2 = playerState[temp1] / 16         
          ;; lda temp1 (duplicate)
          ;; asl (duplicate)
          ;; tax (duplicate)
          ;; lda playerState,x (duplicate)
          ;; sta temp2 (duplicate)
          ;; ;; if temp2 < 5 then PSM_InlineNoRight0
          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_9727 (duplicate)
          ;; jmp PSM_InlineNoRight0 (duplicate)
skip_9727:

          ;; lda temp2 (duplicate)
          ;; cmp # 5 (duplicate)
          ;; bcs skip_3799 (duplicate)
          ;; jmp PSM_InlineNoRight0 (duplicate)
skip_3799:


          ;; lda temp2 (duplicate)
          ;; cmp # 10 (duplicate)
          ;; bcc skip_9364 (duplicate)
skip_9364:


.pend

PSM_InlineYesRight0 .proc
          ;; lda # 1 (duplicate)
          ;; sta temp3 (duplicate)
          ;; jmp PSM_InlineDoneRight0 (duplicate)

.pend

PSM_InlineNoRight0 .proc
          ;; lda # 0 (duplicate)
          ;; sta temp3 (duplicate)

PSM_InlineDoneRight0
          ;; lda temp3 (duplicate)
          ;; bne skip_7724 (duplicate)
                    ;; let playerState[temp1] = playerState[temp1] | 1
;; skip_7724: (duplicate)

          ;; jsr BS_return (duplicate)

.pend

