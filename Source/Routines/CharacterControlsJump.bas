          rem ChaosFight - Source/Routines/CharacterControls.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Character jump velocity lookup table (for StandardJump)
          rem Values are 8-bit twos complement upward velocities
          rem 0 = special jump (use character-specific function)
          rem Non-zero = standard jump velocity
          data CharacterJumpVelocities
          0, 254, 0, 244, 248, 254, 0, 248, 0, 254, 243, 248, 243, 0, 248, 245
end

StandardJump
          asm
StandardJump
end
          rem Shared standard jump with velocity lookup
          rem Input: temp1 = player index
          rem Output: Upward velocity applied, jumping flag set
          let temp2 = playerCharacter[temp1]
          let temp2 = CharacterJumpVelocities(temp2)
          if temp2 = 0 then return
          let playerVelocityY[temp1] = temp2
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return otherbank

CCJ_ConvertPlayerXToPlayfieldColumn
          asm
CCJ_ConvertPlayerXToPlayfieldColumn
end
          rem Convert player X to playfield column (0-31)
          rem Input: temp1 = player index
          rem Output: temp2 = playfield column
          rem FIXME: This should be inlined.
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          return otherbank

BernieJump
          asm
BernieJump
end
          rem BERNIE (0) - Drop through single-row platforms
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
          if temp4 = 0 then return
          if temp6 >= pfrows - 1 then goto BernieCheckBottomWrap
          let temp4 = temp6 + 1
          let temp5 = 0
          let temp3 = temp1
          let temp1 = temp2
          let temp2 = temp4
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = temp3
          if temp5 = 1 then return
          let playerY[temp1] = playerY[temp1] + 1
          return otherbank

BernieCheckBottomWrap
          rem Helper: Wrap Bernie to top row if clear
          rem Input: temp1 = player index, temp2 = playfield column
          let temp4 = 0
          let temp5 = 0
          let temp3 = temp1
          let temp1 = temp2
          let temp2 = temp4
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = temp3
          if temp5 = 1 then return
          let playerY[temp1] = 0
          return otherbank

CCJ_FreeFlightUp
          asm
CCJ_FreeFlightUp
end
          rem Shared free flight upward movement (DragonOfStorms, Frooty)
          rem Input: temp1 = player index, temp2 = playfield column (from CCJ_ConvertPlayerXToPlayfieldColumn)
          rem Output: Upward velocity applied if clear above, jumping flag set
          rem Mutates: temp3-temp6, playerVelocityY[], playerVelocityYL[], playerState[]
          let temp3 = playerY[temp1]
          let temp4 = temp3 / 16
          if temp4 <= 0 then return
          let temp4 = temp4 - 1
          let temp5 = 0
          let temp6 = temp1
          let temp1 = temp2
          let temp2 = temp4
          gosub PlayfieldRead bank16
          if temp1 then let temp5 = 1
          let temp1 = temp6
          if temp5 = 1 then return
          let playerVelocityY[temp1] = 254
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          return otherbank

DragonOfStormsJump
          asm
DragonOfStormsJump
end
          rem DRAGON OF STORMS (2) - FREE FLIGHT
          rem Input: temp1 = player index
          rem Output: Upward velocity if clear above
          gosub CCJ_ConvertPlayerXToPlayfieldColumn bank13
          gosub CCJ_FreeFlightUp
          return otherbank

          rem ZOE RYEN (3) - STANDARD JUMP (dispatched directly to StandardJump)
          rem FAT TONY (4) - STANDARD JUMP (dispatched directly to StandardJump)

HarpyJump
          asm
HarpyJump
end
          rem HARPY (6) - FLAP TO FLY
          rem Input: temp1 = player index
          rem Output: Upward velocity if energy available and cooldown expired
          dim HJ_stateFlags = temp3
          if characterSpecialAbility_R[temp1] = 0 then return
          let temp2 = frame - harpyLastFlapFrame_R[temp1]
          if temp2 > 127 then temp2 = 127
          if temp2 < HarpyFlapCooldownFrames then return
          if playerY[temp1] <= 5 then goto HarpyFlapRecord
          let playerVelocityY[temp1] = 254
          let playerVelocityYL[temp1] = 0
          let playerState[temp1] = playerState[temp1] | 4
          let HJ_stateFlags = characterStateFlags_R[temp1] | 2
          let characterStateFlags_W[temp1] = HJ_stateFlags

