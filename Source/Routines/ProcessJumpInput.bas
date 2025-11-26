          rem ChaosFight - Source/Routines/ProcessJumpInput.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

ProcessJumpInput
          asm
ProcessJumpInput

end
          rem
          rem Shared Jump Input Handler
          rem Handles jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          rem Must be identical in effect to ProcessUpInput for all characters
          rem Processes jump logic including Zoe double-jump and character-specific behaviors
          rem
          rem INPUT: temp1 = player index (0-3), temp2 = cached animation state
          rem
          rem OUTPUT: Jump or character-specific behavior executed if conditions met
          rem
          rem Mutates: temp3, temp4, temp6, playerCharacter[], playerState[],
          rem         playerY[], characterStateFlags_W[]
          rem
          rem Called Routines: CheckEnhancedJumpButton, BernieJump (bank10),
          rem         HarpyJump (bank10), DispatchCharacterJump (bank10), PlayfieldRead (bank10)
          rem
          rem Constraints: Must be colocated with PJI_CheckEnhanced, PJI_CharacterBehaviors helpers
          rem Process jump input from enhanced buttons (Genesis/Joy2b+ Button C/II)
          rem Note: For Shamone/MethHound, UP is form switch, so jump via enhanced buttons only
          rem Note: For Bernie, UP is fall-through, so jump via enhanced buttons only
          rem Note: For Harpy, UP is flap, so jump via enhanced buttons only
          rem Check enhanced button first (sets temp3 = 1 if pressed, 0 otherwise)
          rem Check Genesis/Joy2b+ Button C/II
          gosub CheckEnhancedJumpButton bank10
          rem If enhanced button not pressed, return (no jump)
          
          if temp3 = 0 then return otherbank
          rem For characters with special UP behaviors, enhanced button acts as UP
          
          rem Check Shamone form switching first (Shamone <-> MethHound)
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = CharacterShamone then let playerCharacter[temp1] = CharacterMethHound : return otherbank
          rem Switch MethHound -> Shamone
          if playerCharacter[temp1] = CharacterMethHound then let playerCharacter[temp1] = CharacterShamone : return otherbank

          rem Robo Tito: Hold enhanced button to ascend; auto-latch on ceiling contact
          if playerCharacter[temp1] = CharacterRoboTito then goto PJI_RoboTitoAscend

          rem Check Bernie fall-through
          if playerCharacter[temp1] = CharacterBernie then goto PJI_BernieFallThrough

          rem Check Harpy flap
          if playerCharacter[temp1] = CharacterHarpy then goto PJI_HarpyFlap

          rem For all other characters, enhanced button is jump
          rem Allow Zoe Ryen a single mid-air double-jump
          rem Use cached animation state - block jump during attack animations (states 13-15)
          if playerCharacter[temp1] = CharacterZoeRyen then goto PJI_ZoeJumpCheck
          rem Block jump during attack windup/execute/recovery
          if temp2 >= 13 then return otherbank
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterJump bank10
          return otherbank

PJI_ZoeJumpCheck
          let temp6 = 0
          rem Use goto to avoid branch out of range
          if (playerState[temp1] & 4) then temp6 = 1
          rem Use cached animation state - block jump during attack animations (states 13-15)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then return
          if temp2 >= 13 then return
          rem Block jump during attack windup/execute/recovery
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterJump bank10
          if temp6 = 1 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
          return otherbank
PJI_BernieFallThrough
          rem Bernie enhanced button handled in BernieJump routine (fall through 1-row floors)
          gosub BernieJump bank12
          return otherbank
PJI_HarpyFlap
          rem Harpy enhanced button handled in HarpyJump routine (flap to fly)
          gosub HarpyJump bank12
          return otherbank
PJI_RoboTitoAscend
          rem Ascend toward ceiling (same logic as ProcessUpInput)
          let temp6 = playerCharacter[temp1]
          let temp6 = CharacterMovementSpeed[temp6]
          rem Compute playfield column
          let playerY[temp1] = playerY[temp1] - temp6
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          asm
            lsr temp2
            lsr temp2
end
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          rem Save playfield column (temp2 will be overwritten)
          let temp4 = temp2
          rem Compute head row and check ceiling contact
          let temp2 = playerY[temp1]
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          if temp2 = 0 then goto PJI_RoboTitoLatch
          let temp3 = temp2 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          if temp1 then goto PJI_RoboTitoLatch
          rem Clear latch if DOWN pressed (check appropriate port)
          let temp1 = currentPlayer
          if temp1 & 2 = 0 then goto PJI_CheckJoy0Down
          if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          return otherbank
PJI_CheckJoy0Down
          if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          return otherbank
PJI_RoboTitoLatch
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          return otherbank
