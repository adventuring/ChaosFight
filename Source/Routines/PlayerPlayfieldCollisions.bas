          rem ChaosFight - Source/Routines/PlayerPlayfieldCollisions.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

CheckPlayfieldCollisionAllDirections
          asm
CheckPlayfieldCollisionAllDirections
end
          rem Check Playfield Collision All Directions
          rem Checks for playfield pixel collisions in all four directions and blocks movement by zeroing velocity.
          rem Uses CharacterHeights table for proper hitbox detection.
          rem
          rem Input: currentPlayer = player index (0-3)
          rem        playerX[], playerY[], playerCharacter[]
          rem        playerVelocityX[], playerVelocityY[], playerVelocityXL[], playerVelocityYL[]
          rem        playerSubpixelX[], playerSubpixelY[], playerSubpixelXL[], playerSubpixelYL[]
          rem        CharacterHeights[], ScreenInsetX, pfrowheight, pfrows
          rem
          rem Output: Player velocities zeroed when collisions detected
          rem
          rem Mutates: temp2-temp6, playfieldRow, playfieldColumn, rowCounter,
          rem           playerVelocityX[], playerVelocityY[],
          rem           playerVelocityXL[], playerVelocityYL[],
          rem           playerSubpixelX[], playerSubpixelY[],
          rem           playerSubpixelXL[], playerSubpixelYL[]
          rem
          rem Called Routines: PlayfieldRead (bank16)
          rem
          rem Constraints: Checks collisions at head, middle, and feet positions.
          let temp2 = playerX[currentPlayer]
          let temp3 = playerY[currentPlayer]
          let temp4 = playerCharacter[currentPlayer]
          let temp5 = CharacterHeights[temp4] / 16
          let temp6 = temp2 - ScreenInsetX
          let temp6 = temp6 / 4
          if temp6 & $80 then temp6 = 0
          if temp6 > 31 then temp6 = 31

          let playfieldRow = temp3 / 16
          if playfieldRow >= pfrows then let playfieldRow = pfrows - 1
          if playfieldRow & $80 then let playfieldRow = 0

          if temp6 = 0 then goto PFCheckRight

          let temp1 = temp6 - 1
          let temp3 = 0
          gosub PF_ProcessHorizontalCollision bank10

PFCheckRight
          if temp6 >= 31 then goto PFCheckUp

          let temp1 = temp6 + 4
          let temp3 = 1
          gosub PF_ProcessHorizontalCollision bank10

PFCheckUp
          if playfieldRow = 0 then goto PFCheckDown_Body

          let rowCounter = playfieldRow - 1
          let temp2 = rowCounter
          gosub PF_CheckRowColumns bank10
          if temp4 then goto PFBlockUp
          goto PFCheckDown_Body

PFBlockUp
          rem Skip zeroing velocity for Radish Goblin (bounce system handles it)
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then goto PFBlockUpClamp
          if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
PFBlockUpClamp
          let rowYPosition = playfieldRow + 1
          let rowYPosition = rowYPosition * 16
          if playerY[currentPlayer] < rowYPosition then let playerY[currentPlayer] = rowYPosition
          if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_W[currentPlayer] = rowYPosition
          if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_WL[currentPlayer] = 0
PFBlockDown
          rem Skip zeroing velocity for Radish Goblin (bounce system handles it)
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then return
          if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          return otherbank
PF_CheckColumnSpan
          asm
PF_CheckColumnSpan
end
          rem Helper: sample a column at up to three row offsets (top/mid/bottom)
          rem Input: playfieldColumn (global), playfieldRow (global top row), temp3 = row span
          rem Output: temp4 = 1 if any solid pixel encountered
          dim PCC_rowSpan = temp3
          dim PCC_result = temp4
          let PCC_result = 0
          let rowCounter = playfieldRow
          let temp3 = 0
