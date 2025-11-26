          rem ChaosFight - Source/Routines/FlyingMovementHelpers.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

HFCM_AttemptMoveLeft
          asm
HFCM_AttemptMoveLeft
end
          let temp1 = currentPlayer
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then let temp2 = 31
          if temp2 & $80 then let temp2 = 0
          if temp2 <= 0 then return otherbank
          let temp3 = temp2 - 1
          let temp4 = playerY[temp1]
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp7 = temp2
          let temp1 = temp3
          let temp2 = temp7
          gosub PlayfieldRead bank16
          if temp1 then return otherbank
          let temp2 = temp4 + 16
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp7 = temp2
          if temp7 >= pfrows then goto HFCM_ApplyLeft
          let temp1 = temp3
          let temp2 = temp7
          gosub PlayfieldRead bank16
          if temp1 then return otherbank
HFCM_ApplyLeft
          let temp1 = currentPlayer
          let temp5 = playerCharacter[temp1]
          if temp5 = 8 then goto HFCM_LeftMomentum
          if temp5 = 2 then goto HFCM_LeftDirect
          let playerVelocityX[temp1] = $ff
          let playerVelocityXL[temp1] = 0
          goto HFCM_LeftFacing
HFCM_LeftMomentum
          let characterMovementSpeed = CharacterMovementSpeed[temp5]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - characterMovementSpeed
          let playerVelocityXL[temp1] = 0
          goto HFCM_LeftFacing
HFCM_LeftDirect
          let characterMovementSpeed = CharacterMovementSpeed[temp5]
          let temp2 = playerX[temp1]
          let playerX[temp1] = temp2 - characterMovementSpeed
HFCM_LeftFacing
          if (playerState[temp1] & 8) then return
          gosub GetPlayerAnimationStateFunction bank13
          if temp2 < 5 then HFCM_SetFacingLeft
          if temp2 > 9 then HFCM_SetFacingLeft
          return otherbank
HFCM_SetFacingLeft
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          return otherbank
HFCM_AttemptMoveRight
          asm
HFCM_AttemptMoveRight
end
          let temp1 = currentPlayer
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then let temp2 = 31
          if temp2 & $80 then let temp2 = 0
          if temp2 >= 31 then return otherbank
          let temp3 = temp2 + 1
          let temp4 = playerY[temp1]
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp7 = temp2
          let temp1 = temp3
          let temp2 = temp7
          gosub PlayfieldRead bank16
          if temp1 then return otherbank
          let temp2 = temp4 + 16
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp7 = temp2
          if temp7 >= pfrows then goto HFCM_ApplyRight
          let temp1 = temp3
          let temp2 = temp7
          gosub PlayfieldRead bank16
          if temp1 then return otherbank
HFCM_ApplyRight
          let temp1 = currentPlayer
          let temp5 = playerCharacter[temp1]
          if temp5 = 8 then goto HFCM_RightMomentum
          if temp5 = 2 then goto HFCM_RightDirect
          let playerVelocityX[temp1] = 1
          let playerVelocityXL[temp1] = 0
          goto HFCM_RightFacing
HFCM_RightMomentum
          let characterMovementSpeed = CharacterMovementSpeed[temp5]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + characterMovementSpeed
          let playerVelocityXL[temp1] = 0
          goto HFCM_RightFacing
HFCM_RightDirect
          let characterMovementSpeed = CharacterMovementSpeed[temp5]
          let temp2 = playerX[temp1]
          let playerX[temp1] = temp2 + characterMovementSpeed
HFCM_RightFacing
          if (playerState[temp1] & 8) then return
          gosub GetPlayerAnimationStateFunction bank13
          if temp2 < 5 then HFCM_SetFacingRight
          if temp2 > 9 then HFCM_SetFacingRight
          return otherbank
HFCM_SetFacingRight
          let playerState[temp1] = playerState[temp1] | 1
          return otherbank

