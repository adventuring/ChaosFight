          rem ChaosFight - Source/Routines/HandleFlyingCharacterMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

HandleFlyingCharacterMovement
          asm
HandleFlyingCharacterMovement

end
          rem
          rem Shared Flying Character Movement
          rem Handles horizontal movement with collision for flying
          rem   characters (Frooty, Dragon of Storms)
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0left/joy0right for players 0,2;
          rem joy1left/joy1right
          rem for players 1,3
          let temp5 = playerCharacter[temp1]
          let currentPlayer = temp1
          rem Save player index to global variable
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          let temp6 = temp1 & 2
          rem temp6 = 0 for players 0,2 (joy0), 2 for players 1,3 (joy1)
          rem Check left movement
          if temp6 = 0 then HFCM_CheckLeftJoy0
          if !joy1left then goto HFCM_CheckRight
          goto HFCM_DoLeft
HFCM_CheckLeftJoy0
          if !joy0left then goto HFCM_CheckRight
HFCM_DoLeft
          rem Convert X to playfield column
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          if temp2 <= 0 then goto HFCM_CheckRight
          rem Check collision to the left
          let temp3 = temp2 - 1
          let temp4 = playerY[temp1]
          rem Convert Y to playfield row (top)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp7 = temp2
          rem Check top row collision
          let temp1 = temp3
          let temp2 = temp7
          gosub PlayfieldRead bank16
          if temp1 then goto HFCM_CheckRight
          rem Check bottom row collision
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
          if temp1 then goto HFCM_CheckRight
HFCM_ApplyLeft
          rem Apply left movement based on character type
          let temp1 = currentPlayer
          let temp5 = playerCharacter[temp1]
          if temp5 = 8 then goto HFCM_LeftMomentum
          if temp5 = 2 then goto HFCM_LeftDirect
          rem Default: apply -1
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
          rem Update facing (clear bit for left)
          if (playerState[temp1] & 8) then goto HFCM_CheckRight
          gosub GetPlayerAnimationStateFunction bank13
          if temp2 < 5 then HFCM_SetFacingLeft
          if temp2 > 9 then HFCM_SetFacingLeft
          goto HFCM_CheckRight
HFCM_SetFacingLeft
          let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
HFCM_CheckRight
          rem Check right movement
          if temp6 = 0 then HFCM_CheckRightJoy0
          if !joy1right then goto HFCM_CheckVertical
          goto HFCM_DoRight
HFCM_CheckRightJoy0
          if !joy0right then goto HFCM_CheckVertical
HFCM_DoRight
          rem Convert X to playfield column
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          if temp2 >= 31 then goto HFCM_CheckVertical
          rem Check collision to the right
          let temp3 = temp2 + 1
          let temp4 = playerY[temp1]
          rem Convert Y to playfield row (top)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp7 = temp2
          rem Check top row collision
          let temp1 = temp3
          let temp2 = temp7
          gosub PlayfieldRead bank16
          if temp1 then goto HFCM_CheckVertical
          rem Check bottom row collision
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
          if temp1 then goto HFCM_CheckVertical
HFCM_ApplyRight
          rem Apply right movement based on character type
          let temp1 = currentPlayer
          let temp5 = playerCharacter[temp1]
          if temp5 = 8 then goto HFCM_RightMomentum
          if temp5 = 2 then goto HFCM_RightDirect
          rem Default: apply +1
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
          rem Update facing (set bit for right)
          if (playerState[temp1] & 8) then goto HFCM_CheckVertical
          gosub GetPlayerAnimationStateFunction bank13
          if temp2 < 5 then HFCM_SetFacingRight
          if temp2 > 9 then HFCM_SetFacingRight
          goto HFCM_CheckVertical
HFCM_SetFacingRight
          let playerState[temp1] = playerState[temp1] | 1
HFCM_CheckVertical
          rem Vertical control for flying characters: UP/DOWN
          let temp1 = currentPlayer
          let temp5 = playerCharacter[temp1]
          let characterMovementSpeed = CharacterMovementSpeed[temp5]
          if temp6 = 0 then HFCM_VertJoy0
          if joy1up then goto HFCM_VertUp
          if joy1down then goto HFCM_VertDown
          return otherbank
HFCM_VertJoy0
          if joy0up then goto HFCM_VertUp
          if joy0down then goto HFCM_VertDown
          return otherbank
HFCM_VertUp
          if temp5 = 8 then let playerVelocityY[temp1] = playerVelocityY[temp1] - characterMovementSpeed : return otherbank
          if temp5 = 2 then let playerY[temp1] = playerY[temp1] - characterMovementSpeed : return otherbank
          return otherbank
HFCM_VertDown
          if temp5 = 8 then let playerVelocityY[temp1] = playerVelocityY[temp1] + characterMovementSpeed : return otherbank
          if temp5 = 2 then let playerY[temp1] = playerY[temp1] + characterMovementSpeed : return otherbank
          return otherbank

