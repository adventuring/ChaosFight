          rem ChaosFight - Source/Routines/MovePlayerToTarget.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.
          rem Helper functions for falling animation player movement

MovePlayerToTarget
          rem Move player toward target position (called from FallingAnimation1)
          rem Input: temp1 = player index (0-3)
          rem        temp2 = target X position
          rem        temp3 = target Y position
          rem Output: Player moved closer to target, or at target
          rem Mutates: playerX[], playerY[], temp4-temp6, distanceUp_W
          
          rem Calculate X distances
          gosub CalcDeltaXRight
          gosub CalcDeltaXLeft

          rem Calculate Y distances
          gosub CalcDeltaYDown
          gosub CalcDeltaYUp

          rem Move in X direction first
          if temp4 > 0 then gosub MoveRight
          if temp5 > 0 then gosub MoveLeft

          rem Then move in Y direction
          if temp6 > 0 then gosub MoveDown
          if distanceUp_W > 0 then gosub MoveUp
          
          rem Check if at target
          gosub AtTarget
          return

CalcDeltaXRight
          rem Calculate X distance to the right
          rem Input: temp1 = player, temp2 = target X
          rem Output: temp4 = distance right (0 if at or left of target)
          let temp4 = temp2 - playerX[temp1]
          if temp4 < 0 then temp4 = 0
DeltaXDone
          return

CalcDeltaYDown
          rem Calculate Y distance downward
          rem Input: temp1 = player, temp3 = target Y  
          rem Output: temp6 = distance down (0 if at or above target)
          let temp6 = temp3 - playerY[temp1]
          if temp6 < 0 then temp6 = 0
DeltaYDone
          return

CalcDeltaXLeft
          rem Calculate X distance to the left
          rem Input: temp1 = player, temp2 = target X
          rem Output: temp5 = distance left (0 if at or right of target)
          let temp5 = playerX[temp1] - temp2
          if temp5 < 0 then temp5 = 0
          return

CalcDeltaYUp
          rem Calculate Y distance upward
          rem Input: temp1 = player, temp3 = target Y
          rem Output: distanceUp_W = distance up (0 if at or below target)
          let distanceUp_W = playerY[temp1] - temp3
          if distanceUp_W < 0 then distanceUp_W = 0
          return

MoveRight
          rem Move player right by 1 pixel
          rem Input: temp1 = player index
          rem Output: playerX[temp1] incremented
          let playerX[temp1] = playerX[temp1] + 1
HorizontalDone
          return

MoveLeft
          rem Move player left by 1 pixel
          rem Input: temp1 = player index
          rem Output: playerX[temp1] decremented
          let playerX[temp1] = playerX[temp1] - 1
          return

MoveDown
          rem Move player down by 1 pixel
          rem Input: temp1 = player index
          rem Output: playerY[temp1] incremented
          let playerY[temp1] = playerY[temp1] + 1
VerticalDone
          return

MoveUp
          rem Move player up by 1 pixel
          rem Input: temp1 = player index
          rem Output: playerY[temp1] decremented
          let playerY[temp1] = playerY[temp1] - 1
          return

AtTarget
          rem Check if player is at target position
          rem Input: temp1 = player, temp2 = target X, temp3 = target Y
          rem Output: Returns if at target, otherwise calls nudge functions
          if playerX[temp1] <> temp2 then gosub NudgePlayerFromPlayfield
          if playerY[temp1] <> temp3 then gosub NudgePlayerFromPlayfield
          return

NudgePlayerFromPlayfield
          rem Nudge player away from playfield collision
          rem Input: temp1 = player index
          rem Output: Player position adjusted to avoid playfield
          gosub NudgeFromPF
          return

NudgeFromPF
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
          return

NudgeRight
          rem Check if nudging right avoids collision
          rem Input: temp1 = player, originalPlayerX_W = original X, originalPlayerY_W = original Y
          rem Output: playerX adjusted if collision detected
          let playerX[temp1] = originalPlayerX_W + 1
          if collision(playerX[temp1], originalPlayerY_W) then let playerX[temp1] = originalPlayerX_W
          return

NudgeLeft
          rem Check if nudging left avoids collision
          rem Input: temp1 = player, originalPlayerX_W = original X, originalPlayerY_W = original Y
          rem Output: playerX adjusted if collision detected
          let playerX[temp1] = originalPlayerX_W - 1
          if collision(playerX[temp1], originalPlayerY_W) then let playerX[temp1] = originalPlayerX_W
          return

NudgeVertical
          rem Vertical nudging (placeholder for future use)
          gosub NudgeDown
          gosub NudgeUp
          return

NudgeDown
          rem Check downward nudge (placeholder)
          return

NudgeUp  
          rem Check upward nudge (placeholder)
          return
