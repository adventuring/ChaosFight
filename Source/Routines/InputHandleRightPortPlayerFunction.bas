          rem ChaosFight - Source/Routines/InputHandleRightPortPlayerFunction.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

InputHandleRightPortPlayerFunction
          asm
InputHandleRightPortPlayerFunction

end
          rem
          rem RIGHT PORT PLAYER INPUT HANDLER (joy1 - Players 2 & 4)
          rem
          rem INPUT: temp1 = player index (1 or 3)
          rem USES: joy1left, joy1right, joy1up, joy1down, joy1fire
          let currentPlayer = temp1
          rem Cache animation state at start (used for movement, jump,
          rem and attack checks)
          gosub GetPlayerAnimationStateFunction
          rem   block movement during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 327+ bytes away)
          if temp2 >= 13 then goto DoneRightPortMovement
          rem Block movement during attack windup/execute/recovery

          rem Process left/right movement (with playfield collision for
          rem   flying characters)
          let temp6 = playerState[temp1] & 2
          rem Check if player is guarding - guard blocks movement
          rem Use goto to avoid branch out of range (target is 314+ bytes away)
          if temp6 then goto DoneRightPortMovement
          rem Guarding - block movement

          rem Frooty (8) and Dragon of Storms (2) need collision checks
          let temp5 = playerCharacter[temp1]
          rem   for horizontal movement
          rem Use goto to avoid branch out of range (target is 302+ bytes away)
          if temp5 = 8 then goto IHRP_FlyingMovement
          if temp5 = 2 then goto IHRP_FlyingMovement

          rem Standard horizontal movement (no collision check)

          if !joy1left then goto IHRP_DoneLeftMovement
          if playerCharacter[temp1] = 8 then goto IHRP_LeftMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let temp2 = 0
          let temp2 = temp2 - temp6
          let playerVelocityX[temp1] = temp2
          let playerVelocityXL[temp1] = 0
          goto IHRP_AfterLeftSet1
IHRP_LeftMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] - temp6
          let playerVelocityXL[temp1] = 0
IHRP_AfterLeftSet1
          rem Preserve facing during hurt/recovery states while processing right movement
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes5
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo5
          if temp2 > 9 then goto SPF_InlineNo5
SPF_InlineYes5
          let temp3 = 1
          goto SPF_InlineDone5
SPF_InlineNo5
          let temp3 = 0
SPF_InlineDone5
          if !temp3 then let playerState[temp1] = playerState[temp1] & (255 - PlayerStateBitFacing)
IHRP_DoneLeftMovement

          if !joy1right then goto IHRP_DoneFlyingLeftRight
          if playerCharacter[temp1] = 8 then goto IHRP_RightMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = temp6
          rem Apply rightward velocity impulse
          let playerVelocityXL[temp1] = 0
          goto IHRP_AfterRightSet1
IHRP_RightMomentum1
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          let playerVelocityX[temp1] = playerVelocityX[temp1] + temp6
          let playerVelocityXL[temp1] = 0
IHRP_AfterRightSet1
          rem Preserve facing during hurt/recovery states (knockback, hitstun)
          rem Inline ShouldPreserveFacing logic
          if (playerState[temp1] & 8) then goto SPF_InlineYes6
          gosub GetPlayerAnimationStateFunction
          if temp2 < 5 then goto SPF_InlineNo6
          if temp2 > 9 then goto SPF_InlineNo6
SPF_InlineYes6
          let temp3 = 1
          goto SPF_InlineDone6
SPF_InlineNo6
          let temp3 = 0
SPF_InlineDone6
          if !temp3 then let playerState[temp1] = playerState[temp1] | 1
          rem Right movement complete (right port)

DoneRightPortMovement
IHRP_FlyingMovement
          gosub HandleFlyingCharacterMovement
IHRP_DoneFlyingLeftRight


          rem Process UP input for character-specific behaviors (right
          rem   port)
          rem - Shamone/MethHound: form switching (15 <-> 31)
          rem - Bernie: fall through 1-row floors
          rem - Harpy: flap to fly (Character 6)
          if !joy1up then goto DoneUpInputHandlingRight

          rem Check Shamone form switching first (Character 15 <-> 31)
          if playerCharacter[temp1] = 15 then let playerCharacter[temp1] = 31 : goto DoneJumpInputRight
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = 31 then let playerCharacter[temp1] = 15 : goto DoneJumpInputRight
          rem Switch MethHound -> Shamone

          rem Robo Tito (13): Hold UP to ascend; auto-latch on ceiling contact
          if playerCharacter[temp1] = 13 then RoboTitoAscendRight

          rem Check Bernie fall-through (Character 0)

          if playerCharacter[temp1] = 0 then BernieFallThroughRight

          rem Check Harpy flap (Character 6)

          if playerCharacter[temp1] = 6 then HarpyFlapRight

          goto NormalJumpInputRight
          rem For all other characters, UP is jump

