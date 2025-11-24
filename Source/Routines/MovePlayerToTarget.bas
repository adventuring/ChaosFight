          rem ChaosFight - Source/Routines/MovePlayerToTarget.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Helper functions for falling animation player movement

MovePlayerToTarget
          asm
MovePlayerToTarget

end
          rem Move player toward target position (called from FallingAnimation1)
          rem Input: temp1 = player index (0-3)
          rem        temp2 = target X position
          rem        temp3 = target Y position
          rem Output: Player moved closer to target, or at target
          rem Mutates: playerX[], playerY[], temp4-temp6, distanceUp_W

          rem Update X axis (one pixel per frame)
          let temp4 = playerX[temp1]
          if temp4 < temp2 then goto MovePlayerRight
          if temp4 > temp2 then goto MovePlayerLeft
          goto MovePlayerCheckVertical
MovePlayerRight
          let playerX[temp1] = temp4 + 1
          goto MovePlayerCheckVertical
MovePlayerLeft
          let playerX[temp1] = temp4 - 1
MovePlayerCheckVertical
          rem Update Y axis (one pixel per frame)
          let temp4 = playerY[temp1]
          if temp4 < temp3 then goto MovePlayerDown
          if temp4 > temp3 then goto MovePlayerUp
          goto MovePlayerCheckTarget
MovePlayerDown
          let playerY[temp1] = temp4 + 1
          goto MovePlayerCheckTarget
MovePlayerUp
          let playerY[temp1] = temp4 - 1
MovePlayerCheckTarget
          rem Check if at target
          gosub AtTarget
          return otherbank

AtTarget
          asm
AtTarget
end
          rem Check if player is at target position
          rem Input: temp1 = player, temp2 = target X, temp3 = target Y
          rem Output: Returns if at target, otherwise calls nudge functions
          if playerX[temp1] = temp2 then goto CheckY
          gosub NudgePlayerFromPlayfield
CheckY
          if playerY[temp1] = temp3 then return otherbank
          gosub NudgePlayerFromPlayfield
          return otherbank

NudgePlayerFromPlayfield
          asm
NudgePlayerFromPlayfield

end
          rem Nudge player away from playfield collision
          rem Input: temp1 = player index
          rem Output: Player position adjusted to avoid playfield
          gosub NudgeFromPF
          return otherbank

NudgeFromPF
          asm
NudgeFromPF
end
          rem Detect playfield collision and nudge accordingly
          rem Input: temp1 = player index (preserved)
          rem Output: Player nudged right/left based on collision
          let originalPlayerX_W = playerX[temp1]
          let originalPlayerY_W = playerY[temp1]

          rem Check right nudge needed
          gosub NudgeRight

          rem Check left nudge needed
          gosub NudgeLeft
NudgeHorizontalDone
          return otherbank

NudgeRight
          asm
NudgeRight

end
          rem Check if nudging right avoids collision
          rem Input: temp1 = player, originalPlayerX_W = original X, originalPlayerY_W = original Y
          rem Output: playerX adjusted if no collision detected
          let playerX[temp1] = originalPlayerX_W + 1

          rem Check for collision at new position
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          rem Handle wraparound

          let temp3 = originalPlayerY_W
          let temp4 = temp3
          let temp5 = temp3
          asm
            lsr temp5
            lsr temp5
            lsr temp5
            lsr temp5
end
          rem temp5 = top row

          let temp6 = 0
          rem Reset collision flag
          let temp4 = temp1
          let temp1 = temp2
          let temp2 = temp5
          gosub PlayfieldRead bank16
          if temp1 then let temp6 = 1
          let temp1 = temp4

          rem Check bottom row too
          let temp3 = temp3 + 16
          let temp4 = temp3
          let temp2 = temp3
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp5 = temp2
          if temp5 < pfrows then let temp4 = temp1 : let temp1 = temp2 : let temp2 = temp5 : gosub PlayfieldRead bank16 : if temp1 then let temp6 = 1 : let temp1 = temp4

          rem If collision detected, revert position
          if temp6 = 1 then let playerX[temp1] = originalPlayerX_W
          return otherbank

NudgeLeft
          asm
NudgeLeft

end
          rem Check if nudging left avoids collision
          rem Input: temp1 = player, originalPlayerX_W = original X, originalPlayerY_W = original Y
          rem Output: playerX adjusted if no collision detected
          let playerX[temp1] = originalPlayerX_W - 1

          rem Check for collision at new position
          let temp2 = playerX[temp1]
          let temp2 = temp2 - ScreenInsetX
          let temp2 = temp2 / 4
          rem temp2 = playfield column
          if temp2 > 31 then temp2 = 31
          if temp2 & $80 then temp2 = 0
          rem Handle wraparound

          let temp3 = originalPlayerY_W
          let temp4 = temp3
          let temp2 = temp3
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp5 = temp2
          rem temp5 = top row

          let temp6 = 0
          rem Reset collision flag
          let temp4 = temp1
          let temp1 = temp2
          let temp2 = temp5
          gosub PlayfieldRead bank16
          if temp1 then let temp6 = 1
          let temp1 = temp4

          rem Check bottom row too
          let temp3 = temp3 + 16
          let temp4 = temp3
          let temp2 = temp3
          asm
            lsr temp2
            lsr temp2
            lsr temp2
            lsr temp2
end
          let temp5 = temp2
          if temp5 < pfrows then let temp4 = temp1 : let temp1 = temp2 : let temp2 = temp5 : gosub PlayfieldRead bank16 : if temp1 then let temp6 = 1 : let temp1 = temp4

          rem If collision detected, revert position
          if temp6 = 1 then let playerX[temp1] = originalPlayerX_W
          return otherbank

