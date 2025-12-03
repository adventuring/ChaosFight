          rem ChaosFight - Source/Routines/ProcessUpAction.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

ProcessUpAction
          asm
ProcessUpAction
end
          rem Shared UP Action Handler
          rem Executes character-specific UP behavior (UP = Button C = Button II, no exceptions)
          rem
          rem Character-specific UP actions:
          rem   Shamone/MethHound: Body change (form switch)
          rem   RoboTito: Stretch (ascend toward ceiling)
          rem   Bernie: Drop (fall through thin floors)
          rem   Harpy: Flap (fly)
          rem   Dragon of Storms: Move up
          rem   Frooty (Fairy): Accelerate up
          rem   Most other characters: Jump
          rem
          rem INPUT: temp1 = player index (0-3)
          rem        temp2 = cached animation state (for attack blocking)
          rem
          rem OUTPUT: temp3 = 1 if action was jump, 0 if special ability
          rem
          rem Mutates: temp2, temp3, temp4, temp6, playerCharacter[],
          rem         playerY[], characterStateFlags_W[]
          rem
          rem Called Routines: BernieJump (bank12), HarpyJump (bank12),
          rem                   DispatchCharacterJump (bank8), PlayfieldRead (bank16)
          rem
          rem Constraints: Must be colocated with helpers in same bank

          rem Check Shamone form switching first (Shamone <-> MethHound)
          rem Switch Shamone -> MethHound
          if playerCharacter[temp1] = CharacterShamone then let playerCharacter[temp1] = CharacterMethHound : let temp3 = 0 : return thisbank
          rem Switch MethHound -> Shamone
          if playerCharacter[temp1] = CharacterMethHound then let playerCharacter[temp1] = CharacterShamone : let temp3 = 0 : return thisbank

          rem Robo Tito: Stretch (ascend toward ceiling; auto-latch on contact)
          if playerCharacter[temp1] = CharacterRoboTito then goto PUA_RoboTitoAscend

          rem Bernie: Drop (fall through thin floors)
          if playerCharacter[temp1] = CharacterBernie then goto PUA_BernieFallThrough

          rem Harpy: Flap (fly)
          if playerCharacter[temp1] = CharacterHarpy then goto PUA_HarpyFlap

          rem For all other characters, UP is jump
          rem Check Zoe Ryen for double-jump capability
          if playerCharacter[temp1] = CharacterZoeRyen then goto PUA_ZoeJumpCheck

          rem Standard jump - block during attack animations (states 13-15)
          if temp2 >= 13 then let temp3 = 0 : return thisbank

          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterJump
          let temp3 = 1
          return thisbank

PUA_BernieFallThrough
          rem Bernie UP handled in BernieJump routine (fall through 1-row floors)
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          let temp3 = 0
          goto BernieJump bank12

PUA_HarpyFlap
          rem Harpy UP handled in HarpyJump routine (flap to fly)
          rem Tail call: goto instead of gosub to save 2 bytes on stack
          let temp3 = 0
          goto HarpyJump bank12

PUA_RoboTitoAscend
          rem Ascend toward ceiling
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
          if temp2 > 31 then let temp2 = 31
          if temp2 & $80 then let temp2 = 0
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
          if temp2 = 0 then goto PUA_RoboTitoLatch
          let temp3 = temp2 - 1
          let currentPlayer = temp1
          let temp1 = temp4
          let temp2 = temp3
          gosub PlayfieldRead bank16
          if temp1 then goto PUA_RoboTitoLatch
          rem Clear latch if DOWN pressed (check appropriate port)
          let temp1 = currentPlayer
          if temp1 & 2 = 0 then goto PUA_CheckJoy0Down
          if joy1down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          let temp3 = 0
          return thisbank
PUA_CheckJoy0Down
          if joy0down then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] & (255 - 1)
          let temp3 = 0
          return thisbank
PUA_RoboTitoLatch
          let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 1
          let temp3 = 0
          return thisbank

PUA_ZoeJumpCheck
          rem Zoe Ryen: Allow single mid-air double-jump
          let temp6 = 0
          if (playerState[temp1] & 4) then let temp6 = 1
          rem Block double-jump if already used (characterStateFlags bit 3)
          if temp6 = 1 then if (characterStateFlags_R[temp1] & 8) then let temp3 = 0 : return thisbank
          rem Block jump during attack animations (states 13-15)
          if temp2 >= 13 then let temp3 = 0 : return thisbank
          let temp4 = playerCharacter[temp1]
          gosub DispatchCharacterJump
          rem Set double-jump flag if jumping in air
          if temp6 = 1 then let characterStateFlags_W[temp1] = characterStateFlags_R[temp1] | 8
          let temp3 = 1
          return thisbank