BernieFallThroughRight
          rem Bernie UP input handled in BernieJump routine (fall
          gosub BernieJump bank13
          rem   through 1-row floors)
          goto DoneJumpInputRight

HarpyFlapRight
          gosub HarpyJump bank13
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto DoneJumpInputRight

RoboTitoAscendRight
          rem Ascend toward ceiling (right port)
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
          if temp2 = 0 then goto RoboTitoLatchRight
          let temp3 = temp2 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          if temp1 then RoboTitoLatchRight
          let temp1 = currentPlayer
          rem Clear latch if DOWN pressed
          if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          goto DoneJumpInputRight
RoboTitoLatchRight
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          goto DoneJumpInputRight
NormalJumpInputRight
          let temp3 = 1
          rem Process jump input (UP + enhanced buttons)
          goto DoneUpInputHandlingRight
          rem Jump pressed flag (UP pressed)

DoneJumpInputRight
          let temp3 = 0
          rem No jump (UP used for special ability)

DoneUpInputHandlingRight
          rem Process jump input from enhanced buttons (Genesis/Joy2b+
          rem   Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump
          rem   via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced
          rem   buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons
          rem only
          if playerCharacter[temp1] = 15 then goto ShamoneJumpCheckEnhancedRight
          if playerCharacter[temp1] = 31 then goto ShamoneJumpCheckEnhancedRight
          if playerCharacter[temp1] = 0 then goto ShamoneJumpCheckEnhancedRight
          if playerCharacter[temp1] = 6 then goto ShamoneJumpCheckEnhancedRight
          rem Bernie and Harpy also use enhanced buttons for jump

          goto SkipEnhancedJumpCheckRight
ShamoneJumpCheckEnhancedRight
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II for JUMP for any character, identical to UP

          rem Execute jump if pressed and not already jumping
          rem For Shamone/Meth Hound, treat enhanced button as UP (toggle forms)
          if playerCharacter[temp1] = 15 then if temp3 then let playerCharacter[temp1] = 31 : goto InputDoneRightPortJump
          if playerCharacter[temp1] = 31 then if temp3 then let playerCharacter[temp1] = 15 : goto InputDoneRightPortJump
          rem Use goto to avoid branch out of range (target is 218+ bytes away)
          if temp3 = 0 then goto InputDoneRightPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto RightZoeEnhancedCheck
          rem Use goto to avoid branch out of range (target is 198+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneRightPortJump
          goto RightEnhancedJumpProceed
RightZoeEnhancedCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 163+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneRightPortJump
RightEnhancedJumpProceed
          rem Use cached animation state - block jump during attack animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 157+ bytes away)
          if temp2 >= 13 then goto InputDoneRightPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          gosub DispatchCharacterJump bank13
          if playerCharacter[temp1] = 3 then if temp6 = 1 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
          goto InputDoneRightPortJump

SkipEnhancedJumpCheckRight
          gosub CheckEnhancedJumpButton
          rem Check Genesis/Joy2b+ Button C/II
          rem temp3 already set by CheckEnhancedJumpButton

          rem Execute jump if pressed and not already jumping
          rem Handle MethHound jump (character 31 uses same jump as
          rem Shamone)
          rem Use goto to avoid branch out of range (target is 218+ bytes away)
          if temp3 = 0 then goto InputDoneRightPortJump
          rem Allow Zoe (3) a single mid-air double-jump
          if playerCharacter[temp1] = 3 then goto RightZoeStdJumpCheck
          rem Use goto to avoid branch out of range (target is 198+ bytes away)
          if (playerState[temp1] & 4) then goto InputDoneRightPortJump
          goto RightStdJumpProceed
RightZoeStdJumpCheck
          let temp6 = 0
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use goto to avoid branch out of range (target is 163+ bytes away)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then goto InputDoneRightPortJump
RightStdJumpProceed
          rem Use cached animation state - block jump during attack
          rem animations (states 13-15)
          rem Use goto to avoid branch out of range (target is 157+ bytes away)
          if temp2 >= 13 then goto InputDoneRightPortJump
          let temp4 = playerCharacter[temp1]
          rem Block jump during attack windup/execute/recovery
          gosub DispatchCharacterJump bank13
InputDoneRightPortJump
          gosub HandleGuardInput
          rem Process down/guard input

          rem Process attack input
          rem Use cached animation state - block attack input during
          rem attack
          rem animations (states 13-15)
          if temp2 >= 13 then InputDoneRightPortAttack
          rem Block attack input during attack windup/execute/recovery
          let temp2 = playerState[temp1] & 2
          if temp2 then InputDoneRightPortAttack
          rem Guarding - block attack input
          if !joy1fire then InputDoneRightPortAttack
          if (playerState[temp1] & PlayerStateBitFacing) then InputDoneRightPortAttack
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterAttack bank7
InputDoneRightPortAttack
          return

