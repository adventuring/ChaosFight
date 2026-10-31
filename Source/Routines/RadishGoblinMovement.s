;;; ChaosFight - Source/Routines/RadishGoblinMovement.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Radish Goblin Bounce Movement System (Optimized)
;;; Complete replacement of standard movement for Radish Goblin character

          pfrows = 8

RadishGoblinHandleInput .block
          ;; Handle joystick input for Radish Goblin bounce movement
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index (0-3)
          ;; Output: Horizontal momentum added based on stick direction (only when on ground)

          ;; Determine if jumping
          lda temp1
          tax
          lda playerState,x
          and # PlayerStateBitJumping
          beq NotJumpingRGHI
          jmp BS_return
NotJumpingRGHI:

          lda temp1
          and # 2
          beq RGHI_Joy0
          ;; Player uses joy1
          lda joy1left_R
          beq RGHI_CheckRight
          jmp RGHI_MoveLeft
RGHI_Joy0:
          lda joy0left_R
          beq RGHI_CheckRight
          jmp RGHI_MoveLeft
.bend

RGHI_MoveLeft .block
          ;; Move left: playerVelocityX[temp1] -= CharacterMovementSpeed[temp4]
          lda temp1
          tax
          lda playerCharacter,x
          sta temp4
          lda temp4
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp1
          tax
          lda playerVelocityX,x
          sec
          sbc temp6
          sta playerVelocityX,x
          lda temp1
          tax
          lda # 0
          sta playerVelocityXL,x
          ;; If facing (bit 3 set?) check animation - original checks (playerState & 8)
          lda temp1
          tax
          lda playerState,x
          and # 8
          beq RGHI_LeftFaceCheckDone
          ;; Cross-bank call to GetPlayerAnimationStateFunction in bank 13
          lda # ((>(RGHI_AfterGetAnimLeft-1)) & $0f) | $b0
          pha
          lda # <(RGHI_AfterGetAnimLeft-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ldx # 13
          jmp BS_jsr
RGHI_AfterGetAnimLeft:
          lda temp2
          cmp # 5
          bcc RGHI_SetFacingLeft
          cmp # 10
          bcs RGHI_LeftFaceCheckDone
RGHI_SetFacingLeft:
          lda temp1
          tax
          lda playerState,x
          and # (255 - PlayerStateBitFacing)
          sta playerState,x
RGHI_LeftFaceCheckDone:
          jmp RGHI_AfterLeft
.bend

RGHI_CheckRight .block
          lda temp1
          and # 2
          beq RGHI_CheckRightJoy0
          lda joy1right_R
          beq RGHI_NoRight
          jmp RGHI_MoveRight
RGHI_CheckRightJoy0:
          lda joy0right_R
          beq RGHI_NoRight
          jmp RGHI_MoveRight
RGHI_NoRight:
          jmp BS_return
.bend

RGHI_MoveRight .block
          lda temp1
          tax
          lda playerCharacter,x
          sta temp4
          lda temp4
          tax
          lda CharacterMovementSpeed,x
          sta temp6
          lda temp1
          tax
          lda playerVelocityX,x
          clc
          adc temp6
          sta playerVelocityX,x
          lda temp1
          tax
          lda # 0
          sta playerVelocityXL,x
          lda temp1
          tax
          lda playerState,x
          and # 8
          beq RGHI_RightFaceCheckDone
          lda # ((>(RGHI_AfterGetAnimRight-1)) & $0f) | $b0
          pha
          lda # <(RGHI_AfterGetAnimRight-1)
          pha
          lda # >(GetPlayerAnimationStateFunction-1)
          pha
          lda # <(GetPlayerAnimationStateFunction-1)
          pha
          ldx # 13
          jmp BS_jsr
RGHI_AfterGetAnimRight:
          lda temp2
          cmp # 5
          bcc RGHI_SetFacingRight
          cmp # 10
          bcs RGHI_RightFaceCheckDone
RGHI_SetFacingRight:
          lda temp1
          tax
          lda playerState,x
          ora # PlayerStateBitFacing
          sta playerState,x
RGHI_RightFaceCheckDone:
          jmp BS_return
