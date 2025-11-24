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
          gosub HFCM_AttemptMoveLeft bank13
          goto HFCM_CheckRight
HFCM_CheckRight
          rem Check right movement
          if temp6 = 0 then HFCM_CheckRightJoy0
          if !joy1right then goto HFCM_CheckVertical
          goto HFCM_DoRight
HFCM_CheckRightJoy0
          if !joy0right then goto HFCM_CheckVertical
HFCM_DoRight
          gosub HFCM_AttemptMoveRight bank13
          goto HFCM_CheckVertical
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

