          rem ChaosFight - Source/Routines/RadishGoblinMovement.bas

          rem Copyright © 2025 Bruce-Robert Pocock.



          rem Radish Goblin Bounce Movement System (Optimized)

          rem Complete replacement of standard movement for Radish Goblin character



RadishGoblinHandleInput
          rem Returns: Far (return otherbank)

          asm

RadishGoblinHandleInput

end

          rem Handle joystick input for Radish Goblin bounce movement
          rem Returns: Far (return otherbank)

          rem Input: temp1 = player index (0-3)

          rem Output: Horizontal momentum added based on stick direction (only when on ground)

          rem Determine joy port (temp1 & 2 = 0 for players 0,2 use joy0)

          if (playerState[temp1] & PlayerStateBitJumping) then return otherbank

          if temp1 & 2 = 0 then goto RGHI_Joy0

          if !joy1left then goto RGHI_CheckRight

          goto RGHI_Left

RGHI_Joy0

          if !joy0left then goto RGHI_CheckRight

RGHI_Left

          let temp4 = playerCharacter[temp1]

          let temp6 = CharacterMovementSpeed[temp4]

          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6

          let playerVelocityXL[temp1] = 0

          if (playerState[temp1] & 8) then goto RGHI_AfterLeft

          gosub GetPlayerAnimationStateFunction bank13

          if temp2 < 5 then goto RGHI_SPF_No1

          if temp2 > 9 then goto RGHI_SPF_No1

          goto RGHI_AfterLeft

RGHI_SPF_No1

          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)

RGHI_AfterLeft

RGHI_CheckRight

          if temp1 & 2 = 0 then goto RGHI_CheckRightJoy0

          if !joy1right then return thisbank

          goto RGHI_Right

RGHI_CheckRightJoy0

          if !joy0right then return thisbank

RGHI_Right

          let temp4 = playerCharacter[temp1]

          let temp6 = CharacterMovementSpeed[temp4]

          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6

          let playerVelocityXL[temp1] = 0

          if (playerState[temp1] & 8) then return thisbank

          gosub GetPlayerAnimationStateFunction bank13

          if temp2 < 5 then goto RGHI_SPF_No2

          if temp2 > 9 then goto RGHI_SPF_No2

          return thisbank

RGHI_SPF_No2

          let playerState[temp1] = playerState[temp1] | 1

          return thisbank



RadishGoblinHandleStickDown
          rem Returns: Far (return otherbank)

          asm

RadishGoblinHandleStickDown

end

          rem Drop all momentum for Radish Goblin
          rem Returns: Far (return otherbank)

          rem Input: temp1 = player index (0-3)

          let playerVelocityX[temp1] = 0

          let playerVelocityXL[temp1] = 0

          let playerVelocityY[temp1] = 0

          let playerVelocityYL[temp1] = 0

          return otherbank



RadishGoblinCheckGroundBounce
          rem Returns: Far (return otherbank)

          asm

RadishGoblinCheckGroundBounce

end

          rem Check for ground contact and apply bounce for Radish Goblin
          rem Returns: Far (return otherbank)

          rem Input: currentPlayer = player index (0-3) (global)

          let temp1 = currentPlayer

          if playerCharacter[temp1] <> CharacterRadishGoblin then return otherbank

          rem Convert X to playfield column

          if playerVelocityY[temp1] <= 0 then goto RGBGB_ClearCheck

          let temp2 = playerX[temp1] - ScreenInsetX

          if temp2 & $80 then temp2 = 0

          asm

            lsr temp2

            lsr temp2

end

          if temp2 > 31 then temp2 = 31

          rem Calculate feet row

          let temp6 = temp2

          let temp2 = playerY[temp1] + PlayerSpriteHeight

          asm

            lsr temp2

            lsr temp2

            lsr temp2

            lsr temp2

end

          if temp2 >= pfrows then goto RGBGB_ClearCheck

          let temp5 = temp2 + 1

          rem Check ground pixel

          if temp5 >= pfrows then goto RGBGB_ClearCheck

          let temp4 = temp1

          let temp1 = temp6

          gosub PlayfieldRead bank16

          let temp1 = temp4

          rem Ground detected - check bounce state

          if !temp1 then goto RGBGB_ClearCheck

          rem Check if moved away from contact

          if radishGoblinBounceState_R[temp1] = 1 then goto RGBGB_ClearCheck

          let temp2 = playerY[temp1]

          let temp3 = radishGoblinLastContactY_R[temp1]

          if temp2 < temp3 then goto RGBGB_ClearState

          let temp4 = temp2 - temp3

          if temp4 > 8 then goto RGBGB_ClearState

          goto RGBGB_CalcBounce

RGBGB_ClearState

          let radishGoblinBounceState_W[temp1] = 0

RGBGB_CalcBounce

          rem Calculate bounce height
          rem Returns: Far (return otherbank)

          let temp2 = RadishGoblinBounceNormal

          rem Check jump button (enhanced button or stick up)

          if playerVelocityY[temp1] >= TerminalVelocity then let temp2 = RadishGoblinBounceHighSpeed

          let temp3 = 0

          if temp1 >= 2 then goto RGBGB_CheckStick

          if temp1 = 0 then goto RGBGB_CheckEnhanced0

          if (enhancedButtonStates_R & 2) then let temp3 = 1

          goto RGBGB_CheckStick

RGBGB_CheckEnhanced0

          if (enhancedButtonStates_R & 1) then let temp3 = 1

RGBGB_CheckStick

          if temp1 & 2 = 0 then RGBGB_StickJoy0

          if joy1up then let temp3 = 1

          goto RGBGB_Apply

RGBGB_StickJoy0

          if joy0up then let temp3 = 1

RGBGB_Apply

          if !temp3 then RGBGB_DoneApply

          asm

            asl temp2

end

RGBGB_DoneApply

          let playerVelocityY[temp1] = 0 - temp2

          let playerVelocityYL[temp1] = 0

          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping

          let radishGoblinBounceState_W[temp1] = 1

          let radishGoblinLastContactY_W[temp1] = playerY[temp1]

          return thisbank

RGBGB_ClearCheck

          if radishGoblinBounceState_R[temp1] = 0 then return thisbank

          let temp2 = playerY[temp1]

          let temp3 = radishGoblinLastContactY_R[temp1]

          if temp2 < temp3 then goto RGBGB_ClearState2

          let temp4 = temp2 - temp3

          if temp4 > 8 then goto RGBGB_ClearState2

          return thisbank

RGBGB_ClearState2

          let radishGoblinBounceState_W[temp1] = 0

          return thisbank



RadishGoblinCheckWallBounce
          rem Returns: Far (return otherbank)

          asm

RadishGoblinCheckWallBounce

end

          rem Check for wall bounce collision (horizontal only)
          rem Returns: Far (return otherbank)

          rem Input: currentPlayer = player index (0-3) (global)

          if playerCharacter[currentPlayer] <> CharacterRadishGoblin then return otherbank

          return otherbank



RadishGoblinHandleStickDownRelease
          rem Returns: Far (return otherbank)

          asm

RadishGoblinHandleStickDownRelease

end

          rem Handle stick down release for Radish Goblin (short bounce if on ground)
          rem Returns: Far (return otherbank)

          rem Input: temp1 = player index (0-3)

          if (playerState[temp1] & PlayerStateBitJumping) then return otherbank

          let playerVelocityY[temp1] = 0 - RadishGoblinBounceShort

          let playerVelocityYL[temp1] = 0

          let playerState[temp1] = playerState[temp1] | PlayerStateBitJumping

          let radishGoblinBounceState_W[temp1] = 0

          return otherbank
