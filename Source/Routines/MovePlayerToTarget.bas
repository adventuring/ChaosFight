          rem ChaosFight - Source/Routines/MovePlayerToTarget.bas
          rem Copyright © 2025 Bruce-Robert Pocock.
          rem Helper functions for falling animation player movement

MovePlayerToTarget
          rem Returns: Far (return otherbank)
          asm
MovePlayerToTarget

end
          rem Move player toward target position (called from FallingAnimation1)
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index (0-3)
          rem        temp2 = target X position
          rem        temp3 = target Y position
          rem Output: Player moved closer to target, or at target
          rem Mutates: playerX[], playerY[], temp4-temp6, distanceUp_W

          rem Update X axis (one pixel per frame)
          let temp4 = playerX[temp1]
          if temp4 < temp2 then let playerX[temp1] = temp4 + 1
          rem Update Y axis (one pixel per frame)
          if temp4 > temp2 then let playerX[temp1] = temp4 - 1
          let temp4 = playerY[temp1]
          if temp4 < temp3 then let playerY[temp1] = temp4 + 1
          rem Check if at target and nudge if needed
          if temp4 > temp3 then let playerY[temp1] = temp4 - 1
          if playerX[temp1] <> temp2 then gosub NudgePlayerFromPlayfield
          if playerY[temp1] <> temp3 then gosub NudgePlayerFromPlayfield
          return otherbank

NudgePlayerFromPlayfield
          rem Returns: Far (return otherbank)
          asm
NudgePlayerFromPlayfield
end
          rem Nudge player away from playfield collision
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index
          rem Output: Player position adjusted to avoid playfield
          let originalPlayerX_W = playerX[temp1]
          let originalPlayerY_W = playerY[temp1]
          gosub MPT_NudgeRight

          gosub MPT_NudgeLeft

          return otherbank

MPT_NudgeRight
          rem Returns: Far (return otherbank)
          asm
MPT_NudgeRight
end
          let playerX[temp1] = originalPlayerX_R + 1
          gosub MPT_CheckCollision

          if temp6 = 1 then let playerX[temp1] = originalPlayerX_R
          return otherbank

MPT_NudgeLeft
          rem Returns: Far (return otherbank)
          asm
MPT_NudgeLeft
end
          let playerX[temp1] = originalPlayerX_R - 1
          gosub MPT_CheckCollision

          if temp6 = 1 then let playerX[temp1] = originalPlayerX_R
          return otherbank

MPT_CheckCollision
          rem Returns: Far (return otherbank)
          asm
MPT_CheckCollision
end
          rem Check collision at current position
          rem Returns: Far (return otherbank)
          rem Input: temp1 = player index, playerX[temp1] = test position, originalPlayerY_R = Y
          rem Output: temp6 = 1 if collision, 0 if clear
          let temp2 = playerX[temp1] - ScreenInsetX
          let temp2 = temp2 / 4
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          let temp3 = originalPlayerY_R
          let temp5 = temp3 / 16
          let temp6 = 0
          let temp4 = temp1
          let temp1 = temp2
          let temp2 = temp5
          gosub PlayfieldRead bank16
          if temp1 then let temp6 = 1
          let temp1 = temp4
          let temp3 = temp3 + 16
          let temp5 = temp3 / 16
          rem MovePlayerToTarget is called cross-bank, so all return otherbank paths must use return otherbank
          if temp5 < pfrows then let temp4 = temp1 : let temp1 = temp2 : let temp2 = temp5 : gosub PlayfieldRead bank16 : if temp1 then let temp6 = 1 : let temp1 = temp4
          return otherbank
