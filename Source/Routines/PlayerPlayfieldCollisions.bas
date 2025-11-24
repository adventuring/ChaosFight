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
          let temp5 = CharacterHeights[temp4]

          let temp6 = temp2
          let temp6 = temp6 - ScreenInsetX
          asm
            lsr temp6
            lsr temp6
end
          if temp6 & $80 then temp6 = 0
          if temp6 > 31 then temp6 = 31

          let playfieldRow = temp3 / 16
          if playfieldRow >= pfrows then let playfieldRow = pfrows - 1
          if playfieldRow & $80 then let playfieldRow = 0

          if temp6 = 0 then goto PFCheckRight

          let playfieldColumn = temp6 - 1
          if playfieldColumn & $80 then goto PFCheckRight

          let temp4 = 0
          let temp1 = playfieldColumn
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockLeft
          asm
            lda temp5
            lsr
            lsr
            lsr
            lsr
            sta temp2
end
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckRight
          let temp1 = playfieldColumn
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockLeft
          let temp2 = temp5 / 16
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckRight
          let temp1 = playfieldColumn
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockLeft

          goto PFCheckRight

PFBlockLeft
          rem Skip zeroing velocity for Radish Goblin (bounce system handles it)
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then goto PFBlockLeftClamp
          if playerVelocityX[currentPlayer] & $80 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
PFBlockLeftClamp
          let rowYPosition = temp6 + 1
          asm
            lda rowYPosition
            asl
            asl
            clc
            adc #ScreenInsetX
            sta rowYPosition
end
          if playerX[currentPlayer] < rowYPosition then let playerX[currentPlayer] = rowYPosition
          if playerX[currentPlayer] < rowYPosition then let playerSubpixelX_W[currentPlayer] = rowYPosition
          if playerX[currentPlayer] < rowYPosition then let playerSubpixelX_WL[currentPlayer] = 0

PFCheckRight
          if temp6 >= 31 then goto PFCheckUp

          let playfieldColumn = temp6 + 4
          if playfieldColumn > 31 then goto PFCheckUp

          let temp4 = 0
          let temp1 = playfieldColumn
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockRight
          asm
            lda temp5
            lsr a
            lsr a
            lsr a
            lsr a
            sta temp2
end
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckUp
          let temp1 = playfieldColumn
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockRight
          let temp2 = temp5 / 16
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then goto PFCheckUp
          let temp1 = playfieldColumn
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockRight

          goto PFCheckUp

PFBlockRight
          rem Skip zeroing velocity for Radish Goblin (bounce system handles it)
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then goto PFBlockRightClamp
          if playerVelocityX[currentPlayer] > 0 then let playerVelocityX[currentPlayer] = 0 : let playerVelocityXL[currentPlayer] = 0
PFBlockRightClamp
          let rowYPosition = temp6 - 1
          asm
            lda rowYPosition
            asl a
            asl a
            clc
            adc #ScreenInsetX
            sta rowYPosition
end
          if playerX[currentPlayer] > rowYPosition then let playerX[currentPlayer] = rowYPosition
          if playerX[currentPlayer] > rowYPosition then let playerSubpixelX_W[currentPlayer] = rowYPosition
          if playerX[currentPlayer] > rowYPosition then let playerSubpixelX_WL[currentPlayer] = 0

PFCheckUp
          if playfieldRow = 0 then goto PFCheckDown_Body

          let rowCounter = playfieldRow - 1
          if rowCounter & $80 then goto PFCheckDown_Body

          let temp4 = 0
          let temp1 = temp6
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockUp
          if temp6 = 0 then goto PFCheckUp_CheckRight
          let playfieldColumn = temp6 - 1
          let temp1 = playfieldColumn
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockUp
PFCheckUp_CheckRight
          if temp6 >= 31 then goto PFCheckDown_Body
          let playfieldColumn = temp6 + 1
          let temp1 = playfieldColumn
          let temp2 = rowCounter
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockUp

          goto PFCheckDown_Body

PFBlockUp
          rem Skip zeroing velocity for Radish Goblin (bounce system handles it)
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then goto PFBlockUpClamp
          if playerVelocityY[currentPlayer] & $80 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
PFBlockUpClamp
          let rowYPosition = playfieldRow + 1
          asm
            lda rowYPosition
            asl a
            asl a
            asl a
            asl a
            sta rowYPosition
end
          if playerY[currentPlayer] < rowYPosition then let playerY[currentPlayer] = rowYPosition
          if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_W[currentPlayer] = rowYPosition
          if playerY[currentPlayer] < rowYPosition then let playerSubpixelY_WL[currentPlayer] = 0
PFBlockDown
          rem Skip zeroing velocity for Radish Goblin (bounce system handles it)
          if playerCharacter[currentPlayer] = CharacterRadishGoblin then return
          if playerVelocityY[currentPlayer] > 0 then let playerVelocityY[currentPlayer] = 0 : let playerVelocityYL[currentPlayer] = 0
          return

PFCheckDown_Body
          let temp2 = temp5 / 16
          let rowCounter = playfieldRow + temp2
          if rowCounter >= pfrows then return

          let playfieldRow = rowCounter + 1
          if playfieldRow >= pfrows then return

          let temp4 = 0
          let temp1 = temp6
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockDown
          if temp6 = 0 then goto PFCheckDown_CheckRight
          let playfieldColumn = temp6 - 1
          let temp1 = playfieldColumn
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockDown
PFCheckDown_CheckRight
          if temp6 >= 31 then return
          let playfieldColumn = temp6 + 1
          let temp1 = playfieldColumn
          let temp2 = playfieldRow
          gosub PlayfieldRead bank16
          if temp1 then let temp4 = 1
          if temp4 = 1 then goto PFBlockDown

          return

CheckPlayfieldCollisionUpDone
          return


