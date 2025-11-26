          rem ChaosFight - Source/Routines/RoboTitoJump.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem
          rem Robo Tito stretch-and-latch jump routine relocated from Bank 12
          rem to Bank 10 to relieve pressure on CharacterControlsJump.

RoboTitoJump
          asm
RoboTitoJump
end
          rem ROBO TITO (13) - Stretch to ceiling
          rem Input: temp1 = player index
          rem Output: Moves up 3px/frame, latches on ceiling contact
          if (characterStateFlags_R[temp1] & 1) then return thisbank
          if (playerState[temp1] & 4) then goto RoboTitoCannotStretch
          if characterSpecialAbility_R[temp1] = 0 then goto RoboTitoCannotStretch
          goto RoboTitoCanStretch

RoboTitoCannotStretch
          let missileStretchHeight_W[temp1] = 0
          return thisbank
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
          let temp2 = temp5 / 16
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
          return thisbank
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
          return thisbank
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
          return thisbank