PFCS_SampleLoop
          if rowCounter & $80 then goto PFCS_Advance
          if rowCounter >= pfrows then goto PFCS_Advance
          let temp1 = playfieldColumn
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let PCC_result = 1 : goto PFCS_Done
PFCS_Advance
          let temp3 = temp3 + 1
          if temp3 >= 3 then goto PFCS_Done
          if PCC_rowSpan = 0 then goto PFCS_Done
          let rowCounter = rowCounter + PCC_rowSpan
          goto PFCS_SampleLoop

PFCS_Done
          let temp4 = PCC_result
          return otherbank
PF_CheckRowColumns
          asm
PF_CheckRowColumns
end
          rem Helper: test current row for center/side collisions
          rem Input: temp2 = row index, temp6 = center column
          rem Output: temp4 = 1 if any column collides
          dim PRC_rowIndex = temp2
          dim PRC_result = temp4
          let PRC_result = 0
          if PRC_rowIndex & $80 then return otherbank
          if PRC_rowIndex >= pfrows then return otherbank

          let temp1 = temp6
          let temp2 = PRC_rowIndex
          gosub PlayfieldRead bank16
          if temp1 then let PRC_result = 1 : goto PRC_Done

          if temp6 > 0 then goto PRC_CheckLeft
          goto PRC_CheckRight
PRC_CheckLeft
          let temp1 = temp6 - 1
          let temp2 = PRC_rowIndex
          gosub PlayfieldRead bank16
          if temp1 then let PRC_result = 1 : goto PRC_Done
PRC_CheckRight
          if temp6 >= 31 then goto PRC_Done
          let temp1 = temp6 + 1
          let temp2 = PRC_rowIndex
          gosub PlayfieldRead bank16
          if temp1 then let PRC_result = 1
PRC_Done
          let temp4 = PRC_result
          return otherbank
PF_ProcessHorizontalCollision
          asm
PF_ProcessHorizontalCollision
end
          rem Helper: evaluate horizontal collision for given column and clamp
          rem Input: temp1 = column index, temp3 = direction (0=left, 1=right)
          dim PHC_column = temp1
          dim PHC_direction = temp3
          if PHC_column & $80 then return otherbank
          if PHC_column > 31 then return otherbank

          let playfieldColumn = PHC_column
          let temp3 = temp5
          gosub PF_CheckColumnSpan bank10
          if !temp4 then return otherbank

          let temp1 = currentPlayer
          if playerCharacter[temp1] = CharacterRadishGoblin then goto PHC_ClampOnly
          if PHC_direction then goto PHC_CheckRightVelocity
          if playerVelocityX[temp1] & $80 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0
          goto PHC_ClampOnly
PHC_CheckRightVelocity
          if playerVelocityX[temp1] > 0 then let playerVelocityX[temp1] = 0 : let playerVelocityXL[temp1] = 0
PHC_ClampOnly
          let rowYPosition = temp6
          if PHC_direction then goto PHC_ClampRight
          let rowYPosition = rowYPosition + 1
          let rowYPosition = rowYPosition * 4
          let rowYPosition = rowYPosition + ScreenInsetX
          if playerX[temp1] < rowYPosition then let playerX[temp1] = rowYPosition
          if playerX[temp1] < rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          if playerX[temp1] < rowYPosition then let playerSubpixelX_WL[temp1] = 0
          return otherbank
PHC_ClampRight
          let rowYPosition = rowYPosition - 1
          let rowYPosition = rowYPosition * 4
          let rowYPosition = rowYPosition + ScreenInsetX
          if playerX[temp1] > rowYPosition then let playerX[temp1] = rowYPosition
          if playerX[temp1] > rowYPosition then let playerSubpixelX_W[temp1] = rowYPosition
          if playerX[temp1] > rowYPosition then let playerSubpixelX_WL[temp1] = 0
          return otherbank
PFCheckDown_Body
          let rowCounter = playfieldRow + temp5
          if rowCounter >= pfrows then return

          let playfieldRow = rowCounter + 1
          if playfieldRow >= pfrows then return

          let temp2 = playfieldRow
          gosub PF_CheckRowColumns bank10
          if temp4 then goto PFBlockDown
          return otherbank