.bend

RGHI_AfterLeft:
          jmp BS_return

RadishGoblinHandleStickDown .block
          ;; Drop all momentum for Radish Goblin
          ;; Returns: Far (return otherbank)
          ;; Input: temp1 = player index (0-3)
          lda temp1
          tax
          lda # 0
          sta playerVelocityX,x
          lda temp1
          tax
          lda # 0
          sta playerVelocityXL,x
          lda temp1
          tax
          lda # 0
          sta playerVelocityY,x
          lda temp1
          tax
          lda # 0
          sta playerVelocityYL,x
          jmp BS_return
.bend

RadishGoblinCheckWallBounce .block
          ;; Radish Goblin currently has no horizontal bounce response;
          ;; keep the far-call entry point so the movement chain has a
          ;; consistent shape.
          jmp BS_return
.bend

RadishGoblinCheckGroundBounce .block
          ;; Detect ground contact from Y velocity + playfield pixel and
          ;; turn it into a bounce.
          ;; Input: currentPlayer = player index (global)
          ;; Returns: Far (return otherbank)
          lda currentPlayer
          sta temp1
          lda temp1
          tax
          lda playerCharacter,x
          cmp # CharacterRadishGoblin
          beq RGBGB_CharacterOk
          jmp BS_return
RGBGB_CharacterOk:

          ;; Only look for a landing while falling (Y velocity > 0).
          lda # 0
          ldx temp1
          cmp playerVelocityY,x
          bcc RGBGB_CheckGround
          jmp RGBGB_ClearCheck
RGBGB_CheckGround:

          ;; Convert X to a playfield column.
          ldx temp1
          lda playerX,x
          sec
          sbc # ScreenInsetX
          sta temp2
          lda temp2
          and # $80
          beq RGBGB_ColumnNoWrap
          lda # 0
          sta temp2
RGBGB_ColumnNoWrap:
          lsr temp2
          lsr temp2
          lda # 31
          cmp temp2
          bcs RGBGB_ColumnInRange
          lda # 31
          sta temp2
RGBGB_ColumnInRange:
          lda temp2
          sta temp6

          ;; Convert the feet Y to a playfield row.
          ldx temp1
          lda playerY,x
          clc
          adc # PlayerSpriteHeight
          sta temp2
          lsr temp2
          lsr temp2
          lsr temp2
          lsr temp2
          lda temp2
          cmp # pfrows
          bcc RGBGB_RowInRange
          jmp RGBGB_ClearCheck
RGBGB_RowInRange:
          lda temp2
          clc
          adc # 1
          sta temp5
          lda temp5
          cmp # pfrows
          bcc RGBGB_FeetRowInRange
          jmp RGBGB_ClearCheck
RGBGB_FeetRowInRange:

          ;; Read the ground pixel at (temp6, temp2).
          lda temp1
          sta temp4
          lda temp6
          sta temp1
          ;; Far call to PlayfieldRead in bank 15
          lda # ((>(RGBGB_AfterRead-1)) & $0f) | $b0
          pha
          lda # <(RGBGB_AfterRead-1)
          pha
          lda # >(PlayfieldRead-1)
          pha
          lda # <(PlayfieldRead-1)
          pha
          ldx # 15
          jmp BS_jsr
RGBGB_AfterRead:
          ;; temp1 = result (0 = clear, $80 = set)
          lda temp1
          bne RGBGB_GroundFound
          lda temp4
          sta temp1
          jmp RGBGB_ClearCheck
RGBGB_GroundFound:
          lda temp4
          sta temp1

          ;; Do not start a new bounce while one is in progress.
          ldx temp1
          lda radishGoblinBounceState_R,x
          cmp # 1
          bne RGBGB_ContactCheck
          jmp RGBGB_ClearCheck
RGBGB_ContactCheck:

          ;; Avoid re-bouncing if we have not moved away from the last
          ;; contact point by more than 8 pixels vertically.
          ldx temp1
          lda playerY,x
          sta temp2
          ldx temp1
          lda radishGoblinLastContactY_R,x
          sta temp3
          lda temp2
          cmp temp3
          bcs RGBGB_ContactMoved
          jmp RGBGB_ClearState
