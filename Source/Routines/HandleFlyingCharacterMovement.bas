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
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 & 2 = 0 then HFCM_UseJoy0
          rem Players 1,3 use joy1
          if joy1left then HFCM_CheckLeftCollision
          goto HFCM_CheckRightMovement
HFCM_UseJoy0
          rem Players 0,2 use joy0
          if joy0left then HFCM_CheckLeftCollision
          goto HFCM_CheckRightMovement
HFCM_CheckLeftCollision
          rem Convert player position to playfield coordinates
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0

          rem Check column to the left

          if temp2 <= 0 then goto HFCM_CheckRightMovement
          let temp3 = temp2 - 1
          rem Already at left edge
          rem checkColumn = column to the left
          let currentPlayer = temp1
          rem Save player index to global variable
          let temp4 = playerY[temp1]
          rem Check player current row (check both top and bottom of sprite)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          rem pfRow = top row  
          rem Check if blocked in current row
          let temp5 = 0
          rem Reset left-collision flag
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then goto HFCM_CheckRightMovement
          rem Blocked, cannot move left
          let temp2 = temp4 + 16
          rem Also check bottom row (feet)
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          if temp6 >= pfrows then goto HFCM_MoveLeftOK
          rem Do not check if beyond screen
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then goto HFCM_CheckRightMovement
HFCM_MoveLeftOK
          rem Blocked at bottom too
          if temp5 = 8 then goto HFCM_LeftMomentumApply
          if temp5 = 2 then goto HFCM_LeftDirectApply
          rem Default (should not hit): apply -1
          let playerVelocityX[temp1] = $ff
          let playerVelocityXL[temp1] = 0
          goto HFCM_LeftApplyDone
HFCM_LeftMomentumApply
          let playerVelocityX[temp1] = playerVelocityX[temp1] - CharacterMovementSpeed[temp5]
          let playerVelocityXL[temp1] = 0
          goto HFCM_LeftApplyDone
HFCM_LeftDirectApply
          let playerX[temp1] = playerX[temp1] - CharacterMovementSpeed[temp5]
HFCM_LeftApplyDone
          rem Preserve facing during hurt/recovery states (knockback, hitstun)
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes1
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo1
          if temp2 > 9 then goto SPF_InlineNo1
SPF_InlineYes1
          let temp3 = 1
          goto SPF_InlineDone1
SPF_InlineNo1
          let temp3 = 0
SPF_InlineDone1
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
HFCM_CheckRightMovement
          rem Determine which joy port to use for right movement
          if temp1 = 0 then HFCM_CheckRightJoy0
          if temp1 = 2 then HFCM_CheckRightJoy0
          rem Players 1,3 use joy1
          if !joy1right then return
          goto HFCM_DoRightMovement
HFCM_CheckRightJoy0
          rem Players 0,2 use joy0
          if !joy0right then return
HFCM_DoRightMovement
          rem Convert player position to playfield coordinates
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0

          rem Check column to the right

          if temp2 >= 31 then return
          let temp3 = temp2 + 1
          rem Already at right edge
          rem checkColumn = column to the right
          let currentPlayer = temp1
          rem Save player index to global variable
          let temp4 = playerY[temp1]
          rem Check player current row (check both top and bottom of sprite)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          rem pfRow = top row
          rem Check if blocked in current row
          let temp5 = 0
          rem Reset right-collision flag
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then return
          rem Blocked, cannot move right
          let temp4 = temp4 + 16
          rem Also check bottom row (feet)
          let temp2 = temp4
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp6 = temp2
          if temp6 >= pfrows then goto HFCM_MoveRightOK
          rem Do not check if beyond screen
          let temp1 = temp3
          let temp2 = temp6
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = currentPlayer
          if temp5 = 1 then return
HFCM_MoveRightOK
          rem Blocked at bottom too
          if temp5 = 8 then goto HFCM_RightMomentumApply
          if temp5 = 2 then goto HFCM_RightDirectApply
          rem Default (should not hit): apply +1
          let playerVelocityX[temp1] = 1
          let playerVelocityXL[temp1] = 0
          goto HFCM_RightApplyDone
HFCM_RightMomentumApply
          let playerVelocityX[temp1] = playerVelocityX[temp1] + CharacterMovementSpeed[temp5]
          let playerVelocityXL[temp1] = 0
          goto HFCM_RightApplyDone
HFCM_RightDirectApply
          let playerX[temp1] = playerX[temp1] + CharacterMovementSpeed[temp5]
HFCM_RightApplyDone
          rem Preserve facing during hurt/recovery states while processing right movement
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes2
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo2
          if temp2 > 9 then goto SPF_InlineNo2
SPF_InlineYes2
          let temp3 = 1
          goto SPF_InlineDone2
SPF_InlineNo2
          let temp3 = 0
SPF_InlineDone2
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          rem Vertical control for flying characters: UP/DOWN
          if temp1 & 2 = 0 then HFCM_VertJoy0
          if joy1up then HFCM_VertUp
          if joy1down then HFCM_VertDown
          return
HFCM_VertJoy0
          if joy0up then HFCM_VertUp
          if joy0down then HFCM_VertDown
          return
HFCM_VertUp
          if temp5 = 8 then let playerVelocityY[temp1] = playerVelocityY[temp1] - CharacterMovementSpeed[temp5] : return
          if temp5 = 2 then let playerY[temp1] = playerY[temp1] - CharacterMovementSpeed[temp5] : return
          return
HFCM_VertDown
          if temp5 = 8 then let playerVelocityY[temp1] = playerVelocityY[temp1] + CharacterMovementSpeed[temp5] : return
          if temp5 = 2 then let playerY[temp1] = playerY[temp1] + CharacterMovementSpeed[temp5] : return
          return

