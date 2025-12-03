          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Bruce-Robert Pocock
          rem :
          rem Character jump velocity lookup table (for StandardJump)
          rem Values are 8-bit twos complement upward velocities
          rem 0 = special jump (use character-specific function)
          rem Non-zero = standard jump velocity
          data CharacterJumpVelocities
            0, 254, 0, 244, 248, 254, 0, 248, 0, 254, 243, 248, 243, 0, 248, 245
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 245
end

StandardJump
          rem Returns: Far (return otherbank)
          asm
StandardJump
end
          rem Shared standard jump with velocity lookup
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index
          rem Output: Upward velocity applied, jumping flag set
          let temp2 = playerCharacter[temp1]
          let temp2 = CharacterJumpVelocities[temp2]
          if temp2 = 0 then return otherbank

          let playerVelocityY[temp1] = temp2
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return otherbank

CCJ_ConvertPlayerXToPlayfieldColumn
          asm
CCJ_ConvertPlayerXToPlayfieldColumn
end
          rem Convert player X to playfield column (0-31)
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index
          rem Output: temp2 = playfield column
          rem FIXME: This should be inlined.
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          return otherbank

BernieJump
          rem Returns: Far (return otherbank)
          asm
BernieJump
end
          rem BERNIE (0) - Drop through single-row platforms
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index
          rem Output: playerY[] updated when falling through
          gosub CCJ_ConvertPlayerXToPlayfieldColumn bank13

          let temp3 = playerY[temp1]
          let temp5 = temp3 + 16
          let temp6 = temp5 / 16
          let temp4 = 0
          let temp3 = temp1
          let temp1 = temp2
          let temp2 = temp6
          gosub PlayfieldRead bank16

          if temp1 then let temp4 = 1
          let temp1 = temp3
          if temp4 = 0 then return otherbank

          if temp6 >= pfrows - 1 then goto BernieCheckBottomWrap

          let temp4 = temp6 + 1
          let temp5 = 0
          let temp3 = temp1
          let temp1 = temp2
          let temp2 = temp4
          gosub PlayfieldRead bank16

          if temp1 then let temp5 = 1
          let temp1 = temp3
          if temp5 = 1 then return otherbank

          let playerY[temp1] = playerY[temp1] + 1
          return otherbank

BernieCheckBottomWrap
          rem Helper: Wrap Bernie to top row if clear
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index, temp2 = playfield column
          let temp4 = 0
          let temp5 = 0
          let temp3 = temp1
          let temp1 = temp2
          let temp2 = temp4
          gosub PlayfieldRead bank16

          if temp1 then let temp5 = 1
          let temp1 = temp3
          if temp5 = 1 then return otherbank

          let playerY[temp1] = 0
          return otherbank

CCJ_FreeFlightUp
          asm
CCJ_FreeFlightUp
end
          rem Shared free flight upward movement (DragonOfStorms, Frooty)
          rem Calling Convention: Near
          rem Input: temp1 = player index, temp2 = playfield column (from CCJ_ConvertPlayerXToPlayfieldColumn)
          rem Output: Upward velocity applied if clear above, jumping flag set
          rem Mutates: temp3-temp6, playerVelocityY[], playerVelocityYL[], playerState[]
          let temp3 = playerY[temp1]
          let temp4 = temp3 / 16
          if temp4 <= 0 then return thisbank

          let temp4 = temp4 - 1
          let temp5 = 0
          let temp6 = temp1
          let temp1 = temp2
          let temp2 = temp4
          gosub PlayfieldRead bank16

          if temp1 then let temp5 = 1
          let temp1 = temp6
          if temp5 = 1 then return thisbank

          let playerVelocityY[temp1] = 254
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return thisbank

DragonOfStormsJump
          rem Returns: Far (return otherbank)
          asm
DragonOfStormsJump
end
          goto CCJ_FreeFlightCharacterJump
          rem ZOE RYEN (3) - STANDARD JUMP (dispatched directly to StandardJump)
          rem Returns: Far (return otherbank)
          rem FAT TONY (4) - STANDARD JUMP (dispatched directly to StandardJump)

HarpyJump
          rem Returns: Far (return otherbank)
          asm

HarpyJump

end
          rem HARPY (6) - FLAP TO FLY
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index
          rem Output: Upward velocity if energy available and cooldown expired
          dim HJ_stateFlags = temp3
          if characterSpecialAbility_R[temp1] = 0 then return otherbank

          let temp2 = frame - harpyLastFlapFrame_R[temp1]
          if temp2 > 127 then temp2 = 127
          if temp2 < HarpyFlapCooldownFrames then return otherbank

          if playerY[temp1] <= 5 then goto HarpyFlapRecord

          let playerVelocityY[temp1] = 254
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          let HJ_stateFlags = characterStateFlags_R[temp1] | 2
          let characterStateFlags_W[temp1] = HJ_stateFlags

HarpyFlapRecord
          rem Returns: Far (return otherbank)
          if characterSpecialAbility_R[temp1] > 0 then let characterSpecialAbility_W[temp1] = characterSpecialAbility_R[temp1] - 1
          let harpyLastFlapFrame_W[temp1] = frame
          return otherbank

FrootyJump
          asm
FrootyJump
end
CCJ_FreeFlightCharacterJump
          rem Shared free-flight jump for DragonOfStorms (2) and Frooty (8)
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index
          rem Output: Upward velocity if clear above
          gosub CCJ_ConvertPlayerXToPlayfieldColumn bank13

          gosub CCJ_FreeFlightUp

          return otherbank