HarpyFlapRecord
          if characterSpecialAbility_R[temp1] > 0 then let characterSpecialAbility_W[temp1] = characterSpecialAbility_R[temp1] - 1
          let harpyLastFlapFrame_W[temp1] = frame
          return otherbank

          rem KNIGHT GUY (7) - STANDARD JUMP (dispatched directly to StandardJump)
          rem Removed redundant wrapper function - DispatchCharacterJump calls StandardJump directly

FrootyJump
          asm
FrootyJump
end
          rem FROOTY (8) - PERMANENT FREE FLIGHT
          rem Input: temp1 = player index
          rem Output: Upward velocity if clear above
          gosub CCJ_ConvertPlayerXToPlayfieldColumn bank13
          gosub CCJ_FreeFlightUp
          return otherbank

          rem NINJISH GUY (10) - STANDARD JUMP (dispatched directly to StandardJump)
          rem PORK CHOP (11) - STANDARD JUMP (dispatched directly to StandardJump)
          rem RADISH GOBLIN (12) - STANDARD JUMP (dispatched directly to StandardJump)
          rem Removed redundant wrapper functions - DispatchCharacterJump calls StandardJump directly

RoboTitoJump
          asm
RoboTitoJump
end
          rem ROBO TITO (13) - Stretch to ceiling
          rem Input: temp1 = player index
          rem Output: Moves up 3px/frame, latches on ceiling contact
          if (characterStateFlags_R[temp1] & 1) then return
          if (playerState[temp1] & 4) then goto RoboTitoCannotStretch
          if characterSpecialAbility_R[temp1] = 0 then goto RoboTitoCannotStretch
          goto RoboTitoCanStretch

RoboTitoCannotStretch
          let missileStretchHeight_W[temp1] = 0
          return otherbank

RoboTitoCanStretch
RoboTitoStretching
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          gosub CCJ_ConvertPlayerXToPlayfieldColumn bank13
          let temp4 = temp2
          let temp2 = playerY[temp1] + 16
          let temp5 = temp2 / 16

GroundSearchLoop
          if temp5 >= pfrows then goto GroundSearchBottom
          let temp6 = 0
          let temp3 = temp1
          let temp1 = temp4
          let temp2 = temp5
          gosub PlayfieldRead bank16
          if temp1 then let temp6 = 1
          let temp1 = temp3
          if temp6 = 1 then goto GroundFound
          let temp5 = temp5 + 1
          goto GroundSearchLoop

GroundFound
          asm
            LDA temp5
            ASL
            ASL
            ASL
            ASL
            STA temp2
end
          goto GroundSearchDone

GroundSearchBottom
          let temp2 = ScreenBottom

GroundSearchDone
          let temp3 = playerY[temp1]
          let temp3 = temp3 - temp2
          if temp3 > 80 then temp3 = 80
          if temp3 < 1 then temp3 = 1
          let missileStretchHeight_W[temp1] = temp3
          let characterSpecialAbility_W[temp1] = 0
          if playerY[temp1] <= 5 then goto RoboTitoCheckCeiling
          let playerY[temp1] = playerY[temp1] - 3
          return otherbank

RoboTitoCheckCeiling
          gosub CCJ_ConvertPlayerXToPlayfieldColumn bank13
          let temp3 = playerY[temp1]
          if temp3 <= 0 then goto RoboTitoLatch
          let temp4 = temp3 / 16
          if temp4 <= 0 then goto RoboTitoLatch
          let temp4 = temp4 - 1
          let temp5 = temp1
          let temp1 = temp2
          let temp2 = temp4
          gosub PlayfieldRead bank16
          if temp1 then goto RoboTitoLatch
          let temp1 = temp5
          let playerY[temp1] = playerY[temp1] - 3
          return otherbank

RoboTitoLatch
          dim RTL_stateFlags = temp5
          let RTL_stateFlags = characterStateFlags_R[temp1] | 1
          let characterStateFlags_W[temp1] = RTL_stateFlags
          let playerState[temp1] = (playerState[temp1] & MaskPlayerStateFlags) | ActionJumpingShifted
          let temp2 = missileStretchHeight_R[temp1]
          if temp2 <= 0 then goto RTL_HeightCleared
          if temp2 > 25 then goto RTL_ReduceHeight
          let missileStretchHeight_W[temp1] = 0
          goto RTL_HeightCleared
RTL_ReduceHeight
          let temp2 = temp2 - 25
          let missileStretchHeight_W[temp1] = temp2
RTL_HeightCleared
          return otherbank

          rem URSULO (14) - STANDARD JUMP (dispatched directly to StandardJump)
          rem SHAMONE (15) - STANDARD JUMP (dispatched directly to StandardJump)
          rem Removed redundant wrapper functions - DispatchCharacterJump calls StandardJump directly
