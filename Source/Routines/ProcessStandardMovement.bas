          rem ChaosFight - Source/Routines/ProcessStandardMovement.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ProcessStandardMovement
          asm
ProcessStandardMovement

end
          rem
          rem Shared Standard Movement Handler
          rem Handles left/right movement for standard (non-flying) characters
          rem Uses temp1 & 2 pattern to select joy0 vs joy1 (same as HandleFlyingCharacterMovement)
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0left/joy0right for players 0,2; joy1left/joy1right for players 1,3
          rem
          rem OUTPUT: Movement applied to playerVelocityX[] or playerX[]
          rem
          rem Mutates: temp2, temp3, temp6, playerVelocityX[], playerVelocityXL[],
          rem         playerX[], playerState[]
          rem
          rem Called Routines: GetPlayerAnimationStateFunction
          rem
          rem Constraints: Must be colocated with PSM_UseJoy0, PSM_CheckLeftJoy0,
          rem PSM_CheckRightJoy0 helpers
          rem Check if player is guarding - guard blocks movement (right port only)
          rem Left port does not check guard here (may be bug, but preserving behavior)
          rem Right port handler should check guard before calling this
          rem Determine which joy port to use based on player index
          
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          rem Players 1,3 use joy1
          if temp1 & 2 = 0 then goto PSM_UseJoy0
          rem Left movement: set negative velocity
          
          if !joy1left then goto PSM_CheckRightJoy1
          if playerCharacter[temp1] = CharacterFrooty then PSM_LeftMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let temp2 = 0
          let temp2 = temp2 - temp6
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          goto PSM_AfterLeftSet1
PSM_LeftMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
PSM_AfterLeftSet1
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then PSM_InlineYesLeft
          let temp2 = playerState[temp1] / 16
          if temp2 < 5 then PSM_InlineNoLeft
          if temp2 > 9 then PSM_InlineNoLeft
PSM_InlineYesLeft
          let temp3 = 1
          goto PSM_InlineDoneLeft
PSM_InlineNoLeft
          let temp3 = 0
PSM_InlineDoneLeft
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
PSM_CheckRightJoy1
          rem Right movement: set positive velocity
          if !joy1right then return
          if playerCharacter[temp1] = CharacterFrooty then PSM_RightMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = temp6
          let playerVelocityXL[temp1] = 0
          goto PSM_AfterRightSet1
PSM_RightMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
PSM_AfterRightSet1
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then PSM_InlineYesRight1
          let temp2 = playerState[temp1] / 16
          if temp2 < 5 then PSM_InlineNoRight1
          if temp2 > 9 then PSM_InlineNoRight1
PSM_InlineYesRight1
          let temp3 = 1
          goto PSM_InlineDoneRight1
PSM_InlineNoRight1
          let temp3 = 0
PSM_InlineDoneRight1
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          return
          
PSM_UseJoy0
          rem Players 0,2 use joy0
          rem Left movement: set negative velocity
          
          if !joy0left then goto PSM_CheckRightJoy0
          if playerCharacter[temp1] = CharacterFrooty then PSM_LeftMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let temp2 = 0
          let temp2 = temp2 - temp6
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          goto PSM_AfterLeftSet0
PSM_LeftMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
PSM_AfterLeftSet0
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then PSM_InlineYesLeft0
          let temp2 = playerState[temp1] / 16
          if temp2 < 5 then PSM_InlineNoLeft0
          if temp2 > 9 then PSM_InlineNoLeft0
PSM_InlineYesLeft0
          let temp3 = 1
          goto PSM_InlineDoneLeft0
PSM_InlineNoLeft0
          let temp3 = 0
PSM_InlineDoneLeft0
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
          
PSM_CheckRightJoy0
          rem Right movement: set positive velocity
          if !joy0right then return
          if playerCharacter[temp1] = CharacterFrooty then PSM_RightMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = temp6
          let playerVelocityXL[temp1] = 0
          goto PSM_AfterRightSet0
PSM_RightMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
PSM_AfterRightSet0
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then PSM_InlineYesRight0
          let temp2 = playerState[temp1] / 16
          if temp2 < 5 then PSM_InlineNoRight0
          if temp2 > 9 then PSM_InlineNoRight0
PSM_InlineYesRight0
          let temp3 = 1
          goto PSM_InlineDoneRight0
PSM_InlineNoRight0
          let temp3 = 0
PSM_InlineDoneRight0
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          return