RGBGB_ContactMoved:
          lda temp2
          sec
          sbc temp3
          sta temp4
          lda # 8
          cmp temp4
          bcs RGBGB_CalcBounce
          jmp RGBGB_ClearState

RGBGB_ClearState:
          lda # 0
          ldx temp1
          sta radishGoblinBounceState_W,x
          jmp RGBGB_CalcBounce

RGBGB_CalcBounce:
          ;; Base bounce height; higher when landing at terminal speed.
          lda # RadishGoblinBounceNormal
          sta temp2
          ldx temp1
          lda playerVelocityY,x
          cmp # TerminalVelocity
          bcc RGBGB_BounceSizeSet
          lda # RadishGoblinBounceHighSpeed
          sta temp2
RGBGB_BounceSizeSet:

          ;; Check the jump button (enhanced button or stick up).
          lda # 0
          sta temp3
          lda temp1
          cmp # 2
          bcs RGBGB_CheckStick
          lda temp1
          cmp # 0
          bne RGBGB_CheckEnhanced1
          lda enhancedButtonStates_R
          and # 1
          beq RGBGB_CheckStick
          lda # 1
          sta temp3
          jmp RGBGB_CheckStick
RGBGB_CheckEnhanced1:
          lda enhancedButtonStates_R
          and # 2
          beq RGBGB_CheckStick
          lda # 1
          sta temp3
RGBGB_CheckStick:
          lda temp1
          and # 2
          beq RGBGB_StickJoy0
          lda joy1up_R
          beq RGBGB_Apply
          lda # 1
          sta temp3
          jmp RGBGB_Apply
RGBGB_StickJoy0:
          lda joy0up_R
          beq RGBGB_Apply
          lda # 1
          sta temp3
RGBGB_Apply:
          lda temp3
          beq RGBGB_DoneApply
          asl temp2
RGBGB_DoneApply:
          lda # 0
          sec
          sbc temp2
          ldx temp1
          sta playerVelocityY,x
          lda # 0
          ldx temp1
          sta playerVelocityYL,x
          lda temp1
          tax
          lda playerState,x
          ora # PlayerStateBitJumping
          sta playerState,x
          lda # 1
          ldx temp1
          sta radishGoblinBounceState_W,x
          ldx temp1
          lda playerY,x
          ldx temp1
          sta radishGoblinLastContactY_W,x
          jmp BS_return

RGBGB_ClearCheck:
          ldx temp1
          lda radishGoblinBounceState_R,x
          cmp # 0
          bne RGBGB_ClearCheckActive
          jmp BS_return
RGBGB_ClearCheckActive:
          ldx temp1
          lda playerY,x
          sta temp2
          ldx temp1
          lda radishGoblinLastContactY_R,x
          sta temp3
          lda temp2
          cmp temp3
          bcs RGBGB_ClearMoved
          jmp RGBGB_ClearState2
RGBGB_ClearMoved:
          lda temp2
          sec
          sbc temp3
          sta temp4
          lda # 8
          cmp temp4
          bcs RGBGB_GroundBounceDone
          jmp RGBGB_ClearState2
RGBGB_ClearState2:
          lda # 0
          ldx temp1
          sta radishGoblinBounceState_W,x
RGBGB_GroundBounceDone:
          jmp BS_return
.bend

RadishGoblinHandleStickDownRelease .block
          ;; Release "down" on the ground triggers a short bounce.
          ;; Input: temp1 = player index (0-3)
          ldx temp1
          lda playerState,x
          and # PlayerStateBitJumping
          bne RGBHSDR_Done
          lda # 0
          sec
          sbc # RadishGoblinBounceShort
          ldx temp1
          sta playerVelocityY,x
          lda # 0
          ldx temp1
          sta playerVelocityYL,x
          ldx temp1
          lda playerState,x
          ora # PlayerStateBitJumping
          sta playerState,x
          lda # 0
          ldx temp1
          sta radishGoblinBounceState_W,x
RGBHSDR_Done:
          jmp BS_return
.bend
