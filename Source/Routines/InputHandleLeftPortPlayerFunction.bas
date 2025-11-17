          rem ChaosFight - Source/Routines/InputHandleLeftPortPlayerFunction.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

InputHandleLeftPortPlayerFunction
          asm
InputHandleLeftPortPlayerFunction

end
          rem
          rem LEFT PORT PLAYER INPUT HANDLER (joy0 - Players 1 & 3)
          rem
          rem INPUT: temp1 = player index (0 or 2)
          rem USES: joy0left, joy0right, joy0up, joy0down, joy0fire
          let currentPlayer = temp1
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationStateFunction
          rem   block movement during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 310+ bytes away)
          if temp2 >= 13 then goto DoneLeftPortMovement
          rem Block movement during attack windup/execute/recovery

          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = playerCharacter[temp1]
          rem   for horizontal movement
          rem Use goto to avoid branch out of range (target is 298+ bytes away)
          if temp5 = 8 then goto IHLP_FlyingMovement
          if temp5 = 2 then goto IHLP_FlyingMovement

          rem Standard horizontal movement (modifies velocity, not
          rem position)
          rem Left movement: set negative velocity (255 in 8-bit twos
          rem complement = -1)
          if !joy0left then goto IHLP_DoneLeftMovement
          if playerCharacter[temp1] = 8 then goto IHLP_LeftMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let temp2 = 0
          let temp2 = temp2 - temp6
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          goto IHLP_AfterLeftSet0
IHLP_LeftMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
IHLP_AfterLeftSet0
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes3
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo3
          if temp2 > 9 then goto SPF_InlineNo3
SPF_InlineYes3
          let temp3 = 1
          goto SPF_InlineDone3
SPF_InlineNo3
          let temp3 = 0
SPF_InlineDone3
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
IHLP_DoneLeftMovement
          rem Right movement: set positive velocity
          if !joy0right then goto IHLP_DoneFlyingLeftRight
          if playerCharacter[temp1] = 8 then goto IHLP_RightMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = temp6
          let playerVelocityXL[temp1] = 0
          goto IHLP_AfterRightSet0
IHLP_RightMomentum0
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
IHLP_AfterRightSet0
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes4
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo4
          if temp2 > 9 then goto SPF_InlineNo4
SPF_InlineYes4
          let temp3 = 1
          goto SPF_InlineDone4
SPF_InlineNo4
          let temp3 = 0
SPF_InlineDone4
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          rem Right movement complete
DoneLeftPortMovement
IHLP_FlyingMovement
          gosub HandleFlyingCharacterMovement
IHLP_DoneFlyingLeftRight

          rem Process UP input for character-specific behaviors
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy0up then goto DoneUpInputHandling

          rem Check Shamone form switching first (Character 15 <-> 31)
          if playerCharacter[temp1] = 15 then let playerCharacter[temp1] = 31 : goto DoneJumpInput
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = 31 then let playerCharacter[temp1] = 15 : goto DoneJumpInput
          rem Switch MethHound -> Shamone

          rem Robo Tito (13): Hold UP to ascend; auto-latch on ceiling contact
          if playerCharacter[temp1] = 13 then RoboTitoAscendLeft

          rem Check Bernie fall-through (Character 0)

          if playerCharacter[temp1] = 0 then BernieFallThrough

          rem Check Harpy flap (Character 6)

          if playerCharacter[temp1] = 6 then HarpyFlap

          goto NormalJumpInput
          rem For all other characters, UP is jump

BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump bank13
          rem   through 1-row floors)
          goto DoneJumpInput

HarpyFlap
          gosub HarpyJump bank13
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInput

RoboTitoAscendLeft
          rem Ascend toward ceiling
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerY[temp1] = playerY[temp1] - temp6
          rem Compute playfield column
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          let temp4 = temp2
          rem Save playfield column (temp2 will be overwritten)
          rem Compute head row and check ceiling contact
          let temp2 = playerY[temp1]
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          if temp2 = 0 then goto RoboTitoLatchLeft
          let temp3 = temp2 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          if temp1 then RoboTitoLatchLeft
          let temp1 = currentPlayer
          rem Clear latch if DOWN pressed
          if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          goto DoneJumpInput
RoboTitoLatchLeft
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          goto DoneJumpInput
NormalJumpInput
          let temp3 = 1
          rem Process jump input (UP + enhanced buttons)
          goto DoneUpInputHandling
          rem Jump pressed flag (UP pressed)

DoneJumpInput
          let temp3 = 0
          rem No jump (UP used for special ability)

DoneUpInputHandling
          rem Process jump input from enhanced buttons (Genesis/Joy2b+
          rem   Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump
          rem   via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced
          rem   buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons
          rem only
          if playerCharacter[temp1] = 15 then goto ShamoneJumpCheckEnhanced
          if playerCharacter[temp1] = 31 then goto ShamoneJumpCheckEnhanced
          if playerCharacter[temp1] = 0 then goto ShamoneJumpCheckEnhanced
          if playerCharacter[temp1] = 6 then goto ShamoneJumpCheckEnhanced
          rem Bernie and Harpy also use enhanced buttons for jump

          goto SkipEnhancedJumpCheck
ShamoneJumpCheckEnhanced
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II for alternative UP for any characters

          rem Execute jump if pressed and not already jumping
          rem For Shamone/Meth Hound, treat enhanced button as UP (toggle forms)
          if playerCharacter[temp1] = 15 then if temp3 then let playerCharacter[temp1] = 31 : goto InputDoneLeftPortJump
          if playerCharacter[temp1] = 31 then if temp3 then let playerCharacter[temp1] = 15 : goto InputDoneLeftPortJump
          rem Use goto to avoid branch out of range (target is 244+ bytes away)
          if temp3 = 0 then goto InputDoneLeftPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto LeftZoeEnhancedCheck
          rem Use goto to avoid branch out of range (target is 224+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneLeftPortJump
          goto LeftEnhancedJumpProceed
LeftZoeEnhancedCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 189+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneLeftPortJump
LeftEnhancedJumpProceed
          rem Use cached animation state - block jump during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 183+ bytes away)
          if temp2 >= 13 then goto InputDoneLeftPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          gosub DispatchCharacterJump bank13
          if playerCharacter[temp1] = 3 then if temp6 = 1 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
          goto InputDoneLeftPortJump

SkipEnhancedJumpCheck
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II

          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          rem Use goto to avoid branch out of range (target is 244+ bytes away)
          if temp3 = 0 then goto InputDoneLeftPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto LeftZoeStdJumpCheck
          rem Use goto to avoid branch out of range (target is 224+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneLeftPortJump
          goto LeftStdJumpProceed
LeftZoeStdJumpCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 189+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneLeftPortJump
LeftStdJumpProceed
          rem Use cached animation state - block jump during attack
          rem animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 183+ bytes away)
          if temp2 >= 13 then goto InputDoneLeftPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          gosub DispatchCharacterJump bank13
          if playerCharacter[temp1] = 3 then if temp6 = 1 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
InputDoneLeftPortJump



          gosub HandleGuardInput
          rem Process down/guard input


          rem Process attack input
          rem Map MethHound (31) to ShamoneAttack handler
          rem Use cached animation state - block attack input during
          rem attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneLeftPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = playerState[temp1] & 2
          rem Check if player is guarding - guard blocks attacks
          if temp2 then InputDoneLeftPortAttack
          rem Guarding - block attack input
          if !joy0fire then InputDoneLeftPortAttack
          if (playerState[temp1] & PlayerStateBitFacing) then InputDoneLeftPortAttack
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterAttack bank7
InputDoneLeftPortAttack


          return

