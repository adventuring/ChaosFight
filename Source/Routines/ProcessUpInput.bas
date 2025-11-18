          rem ChaosFight - Source/Routines/ProcessUpInput.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

ProcessUpInput
          asm
ProcessUpInput

end
          rem
          rem Shared UP Input Handler
          rem Handles UP input for character-specific behaviors
          rem Uses temp1 & 2 pattern to select joy0 vs joy1
          rem
          rem INPUT: temp1 = player index (0-3)
          rem Uses: joy0up/joy0down for players 0,2; joy1up/joy1down for players 1,3
          rem
          rem OUTPUT: temp3 = jump flag (1 if UP used for jump, 0 if special ability)
          rem         Character state may be modified (form switching, RoboTito latch)
          rem
          rem Mutates: temp2, temp3, temp4, temp6, playerCharacter[],
          rem         playerY[], characterStateFlags_W[]
          rem
          rem Called Routines: BernieJump (bank10), HarpyJump (bank10), PlayfieldRead (bank10)
          rem
          rem Constraints: Must be colocated with PUI_UseJoy0, PUI_RoboTitoAscend helpers
          rem Determine which joy port to use based on player index
          rem Players 0,2 use joy0 (left port); Players 1,3 use joy1 (right port)
          if temp1 & 2 = 0 then goto PUI_UseJoy0
          rem Players 1,3 use joy1
          if !joy1up then goto PUI_DoneUpInputHandling
          goto PUI_ProcessUp
          
PUI_UseJoy0
          rem Players 0,2 use joy0
          if !joy0up then goto PUI_DoneUpInputHandling
          
PUI_ProcessUp
          rem Check Shamone form switching first (Character 15 <-> 31)
          if playerCharacter[temp1] = 15 then let playerCharacter[temp1] = 31 : goto PUI_DoneJumpInput
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = 31 then let playerCharacter[temp1] = 15 : goto PUI_DoneJumpInput
          rem Switch MethHound -> Shamone

          rem Robo Tito (13): Hold UP to ascend; auto-latch on ceiling contact
          if playerCharacter[temp1] = 13 then goto PUI_RoboTitoAscend

          rem Check Bernie fall-through (Character 0)
          if playerCharacter[temp1] = 0 then goto PUI_BernieFallThrough

          rem Check Harpy flap (Character 6)
          if playerCharacter[temp1] = 6 then goto PUI_HarpyFlap

          goto PUI_NormalJumpInput
          rem For all other characters, UP is jump

PUI_BernieFallThrough
          rem Bernie UP input handled in BernieJump routine (fall through 1-row floors)
          gosub BernieJump bank10
          goto PUI_DoneJumpInput

PUI_HarpyFlap
          gosub HarpyJump bank10
          rem Harpy UP input handled in HarpyJump routine (flap to fly)
          goto PUI_DoneJumpInput

PUI_RoboTitoAscend
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
          if temp2 = 0 then goto PUI_RoboTitoLatch
          let temp3 = temp2 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          if temp1 then goto PUI_RoboTitoLatch
          let temp1 = currentPlayer
          rem Clear latch if DOWN pressed (check appropriate port)
          if temp1 & 2 = 0 then goto PUI_CheckJoy0Down
          if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          goto PUI_DoneJumpInput
PUI_CheckJoy0Down
          if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          goto PUI_DoneJumpInput
PUI_RoboTitoLatch
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          goto PUI_DoneJumpInput
          
PUI_NormalJumpInput
          let temp3 = 1
          rem Process jump input (UP + enhanced buttons)
          goto PUI_DoneUpInputHandling
          rem Jump pressed flag (UP pressed)

PUI_DoneJumpInput
          let temp3 = 0
          rem No jump (UP used for special ability)

PUI_DoneUpInputHandling
          return

